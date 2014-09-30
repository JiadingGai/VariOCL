#ifndef MXPA_BREAK_PHI_H
#define MXPA_BREAK_PHI_H

// LLVM includes
#include "llvm/IR/Function.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"

// System includes
#include <set>

// MxPA includes
#include "barrier_inst.h"
#include "control_dependence.h"

namespace SpmdKernel {
namespace Coarsening {

//
class BreakPhi : public llvm::FunctionPass {

  ControlDep *CD;
  std::set<llvm::PHINode *> UnbreakablePHIs;

public:
  static char ID; // Pass identification, replacement for typeid

  BreakPhi() : FunctionPass(ID) {
  }

  ~BreakPhi();

  void CollectUnbreakablePHIs(llvm::Function &F);
  void BreakPhi2Alloca(llvm::Function &F);
  void BreakPhi2Alloca2(llvm::PHINode *phi, llvm::Instruction *LoadInsertPt);
  void SplitAndSinkFromTo(llvm::BasicBlock *From, llvm::BasicBlock *To);
  void SplitAndSink(llvm::Function &F);
  virtual bool runOnFunction(llvm::Function &F);

  virtual void getAnalysisUsage(llvm::AnalysisUsage &AU) const {
    // We need loop information to split barrier carefully
    AU.addRequired<llvm::DominatorTree>();
    AU.addPreserved<llvm::DominatorTree>();

    AU.addRequired<llvm::LoopInfo>();
    AU.addPreserved<llvm::LoopInfo>();

    AU.addRequired<PostDominatorTree>();
    AU.addPreserved<llvm::PostDominatorTree>();

    AU.addRequired<DominanceFrontier>();
    AU.addPreserved<llvm::DominanceFrontier>();

    AU.addRequired<ControlDep>();
    AU.addPreserved<ControlDep>();
  }

};

//===----------------------------------------------------------------------===//
struct IPBreakPhi : public llvm::ModulePass {
  virtual void getAnalysisUsage(llvm::AnalysisUsage &AU) const;
  static char ID;
  IPBreakPhi() : llvm::ModulePass(ID) {
    ;
  }
  bool runOnModule(llvm::Module &M);
  
};
 
}
}

#endif
