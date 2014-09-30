#ifndef MXPA_MS5_H
#define MXPA_MS5_H

// LLVM includes
#include "llvm/Analysis/DominanceFrontier.h"
#include "llvm/Analysis/PostDominators.h"
#include "llvm/IR/Function.h"
#include "llvm/Pass.h"
#include "llvm/Support/Debug.h"

// System includes
#include <stdlib.h>
#include <vector>
#include <map>

namespace SpmdKernel {
namespace Coarsening {

  class Digraph 
  {
    int V;
    int E;
  
    std::map<llvm::BasicBlock*, std::vector<llvm::BasicBlock*> > adj;
  
  public:
    typedef std::map<llvm::BasicBlock*, std::vector<llvm::BasicBlock*> >::iterator GraphIteratorTy;
    typedef std::vector<llvm::BasicBlock *>::iterator AdjIteratorTy;

    Digraph()
    {
      this->V = 0;
      this->E = 0;
    }
    
    Digraph(int V)
    {
      this->V = V;
      this->E = 0;
    }
  
    int getNumNodes() { return V; }
    int getNumEdges() { return E; }
    void setNumNodes(int V) 
    { 
      this->V = V; 
    }
    void setNumEdges(int E) 
    { 
      this->E = E; 
    }
  
    GraphIteratorTy begin() { return adj.begin(); }
    GraphIteratorTy end() { return adj.end(); }
 
    void addNode(llvm::BasicBlock *v)
    {
      adj[v];
    }

    void addEdge(llvm::BasicBlock *v, llvm::BasicBlock *w)
    {
      adj[v].push_back(w);
      E++;
    }
  
    std::vector<llvm::BasicBlock *> getAdjs(llvm::BasicBlock *v)
    {
      return adj[v];
    }
  
    void reverseGraph(Digraph *OutG)
    {
      OutG->setNumNodes(V);
      
      for (GraphIteratorTy I = begin(), E = end(); I != E; ++I) {
        llvm::BasicBlock *A = I->first;
        std::vector<llvm::BasicBlock *> B = I->second;

        for (AdjIteratorTy II = B.begin(), EE = B.end(); II != EE; ++II) {
          OutG->addEdge(*II, A);
        }
      }
    }

    void dump() 
    {
      for (GraphIteratorTy I = begin(), E = end(); I != E; ++I) {
        llvm::BasicBlock *A = I->first;
        std::vector<llvm::BasicBlock *> B = I->second;
 
        llvm::errs() << "[CtrlDepG]" << A->getName() << " :"; 
        for (AdjIteratorTy II = B.begin(), EE = B.end(); II != EE; ++II) {
          llvm::errs() << "-->" << (*II)->getName();
        }
        llvm::errs() << "\n";
      } 
    }
  };
  
  class DirectedDFS
  {
    std::map<llvm::BasicBlock *, bool> Marked;
  
    void dfs(Digraph *G, llvm::BasicBlock* v) 
    {
      Marked[v] = true;
  
      std::vector<llvm::BasicBlock *> Adjv = G->getAdjs(v);
      for (Digraph::AdjIteratorTy II = Adjv.begin(), EE = Adjv.end(); II != EE; ++II) {
        llvm::BasicBlock *X = *II;
          
        if (!Marked[X]) dfs(G, X);
      }
    }
  
  public:
  
    DirectedDFS(Digraph *G, std::vector<llvm::BasicBlock *> &S)
    {
      for (Digraph::AdjIteratorTy II = S.begin(), EE = S.end(); II != EE; ++II) {
        llvm::BasicBlock *Source = *II;
  
        if (!Marked[Source]) 
          dfs(G, Source);
      }
    }
  
    // Find vertices in G that are reachable from s.
    DirectedDFS(Digraph *G, llvm::BasicBlock* s)
    {
      dfs(G, s);
    }
  
    bool marked(llvm::BasicBlock* v) { return Marked[v]; }
  };
  
  class TransitiveClosure
  {
    std::map<llvm::BasicBlock*, DirectedDFS*> all;
    typedef std::map<llvm::BasicBlock*, DirectedDFS*>::iterator TransitiveClosureIteratorTy;
    Digraph *G;
  
  public:
 
    TransitiveClosure() {
      G = NULL;
    }

    void setDigraph(Digraph *G) {
      this->G = G;
    }
  
    void computeTC()
    {
      for (Digraph::GraphIteratorTy I = G->begin(), E = G->end(); I != E; ++I) {
        llvm::BasicBlock *A = I->first;
       
        all[A] = new DirectedDFS(G, A);
      }
    }

    bool reachable(llvm::BasicBlock *v, llvm::BasicBlock *w)
    {
      if (all.find(v) != all.end()) {
        return all[v]->marked(w);
      } else {
        return false;
      }
    }
  
    ~TransitiveClosure() {
      for (TransitiveClosureIteratorTy It = all.begin(), Ie = all.end(); It != Ie; ++It) {
        delete It->second;
      }
    }

    void dump() 
    {
      for (Digraph::GraphIteratorTy I = G->begin(), E = G->end(); I != E; ++I) {
        llvm::BasicBlock *X = I->first;
        llvm::errs() << "[TransitiveClosure]" << X->getName() << " :";
 
        for (Digraph::GraphIteratorTy II = G->begin(), EE = G->end(); II != EE; ++II) {
          llvm::BasicBlock *Y = II->first;
          bool IsTC = reachable(X, Y);
          if (IsTC) {
            llvm::errs() << "-->" << Y->getName();
          }
        }
        llvm::errs() << "\n";
      } 
    }

  };

  class ControlDep: public llvm::DominanceFrontierBase {
  public:
    static char ID;
    ControlDep() : llvm::DominanceFrontierBase(ID, true) {
      /* empty */; 
    }

    virtual bool runOnFunction(llvm::Function &F);
    virtual void getAnalysisUsage(llvm::AnalysisUsage &AU) const;
    
    // Tells whether Y is control dependent on X.
    virtual bool isCtrlDep(llvm::BasicBlock *X, 
                           llvm::BasicBlock *Y);


    // Tells whether Y is iteratively control dependent on X.
    virtual bool isIterativelyCtrlDep(llvm::BasicBlock *X, 
                                      llvm::BasicBlock *Y);
    
    // Tells whether Y is control dependent on X in the reverse CFG.
    virtual bool isReverselyCtrlDep(llvm::BasicBlock *X, 
                                    llvm::BasicBlock *Y);

    // Tells whether Y is iteratively control dependent on X 
    // in the reverse CFG.
    virtual bool isReverselyIterativelyCtrlDep(llvm::BasicBlock *X, 
                                               llvm::BasicBlock *Y);

    Digraph CDG;
    TransitiveClosure TCCDG;
    Digraph RCDG;
    TransitiveClosure TCRCDG;

  private:
    llvm::DominanceFrontier *DF;

    const llvm::DominanceFrontier::DomSetType &
      calculate(const llvm::PostDominatorTree &DT,
                const llvm::DomTreeNode *Node);

    void debugCD(llvm::Function &F);
  };

}
}

#endif
