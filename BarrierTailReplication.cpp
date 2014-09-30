//#include "config.h"
#include "BarrierTailReplication.h"
#include "barrier_inst.h"
//#include "Workgroup.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/IR/InstrTypes.h"
#include "llvm/IR/Instructions.h"

#include <iostream>
#include <algorithm>

using namespace llvm;

namespace SpmdKernel {

using namespace llvm;

namespace Coarsening {  

  char BarrierTailReplication::ID = 0;

namespace {
  static
  RegisterPass<BarrierTailReplication> X("barriertails",
					 "Barrier tail replication pass");
}

void
BarrierTailReplication::getAnalysisUsage(AnalysisUsage &AU) const
{
  AU.addRequired<DominatorTree>();
  AU.addPreserved<DominatorTree>();
  AU.addRequired<LoopInfo>();
  AU.addPreserved<LoopInfo>();
}

bool
BarrierTailReplication::runOnFunction(Function &F)
{
  //if (!Workgroup::isKernelToProcess(F))
  //  return false;
  
  DT = &getAnalysis<DominatorTree>();
  LI = &getAnalysis<LoopInfo>();

  bool changed = ProcessFunction(F);

  DT->verifyAnalysis();
  LI->verifyAnalysis();

  for (Function::iterator i = F.begin(), e = F.end();
       i != e; ++i)
    {
      llvm::BasicBlock *bb = i;
      changed |= CleanupPHIs(bb);
    }      

  return changed;
}

bool
BarrierTailReplication::ProcessFunction(Function &F)
{
  BasicBlockSet processed_bbs;

  return FindBarriersDFS(&F.getEntryBlock(), processed_bbs);
}  

bool
BarrierTailReplication::FindBarriersDFS(BasicBlock *bb,
                                        BasicBlockSet &processed_bbs)
{
  bool changed = false;

  if (processed_bbs.count(bb) != 0)
    return changed;

  processed_bbs.insert(bb);

  bool HasBarrier = BarrierInst::hasBarrier(bb);
  if (HasBarrier) {
    BasicBlockSet processed_bbs_rjs;
    changed = ReplicateJoinedSubgraphs(bb, bb, processed_bbs_rjs);
  }

  TerminatorInst *t = bb->getTerminator();

  for (unsigned i = 0, e = t->getNumSuccessors(); i != e; ++i)
    changed |= FindBarriersDFS(t->getSuccessor(i), processed_bbs);

  return changed;
}

bool
BarrierTailReplication::ReplicateJoinedSubgraphs(BasicBlock *dominator,
                                                 BasicBlock *subgraph_entry,
                                                 BasicBlockSet &processed_bbs)
{
  bool changed = false;

  assert(DT->dominates(dominator, subgraph_entry));

  Function *f = dominator->getParent();

  TerminatorInst *t = subgraph_entry->getTerminator();
  for (int i = 0, e = t->getNumSuccessors(); i != e; ++i) {
    BasicBlock *b = t->getSuccessor(i);

    if (processed_bbs.count(b) != 0) 
      {
        continue;
      }

    const bool isBackedge = DT->dominates(b, subgraph_entry);
    if (isBackedge) {
      continue;
    }
    if (DT->dominates(dominator, b))
      {
        changed |= ReplicateJoinedSubgraphs(dominator, b, processed_bbs);
      } 
    else           
      {
        BasicBlock *replicated_subgraph_entry =
          ReplicateSubgraph(b, f);
        t->setSuccessor(i, replicated_subgraph_entry);
        changed = true;
      }

    if (changed) 
      {
        DT->runOnFunction(*f);
      }
  }
  processed_bbs.insert(subgraph_entry);
  return changed;
}

bool
BarrierTailReplication::CleanupPHIs(llvm::BasicBlock *BB)
{
  bool changed = false;

  for (BasicBlock::iterator BI = BB->begin(), BE = BB->end(); BI != BE; )
    {
      PHINode *PN = dyn_cast<PHINode>(BI);
      if (PN == NULL) break;

      bool PHIRemoved = false;
      for (unsigned i = 0, e = PN->getNumIncomingValues(); i < e; ++i)
        {
          bool isSuccessor = false;
          for (unsigned s = 0, 
                 se = PN->getIncomingBlock(i)->getTerminator()->getNumSuccessors();
               s < se; ++s) {
            if (PN->getIncomingBlock(i)->getTerminator()->getSuccessor(s) == BB) 
              {
                isSuccessor = true;
                break;
              }
          }
          if (!isSuccessor)
            {
              PN->removeIncomingValue(i, true);
              changed = true;
              e--;
              if (e == 0)
                {
                  PHIRemoved = true;
                  break;
                }
              i = 0; 
              continue;
            }
        }
      if (PHIRemoved)
        BI = BB->begin();
      else
        BI++;
    }
  return changed;
}

BasicBlock *
BarrierTailReplication::ReplicateSubgraph(BasicBlock *entry,
                                          Function *f)
{
  BasicBlockVector subgraph;
  FindSubgraph(subgraph, entry);

  BasicBlockVector v;

  ValueToValueMapTy m;
  ReplicateBasicBlocks(v, m, subgraph, f);
  UpdateReferences(v, m);

  return cast<BasicBlock>(m[entry]);
}

void
BarrierTailReplication::FindSubgraph(BasicBlockVector &subgraph,
                                     BasicBlock *entry)
{
  if (std::count(subgraph.begin(), subgraph.end(), entry) > 0)
    return;

  subgraph.push_back(entry);

  const TerminatorInst *t = entry->getTerminator();
  for (unsigned i = 0, e = t->getNumSuccessors(); i != e; ++i) {
    BasicBlock *successor = t->getSuccessor(i);
    const bool isBackedge = DT->dominates(successor, entry);
    if (isBackedge) continue;
    FindSubgraph(subgraph, successor);
  }
}

void
BarrierTailReplication::ReplicateBasicBlocks(BasicBlockVector &new_graph,
                                             ValueToValueMapTy &reference_map,
                                             BasicBlockVector &graph,
                                             Function *f)
{
  for (BasicBlockVector::const_iterator i = graph.begin(),
         e = graph.end();
       i != e; ++i) {
    BasicBlock *b = *i;
    BasicBlock *new_b = BasicBlock::Create(b->getContext(),
					   b->getName() + ".btr",
					   f);
    reference_map.insert(std::make_pair(b, new_b));
    new_graph.push_back(new_b);

    for (BasicBlock::iterator i2 = b->begin(), e2 = b->end();
	 i2 != e2; ++i2) {
      Instruction *i = i2->clone();
      reference_map.insert(std::make_pair(i2, i));
      new_b->getInstList().push_back(i);
    }

    TerminatorInst *t = new_b->getTerminator();
    for (unsigned i = 0, e = t->getNumSuccessors(); i != e; ++i) {
      BasicBlock *successor = t->getSuccessor(i);
      if (std::count(graph.begin(), graph.end(), successor) == 0) {
        for (BasicBlock::iterator i  = successor->begin(), e = successor->end();
             i != e; ++i) {
          PHINode *phi = dyn_cast<PHINode>(i);
          if (phi == NULL)
            break; // All PHINodes already checked.
          
          Value *v = phi->getIncomingValueForBlock(b);
          Value *new_v = reference_map[v];
          if (new_v == NULL) {
            new_v = v;
          }
          phi->addIncoming(new_v, new_b);
        }
      }
    }
  }
}

void
BarrierTailReplication::UpdateReferences(const BasicBlockVector &graph,
                                         ValueToValueMapTy &reference_map)
{
  for (BasicBlockVector::const_iterator i = graph.begin(),
	 e = graph.end();
       i != e; ++i) {
    BasicBlock *b = *i;
    for (BasicBlock::iterator i2 = b->begin(), e2 = b->end();
         i2 != e2; ++i2) {
      Instruction *i = i2;
      RemapInstruction(i, reference_map,
                       RF_IgnoreMissingEntries | RF_NoModuleLevelChanges);
    }
  }
}

}
}
