#ifndef MXPA_LOOP_BARRIERS_H
#define MXPA_LOOP_BARRIERS_H

#include "llvm/Analysis/LoopPass.h"
#include <set>

namespace SpmdKernel {
namespace Coarsening {
  class LoopBarriers : public llvm::LoopPass {
    
  public:
    static char ID;
    
  LoopBarriers() : LoopPass(ID) {}
    
    virtual void getAnalysisUsage(llvm::AnalysisUsage &AU) const;
    virtual bool runOnLoop(llvm::Loop *L, llvm::LPPassManager &LPM);

  private:
    llvm::DominatorTree *DT;

    bool ProcessLoop(llvm::Loop *L, llvm::LPPassManager &LPM);
  };
}
}

#endif
