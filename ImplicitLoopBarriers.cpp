#define DEBUG_TYPE "mxpa_implicitloopbarriers"

// LLVM
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Module.h"

// System
#include <iostream>

// MxPA includes
#include "ImplicitLoopBarriers.h"
#include "barrier_inst.h"
#include "triplet_invariance_analysis.h"

namespace SpmdKernel {

using namespace llvm;

namespace Coarsening {

  char ImplicitLoopBarriers::ID = 0;

  namespace {
    static
    RegisterPass<ImplicitLoopBarriers> X("implicit-loop-barriers",
                                         "Adds implicit barriers to loops");
  }

  void
  ImplicitLoopBarriers::getAnalysisUsage(AnalysisUsage &AU) const
  {
    AU.addRequired<DominatorTree>();
    AU.addPreserved<DominatorTree>();

    AU.addRequired<TripletInvarianceAnalysis>();
    AU.addPreserved<TripletInvarianceAnalysis>();
  }
  
  bool
  ImplicitLoopBarriers::runOnLoop(Loop *L, LPPassManager &LPM)
  {
    //if (!Workgroup::isKernelToProcess(*L->getHeader()->getParent()))
    //  return false;

    Function *F = L->getExitingBlock()->getParent();

    TripletInvarianceAnalysis &TIA = 
      getAnalysis<TripletInvarianceAnalysis>();
 
    return ProcessLoop(L, LPM);
  }
  
  bool
  ImplicitLoopBarriers::ProcessLoop(Loop *L, LPPassManager &LPM)
  {
    bool isBLoop = false;
    for (Loop::block_iterator i = L->block_begin(), e = L->block_end();
         i != e && !isBLoop; ++i) {
      for (BasicBlock::iterator j = (*i)->begin(), e = (*i)->end();
           j != e; ++j) {
        if (isa<BarrierInst>(j)) {
            isBLoop = true;
            break;
        }
      }
    }
    if (isBLoop) return false;
  
    return AddInnerLoopBarrier(L, LPM);
  }
  
  bool
  ImplicitLoopBarriers::AddInnerLoopBarrier(Loop *L, LPPassManager &LPM) 
  {
    if (L->getSubLoops().size() > 0)
      return false;
  
    BasicBlock *brexit = L->getExitingBlock();
    if (brexit == NULL) return false; /* Multiple exit points */
  
    BasicBlock *loopEntry = L->getHeader();
    if (loopEntry == NULL) return false; /* Multiple entries blocks? */
  
    Function *f = brexit->getParent();
  
    TripletInvarianceAnalysis &TIA = 
      getAnalysis<TripletInvarianceAnalysis>();
 
    if (!TIA.isUniform(f, loopEntry)) {
      return false;
    }
  
    BranchInst *br = dyn_cast<BranchInst>(brexit->getTerminator());  
    if (br && br->isConditional() 
           && TIA.isUniform(f, br->getCondition())) {
      LLVMContext &LC = br->getParent()->getParent()->getContext();
      IntegerType * IntTy = IntegerType::get(LC, 32);
      Value *Args = ConstantInt::get(IntTy, 0);
      BarrierInst::createBarrier(Args, brexit->getTerminator());   
      BarrierInst::createBarrier(Args, loopEntry->getFirstNonPHI());

      return true;
    } else {
  
    }
  
    return false;
  }
  
}
}
