#define DEBUG_TYPE "mxpa_cdg"

// LLVM includes

// MxPA includes
#include "control_dependence.h"

namespace SpmdKernel {

using namespace llvm;

namespace Coarsening {

  char ControlDep::ID = 0;
  
  namespace {
    static
    RegisterPass<ControlDep> CDGFunPass("mxpa_cdg", 
      "control dependence graph construction.");
  }

  bool ControlDep::runOnFunction(Function &F) {
    bool Changed = false;

    // Compute iterated post dominator frontiers.
    Frontiers.clear();
    PostDominatorTree &DT = getAnalysis<PostDominatorTree>();
    Roots = DT.getRoots();
    if (const DomTreeNode *Root = DT.getRootNode())
      calculate(DT, Root);

    // Put control dependence relations in a Digraph "CDG".
    DEBUG_WITH_TYPE("mxpa_cdg", debugCD(F));

    CDG.setNumNodes(F.size());
    for (Function::iterator BI = F.begin(), BE = F.end();
         BI != BE; ++BI) {
      BasicBlock *X = BI;
      CDG.addNode(X);
      for (Function::iterator BI2 = F.begin(), BE2 = F.end();
           BI2 != BE2; ++BI2) {
        BasicBlock *Y = BI2;
        bool IsCD = isCtrlDep(X, Y);
        if (IsCD) {
          CDG.addEdge(X, Y);
        }
      }
    }
    DEBUG_WITH_TYPE("mxpa_cdg", CDG.dump());

    TCCDG.setDigraph(&CDG);
    TCCDG.computeTC();
    DEBUG_WITH_TYPE("mxpa_cdg", TCCDG.dump());

    // Now the reverse CDG
    DF = &getAnalysis<DominanceFrontier>();

    RCDG.setNumNodes(F.size());
    for (Function::iterator BI = F.begin(), BE = F.end();
         BI != BE; ++BI) {
      BasicBlock *X = BI;
      RCDG.addNode(X);
      for (Function::iterator BI2 = F.begin(), BE2 = F.end();
           BI2 != BE2; ++BI2) {
        BasicBlock *Y = BI2;
        bool IsCD = isReverselyCtrlDep(X, Y);
        if (IsCD) {
          RCDG.addEdge(X, Y);
        }
      }
    }
    DEBUG_WITH_TYPE("mxpa_cdg", RCDG.dump());

    TCRCDG.setDigraph(&RCDG);
    TCRCDG.computeTC();
    DEBUG_WITH_TYPE("mxpa_cdg", TCRCDG.dump());

    return Changed;
  }

  void ControlDep::getAnalysisUsage(AnalysisUsage &AU) const {
    AU.setPreservesAll();
    AU.addRequired<DominatorTree>();
    AU.addRequired<PostDominatorTree>();
    AU.addRequired<DominanceFrontier>();
  }

  const DominanceFrontier::DomSetType &
  ControlDep::calculate(const PostDominatorTree &DT,
                        const DomTreeNode *Node) {
    BasicBlock *BB = Node->getBlock();
    DomSetType &S = Frontiers[BB]; 
    if (getRoots().empty()) return S;
  
    if (BB)
      for (pred_iterator SI = pred_begin(BB), SE = pred_end(BB);
           SI != SE; ++SI) {
        BasicBlock *P = *SI;
        DomTreeNode *SINode = DT[P];
        if (SINode && SINode->getIDom() != Node)
          S.insert(P);
      }
  
    for (DomTreeNode::const_iterator
           NI = Node->begin(), NE = Node->end(); NI != NE; ++NI) {
      DomTreeNode *IDominee = *NI;
      const DomSetType &ChildDF = calculate(DT, IDominee);
  
      DomSetType::const_iterator CDFI = ChildDF.begin(); 
      DomSetType::const_iterator CDFE = ChildDF.end();
      for (; CDFI != CDFE; ++CDFI) {
        if (!DT.properlyDominates(Node, DT[*CDFI]))
          S.insert(*CDFI);
      }
    }
  
    return S;
  }

  bool ControlDep::isCtrlDep(BasicBlock *X, BasicBlock *Y)
  {
    DomSetType YF = Frontiers[Y];
    
    if (YF.find(X) != YF.end()) {
      return true;
    } else {
      return false;
    }
  }

  bool ControlDep::isReverselyCtrlDep(BasicBlock *X, BasicBlock *Y)
  {
    DomSetType YF = DF->find(Y)->second;
    
    if (YF.find(X) != YF.end()) {
      return true;
    } else {
      return false;
    }
  }

  bool ControlDep::isIterativelyCtrlDep(BasicBlock *X, BasicBlock *Y)
  {
     return TCCDG.reachable(X, Y); 
  }

  bool ControlDep::isReverselyIterativelyCtrlDep(BasicBlock *X, BasicBlock *Y)
  {
     return TCRCDG.reachable(X, Y); 
  }

  void ControlDep::debugCD(Function &F)
  {
    for (Function::iterator BI = F.begin(), BE = F.end();
         BI != BE; ++BI) {
      BasicBlock *X = BI;
      for (Function::iterator BI2 = F.begin(), BE2 = F.end();
           BI2 != BE2; ++BI2) {
        BasicBlock *Y = BI2;
        bool IsCD = isCtrlDep(X, Y);
        if (IsCD) {
          DEBUG_WITH_TYPE("mxpa_cdg", 
            errs() << Y->getName() << " c-depends on " 
                   << X->getName() << " : " << IsCD << "\n");
        }
      }
    }
  }
  
}
}
