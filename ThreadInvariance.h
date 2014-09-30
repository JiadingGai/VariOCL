/*! \file llvm/Analysis/ThreadInvariance.h
    \brief  Define ThreadInvariance Analysis

*/

// TODO(matthieu): Add copyright/license info here

#ifndef INCLUDE_LLVM_ANALYSIS_THREADINVARIANCE_H_
#define INCLUDE_LLVM_ANALYSIS_THREADINVARIANCE_H_

#include <llvm/IR/Constants.h>
#include <llvm/Pass.h>
#include <llvm/ADT/DenseSet.h>
#include <llvm/Support/raw_ostream.h>


namespace SpmdKernel {
namespace Coarsening {

class ScalarInvarianceInfo;

class InvarianceInfo {
  public:
  /** \brief Enumeration of the different variances supported */
  typedef enum { kUnknown, kMaybeNonInvariant, kNonInvariant, kInvariant } InvarianceKind;

  /** \brief Enumeration over the different level indexing provided */
  typedef enum { kDimLocal, kDimGlobal, kDimMax } DimLevel;

  InvarianceInfo();
  InvarianceInfo(unsigned int width);
  InvarianceInfo(const llvm::Value&);
  InvarianceInfo(const InvarianceInfo& other);
  ~InvarianceInfo();
  ScalarInvarianceInfo& operator[](unsigned int val);
  const ScalarInvarianceInfo& operator[](unsigned int val) const;
  bool operator!=(const InvarianceInfo& other) const;
  bool operator==(const InvarianceInfo& other) const;
  InvarianceInfo& operator=(const InvarianceInfo& other);
  const InvarianceInfo operator|(const InvarianceInfo& other) const;
  InvarianceInfo& operator|=(const InvarianceInfo& other);
  const InvarianceInfo operator&(const InvarianceInfo& other) const;
  InvarianceInfo& operator&=(const InvarianceInfo& other);
  void Reset(const InvarianceKind& val);
  void ResetPointer(const llvm::Value * V);
  llvm::raw_ostream& print(llvm::raw_ostream& OS) const;

  int getWidth() const;

  private:
  unsigned width;
  ScalarInvarianceInfo * values;
};



/** \brief Define variance axis information for a given value
 */
class ScalarInvarianceInfo {
  public:
  typedef InvarianceInfo::InvarianceKind InvarianceKind;
  typedef InvarianceInfo::DimLevel DimLevel;
  /** \brief Maximum amount of different axis defined for indices */
  static const unsigned MaxAxis = 3;

  /** \brief Default constructor, set all variances to kMaybeVariant */
  ScalarInvarianceInfo();

  /** \brief Comparaison binary operator */
  bool operator!=(const ScalarInvarianceInfo& other) const;

  /** \brief Comparaison binary operator */
  bool operator==(const ScalarInvarianceInfo& other) const;

  /** \brief Binary join operator */
  const ScalarInvarianceInfo operator|(const ScalarInvarianceInfo& other) const;

  /** \brief Binary join operator */
  ScalarInvarianceInfo& operator|=(const ScalarInvarianceInfo& other);

  /** \brief Binary meet operator */
  const ScalarInvarianceInfo operator&(const ScalarInvarianceInfo& other) const;

  /** \brief Binary meet operator */
  ScalarInvarianceInfo& operator&=(const ScalarInvarianceInfo& other);

  /** \brief Query the variance for a specific axis of a dimension level */
  const InvarianceKind getInvariance(DimLevel level, unsigned axis) const;

  /** \brief Set all the axis of all levels with a specific variance */
  void Reset(const InvarianceKind& val);

  /** \brief Set a specific axis/level */
  void Set(const DimLevel& level, unsigned axis, const InvarianceKind& val);

  llvm::raw_ostream& print(llvm::raw_ostream& OS) const;

  /** \brief get base pointer of the value, if any */
  const llvm::Value * getBasePointer() const;

  /** \brief set base pointer of the value */
  void setBasePointer(const llvm::Value * V);

  private:
  InvarianceKind Invariances[InvarianceInfo::kDimMax][MaxAxis];

  const llvm::Value * basePtr;
};

inline llvm::raw_ostream& operator<<(llvm::raw_ostream& OS, const ScalarInvarianceInfo& val) {
  val.print(OS);
  return OS;
}

inline llvm::raw_ostream& operator<<(llvm::raw_ostream& OS, const InvarianceInfo& val) {
  val.print(OS);
  return OS;
}

class ThreadInvarianceImpl;

class ThreadInvariance : public llvm::FunctionPass {
  public:
  typedef llvm::DenseSet<llvm::GlobalVariable *> GVSet;
  typedef GVSet::const_iterator global_iterator;
  /** \brief Uniq Id of this pass. Replacement for typeinfo */
  static char ID;

  /** \brief Default Constructor */
  ThreadInvariance();

  /** \brief Virtual destructor as we define virtual methods */
  ~ThreadInvariance();

  /** \brief Run analysis on the given function */
  virtual bool runOnFunction(llvm::Function& F);  // NOLINT

  /** \brief Set analysis dependencies on AnalysisUsage */
  virtual void getAnalysisUsage(llvm::AnalysisUsage& AU) const; // NOLINT

  InvarianceInfo getInvariance(const llvm::Value * V) const;

  bool hasGlobalInvariance() const;

  bool alreadyCoarsed() const;

  global_iterator begin() const;

  global_iterator end() const;
  


  private:
  /** \brief Instance of the class to which the implementation is delegated */
  ThreadInvarianceImpl * Impl;
};

}
}
#endif  // INCLUDE_LLVM_ANALYSIS_THREADVARIANCE_H_
