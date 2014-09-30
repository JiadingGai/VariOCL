#define DEBUG_TYPE "mxpa_BreakPhi"

//LLVM includes
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Constants.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/Support/InstIterator.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/IR/IRBuilder.h"
//MxPA includes
#include "barrier_inst.h"
#include "barrier_utils.h"
#include "break_phi_to_alloca.h"
#include "kernel_info_reader.h"

namespace SpmdKernel {

using namespace llvm;

namespace Coarsening {
  
  char BreakPhi::ID = 0;

  namespace {
    static
    RegisterPass<BreakPhi> X("mxpa_BreakPhi", "Break phi to alloca");
  }

  bool BreakPhi::runOnFunction(Function &F) {
    bool Changed = false;

    CD = &getAnalysis<ControlDep>();
    LLVMContext &LC = F.getContext();

    CollectUnbreakablePHIs(F); // collect all untouchable phis in the function
    DEBUG_WITH_TYPE("mxpa_BreakPhi", errs() << "[nUnbreakablePHIs] " << UnbreakablePHIs.size() << " is " << **UnbreakablePHIs.begin() << "\n");

    SplitAndSink(F); // process phi's in those bb's that controls a barrier.

    BreakPhi2Alloca(F); // process the rest of the phi's in the function.

    return Changed;
  }
  
  BreakPhi::~BreakPhi() {
  }

  void BreakPhi::SplitAndSinkFromTo(BasicBlock *From, BasicBlock *To)
  {
    assert(To->size() == 1 && "The moveto target of SplitAndSinkFromTo should contain a single (cond br) instruction!\n");
    
    Instruction *MovePoint = To->getFirstInsertionPt();

    BranchInst *BrMovePoint = dyn_cast<BranchInst>(MovePoint);
    //assert(BrMovePoint && BrMovePoint->isConditional() && "SplitAndSinkFromTo only works for conditional branch!");

    std::set<Instruction *> TransitiveUsesByTI;
    TransitiveUsesByTI.insert(MovePoint);

    bool FindAllTransitiveUsesComplete = false;
    do {
      int NumOfTransitiveUses = 0;

      for (BasicBlock::iterator II = From->begin(), IE = From->end(); II != IE; ++II) {
        Instruction *Inst = &*II;

        for (Instruction::use_iterator ui = Inst->use_begin(), ue = Inst->use_end(); ui != ue; ++ui) {
          Instruction *user = dyn_cast<Instruction>(*ui);

          if ((user == NULL) || ((user->getParent() != From) && (user->getParent() != To)))
            continue;

          if ((TransitiveUsesByTI.find(user) != TransitiveUsesByTI.end()) && 
              (TransitiveUsesByTI.find(Inst) == TransitiveUsesByTI.end())) {
            TransitiveUsesByTI.insert(Inst);
            NumOfTransitiveUses++;
            break;
          }
        }
      }   

      if (NumOfTransitiveUses == 0) {
        FindAllTransitiveUsesComplete = true;
      }
    } while(!FindAllTransitiveUsesComplete);


    std::vector<Instruction *> InstToMove;
    for (BasicBlock::iterator II = From->begin(), IE = From->end(); II != IE; ++II)
    {
      Instruction *Inst = &*II;

      if (isa<TerminatorInst>(Inst))
        continue;

      if (TransitiveUsesByTI.find(Inst) != TransitiveUsesByTI.end())
        continue;

      InstToMove.push_back(Inst);
    }

    for (std::vector<Instruction *>::iterator II = InstToMove.begin(), IE = InstToMove.end(); II != IE; ++II)
    {
      Instruction *Inst = *II;

      if (isa<PHINode>(Inst)) {
        PHINode *PN = dyn_cast<PHINode>(Inst);
        BreakPhi2Alloca2(PN, MovePoint);

      } else {
        Inst->moveBefore(MovePoint);
      }
    }
  }

  void BreakPhi::SplitAndSink(Function &F)
  {
    std::vector<Instruction*> BarSet;

    for (Function::iterator BI = F.begin(), BE = F.end(); BI != BE; ++BI) {
      BasicBlock *X = BI;
      for (BasicBlock::iterator II = X->begin(), IE = X->end(); II != IE; ++II) {
        Instruction *I = &*II;

        if (isa<BarrierInst>(I)) {
          BarSet.push_back(I);
        }
      }
    } 

    std::set<BasicBlock*> BBsCtrl;
    for (std::vector<Instruction*>::iterator II = BarSet.begin(), IE = BarSet.end(); II != IE; ++II) {
      Instruction *BarInst = *II;
      BasicBlock *Y = BarInst->getParent();

      for (Function::iterator BI = F.begin(), BE = F.end(); BI != BE; ++BI) {
        BasicBlock *X = &*BI;

        if (CD->isIterativelyCtrlDep(X, Y) && (X != Y)) {
          BBsCtrl.insert(X);
          continue;
        }
      }
    }

    if (BBsCtrl.size() > 0) {
      for (std::set<BasicBlock*>::iterator BI = BBsCtrl.begin(), BE = BBsCtrl.end(); BI != BE; ++BI)
      {
        BasicBlock *Old = *BI;
        
        Instruction *SplitPt = Old->getTerminator();

        BranchInst *SplitPtBrInst = dyn_cast<BranchInst>(SplitPt);
        //assert(SplitPtBrInst && SplitPtBrInst->isConditional() && "SplitAndSink only works for conditional branch!");

        BasicBlock *New = SplitBlock(Old, SplitPt, this); 

        SplitAndSinkFromTo(Old, New);
      }
    } 
  }
  
  void BreakPhi::CollectUnbreakablePHIs(Function &F)
  {
    std::vector<Instruction*> BarSet;

    for (Function::iterator BI = F.begin(), BE = F.end(); BI != BE; ++BI) {
      BasicBlock *X = BI;
      for (BasicBlock::iterator II = X->begin(), IE = X->end(); II != IE; ++II) {
        Instruction *I = &*II;

        if (isa<BarrierInst>(I)) {
          BarSet.push_back(I);
        }
      }
    } 

    std::set<BasicBlock*> BBsCtrl;
    for (std::vector<Instruction*>::iterator II = BarSet.begin(), IE = BarSet.end(); II != IE; ++II) {
      Instruction *BarInst = *II;
      BasicBlock *Y = BarInst->getParent();

      for (Function::iterator BI = F.begin(), BE = F.end(); BI != BE; ++BI) {
        BasicBlock *X = &*BI;

        if (CD->isIterativelyCtrlDep(X, Y) && (X != Y)) {
          BBsCtrl.insert(X);
          continue;
        }
      }
    }

    for (std::set<BasicBlock*>::iterator BI = BBsCtrl.begin(), BE = BBsCtrl.end(); BI != BE; ++BI)
    {
      BasicBlock *BB = *BI;
      TerminatorInst *TI = BB->getTerminator();

      std::set<Instruction *> TransitiveUsesByTI;
      TransitiveUsesByTI.insert(TI);

      bool NoMoreTransitiveUses = false;
      do {
        int NumOfNewTransitiveUsesFound = 0;

        for (BasicBlock::iterator II = BB->begin(), IE = BB->end(); II != IE; ++II) {
          Instruction *Inst = &*II;

          for (Instruction::use_iterator ui = Inst->use_begin(), ue = Inst->use_end(); ui != ue; ++ui) {
            Instruction *user = dyn_cast<Instruction>(*ui);

            if ((user == NULL) || (user->getParent() != BB)) 
              continue;

            if ((TransitiveUsesByTI.find(user) != TransitiveUsesByTI.end()) && 
                (TransitiveUsesByTI.find(Inst) == TransitiveUsesByTI.end())) {
              TransitiveUsesByTI.insert(Inst);
              ++NumOfNewTransitiveUsesFound;

              if(PHINode * PN = dyn_cast<PHINode>(Inst)) {
                UnbreakablePHIs.insert(PN);
              }

              break;
            }
          }
        }

        if (NumOfNewTransitiveUsesFound == 0) {
          NoMoreTransitiveUses = true;
        }
      } while (!NoMoreTransitiveUses);

    }
  }

  void BreakPhi::BreakPhi2Alloca(Function &F)
  {
    typedef std::vector<Instruction* > InstructionVec;
    InstructionVec PHIs;

    for (Function::iterator bb = F.begin(); bb != F.end(); ++bb) {
      for (BasicBlock::iterator p = bb->begin(); p != bb->end(); ++p) {
        Instruction* instr = p;
        if (isa<PHINode>(instr)) {
          PHINode *PN = dyn_cast<PHINode>(instr);
          if (UnbreakablePHIs.find(PN) == UnbreakablePHIs.end()) {
            PHIs.push_back(instr);
          }
        }
      }
    }

    for (InstructionVec::iterator i = PHIs.begin(); i != PHIs.end(); ++i) {
      Instruction *instr = *i;
      PHINode *phi = dyn_cast<PHINode>(instr);

      std::string allocaName = std::string(phi->getName().str()) + ".ex_phi";

      Function *function = phi->getParent()->getParent();

      BasicBlock *RealKernelEntry = &function->getEntryBlock();

      IRBuilder<> BuilderBP(&RealKernelEntry->front());

      Instruction *alloca = 
        BuilderBP.CreateAlloca(phi->getType(), 0, allocaName);

      for (unsigned incoming = 0; incoming < phi->getNumIncomingValues(); ++incoming) {
        Value *val = phi->getIncomingValue(incoming);
        BasicBlock *incomingBB = phi->getIncomingBlock(incoming);
        BuilderBP.SetInsertPoint(incomingBB->getTerminator());
        BuilderBP.CreateStore(val, alloca);
      }

      BuilderBP.SetInsertPoint(phi);

      Instruction *loadedValue = BuilderBP.CreateLoad(alloca);
      phi->replaceAllUsesWith(loadedValue);
      phi->eraseFromParent();
    }  
  }

  void BreakPhi::BreakPhi2Alloca2(PHINode *phi, Instruction *LoadInsertPt)
  {
    std::string allocaName = std::string(phi->getName().str()) + ".ex_phi";

    Function *function = phi->getParent()->getParent();

    BasicBlock *RealKernelEntry = &function->getEntryBlock();

    IRBuilder<> BuilderBP(&RealKernelEntry->front());

    Instruction *alloca = 
      BuilderBP.CreateAlloca(phi->getType(), 0, allocaName);

    for (unsigned incoming = 0; incoming < phi->getNumIncomingValues(); ++incoming) {
      Value *val = phi->getIncomingValue(incoming);
      BasicBlock *incomingBB = phi->getIncomingBlock(incoming);
      BuilderBP.SetInsertPoint(incomingBB->getTerminator());
      BuilderBP.CreateStore(val, alloca);
    }

    BuilderBP.SetInsertPoint(LoadInsertPt);

    Instruction *loadedValue = BuilderBP.CreateLoad(alloca);
    phi->replaceAllUsesWith(loadedValue);
    phi->eraseFromParent();
  }

  //===--------------------------------------------------------------------===//
  char IPBreakPhi::ID = 0;

  namespace {
    static
    RegisterPass<IPBreakPhi>
      IPBreakPhiModulePass("mxpa_IPBreakPhi", "Break phi to alloca");
  }

  void IPBreakPhi::getAnalysisUsage(AnalysisUsage &AU) const {
    AU.addRequired<BreakPhi>();
  }

  bool IPBreakPhi::runOnModule(Module &M) {
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
      DEBUG_WITH_TYPE("mxpa_ms4", errs() << "Kevin said ---->" << *K << "\n");
    }

    for (Module::iterator F = M.begin(), E = M.end(); F != E; ++F) {
      if (F->isDeclaration())
        continue;

      std::string fnm = F->getName().str();
      bool IsKernel = (std::find(KernelNames.begin(), KernelNames.end(), fnm) 
                       != KernelNames.end());

      if (!IsKernel)
        continue;

      DEBUG_WITH_TYPE("mxpa_ms4", errs() << "Found a function: " 
                                         << F->getName() << "\n");
      getAnalysis<BreakPhi>(*F);

      Changed = true;
    }

    return Changed;
  }

}
}
