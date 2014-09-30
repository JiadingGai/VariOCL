#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Pass.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/IR/Value.h"

using namespace llvm;

namespace {
class BarrierDeleter : public ModulePass {
        public:
        static char ID;
        BarrierDeleter();
        virtual ~BarrierDeleter();
        bool runOnModule(Module& M);
};
} //unnamed namespace

BarrierDeleter::BarrierDeleter() : ModulePass(ID)
{}

BarrierDeleter::~BarrierDeleter()
{}

bool BarrierDeleter::runOnModule(Module &M)
{
    //First, find the barrier function.
    Function* barrier_func = M.getFunction("barrier");
    if (NULL == barrier_func) {
        //No barrier func, do nothing.
        return false;
    }

    //Collect the uses of barrier
    SmallPtrSet<CallInst*,128> barrier_calls;
    typedef Function::use_iterator use_itr;
    for (use_itr U = barrier_func->use_begin(), Uend = barrier_func->use_end();
            U != Uend; ++U) {
        if (CallInst* call = dyn_cast<CallInst>(*U)) {
            barrier_calls.insert(call);
        }
    }

    //Remove uses of barrier from their parent blocks
    typedef SmallPtrSet<CallInst*,128>::iterator cinst_itr;
    for (cinst_itr I = barrier_calls.begin(), Iend = barrier_calls.end();
            I != Iend; ++I) {
        (*I)->eraseFromParent();
    }

    //delete the function declaration too
    barrier_func->eraseFromParent();

    //We changed the module, return true
    return true;
}

char BarrierDeleter::ID = 0;
static RegisterPass<BarrierDeleter>
Y("delete-barriers", "Remove all calls to the function barrier");
