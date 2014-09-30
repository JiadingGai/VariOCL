#define DEBUG_TYPE "mxpa_implicitcdgbarriers"

// LLVM includes
#include "llvm/IR/Constants.h"

// MxPA includes
#include "ImplicitCdgBarriers.h"
#include "barrier_inst.h"

namespace SpmdKernel {

using namespace llvm;

namespace Coarsening {

  char ImplicitCdgBarriers::ID = 0;

  namespace {
    static
    RegisterPass<ImplicitCdgBarriers> 
      X("mxpa_implicit-cdg-barriers", "Inserts implicit barriers guided by cdg");
  }

  void ImplicitCdgBarriers::getAnalysisUsage(AnalysisUsage &AU) const
  {
    AU.addRequired<PostDominatorTree>();
    AU.addRequired<DominatorTree>();
    AU.addRequired<DominanceFrontier>();
    AU.addRequired<ControlDep>();
  }

  bool ImplicitCdgBarriers::runOnFunction(Function &F)
  {
    CD = &getAnalysis<ControlDep>();
    DEBUG_WITH_TYPE("mxpa_implicitcdgbarriers", CD->CDG.dump());

    std::vector<Instruction*> BarSet;

    for (Function::iterator BI = F.begin(), BE = F.end(); BI != BE; ++BI) {
      BasicBlock *X = BI;
      for (BasicBlock::iterator II = X->begin(), IE = X->end(); II != IE; ++II) {
        Instruction *I = &*II;

        if (isa<BarrierInst>(I)) {
          BarSet.push_back(I);
        }
      }
    }

    std::vector<BasicBlock*> BBsCtrl;
    for (std::vector<Instruction*>::iterator II = BarSet.begin(), IE = BarSet.end(); II != IE; ++II) {
      Instruction *BarInst = *II;
      BasicBlock *Y = BarInst->getParent();
      DEBUG_WITH_TYPE("mxpa_implicitcdgbarriers", errs() << "[" << Y->getName() << "]:\n");

      for (Function::iterator BI = F.begin(), BE = F.end(); BI != BE; ++BI) {
        BasicBlock *X = &*BI;

        if (CD->isIterativelyCtrlDep(X, Y) && (X != Y)) {
          BBsCtrl.push_back(X);
          DEBUG_WITH_TYPE("mxpa_implicitcdgbarriers", errs() << "    +" << X->getName() << "\n");
          continue;
        }

        if (CD->isReverselyIterativelyCtrlDep(X, Y) && (X != Y)) {
          BBsCtrl.push_back(X);
          DEBUG_WITH_TYPE("mxpa_implicitcdgbarriers", errs() << "    -" << X->getName() << "\n");
          continue;
        }
      }
    }


    for (std::vector<BasicBlock*>::iterator BI = BBsCtrl.begin(), BE = BBsCtrl.end(); BI != BE; ++BI)
    {
      BasicBlock *BB = *BI;

      LLVMContext &LC = F.getContext();
      IntegerType * IntTy = IntegerType::get(LC, 32);
      Value *Args = ConstantInt::get(IntTy, 0);  
      Instruction *CdgAuxBarrierInst = BarrierInst::createBarrier(Args, BB->getFirstNonPHI());

      MDNode* CdgAuxBarrierInfo = MDNode::get(LC, MDString::get(LC, "aux cdg barrier"));
      CdgAuxBarrierInst->setMetadata("aux.cdg.barrier", CdgAuxBarrierInfo);

      Instruction *CdgAuxBarrierInst2 = BarrierInst::createBarrier(Args, BB->getTerminator());

      MDNode* CdgAuxBarrierInfo2 = MDNode::get(LC, MDString::get(LC, "aux cdg barrier"));
      CdgAuxBarrierInst2->setMetadata("aux.cdg.barrier", CdgAuxBarrierInfo2);


      DominatorTree *DT = &getAnalysis<DominatorTree>();

      bool HasBackEdge = false;
      for (pred_iterator i = pred_begin(BB), e = pred_end(BB); i != e; ++i) {
        BasicBlock *Pred = *i;
        if (DT->dominates(BB, Pred)) {
          HasBackEdge = true;
          break;
        }
      }

      if (!HasBackEdge) {
        TerminatorInst *TI = BB->getTerminator();
        for (int n = 0; n < TI->getNumSuccessors(); ++n) {
          BasicBlock *Succ = TI->getSuccessor(n);
          
          Instruction *CdgAuxBarrierInst2 = BarrierInst::createBarrier(Args, Succ->getFirstNonPHI());
          MDNode* CdgAuxBarrierInfo2 = MDNode::get(LC, MDString::get(LC, "aux cdg barrier"));
          CdgAuxBarrierInst2->setMetadata("aux.cdg.barrier", CdgAuxBarrierInfo);
        }
      }
    }

  }

}
}
