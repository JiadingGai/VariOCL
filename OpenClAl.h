/*! \file llvm/Analysis/OpenClAl.h
    \brief Define OpenCl Abstraction Layer
*/

// TODO(matthieu): Add copyright/license info here

#ifndef INCLUDE_LLVM_ANALYSIS_OPENCLAL_H_
#define INCLUDE_LLVM_ANALYSIS_OPENCLAL_H_

#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Pass.h"

#include <map>
#include <set>
#include <list>

namespace SpmdKernel {
namespace Coarsening {
/*! \brief this class contains the index in the llvm metadata and a reference
    to the function it is related
 */
class Kernel {
  friend class OpenClAl;
  unsigned int index;// contains the index in the llvm metadata
  llvm::Function* F;// reference to the function it is related
public:
  Kernel(size_t idx, llvm::Function* Fun): index(idx), F(Fun){};

};

/*! \brief Identify OpenCL specific runtime information
 *
 * This analysis allows user to query for possible OpenCl
 * semantic information associated to a given element.
 *
 */
class OpenClAl : public llvm::ImmutablePass {
  std::list<Kernel> KernelList;

  void createKernelList(llvm::Module& M);
  public:
  /** \brief Pass identificationHold uniq identifier for this class. Replaces typeinfo. */
  static char ID;

  /** \brief Represents the different classes of memory */
  typedef enum { kMemPrivate=0, kMemGlobal, kMemConstant, kMemLocal, kMemUnknown, kInvalid }
          MemClass;

  /** \brief Represents the different Work-Item Built-in Functions */
  typedef enum { kWIUnknown, kWIWorkDim, kWIGlobalSize, kWIGlobalId, kWILocalSize, kWILocalId, kWINumGroups, kWIGroupId, kWIGlobalOffset } WIFunctions;

  /** \brief Represents the different Work-Item Built-in Functions */
  typedef enum { kTargetGPU, kTargetCPU32, kTargetCPU64, kTargetUnknown } TargetKind;

  /** \brief Map each Work-Item Built-in functions name to their enumerator */
  typedef std::map<const std::string, WIFunctions> WIMap;
  static const WIMap WIFunctionMap;

  typedef std::set<std::string> FuncSet;
  static const FuncSet MathSet;
  static const FuncSet LogicalSet;
  static const FuncSet SafeAtom;


  static TargetKind getModuleTarget(const llvm::Module& M);

  /** \brief default constructor */
  OpenClAl();

  /** \brief build a list of Kernel (std::list)
   *  \param M the module to analyse
   *  \return False as this analysis does not modify the module
   */
  virtual bool runOnModule(llvm::Module& M);  // NOLINT

  /** \brief check whether a given function is a kernel */
  /**
   *  \param F the queried function
   *  \return True if the queried function is a kernel,
   *          False otherwise
   *
   */
  bool IsThisFunctionAKernel(const llvm::Function* F) const;

  /** \brief check whether a given function is a stub */
  /**
   *  \param F the queried function
   *  \return True if the queried function is a stub,
   *          False otherwise
   *
   */
  bool IsThisFunctionAStub(const llvm::Function* F) const;

  static WIFunctions TypeOfWorkItemFunction(const llvm::Function *F);

  bool addMissingWIFunctionDeclarations(llvm::Module& M) const;

  static llvm::Function * getWIFunction(llvm::Module& M, WIFunctions);

  static llvm::Function * getMad(llvm::Module& M, llvm::Type * T);



  /** \brief check whether the function returns one of the group id index */
  /**
   *  \param F the queried function
   *  \return True if the queried function is get_group_id,
   *          False otherwise
   *
   */

  bool IsGroupIndex(const llvm::Function* F) const;

  /** \brief check whether the function returns one of the local id index */
  /**
   *  \param F the queried function
   *  \return True if the queried function is get_local_id,
   *          False otherwise
   *
   */
  bool IsGlobalIndex(const llvm::Function* F) const;

  /** \brief check whether the function returns one of the local id index */
  /**
   *  \param F the queried function
   *  \return True if the queried function is get_local_id,
   *          False otherwise
   *
   */
  bool IsLocalIndex(const llvm::Function* F) const;

  bool IsLocalSize(const llvm::Function* F) const;

  bool IsGlobalSize(const llvm::Function * F) const;

  bool IsNumGroup(const llvm::Function *F) const;

  /** \brief obtain axis requested for a call to local/global id */
  int GetIndexAxis(const llvm::CallInst * CI) const;

  /** \brief  check whether the function is a Barrier */
  /**
   *  \param  F the queried function
   *  \return True if the queried function is barrier,
   *          False otherwise
   *
   */
  bool IsBarrier(const llvm::Function* F) const;

  bool IsMathFunc(const llvm::Function* F) const;

  bool IsLogicalFunc(const llvm::Function *F) const;

  bool IsSafeAtomic(const llvm::Function *F) const;

  /** \brief Identify the memory class referenced by a pointer */
  /**
   *  \param  type the pointer type to test
   *  \return kInvalid if the type is NULL,
   *          kMemUnknown if the memory class is unknown,
   *          the kind of memory otherwise.
   */
  MemClass GetReferencedMemory(const llvm::PointerType* type) const;

  /** \brief Identify the memory class referenced by an assumed pointer type */
  /**
   * \param   type The type to test
   * \return  kInvalid if the type is NULL or is not a pointer type,
   *          kMemUnknown if the memory class type is unknown,
   *          the kind of memory otherwise.
   */
  MemClass GetReferencedMemory(const llvm::Type* type) const;

  /** \brief  Test if a given pointer refer a given memory class */
  /**
   * \param   type The pointer type to test
   * \param   kind The tested memory class
   * \return  True if the pointer type is valid and refers to the given
              memory class, False otherwise
   */
  bool IsPointerToMemClass(const llvm::PointerType* type, const MemClass& kind) const;

  /** \brief  Test if an assumed pointer refer to a given memory class */
  /**
   * \param   type The type to test
   * \param   kind The tested memory class
   * \return  True if the type if a valid pointer type and refers to the given memory class,
              False otherwise
   */
  bool IsPointerToMemClass(const llvm::Type* type, const MemClass& kind) const;

  bool IsAtomicOperation(llvm::Function * F) const;

  /** \brief  iterate over the kernel list
   * \param F the given function
   * \return return the kernel class associated to it
  */
  size_t findKernel(llvm::Function* F) const;

  /** \brief reread the llvm metadata
   * \param M the module containing the llvm metadata
  */
  void kernelChanged(llvm::Module& M);

  std::list<Kernel>::const_iterator kernel_begin() { return KernelList.begin(); }
  std::list<Kernel>::const_iterator kernel_end() { return KernelList.end(); }

  /** \brief check if the stub exists, then it is built for CPU target
  */
  bool isCPUTarget(llvm::Module& M) const;
};

llvm::ImmutablePass * createOpenClAlPass();

}
}
#endif  // INCLUDE_LLVM_ANALYSIS_OPENCLAL_H_
