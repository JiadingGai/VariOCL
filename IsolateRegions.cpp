#include "IsolateRegions.h"
#include "barrier_inst.h"
#include "llvm/Analysis/RegionInfo.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Analysis/DominanceFrontier.h"
#include "llvm/Analysis/PostDominators.h"
#include <iostream>

namespace SpmdKernel {
using namespace llvm;
namespace Coarsening {
 
namespace {
  static
  RegisterPass<IsolateRegions> X("isolate-regions",
					 "Single-Entry Single-Exit region isolation pass.");
}

char IsolateRegions::ID = 0;

void
IsolateRegions::getAnalysisUsage(AnalysisUsage &AU) const
{
  AU.addRequired<PostDominatorTree>();
  AU.addRequired<DominatorTree>();
  AU.addRequired<DominanceFrontier>();
}

bool
IsolateRegions::runOnRegion(Region *R, RGPassManager&) 
{
  BasicBlock *exit = R->getExit();
  if (exit == NULL) return false;

  bool isFunctionExit = exit->getTerminator()->getNumSuccessors() == 0;

  bool changed = false;

  //if (BarrierInst::hasBarrier(exit) || isFunctionExit)
  {
      addDummyBefore(R, exit);
      changed = true;
  }

  BasicBlock *entry = R->getEntry();
  if (entry == NULL) return changed;

  bool isFunctionEntry = &entry->getParent()->getEntryBlock() == entry;

  //if (BarrierInst::hasBarrier(entry) || isFunctionEntry) 
  {
      addDummyAfter(R, entry);
      changed = true;
  }

  return changed;
}


void
IsolateRegions::addDummyAfter(Region *R, BasicBlock *bb)
{
  std::vector< BasicBlock* > regionSuccs;

  for (succ_iterator i = succ_begin(bb), e = succ_end(bb);
       i != e; ++i) {
    BasicBlock* succ = *i;
    if (R->contains(succ))
      regionSuccs.push_back(succ);
  }
  BasicBlock* newEntry = 
    SplitBlock(bb, &bb->front(), this);
  newEntry->setName(bb->getName() + ".r_entry");
  R->replaceEntry(newEntry);
}

void
IsolateRegions::addDummyBefore(Region *R, BasicBlock *bb)
{
  std::vector< BasicBlock* > regionPreds;

  for (pred_iterator i = pred_begin(bb), e = pred_end(bb);
       i != e; ++i) {
    BasicBlock* pred = *i;
    if (R->contains(pred))
      regionPreds.push_back(pred);
  }
  BasicBlock* newExit = 
    SplitBlockPredecessors(bb, regionPreds, ".r_exit", this);
  R->replaceExit(newExit);
}

}
}
