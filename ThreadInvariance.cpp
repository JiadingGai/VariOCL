/** \file lib/Analysis/ThreadInvariance.cpp
    \brief Implements ThreadInvariance Analysis Pass */
// TODO(matthieu): Add copyright/license here
#include <queue>
#include "llvm/Analysis/Dominators.h"
#include "llvm/IR/Instructions.h"
//#include "llvm/MCWInitializePasses.h"
#include "llvm/IR/Module.h"
#include "llvm/InstVisitor.h"
#include "llvm/Support/raw_ostream.h"

#include "ControlDependence.h"
#include "OpenClAl.h"
#include "ThreadInvariance.h"

using namespace llvm;
//INITIALIZE_PASS_BEGIN(ThreadInvariance, "thread-invariance",
//                "Identify to which local/global ids a value is dependent on",
//                false, true)
//INITIALIZE_PASS_DEPENDENCY(OpenClAl)
//INITIALIZE_PASS_DEPENDENCY(ControlDependence)
//INITIALIZE_PASS_DEPENDENCY(DominatorTree)
//INITIALIZE_PASS_END(ThreadInvariance, "thread-invariance",
//                "Identify to which local/global ids a value is dependent on",
//                false, true)

namespace {
using ::llvm::BasicBlock;
using SpmdKernel::Coarsening::ControlDependence;
using ::llvm::Function;
using ::llvm::TerminatorInst;
using SpmdKernel::Coarsening::InvarianceInfo;
using ::llvm::Value;

typedef InvarianceInfo::InvarianceKind InvarianceKind;

/** \brief Meet binary operator for InvarianceKind
  *                       +-----------------+--------------------+--------------------+--------------------+
  *                       |  kNonInvariant  | kMaybeNonInvariant | kInvariant         | kUnknown           |
  * +--------------------++=================+====================+====================+====================+
  * | kNonInvariant      ||  kNonInvariant  | kNonInvariant      | kNonInvariant      | kNonInvariant      |
  * +--------------------++-----------------+--------------------+--------------------+--------------------+
  * | kMaybeNonInvariant ||  kNonInvariant  | kMaybeNonInvariant | kMaybeNonInvariant | kMaybeNonInvariant |
  * +--------------------++-----------------+--------------------+--------------------+--------------------+
  * | kInvariant         ||  kNonInvariant  | kMaybeNonInvariant | kInvariant         | kInvariant         |
  * +--------------------++-----------------+--------------------+--------------------+--------------------+
  * | kUnknown           ||  kNonInvariant  | kMaybeNonInvariant | kInvariant         | kUnknown           |
  * +--------------------++-----------------+--------------------+--------------------+--------------------+
  \param  lhs the first operand to the binary operator
  \param  rhs the second operand to the binary operator
  \return The table entry value corresponding to the two operands
 */


InvarianceKind meet(const InvarianceKind& lhs, const InvarianceKind& rhs) {
  if (lhs == InvarianceInfo::kNonInvariant
      || rhs == InvarianceInfo::kNonInvariant ) return InvarianceInfo::kNonInvariant;
  if (lhs == InvarianceInfo::kMaybeNonInvariant
      || rhs == InvarianceInfo::kMaybeNonInvariant ) return InvarianceInfo::kMaybeNonInvariant;
  if (lhs == InvarianceInfo::kInvariant
      || rhs == InvarianceInfo::kInvariant) return InvarianceInfo::kInvariant;
  return InvarianceInfo::kUnknown;
}

/** \brief Join ( V ) binary operator for InvarianceKind
  *                 +-------------+---------------+------------+
  *                 |   kNonInvariant  | kMaybeNonInvariant | kInvariant |
  * +---------------++============+===============+============+
  * | kNonInvariant ||  kNonInvariant  |   kNonInvariant    | kInvariant |
  * +---------------++------------+---------------+------------+
  * | kMaybeNonInvariant ||  kNonInvariant  | kMaybeNonInvariant | kInvariant |
  * +---------------++------------+---------------+------------+
  * | kInvariant    || kInvariant |  kInvariant   | kInvariant |
  * +---------------++------------+---------------+------------+
  \param  lhs the first operand to the binary operator
  \param  rhs the second operand to the binary operator
  \return The table entry value corresponding to the two operands
 */

InvarianceKind join(const InvarianceKind& lhs, const InvarianceKind& rhs) {
  if (lhs == InvarianceInfo::kInvariant
      || rhs == InvarianceInfo::kInvariant) return InvarianceInfo::kInvariant;
  if (lhs == InvarianceInfo::kMaybeNonInvariant
      || rhs == InvarianceInfo::kMaybeNonInvariant ) return InvarianceInfo::kMaybeNonInvariant;
  if (lhs == InvarianceInfo::kNonInvariant
      || rhs == InvarianceInfo::kNonInvariant) return InvarianceInfo::kNonInvariant;
  return InvarianceInfo::kUnknown;

}
} // namespace <anonymous>

namespace SpmdKernel {
namespace Coarsening {

/// TODO(matthieu): hide
class ThreadInvarianceImpl {
  public:
  typedef std::deque<const BasicBlock *> WorkQueue;
  typedef ThreadInvariance::GVSet GVSet;
  typedef GVSet::const_iterator iterator;
  ThreadInvarianceImpl() : coarseDetected(false) {}
  ~ThreadInvarianceImpl() {}
  bool Build(Function& F, ControlDependence& CD, const OpenClAl& opencl, const DominatorTree& DT);  // NOLINT
  InvarianceInfo getInvariance(const Value * V) const;
  void updateInvariance(const Value *V, const InvarianceInfo& variance);
  iterator begin() const;
  iterator end() const;
  bool alreadyCoarsed() const;
  void setCoarseDetected();

  protected:

  void InitializeMap(Function &F, const OpenClAl& opencl);
  typedef llvm::DenseMap<const Value *, InvarianceInfo> InvarianceMap;
  GVSet globalInvariances;

  InvarianceMap variances;
  bool coarseDetected;
};

}
} 

namespace {
using SpmdKernel::Coarsening::ControlDependence;
using SpmdKernel::Coarsening::ThreadInvarianceImpl;
using SpmdKernel::Coarsening::OpenClAl;
using ::llvm::DominatorTree;

/** \brief Implementation of DataFlow algorithm
  *        for value variance computation.
  */
class DataFlow : public llvm::InstVisitor<DataFlow> {
  public:
  typedef ThreadInvarianceImpl::WorkQueue WorkQueue;
  DataFlow(ThreadInvarianceImpl * var, ControlDependence& dependences,  // NOLINT
           const OpenClAl& opencl, const DominatorTree& DT, WorkQueue& work);
  ~DataFlow();
  void visitAllocaInst(llvm::AllocaInst& AI);
  void visitBinaryOperator(llvm::BinaryOperator& BO);
  void visitCallInst(llvm::CallInst& CallInst);
  void visitCastInst(llvm::CastInst& CastInst);
  void visitCmpInst(llvm::CmpInst& CI);
  void visitExtractElementInst(llvm::ExtractElementInst& EEI);
  void visitGetElementPtrInst(llvm::GetElementPtrInst& GEP);
  void visitInsertElementInst(llvm::InsertElementInst& IEI);
  void visitInstruction(llvm::Instruction& inst);
  void visitLoadInst(llvm::LoadInst& load);
  void visitPHINode(llvm::PHINode& phi);
  void visitSelectInst(llvm::SelectInst& SI);
  void visitShuffleVectorInst(llvm::ShuffleVectorInst& SVI);
  void visitStoreInst(llvm::StoreInst& SI);
  void visitBranchInst(llvm::BranchInst& BI);
  void AnalyzeBlock(const BasicBlock * BB);

  private:
  ThreadInvarianceImpl * parent;
  ControlDependence& controlDep;
  const OpenClAl& opencl;
  const DominatorTree& dt;
  WorkQueue& queue;
  InvarianceInfo currentControlInvariance;
  void applyStandardRule(llvm::Instruction& inst);

  InvarianceInfo ControlInvarianceFromBlock(const BasicBlock * BB) const;
  InvarianceInfo ControlInvarianceForBlock(const BasicBlock * BB) const;
  void updateInvariance(const llvm::Instruction * V, const InvarianceInfo& result) const;
  void updateInvariance(const llvm::GlobalVariable * GV, const InvarianceInfo& result, const BasicBlock * currentBlock) const;
  void updateInvariance(const llvm::Argument * Arg, const InvarianceInfo& result) const;
};
} // namespace <anonymous>


DataFlow::DataFlow(ThreadInvarianceImpl * var,
                   ControlDependence& dependences,
                   const OpenClAl& cl,
                   const DominatorTree& DT,
                   WorkQueue& work) : parent(var),
                                      controlDep(dependences),
                                      opencl(cl),
                                      dt(DT),
                                      queue(work) {}

DataFlow::~DataFlow() {}

void DataFlow::AnalyzeBlock(const BasicBlock * BB) {
  if (!BB) return;
  InvarianceInfo previousControlInvariance = currentControlInvariance;
  currentControlInvariance = ControlInvarianceForBlock(BB);
  visit(const_cast<BasicBlock *>(BB));
  currentControlInvariance = previousControlInvariance;
}

void DataFlow::visitInsertElementInst(llvm::InsertElementInst& IEI) {
  const Value * index = IEI.getOperand(2);
  if(llvm::isa<llvm::ConstantInt>(index)) {
    uint64_t ind = llvm::cast<llvm::ConstantInt>(index)->getZExtValue();
    InvarianceInfo insertedValue = parent->getInvariance(IEI.getOperand(1));
    InvarianceInfo result = parent->getInvariance(IEI.getOperand(0));
    result[ind]=insertedValue[0];
    updateInvariance(&IEI, result);
    return;
  }
  applyStandardRule(IEI);
}

void DataFlow::visitInstruction(llvm::Instruction& Inst) {
    InvarianceInfo result(Inst);
    result.Reset(InvarianceInfo::kMaybeNonInvariant);
    updateInvariance(&Inst, result);
}


void DataFlow::visitAllocaInst(llvm::AllocaInst& BO) {
//  if (!BO.isStaticAlloca()) llvm::errs() << "Dynamic alloc!\n";
  if (!BO.isStaticAlloca()) visitInstruction(BO);

  InvarianceInfo result(BO);
  result.Reset(InvarianceInfo::kInvariant);
  result.ResetPointer(&BO);
  updateInvariance(&BO, result);
}

void DataFlow::visitBinaryOperator(llvm::BinaryOperator& BO) {
  applyStandardRule(BO);
}

void DataFlow::visitCallInst(llvm::CallInst& CallInst) {
  llvm::Function * Called;
  Called = CallInst.getCalledFunction();
  if (Called) {
    if(opencl.IsGlobalIndex(Called)) {
      InvarianceInfo result(CallInst);
      result.Reset(InvarianceInfo::kInvariant);
      for(int axis =0; axis<3; ++axis) {
        result[axis].Set(InvarianceInfo::kDimGlobal, axis, InvarianceInfo::kNonInvariant);
        result[axis].Set(InvarianceInfo::kDimLocal, axis, InvarianceInfo::kNonInvariant);
      }
      updateInvariance(&CallInst, result);
      return;
    }
    if(opencl.IsLocalIndex(Called)) {
      InvarianceInfo result(CallInst);
      result.Reset(InvarianceInfo::kInvariant);
      for(int axis =0; axis<3; ++axis) {
        result[axis].Set(InvarianceInfo::kDimLocal, axis, InvarianceInfo::kNonInvariant);
      }
      updateInvariance(&CallInst, result);
      return;
    }
    if(opencl.IsGroupIndex(Called)) {
      InvarianceInfo result(CallInst);
      result.Reset(InvarianceInfo::kInvariant);
      for(int axis =0; axis<3; ++axis) {
        result[axis].Set(InvarianceInfo::kDimGlobal, axis, InvarianceInfo::kNonInvariant);
      }
      updateInvariance(&CallInst, result);
      return;
    }
    int axis = opencl.GetIndexAxis(&CallInst);
    if ( axis != -1) {
      InvarianceInfo::DimLevel level;
      level = opencl.IsGroupIndex(Called)?InvarianceInfo::kDimGlobal:InvarianceInfo::kDimLocal;
      InvarianceInfo result(CallInst);
      result.Reset(InvarianceInfo::kInvariant);
      result[0].Set(level, axis, InvarianceInfo::kNonInvariant);
      updateInvariance(&CallInst, result);
      return;
    }
    if(opencl.IsSafeAtomic(Called)) {
      InvarianceInfo result(CallInst);
      result.Reset(InvarianceInfo::kNonInvariant);
      updateInvariance(&CallInst, result);
      // I assume here that the first parameter is always the memory accessed.
      //if((CallInst.getNumOperands()<2) || (!isa<PointerType>(CallInst.getOperand(0)->getType())))
        //errs() << "WRONG ASSUMPTION ON ATOMIC PTR TYPE\n";
      Value * Ptr = CallInst.getOperand(0);
      // we need to obtain the basePtr of this value...
      InvarianceInfo ptrOperand = parent->getInvariance(Ptr);
      const Value * basePtr = ptrOperand[0].getBasePointer();
      InvarianceInfo newInvariance = ptrOperand;
      for(unsigned i=0; i<3; ++i) {
        newInvariance[0].Set(InvarianceInfo::kDimGlobal, i, InvarianceInfo::kNonInvariant);
      }
      if(newInvariance != ptrOperand) {
        if(const llvm::PointerType *Ptype = llvm::dyn_cast<llvm::PointerType>(basePtr->getType())) {
          if(Ptype->getAddressSpace()==OpenClAl::kMemGlobal) {
            if(const llvm::GlobalVariable * GV = llvm::dyn_cast<llvm::GlobalVariable>(basePtr)) {
              updateInvariance(GV, newInvariance, CallInst.getParent());
            } else if(const llvm::Argument * Arg=llvm::dyn_cast<llvm::Argument>(basePtr)) {
              updateInvariance(Arg, newInvariance);
            } else {
              //errs() << "Unknown type of basePtr: ";
              //basePtr->dump();
            }
          }
        }
      }

    }
    if(Called->isDeclaration()) {
      applyStandardRule(CallInst);
      return;
    }
  }
  visitInstruction(CallInst);
}

void DataFlow::visitCastInst(llvm::CastInst& CI) {
  applyStandardRule(CI);
}

void DataFlow::visitCmpInst(llvm::CmpInst& CI) {
  applyStandardRule(CI);
}

void DataFlow::visitExtractElementInst(llvm::ExtractElementInst& EEI) {
  InvarianceInfo result(EEI);
  result.Reset(InvarianceInfo::kMaybeNonInvariant);
  const InvarianceInfo& source = parent->getInvariance(EEI.getVectorOperand());
  const Value * index = EEI.getIndexOperand();
  if(llvm::isa<llvm::ConstantInt>(index)) {
    uint64_t ind = llvm::cast<llvm::ConstantInt>(index)->getZExtValue();
    //for(int axis=0; axis<3; ++axis) {
      result[0] = source[ind];
      updateInvariance(&EEI, result);
      //.Set(InvarianceInfo::kDimGlobal, axis, source[index].getInvariance(InvarianceInfo::kDimGlobal, axis));
      //result[0].Set(InvarianceInfo::kDimLocal, axis, source[index].getInvariance(InvarianceInfo::kDimGlobal, axis));
    //}
  }


}

void DataFlow::visitGetElementPtrInst(llvm::GetElementPtrInst& GEP) {
  applyStandardRule(GEP);
}

void DataFlow::visitLoadInst(llvm::LoadInst& load) {
  InvarianceInfo result(load);
  if (llvm::isa<llvm::VectorType>(load.getType())) parent->setCoarseDetected();
  //result.Reset(InvarianceInfo::kMaybeNonInvariant);
  result &= parent->getInvariance(load.getPointerOperand());
  updateInvariance(&load, result);
}

void DataFlow::visitPHINode(llvm::PHINode& phi) {
  //errs() << "ThreadInvariance: visiting phi node ";
  //phi.dump();
  InvarianceInfo result(phi);
  InvarianceInfo control(phi);
  BasicBlock * thisBlock = phi.getParent();
  unsigned nbControl =0;
  unsigned nbSkipped = 0;
  for(unsigned i=0, ie=phi.getNumIncomingValues(); i < ie; ++i) {

    BasicBlock* BB = phi.getIncomingBlock(i);
    //errs() << "Incoming variance from BB " << BB->getName() << " has variance " << parent->getInvariance(phi.getIncomingValue(i)) << "\n";
    Value* incomingValue = phi.getIncomingValue(i);

    result &= parent->getInvariance(incomingValue);
    if(isa<UndefValue>(incomingValue)) nbSkipped+=1;
    if(!dt.dominates(thisBlock, BB) && !dt.dominates(BB, thisBlock) && !isa<UndefValue>(incomingValue)) {
      control &= ControlInvarianceForBlock(BB);
    }
  }
  if(nbSkipped==0 || ((phi.getNumIncomingValues()-nbSkipped)>1)) {
    result &= control;
  }
  //errs() << "Setting invariance tpp " << result << "\n";
  updateInvariance(&phi, result);

}

void DataFlow::visitShuffleVectorInst(llvm::ShuffleVectorInst& SVI) {
  InvarianceInfo result(SVI);
  InvarianceInfo lhs = parent->getInvariance(SVI.getOperand(0));
  InvarianceInfo rhs = parent->getInvariance(SVI.getOperand(1));
  if(const llvm::ConstantVector * shuffleMask = llvm::dyn_cast<llvm::ConstantVector>(SVI.getOperand(2))) {
    unsigned nbElems = shuffleMask->getType()->getNumElements();
    for(unsigned i=0; i<nbElems; ++i) {
      if(i < shuffleMask->getNumOperands()) {
        if(llvm::ConstantInt * indexVal = llvm::dyn_cast<llvm::ConstantInt>(shuffleMask->getOperand(i))) {
          uint64_t ind = indexVal->getZExtValue();
          result[i] = (ind/rhs.getWidth()?rhs:lhs)[ind%rhs.getWidth()];
        }
      } else {
        result[i] = lhs[0];
      }
    }
  } else {
    unsigned nbElems = SVI.getType()->getNumElements();
    for(unsigned i=0; i<nbElems; ++i) {
      result[i] = lhs[0];
    }
  }
  updateInvariance(&SVI, result);

}

void DataFlow::visitSelectInst(llvm::SelectInst& SI) {
  applyStandardRule(SI);

}

void DataFlow::visitStoreInst(llvm::StoreInst& SI) {
  InvarianceInfo result(SI);
  InvarianceInfo ptrOperand = parent->getInvariance(SI.getOperand(1));
  InvarianceInfo valueOperand = parent->getInvariance(SI.getOperand(0));
  if(llvm::isa<llvm::VectorType>(SI.getType())) parent->setCoarseDetected();
  const Value * basePtr = ptrOperand[0].getBasePointer();
  if(!basePtr) {
    //llvm::errs() << "Warning! lost base ptr!\n";
    //abort();
  }
  result &= ptrOperand;
  result &= valueOperand;
  updateInvariance(&SI, result);
  if (basePtr) {

    InvarianceInfo baseInv = parent->getInvariance(basePtr);
    if(const llvm::PointerType * Ptype = llvm::dyn_cast<llvm::PointerType>(basePtr->getType())) {
      unsigned addrSpace = cast<PointerType>(SI.getOperand(1)->getType())->getAddressSpace();
      switch(addrSpace) {
        case OpenClAl::kMemPrivate:
          {

           if(const llvm::AllocaInst * inst = llvm::dyn_cast<llvm::AllocaInst>(basePtr)) {
             result &= parent->getInvariance(inst);
             updateInvariance(inst, result);
           } else if(const llvm::Argument * arg=llvm::dyn_cast<llvm::Argument>(basePtr)) {
		         updateInvariance(arg, result);
           } else {
         /*     llvm::errs() << "BASE POINTER IS NOT AN ALLOCA!\n";
              llvm::errs() << "While trying to set invariance of "; SI.dump(); errs() << " to " << result << "\n";
              SI.getParent()->getParent()->dump();

              abort();*/
           }
          }
           break;
        case OpenClAl::kMemLocal:
          {
            // We only need to look at the global axis.

            InvarianceInfo newInv = baseInv;
            for(unsigned i=0; i<3; ++i) {
              newInv[0].Set(InvarianceInfo::kDimGlobal, i, result[0].getInvariance(InvarianceInfo::kDimGlobal, i));
            }
            if(newInv != baseInv) {
                if(const llvm::GlobalVariable * GV=llvm::dyn_cast<llvm::GlobalVariable>(basePtr)) {
                  updateInvariance(GV, newInv, SI.getParent());
                } else if(const llvm::Argument * Arg=llvm::dyn_cast<llvm::Argument>(basePtr)) {
                  updateInvariance(Arg, newInv);
                } else {
/*
                  llvm::errs() << "While working on "; SI.dump();
                  llvm::errs() << "Unknown basePtr: ";
                  basePtr->dump();
                  abort();*/
                }
            }
          }
        default:
          break;
      }
    }
    //if(baseInv != result) updateInvariance(basePtr, result&baseInv);
  }
}

void DataFlow::visitBranchInst(llvm::BranchInst& BI) {
  // Find condition of this branch
  InvarianceInfo result(BI);

  if (BI.isConditional()) {
    InvarianceInfo cond = parent->getInvariance(BI.getOperand(0));
    result |= cond;
  }

  updateInvariance(&BI, result);
}

void DataFlow::applyStandardRule(llvm::Instruction& Inst) {
  InvarianceInfo result(Inst);
  typedef llvm::User::op_iterator u_iterator;
  u_iterator O = Inst.op_begin();
  for (u_iterator  Oe = Inst.op_end(); O != Oe; ++O) {
    result &= parent->getInvariance(&**O);
  }
  //errs() << "Applying standard rule on "; Inst.dump();
  //errs() << "base ptr, when relevant, is: ";
  //for(unsigned i=0; i<result.getWidth(); ++i) {
  //  if(result[i].getBasePointer()) result[i].getBasePointer()->dump(); else errs() << "<NULL>\n";
  //}
  updateInvariance(&Inst, result);
}

InvarianceInfo DataFlow::ControlInvarianceFromBlock(const BasicBlock *BB) const {
  const TerminatorInst * inst = BB->getTerminator();
  const BranchInst * BI;
  if((BI=dyn_cast<BranchInst>(inst)) && BI->isConditional()) return parent->getInvariance(BI->getCondition());

  return parent->getInvariance(inst);
}

InvarianceInfo DataFlow::ControlInvarianceForBlock(const BasicBlock * BB) const {
  //errs() << "Computing control invariance for block " << BB->getName() << "\n";
  InvarianceInfo result(1);
  result.Reset(InvarianceInfo::kInvariant);
  typedef ControlDependence::BlockSet::const_iterator c_iterator;
  const ControlDependence::BlockSet * blocks = controlDep.getInputDependence(BB);
  for (c_iterator B = blocks->begin(), Be = blocks->end(); B != Be; ++B) {
      //errs() << " need to get control invariance from block " << (*B)->getName() << "\n";
      result &= ControlInvarianceFromBlock(*B);
  }
  return result;
}

void DataFlow::updateInvariance(const llvm::Argument *Arg, const InvarianceInfo& result) const {

  InvarianceInfo original = parent->getInvariance(Arg);
  InvarianceInfo actualInvariance = original & result;
  if (original == actualInvariance) return;

  parent->updateInvariance(Arg, actualInvariance);
  typedef Value::const_use_iterator u_iterator;

  typedef ControlDependence::BlockSet BlockSet;
  BlockSet blocks;

  for(u_iterator U=Arg->use_begin(), Ue=Arg->use_end(); U!=Ue; ++U) {
    const BasicBlock * container;
    if(const llvm::Instruction *I = llvm::dyn_cast<llvm::Instruction>(*U)) {
      container = I->getParent();
      if(!container) continue;
      blocks.insert((llvm::BasicBlock*) container);
    }
  }

  typedef BlockSet::iterator b_iterator;
  for (b_iterator B = blocks.begin(), Be = blocks.end(); B != Be; ++B) {
    WorkQueue::iterator I=queue.begin();
    for(WorkQueue::iterator  Ie=queue.end(); I!=Ie; ++I) {
	if(*I==*B) break;
    }
    if(I==queue.end()) {
      queue.push_back(*B);
    }
  }

}


void DataFlow::updateInvariance(const llvm::GlobalVariable *GV, const InvarianceInfo& result, const BasicBlock* currentBlock) const {

  InvarianceInfo original = parent->getInvariance(GV);
  if (original == result) return;
  parent->updateInvariance(GV, result);
  typedef Value::const_use_iterator u_iterator;

  typedef ControlDependence::BlockSet BlockSet;
  BlockSet blocks;

  for(u_iterator U=GV->use_begin(), Ue=GV->use_end(); U!=Ue; ++U) {
    const BasicBlock * container;
    if(const llvm::Instruction *I = llvm::dyn_cast<llvm::Instruction>(*U)) {
      container = I->getParent();
      if(!container) continue;
      if(container->getParent() != currentBlock->getParent()) continue;
      blocks.insert((llvm::BasicBlock*) container);
    }
  }

  typedef BlockSet::iterator b_iterator;
  for (b_iterator B = blocks.begin(), Be = blocks.end(); B != Be; ++B) {
    WorkQueue::iterator I=queue.begin();
    for(WorkQueue::iterator  Ie=queue.end(); I!=Ie; ++I) {
	if(*I==*B) break;
    }
    if(I==queue.end()) {
      queue.push_back(*B);
    }
  }

}

void DataFlow::updateInvariance(const llvm::Instruction *V, const InvarianceInfo& result) const {

  InvarianceInfo original = parent->getInvariance(V);
  if ( original == result ) return;

  //errs() << "Updating invariance of ";
  //V->dump(); errs() << "   to " << result << "\n" << "from " << original << "\n";
  parent->updateInvariance(V, result);
  typedef ControlDependence::BlockSet BlockSet;
  typedef Value::const_use_iterator u_iterator;
  BlockSet blocks;
  const BasicBlock * currentBlock = V->getParent();
  if (!currentBlock) return;

  for(u_iterator U=V->use_begin(), Ue=V->use_end(); U != Ue; ++U) {

    const BasicBlock * container;
    if(const llvm::Instruction * I = llvm::dyn_cast<llvm::Instruction>(*U)) {
      container = I->getParent();
      if ( !container ) continue;
      if ( container == currentBlock ) {
        if (!llvm::isa<llvm::PHINode>(I)) continue;
      }
      blocks.insert((llvm::BasicBlock*) container);
    }
  }

  if(const TerminatorInst * term = llvm::dyn_cast<TerminatorInst>(V)) {
    const BlockSet * outDependences = controlDep.getOutputDependence(term);
    blocks.insert(outDependences->begin(), outDependences->end());

    typedef ControlDependence::BlockSet::const_iterator c_iterator;
    for (c_iterator B = outDependences->begin(), Be = outDependences->end(); B != Be; ++B) {
      InvarianceInfo invB = parent->getInvariance(*B);
      invB &= result;
      parent->updateInvariance(*B, invB);
    }
  }
  typedef BlockSet::iterator b_iterator;
  for (b_iterator B = blocks.begin(), Be = blocks.end(); B != Be; ++B) {
    WorkQueue::iterator I=queue.begin();
    for(WorkQueue::iterator  Ie=queue.end(); I!=Ie; ++I) {
	if(*I==*B) break;
    }
    if(I==queue.end()) {
      queue.push_back(*B);
    }
  }

}

namespace SpmdKernel {
namespace Coarsening {
bool ThreadInvarianceImpl::alreadyCoarsed() const {
  return coarseDetected;
}

void ThreadInvarianceImpl::setCoarseDetected() {
  coarseDetected = true;
}

bool ThreadInvarianceImpl::Build(Function& F, ControlDependence& CD, const OpenClAl& opencl, const DominatorTree& DT) {  // NOLINT
  typedef std::deque<const BasicBlock *> WorkQueue;
  InitializeMap(F, opencl);
  WorkQueue work;
  for (Function::iterator B = F.begin(), Be = F.end(); B != Be; ++B) {
    work.push_back(B);
  }
  DataFlow dataFlow(this, CD, opencl, DT, work);
  while (!work.empty()) {
    const BasicBlock * next = work.front();
    //errs() << work.size() << " remaining blocks!\n";
    work.pop_front();
    dataFlow.AnalyzeBlock(next);
  }
  return false;
}

InvarianceInfo ThreadInvarianceImpl::getInvariance(const Value * V) const {
  InvarianceMap::const_iterator found = variances.find(V);
  if (found == variances.end()) {
    if( isa<Constant>(V)) {
      InvarianceInfo result(*V);
      result.Reset(InvarianceInfo::kInvariant);
      if(isa<PointerType>(V->getType())) {
        if(isa<llvm::ConstantExpr>(V)) {
          result = getInvariance(cast<ConstantExpr>(V)->getOperand(0));
          result.ResetPointer(cast<ConstantExpr>(V)->getOperand(0));
        } else
        result.ResetPointer(V);
      }
      return result;
    }

    return InvarianceInfo(*V);
  }
  return found->second;
}

ThreadInvarianceImpl::iterator ThreadInvarianceImpl::begin() const {
  return globalInvariances.begin();
}

ThreadInvarianceImpl::iterator ThreadInvarianceImpl::end() const {
  return globalInvariances.end();
}

void ThreadInvarianceImpl::updateInvariance(const Value *V,
                                        const InvarianceInfo& result) {
  InvarianceInfo current = getInvariance(V);
  if (current == result) return;
  if(const GlobalVariable * GV=dyn_cast<GlobalVariable>(V)) {
    globalInvariances.insert(const_cast<GlobalVariable *>(GV));
  }
  InvarianceMap::iterator found = variances.find(V);
  if (found == variances.end()) {
    variances.insert(std::make_pair(V, result));
  } else {
    found->second = result;
  }
}

void ThreadInvarianceImpl::InitializeMap(Function &F, const OpenClAl& opencl) { // NOLINT
  bool kernel = opencl.IsThisFunctionAKernel(&F);

  typedef Function::const_arg_iterator iterator;
  for (iterator A = F.arg_begin(), Ae = F.arg_end(); A != Ae; ++A) {
    InvarianceInfo result(*A);
    result.Reset(InvarianceInfo::kMaybeNonInvariant);
    if (kernel) {
      result.Reset(InvarianceInfo::kInvariant);
    }
    if(isa<PointerType>(A->getType())) {
      result.ResetPointer(A);
    }

    updateInvariance(A, result);
  }

}

ScalarInvarianceInfo::ScalarInvarianceInfo() : basePtr(NULL) {
  Reset(InvarianceInfo::kUnknown);
}

bool ScalarInvarianceInfo::operator!=(const ScalarInvarianceInfo& other) const {
  for (unsigned i = 0; i < InvarianceInfo::kDimMax; ++i) {
    for (unsigned j = 0; j < MaxAxis; ++j) {
      if (Invariances[i][j] != other.Invariances[i][j])
        return true;
    }
  }
  //if(basePtr != other.basePtr) return true;
  return false;
}

bool ScalarInvarianceInfo::operator==(const ScalarInvarianceInfo& other) const {
  return ! (this->operator!=(other));
}

ScalarInvarianceInfo& ScalarInvarianceInfo::operator|=(const ScalarInvarianceInfo& other) {
  for (unsigned i = 0; i < InvarianceInfo::kDimMax; ++i) {
    for (unsigned j = 0; j < MaxAxis; ++j) {
      Invariances[i][j] = join(Invariances[i][j], other.Invariances[i][j]);
    }
  }
  if(basePtr && other.basePtr && (basePtr != other.basePtr)) {
//	errs() << "Warning: mixing multiple base ptr!\n";
//        abort();
  }
  if(!basePtr && other.basePtr) basePtr = other.basePtr;
  return *this;
}

const ScalarInvarianceInfo ScalarInvarianceInfo::operator|(
    const ScalarInvarianceInfo& other) const {
  ScalarInvarianceInfo result(*this);
  return result|=(other);
}

ScalarInvarianceInfo& ScalarInvarianceInfo::operator&=(const ScalarInvarianceInfo& other) {
  for (unsigned i = 0; i < InvarianceInfo::kDimMax; ++i) {
    for (unsigned j = 0; j < MaxAxis; ++j) {
      Invariances[i][j] = meet(Invariances[i][j], other.Invariances[i][j]);
    }
  }
  if(basePtr && other.basePtr && (basePtr != other.basePtr)) {
//	errs() << "Warning: mixing multiple base ptr!\n";
//        abort();
  }
  if(!basePtr && other.basePtr) basePtr =  other.basePtr;
  return *this;
}

const ScalarInvarianceInfo ScalarInvarianceInfo::operator&(
    const ScalarInvarianceInfo& other) const {
  ScalarInvarianceInfo result(*this);
  return result&=(other);
}

typedef ScalarInvarianceInfo::InvarianceKind InvarianceKind;

const InvarianceKind ScalarInvarianceInfo::getInvariance(DimLevel level,
                                               unsigned axis) const {
  if ( axis >= MaxAxis || level >= InvarianceInfo::kDimMax )
    return InvarianceInfo::kInvariant;
  return Invariances[level][axis];
}

void ScalarInvarianceInfo::Reset(const InvarianceKind& value) {
  Set(InvarianceInfo::kDimMax, MaxAxis, value);
}


void ScalarInvarianceInfo::Set(const DimLevel& level, unsigned axis,
                         const InvarianceKind& val) {

  unsigned start_axis, end_axis;
  if ( axis < MaxAxis ) {
    start_axis = axis;
    end_axis = axis+1;
  } else {
    start_axis = 0;
    end_axis = MaxAxis;
  }
  unsigned start_level, end_level;
  if ( level < InvarianceInfo::kDimMax ) {
    start_level = level;
    end_level = level + 1;
  } else {
    start_level = InvarianceInfo::kDimLocal;
    end_level = InvarianceInfo::kDimMax;
  }

  for  (unsigned i = start_level; i < end_level; ++i) {
    for (unsigned j = start_axis; j < end_axis; ++j) {
      Invariances[i][j]= val;
    }
  }

}

void ScalarInvarianceInfo::setBasePointer(const Value * V) {
  if(((intptr_t)V) % 4) {
    errs() << "Invalid base pointer!\n";
    abort();
  }
  basePtr = V;
}

const Value * ScalarInvarianceInfo::getBasePointer() const {
  return basePtr;
}

raw_ostream& ScalarInvarianceInfo::print(raw_ostream& OS) const {
  for (unsigned i=0; i<InvarianceInfo::kDimMax; ++i) {
    for (unsigned j=0; j<MaxAxis; ++j) {
      switch(Invariances[i][j]) {
        case InvarianceInfo::kInvariant:
          OS << "I";
          break;
        case InvarianceInfo::kNonInvariant:
          OS << "V";
          break;
        case InvarianceInfo::kMaybeNonInvariant:
          OS << "M";
          break;
        case InvarianceInfo::kUnknown:
          OS << "?";
          break;
      }
    }
    OS << "/";
  }
  //if(basePtr) OS << "BasePtr(" << basePtr->getName() << ")";
  if(basePtr) OS << "BasePtr(" << *basePtr << ")";
  return OS;
}

InvarianceInfo::InvarianceInfo() : width(0), values(NULL) {}

InvarianceInfo::InvarianceInfo(unsigned int w) : width(w), values(NULL) {
  if(width) values = new ScalarInvarianceInfo[width];
}

InvarianceInfo::InvarianceInfo(const Value& val) : width(0), values(NULL) {
  if(const VectorType  * type = dyn_cast<VectorType>(val.getType())) {
    width =  type->getNumElements();
  } else {
    width = 1;
  }
  values = new ScalarInvarianceInfo[width];
}

InvarianceInfo::InvarianceInfo(const InvarianceInfo& other) : width(0), values(NULL) {
  width = other.width;
  if ( width ) {
    values = new ScalarInvarianceInfo[width];
    for ( unsigned val = 0; val < width; ++val) {
      values[val] = other[val];
    }
  }
}

InvarianceInfo::~InvarianceInfo() {
  if (values)
    delete [] values;
}

ScalarInvarianceInfo& InvarianceInfo::operator[](unsigned int val) {
  assert(val < width && "Index out of range\n");
  return values[val];
}

const ScalarInvarianceInfo& InvarianceInfo::operator[](unsigned int val) const {
  assert(val < width && "Index out of range\n");
  return values[val];
}

bool InvarianceInfo::operator!=(const InvarianceInfo& other) const {
  if ( width != other.width ) return true;
  for (unsigned int val=0; val < width; ++ val) {
    if (values[val] != other.values[val]) return true;
  }
  return false;
}

bool InvarianceInfo::operator==(const InvarianceInfo& other) const {
  return !(this->operator!=(other));
}

InvarianceInfo& InvarianceInfo::operator=(const InvarianceInfo& other) {
  if (values) {
    delete [] values;
    values = NULL;
  }
  width = other.width;
  if (width) {
    values = new ScalarInvarianceInfo[width];
    for ( unsigned val = 0; val < width; ++val) {
      values[val] = other[val];
    }
  }
  return *this;
}

InvarianceInfo& InvarianceInfo::operator|=(const InvarianceInfo& other) {
  assert (width == other.width && "Size mismatch");
  if ( width != other.width ) return *this;
  for (unsigned val = 0; val < width; ++val) {
    values[val] |= other[val];
  }
  return *this;
}

const InvarianceInfo InvarianceInfo::operator|(const InvarianceInfo& other) const {
  InvarianceInfo result(*this);
  result |= other;
  return result;
}

InvarianceInfo& InvarianceInfo::operator&=(const InvarianceInfo& other) {
  //assert (width == other.width && "Size mismatch");
  //if ( width != other.width ) return *this;
  if(width == other.width) {
    for (unsigned val = 0; val < width; ++val) {
      values[val] &= other[val];
    }
  } else if (width == 1) {
    for (unsigned val = 0; val < width; ++val) {
      values[0] &= other[val];
    }
  } else if (other.width == 1) {
    for (unsigned val = 0; val < width; ++val) {
      values[val] &= other[0];
    }
  }
  return *this;
}

const InvarianceInfo InvarianceInfo::operator&(const InvarianceInfo& other) const {
  InvarianceInfo result(*this);
  result &= other;
  return result;
}

void InvarianceInfo::Reset(const InvarianceKind& kind) {
  for (unsigned val = 0; val < width; ++val) {
    values[val].Reset(kind);
  }
}

int InvarianceInfo::getWidth() const {
  return width;
}

void InvarianceInfo::ResetPointer(const Value * V) {
  for (unsigned val = 0; val < width; ++val) {
    values[val].setBasePointer(V);
  }
}

raw_ostream& InvarianceInfo::print(raw_ostream& out) const {
  out << "(";
  bool first = true;
  for (unsigned val = 0; val < width; ++val) {
    if (!first) out << ",";
    else first = false;
    out << values[val];
  }
  out << ")";
  return out;
}

/** \brief Static initialization of ThreadInvariance class member ID.
    Set to 0 to mark as initially not registered
*/
char ThreadInvariance::ID = 0;
/** \brief Registration of the ThreadInvariance analysis.
    This will set the ThreadInvariance class member ID to a uniq value
*/
static RegisterPass<ThreadInvariance> 
  X("thread-invariance", 
    "Identify to which local/global ids a value is dependent on", false, true);

ThreadInvariance::ThreadInvariance() : FunctionPass(ID), Impl(NULL) {
    //initializeThreadInvariancePass(*PassRegistry::getPassRegistry());
}

ThreadInvariance::~ThreadInvariance() {
  if (Impl) delete Impl;
}

void ThreadInvariance::getAnalysisUsage(AnalysisUsage& AU) const { // NOLINT
  AU.addRequired<OpenClAl>();
  AU.addRequired<ControlDependence>();
  AU.addRequired<DominatorTree>();
  AU.setPreservesAll();
}

bool ThreadInvariance::runOnFunction(Function& F) { // NOLINT
//  errs() << "Starting TI\n";
  if (Impl) {
    delete Impl;
  }
  Impl = new ThreadInvarianceImpl;
  ControlDependence& CD = getAnalysis<ControlDependence>();
  OpenClAl& OpenCl = getAnalysis<OpenClAl>();
  DominatorTree& DT = getAnalysis<DominatorTree>();
  bool result =  Impl->Build(F, CD, OpenCl, DT);

  // Jiading GAI
  for (Function::iterator BI = F.begin(), BE = F.end(); BI != BE; ++BI) {
    BasicBlock &BB = *BI;
    for (BasicBlock::iterator II = BB.begin(), IE = BB.end(); II != IE; ++II) {
      Instruction *Inst = &*II;
      errs() << "[" << *Inst << "] : \n";
      InvarianceInfo IvInfo = Impl->getInvariance(Inst);
      IvInfo.print(errs());
      errs() << "----> \n\n\n";
    }
  }
    

//  errs() << "End of TI\n";
  return result;
}

InvarianceInfo ThreadInvariance::getInvariance(const Value * V) const {
  assert(V && "Value is NULL");
  InvarianceInfo deflt;
  if (!V) return deflt;
  return Impl->getInvariance(V);
}

bool ThreadInvariance::hasGlobalInvariance() const {
  return Impl->begin() != Impl->end();
}

bool ThreadInvariance::alreadyCoarsed() const {
  return Impl->alreadyCoarsed();
}

ThreadInvariance::global_iterator ThreadInvariance::begin()  const {
  return Impl->begin();
}

ThreadInvariance::global_iterator ThreadInvariance::end()  const {
  return Impl->end();
}


}
}  // namespace llvm
