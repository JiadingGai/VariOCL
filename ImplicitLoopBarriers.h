#ifndef IMPLICIT_LOOP_BARRIERS_H
#define IMPLICIT_LOOP_BARRIERS_H

#include "llvm/Analysis/LoopPass.h"
#include <set>

namespace SpmdKernel {
namespace Coarsening {
  class ImplicitLoopBarriers : public llvm::LoopPass {
    
  public:
    static char ID;
    
  ImplicitLoopBarriers() : LoopPass(ID) {}
    
    virtual void getAnalysisUsage(llvm::AnalysisUsage &AU) const;
    virtual bool runOnLoop(llvm::Loop *L, llvm::LPPassManager &LPM);

  private:
    llvm::DominatorTree *DT;

    bool ProcessLoop(llvm::Loop *L, llvm::LPPassManager &LPM);
    bool AddInnerLoopBarrier(llvm::Loop *L, llvm::LPPassManager &LPM);

  };
}
}

#endif
