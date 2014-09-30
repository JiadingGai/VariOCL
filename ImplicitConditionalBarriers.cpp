//#include "config.h"

#include "ImplicitConditionalBarriers.h"
#include "barrier_inst.h"
#include "barrier_utils.h"
//#include "BarrierBlock.h"
//#include "Workgroup.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Module.h"

#include <iostream>

namespace SpmdKernel {

using namespace llvm;

namespace Coarsening {
  
  char ImplicitConditionalBarriers::ID = 0;
  
  namespace {  
    static
    RegisterPass<ImplicitConditionalBarriers> 
      X("implicit-cond-barriers", "Adds implicit barriers to branches.");
  }
  
  void
  ImplicitConditionalBarriers::getAnalysisUsage(AnalysisUsage &AU) const
  {
    AU.addRequired<PostDominatorTree>();
    AU.addPreserved<PostDominatorTree>();
    AU.addRequired<DominatorTree>();
    AU.addPreserved<DominatorTree>();
  }
  
  BasicBlock*
  ImplicitConditionalBarriers::firstNonBackedgePredecessor(BasicBlock *bb) 
  {
#if 0 
    DominatorTree *DT = &getAnalysis<DominatorTree>();
    pred_iterator I = pred_begin(bb), E = pred_end(bb);

    if (I == E) {
      return NULL;
    }

    while (DT->dominates(bb, *I) && I != E) {
      ++I;
    }

    if (I == E) {
      return NULL;
    }
    else {
      return *I;
    }
#else
    DominatorTree *DT = &getAnalysis<DominatorTree>();
    BasicBlock *APred = NULL;
    std::vector<BasicBlock*> PredBlocks;
    for (pred_iterator I = pred_begin(bb), E = pred_end(bb); I != E; ++I) {
      BasicBlock *P = *I;
      PredBlocks.push_back(P);
    }

    for (std::vector<BasicBlock*>::iterator I = PredBlocks.begin(), 
         E = PredBlocks.end(); I != E; ++I) {
      BasicBlock *PBlock = *I;

      if (!(DT->dominates(bb, PBlock))) {
        APred = PBlock;
        break;
      }
    }

    return APred;
#endif
  }
  
  bool
  ImplicitConditionalBarriers::runOnFunction(Function &F) 
  {
    bool changed = false;
    
    //if (!Workgroup::isKernelToProcess(F))
    //  return false;
    
    BasicBlock *Fentry = &(F.getEntryBlock()); 
    PDT = &getAnalysis<PostDominatorTree>();
  
    typedef std::vector<BasicBlock*> BarrierBlockIndex;
    BarrierBlockIndex CondBarrierBBs;
    for (Function::iterator I = F.begin(), E = F.end(); I != E; ++I) {
      BasicBlock *BB = I;
 
      bool HasBarrier = BarrierInst::hasBarrier(BB);
      bool IsConditionalBarrier = !(PDT->dominates(BB, Fentry));
   
      if (HasBarrier && IsConditionalBarrier) {
        CondBarrierBBs.push_back(BB);
      }
    }
  
    for (BarrierBlockIndex::const_iterator i = CondBarrierBBs.begin(), 
         e = CondBarrierBBs.end(); i != e; ++i) {
      BasicBlock *b = *i;
      BasicBlock *pos = b;

      BasicBlock *pred = firstNonBackedgePredecessor(b);

      // Locate the basic block that makes the barrier conditional.
      while (!containsJustABarrier(pred) && PDT->dominates(b, pred)) {
        pos = pred;
        pred = firstNonBackedgePredecessor(pred);
  
        if (pred == b) 
          break; 
      }
  
      if (containsJustABarrier(pos)) 
        continue;

      LLVMContext &LC = F.getContext();
      IntegerType * IntTy = IntegerType::get(LC, 32);
      Value *Args = ConstantInt::get(IntTy, 0); 
      Instruction *CondAuxBarrierInst =
        BarrierInst::createBarrier(Args, pos->getFirstNonPHI());
  
      MDNode* CondAuxBarrierInfo = 
        MDNode::get(LC, MDString::get(LC, "aux conditional barrier"));
      CondAuxBarrierInst->setMetadata("aux.cond.barrier", CondAuxBarrierInfo); 

      changed = true;
    }
  
    return changed;
  }
  
}
}

