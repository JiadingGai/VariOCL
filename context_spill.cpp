#define DEBUG_TYPE "mxpa_contextspill"

// LLVM includes
#include "llvm/IR/Constants.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/Local.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/IR/Type.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#ifdef LLVM_34
#include "llvm/Analysis/CFG.h"
#elif LLVM_33
#include "llvm/Support/CFG.h"
#endif
#include "llvm/Support/SourceMgr.h"
#include "llvm/IRReader/IRReader.h"

// std includes
#include <list>

// MxPA includes
#include "context_spill.h"
#include "barrier_utils.h"
#include "barrier_inst.h"
#include "kernel_info_reader.h"

#define CONTEXT_ARRAY_ALIGN 64

STATISTIC(NumValsSpilled, "Number of values spilled onto a 3D stack slot");
STATISTIC(NumPhisSpilled, "Number of PHIs spilled onto a 3D stack slot");

namespace SpmdKernel {

using namespace llvm;

namespace Coarsening {

  char ContextSpill::ID = 0;

  namespace {
    static
    RegisterPass<ContextSpill> X ("mxpa_context_spill",
      "spill values that are used outside its own BB to a 3D stack slot");

    static IRBuilder<> Builder(getGlobalContext());
  }

  bool ContextSpill::runOnFunction(Function &F) {
    if (F.isDeclaration())
      return false;

    // Insert all new allocas into entry block.
    BasicBlock *BBEntry = &F.getEntryBlock();
    assert(pred_begin(BBEntry) == pred_end(BBEntry) &&
           "Entry block to function must not have predecessors!");

    assert(containsJustABarrier(BBEntry) && 
           "F's entry BB is not a barrier BB (forgot hive off barriers?)!");

#if 0
    BasicBlock *BBNewEntry = SplitBlock(BBEntry, BBEntry->getTerminator(), this);
#elif 1
    BasicBlock *BBNewEntry = BBEntry;
#endif
    Instruction *InstNewEntry = &BBNewEntry->front();
    for (int i = 0; i < 3; ++i) {
      Lsz[i] = insertCallToGetX("get_local_size", i, F.getParent(), F.getContext(), 
                                InstNewEntry);
    }

    Builder.SetInsertPoint(InstNewEntry);
    Flat3DSize = Builder.CreateMul(
                   Builder.CreateMul(Lsz[2], Lsz[1]), Lsz[0], "Flat3DSize");
 
    // Find first non-alloca instruction and create insertion point. This is
    // safe if block is well-formed: it always have terminator, otherwise
    // we'll get and assertion.
#if 0
    BasicBlock::iterator I = BBNewEntry->begin();
    while (isa<AllocaInst>(I)) ++I;

    CastInst *AllocaInsertionPoint =
      new BitCastInst(Constant::getNullValue(Type::getInt32Ty(F.getContext())),
                      Type::getInt32Ty(F.getContext()),
                      "value spilling alloca point", I);
#endif

    CastInst *AllocaInsertionPoint =
      new BitCastInst(Constant::getNullValue(Type::getInt32Ty(F.getContext())),
                      Type::getInt32Ty(F.getContext()),
                      "value spilling alloca point", InstNewEntry);

    // Find the escaped instructions. But don't create stack slots for
    // allocas in entry block.
    std::list<Instruction*> WorkList;
    for (Function::iterator ibb = F.begin(), ibe = F.end();
         ibb != ibe; ++ibb) {
      for (BasicBlock::iterator iib = ibb->begin(), iie = ibb->end();
           iib != iie; ++iib) {
        if (isValueEscaped(iib)) {
          WorkList.push_front(&*iib);
        }
      }
    }

    // Spill escaped instructions
    NumValsSpilled += WorkList.size();
    for (std::list<Instruction*>::iterator ilb = WorkList.begin(),
         ile = WorkList.end(); ilb != ile; ++ilb)
      DemoteRegToStack(**ilb, false, AllocaInsertionPoint);

    WorkList.clear();

    // Find all phi's
    for (Function::iterator ibb = F.begin(), ibe = F.end();
         ibb != ibe; ++ibb)
      for (BasicBlock::iterator iib = ibb->begin(), iie = ibb->end();
           iib != iie; ++iib)
        if (isa<PHINode>(iib))
          WorkList.push_front(&*iib);

    // Spill phi nodes
    NumPhisSpilled += WorkList.size();
    for (std::list<Instruction*>::iterator ilb = WorkList.begin(),
         ile = WorkList.end(); ilb != ile; ++ilb)
      DemotePHIToStack(cast<PHINode>(*ilb), AllocaInsertionPoint);

    return true;
  }

  bool ContextSpill::isValueEscaped(const Instruction *Inst) const 
  {
    const BasicBlock *BB = Inst->getParent();
    for (Value::const_use_iterator UI = Inst->use_begin(),E = Inst->use_end();
         UI != E; ++UI) {
      const Instruction *I = cast<Instruction>(*UI);
      if (I->getParent() != BB || isa<PHINode>(I))
        return true;
    }
    return false; 
  }

  AllocaInst *ContextSpill::DemoteRegToStack(Instruction &I, bool VolatileLoads,
                                   Instruction *AllocaPoint) 
  {
    if (I.use_empty()) {
      I.eraseFromParent();
      return 0;
    }

    // Create a stack slot to hold the value.
    AllocaInst *Slot;
    if (AllocaPoint) {
#if 0
      Slot = new AllocaInst(I.getType(), 0,
                            I.getName()+".valspl", AllocaPoint);
#else
      Slot = insert3DAllocaFor(I, AllocaPoint);
#endif
    } else {
      Function *F = I.getParent()->getParent();
#if 0      
      Slot = new AllocaInst(I.getType(), 0, I.getName()+".valspl",
                            F->getEntryBlock().begin());
#else
      Slot = insert3DAllocaFor(I, F->getEntryBlock().begin());
#endif
    }

    // Change all of the users of the instruction to read from the stack slot.
    while (!I.use_empty()) {
      Instruction *U = cast<Instruction>(I.use_back());
      if (PHINode *PN = dyn_cast<PHINode>(U)) {
        DenseMap<BasicBlock*, Value*> Loads;
        for (unsigned i = 0, e = PN->getNumIncomingValues(); i != e; ++i)
          if (PN->getIncomingValue(i) == &I) {
            Value *&V = Loads[PN->getIncomingBlock(i)];
            if (V == 0) {
              // Insert the load into the predecessor block
#if 0
              V = new LoadInst(Slot, I.getName()+".reload", VolatileLoads,
                               PN->getIncomingBlock(i)->getTerminator());
#else
              V = insert3DLoadFor(*Slot, 
                                  PN->getIncomingBlock(i)->getTerminator());
#endif
            }
            PN->setIncomingValue(i, V);
          }

      } else {
        // If this is a normal instruction, just insert a load.
#if 0
        Value *V = new LoadInst(Slot, I.getName()+".reload", VolatileLoads, U);
#else
        Value *V = insert3DLoadFor(*Slot, U);
#endif
        U->replaceUsesOfWith(&I, V);
      }
    }

    // Insert stores of the computed value into the stack slot. We have to be
    // careful if I is an invoke instruction, because we can't insert the store
    // AFTER the terminator instruction.
    BasicBlock::iterator InsertPt;
    if (!isa<TerminatorInst>(I)) {
      InsertPt = &I;
      ++InsertPt;
    } else {
      InvokeInst &II = cast<InvokeInst>(I);
      if (II.getNormalDest()->getSinglePredecessor())
        InsertPt = II.getNormalDest()->getFirstInsertionPt();
      else {
        unsigned SuccNum = GetSuccessorNumber(I.getParent(), II.getNormalDest());
        TerminatorInst *TI = &cast<TerminatorInst>(I);
        assert (isCriticalEdge(TI, SuccNum) &&
                "Expected a critical edge!");
        BasicBlock *BB = SplitCriticalEdge(TI, SuccNum);
        assert (BB && "Unable to split critical edge.");
        InsertPt = BB->getFirstInsertionPt();
      }
    }

    for (; isa<PHINode>(InsertPt) || isa<LandingPadInst>(InsertPt); ++InsertPt)
      /* empty */;

#if 0
    new StoreInst(&I, Slot, InsertPt);
#else
    insert3DStoreFor(I, Slot, InsertPt);
#endif
    return Slot;
  }

  AllocaInst *ContextSpill::DemotePHIToStack(PHINode *P, Instruction *AllocaPoint) 
  {
    if (P->use_empty()) {
      P->eraseFromParent();
      return 0;
    }
  
    // Create a stack slot to hold the value.
    AllocaInst *Slot;
    if (AllocaPoint) {
#if 0
      Slot = new AllocaInst(P->getType(), 0,
                            P->getName()+".valspl", AllocaPoint);
#else
      Slot = insert3DAllocaFor(*P, AllocaPoint);
#endif
    } else {
      Function *F = P->getParent()->getParent();
#if 0
      Slot = new AllocaInst(P->getType(), 0, P->getName()+".valspl",
                            F->getEntryBlock().begin());
#else
      Slot = insert3DAllocaFor(*P, F->getEntryBlock().begin());
#endif
    }
  
    // Iterate over each operand inserting a store in each predecessor.
    for (unsigned i = 0, e = P->getNumIncomingValues(); i < e; ++i) {
      if (InvokeInst *II = dyn_cast<InvokeInst>(P->getIncomingValue(i))) {
        assert(II->getParent() != P->getIncomingBlock(i) &&
               "Invoke edge not supported yet"); (void)II;
      }
#if 0
      new StoreInst(P->getIncomingValue(i), Slot,
                    P->getIncomingBlock(i)->getTerminator());
#else
      insert3DStoreFor(*(P->getIncomingValue(i)), Slot, 
                       P->getIncomingBlock(i)->getTerminator());
#endif
    }
  
    BasicBlock::iterator InsertPt = P;
  
    for (; isa<PHINode>(InsertPt) || isa<LandingPadInst>(InsertPt); ++InsertPt)
      /* empty */;

#if 0
    Value *V = new LoadInst(Slot, P->getName()+".reload", InsertPt);
#else
    Value *V = insert3DLoadFor(*Slot, InsertPt);
#endif 

    P->replaceAllUsesWith(V);
  
    // Delete PHI.
    P->eraseFromParent();
    return Slot;
  }

  CallInst* 
  ContextSpill::insertCallToGetX(std::string FuncName, 
                                 int dimindx, Module *M, 
                                 LLVMContext &Context, 
                                 Instruction *InsertBefore)
  {
     Function *GetXF =
       cast<Function>(M->getOrInsertFunction(FuncName, 
                                             Type::getInt32Ty(Context),
                                             Type::getInt32Ty(Context),
                                             (Type *)0));

     Value *DimIndx = ConstantInt::get(Type::getInt32Ty(Context), dimindx);

     CallInst *CallGetX = 
       CallInst::Create(GetXF, DimIndx, FuncName, InsertBefore);
    
     return CallGetX;
  }


  AllocaInst* 
  ContextSpill::insert3DAllocaFor(Instruction &I,
                                  Instruction *InsertBefore)
  {
    AllocaInst *AI;

    Type *contextArrayElemType = I.getType();
    AI = new AllocaInst(contextArrayElemType, Flat3DSize, 
                        I.getName()+".3Dspill", InsertBefore);

    return AI;
  }

  LoadInst*
  ContextSpill::insert3DLoadFor(Instruction &I,
                                Instruction *InsertBefore)
  {
    Function *F = I.getParent()->getParent();
    CallInst *Lid[3] = {NULL, NULL, NULL};
    for (int i = 0; i < 3; ++i) {
      Lid[i] = insertCallToGetX("get_local_id", i, F->getParent(),
                                F->getContext(), InsertBefore);
    }
    
    Builder.SetInsertPoint(InsertBefore);
    Value *FlatIdx = Builder.CreateAdd(
                       Builder.CreateAdd(
                         Builder.CreateMul(Builder.CreateMul(Lid[2], Lsz[0]), 
                                           Lsz[1]),
                         Builder.CreateMul(Lid[1], Lsz[0])
                       ),
                       Lid[0], "FlatIdx");

    std::vector<Value *> GepOffsets;
    //GepOffsets.push_back(
    //  ConstantInt::get(IntegerType::get(I.getContext(), 32), 0)
    //);
    GepOffsets.push_back(FlatIdx);

    GetElementPtrInst *Gep = GetElementPtrInst::Create(&I, GepOffsets, 
                               I.getName()+".gep", InsertBefore);

    LoadInst *LI = new LoadInst(Gep, I.getName()+"3dreload", InsertBefore);

    return LI;
  }

  StoreInst*
  ContextSpill::insert3DStoreFor(Value &I, Instruction *Alloca,
                                 Instruction *InsertBefore)
  {
    Function *F = InsertBefore->getParent()->getParent();
    CallInst *Lid[3] = {NULL, NULL, NULL};
    for (int i = 0; i < 3; ++i) {
      Lid[i] = insertCallToGetX("get_local_id", i, F->getParent(),
                                F->getContext(), InsertBefore);
    }
    
    Builder.SetInsertPoint(InsertBefore);
    Value *FlatIdx = Builder.CreateAdd(
                       Builder.CreateAdd(
                         Builder.CreateMul(Builder.CreateMul(Lid[2], Lsz[0]), 
                                           Lsz[1]),
                         Builder.CreateMul(Lid[1], Lsz[0])
                       ),
                       Lid[0], "FlatIdx");

    std::vector<Value *> GepOffsets;
    //GepOffsets.push_back(
    //  ConstantInt::get(IntegerType::get(I.getContext(), 32), 0)
    //);
    GepOffsets.push_back(FlatIdx);

    GetElementPtrInst *AllocaGep = 
      GetElementPtrInst::Create(Alloca, GepOffsets, 
                                Alloca->getName()+".gep", InsertBefore);

    StoreInst *SI = new StoreInst(&I, AllocaGep, InsertBefore);

    return SI;
  }

  //===--------------------------------------------------------------------===//
  char IPContextSpill::ID = 0;

  namespace {
    static
    RegisterPass<IPContextSpill>
      IPContextSpillModulePass("mxpa_IPcontext_spill",
        "Spill context at the BB level");
  }

  void IPContextSpill::getAnalysisUsage(AnalysisUsage &AU) const {
    AU.addRequired<ContextSpill>();
  }

  bool IPContextSpill::runOnModule(Module &M) {
    bool Changed = false;

#if 0
    forwardDeclWIFs(M);
#endif

#if 1
    CL_KernelInfo CLKI(M);
    std::vector<std::string> KernelNames= CLKI.get_kernel_names();
#else
    std::vector<std::string> KernelNames;
    
    LLVMContext &Context = getGlobalContext();
    SMDiagnostic Err;
    Module *KernelInfoLink = ParseIRFile("kernel_info_link.bc", Err, Context);

    GlobalVariable *GVnames  = KernelInfoLink->getNamedGlobal("_cl_kernel_names");
  
    if (Constant *Init = GVnames->getInitializer()) { 
      unsigned n = Init->getNumOperands();
      for (unsigned i = 0; i != n; ++i) {
        Constant *AO = cast<Constant>(Init->getOperand(i));
  
        if (GlobalVariable *gvn = dyn_cast<GlobalVariable>(AO->getOperand(0))) {
          Constant *cn = gvn->getInitializer();
          if (ConstantDataArray *ca = dyn_cast<ConstantDataArray>(cn)) {
            if (ca->isCString()) {
              KernelNames.push_back(ca->getAsCString().str());
            }
          }
        }
      }
    }
#endif

    for (std::vector<std::string>::iterator K = KernelNames.begin(),
         E = KernelNames.end(); K != E; ++K) {
      DEBUG_WITH_TYPE("mxpa_ms4", errs() << "Kevin said ---->" << *K << "\n");
    }

    for (Module::iterator F = M.begin(), E = M.end(); F != E; ++F) {
      if (F->isDeclaration())
        continue;

      std::string fnm = F->getName().str();
      bool IsKernel = (std::find(KernelNames.begin(), KernelNames.end(), fnm) 
                       != KernelNames.end());

      if (!IsKernel)
        continue;

      DEBUG_WITH_TYPE("mxpa_ms4", errs() << "Found a function: " 
                                         << F->getName() << "\n");
      getAnalysis<ContextSpill>(*F);

      Changed = true;
    }

    return Changed;
  }

}
}
