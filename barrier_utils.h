#ifndef MXPA_BARRIER_UTILS_H
#define MXPA_BARRIER_UTILS_H

#include "llvm/IR/Instructions.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/IR/BasicBlock.h"

//===----------------------------------------------------------------------===//
//
// This family of functions perform manipulations on barriers, and basic
// blocks that contain barriers.
//
//===----------------------------------------------------------------------===//
namespace SpmdKernel {
namespace Coarsening {
  bool containsJustABarrier (llvm::BasicBlock *BB);
  llvm::StringRef getCalledFunctionName(llvm::CallInst *Call);
}
}

#endif
