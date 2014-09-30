#ifndef INCLUDE_LLVM_ANALYSIS_CONTROLDEPENDENCE_H_
#define INCLUDE_LLVM_ANALYSIS_CONTROLDEPENDENCE_H_

#include "llvm/IR/Instruction.h"
#include "llvm/IR/Instructions.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/DenseSet.h"
#include "llvm/Pass.h"

namespace SpmdKernel {
namespace Coarsening {

/** \brief Analysis the control flow graph for control dependencies. */
class ControlDependence : public llvm::FunctionPass {
  public:
  /** \brief definition of the type holding the set of control dependencies */
  typedef llvm::DenseSet<const llvm::BasicBlock *> BlockSet;
  /** \brief Uniq pass Id, replacement for typeinfo */
  static char ID;

  /** \brief default constructor */
  ControlDependence();

  /** \brief virtual destructor as we define virtual methods */
  ~ControlDependence();

  /** \brief used by the framework to query the set of analysis we depends on */
  virtual void getAnalysisUsage(llvm::AnalysisUsage& AU) const;  // NOLINT

  /** \brief run the analysis on the function */
  virtual bool runOnFunction(llvm::Function& F);  // NOLINT

  /** \brief compute the set of blocks control dependent on an instruction */
  const BlockSet * getOutputDependence(const llvm::Instruction * V) const;

  /** \brief return the set of blocks this value is dependent on */
  const BlockSet * getInputDependence(const llvm::Instruction * V) const;

  const BlockSet * getInputDependence(const llvm::BasicBlock * BB) const;

  private:
  typedef llvm::DenseMap<const llvm::BasicBlock *, BlockSet> DependenceMap;

  DependenceMap inputDependences;
  DependenceMap outputDependences;
};
}
}
#endif  // INCLUDE_LLVM_ANALYSIS_CONTROLDEPENDENCE_H_
