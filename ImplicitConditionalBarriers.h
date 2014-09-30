#ifndef IMPLICIT_COND_BARRIERS_H
#define IMPLICIT_COND_BARRIERS_H

//#include "config.h"
#include "llvm/IR/Function.h"

#include "llvm/Pass.h"
#include "llvm/Analysis/PostDominators.h"

namespace SpmdKernel {
namespace Coarsening {
  class ImplicitConditionalBarriers : public llvm::FunctionPass {
    
  public:
    static char ID;
    
  ImplicitConditionalBarriers() : FunctionPass(ID) {}
    
    virtual void getAnalysisUsage(llvm::AnalysisUsage &AU) const;
    virtual bool runOnFunction (llvm::Function &F);

  private:
    
    llvm::BasicBlock* firstNonBackedgePredecessor(llvm::BasicBlock *bb);

    llvm::PostDominatorTree *PDT;
    llvm::PostDominatorTree *DT;

  };
}
}

#endif
