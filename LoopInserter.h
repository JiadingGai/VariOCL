#ifndef MXPA_MS4_H
#define MXPA_MS4_H

#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/RegionInfo.h"
#include "llvm/Transforms/Utils/UnifyFunctionExitNodes.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Constants.h"
#include "llvm/InstVisitor.h"

// MxPA includes
#include "barrier_inst.h"
#include "control_dependence.h"
#include "triplet_invariance_analysis.h"

#define DEBUG_MACRO(X) \
   do {  { X; } \
   } while (0)

namespace SpmdKernel {
namespace Coarsening {

class MxPARegion : public llvm::Region {
public:
  //std::vector<llvm::BasicBlock *> BBSet;
  llvm::SmallPtrSet<llvm::BasicBlock*, 8> BBSet;
  bool IsSESE;

  MxPARegion(llvm::SmallPtrSet<llvm::BasicBlock*, 8> &RegionBBset, bool IsaSESE,  llvm::BasicBlock *Entry, 
             llvm::BasicBlock *Exit, llvm::RegionInfo *RInfo, llvm::DominatorTree *dt, llvm::Region *Parent = 0) 
             : Region(Entry, Exit, RInfo, dt), BBSet(RegionBBset), IsSESE(IsaSESE) {}

  typedef llvm::SmallPtrSet<llvm::BasicBlock*, 8>::iterator mxpa_bb_iterator;

  mxpa_bb_iterator block_begin() {return BBSet.begin();}
  mxpa_bb_iterator block_end() {return BBSet.end();}
};

class CondBarrier : public llvm::FunctionPass {
  llvm::DominatorTree *DT;
  llvm::PostDominatorTree *PDT;
  llvm::DominanceFrontier *DF;
  llvm::LoopInfo *LI;
  llvm::RegionInfo *RI;
  llvm::UnifyFunctionExitNodes *UFEN;
  ControlDep *CD;
  TripletInvarianceAnalysis *TIA;

  llvm::BasicBlock *RetBB;

  std::vector<MxPARegion*> PR;
  std::vector<MxPARegion*> PRVector;

  typedef std::map<MxPARegion*, llvm::Instruction*> R2IMapTy;
  R2IMapTy R2IMap;
 
  std::map<std::string, llvm::Instruction*> NamedContexts;

  std::map<llvm::Instruction*, unsigned> tempInstructionIds;
  size_t tempInstructionIndex;

  int __get_local_size[3];
  llvm::CallInst *Lsz[3];
  llvm::Value *Flat3DSize;

  llvm::GlobalVariable *TheTLB;

  bool containBarrierInRegion(MxPARegion *R);
  bool containBarrierInBB(llvm::BasicBlock *B);

  // get_global_id(dim) = 
  //   get_local_size(dim)*get_group_id(dim) + get_local_id(dim)
  //   + get_global_offset(dim)
  void expandGetGlobalID(llvm::Function &F);
  
  void InsertLocalSizeInfoToEntry(llvm::Function &F);

  void EnsureARealEntryOnTopABarrierEntry(llvm::Function &F);

  void moveAllocasToEntry(llvm::Function &F);
  
  void moveUniformCallsToEntry(llvm::Function &F);
  void moveUniformBIFCallsToEntry(llvm::Function &F);

  void addPredecessors(llvm::SmallVectorImpl<llvm::BasicBlock *> &v, 
                       llvm::BasicBlock *b);
 
  MxPARegion* createRegionBeforeBarrier(llvm::BasicBlock *Barrier, 
                                        llvm::RegionInfo *RI,
                                        llvm::DominatorTree *DT);
  
  void gatherParallelRegions(std::vector<MxPARegion *> &PRVector,
                             llvm::Function *F,
                             llvm::RegionInfo *RI,
                             llvm::DominatorTree *DT,
                             llvm::LoopInfo *LI);

  llvm::CallInst* insertCallToGetLocalID(std::string FuncName, 
                                   int dimindx, llvm::Module *M, 
                                   llvm::LLVMContext &Context, 
                                   llvm::Instruction *InsertBefore,
                                   MxPARegion *R = NULL);
  
  llvm::CallInst* insertCallToGetLocalSize(std::string FuncName, 
                                   int dimindx, llvm::Module *M, 
                                   llvm::LLVMContext &Context, 
                                   llvm::Instruction *InsertBefore);

  // From hive_off_barrier
  llvm::SmallPtrSet<llvm::Instruction*, 128> BarrierSet;

  llvm::BasicBlock* SplitBlockBeforeBarrier(llvm::BasicBlock *Old, 
                                            BarrierInst *SplitPt);

  llvm::BasicBlock* SplitBlockAfterBarrier(llvm::BasicBlock *Old, 
                                           BarrierInst *SplitPt);

  virtual void CollectBarriers(llvm::Function &F);
  bool ProcessBarrier(llvm::Function &F);
  
  void verifyHOBAnalysis() const;

  bool runHiveOffBarrierPass(llvm::Function &F);

  bool isRegionTrivial(MxPARegion *RN);
  bool isBasicBlockTrivial(llvm::BasicBlock *BB);
  
  bool isRegionUniform(MxPARegion *RN);
  bool isBasicBlockUniform(llvm::BasicBlock *BB);
  
public:
  static char ID;
  CondBarrier() : FunctionPass(ID) {
  }

  ~CondBarrier();

  virtual bool runOnFunction(llvm::Function &F);
  virtual void getAnalysisUsage(llvm::AnalysisUsage &AU) const;

  virtual std::pair<llvm::BasicBlock*, llvm::BasicBlock*> 
          buildLoopOverRegion(MxPARegion *RN, llvm::BasicBlock *EntryBB,
                              llvm::BasicBlock *ExitBB, int DimensionKind);

  // Insert do-while loop around an SESE region
  virtual std::pair<llvm::BasicBlock*, llvm::BasicBlock*> 
          buildDWLoopOverRegion(MxPARegion *RN, llvm::BasicBlock *EntryBB,
                                llvm::BasicBlock *ExitBB, int DimensionKind);

  virtual void deployRegionContext(MxPARegion *R);

  MxPARegion* findRegionContains(llvm::BasicBlock *BB);

  llvm::Instruction* getContextReplacementOf(llvm::Instruction *Inst);

  void performContextBuffering(llvm::Instruction *Inst);

  llvm::Instruction* doContextStore(llvm::Instruction *Inst,
                                    llvm::Instruction *Alloca);

  llvm::Instruction* doContextReload(llvm::Value *Val, 
                                     llvm::Instruction *Alloca,
                                     llvm::Instruction *Before,
                                     bool isAlloca);

  llvm::StringRef getCalledFunctionName(llvm::CallInst *Call);

  typedef enum {Unknown, Unconditional, Conditional} BarrierKind;
  BarrierKind getBarrierKind(BarrierInst *BI);

};

//===----------------------------------------------------------------------===//
struct IPLooper : public llvm::ModulePass {
  virtual void getAnalysisUsage(llvm::AnalysisUsage &AU) const;
  static char ID;
  IPLooper() : llvm::ModulePass(ID) {
    ;
  }
  bool runOnModule(llvm::Module &M);
  
  // inject forward declarations for all the work-item functions
  void forwardDeclWIFs(llvm::Module &M);
};
  
}
}

#endif

