#include "barrier_inst.h"
#include "barrier_utils.h"

namespace SpmdKernel {

using namespace llvm;

namespace Coarsening {

  bool containsJustABarrier(BasicBlock *BB)
  {
    if (BB->size() == 2) {
      BasicBlock::iterator I = BB->begin();
      return isa<BarrierInst>(&*I);
    } else {
      return false;
    }
  }
  
  StringRef getCalledFunctionName(CallInst *Call)
  {
    Function *fun = Call->getCalledFunction();
    if (fun) 
      return fun->getName(); 
    else
      return StringRef("indirect call");
  }

}
}
