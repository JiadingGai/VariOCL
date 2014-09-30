#ifndef MXPA_BARRIER_TAIL_REPLICATION_H
#define MXPA_BARRIER_TAIL_REPLICATION_H

//#include "config.h"
#include "llvm/IR/Function.h"

#include "llvm/Analysis/Dominators.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Pass.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include <map>
#include <set>

namespace SpmdKernel {
namespace Coarsening {
  class Workgroup;

  class BarrierTailReplication : public llvm::FunctionPass {

  public:
    static char ID;

    BarrierTailReplication(): FunctionPass(ID) {}

    virtual void getAnalysisUsage(llvm::AnalysisUsage &AU) const;
    virtual bool runOnFunction(llvm::Function &F);
    
  private:
    typedef std::set<llvm::BasicBlock *> BasicBlockSet;
    typedef std::vector<llvm::BasicBlock *> BasicBlockVector;
    typedef std::map<llvm::Value *, llvm::Value *> ValueValueMap;

    llvm::DominatorTree *DT;
    llvm::LoopInfo *LI;

    bool ProcessFunction(llvm::Function &F);
    bool FindBarriersDFS(llvm::BasicBlock *bb,
                         BasicBlockSet &processed_bbs);
    bool ReplicateJoinedSubgraphs(llvm::BasicBlock *dominator,
                                  llvm::BasicBlock *subgraph_entry,
                                  BasicBlockSet &processed_bbs);

    llvm::BasicBlock* ReplicateSubgraph(llvm::BasicBlock *entry,
                                        llvm::Function *f);
    void FindSubgraph(BasicBlockVector &subgraph,
                      llvm::BasicBlock *entry);
    void ReplicateBasicBlocks(BasicBlockVector &new_graph,
                              llvm::ValueToValueMapTy &reference_map,
                              BasicBlockVector &graph,
                              llvm::Function *f);
    void UpdateReferences(const BasicBlockVector &graph,
                          llvm::ValueToValueMapTy &reference_map);

    bool CleanupPHIs(llvm::BasicBlock *BB);

    //friend class pocl::Workgroup;
  };
}
}
#endif
