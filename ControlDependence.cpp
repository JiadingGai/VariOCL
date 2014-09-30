/** \file lib/Analysis/ControlDependence.cpp
    \brief Implements ControlDependence Analysis Pass */
// TODO(matthieu): Add copyright/license here

#include "llvm/Analysis/Dominators.h"
#include "llvm/Analysis/PostDominators.h"

#include "ControlDependence.h"

namespace SpmdKernel {
namespace Coarsening {

using namespace llvm;

/** \brief Static initialization of ControlDependence class member ID.
    Set to 0 to mark as initially not registered
*/
char ControlDependence::ID = 0;

/** \brief Registration of the ControlDependence analysis.
    This will set the ControlDependence class member ID to a uniq value
*/
namespace {
  static 
  RegisterPass<ControlDependence> 
    X("control-dependence", 
      "Compute control dependencies between basic blocks", false, true);
}

ControlDependence::ControlDependence() : FunctionPass(ID) {
}

ControlDependence::~ControlDependence() {}

void ControlDependence::getAnalysisUsage(AnalysisUsage& AU) const { // NOLINT
  AU.addRequired<PostDominatorTree>();
  //AU.addRequired<PostDominanceFrontier>();
  AU.setPreservesAll();
}

bool ControlDependence::runOnFunction(Function& F) {  // NOLINT
  // we first initialize the maps
  BlockSet empty;
  PostDominatorTree& PDom = getAnalysis<PostDominatorTree>();
  for  (Function::iterator BB = F.begin(), BBe = F.end(); BB != BBe; ++BB) {
    inputDependences.insert(std::make_pair(BB, empty));
    outputDependences.insert(std::make_pair(BB, empty));
  }
  // we now do a quadratic search of all control dependencies. Can do better.
  // S2 is control dependent on S1 if and only if:
  //  * S2 post dominate a successor of S1,
  //  * S2 does not strictly post dominate S1
  for (Function::iterator S1 = F.begin(), S1e = F.end(); S1 != S1e; ++S1) {
    // As a consequence to the rules, S1 must have at least 2 successors.
    TerminatorInst * term = S1->getTerminator();
    unsigned nbSuccessors = term->getNumSuccessors();
    if (nbSuccessors < 2) continue;

    DependenceMap::iterator s1_set = outputDependences.find(S1);

    for (Function::iterator S2 = F.begin(), S2e = F.end(); S2 != S2e; ++S2) {
      // we check directly the second rule
      if (PDom.dominates (S2, S1)) continue;
      // We now need to find whether it post-dominates one of the successor
      bool found = false;
      for (unsigned successor = 0; (successor < nbSuccessors) && !found;
           ++successor) {
        if (PDom.dominates (S2, term->getSuccessor(successor))) found = true;
      }

      if (found) {  // S2 is control dependent on S1
        s1_set->second.insert(S2);
        DependenceMap::iterator s2_set = inputDependences.find(S2);
        s2_set->second.insert(S1);
      }
    }
  }
  return false;
}
typedef ControlDependence::BlockSet BlockSet;

const BlockSet * ControlDependence::getOutputDependence(
    const Instruction * I) const {
  assert(I && "NULL pointer for Value\n");
  if (!I) return NULL;

  // this only work if the value is a terminator inst
  if (!isa<TerminatorInst>(I)) return NULL;

  const BasicBlock * BB = I->getParent();
  assert(BB && "Value is not inserted in a basic block!\n");

  DependenceMap::const_iterator found = outputDependences.find(BB);
  assert(found != outputDependences.end()
         && "basic block not inserted within current function\n");

  if (found == outputDependences.end()) return NULL;

  return &found->second;
}

const BlockSet * ControlDependence::getInputDependence(
  const Instruction * I) const {
  assert(I && "NULL pointer for Instruction");
  if (!I) return NULL;
  const BasicBlock * BB = I->getParent();
  assert(BB && "Value is not inseted in a basic block!\n");
  return getInputDependence(BB);
}

const BlockSet * ControlDependence::getInputDependence(
    const BasicBlock*BB) const {
  assert(BB && "basic block does not exist");
  if (!BB) return NULL;

  DependenceMap::const_iterator found = inputDependences.find(BB);
  assert(found != inputDependences.end()
         && "basic block not inserted within current function\n");

  if (found == inputDependences.end()) return NULL;

  return &found->second;
}
 

}
}
