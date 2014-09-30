#define DEBUG_TYPE "mxpa_hiveoffbarrier"

//LLVM includes
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Constants.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/Support/InstIterator.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/IRReader/IRReader.h"

//MxPA includes
#include "barrier_inst.h"
#include "barrier_utils.h"
#include "hive_off_barrier.h"
#include "kernel_info_reader.h"

namespace SpmdKernel {

using namespace llvm;

namespace Coarsening {
  
  char HiveOffBarrier::ID = 0;

  namespace {
    static
    RegisterPass<HiveOffBarrier> X("mxpa_hiveoffbarrier",
                                   "Single out barrier from its BB");
  }

  bool HiveOffBarrier::runOnFunction(Function &F) {
    bool Changed = false;

    LLVMContext &LC = F.getContext();

    //FIXME: More assertion type of work needed here:
    //       1. Check whether F is a proper OCL kernel or not.
    //       2. Ensure function entry and exit BBs are barrier blocks (?!).
    //LIX:XCIII
    BasicBlock *entry = &F.getEntryBlock();
    IntegerType * IntTy = IntegerType::get(LC, 32);
    Value *Args = ConstantInt::get(IntTy, 0);
    if (!containsJustABarrier(entry)) {
      BasicBlock *effective_entry = SplitBlock(entry, 
                                               &(entry->front()),
                                               this);

      effective_entry->takeName(entry);
      entry->setName("entry.barrier");

      BarrierInst::createBarrier(Args, entry->getTerminator());
    }

    for (Function::iterator i = F.begin(), e = F.end(); i != e; ++i) {
      BasicBlock *b = i;
      TerminatorInst *t = b->getTerminator();
      if ((t->getNumSuccessors() == 0) && (!containsJustABarrier(b))) {
        BasicBlock *exit; 
        if (BarrierInst::endsWithBarrier(b)) {
          exit = SplitBlock(b, t->getPrevNode(), this);
        } else {
          exit = SplitBlock(b, t, this);
          //FIXME: potential QPDM's bug
          BarrierInst::createBarrier(Args, exit->getTerminator());
        }
        exit->setName("exit.barrier");
      }
    }
 
    DT = getAnalysisIfAvailable<DominatorTree>();
    LI = getAnalysisIfAvailable<LoopInfo>();

    Changed |= ProcessBarrier(F);

    verifyAnalysis();

    return Changed;
  }
  
  HiveOffBarrier::~HiveOffBarrier() {
  }

  void HiveOffBarrier::CollectBarriers(Function &F) {
    BarrierSet.clear();
    // Collect the set of "barrier call" instructions that are known live
    for (inst_iterator I = inst_begin(F), E = inst_end(F); I != E; ++I) {
      BasicBlock::iterator BI = I.getInstructionIterator();
      if (isa<BarrierInst>(&*BI)) {
        BarrierSet.insert(&*BI);
      }
    }
  }
  
  bool HiveOffBarrier::ProcessBarrier(Function &F) {
    bool Changed = false;

    CollectBarriers(F);

    //
    for (SmallPtrSet<Instruction*, 128>::iterator It = BarrierSet.begin(),
         E = BarrierSet.end(); It != E; ++It) {

      BarrierInst *I = cast<BarrierInst>(*It);
      BasicBlock *B = I->getParent();
      Function *F = B->getParent();

      if (I->getNextNode() != B->getTerminator()) {
        SplitBlockAfterBarrier(B, I);
        Changed = true;
      }

      //FIXME: Should we handle the following case separtely:
      //         If Barrier is at the beginning of the BB,
      //         which has a single predecessor with just
      //         one successor (the barrier itself), thus
      //         no need to split before barrier.
      //CLVIII:CLXIX
    
      if ((B == &(F->front())) && ((B->getFirstNonPHI()) == I)) {
        continue;
      }

      SplitBlockBeforeBarrier(B, I);
      Changed = true;
    }

    return Changed;
  }

  BasicBlock* 
  HiveOffBarrier::SplitBlockBeforeBarrier(BasicBlock *Old, 
                                          BarrierInst *SplitPt) {
    BasicBlock *New = SplitBlock(Old, SplitPt, this);
    New->takeName(Old);
    Old->setName(New->getName() + ".mxpa.b4.barrier");
    return New;
  }
 
  BasicBlock* 
  HiveOffBarrier::SplitBlockAfterBarrier(BasicBlock *Old, 
                                         BarrierInst *SplitPt) {
    Instruction *NextInstAfterBarrier = SplitPt->getNextNode();
    BasicBlock *New = SplitBlock(Old, NextInstAfterBarrier, this);
    New->setName(Old->getName() + ".mxpa.after.barrier");
    return Old;
  }
  
  void HiveOffBarrier::verifyAnalysis() const {
    if (DT) DT->verifyAnalysis();
    if (LI) LI->verifyAnalysis();
 
    for (SmallPtrSet<Instruction*, 128>::iterator It = BarrierSet.begin(),
         E = BarrierSet.end(); It != E; ++It) {
      Instruction *BI = *It;
      BasicBlock *BB = BI->getParent();
      assert(
        containsJustABarrier(BB) && "Not all barriers are hived off properly!"
      );
    }
  }

  void HiveOffBarrier::print(raw_ostream &OS, const Module *) const {
    ;
  }

  //===--------------------------------------------------------------------===//
  char IPHiveOff::ID = 0;

  namespace {
    static
    RegisterPass<IPHiveOff>
      IPHiveOffModulePass("mxpa_IPhiveoffbarrier",
        "Hive off barriers");
  }

  void IPHiveOff::getAnalysisUsage(AnalysisUsage &AU) const {
    AU.addRequired<HiveOffBarrier>();
  }

  bool IPHiveOff::runOnModule(Module &M) {
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
      getAnalysis<HiveOffBarrier>(*F);

      Changed = true;
    }

    return Changed;
  }

}
}
