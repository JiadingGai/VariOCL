#ifndef MXPA_MS5_H
#define MXPA_MS5_H

// LLVM includes
#include "llvm/IR/Function.h"
#include "llvm/Pass.h"

namespace SpmdKernel {
namespace Coarsening {
  class SplitBBAtCondBr: public llvm::FunctionPass{
  public:
    static char ID;
    SplitBBAtCondBr() : llvm::FunctionPass(ID) {
      /* empty */; 
    }

    virtual bool runOnFunction(llvm::Function &F);
    virtual void getAnalysisUsage(llvm::AnalysisUsage &AU) const
    {
    
    }
  };
}
}

#endif
