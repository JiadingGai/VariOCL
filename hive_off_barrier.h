#ifndef MXPA_HIVE_OFF_BARRIER_H
#define MXPA_HIVE_OFF_BARRIER_H

// LLVM includes
#include "llvm/IR/Function.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"

// System includes
#include <set>

// MxPA includes
#include "barrier_inst.h"

namespace SpmdKernel {
namespace Coarsening {

//
class HiveOffBarrier : public llvm::FunctionPass {
public:
  static char ID; // Pass identification, replacement for typeid

  HiveOffBarrier() : FunctionPass(ID) {
  }

  ~HiveOffBarrier();

  bool ProcessBarrier(llvm::Function &F);
  virtual bool runOnFunction(llvm::Function &F);

  virtual void getAnalysisUsage(llvm::AnalysisUsage &AU) const {
    // We need loop information to split barrier carefully
    AU.addRequired<llvm::DominatorTree>();
    AU.addPreserved<llvm::DominatorTree>();

    AU.addRequired<llvm::LoopInfo>();
    AU.addPreserved<llvm::LoopInfo>();
  }

  /// 
  virtual void verifyAnalysis() const;
  virtual void print(llvm::raw_ostream &OS, const llvm::Module*) const;
  virtual void CollectBarriers(Function &F);

private:
  llvm::LoopInfo *LI;
  llvm::DominatorTree *DT;
  llvm::SmallPtrSet<llvm::Instruction*, 128> BarrierSet;
  llvm::BasicBlock* SplitBlockBeforeBarrier(llvm::BasicBlock *Old, 
                                            BarrierInst *SplitPt);
  llvm::BasicBlock* SplitBlockAfterBarrier(llvm::BasicBlock *Old, 
                                           BarrierInst *SplitPt);
};

//===----------------------------------------------------------------------===//
struct IPHiveOff : public llvm::ModulePass {
  virtual void getAnalysisUsage(llvm::AnalysisUsage &AU) const;
  static char ID;
  IPHiveOff() : llvm::ModulePass(ID) {
    ;
  }
  bool runOnModule(llvm::Module &M);
  
};
 
}
}

#endif
