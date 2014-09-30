//#include "config.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include <iostream>

#include "LoopBarriers.h"
#include "barrier_inst.h"
//#include "Workgroup.h"

namespace SpmdKernel {

using namespace llvm;

namespace Coarsening {

  char LoopBarriers::ID = 0;
  
  namespace {
    static
    RegisterPass<LoopBarriers> X("loop-barriers",
                                 "Add needed barriers to loops");
  }
  
  void
  LoopBarriers::getAnalysisUsage(AnalysisUsage &AU) const
  {
    AU.addRequired<DominatorTree>();
    AU.addPreserved<DominatorTree>();
  }
  
  bool
  LoopBarriers::runOnLoop(Loop *L, LPPassManager &LPM)
  {
    //if (!Workgroup::isKernelToProcess(*L->getHeader()->getParent()))
    //  return false;
    DT = &getAnalysis<DominatorTree>();
  
    bool changed = ProcessLoop(L, LPM);
  
    DT->verifyAnalysis();
  
    return changed;
  }
  
  bool
  LoopBarriers::ProcessLoop(Loop *L, LPPassManager &LPM)
  {
    bool isBLoop = false;
    bool changed = false;
  
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

    LLVMContext &LC = getGlobalContext();
    IntegerType * IntTy = IntegerType::get(LC, 32);
    Value *Args = ConstantInt::get(IntTy, 0);
  
    for (Loop::block_iterator i = L->block_begin(), e = L->block_end();
         i != e && isBLoop; ++i) {
      for (BasicBlock::iterator j = (*i)->begin(), e = (*i)->end();
           j != e; ++j) {
        if (isa<BarrierInst>(j)) {
          BasicBlock *preheader = L->getLoopPreheader();
          assert((preheader != NULL) && "Non-canonicalized loop found!\n");
          Instruction *PhdrBarrierInst = 
            BarrierInst::createBarrier(Args, preheader->getTerminator());
          MDNode* PhdrAuxBarrierInfo = 
            MDNode::get(LC, MDString::get(LC, "auxiliary phdr barrier"));
          PhdrBarrierInst->setMetadata("aux.phdr.barrier", PhdrAuxBarrierInfo);
          preheader->setName(preheader->getName() + ".loopbarrier");
  
          BasicBlock *header = L->getHeader();
          if (header->getFirstNonPHI() != &header->front()) {
            Instruction *HdrBarrierInst = 
              BarrierInst::createBarrier(Args, header->getFirstNonPHI());
            MDNode* HdrAuxBarrierInfo = 
              MDNode::get(LC, MDString::get(LC,  "auxiliary phihdr barrier"));
            HdrBarrierInst->setMetadata("aux.phihdr.barrier", HdrAuxBarrierInfo);
            header->setName(header->getName() + ".phibarrier");
          }
 
          /*
          SmallVector<BasicBlock*, 8> ExitingBlocks;
          L->getExitingBlocks(ExitingBlocks);
          */
          BasicBlock *brexit = L->getExitingBlock();
          if (brexit != NULL) {
            Instruction *ExitingBarrierInst = 
              BarrierInst::createBarrier(Args, brexit->getTerminator());
            MDNode* ExitingAuxBarrierInfo =
              MDNode::get(LC, MDString::get(LC, "auxiliary exiting barrier"));
            ExitingBarrierInst->setMetadata("aux.exiting.barrier", 
                                            ExitingAuxBarrierInfo);
            brexit->setName(brexit->getName() + ".brexitbarrier");
          }
  
          BasicBlock *latch = L->getLoopLatch();
          if (latch != NULL && brexit != latch) {
            Instruction *LatchBarrierInst =
              BarrierInst::createBarrier(Args, latch->getTerminator());
            MDNode* LatchAuxBarrierInfo =
              MDNode::get(LC, MDString::get(LC, "auxiliary latch barrier"));
            LatchBarrierInst->setMetadata("aux.latch.barrier", 
                                          LatchAuxBarrierInfo);
            latch->setName(latch->getName() + ".latchbarrier");
            return changed;
          }
  
          BasicBlock *Header = L->getHeader();
          typedef GraphTraits<Inverse<BasicBlock *> > InvBlockTraits;
          InvBlockTraits::ChildIteratorType PI = InvBlockTraits::child_begin(Header);
          InvBlockTraits::ChildIteratorType PE = InvBlockTraits::child_end(Header);
          BasicBlock *Latch = NULL;
          for (; PI != PE; ++PI) {
            InvBlockTraits::NodeType *N = *PI;
            if (L->contains(N)) {
              Latch = N;
              if (DT->dominates(j->getParent(), Latch)) {
                BarrierInst::createBarrier(Args, Latch->getTerminator());
                Latch->setName(Latch->getName() + ".latchbarrier");
              }
            }
          }
          return true;
        }
      }
    }
  
    BasicBlock *preheader = L->getLoopPreheader();
    assert((preheader != NULL) && "Non-canonicalized loop found!\n");
    TerminatorInst *t = preheader->getTerminator();
    Instruction *prev = NULL;
    if (&preheader->front() != t) {
      // If t is not the first/only instruction in the block, get the previous
      // instruction.
      prev = t->getPrevNode();
    }

    if (prev && isa<BarrierInst>(prev)) {
        BasicBlock *new_b = SplitBlock(preheader, t, this);
        new_b->setName(preheader->getName() + ".postbarrier_dummy");
        return true;
    }
  
    return changed;
  }

}
}
