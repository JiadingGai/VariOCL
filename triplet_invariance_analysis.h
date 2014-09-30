#ifndef MXPA_TRIPLET_INVARIANCE_ANALYSIS
#define MXPA_TRIPLET_INVARIANCE_ANALYSIS

#include "llvm/Pass.h"
#include "llvm/InstVisitor.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/Analysis/Dominators.h"
#include "llvm/Analysis/PostDominators.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Constants.h"
#include "llvm/Analysis/LoopPass.h"
#include "llvm/Analysis/ScalarEvolution.h"

//
#include <vector>
#include <utility>

namespace SpmdKernel{
namespace Coarsening {

//
class TripletInvarianceAnalysis : public llvm::FunctionPass {
  
private:

  enum CycleColor {WHITE, GREY, BLACK};
  typedef llvm::DenseMap<llvm::Instruction *, CycleColor> I2CMapTy;
  I2CMapTy CycleColorMap;

  /*
   * kInvariant : work-item invariant
   * kNonInvariant : work-item variant
   * kUnknown : not computed yet
   * kMaybeNonInvariant : 
   */
  enum Color {kInvariant, kNonInvariant, kUnknown, kMaybeNonInvariant};
  typedef struct TripletTy {
    Color x;
    Color y;
    Color z;
  } TripletType;

  typedef std::map<llvm::Value*, TripletType> TripletIndex;
  TripletIndex TI;
  
  typedef std::map<llvm::Function*, TripletIndex> TripletCache;
  TripletCache TC;

  std::vector<llvm::ConstantInt *> DimensionKinds;

  llvm::ScalarEvolution *SE;

  void setTripletType(llvm::Function *F, llvm::Value *V, TripletType *TT, 
                      Color x, Color y, Color z)
  {
    TT->x = x;
    TT->y = y;
    TT->z = z;
    
    setTripletToValue(F, V, *TT);
  }

  virtual void setTripletToValue(llvm::Function *F, llvm::Value *V, 
                                 TripletType TT) 
  {
    TI[V] = TT;

    TripletIndex &Ti = TC[F];
    Ti[V] = TT; 
  }

  Color colorLUT(Color Op1, Color Op2) 
  {
    Color C = kUnknown;
    if ((Op1 == kNonInvariant) || (Op2 == kNonInvariant)) {
      C = kNonInvariant;
    } else if ((Op1 == kUnknown) || (Op2 == kUnknown) ) {
      C = kUnknown;
    } else if ((Op1 == kInvariant) && (Op2 == kInvariant)) {
      C = kInvariant;
    }

    return C;
  }

  TripletType tripletUnion(TripletType T1, TripletType T2) 
  {
    TripletType T;
    T.x = colorLUT(T1.x, T2.x);
    T.y = colorLUT(T1.y, T2.y);
    T.z = colorLUT(T1.z, T2.z);

    return T;
  }

  TripletType 
  unionTripletFromAllOperands(llvm::Function *F, llvm::Instruction *Instr) 
  {
    TripletType T = TI[Instr];
    if (Instr == NULL) {
      return T;
    } else {
      if (Instr->getNumOperands() >= 1) {
        std::vector<TripletType> VT;
        for (unsigned opr = 0; opr < Instr->getNumOperands(); ++opr) {
          llvm::Value *operand = Instr->getOperand(opr);
    
          VT.push_back(getOrCalculateTriplet(F, operand));
        }

        TripletType T = VT[0];
        for (unsigned opr = 1; opr < Instr->getNumOperands(); ++opr) {
          T = tripletUnion(T, VT[opr]);
        }
      }
      return T;
    }
  }

public:
  static char ID;

  TripletInvarianceAnalysis() : FunctionPass(ID) {
    /* empty */;
  }

  ~TripletInvarianceAnalysis();

  virtual void getAnalysisUsage(llvm::AnalysisUsage &AU) const {
    //
    AU.setPreservesAll();
    AU.addRequired<llvm::DominatorTree>();
    AU.addRequired<llvm::PostDominatorTree>();
    AU.addRequired<llvm::LoopInfo>();
    AU.addRequired<llvm::ScalarEvolution>();
  }

  virtual bool runOnFunction(llvm::Function &F);


  virtual TripletType getOrCalculateTriplet(llvm::Function *F, llvm::Value *V);
  virtual bool WorklistApproach(llvm::Function &F);
  virtual bool shouldBePrivatized(llvm::Function *f, llvm::Value *val);
  virtual bool isTripletInvarianceAnalyzed(llvm::Function *f, llvm::Value *v);
  virtual void analyzeBBDivergence(llvm::Function *f, llvm::BasicBlock *bb, 
                                   llvm::BasicBlock *previousUniformBB);
  virtual void printTripletType(llvm::raw_ostream &OS, TripletType *TT, 
                                llvm::Instruction *I = NULL) const;
  virtual void dumpAllTriplets(llvm::raw_ostream &OS, llvm::Function &F);

  virtual void initialize(llvm::Function &F);

  bool isBarrierLoop(llvm::Loop *L);

  bool isTripletEqual(TripletType *left, TripletType *right);

  bool isUniform(llvm::Function *F, llvm::Value *V);
};

//===----------------------------------------------------------------------===//
struct IPTIA : public llvm::ModulePass {
  virtual void getAnalysisUsage(llvm::AnalysisUsage &AU) const;
  static char ID;
  IPTIA() : llvm::ModulePass(ID) {
    ;
  }
  bool runOnModule(llvm::Module &M);
  
};

}
}

#endif
