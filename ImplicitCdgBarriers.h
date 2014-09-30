#ifndef IMPLICIT_CDG_BARRIERS_H
#define IMPLICIT_CDG_BARRIERS_H

#include "control_dependence.h"

namespace SpmdKernel {
namespace Coarsening {

  class ImplicitCdgBarriers : public llvm::FunctionPass {
  
  public:
    static char ID;

    ImplicitCdgBarriers() : FunctionPass(ID) {}

    virtual void getAnalysisUsage(llvm::AnalysisUsage &AU) const;
    virtual bool runOnFunction(llvm::Function &F);

  private:
    ControlDep *CD;

  };

}
}

#endif
