#ifndef MXPA_MS4_H
#define MXPA_MS4_H

// LLVM includes
#include "llvm/IR/Module.h"
#include "llvm/Pass.h"
#include "llvm/ADT/StringRef.h"

namespace SpmdKernel {
namespace Coarsening {
  class TestMod : public llvm::ModulePass {
    int LocalSizeX, LocalSizeY, LocalSizeZ;
  public:
    static char ID;
    TestMod() : llvm::ModulePass(ID) {
      /* empty */; 
    }

    bool runOnModule(llvm::Module &M);
  
    llvm::StringRef getCalledFunctionName(llvm::CallInst *Call);

    void ReplaceCallsWithConstant(llvm::CallInst *a_call,
                                  llvm::StringRef builtin_fn,
                                  llvm::ConstantInt *ReplVal,
                                  int dimindx,
                                  std::vector<llvm::Instruction*> &CallsToErase);
  };
}
}

#endif
