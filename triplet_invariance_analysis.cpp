#define DEBUG_TYPE "mxpa_tripletinvarianceanalysis"

// LLVM includes
#include "llvm/Support/InstIterator.h"
#include "llvm/Analysis/ScalarEvolutionExpressions.h"
#include "llvm/Support/Debug.h"

// MxPA includes
#include "triplet_invariance_analysis.h"
#include "barrier_utils.h"
#include "barrier_inst.h"
#include "kernel_info_reader.h"

// Standard includes
#include <queue>

namespace SpmdKernel {

using namespace llvm;

namespace Coarsening {

  char TripletInvarianceAnalysis::ID = 0;
  
  namespace {
    static
    RegisterPass<TripletInvarianceAnalysis> 
      X("mxpa_triplet_invariance_analysis", 
        "work-item invariance analysis using triplets");
  }

  bool TripletInvarianceAnalysis::isBarrierLoop(Loop *L) {
    bool isBLoop = false;
    for (Loop::block_iterator i = L->block_begin(), e = L->block_end();
         i != e && !isBLoop; ++i) {
      for (BasicBlock::iterator j = (*i)->begin(), e = (*i)->end();
           j != e; ++j) {
        if (isa<BarrierInst>(j)) {
            isBLoop = true;
            break;
        }
      }
    }

    return isBLoop;
  }

  bool TripletInvarianceAnalysis::runOnFunction(Function &F) {
    bool Changed = false;

    TC[&F].clear();

    Module &M = *F.getParent();

    for (Function::iterator BI = F.begin(), BE = F.end(); BI != BE; ++BI) {
      BasicBlock &BB = *BI;
      for (BasicBlock::iterator II = BB.begin(), IE = BB.end(); II != IE; ++II) {
        Instruction *I = &*II;
        CycleColorMap[I] = WHITE;
      }
    }

    // Mark globals as uniform
    for (Module::global_iterator I = M.global_begin(), E = M.global_end();
         I != E; ++I) {
      TripletType T = {kUnknown, kUnknown, kUnknown};
      setTripletType(&F, I, &T, kInvariant, kInvariant, kInvariant);
    }

#if 0
    SE = &getAnalysis<ScalarEvolution>();

    for (LoopInfo::iterator i = LI.begin(), e = LI.end(); 
         i != e; ++i) {
      Loop *L = *i;
      bool IsBarrierLoop = isBarrierLoop(L);

      if (IsBarrierLoop) {
        for (Loop::block_iterator i = L->block_begin(), e = L->block_end();
            i != e; ++i) {
          for (BasicBlock::iterator j = (*i)->begin(), e = (*i)->end();
               j != e; ++j) {
            if (isa<PHINode>(j)) {
              const SCEV *S = SE->getSCEV(j);
              const SCEVAddRecExpr *SARE = dyn_cast<SCEVAddRecExpr>(S);

              if (SARE) {
                DEBUG_WITH_TYPE("mxpa_tripletinvarianceanalysis", 
                  errs() << "Looping ... " << *L << "... bloop = " 
                         << IsBarrierLoop << "..." << *j << "\n"
                );

                const Loop *CurLoop = SARE->getLoop();
                
                if (CurLoop == L) {
                  TripletType T = {kUnknown, kUnknown, kUnknown};
                  setTripletType(&F, j, &T, kInvariant, kInvariant, kInvariant);

                }
              }
            }
          }
        }
      }
    }
#endif 

#if 1
    initialize(F);

    LoopInfo &LI = getAnalysis<LoopInfo>();

    // -- Mark all values defined in the barrier loop header uniform -- //
    for (LoopInfo::iterator i = LI.begin(), e = LI.end();
         i != e; ++i) {
      Loop *TL = *i;

      BasicBlock *header = TL->getHeader(); 
      if (header) {
        if (isBarrierLoop(TL)) {
          for (BasicBlock::iterator BI = header->begin(), BE = header->end();
               BI != BE; ++BI) {
            TripletType T = {kInvariant, kInvariant, kInvariant};
            setTripletType(&F, BI, &T, kInvariant, kInvariant, kInvariant);
          }
        } else {
          for (BasicBlock::iterator BI = header->begin(), BE = header->end();
               BI != BE; ++BI) {
            TripletType T = {kNonInvariant, kNonInvariant, kNonInvariant};
            setTripletType(&F, BI, &T, kNonInvariant, kNonInvariant, kNonInvariant);
          }
        }
      }

      BasicBlock *latch = TL->getLoopLatch(); 
      if (latch) {
        if (isBarrierLoop(TL)) {
          for (BasicBlock::iterator BI = latch->begin(), BE = latch->end();
               BI != BE; ++BI) {
            TripletType T = {kInvariant, kInvariant, kInvariant};
            setTripletType(&F, BI, &T, kInvariant, kInvariant, kInvariant);
          }
        } else {
          for (BasicBlock::iterator BI = latch->begin(), BE = latch->end();
               BI != BE; ++BI) {
            TripletType T = {kNonInvariant, kNonInvariant, kNonInvariant};
            setTripletType(&F, BI, &T, kNonInvariant, kNonInvariant, kNonInvariant);
          }
        }
      }
      
      for (Loop::iterator li = TL->begin(), le = TL->end();
           li != le; ++li) {
        Loop *L = *li;

        BasicBlock *header = L->getHeader(); 
        if (header) {
          if (isBarrierLoop(L)) {
            for (BasicBlock::iterator BI = header->begin(), BE = header->end();
                 BI != BE; ++BI) {
              TripletType T = {kInvariant, kInvariant, kInvariant};
              setTripletType(&F, BI, &T, kInvariant, kInvariant, kInvariant);
            }
          } else {
            for (BasicBlock::iterator BI = header->begin(), BE = header->end();
                 BI != BE; ++BI) {
              TripletType T = {kNonInvariant, kNonInvariant, kNonInvariant};
              setTripletType(&F, BI, &T, kNonInvariant, kNonInvariant, kNonInvariant);
            }
          }
        }

        BasicBlock *latch = L->getLoopLatch(); 
        if (latch) {
          if (isBarrierLoop(L)) {
            for (BasicBlock::iterator BI = latch->begin(), BE = latch->end();
                 BI != BE; ++BI) {
              TripletType T = {kInvariant, kInvariant, kInvariant};
              setTripletType(&F, BI, &T, kInvariant, kInvariant, kInvariant);
            }
          } else {
            for (BasicBlock::iterator BI = latch->begin(), BE = latch->end();
                 BI != BE; ++BI) {
              TripletType T = {kNonInvariant, kNonInvariant, kNonInvariant};
              setTripletType(&F, BI, &T, kNonInvariant, kNonInvariant, kNonInvariant);
            }
          }
        }
      }
    }
#endif

    TripletType T = {kInvariant, kInvariant, kInvariant};
    setTripletType(&F, &F.getEntryBlock(), &T, kInvariant, kInvariant, kInvariant);

#if 1
    for (inst_iterator I = inst_begin(F), E = inst_end(F); I != E; ++I) {
      BasicBlock::iterator BI = I.getInstructionIterator();
     
      TripletType tmp = getOrCalculateTriplet(&F, &*BI);
      DEBUG_WITH_TYPE("mxpa_tripletinvarianceanalysis", printTripletType(errs(), &tmp, BI));
    }
#else
    // The Worklist approach
    WorklistApproach(F);
#endif

    return Changed;
  }

  TripletInvarianceAnalysis::~TripletInvarianceAnalysis() {
    /* empty */;
  }

  TripletInvarianceAnalysis::TripletType
  TripletInvarianceAnalysis::getOrCalculateTriplet(Function *F, Value *V) {

    //TripletType T = {kUnknown, kUnknown, kUnknown};
    TripletType T = {kInvariant, kInvariant, kInvariant};
    TripletIndex &TI = TC[F];

    TripletIndex::const_iterator i = TI.find(V);
    if (i != TI.end()) {
      return (*i).second;
    }

    if (BasicBlock *bb = dyn_cast<BasicBlock>(V)) {
      if (bb == &F->getEntryBlock()) {
        setTripletType(F, V, &T, kInvariant, kInvariant, kInvariant);
        return T;
      }
    }

    //FIXME: Need to handle BasicBlock too
    if (isa<Argument>(V) || isa<Constant>(V)) {
      setTripletType(F, V, &T, kInvariant, kInvariant, kInvariant);
      return T;
    }

    if (isa<AllocaInst>(V)) {
      Instruction *IV = dyn_cast<AllocaInst>(V);

      CycleColorMap[IV] = GREY;

#if 0
      TripletType TT;
      setTripletType(F, V, &TT, kNonInvariant, kNonInvariant, kNonInvariant);
      return TT;
#else
      if (IV->hasNUses(0) == true) {
        TripletType TT;
        setTripletType(F, V, &TT, kInvariant, kInvariant, kInvariant);
        return TT;
      } else {
        std::vector<TripletType> VT;
        for (Instruction::use_iterator ui = IV->use_begin(), ue = IV->use_end(); ui != ue; ++ui) {
          Value *UserValue = *ui;
          Instruction *User;

          if ((User = dyn_cast<Instruction> (*ui)) == NULL) 
            continue;

          CycleColor SuccColor = CycleColorMap[User];

          if ((SuccColor == GREY) && (TI.find(UserValue) == TI.end())) {
            TripletType TT;
            setTripletType(F, User, &TT, kInvariant, kInvariant, kInvariant);
            VT.push_back(TT);
          } else {
            StoreInst *Store = dyn_cast<StoreInst>(User);
            LoadInst *Load = dyn_cast<LoadInst>(User);
            if (Store) {
              //errs() <<"  " << *V << " +++++> " << *Store << " ---===> " 
              //       << *Store->getValueOperand() << "\n";
              TripletType TT = getOrCalculateTriplet(F, Store->getValueOperand());
              VT.push_back(TT);
            } else if (Load) {
              //TODO: Load from me ... do nothing?
              // TripletType TT;
              // setTripletType(F, V, &TT, kUnknown, kUnknown, kUnknown);
              // VT.push_back(T);
            } else {
              // FIXME: Alloca's use can only be either LOAD or STORE or GEPs, right?
              TripletType TT;
              setTripletType(F, V, &TT, kNonInvariant, kNonInvariant, kNonInvariant);
              VT.push_back(TT);
            }
          }
        }

        TripletType TT = VT[0];
        //for (unsigned u = 1; u < IV->getNumUses(); ++u) {
        for (unsigned u = 1; u < VT.size(); ++u) {
          TT = tripletUnion(TT, VT[u]);
        }
     
        setTripletToValue(F, V, TT);
        return TT;
      }
#endif
    }
   
    if (isa<LoadInst>(V)) {
      LoadInst *Load = dyn_cast<LoadInst>(V);
      CycleColorMap[Load] = GREY;

      Value *PtrOperand = Load->getPointerOperand();
      Instruction *POInst = dyn_cast<Instruction>(PtrOperand);
      if (POInst && CycleColorMap[POInst] == GREY && (TI.find(PtrOperand) == TI.end())) {
        TripletType TT;
        setTripletType(F, POInst, &TT, kNonInvariant, kNonInvariant, kNonInvariant);
        return TT;
      } else {
        T = getOrCalculateTriplet(F, PtrOperand);
        setTripletToValue(F, V, T);
        return T;
      }
    }

    if (isa<StoreInst>(V)) {
      StoreInst *Store = dyn_cast<StoreInst>(V);
      CycleColorMap[Store] = GREY;

      Value *ValueOperand = Store->getValueOperand();
      Instruction *ValueInst = dyn_cast<Instruction>(ValueOperand);
      if (ValueOperand && CycleColorMap[ValueInst] == GREY && (TI.find(ValueOperand) == TI.end())) {
        TripletType TT;
        setTripletType(F, ValueInst, &TT, kNonInvariant, kNonInvariant, kNonInvariant);
        return TT;
      } else {
        T = getOrCalculateTriplet(F, ValueOperand);
        setTripletToValue(F, V, T);
        return T;
      }
    }

    if (isa<BranchInst>(V)) {
      BranchInst *Branch = dyn_cast<BranchInst>(V);

      if (Branch->isUnconditional()) {
        setTripletType(F, V, &T, kInvariant, kInvariant, kInvariant);
        return T;
      } else {
        TripletType BrCondTT = getOrCalculateTriplet(F, Branch->getCondition());
        setTripletType(F, V, &T, BrCondTT.x, BrCondTT.y, BrCondTT.z);
        return BrCondTT;
      }
    }

    if (isa<ReturnInst>(V)) {
      setTripletType(F, V, &T, kInvariant, kInvariant, kInvariant);
      return T;
    }

    if (isa<PHINode>(V)) {
      setTripletType(F, V, &T, kNonInvariant, kNonInvariant, kNonInvariant);
      return T;
    }

    if (isa<CallInst>(V)) {
      CallInst *a_call = dyn_cast<CallInst>(V);
      StringRef called_func_nm = getCalledFunctionName(a_call);
      StringRef workdim_func_nm("get_work_dim");
      StringRef globalsize_func_nm("get_global_size");
      StringRef globalid_func_nm("get_global_id");
      StringRef localsize_func_nm("get_local_size");
      StringRef localid_func_nm("get_local_id");
      StringRef numgroups_func_nm("get_num_groups");
      StringRef groupid_func_nm("get_group_id");
      StringRef globaloffset_func_nm("get_global_offset");

      if ((called_func_nm == localid_func_nm) ||
          (called_func_nm == globalid_func_nm)) {
        Value *get_local_id_arg = a_call->getArgOperand(0);
        ConstantInt *CI = dyn_cast<ConstantInt>(get_local_id_arg);
        
        if (CI == DimensionKinds[0]) {
          setTripletType(F, V, &T, kNonInvariant, kInvariant, kInvariant);
        } else if (CI == DimensionKinds[1]) {
          setTripletType(F, V, &T, kInvariant, kNonInvariant, kInvariant);
        } else if (CI == DimensionKinds[2]) {
          setTripletType(F, V, &T, kInvariant, kInvariant, kNonInvariant);
        }
        return T;
      } else if ((called_func_nm == localsize_func_nm) || 
                 (called_func_nm == globalsize_func_nm) ||
                 (called_func_nm == workdim_func_nm) || 
                 (called_func_nm == numgroups_func_nm) ||
                 (called_func_nm == groupid_func_nm) ||
                 (called_func_nm == globaloffset_func_nm)){
        setTripletType(F, V, &T, kInvariant, kInvariant, kInvariant);
        return T;
      } else {
#if 1
        CallSite CS(a_call);
        SmallVector<TripletType, 8> VT;
        for (CallSite::arg_iterator ArgIt = CS.arg_begin(), End = CS.arg_end(); ArgIt != End; ++ArgIt) {
          Value *A = *ArgIt;
          VT.push_back(getOrCalculateTriplet(F, A));
        }

        T = VT[0];
        for (unsigned opr = 1; opr < VT.size(); ++opr) {
          T = tripletUnion(T, VT[opr]);
        }

        setTripletToValue(F, V, T);
        return T;
#else
        setTripletType(F, V, &T, kNonInvariant, kNonInvariant, kNonInvariant);
        return T;
#endif
      }
    }

    if (isa<GetElementPtrInst>(V)) {
      GetElementPtrInst *GEP = dyn_cast<GetElementPtrInst>(V);
      
      //FIXME: if this is a GEP with a variable indices, we can't handle it
      PointerType *PtrTy = dyn_cast<PointerType>(GEP->getPointerOperandType());
      if (!PtrTy) {
        setTripletType(F, V, &T, kNonInvariant, kNonInvariant, kNonInvariant);
        return T;
      }

      // Collect the offsets that this GEP add to the pointer
      Value *PtrOp = GEP->getPointerOperand();

      if (PtrOp) {
        T = getOrCalculateTriplet(F, PtrOp);
        if (GEP->hasAllConstantIndices()) {
          setTripletToValue(F, V, T);
          return T;
        } else {
          SmallVector<Value*, 8> Indices(GEP->op_begin() + 1, GEP->op_end());
          SmallVector<TripletType, 8> VT;

          for (SmallVector<Value*, 8>::iterator I = Indices.begin(), 
               E = Indices.end(); I != E; ++I) {
            VT.push_back(getOrCalculateTriplet(F, *I));
          }

          for (SmallVector<TripletType, 8>::iterator IT = VT.begin(), 
               ET = VT.end(); IT != ET; ++IT) {
            T = tripletUnion(T, *IT);
          }

          setTripletToValue(F, V, T);
          return T;
        }
      } else {
          setTripletType(F, V, &T, kNonInvariant, kNonInvariant, kNonInvariant);
          return T;
      }

      setTripletType(F, V, &T, kNonInvariant, kNonInvariant, kNonInvariant);
      return T;
    }

    Instruction *instr = dyn_cast<Instruction>(V);
    if (instr == NULL) {
      setTripletType(F, V, &T, kNonInvariant, kNonInvariant, kNonInvariant);
      return T;
    } else {
      if (instr->getNumOperands() >= 1) {
        std::vector<TripletType> VT;
        for (unsigned opr = 0; opr < instr->getNumOperands(); ++opr) {
          Value *operand = instr->getOperand(opr);
          VT.push_back(getOrCalculateTriplet(F, operand));
        }

        T = VT[0];
        for (unsigned opr = 1; opr < instr->getNumOperands(); ++opr) {
          T = tripletUnion(T, VT[opr]);
        }
      }
      
      setTripletToValue(F, V, T);
      return T;
    }
  
    setTripletToValue(F, V, T);
    return T;
  }

  void 
  TripletInvarianceAnalysis::printTripletType(raw_ostream &OS, 
                                              TripletType *TT,
                                              Instruction *I) const 
  {
    if (!I) {
      OS << "(" << TT->x << "," << TT->y << "," << TT->z <<")\n";
    } else {
      OS << "(" << TT->x << "," << TT->y << "," 
                << TT->z << ") ... " << *I << "\n";
    }
  }

  void
  TripletInvarianceAnalysis::initialize(Function &F) {

    TI.clear();

    // Initialize dimension vector
    ConstantInt *DK_CI_0 = ConstantInt::get(
                             IntegerType::get(
                               F.getContext(), 32), 0);

    ConstantInt *DK_CI_1 = ConstantInt::get(
                             IntegerType::get(
                               F.getContext(), 32), 1);

    ConstantInt *DK_CI_2 = ConstantInt::get(
                             IntegerType::get(
                               F.getContext(), 32), 2);

    DimensionKinds.push_back(DK_CI_0);
    DimensionKinds.push_back(DK_CI_1);
    DimensionKinds.push_back(DK_CI_2);
  }

  bool TripletInvarianceAnalysis::WorklistApproach(Function &F) {
    bool Changed = false;

    std::queue<Instruction *> Worklist;
    for (inst_iterator I = inst_begin(F), E = inst_end(F); I != E; ++I) {
      BasicBlock::iterator BI = I.getInstructionIterator();
      Worklist.push(&*BI);

      TripletType TTT = getOrCalculateTriplet(&F, &*BI);
      TI[&*BI] = TTT;
      printTripletType(errs(), &TI[&*BI], BI);
    }

    while(!Worklist.empty()) {
      Instruction* n = Worklist.front();
      Worklist.pop();
      
      //visit(n);
      TripletType OldColor = TI[n];
      TripletType NewColor = unionTripletFromAllOperands(&F, n);
      TI[n] = NewColor;

      //errs() << "Visiting " << *n << "; OldColor ";
      //printTripletType(errs(), &OldColor, NULL);
      //printTripletType(errs(), &NewColor, NULL);
      
      if (!isTripletEqual(&OldColor, &NewColor)) {
        for (Instruction::use_iterator ui = n->use_begin(), 
                                       ue = n->use_end();
                                       ui != ue; ++ui) {
          if (isa<Instruction>(*ui)) {
            errs() << **ui << " | ";
            Worklist.push(dyn_cast<Instruction>(*ui));
          }
        }
      }
    }

    return Changed;
  }

  bool 
  TripletInvarianceAnalysis::shouldBePrivatized(Function *f, Value *val)
  {
    TripletType T = {kInvariant, kInvariant, kInvariant};

    TripletInvarianceAnalysis::TripletType TV = getOrCalculateTriplet(f, val);

    if (!isTripletEqual(&T, &TV)) {
      return true;
    }

    if (isa<AllocaInst>(val))
      return true;

    if (isa<StoreInst>(val) &&
        isa<AllocaInst>(dyn_cast<StoreInst>(val)->getPointerOperand()))
      return true;

    return false;
  }

  void
  TripletInvarianceAnalysis::analyzeBBDivergence(Function *f, BasicBlock *bb, 
                                                 BasicBlock *previousUniformBB)
  {
    BranchInst *Br = 
      dyn_cast<BranchInst>(previousUniformBB->getTerminator());  

    if (Br == NULL) {
      return;
    }

    BasicBlock *NewPreviousUniformBB = previousUniformBB;

    TripletType BrCondTT = getOrCalculateTriplet(f, Br->getCondition());
    TripletType III = {kInvariant, kInvariant, kInvariant};
    bool IsUniform = isTripletEqual(&BrCondTT, &III);
    if ((!Br->isConditional() || IsUniform)) {
      for (unsigned suc = 0, end = Br->getNumSuccessors(); suc < end; ++suc) {
        if (Br->getSuccessor(suc) == bb) {
          TripletType T = {kUnknown, kUnknown, kUnknown};
          setTripletType(f, bb, &T, kInvariant, kInvariant, kInvariant);
          NewPreviousUniformBB = bb;
          break;
        }
      }
    } 

    if (NewPreviousUniformBB != bb) {
      PostDominatorTree *PDT = &getAnalysis<PostDominatorTree>();
      if (PDT->dominates(bb, previousUniformBB)) {
        TripletType T = {kUnknown, kUnknown, kUnknown};
        setTripletType(f, bb, &T, kInvariant, kInvariant, kInvariant);
        NewPreviousUniformBB = bb;
      }
    } 

    if (!isTripletInvarianceAnalyzed(f, bb)) {
        TripletType T = {kUnknown, kUnknown, kUnknown};
        setTripletType(f, bb, &T, kNonInvariant, kNonInvariant, kNonInvariant);
    }

    BranchInst *NextBr = dyn_cast<BranchInst>(bb->getTerminator());  

    if (NextBr == NULL) return;

    for (unsigned suc = 0, end = NextBr->getNumSuccessors(); suc < end; ++suc) {
      BasicBlock *NextBB = NextBr->getSuccessor(suc);
      if (!isTripletInvarianceAnalyzed(f, NextBB)) {
        analyzeBBDivergence(f, NextBB, NewPreviousUniformBB);
      }
    }
  }

  bool
  TripletInvarianceAnalysis::isTripletInvarianceAnalyzed(Function *f, Value *v)
  {
    TripletIndex &TI = TC[f];

    if (TI.find(v) != TI.end()) {
      return true;
    }

    return false;
  }

  bool 
  TripletInvarianceAnalysis::isTripletEqual(TripletType *left, 
                                            TripletType *right) 
  {
    if ((left->x == right->x) &&
        (left->y == right->y) &&
        (left->z == right->z) ) {
      return true;
    } else {
      return false;
    }
  } 

  bool TripletInvarianceAnalysis::isUniform(Function *F, Value *V)
  {
    TripletType VTT = getOrCalculateTriplet(F, V);
    TripletType III = {kInvariant, kInvariant, kInvariant};

    bool IsUniform = false;
    if (isTripletEqual(&VTT, &III)) {
      IsUniform = true;
    }

    return IsUniform;
  }

  void TripletInvarianceAnalysis::dumpAllTriplets(raw_ostream &OS, Function &F)
  {

    // Print results
    for (inst_iterator I = inst_begin(F), E = inst_end(F); I != E; ++I) {
      BasicBlock::iterator BI = I.getInstructionIterator();
      if (TC[&F].find(BI) != TC[&F].end()) {
        TripletType tmp = TI[&*BI];
        printTripletType(OS, &tmp, BI);
      } else {
        errs() << "(?,?,?) ... " << *BI << "\n";
      }
    }
  }
 

  //===--------------------------------------------------------------------===//
  char IPTIA::ID = 0;

  namespace {
    static
    RegisterPass<IPTIA>
      IPTIAModulePass("mxpa_IPtia", "thread invariance analysis on module");
  }

  void IPTIA::getAnalysisUsage(AnalysisUsage &AU) const {
    AU.addRequired<TripletInvarianceAnalysis>();
  }

  bool IPTIA::runOnModule(Module &M) {
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
      DEBUG_WITH_TYPE("mxpa_tripletinvarianceanalysis", errs() << "Kevin said ---->" << *K << "\n");
    }

    for (Module::iterator F = M.begin(), E = M.end(); F != E; ++F) {
      if (F->isDeclaration())
        continue;

      std::string fnm = F->getName().str();
      bool IsKernel = (std::find(KernelNames.begin(), KernelNames.end(), fnm) 
                       != KernelNames.end());

      if (!IsKernel)
        continue;

      DEBUG_WITH_TYPE("mxpa_tripletinvarianceanalysis", errs() << "Found a function: " << F->getName() << "\n");
      getAnalysis<TripletInvarianceAnalysis>(*F);

      Changed = true;
    }

    return Changed;
  }

}
}

