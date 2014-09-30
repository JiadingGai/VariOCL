/** \file lib/Analysis/OpenClAl.cpp
    \brief Implements Opencl Abstraction Layer Analysis Pass */
// TODO(matthieu): Add copyright/license here


#include "OpenClAl.h"
#include "llvm/IR/Attributes.h"

#include <string>

//#include "llvm/Analysis/MCWPasses.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Function.h"
//#include "llvm/MCWInitializePasses.h"
#include "llvm/IR/Module.h"

#include "llvm/PassRegistry.h"
#include "llvm/PassSupport.h"
#include "llvm/Support/raw_ostream.h"

namespace {
bool getAPIntFromCall(const llvm::CallInst& CI, unsigned arg, const llvm::APInt *& val) {
  llvm::Value * idAsValue = CI.getOperand(arg);
  if (!idAsValue) return false;
  llvm::ConstantInt * idAsConstant = llvm::dyn_cast<llvm::ConstantInt>(idAsValue);
  if (!idAsConstant) return false;
  val= &idAsConstant->getValue();
  return true;
}

const SpmdKernel::Coarsening::OpenClAl::WIMap initializeWIFunctionMap() {
  SpmdKernel::Coarsening::OpenClAl::WIMap result;
  result.insert(std::make_pair("__amdil_get_work_dim_int", SpmdKernel::Coarsening::OpenClAl::kWIWorkDim));
  result.insert(std::make_pair("__amdil_get_global_size_int", SpmdKernel::Coarsening::OpenClAl::kWIGlobalSize));
  result.insert(std::make_pair("__amdil_get_global_id_int", SpmdKernel::Coarsening::OpenClAl::kWIGlobalId));
  result.insert(std::make_pair("__amdil_get_local_size_int", SpmdKernel::Coarsening::OpenClAl::kWILocalSize));
  result.insert(std::make_pair("__amdil_get_local_id_int", SpmdKernel::Coarsening::OpenClAl::kWILocalId));
  result.insert(std::make_pair("__amdil_get_num_groups_int", SpmdKernel::Coarsening::OpenClAl::kWINumGroups));
  result.insert(std::make_pair("__amdil_get_group_id_int", SpmdKernel::Coarsening::OpenClAl::kWIGroupId));
  result.insert(std::make_pair("__amdil_get_global_offset_int", SpmdKernel::Coarsening::OpenClAl::kWIGlobalOffset));
  return result;

}

const SpmdKernel::Coarsening::OpenClAl::FuncSet initializeMathSet() {
  SpmdKernel::Coarsening::OpenClAl::FuncSet result;
  result.insert("__amdil_cmov_logical_v4i32");
  result.insert("__amdil_div_v4f32");
  result.insert("__amdil_fabs_f32");
  result.insert("__amdil_fabs_v4f32");
  result.insert("__amdil_mad_f32");
  result.insert("__amdil_mad_v4f32");
  result.insert("__amdil_sqrt_vec_f32");
  result.insert("__amdil_sqrt_vec_v4f32");
  result.insert("__amdil_umad_u32");
  result.insert("__amdil_umul_high_u32");
  result.insert("__fma_f32");
  return result;
}

const SpmdKernel::Coarsening::OpenClAl::FuncSet initializeSafeAtom() {
  SpmdKernel::Coarsening::OpenClAl::FuncSet result;
  result.insert("__atom_inc_lu32");
  result.insert("__atom_add_gi32");
  result.insert("__atom_min_gu32");
  result.insert("__atom_max_gu32");
  return result;
}

const SpmdKernel::Coarsening::OpenClAl::FuncSet initializeLogicalSet() {
  SpmdKernel::Coarsening::OpenClAl::FuncSet result;
  result.insert("__amdil_bitalign_i32");
  result.insert("__amdil_cmov_logical");
  result.insert("__amdil_cmov_logical_i32");
  result.insert("__amdil_ffb_hi_u32");
  return result;
}

}


namespace SpmdKernel {
namespace Coarsening {

using namespace llvm;

/** \brief Static initialization of OpenClAl class member ID.
    Set to 0 to mark as initially not registered
*/
char OpenClAl::ID = 0;
/** \brief Registration of the OpenClAl analysis.
    This will set the OpenClAl class member ID to a uniq value
*/
//INITIALIZE_PASS(OpenClAl, "opencl-al",
//                "OpenCl Abstraction Layer", false, true);
static RegisterPass<OpenClAl> X("opencl-al", "OpenCl Abstract Layer", false, true);

const OpenClAl::WIMap OpenClAl::WIFunctionMap=initializeWIFunctionMap();

const OpenClAl::FuncSet OpenClAl::MathSet=initializeMathSet();

const OpenClAl::FuncSet OpenClAl::LogicalSet=initializeLogicalSet();

const OpenClAl::FuncSet OpenClAl::SafeAtom=initializeSafeAtom();



//namespace llvm {
//ImmutablePass *createOpenClAlPass() { return new OpenClAl; }
//}

OpenClAl::OpenClAl() : ImmutablePass(ID) {
}

bool OpenClAl::IsThisFunctionAKernel(const Function * F) const {
  // This is a weak test. So far kernel names ends with the "_kernel" suffix.
  // this break as soon as a non-kernel function ends with a "_kernel_ suffix.
  // A more solid test is to check fromn the metadata informations.
  if (!F || F->isDeclaration()) return false;
  const std::string suffix("_kernel");
  const std::string& fName = F->getName();

  if (fName.length() < suffix.length()) return 0;
  size_t startPos = fName.length() - suffix.length();

  return !(fName.substr(startPos, std::string::npos).compare(suffix));
}

bool OpenClAl::IsThisFunctionAStub(const Function * F) const {
  if (!F || F->isDeclaration()) return false;
  const std::string suffix("_stub");
  const std::string& fName = F->getName();

  if (fName.length() < suffix.length()) return 0;
  size_t startPos = fName.length() - suffix.length();

  return !(fName.substr(startPos, std::string::npos).compare(suffix));
}

// TODO(matthieu): factorize the code for the following three functions

OpenClAl::WIFunctions OpenClAl::TypeOfWorkItemFunction(const Function * F) {
  if(!F || !F->isDeclaration()) return kWIUnknown;
  WIMap::const_iterator found = WIFunctionMap.find(F->getName());
  if (found == WIFunctionMap.end()) return kWIUnknown;
  return found->second;
}

bool OpenClAl::IsGroupIndex(const Function *F) const {
  return TypeOfWorkItemFunction(F)==kWIGroupId;
}

bool OpenClAl::IsLocalIndex(const Function *F) const {
  return TypeOfWorkItemFunction(F)==kWILocalId;
}

bool OpenClAl::IsGlobalIndex(const Function *F) const {
  return TypeOfWorkItemFunction(F)==kWIGlobalId;
}

bool OpenClAl::IsLocalSize(const Function *F) const {
  return TypeOfWorkItemFunction(F)==kWILocalSize;
}

bool OpenClAl::IsGlobalSize(const Function *F) const {
  return TypeOfWorkItemFunction(F)==kWIGlobalSize;
}


bool OpenClAl::IsNumGroup(const Function *F) const {
  return TypeOfWorkItemFunction(F)==kWINumGroups;
}

bool OpenClAl::IsMathFunc(const Function *F) const {
  FuncSet::const_iterator found = MathSet.find(F->getName());
  return found != MathSet.end();
}

bool OpenClAl::IsLogicalFunc(const Function *F) const {
  FuncSet::const_iterator found = LogicalSet.find(F->getName());
  return found != LogicalSet.end();
}

bool OpenClAl::IsSafeAtomic(const Function *F) const {
  if (!F) return false;
  FuncSet::const_iterator found = SafeAtom.find(F->getName());
  return found != SafeAtom.end();
}

Function * OpenClAl::getWIFunction(Module& M, WIFunctions F) {
  std::string funcName;
  switch(F) {
    case kWIWorkDim:
      funcName="__amdil_get_work_dim_int";
    break;
    case kWIGlobalSize:
      funcName="__amdil_get_global_size_int";
    break;
    case kWIGlobalId:
      funcName="__amdil_get_global_id_int";
    break;
    case kWILocalSize:
      funcName="__amdil_get_local_size_int";
    break;
    case kWILocalId:
      funcName="__amdil_get_local_id_int";
    break;
    case kWINumGroups:
      funcName="__amdil_get_num_groups_int";
    break;
    case kWIGroupId:
      funcName="__amdil_get_group_id_int";
    break;
    case kWIGlobalOffset:
      funcName="__amdil_get_global_offset_int";
    break;
    default:
    return NULL;
  }

  return M.getFunction(funcName);


}

int OpenClAl::GetIndexAxis(const CallInst* CI) const {
  Function * Called = CI->getCalledFunction();
  if (!Called) return -1;
  if (!(IsGroupIndex(Called) || IsLocalIndex(Called))) return -1;
  const APInt* val;
  if (!getAPIntFromCall(*CI, 0, val)) return -1;
  return val->getSExtValue();

}

bool OpenClAl::IsBarrier(const Function *F) const {
  if (!F ||!F->isDeclaration()) return false;
  const std::string funcName("barrier");
  return !F->getName().compare(funcName);
}

OpenClAl::MemClass OpenClAl::GetReferencedMemory(
    const PointerType * pType) const {
  if (!pType) return kInvalid;
  // Note: casting unsigned values to enum type is
  //       undefined behavior even though
  //       it usually works well. We will stick to
  //       the most portable code.
  switch (pType->getAddressSpace()) {
    case 0:
      return kMemPrivate;
      break;
    case 1:
      return kMemGlobal;
      break;
    case 2:
      return kMemConstant;
      break;
    case 3:
      return kMemLocal;
      break;
    default:
      return kMemUnknown;
  }
}

OpenClAl::MemClass OpenClAl::GetReferencedMemory(const Type * type) const {
  if (!type || !type->isPointerTy()) return kInvalid;
  return GetReferencedMemory(cast<const PointerType>(type));
}

bool OpenClAl::IsPointerToMemClass(const PointerType* pType,
                                   const MemClass& kind) const {
  if ((kind == kInvalid) || !(pType)) return false;
  if ((unsigned)kind == pType->getAddressSpace()) return true;
  if ((pType->getAddressSpace() >= kInvalid) && (kind == kMemUnknown))
    return true;
  return false;
}

bool OpenClAl::IsPointerToMemClass(const Type * type,
                                   const MemClass& kind) const {
  if (!type || !type->isPointerTy()) return false;
  return IsPointerToMemClass(cast<const PointerType>(type), kind);
}

bool OpenClAl::IsAtomicOperation(Function * F) const {
  if(!strncmp(F->getName().data(), "__atom", 6)) return true;
  return false;
}

void OpenClAl::createKernelList(Module& M) {
  // clear KernelList first
  KernelList.clear();

  GlobalVariable * gv = M.getGlobalVariable("llvm.global.annotations");
  if (!gv || !gv->hasInitializer()) return;
  ConstantArray * initial = cast<ConstantArray>(gv->getInitializer());
  size_t arraySize = initial->getType()->getNumElements();

  for(size_t i=0; i<arraySize; ++i) {
    KernelList.push_back(Kernel(i,
    cast<Function>(cast<ConstantArray>(initial->getOperand(i))->getOperand(0)->getOperand(0))));
  }
}

bool OpenClAl::isCPUTarget(Module& M) const {
  if (KernelList.empty()) return false;

  // take the first kernel and then check if the stub exist for this kernel
  Kernel K = *KernelList.begin();
  std::string FirstKernelName = K.F->getName();
  FirstKernelName = FirstKernelName.substr(0, FirstKernelName.length() - strlen("_kernel"));

  for (Module::iterator It = M.begin(); It != M.end(); ++It) {
    Function* F = It;
    if (IsThisFunctionAStub(F)) {
      std::string Name = F->getName();

      Name = Name.substr(0, Name.length() - strlen("_stub"));
      if (FirstKernelName.compare(Name) == 0)
        return true;
    }
  }

  return false;
}

bool OpenClAl::runOnModule(Module& M) { // NOLINT
  createKernelList(M);

  return false;
}

size_t OpenClAl::findKernel(Function* F) const {
  for ( std::list<Kernel>::const_iterator It = KernelList.begin(); It != KernelList.end(); ++It ) {
    if (It->F == F) return It->index;
  }
  return -1;
}

void OpenClAl::kernelChanged(Module& M) {
#ifdef _DEBUG
  llvm::errs()<<"OpenClAl::kernelChanged(), recreate kernel list\n";
#endif
  createKernelList(M);
}

bool OpenClAl::addMissingWIFunctionDeclarations(Module& M) const {
  bool changed = false;
  IntegerType * baseType = getModuleTarget(M)==kTargetCPU64?Type::getInt64Ty(M.getContext()):Type::getInt32Ty(M.getContext());
  VectorType * resultType = VectorType::get(baseType, 4);
  IntegerType * resultType2 = baseType;
  FunctionType * fType = FunctionType::get(resultType, false);
  std::vector<llvm::Type*> barrierParams;
  barrierParams.push_back(Type::getInt32Ty(M.getContext()));
  FunctionType * barrierType = FunctionType::get(Type::getVoidTy(M.getContext()), barrierParams, false);
  for(WIMap::const_iterator F=WIFunctionMap.begin(), Fe=WIFunctionMap.end(); F!=Fe; ++F) {
    if(!M.getFunction(F->first)) {
      if (F->second == kWIWorkDim) {
        M.getOrInsertFunction(F->first, resultType2, NULL);
      }
      else
      M.getOrInsertFunction(F->first, fType);
      changed = true;

    }
  }
  if(!M.getFunction("barrier")) {
    M.getOrInsertFunction("barrier", barrierType);
  }


  return changed;

}

static llvm::Attribute::AttrKind getRTAttribute(Module& M) {
	for(Module::iterator F=M.begin(), Fe=M.end(); F!=Fe; ++F) {
		if(F->isDeclaration()) {
			if(F->hasFnAttribute(llvm::Attribute::ReadNone)) return llvm::Attribute::ReadNone;
			if(F->hasFnAttribute(llvm::Attribute::ReadOnly)) return llvm::Attribute::ReadOnly;
		}
	}
	return llvm::Attribute::ReadNone;
}

Function * OpenClAl::getMad(Module& M, Type * T) {
  if(getModuleTarget(M)!=kTargetGPU) return NULL;

  std::string name;
  if(T->isFloatTy()) {
    name="__amdil_mad_f32";
  } else if(const VectorType * V=dyn_cast<VectorType>(T)) {
    if ((V->getNumElements() == 4) && (V->getElementType()->isFloatTy())) {
      name="__amdil_mad_v4f32";
    }
  }
  if(!name.size()) return NULL;
  Function * result = M.getFunction(name);
  if(result) return result;
  std::vector<Type *> params;
  params.push_back(T);
  params.push_back(T);
  params.push_back(T);
  FunctionType * FT = FunctionType::get(T, ArrayRef<Type *>(params), false);
  result = Function::Create(FT, GlobalValue::ExternalLinkage, name, &M);
  
  result->addFnAttr(llvm::Attribute::NoUnwind);
//  result->addFnAttr(llvm::Attribute::ReadOnly);
  result->addFnAttr(getRTAttribute(M));

  return result; 

};

OpenClAl::TargetKind OpenClAl::getModuleTarget(const Module& M) {
  const std::string& triple = M.getTargetTriple();
  if (triple == "i686-pc-amdopencl" ) return kTargetCPU32;
  if (triple == "x86_64-pc-amdopencl" ) return kTargetCPU64;
  if (triple == "amdil-pc-amdopencl" ) return kTargetGPU;
  return kTargetUnknown;
}

}
}
