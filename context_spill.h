#ifndef MXPA_CONTEXT_SPILL_H
#define MXPA_CONTEXT_SPILL_H

#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Transforms/Scalar.h"
#include "llvm/Pass.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Support/raw_ostream.h"

#include <string>

namespace SpmdKernel {
namespace Coarsening {

class ContextSpill : public llvm::FunctionPass {

  llvm::CallInst *Lsz[3];
  llvm::Value *Flat3DSize;

public:
  static char ID;

  ContextSpill() : FunctionPass(ID) {
  }

  ~ContextSpill() {
  }

  virtual void getAnalysisUsage(llvm::AnalysisUsage &AU) const {
    AU.addRequiredID(llvm::BreakCriticalEdgesID);
    AU.addPreservedID(llvm::BreakCriticalEdgesID);
  }

  llvm::AllocaInst* DemoteRegToStack(llvm::Instruction &I, 
                                     bool VolatileLoads,
                                     llvm::Instruction *AllocaPoint);
  llvm::AllocaInst* DemotePHIToStack(llvm::PHINode *P, 
                                     llvm::Instruction *AllocaPoint);
  bool isValueEscaped(const llvm::Instruction *Inst) const;
  virtual bool runOnFunction(llvm::Function &F);

  
  // Good for inserting the following builtin functions:
  //
  //   size_t get_global_size(uint dimindx);
  //   size_t get_global_id(uint dimindx);
  //   size_t get_local_size(uint dimindx);
  //   size_t get_local_id(uint dimindx);
  //   size_t get_num_groups(uint dimindx);
  //   size_t get_group_id(uint dimindx);
  //   size_t get_global_offset(uint dimindx);
  //
  llvm::CallInst* insertCallToGetX(std::string FuncName, 
                                   int dimindx, llvm::Module *M,
                                   llvm::LLVMContext &Context,
                                   llvm::Instruction *InsertBefore);

  llvm::AllocaInst* insert3DAllocaFor(llvm::Instruction &I,
                                      llvm::Instruction *InsertBefore);
  
  llvm::LoadInst* insert3DLoadFor(llvm::Instruction &I,
                                    llvm::Instruction *InsertBefore);
  
  llvm::StoreInst* insert3DStoreFor(llvm::Value &I,
                                    llvm::Instruction *Alloca,
                                    llvm::Instruction *InsertBefore);
  
};

//===----------------------------------------------------------------------===//
struct IPContextSpill : public llvm::ModulePass {
  virtual void getAnalysisUsage(llvm::AnalysisUsage &AU) const;
  static char ID;
  IPContextSpill() : llvm::ModulePass(ID) {
    ;
  }
  bool runOnModule(llvm::Module &M);
  
};
 
}
}

#endif
