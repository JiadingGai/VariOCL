#ifndef MXPA_ISOLATE_REGIONS_H
#define MXPA_ISOLATE_REGIONS_H

#include "llvm/Analysis/RegionPass.h"

namespace SpmdKernel {
namespace Coarsening {

  class IsolateRegions : public llvm::RegionPass {
  public:
    static char ID;

    IsolateRegions() : RegionPass(ID) {}

    virtual void getAnalysisUsage(llvm::AnalysisUsage &AU) const;
    virtual bool runOnRegion(llvm::Region *R, llvm::RGPassManager&);
    void addDummyAfter(llvm::Region *R, llvm::BasicBlock *bb);
    void addDummyBefore(llvm::Region *R, llvm::BasicBlock *bb);

  };
}
}

#endif
