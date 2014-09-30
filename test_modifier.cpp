#define DEBUG_TYPE "mxpa_ms4"

// LLVM includes
#include "llvm/Support/Debug.h"
#include "llvm/Bitcode/ReaderWriter.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/Instruction.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Constant.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Bitcode/ReaderWriter.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Analysis/Verifier.h"
#include "llvm/ADT/DepthFirstIterator.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/IRReader/IRReader.h"

// MxPA includes
#include "test_modifier.h"

namespace SpmdKernel {

using namespace llvm;

namespace Coarsening {

  cl::list<int> LocalSize("local-size", cl::desc("local size (x y z)"), cl::multi_val(3));

  char TestMod::ID = 0;
  
  namespace {
    static
    RegisterPass<TestMod> DFIModulePass("mxpa_testmod", 
      "replace problematic get_x calls with contant number");

    static IRBuilder<> Builder(getGlobalContext());
  }

  bool TestMod::runOnModule(Module &M) {
    bool Changed = false;

    for (Module::iterator FI = M.begin(), FE = M.end(); FI != FE; ++FI) {
      if (FI->isDeclaration())
        continue;

      Function *F = FI;

      LocalSizeX = LocalSize[0];
      LocalSizeY = LocalSize[1];
      LocalSizeZ = LocalSize[2];

      errs() << "---> " << FI->getName() << "\n";
      std::vector<Instruction*> CallsToErase;
      for (Function::iterator BI = F->begin(), BE = F->end(); BI != BE; ++BI) {
        BasicBlock *B = BI;

        for (BasicBlock::iterator II = B->begin(), IE = B->end(); 
             II != IE; ++II) {
          Instruction *inst = II;

          if (isa<CallInst>(inst)) {

            CallInst *a_call = cast<CallInst>(inst);

            // -- get_global_offset
            ConstantInt *GGOReplVal = ConstantInt::get(IntegerType::get(getGlobalContext(), 32), 0);
            ReplaceCallsWithConstant(a_call, "get_global_offset", GGOReplVal, 0, CallsToErase);
            ReplaceCallsWithConstant(a_call, "get_global_offset", GGOReplVal, 1, CallsToErase);
            ReplaceCallsWithConstant(a_call, "get_global_offset", GGOReplVal, 2, CallsToErase);

            // --- get_group_id
            ConstantInt *GGIReplVal = ConstantInt::get(IntegerType::get(getGlobalContext(), 32), 0);
            ReplaceCallsWithConstant(a_call, "get_group_id", GGIReplVal, 0, CallsToErase);
            ReplaceCallsWithConstant(a_call, "get_group_id", GGIReplVal, 1, CallsToErase);
            ReplaceCallsWithConstant(a_call, "get_group_id", GGIReplVal, 2, CallsToErase);


            // --- get_local_size
            ConstantInt *GLSReplVal0 = ConstantInt::get(IntegerType::get(getGlobalContext(), 32), LocalSizeX);
            ReplaceCallsWithConstant(a_call, "get_local_size", GLSReplVal0, 0, CallsToErase);
           
            ConstantInt *GLSReplVal1 = ConstantInt::get(IntegerType::get(getGlobalContext(), 32), LocalSizeY);
            ReplaceCallsWithConstant(a_call, "get_local_size", GLSReplVal1, 1, CallsToErase);
            
            ConstantInt *GLSReplVal2 = ConstantInt::get(IntegerType::get(getGlobalContext(), 32), LocalSizeZ);
            ReplaceCallsWithConstant(a_call, "get_local_size", GLSReplVal2, 2, CallsToErase);
          }
 
        }
      }

      for (std::vector<Instruction*>::iterator i = CallsToErase.begin(), 
              e = CallsToErase.end(); i != e; ++i) {
          (*i)->eraseFromParent();
      } 

    }
    return Changed;
  }
   
  StringRef TestMod::getCalledFunctionName(CallInst *Call) {
    Function *fun = Call->getCalledFunction();
    if (fun) 
      return fun->getName(); 
    else
      return StringRef("indirect call");
  }

  void TestMod::ReplaceCallsWithConstant(CallInst *a_call, StringRef builtin_fn, 
                                         ConstantInt *ReplVal,
                                         int dimindx,
                                         std::vector<Instruction*> &CallsToErase) 
  {
    StringRef called_func_nm = getCalledFunctionName(a_call);
    if (called_func_nm == builtin_fn) {
      Value *get_local_id_arg = a_call->getArgOperand(0);
      ConstantInt *CI = dyn_cast<ConstantInt>(get_local_id_arg);

      ConstantInt *DK_CI = ConstantInt::get(IntegerType::get(getGlobalContext(),32), 
                                            dimindx);

      if (CI == DK_CI) {
        Builder.SetInsertPoint(a_call);

        AllocaInst *AI = Builder.CreateAlloca(
          IntegerType::get(getGlobalContext(),32), 
          0, a_call->getName()+".gaimod"
        );

        //ConstantInt *ReplVal = ConstantInt::get(IntegerType::get(getGlobalContext(), 32), 1);
        
        StoreInst *SI = Builder.CreateStore(ReplVal, AI);
        LoadInst *LI = Builder.CreateLoad(AI, ".gaild");
        a_call->replaceAllUsesWith(LI);
    
        CallsToErase.push_back(a_call); 
      }
    }
  }

 
}
}
