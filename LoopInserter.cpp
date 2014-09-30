#define DEBUG_TYPE "mxpa_ms5"

// LLVM includes
#include "llvm/Bitcode/ReaderWriter.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/Instruction.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Constant.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Bitcode/ReaderWriter.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/Debug.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Analysis/Verifier.h"
#include "llvm/ADT/DepthFirstIterator.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/IRReader/IRReader.h"

// System includes
#include <sstream>
#include <algorithm>

// MxPA includes
#include "LoopInserter.h"
#include "kernel_info_reader.h"
#include "barrier_utils.h"

#define CONTEXT_ARRAY_ALIGN 64

namespace SpmdKernel {

using namespace llvm;

namespace Coarsening {

  char CondBarrier::ID = 0;

  namespace {
    static
    RegisterPass<CondBarrier>
      X("mxpa_loopinserter",
        "maximum coarsening on any cl programs");

    static IRBuilder<> Builder(getGlobalContext());
  }

  void CondBarrier::expandGetGlobalID(Function &F) 
  {
    Module *Mod = F.getParent();
    LLVMContext &LC = F.getContext();

    std::vector<Instruction*> CallsToErase;

    for (Function::iterator i = F.begin(), e = F.end(); i != e; ++i) {
      BasicBlock *BB = i;
      for (BasicBlock::iterator BI = BB->begin(), BE = BB->end(); 
           BI != BE; ++BI) {
        assert(BI && "Iteration encounters an undefined instructions\n");
        Instruction *inst = BI;
        if (isa<CallInst>(inst)) {
          CallInst *a_call = cast<CallInst>(inst);
          StringRef called_func_nm = getCalledFunctionName(a_call);
          StringRef target_func_nm("get_global_id");
          if (called_func_nm == target_func_nm) {
            Value *get_global_id_arg = a_call->getArgOperand(0);

            Type *Int32Ty = IntegerType::get(LC, 32);

            Builder.SetInsertPoint(a_call);
            CallInst *GLSCall = Builder.CreateCall(
              cast<Function>(Mod->getOrInsertFunction(
                                    "get_local_size", Int32Ty, Int32Ty, NULL)),
              get_global_id_arg,
              "get_local_size");

            CallInst *GGrpIDCall = Builder.CreateCall(
              cast<Function>(Mod->getOrInsertFunction(
                                    "get_group_id", Int32Ty, Int32Ty, NULL)),
              get_global_id_arg,
              "get_group_id");

            CallInst *GLIDCall = Builder.CreateCall(
              cast<Function>(Mod->getOrInsertFunction(
                                    "get_local_id", Int32Ty, Int32Ty, NULL)),
              get_global_id_arg,
              "get_local_id");

            CallInst *GGOCall = Builder.CreateCall(
              cast<Function>(Mod->getOrInsertFunction(
                                    "get_global_offset", Int32Ty, 
                                    Int32Ty, NULL)),
              get_global_id_arg,
              "get_global_offset");
            
            //The "get_global_id" expansion formula:
            //
            // get_global_id(dim) = 
            //   get_local_size(dim)*get_group_id(dim) + get_local_id(dim) 
            //   + get_global_offset(dim)
            Value *the_repl =  Builder.CreateAdd(
                                 Builder.CreateAdd(
                                   Builder.CreateMul(GLSCall, GGrpIDCall),
                                   GLIDCall),
                                 GGOCall);
           
            if (a_call->hasOneUse() && isa<TruncInst>(a_call->use_back())) {
              TruncInst *TI = cast<TruncInst>(a_call->use_back());
              TI->replaceAllUsesWith(the_repl);
              CallsToErase.push_back(TI);
            } else {
              a_call->replaceAllUsesWith(the_repl);
            }
             
            #if 0 //FIXME: understand why this erase method does not work??
            a_call->eraseFromParent();
            #else
            CallsToErase.push_back(a_call);
            #endif
          }
        }
      }
    }

    for (std::vector<Instruction*>::iterator i = CallsToErase.begin(), 
            e = CallsToErase.end(); i != e; ++i) {
        (*i)->eraseFromParent();
    }
  }

  void CondBarrier::addPredecessors(SmallVectorImpl<BasicBlock *> &v, 
                                    BasicBlock *b)
  {
    for (pred_iterator i = pred_begin(b), e = pred_end(b);
         i !=e; ++i) {
      if ((containsJustABarrier(*i)) && containsJustABarrier(b)) {
        // CXLV
        addPredecessors(v, *i);
        continue;
      }
      v.push_back(*i);
    }
  }

  MxPARegion* CondBarrier::createRegionBeforeBarrier(BasicBlock *Barrier,
                                                     RegionInfo *RI,
                                                     DominatorTree *DT)
  {
    //The BB work list for the region (by a bottom-up formation from *Barrier)
    SmallVector<BasicBlock*, 4> BBWorkList;
    SmallPtrSet<BasicBlock*, 8> RegionBBSet;
    BasicBlock *RegionEntryBarrier = NULL;
    BasicBlock *Entry = NULL;
    BasicBlock *Exit = Barrier->getSinglePredecessor();
    
    //assert(Exit && "Invalid region exit detected during formation!");

    BBWorkList.clear();

    addPredecessors(BBWorkList, Barrier);
  
    while (!BBWorkList.empty()) {
      BasicBlock *CurrentBB = BBWorkList.pop_back_val();

      bool AlreadyInThisRegion = (RegionBBSet.count(CurrentBB) == 1);
      if (AlreadyInThisRegion) {
        continue;
      }

      if (containBarrierInBB(CurrentBB)) {
        if (RegionEntryBarrier == NULL) {
          RegionEntryBarrier = CurrentBB;
        }
        continue;
      }

      //CIII ...

      DEBUG_WITH_TYPE("mxpa_ms5", errs() << *CurrentBB << "\n");
      RegionBBSet.insert(CurrentBB);
      addPredecessors(BBWorkList, CurrentBB);
    }

    if (RegionBBSet.empty())
      return NULL;

    //FIXME:
    //assert(RegionEntryBarrier != NULL);
    if (RegionEntryBarrier == NULL) {
      return NULL;
    }
    
    TerminatorInst *REBTI = RegionEntryBarrier->getTerminator();
    for (unsigned i = 0, ie = REBTI->getNumSuccessors(); i != ie; ++i) {
      BasicBlock *EntryCandidate = REBTI->getSuccessor(i);
      if (RegionBBSet.count(EntryCandidate) == 1) {
        Entry = EntryCandidate;
        break;
      }
    }
    assert (RegionBBSet.count(Entry) != 0);

    return new MxPARegion(RegionBBSet, false, Entry, Exit, RI, DT);
  }

  void CondBarrier::gatherParallelRegions(std::vector<MxPARegion *> &PRVector,
                                          Function *F,
                                          RegionInfo *RI,
                                          DominatorTree *DT,
                                          LoopInfo *LI)
  {
    PRVector.clear();

    std::vector<BasicBlock *> ExitBlocks;
    ExitBlocks.clear();
 
    // Collect all exits of the kernel
    for (Function::iterator i = F->begin(), e = F->end(); i != e; ++i) {
      const TerminatorInst *t = i->getTerminator();
      if (t->getNumSuccessors() == 0) {
        assert(containsJustABarrier(i) && "All exits must be barrier blocks.");
        ExitBlocks.push_back(i);
      }
    }

    SmallPtrSet<BasicBlock *, 8> VisitedBarriers;

    while (!ExitBlocks.empty()) {
      
      BasicBlock *ExitBB = ExitBlocks.back();
      ExitBlocks.pop_back();

      assert(containsJustABarrier(ExitBB) && 
             "Region formation must start from a barrier BB");
      while (MxPARegion *PR = createRegionBeforeBarrier(ExitBB, RI, DT)) {
        assert(PR != NULL && 
               "Empty parallel region in kernel (contiguous barriers)!");

        DEBUG_WITH_TYPE("mxpa_ms5", errs() << "Region collected: " << *PR << "\n");

        VisitedBarriers.insert(ExitBB);
        ExitBB = NULL;
        PRVector.push_back(PR);
        BasicBlock *EntryBB = PR->getEntry();
        int found_predecessors = 0;
        BasicBlock *LoopBarrierBB = NULL;
        for (pred_iterator i = pred_begin(EntryBB), e = pred_end(EntryBB);
             i != e; ++i) {
          BasicBlock *BarrierBB = (*i);
          if (!VisitedBarriers.count(BarrierBB)) {
            bool IS_IN_THE_SAME_LOOP = 
                LI->getLoopFor(BarrierBB) != NULL &&
                LI->getLoopFor(EntryBB) != NULL &&
                LI->getLoopFor(EntryBB) == LI->getLoopFor(BarrierBB);

            if (IS_IN_THE_SAME_LOOP) {
                if (LoopBarrierBB != NULL) {
                  ExitBlocks.push_back(LoopBarrierBB);
                }
                LoopBarrierBB = BarrierBB;
            } else {
                ExitBB = BarrierBB;
            }
            ++found_predecessors;
          }
        }

        if (LoopBarrierBB != NULL) {
            if (ExitBB != NULL) 
              ExitBlocks.push_back(ExitBB);
            if (!VisitedBarriers.count(LoopBarrierBB))
              ExitBB = LoopBarrierBB; 
        }

        if (found_predecessors == 0)
          break;

        assert ((ExitBB != NULL) && "Parallel region without entry barrier!");
      }
    }
  }

  bool CondBarrier::runOnFunction(Function &F) 
  {
    bool Changed = false;

    expandGetGlobalID(F);
    EnsureARealEntryOnTopABarrierEntry(F);
    InsertLocalSizeInfoToEntry(F);


    // Privatizing local memory 
    Module *M = F.getParent();
    for (Module::global_iterator I = M->global_begin(), E = M->global_end(); I != E; ++I) {
      GlobalVariable *GV = I;
      std::string GVName = GV->getName().str();
      std::string FnName = F.getName().str();

      std::size_t Found = GVName.find(FnName);

      if (Found != std::string::npos) {
        BasicBlock *EntryBlock = &F.getEntryBlock();
        std::string LocalName = GVName.substr(FnName.size());

        Type * GlobalType = GV->getType()->getElementType();

        Builder.SetInsertPoint(F.getEntryBlock().getFirstNonPHI());
        AllocaInst *AI = 
          Builder.CreateAlloca(GlobalType, 0, "localmem" + LocalName);
        AI->setAlignment(GV->getAlignment());

        DEBUG_WITH_TYPE("mxpa_ms5", errs() << "[Globals] " <<  GVName << ":" << LocalName << ":" << GV->getNumUses() << ":" << *AI << "\n");
        std::vector<Instruction*> GVUsers;
        for (GlobalVariable::use_iterator ui = GV->use_begin(), ue = GV->use_end(); ui != ue; ++ui) {
          Instruction *User = dyn_cast<Instruction>(*ui);


          if (User) {
            DEBUG_WITH_TYPE("mxpa_ms5", errs() << "[GlobalUsers]" << *User << "\n");
            //User->replaceUsesOfWith(GV, AI);
            GVUsers.push_back(User);
          } else {
            //(*ui)->dump();
          }
        }

        for (std::vector<Instruction*>::iterator ui = GVUsers.begin(), ue = GVUsers.end(); ui != ue; ++ui) {
          Instruction *User = dyn_cast<Instruction>(*ui);
          User->replaceUsesOfWith(GV, AI);
        }
      }
    }

    DT = &getAnalysis<DominatorTree>();
    PDT = &getAnalysis<PostDominatorTree>();
    DF = &getAnalysis<DominanceFrontier>();
    LI = &getAnalysis<LoopInfo>();
    RI = &getAnalysis<RegionInfo>();
    //UFEN = &getAnalysis<UnifyFunctionExitNodes>();
    CD = &getAnalysis<ControlDep>();
    TIA = &getAnalysis<TripletInvarianceAnalysis>();

#if 0    
    for (Function::iterator BI = F.begin(), BE = F.end(); BI != BE; ++BI) {
      if (containsJustABarrier(BI)) {
        for (Function::iterator BI2 = F.begin(), BE2 = F.end(); BI2 != BE2; ++BI2) {
          if (CD->isCtrlDep(BI2, BI)) {
            errs() << BI->getName() << " c-dp'd on " << BI2->getName() << " \n";
          }
        }
      }
    }
#endif

//    runHiveOffBarrierPass(F);

    // NEW ------------------------------------------------------------------//
#if 0 // milestone 4 specific region formation
    int BarrierID = 0;
    std::vector<BasicBlock*> BarBBs;
    for (Function::iterator ib = F.begin(), ie = F.end(); ib != ie; ++ib) {
      BasicBlock *BB = &*ib;
     
      //if (containsJustABarrier(BB)) {
      if (containBarrierInBB(BB)) {
        ++BarrierID;
        //errs() << "Barrier No. " << BarrierID << ":" << *BB->begin() << "\n";
        BarBBs.push_back(BB);
      }
    }

    int NumOfRegions = BarBBs.size() - 1;
    Region *RD[NumOfRegions];

    PR.clear();
    for (int i = 0; i < NumOfRegions; ++i) {
      //no region formation for the toppest barrier
      BasicBlock *a = BarBBs[i + 1];
      RD[i] = createRegionBeforeBarrier(a, RI, DT);
      PR.push_back(RD[i]);
    }
#else // milestone 5 region formation, backwared compatible with milestone 4.
    PRVector.clear();
    gatherParallelRegions(PRVector, &F, RI, DT, LI);
    DEBUG_WITH_TYPE("mxpa_ms5", errs() << "PR gathered: " << PRVector.size() << "\n");

    int RegionCount = 0;
    for (std::vector<MxPARegion*>::iterator ri = PRVector.begin(); ri != PRVector.end(); 
         ++ri) {
      DEBUG_WITH_TYPE("mxpa_ms5", errs() << **ri << " | " 
                                         << (*ri)->isSimple() << " | " << RegionCount << "\n");
      ++RegionCount;
    }
    DEBUG_WITH_TYPE("mxpa_ms5", errs() << "Total # of parallel regions (raw) is " 
                                       << RegionCount << "\n");

    // "Raw" means some region might be proven late as not necessary for a mxpa loop insertion around
    int NumOfRawRegions  = PRVector.size();
    MxPARegion *RD[NumOfRawRegions];
    PR.clear();
    for (int i = 0; i < NumOfRawRegions; ++i) {
      RD[i] = PRVector[i];
      
      if (!isRegionTrivial(RD[i]) && !isRegionUniform(RD[i])) {
        PR.push_back(RD[i]);
      }
    }
#endif

    //assert(PR.size() > 0 && "Milestone 5 should have at least one region!");
    if (PR.size() > 0) {
      int NumOfRegions = PR.size();
      for (int i = 0; i < NumOfRegions; ++i) {
        BasicBlock::iterator WhereToInsertLocalID = PR[i]->getEntry()->getFirstNonPHI();
        CallInst *Lid[3] = {NULL, NULL, NULL};
        for (int j = 0; j < 3; ++j) {
          Lid[j] = insertCallToGetLocalID("get_local_id", j, F.getParent(),
                                    F.getContext(), WhereToInsertLocalID, PR[i]);
        } 
  
        Builder.SetInsertPoint(WhereToInsertLocalID);
        Value *FlatIdx = Builder.CreateAdd(
                           Builder.CreateAdd(
                             Builder.CreateMul(Builder.CreateMul(Lid[2], Lsz[0]), Lsz[1]),
                             Builder.CreateMul(Lid[1], Lsz[0])
                           ),
                           Lid[0], 
                           "FlatIdx"
                         );
  
        R2IMap[PR[i]] = cast<Instruction>(FlatIdx);
      }
   
      // NEW ------------------------------------------------------------------//
  
      int region_count = 0;
      for (std::vector<MxPARegion*>::iterator ri = PR.begin(); ri != PR.end(); 
           ++ri) {
        DEBUG_WITH_TYPE("mxpa_ms5", errs() << **ri << " | " 
                                           << (*ri)->isSimple() << "\n");
        ++region_count;
      }
      DEBUG_WITH_TYPE("mxpa_ms5", errs() << "Total # of parallel regions (ms5) is " 
                                         << region_count << "\n");

      for (std::vector<MxPARegion*>::iterator ri = PR.begin(); ri != PR.end(); ++ri) 
      {
        deployRegionContext(*ri);
  
        Changed = true;
      }


      for (std::vector<MxPARegion*>::iterator ri = PR.begin(); ri != PR.end(); ++ri) 
      {
        MxPARegion *X = (*ri);
  
        BasicBlock *Entry = X->getEntry();
        BasicBlock *Exit = X->getExit();
  
        DEBUG_WITH_TYPE("mxpa_ms5", errs() << " Inserting loop around (" 
                                           << Entry->getName() << ","
                                           << Exit->getName() << ")\n");
  
        std::pair<BasicBlock*, BasicBlock*> l0, l1, l2;
        l0 = buildDWLoopOverRegion(X, Entry, Exit, 0);
        
        l1 = buildDWLoopOverRegion(X, l0.first, l0.second, 1);
       
        l2 = buildDWLoopOverRegion(X, l1.first, l1.second, 2);
  
        Changed = true;
      }
  
      // As a final step, prior to output a .bc file, 
      // remove all the barrier calls.
      std::vector<Instruction*> BarrierCalls;
      for (Function::iterator ibb = F.begin(), ibe = F.end();
           ibb != ibe; ++ibb)  {
        for (BasicBlock::iterator iib = ibb->begin(), iie = ibb->end();
             iib != iie; ++iib) {
          Instruction *inst = iib;
  
          if (isa<CallInst>(inst)) {
            CallInst *BCall = cast<CallInst>(inst);
            StringRef called_func_nm = getCalledFunctionName(BCall);
            StringRef barrier_func_nm("barrier");
  
            if (called_func_nm == barrier_func_nm) {
              BarrierCalls.push_back(BCall);
            }
          }
        }
      }
      for (std::vector<Instruction*>::iterator i = BarrierCalls.begin(), 
              e = BarrierCalls.end(); i != e; ++i) {
          (*i)->eraseFromParent();
      }
  
      // These are for fixing the "undominated uses" issue.
      moveAllocasToEntry(F);
      //moveUniformCallsToEntry(F);
      moveUniformBIFCallsToEntry(F);
    }

    return Changed;
  }

  bool CondBarrier::isBasicBlockTrivial(BasicBlock *BB)
  {
    TerminatorInst *Bt = BB->getTerminator();
    BranchInst *Br = dyn_cast<BranchInst>(Bt);
  
    if ((BB->size() == 1) && 
        (Bt->getNumSuccessors() == 1) && 
        (BB->getSinglePredecessor()) && 
        !(Br->isConditional())) {
      return true;
    }
    
    return false;
  }

  bool CondBarrier::isBasicBlockUniform(BasicBlock *BB)
  {
    bool IsBBUniform = true;
    Function *F = BB->getParent();

    for (BasicBlock::iterator I = BB->begin(), E = BB->end(); I != E; ++I) {
      Instruction *Inst = &*I;

      if (!TIA->isUniform(F, Inst)) {
        IsBBUniform = false;
      }
    }

    return IsBBUniform;
  }

  bool CondBarrier::isRegionTrivial(MxPARegion *RN)
  {
    if (RN->getEntry() != RN->getExit()) {
      bool IsRegionTrivial = true;

      for (MxPARegion::mxpa_bb_iterator i = RN->block_begin(), 
             e = RN->block_end(); i != e; ++i) {
          BasicBlock *BB = *i;
      
          if (!isBasicBlockTrivial(BB)) {
            IsRegionTrivial = false;
            break;
          }
      }
      return IsRegionTrivial;
    } else {
      return isBasicBlockTrivial(RN->getEntry());
    }
  }

  bool CondBarrier::isRegionUniform(MxPARegion *RN)
  {
    if (RN->getEntry() != RN->getExit()) {
      bool IsRegionUniform = true;

      for (MxPARegion::mxpa_bb_iterator i = RN->block_begin(), e = RN->block_end(); i != e; ++i) {
        BasicBlock *BB = *i;
      
        if (!isBasicBlockUniform(BB)) {
          IsRegionUniform = false;
          break;
        }
      }
      return IsRegionUniform;
    } else {
      return isBasicBlockUniform(RN->getEntry());
    }
  }

  CondBarrier::~CondBarrier() {
    ;
  }

  void CondBarrier::getAnalysisUsage(AnalysisUsage &AU) const {
    
    //AU.addRequired<UnifyFunctionExitNodes>();
    AU.addRequired<DominatorTree>();
    AU.addRequired<PostDominatorTree>();
    AU.addRequired<DominanceFrontier>();
    AU.addRequired<LoopInfo>();
    AU.addRequired<RegionInfo>();

    AU.addRequired<ControlDep>();

    AU.addRequired<TripletInvarianceAnalysis>();
    //AU.addRequired<DataLayout>();
  }

  std::pair<BasicBlock*, BasicBlock*>
  CondBarrier::buildLoopOverRegion(MxPARegion *RN, BasicBlock *EntryBB,
                                   BasicBlock *ExitBB, int DimensionKind) 
  {
    assert(EntryBB && "Region's entry BB is empty");
    assert(ExitBB && "Region's exit BB is empty");
      
    Function *Fun = EntryBB->getParent();
    Module *Mod = Fun->getParent();
    LLVMContext &LC = Fun->getContext();
    
    // Insert a loop latch node after ExitBB, and re-organize branches.
    assert(ExitBB->getTerminator()->getNumSuccessors() <= 1);
    BasicBlock *TheSucc2Exit = ExitBB->getTerminator()->getSuccessor(0);
    BasicBlock *LatchBB = BasicBlock::Create(LC, "mxpa.latch", 
                                             Fun, TheSucc2Exit);

    ExitBB->getTerminator()->replaceUsesOfWith(TheSucc2Exit, LatchBB);

    Builder.SetInsertPoint(LatchBB);
    Builder.CreateBr(TheSucc2Exit);
    
    BasicBlock *LoopBody = EntryBB;
    LoopBody->setName(std::string("mxpa.lp.body"));

    assert(LatchBB->getTerminator()->getNumSuccessors() == 1);
    
    BasicBlock *OldExitBB = LatchBB->getTerminator()->getSuccessor(0);

    BasicBlock *LoopPreheader = 
      BasicBlock::Create(LC, "mxpa.lp.phdr", Fun, LoopBody);
    DT->addNewBlock(LoopPreheader, DT->getNode(EntryBB)->getBlock());

    BasicBlock *LoopHeader = 
      BasicBlock::Create(LC, "mxpa.lp.hdr", Fun, LoopBody);
    DT->addNewBlock(LoopHeader, LoopPreheader);

    BasicBlock *LoopEnd = 
      BasicBlock::Create(LC, "mxpa.lp.end", Fun, ExitBB);
    DT->addNewBlock(LoopEnd, LoopHeader);
   
    //
    std::set<BasicBlock*> LoopEntryPreds;
    DT = getAnalysisIfAvailable<DominatorTree>();
    for (pred_iterator PI = pred_begin(EntryBB), E = pred_end(EntryBB); 
         PI != E; ++PI) {
      BasicBlock *Pred = *PI;
      if (DT->dominates(EntryBB, Pred))
          continue;
      Pred->getTerminator()->replaceUsesOfWith(EntryBB, LoopPreheader);

      // Collects all preds that are not in the region
      LoopEntryPreds.insert(Pred);
    }

    // Loop over the PHI nodes in EntryBB, fix incoming BBs from the old
    // predecessors to the new predecessors
    for (BasicBlock::iterator i = EntryBB->begin(), E = EntryBB->end();
         i != E; ++i) {
      Instruction *I = &*i;
      if (isa<PHINode>(I)) {
        PHINode *PN = cast<PHINode>(I);

        for (unsigned i = 0, e = PN->getNumIncomingValues(); i != e; ++i) {
          BasicBlock *IBB = PN->getIncomingBlock(i);

          if (LoopEntryPreds.find(IBB) != LoopEntryPreds.end()) {
            PN->setIncomingBlock(i, LoopHeader);
          }
        }
      }
    }

    //
    Builder.SetInsertPoint(LoopPreheader);
    Builder.CreateBr(LoopHeader);
    
    //
    LatchBB->getTerminator()->replaceUsesOfWith(OldExitBB, LoopHeader);
    
    //
    Builder.SetInsertPoint(LoopHeader, LoopHeader->getFirstNonPHI());
    std::stringstream ss;
    ss << "IV" << DimensionKind;
    PHINode *IV =
      Builder.CreatePHI(Type::getInt32Ty(getGlobalContext()), 2, ss.str());

    Constant *Zero = ConstantInt::get(Type::getInt32Ty(getGlobalContext()), 0);
    IV->addIncoming(Zero, LoopPreheader);

    Value *CmpResult;
#if 1
    CallInst *GLSCall = Builder.CreateCall(
      cast<Function>(Mod->getOrInsertFunction(
                            "get_local_size", 
                            Type::getInt32Ty(getGlobalContext()),
                            Type::getInt32Ty(getGlobalContext()),
                            (Type *)0)), 
      ConstantInt::get(IntegerType::get(LC, 32), DimensionKind), 
      "get_local_size");
    
    CmpResult = Builder.CreateICmpULT(IV, GLSCall, "CmpResult");
#endif
    Builder.CreateCondBr(CmpResult, LoopBody, LoopEnd);

    //
    Builder.SetInsertPoint(LatchBB->getTerminator());
    ss << "_inc";
    Value *IV_inc = Builder.CreateAdd(IV,
            ConstantInt::get(IntegerType::get(LC,32), 1), ss.str());
    IV->addIncoming(IV_inc, LatchBB);

    // Redirect "br to OldExitBB" to "br to LatchBB"
    LoopBody->getTerminator()->replaceUsesOfWith(OldExitBB, LatchBB);
    
    //
    Builder.SetInsertPoint(LoopEnd);
    Builder.CreateBr(OldExitBB);

    // Replace get_*_id calls with induction variables.
    std::vector<Instruction*> CallsToErase;
    std::vector<BasicBlock*> BBInvolved;

    // If RN contains more than one basic block.
    if (RN->getEntry() != RN->getExit()) {
      //FIXME: LLVM df_iterator cannot traverse a graph containing just one BB.
      for (MxPARegion::mxpa_bb_iterator i = RN->block_begin(), 
           e = RN->block_end(); i != e; ++i) {
        BasicBlock *BB = *i;
        BBInvolved.push_back(BB);
      }
    } else {
      // Need to replace calls in the exit block of the region too, which is
      // not part of the region.
      //FIXME:
      BBInvolved.push_back(RN->getExit());
    }

    for (std::vector<BasicBlock*>::iterator i = BBInvolved.begin(), 
         e = BBInvolved.end(); i != e; ++i) {
      BasicBlock *BB = *i;
      //DEBUG_WITH_TYPE("mxpa_ms5" , errs() << "Region block: " 
      //                << BB->getName() << "\n");
      for (BasicBlock::iterator BI = BB->begin(), BE = BB->end(); BI != BE; 
           ++BI) {
        assert(BI && "Iteration encounters an undefined instructions\n");
        Instruction *inst = BI;
        if (isa<CallInst>(inst)) {
          //DEBUG_WITH_TYPE("mxpa_ms5", errs() << "Found a function call" 
          //                                   << *inst << "\n");
          CallInst *a_call = cast<CallInst>(inst);
          StringRef called_func_nm = getCalledFunctionName(a_call);
          StringRef target_func_nm("get_local_id");
          if (called_func_nm == target_func_nm) {
            Value *get_local_id_arg = a_call->getArgOperand(0);
            ConstantInt *CI = dyn_cast<ConstantInt>(get_local_id_arg);
            ConstantInt *DK_CI = ConstantInt::get(IntegerType::get(LC,32), 
                                                  DimensionKind);

            if (CI == DK_CI) {
              if (a_call->hasOneUse() && isa<TruncInst>(a_call->use_back())) {
                TruncInst *TI = cast<TruncInst>(a_call->use_back());
                TI->replaceAllUsesWith(IV);
                CallsToErase.push_back(TI);
              } else {
                a_call->replaceAllUsesWith(IV);
              }
               
              #if 0 //FIXME: understand why this erase method does not work??
              a_call->eraseFromParent();
              #else
              CallsToErase.push_back(a_call);
              #endif
            }
          }
        }
      }
    }

    for (std::vector<Instruction*>::iterator i = CallsToErase.begin(), 
            e = CallsToErase.end(); i != e; ++i) {
        (*i)->eraseFromParent();
    }

    return std::make_pair(LoopPreheader, LoopEnd);
  }

  std::pair<BasicBlock*, BasicBlock*>
  CondBarrier::buildDWLoopOverRegion(MxPARegion *RN, BasicBlock *EntryBB,
                                     BasicBlock *ExitBB, int DimensionKind) 
  {
    assert(EntryBB && "Region's entry BB is empty");
    assert(ExitBB && "Region's exit BB is empty");
      
    Function *Fun = EntryBB->getParent();
    Module *Mod = Fun->getParent();
    LLVMContext &LC = Fun->getContext();
    
    // Insert a loop latch node after ExitBB, and re-organize branches.
    assert(ExitBB->getTerminator()->getNumSuccessors() <= 1);
    BasicBlock *TheSucc2Exit = ExitBB->getTerminator()->getSuccessor(0);
    BasicBlock *LatchBB = BasicBlock::Create(LC, "mxpa.latch", 
                                             Fun, TheSucc2Exit);

    ExitBB->getTerminator()->replaceUsesOfWith(TheSucc2Exit, LatchBB);

   // Builder.SetInsertPoint(LatchBB);
   // Builder.CreateBr(TheSucc2Exit);
    
    BasicBlock *LoopBody = EntryBB;
    LoopBody->setName(std::string("mxpa.lp.body"));

    //assert(LatchBB->getTerminator()->getNumSuccessors() == 1);
    
    //BasicBlock *OldExitBB = LatchBB->getTerminator()->getSuccessor(0);

    BasicBlock *LoopPreheader = 
      BasicBlock::Create(LC, "mxpa.lp.phdr", Fun, LoopBody);
    DT->addNewBlock(LoopPreheader, DT->getNode(EntryBB)->getBlock());

    BasicBlock *LoopHeader = 
      BasicBlock::Create(LC, "mxpa.lp.hdr", Fun, LoopBody);
    DT->addNewBlock(LoopHeader, LoopPreheader);

    Builder.SetInsertPoint(LoopHeader);
    Builder.CreateBr(LoopBody);
   
    BasicBlock *LoopEnd = 
      BasicBlock::Create(LC, "mxpa.lp.end", Fun, ExitBB);
    DT->addNewBlock(LoopEnd, LoopHeader);
   
    //
    std::set<BasicBlock*> LoopEntryPreds;
    DT = getAnalysisIfAvailable<DominatorTree>();
    for (pred_iterator PI = pred_begin(EntryBB), E = pred_end(EntryBB); 
         PI != E; ++PI) {
      BasicBlock *Pred = *PI;
      if (DT->dominates(EntryBB, Pred))
          continue;
      Pred->getTerminator()->replaceUsesOfWith(EntryBB, LoopPreheader);

      // Collects all preds that are not in the region
      LoopEntryPreds.insert(Pred);
    }

    // Loop over the PHI nodes in EntryBB, fix incoming BBs from the old
    // predecessors to the new predecessors
    for (BasicBlock::iterator i = EntryBB->begin(), E = EntryBB->end();
         i != E; ++i) {
      Instruction *I = &*i;
      if (isa<PHINode>(I)) {
        PHINode *PN = cast<PHINode>(I);

        for (unsigned i = 0, e = PN->getNumIncomingValues(); i != e; ++i) {
          BasicBlock *IBB = PN->getIncomingBlock(i);

          if (LoopEntryPreds.find(IBB) != LoopEntryPreds.end()) {
            PN->setIncomingBlock(i, LoopHeader);
          }
        }
      }
    }

    //
    Builder.SetInsertPoint(LoopPreheader);
    Builder.CreateBr(LoopHeader);
    
    //
    //LatchBB->getTerminator()->replaceUsesOfWith(OldExitBB, LoopHeader);
    
    //
    Builder.SetInsertPoint(LoopHeader, LoopHeader->getFirstNonPHI());
    std::stringstream ss;
    ss << "IV" << DimensionKind;
    PHINode *IV =
      Builder.CreatePHI(Type::getInt32Ty(getGlobalContext()), 2, ss.str());

    Constant *Zero = ConstantInt::get(Type::getInt32Ty(getGlobalContext()), 0);
    IV->addIncoming(Zero, LoopPreheader);

    
    Builder.SetInsertPoint(LatchBB, LatchBB->getFirstNonPHI());
    Value *CmpResult;
#if 1
    CallInst *GLSCall = Builder.CreateCall(
      cast<Function>(Mod->getOrInsertFunction(
                            "get_local_size", 
                            Type::getInt32Ty(getGlobalContext()),
                            Type::getInt32Ty(getGlobalContext()),
                            (Type *)0)), 
      ConstantInt::get(IntegerType::get(LC, 32), DimensionKind), 
      "get_local_size");
    
#endif

    //
    //Builder.SetInsertPoint(LatchBB->getTerminator());
    ss << "_inc";
    Value *IV_inc = Builder.CreateAdd(IV,
            ConstantInt::get(IntegerType::get(LC,32), 1), ss.str());
    IV->addIncoming(IV_inc, LatchBB);

    CmpResult = Builder.CreateICmpULT(IV_inc, GLSCall, "CmpResult");
    Builder.CreateCondBr(CmpResult, LoopHeader, LoopEnd);

    // Redirect "br to OldExitBB" to "br to LatchBB"
    LoopBody->getTerminator()->replaceUsesOfWith(TheSucc2Exit, LatchBB);
    
    //
    Builder.SetInsertPoint(LoopEnd);
    Builder.CreateBr(TheSucc2Exit);

    // Replace get_*_id calls with induction variables.
    std::vector<Instruction*> CallsToErase;
    std::vector<BasicBlock*> BBInvolved;

    // If RN contains more than one basic block.
    if (RN->getEntry() != RN->getExit()) {
      //FIXME: LLVM df_iterator cannot traverse a graph containing just one BB.
      for (MxPARegion::mxpa_bb_iterator i = RN->block_begin(), 
           e = RN->block_end(); i != e; ++i) {
        BasicBlock *BB = *i;
        BBInvolved.push_back(BB);
      }
    } else {
      // Need to replace calls in the exit block of the region too, which is
      // not part of the region.
      //FIXME:
      BBInvolved.push_back(RN->getExit());
    }

    for (std::vector<BasicBlock*>::iterator i = BBInvolved.begin(), 
         e = BBInvolved.end(); i != e; ++i) {
      BasicBlock *BB = *i;
      //DEBUG_WITH_TYPE("mxpa_ms5" , errs() << "Region block: " 
      //                << BB->getName() << "\n");
      for (BasicBlock::iterator BI = BB->begin(), BE = BB->end(); BI != BE; 
           ++BI) {
        assert(BI && "Iteration encounters an undefined instructions\n");
        Instruction *inst = BI;
        if (isa<CallInst>(inst)) {
          //DEBUG_WITH_TYPE("mxpa_ms5", errs() << "Found a function call" 
          //                                   << *inst << "\n");
          CallInst *a_call = cast<CallInst>(inst);
          StringRef called_func_nm = getCalledFunctionName(a_call);
          StringRef target_func_nm("get_local_id");
          if (called_func_nm == target_func_nm) {
            Value *get_local_id_arg = a_call->getArgOperand(0);
            ConstantInt *CI = dyn_cast<ConstantInt>(get_local_id_arg);
            ConstantInt *DK_CI = ConstantInt::get(IntegerType::get(LC,32), 
                                                  DimensionKind);

            if (CI == DK_CI) {
              if (a_call->hasOneUse() && isa<TruncInst>(a_call->use_back())) {
                TruncInst *TI = cast<TruncInst>(a_call->use_back());
                TI->replaceAllUsesWith(IV);
                CallsToErase.push_back(TI);
              } else {
                a_call->replaceAllUsesWith(IV);
              }
               
              #if 0 //FIXME: understand why this erase method does not work??
              a_call->eraseFromParent();
              #else
              CallsToErase.push_back(a_call);
              #endif
            }
          }
        }
      }
    }

    for (std::vector<Instruction*>::iterator i = CallsToErase.begin(), 
            e = CallsToErase.end(); i != e; ++i) {
        (*i)->eraseFromParent();
    }

    return std::make_pair(LoopPreheader, LoopEnd);
  }

  bool
  CondBarrier::containBarrierInRegion(MxPARegion *R)
  {
    bool hasABarrier = false;
    for (MxPARegion::mxpa_bb_iterator BI = R->block_begin(), 
         BE = R->block_end(); BI != BE; ++BI) {
      if (containsJustABarrier(*BI)) {
        hasABarrier = true;
        break;
      }
    }

    return hasABarrier;
  }

  bool
  CondBarrier::containBarrierInBB(BasicBlock *B)
  {
    bool hasABarrier = false;
    for (BasicBlock::iterator BI = B->begin(), BE = B->end(); BI != BE; ++BI) {
      if (isa<BarrierInst>(*BI)) {
        hasABarrier = true;
        break;
      }
    }

    return hasABarrier;
  }

  StringRef CondBarrier::getCalledFunctionName(CallInst *Call) {
    Function *fun = Call->getCalledFunction();
    if (fun) 
      return fun->getName(); 
    else
      return StringRef("indirect call");
  }

  CondBarrier::BarrierKind 
  CondBarrier::getBarrierKind(BarrierInst *BI)
  {
    assert(BI && "The argument BI is 0x0\n");
   
    CondBarrier::BarrierKind BK = Unknown;
    if (isa<BarrierInst>(BI)) {
      BasicBlock *EntryBB = &(BI->getParent()->getParent()->getEntryBlock());

      assert(PDT && "PDT is null\n");
      if (PDT->dominates(BI->getParent(), EntryBB)) {
        BK = Unconditional;
      } else {
        BK = Conditional;
      }
    }

    return BK;
  }

  void CondBarrier::deployRegionContext(MxPARegion *R)
  {
    assert(R && "deployRegionContext cannot work on empty region!");

    std::set<Instruction*> ATI;// All The Instructions
    std::vector<Instruction*> WorkList;
    std::vector<BasicBlock*> BBInvolved;
    std::vector<Instruction*> UniformWorkList;
    Function *F = R->getEntry()->getParent();

    if (R->getEntry() != R->getExit()) {
      for (MxPARegion::mxpa_bb_iterator i = R->block_begin(), e = R->block_end(); i != e; ++i) {
        BasicBlock *BB = *i;
        BBInvolved.push_back(BB);
      }
    } else {
      BBInvolved.push_back(R->getExit());
    }

    // Collect the set of instructions that are in the region.
    for (std::vector<BasicBlock*>::iterator BI = BBInvolved.begin(), BE = BBInvolved.end(); BI != BE; ++BI) {
      BasicBlock *BB = *BI;
      for (BasicBlock::iterator Instr = BB->begin(); Instr != BB->end(); ++Instr) {
        Instruction *I = &*Instr;
        ATI.insert(I);
      }
    }
    
    //
    for (std::vector<BasicBlock*>::iterator BI = BBInvolved.begin(), BE = BBInvolved.end(); BI != BE; ++BI) {
      BasicBlock *BB = *BI;

      for (BasicBlock::iterator Instr = BB->begin(); Instr != BB->end(); ++Instr) {
        Instruction *Inst = &*Instr;
        // --- New
#if 0
        if (TIA->isUniform(F, Inst)) { //continue;
          for (Instruction::use_iterator ui = Inst->use_begin(), ue = Inst->use_end(); ui != ue; ++ui) {
            Instruction *user = dyn_cast<Instruction>(*ui);
            
            if (user == NULL) 
              continue;

            if ((ATI.find(user) == ATI.end()) && (findRegionContains(user->getParent()) != NULL)) {
              UniformWorkList.push_back(Inst);
              break;
            }
          }
          continue;
        }
        // --- New
#elif 0
        if (TIA->isUniform(F, Inst)) 
          continue;
#elif 1
        if (isa<PHINode>(Inst)) { // all surviving PHIs at this point should be uniform.
          continue;
        }
#endif

        for (Instruction::use_iterator ui = Inst->use_begin(), ue = Inst->use_end(); ui != ue; ++ui) {
          Instruction *user = dyn_cast<Instruction>(*ui);

          if (user == NULL)
            continue;

          //FIXME:
          //if (isa<CallInst>(Inst))
          //  continue;

          if (isa<AllocaInst>(Inst)) {
            WorkList.push_back(Inst);
            break;
          }

          if ((ATI.find(user) == ATI.end()) && 
              (findRegionContains(user->getParent()) != NULL)) {
            WorkList.push_back(Inst);
            break;
          }
        }
      }
    }

#if 1
    for (std::vector<Instruction*>::iterator i = WorkList.begin(); i != WorkList.end(); ++i) {
      Instruction *I = *i;
      DEBUG_WITH_TYPE("mxpa_ms5", errs() << "Region: " << R << 
        " DEPLOYING for the instruction: " << *I << WorkList.size() << "\n");
    }
#endif

    // Move each instruction in the UniformWorkList to the function entry block
    Instruction *FirstInsertionPt = F->getEntryBlock().getFirstInsertionPt();
    for (std::vector<Instruction*>::iterator i = UniformWorkList.begin(); i != UniformWorkList.end(); ++i) {
      Instruction *I = *i;
      I->moveBefore(FirstInsertionPt);
    }

    // Perform context switching on each instruction in the WorkList
    for (std::vector<Instruction*>::iterator i = WorkList.begin(); i != WorkList.end(); ++i) {
      Instruction *I = *i;
      performContextBuffering(I);
    }
  }

  MxPARegion* CondBarrier::findRegionContains(BasicBlock *BB)
  {
    for (std::vector<MxPARegion*>::iterator I = PR.begin(); I != PR.end(); ++I) {
      MxPARegion *RN = *I;
      //FIXME: why exit node is not part of the region?
      if (RN->contains(BB) || BB == RN->getExit()) 
        return RN;
    }
    return NULL;
  }

  Instruction* CondBarrier::getContextReplacementOf(Instruction *Inst)
  {
    //FIXME: List the types of instructions that may need to get 
    //       context replacement

    Function *F = Inst->getParent()->getParent();
    //Module *Mod = F->getParent();

    //FIXME: Choose a unique name like the following
    // http://llvm.org/docs/doxygen/html/StringMap_8h_source.html#l00147
    std::ostringstream var;
    var << ".";

    if (std::string(Inst->getName().str()) != "") {
      var << Inst->getName().str();
    } else if (tempInstructionIds.find(Inst) != tempInstructionIds.end()) {
      var << tempInstructionIds[Inst];
    } else {
      tempInstructionIds[Inst] = tempInstructionIndex++;
      var << tempInstructionIds[Inst];
    }

    var << "." << F->getName().str() << ".mxpa_context_buffer";
    std::string VarName = var.str();

    if (NamedContexts.find(VarName) != NamedContexts.end())
      return NamedContexts[VarName];

    //IRBuilder<> builder(F->getEntryBlock().getFirstInsertionPt());
    IRBuilder<> builder(F->getEntryBlock().getTerminator());

    Type *elementType;
    if (isa<AllocaInst>(Inst)) {
      elementType = dyn_cast<AllocaInst>(Inst)->getType()->getElementType();
    } else {
      elementType = Inst->getType();
    }

#if 0
    Type *contextArrayType = 
      ArrayType::get(
        ArrayType::get(ArrayType::get(elementType, __get_local_size[0]), 
                       __get_local_size[1]), __get_local_size[2]);

    AllocaInst *AI = builder.CreateAlloca(contextArrayType, 0, VarName);
#else
    AllocaInst *AI = builder.CreateAlloca(
                       elementType, Flat3DSize, Inst->getName()+".gaispill"
                     );
#endif

    AI->setAlignment(CONTEXT_ARRAY_ALIGN);

    NamedContexts[VarName] = AI;
    return AI;
  }

  void
  CondBarrier::performContextBuffering(Instruction *Inst) 
  {
    Instruction *Alloca = getContextReplacementOf(Inst);
    Instruction *Store = doContextStore(Inst, Alloca);

    DEBUG_WITH_TYPE("mxpa_ms5", 
      errs() << " Context Replacment Alloca for " << *Inst << " is " 
             << *Alloca <<  "\n");

    DEBUG_WITH_TYPE("mxpa_ms5", 
      errs() << " Context Replacment Store for " << *Inst << " is " 
             << *Store <<  "\n");

    // Collect the uses of Inst
    std::vector<Instruction*> Uses;
    for (Instruction::use_iterator ui = Inst->use_begin(), 
         ue = Inst->use_end(); ui != ue; ++ui) {
       Instruction *user;
       if ((user = dyn_cast<Instruction> (*ui)) == NULL) continue;
       if (user == Store) continue;
       Uses.push_back(user);
    }

    for (std::vector<Instruction*>::iterator i = Uses.begin();
         i != Uses.end(); ++i) {

      Instruction *User = *i;
      Instruction *ReloadLocation = User;

      if (findRegionContains(User->getParent()) == NULL) continue;

      PHINode* Phi = dyn_cast<PHINode>(User);
      if (Phi != NULL) {
        /* PHINodes at region entries are broken down earlier. */
        assert ("Cannot add context reload for a PHI at the region entry!" &&
          findRegionContains(Phi->getParent())->getEnteringBlock() != 
          Phi->getParent()
        );

        BasicBlock *IncomingBB = NULL;
        for (unsigned incoming = 0; incoming < Phi->getNumIncomingValues(); 
             ++incoming) {
          Value *Val = Phi->getIncomingValue(incoming);
          BasicBlock *bb = Phi->getIncomingBlock(incoming);
          if (Val == Inst) IncomingBB = bb;
        }
        assert (IncomingBB != NULL);
        ReloadLocation = IncomingBB->getTerminator();
      }

      bool isAlloca = isa<AllocaInst>(Inst);
      Value *loadedValue = doContextReload(User, Alloca, ReloadLocation, 
                                           isAlloca);
      User->replaceUsesOfWith(Inst, loadedValue);
    }
  }

  Instruction* 
  CondBarrier::doContextStore(Instruction *Inst,
                                Instruction *Alloca) 
  {
    MxPARegion *region = findRegionContains(Inst->getParent());
    assert (region != NULL && 
            "Context Store cannot be performed on an empty region");

    if (isa<AllocaInst>(Inst)) {
        return NULL;
    }

    /* Save the produced variable to the array. */
    BasicBlock::iterator definition = dyn_cast<Instruction>(Inst);

    ++definition;
    while (isa<PHINode>(definition)) ++definition;

    IRBuilder<> BuilderCS(definition); 
#if 0    
    std::vector<Value *> GepOffsets;

    GepOffsets.push_back(
      ConstantInt::get(IntegerType::get(Inst->getContext(), 32), 0)
    );
    
    GepOffsets.push_back(loadXid(region));
    GepOffsets.push_back(loadYid(region));
    GepOffsets.push_back(loadZid(region));
#else
    std::vector<Value *> GepOffsets;
    GepOffsets.push_back(R2IMap[region]);
#endif

    Value *AllocaGep = BuilderCS.CreateGEP(Alloca, GepOffsets);

    return BuilderCS.CreateStore(Inst, AllocaGep);
  }

  Instruction* 
  CondBarrier::doContextReload(Value *Val, 
                                 Instruction *Alloca,
                                 Instruction *Before,
                                 bool isAlloca) 
  {
    MxPARegion *region = findRegionContains(Before->getParent());

    assert (region != NULL && 
            "Context reload cannot be performed on an empty region");

    assert ((Val != NULL) && (Alloca != NULL));

    IRBuilder<> BuilderCL(Alloca);
    if (Before != NULL) {
        BuilderCL.SetInsertPoint(Before);
    } else if (isa<Instruction>(Val)) {
        BuilderCL.SetInsertPoint(dyn_cast<Instruction>(Val));
        Before = dyn_cast<Instruction>(Val);
    } else {
        assert (false && "Unknown context restore location!");
    }

#if 0    
    std::vector<Value *> GepOffsets;
    GepOffsets.push_back(
      ConstantInt::get(IntegerType::get(Val->getContext(), 32), 0)
    );

    GepOffsets.push_back(loadXid(region));
    GepOffsets.push_back(loadYid(region));
    GepOffsets.push_back(loadZid(region));
#else
    std::vector<Value *> GepOffsets;
    GepOffsets.push_back(R2IMap[region]);
#endif

    Instruction *gep = 
      dyn_cast<Instruction>(BuilderCL.CreateGEP(Alloca, GepOffsets));

    if (isAlloca) {
      return gep;
    }          

    return BuilderCL.CreateLoad(gep);
  }

  CallInst* 
  CondBarrier::insertCallToGetLocalID(std::string FuncName, 
                                  int dimindx, Module *M, 
                                  LLVMContext &Context, 
                                  Instruction *InsertBefore,
                                  MxPARegion *R)
  {
    CallInst *CallGetX = NULL; 

    //if (R != NULL) {
    if (NULL) {
      BasicBlock *BB = R->getEntry();
      for (BasicBlock::iterator BI = BB->begin(), BE = BB->end(); BI != BE; 
           ++BI) {
        assert(BI && "Iteration encounters an undefined instructions\n");
        Instruction *inst = BI;
        if (isa<CallInst>(inst)) {
          CallInst *a_call = cast<CallInst>(inst);
          StringRef called_func_nm = getCalledFunctionName(a_call);
          StringRef target_func_nm("get_local_id");
          if (called_func_nm == target_func_nm) {
            Value *get_local_id_arg = a_call->getArgOperand(0);
            ConstantInt *CI = dyn_cast<ConstantInt>(get_local_id_arg);
            ConstantInt *DK_CI = ConstantInt::get(IntegerType::get(Context,32), 
                                                  dimindx);

            if (CI == DK_CI) {
              CallGetX = a_call;
              break;
            } 
          }
        }
      }

      if (CallGetX == NULL) {
        Function *GetXF =
          cast<Function>(M->getOrInsertFunction(FuncName, 
                                                Type::getInt32Ty(Context),
                                                Type::getInt32Ty(Context),
                                                (Type *)0));

          Value *DimIndx = ConstantInt::get(Type::getInt32Ty(Context), dimindx);

          CallGetX = CallInst::Create(GetXF, DimIndx, FuncName, 
                                      InsertBefore);
      }
    } else {
      Function *GetXF =
        cast<Function>(M->getOrInsertFunction(FuncName, 
                                              Type::getInt32Ty(Context),
                                              Type::getInt32Ty(Context),
                                              (Type *)0));

        Value *DimIndx = ConstantInt::get(Type::getInt32Ty(Context), dimindx);

        CallGetX = CallInst::Create(GetXF, DimIndx, FuncName, 
                                    InsertBefore);
    }
    
    return CallGetX;
  }


  CallInst* 
  CondBarrier::insertCallToGetLocalSize(std::string FuncName, 
                                  int dimindx, Module *M, 
                                  LLVMContext &Context, 
                                  Instruction *InsertBefore)
  {
    CallInst *CallGetX = NULL; 
    
    Function *GetXF =
      cast<Function>(M->getOrInsertFunction(FuncName, 
                                            Type::getInt32Ty(Context),
                                            Type::getInt32Ty(Context),
                                            (Type *)0));

    Value *DimIndx = ConstantInt::get(Type::getInt32Ty(Context), dimindx);

    CallGetX = CallInst::Create(GetXF, DimIndx, FuncName, 
                                InsertBefore);
    
    return CallGetX;
  }

  void CondBarrier::EnsureARealEntryOnTopABarrierEntry(Function &F) 
  {
    BasicBlock *BarrierEntry = &F.getEntryBlock();

    assert(pred_begin(BarrierEntry) == pred_end(BarrierEntry) &&
           "Entry block to function must not have predecessors!");

    assert(containsJustABarrier(BarrierEntry) && 
           "F's entry BB is not a barrier BB (forgot hive off barriers?)!");

    assert((BarrierEntry->getTerminator()->getNumSuccessors() == 1) && 
             "local_size insertion detects invalid function entry!");
    
    BasicBlock *RealKernelEntry =  
      SplitBlock(BarrierEntry, &BarrierEntry->front(), this);
  }

  void CondBarrier::InsertLocalSizeInfoToEntry(Function &F)
  {
    BasicBlock *RealKernelEntry =&F.getEntryBlock(); 

    // FIXME: Insert local_size info to the entry block.
    Instruction *InstNewEntry = &RealKernelEntry->back();
    for (int i = 0; i < 3; ++i) {
      Lsz[i] = insertCallToGetLocalSize("get_local_size", i, F.getParent(), 
                                F.getContext(), InstNewEntry);
    }

    Builder.SetInsertPoint(InstNewEntry);
    Flat3DSize = Builder.CreateMul(
                   Builder.CreateMul(Lsz[2], Lsz[1]), Lsz[0], "Flat3DSize");
  }

  void CondBarrier::moveAllocasToEntry(Function &F)
  {
    Function::iterator I = F.begin();
    Instruction *firstInsertionPt = (I++)->getFirstInsertionPt();
      
    for (Function::iterator E = F.end(); I != E; ++I) {
      for (BasicBlock::iterator BI = I->begin(), BE = I->end(); BI != BE;) {
        AllocaInst *allocaInst = dyn_cast<AllocaInst>(BI++);
        if (allocaInst && isa<ConstantInt>(allocaInst->getArraySize())) {
          allocaInst->moveBefore(firstInsertionPt);
        }
      }
    }
  }

  void CondBarrier::moveUniformCallsToEntry(Function &F)
  {
    Function::iterator I = F.begin();
    Instruction *firstInsertionPt = (I++)->getFirstInsertionPt();
      
    for (Function::iterator E = F.end(); I != E; ++I) {
      for (BasicBlock::iterator BI = I->begin(), BE = I->end(); BI != BE;) {
        CallInst *CI = dyn_cast<CallInst>(BI++);

        if (CI) {
          if (TIA->isUniform(&F, CI)) {
            CI->moveBefore(firstInsertionPt);
          }
        }
      }
    }
  }

  void CondBarrier::moveUniformBIFCallsToEntry(Function &F)
  {
    Instruction *firstInsertionPt = F.begin()->getFirstInsertionPt();
    
    StringRef workdim_func_nm("get_work_dim");
    StringRef globalsize_func_nm("get_global_size");
    StringRef globalid_func_nm("get_global_id");
    StringRef localsize_func_nm("get_local_size");
    StringRef localid_func_nm("get_local_id");
    StringRef numgroups_func_nm("get_num_groups");
    StringRef groupid_func_nm("get_group_id");
    StringRef globaloffset_func_nm("get_global_offset"); 

    std::vector<Instruction*> CIsToMove;
    for (Function::iterator I = F.begin(), E = F.end(); I != E; ++I) {
      for (BasicBlock::iterator BI = I->begin(), BE = I->end(); BI != BE; ++BI) {
        if (isa<CallInst>(BI)) {
          CallInst *CI = dyn_cast<CallInst>(BI);
          StringRef called_func_nm = getCalledFunctionName(CI);
          
          if ((called_func_nm == localsize_func_nm) || 
              (called_func_nm == globalsize_func_nm) ||
              (called_func_nm == workdim_func_nm) || 
              (called_func_nm == numgroups_func_nm) ||
              (called_func_nm == groupid_func_nm) ||
              (called_func_nm == globaloffset_func_nm)) {

            //CI->moveBefore(firstInsertionPt);
            CIsToMove.push_back(CI);
          }
        }
      }
    }

    for (std::vector<Instruction*>::iterator I = CIsToMove.begin(), E = CIsToMove.end(); I != E; ++I) {
      (*I)->moveBefore(firstInsertionPt);
    }

  }

  /////////////////////////////////////////////////////////////////////////////
  void CondBarrier::CollectBarriers(Function &F) {
    BarrierSet.clear();
    // Collect the set of "barrier call" instructions that are known live
    for (inst_iterator I = inst_begin(F), E = inst_end(F); I != E; ++I) {
      BasicBlock::iterator BI = I.getInstructionIterator();
      if (isa<BarrierInst>(&*BI)) {
        BarrierSet.insert(&*BI);
      }
    }
  }
  
  bool CondBarrier::ProcessBarrier(Function &F) {
    bool Changed = false;

    CollectBarriers(F);

    //
    for (SmallPtrSet<Instruction*, 128>::iterator It = BarrierSet.begin(),
         E = BarrierSet.end(); It != E; ++It) {

      BarrierInst *I = cast<BarrierInst>(*It);
      BasicBlock *B = I->getParent();
      Function *F = B->getParent();

      if (I->getNextNode() != B->getTerminator()) {
        SplitBlockAfterBarrier(B, I);
        Changed = true;
      }

      //FIXME: Should we handle the following case separtely:
      //         If Barrier is at the beginning of the BB,
      //         which has a single predecessor with just
      //         one successor (the barrier itself), thus
      //         no need to split before barrier.
      //CLVIII:CLXIX
    
      if ((B == &(F->front())) && ((B->getFirstNonPHI()) == I)) {
        continue;
      }

      SplitBlockBeforeBarrier(B, I);
      Changed = true;
    }

#if 0
    bool emptyBBMerged = false;
    do {
      emptyBBMerged = false;

      for (Function::iterator i = F.begin(), e = F.end(); i != e; ++i) {
        BasicBlock *b = i;

        TerminatorInst *bt = b->getTerminator();
        BranchInst *br = dyn_cast<BranchInst>(bt);
      
        if ((b->size() == 1) && 
            (bt->getNumSuccessors() == 1) && 
            (b->getSinglePredecessor()) && 
            !(br->isConditional())) {
          emptyBBMerged = MergeBlockIntoPredecessor(b, this);
          if (emptyBBMerged) {
            Changed = true;
            break;
          }
        }

      }

    } while (emptyBBMerged);

    bool BarrierBBMergedUp = false;
    do {
      BarrierBBMergedUp = false;

      for (Function::iterator i = F.begin(), e = F.end(); i != e; ++i) {
        BasicBlock *b = i;

        if (containsJustABarrier(b)) {
          if (b->getSinglePredecessor()) {
            BasicBlock *Pred = b->getSinglePredecessor();

            if ((Pred->getSinglePredecessor()) && 
                (Pred->size() == 1) && 
                !(dyn_cast<BranchInst>(Pred->getTerminator())->isConditional())) {
              BarrierBBMergedUp = MergeBlockIntoPredecessor(b, this);
              if (BarrierBBMergedUp) {
                Changed = true;
                break;
              }
            }
          }
        }
      }

    } while (BarrierBBMergedUp);
#endif

    bool emptyRegionDeleted = false;
    do {
      emptyRegionDeleted = false;

      for (Function::iterator i = F.begin(), e = F.end();
           i != e; ++i) {
          BasicBlock *b = i;
          TerminatorInst *t = b->getTerminator();
          if (!BarrierInst::endsWithBarrier(b) || t->getNumSuccessors() != 1)
            continue;

          BasicBlock *successor = t->getSuccessor(0);

          if (BarrierInst::hasOnlyBarrier(successor) &&
              successor->getSinglePredecessor() == b &&
              successor->getTerminator()->getNumSuccessors() == 1) {
              b->getTerminator()->setSuccessor(
                0, successor->getTerminator()->getSuccessor(0));
              successor->replaceAllUsesWith(b);
              successor->eraseFromParent();
              emptyRegionDeleted = true;
              Changed = true;
              break;
          }
      }
    } while (emptyRegionDeleted);


    return Changed;
  }

  BasicBlock* 
  CondBarrier::SplitBlockBeforeBarrier(BasicBlock *Old, 
                                       BarrierInst *SplitPt) {
    BasicBlock *New = SplitBlock(Old, SplitPt, this);
    New->takeName(Old);
    Old->setName(New->getName() + ".mxpa.b4.barrier");
    return New;
  }
 
  BasicBlock* 
  CondBarrier::SplitBlockAfterBarrier(BasicBlock *Old, 
                                      BarrierInst *SplitPt) {
    Instruction *NextInstAfterBarrier = SplitPt->getNextNode();
    BasicBlock *New = SplitBlock(Old, NextInstAfterBarrier, this);
    New->setName(Old->getName() + ".mxpa.after.barrier");
    return Old;
  }
  
  void CondBarrier::verifyHOBAnalysis() const {
    if (DT) DT->verifyAnalysis();
    if (LI) LI->verifyAnalysis();
 
    for (SmallPtrSet<Instruction*, 128>::iterator It = BarrierSet.begin(),
         E = BarrierSet.end(); It != E; ++It) {
      Instruction *BI = *It;
      BasicBlock *BB = BI->getParent();
      assert(
        containsJustABarrier(BB) && "Not all barriers are hived off properly!"
      );
    }
  } 

  bool CondBarrier::runHiveOffBarrierPass(Function &F) {
    bool Changed = false;

    LLVMContext &LC = F.getContext();

    IntegerType * IntTy = IntegerType::get(LC, 32);
    Value *Args = ConstantInt::get(IntTy, 0);

#if 0 // Disable the insertion of yet another function entry barrier
    
    // Step 1. Process function entry barrier.
    //FIXME: More assertion type of work needed here:
    //       1. Check whether F is a proper OCL kernel or not.
    //       2. Ensure function entry and exit BBs are barrier blocks (?!).
    //LIX:XCIII
    BasicBlock *entry = &F.getEntryBlock();
    if (!containsJustABarrier(entry)) {
      BasicBlock *effective_entry = SplitBlock(entry, 
                                               &(entry->front()),
                                               this);

      effective_entry->takeName(entry);
      entry->setName("entry.barrier");

      BarrierInst::createBarrier(Args, entry->getTerminator());
    }
#endif

    // Step 2. Process function exit barrier.
    for (Function::iterator i = F.begin(), e = F.end(); i != e; ++i) {
      BasicBlock *b = i;
      TerminatorInst *t = b->getTerminator();
      if ((t->getNumSuccessors() == 0) && (!containsJustABarrier(b))) {
        BasicBlock *exit; 
        if (BarrierInst::endsWithBarrier(b)) {
          exit = SplitBlock(b, t->getPrevNode(), this);
        } else {
          exit = SplitBlock(b, t, this);
          //FIXME: potential QPDM's bug
          BarrierInst::createBarrier(Args, exit->getTerminator());
        }
        exit->setName("exit.barrier");
      }
    }
 
    DT = getAnalysisIfAvailable<DominatorTree>();
    LI = getAnalysisIfAvailable<LoopInfo>();

    // Step 3. Process all the other barriers in the middle.
    Changed |= ProcessBarrier(F);

    // Step 4. Re-collect barriers as some of them might be eliminated
    CollectBarriers(F);
    verifyHOBAnalysis();

    return Changed;
  }

  /////////////////////////////////////////////////////////////////////////////

  //===--------------------------------------------------------------------===//
  char IPLooper::ID = 0;

  namespace {
    static
    RegisterPass<IPLooper>
      IPLooperModulePass("mxpa_IPLoopInserter",
        "maximum coarsening with unconditional barriers");
  }

  void IPLooper::getAnalysisUsage(AnalysisUsage &AU) const {
    AU.addRequired<CondBarrier>();
  }

  bool IPLooper::runOnModule(Module &M) {
    bool Changed = false;

#if 0
    forwardDeclWIFs(M);
#endif

#if 1
    CL_KernelInfo CLKI(M);
    std::vector<std::string> KernelNames= CLKI.get_kernel_names();
#else
    std::vector<std::string> KernelNames;
    
    LLVMContext &Context = getGlobalContext();
    SMDiagnostic Err;
    Module *KernelInfoLink = ParseIRFile("kernel_info_link.bc", Err, Context);

    GlobalVariable *GVnames  = KernelInfoLink->getNamedGlobal("_cl_kernel_names");
  
    if (Constant *Init = GVnames->getInitializer()) { 
      unsigned n = Init->getNumOperands();
      for (unsigned i = 0; i != n; ++i) {
        Constant *AO = cast<Constant>(Init->getOperand(i));
  
        if (GlobalVariable *gvn = dyn_cast<GlobalVariable>(AO->getOperand(0))) {
          Constant *cn = gvn->getInitializer();
          if (ConstantDataArray *ca = dyn_cast<ConstantDataArray>(cn)) {
            if (ca->isCString()) {
              KernelNames.push_back(ca->getAsCString().str());
            }
          }
        }
      }
    }
#endif

    for (std::vector<std::string>::iterator K = KernelNames.begin(),
         E = KernelNames.end(); K != E; ++K) {
      DEBUG_WITH_TYPE("mxpa_ms5", errs() << "Kevin said ---->" << *K << "\n");
    }

    for (Module::iterator F = M.begin(), E = M.end(); F != E; ++F) {
      if (F->isDeclaration())
        continue;

      std::string fnm = F->getName().str();
      bool IsKernel = (std::find(KernelNames.begin(), KernelNames.end(), fnm) 
                       != KernelNames.end());

      if (!IsKernel) {
        // Make sure that no barrier calls exist.
        std::vector<Instruction*> BarrierCalls;
        for (Function::iterator ibb = F->begin(), ibe = F->end();
             ibb != ibe; ++ibb)  {
          for (BasicBlock::iterator iib = ibb->begin(), iie = ibb->end();
               iib != iie; ++iib) {
            Instruction *inst = iib;

            if (isa<CallInst>(inst)) {
              CallInst *BCall = cast<CallInst>(inst);
              StringRef called_func_nm = getCalledFunctionName(BCall);
              StringRef barrier_func_nm("barrier");

              if (called_func_nm == barrier_func_nm) {
                BarrierCalls.push_back(BCall);
              }
            }
          }
        }
        for (std::vector<Instruction*>::iterator i = BarrierCalls.begin(), 
                e = BarrierCalls.end(); i != e; ++i) {
            (*i)->eraseFromParent();
        }

        continue;
      }

      DEBUG_WITH_TYPE("mxpa_ms5", errs() << "Found a function: " 
                                         << F->getName() << "\n");
      getAnalysis<CondBarrier>(*F);

      Changed = true;
    }

    // Output loop-inserted .ll file
    std::string module_out_path = "__cl_kernel.bc";
    std::string ErrorInfo;
#ifdef LLVM_33
    raw_fd_ostream Fout(module_out_path.c_str(), ErrorInfo, 4);
#elif LLVM_34
    raw_fd_ostream Fout(module_out_path.c_str(), ErrorInfo, sys::fs::F_Binary);
#endif
    errs() << "Emitted IR output to __cl_kernel.bc\n";
    WriteBitcodeToFile(&M, Fout);

    return Changed;
  }

  void IPLooper::forwardDeclWIFs(Module &M)
  {
    Twine WifNames[] = {"get_work_dim", "get_global_size", "get_global_id", 
                        "get_local_size", "get_local_id", "get_num_groups", 
                        "get_group_id", "get_global_offset"};

    int NumOfWifs = sizeof(WifNames)/sizeof(WifNames[0]);

    //FIXME: get_work_dim(.) not handled correctly.
    LLVMContext &LC = M.getContext();
    std::vector<Type*> Int32Arg(1, Type::getInt32Ty(LC));
    FunctionType *FT = FunctionType::get(Type::getInt32Ty(LC),
                                         Int32Arg, false);

    for (int i = 1; i < NumOfWifs; ++i) {
        Function::Create(FT, Function::ExternalLinkage, WifNames[i], &M);
    }
  }

}
}

