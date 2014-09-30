#include "llvm/Bitcode/ReaderWriter.h"
#include "llvm/Pass.h"
#include "kernel_info_reader.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Analysis/Verifier.h"

using namespace llvm;

namespace {

  struct InfoWriter : public ModulePass {
    static char ID;
    InfoWriter() : ModulePass(ID) {}

    LoadInst * CreateLoadAligned(IRBuilder<> & Builder, Value * Pointer, unsigned int Alignment)
    {
      LoadInst * ld_inst = Builder.CreateLoad(Pointer);
      ld_inst->setAlignment(Alignment);

      return ld_inst;
    }

    StoreInst * CreateStoreAligned(IRBuilder<> & Builder, Value * Val, Value * Pointer, unsigned int Alignment)
    {
      StoreInst * st_inst = Builder.CreateStore(Val, Pointer);
      st_inst->setAlignment(Alignment);

      return st_inst;
    }

    void setupStringGlobal(Module & infoMod, LLVMContext & GlobalContext,
                           const std::vector<std::string> & list_names, StringRef label)
    {
      assert(list_names.size() > 0);

      Type * intCharPtrTy = Type::getInt8PtrTy(GlobalContext);

      std::vector<Constant *> vec_str;
      for(unsigned int k = 0; k < list_names.size(); ++k) {
        StringRef strR_name = list_names.at(k);
        Constant * const_init = ConstantDataArray::getString(GlobalContext, strR_name);

        GlobalVariable * gbl_str = new GlobalVariable(infoMod,
                                      const_init->getType(),
                                      true, GlobalVariable::PrivateLinkage,
                                      const_init, ".str");
        gbl_str->setAlignment(1);
        gbl_str->setUnnamedAddr(true);

        Constant * const_expr = ConstantExpr::getPointerCast(gbl_str,intCharPtrTy);
        vec_str.push_back(const_expr);
      }

      ArrayRef<Constant*> aref_str(vec_str);
      Constant * const_array = ConstantArray::get(ArrayType::get(intCharPtrTy, aref_str.size()), aref_str);
      GlobalVariable * gbl_name = new GlobalVariable(infoMod,
                                         const_array->getType(),
                                         false, GlobalValue::ExternalLinkage, const_array,
                                         label);
      if(gbl_name->hasName()) {/* Stupid warning until I figure out the math for alignment */ }
      // gbl_name->setAlignment(16);
    }

    template<typename T>
    void setup1DArrayGlobal(Module & infoMod, LLVMContext & GlobalContext,
                               const std::vector<T> & list, StringRef label)
    {
      assert(list.size() > 0);

      Type * Ty = Type::getIntNTy(GlobalContext, sizeof(T)*8);

      std::vector<Constant *> vec;
      for(unsigned int k = 0; k < list.size(); ++k) {

        Constant * const_init = ConstantInt::get(Ty, list.at(k));
        vec.push_back(const_init);

      }
      ArrayRef <Constant*> aref_uint(vec);
      Constant * const_array = ConstantArray::get(ArrayType::get(Ty, aref_uint.size()), aref_uint);
      GlobalVariable * gbl_array = new GlobalVariable(infoMod,
                                      const_array->getType(),
                                      true, GlobalValue::ExternalLinkage, const_array,
                                      label);
      if(gbl_array->hasName()) {/* Stupid warning until I figure out the math for alignment */ }
      // gbl_array->setAlignment(16);
    }

    template<typename T>
    void setup2DUintArrayGlobal(Module & infoMod, LLVMContext & GlobalContext,
                               const std::vector<std::vector<T> > & list, StringRef label)
    {
      assert(list.size() > 0);

      Type * Ty = Type::getIntNTy(GlobalContext, sizeof(T)*8);

      std::vector<Constant *> vec_outer;
      for(unsigned int k = 0; k < list.size(); ++k) {
        std::vector<Constant *> vec_inner;
        for(unsigned int i = 0; i < list.front().size(); ++i) {
          Constant * const_inner = ConstantInt::get(Ty, list.at(k).at(i));
          vec_inner.push_back(const_inner);
        }
        ArrayRef<Constant *> aref_inner(vec_inner);
        Constant * const_outer = ConstantArray::get(ArrayType::get(Ty, aref_inner.size()),
                                                aref_inner);
        vec_outer.push_back(const_outer);
      }
      ArrayRef<Constant*> aref_outer(vec_outer);
      Constant * const_final = ConstantArray::get(ArrayType::get(ArrayType::get(Ty, list.front().size()), 
                                                                    aref_outer.size()), 
                                                     aref_outer);
      GlobalVariable * gbl_array = new GlobalVariable(infoMod,
                                       const_final->getType(),
                                       true, GlobalValue::ExternalLinkage, const_final,
                                       label);
      if(gbl_array->hasName()) {/* Stupid warning until I figure out the math for alignment */ }
      // gbl_array->setAlignment(16);
    }

    virtual bool runOnModule(Module &kernelMod) {

      // Read module and gather all info
      CL_KernelInfo cl_kernel_info(kernelMod);

      // Preparations
      LLVMContext &GlobalContext = getGlobalContext();
      Module kernel_info_mod("cl_kernel_info", GlobalContext);

      Type * int32ty = Type::getInt32Ty(GlobalContext);

      // _cl_kernel_num
      unsigned int cl_kernel_num = cl_kernel_info.get_cl_kernel_num();
      GlobalVariable * g_cl_kernel_num = new GlobalVariable(kernel_info_mod, int32ty, true, GlobalValue::ExternalLinkage , 0, "_cl_kernel_num");
      g_cl_kernel_num->setAlignment(4);
      g_cl_kernel_num->setInitializer(ConstantInt::get(int32ty, cl_kernel_num));

      // _cl_kernel_names 
      StringRef cl_kernel_names("_cl_kernel_names");
      setupStringGlobal(kernel_info_mod, GlobalContext, cl_kernel_info.get_kernel_names(),cl_kernel_names);

      // _cl_kernel_num_args
      StringRef cl_kernel_num_args("_cl_kernel_num_args");
      setup1DArrayGlobal(kernel_info_mod, GlobalContext, cl_kernel_info.get_kernel_num_args(),cl_kernel_num_args);

      // _cl_kernel_attributes
      StringRef cl_kernel_arg_names("_cl_kernel_attributes");
      setupStringGlobal(kernel_info_mod, GlobalContext, cl_kernel_info.get_attr_names(), cl_kernel_arg_names);

      // _cl_kernel_work_group_size_hint
      StringRef cl_kernel_work_group_size_hint("_cl_kernel_work_group_size_hint");
      setup2DUintArrayGlobal(kernel_info_mod, GlobalContext, cl_kernel_info.get_wkgp_size_hints(), cl_kernel_work_group_size_hint);

      // _cl_kernel_reqd_work_group_size
      StringRef cl_kernel_reqd_work_group_size("_cl_kernel_reqd_work_group_size");
      setup2DUintArrayGlobal(kernel_info_mod, GlobalContext, cl_kernel_info.get_reqd_wkgp_sizes(), cl_kernel_reqd_work_group_size);

      // // _cl_kernel_local_mem_size
      StringRef cl_kernel_local_mem_size("_cl_kernel_local_mem_size");
      setup1DArrayGlobal(kernel_info_mod, GlobalContext, cl_kernel_info.get_local_mem_sizes(), cl_kernel_local_mem_size);

      // // _cl_kernel_private_mem_size
      StringRef cl_kernel_private_mem_size("_cl_kernel_private_mem_size");
      setup1DArrayGlobal(kernel_info_mod, GlobalContext, cl_kernel_info.get_priv_mem_sizes(), cl_kernel_private_mem_size);

      // _cl_kernel_arg_address_qualifier
      StringRef cl_kernel_arg_address_qualifier("_cl_kernel_arg_address_qualifier");
      setupStringGlobal(kernel_info_mod, GlobalContext, cl_kernel_info.get_addr_qualifier(), cl_kernel_arg_address_qualifier);

      // _cl_kernel_arg_access_qualifier
      StringRef cl_kernel_arg_access_qualifier("_cl_kernel_arg_access_qualifier");
      setupStringGlobal(kernel_info_mod, GlobalContext, cl_kernel_info.get_access_qualifier(), cl_kernel_arg_access_qualifier);

      // _cl_kernel_arg_type_name
      StringRef cl_kernel_arg_type_name("_cl_kernel_arg_type_name");
      setupStringGlobal(kernel_info_mod, GlobalContext, cl_kernel_info.get_arg_type_names(), cl_kernel_arg_type_name);

      // _cl_kernel_arg_type_qualifier
      StringRef cl_kernel_arg_type_qualifier("_cl_kernel_arg_type_qualifier");
      setup1DArrayGlobal(kernel_info_mod, GlobalContext, cl_kernel_info.get_arg_type_qual(), cl_kernel_arg_type_qualifier);

      // _cl_kernel_arg_name
      StringRef cl_kernel_arg_name("_cl_kernel_arg_name");
      setupStringGlobal(kernel_info_mod, GlobalContext, cl_kernel_info.get_arg_names(), cl_kernel_arg_name);

      // _cl_kernel_dim
      StringRef cl_kernel_dim("_cl_kernel_dim");
      setup1DArrayGlobal(kernel_info_mod, GlobalContext, cl_kernel_info.get_kernel_dims(), cl_kernel_dim);

// ======================================================================================================

      // Write to file
      StringRef infoModID("kernel_info_link");
      std::string ErrorInfo;
      std::string filename(infoModID.str());
      filename.append(".bc");
      raw_fd_ostream out(filename.c_str(), ErrorInfo);
      DEBUG(errs() << "Generating... " << filename);
      WriteBitcodeToFile(&kernel_info_mod, out);

      return false;
    }

  };

}

char InfoWriter::ID = 0;
static RegisterPass<InfoWriter> X("infowrite", "Analyze OpenCL kernel and write metadata.", false, false);
