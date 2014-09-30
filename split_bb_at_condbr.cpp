#define DEBUG_TYPE "mxpa_ms5"

// LLVM includes
#include "llvm/Support/Debug.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/IR/Instruction.h"
#include "llvm/IR/Instructions.h"

// MxPA includes
#include "split_bb_at_condbr.h"
#include "barrier_inst.h"

namespace SpmdKernel {

using namespace llvm;

namespace Coarsening {

  char SplitBBAtCondBr::ID = 0;
  
  namespace {
    static
    RegisterPass<SplitBBAtCondBr> SplitCondBrFuncPass("mxpa_splitcondbr", 
      "Split basic block at its conditional branch instruction.");
  }

  bool SplitBBAtCondBr::runOnFunction(Function &F) {
    bool Changed = false;

    std::vector<BasicBlock*> BBInvolved;
    for (Function::iterator BI = F.begin(), BE = F.end(); BI != BE; ++BI)
    {
      BasicBlock *BB = &*BI;
      BBInvolved.push_back(BB);
    }

    for (std::vector<BasicBlock*>::iterator BI = BBInvolved.begin(), BE = BBInvolved.end(); BI != BE; ++BI) {
      BasicBlock *BB = *BI;

      TerminatorInst *TI = BB->getTerminator();
      if (BranchInst *Br = dyn_cast<BranchInst>(TI)) {

        if (Br->isConditional() && !BarrierInst::endsWithBarrier(BB)) {
          BasicBlock *NewBB = SplitBlock(BB, Br, this);
          NewBB->setName(BB->getName() + ".splitcondbr");

          Changed = true;
        }
      }
    }

    return Changed;
  }

}
}
