#include "llvm/Analysis/Verifier.h"
#include "llvm/Bitcode/ReaderWriter.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Pass.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/IR/IRBuilder.h"
#include "kernel_info_reader.h"

using namespace llvm;

namespace {

  struct LinkWriter : public ModulePass {

    static char ID;
    LinkWriter() : ModulePass(ID) {}

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

    StringRef findApproxFunc(Module &mod, const char* name)
    {
      StringRef ret;

      for(Module::iterator fi = mod.begin(); fi != mod.end(); ++fi)
      {
        Function & f = *fi;

        if(f.getName().str().find(name) != std::string::npos)
          ret = f.getName();
      }
      return ret;
    }
    virtual bool runOnModule(Module &kernelMod)
    {

      CL_KernelInfo * cl_kernel_info = new CL_KernelInfo(kernelMod);

      LLVMContext &GlobalContext = getGlobalContext();
      StringRef linkModID("kernel_link");
      // Module * linkMod = new Module(linkModID, GlobalContext);

      SMDiagnostic Err;
      Module *linkMod_templ = ParseIRFile("kernel_link_templ.ll", Err, GlobalContext);
      LLVMContext & linkMod_templContext = linkMod_templ->getContext();
      if (!linkMod_templ) {
          errs() << Err.getMessage();
          return 1;
      }

      // Types
      IntegerType * int32 = IntegerType::get(GlobalContext, 32);
      IntegerType * int1 = IntegerType::get(GlobalContext, 1);
      PointerType * int32Ptr = PointerType::get(int32, 0);
      IntegerType * int8 = IntegerType::get(GlobalContext, 8);
      PointerType * int8Ptr = PointerType::get(int8, 0);
      ConstantInt * const0 = ConstantInt::get(int32, 0);
      ConstantInt * const1 = ConstantInt::get(int32, 1);
      ConstantInt * constFalse = ConstantInt::get(int1, 0);

      // Read some info from kernel
      unsigned int num_kernels = cl_kernel_info->get_cl_kernel_num();
      std::vector<std::string> arg_names = cl_kernel_info->get_arg_names();
      std::vector<std::vector<Type*> > kernel_arg_types = cl_kernel_info->get_kernel_arg_types();

      // ===============================================================
      // Create new tlb_function structure
      // ===============================================================
      std::vector<Type*> tlb_struct_vec;
      // Forward declare kernel names
      std::vector<Constant*> kernel_decl_vec;
      for(unsigned int k = 0; k < num_kernels; ++k) 
      {
        std::vector<Type* > arg_types = kernel_arg_types.at(k);
        Type * Ty = Type::getVoidTy(GlobalContext);
        FunctionType * fTy = FunctionType::get(Ty, arg_types, false);
        PointerType * pTy = PointerType::get(fTy, 0);

        // Reuse to insert new pointer function type
        arg_types.push_back(dyn_cast<Type>(pTy));

        StructType* function_struct = StructType::create(arg_types, "Function");

        tlb_struct_vec.push_back(dyn_cast<Type>(function_struct));

        std::string kernel_name(cl_kernel_info->get_kernel_names().at(k));
        Constant * fwd_func_decl = linkMod_templ->getOrInsertFunction(kernel_name, fTy);
        kernel_decl_vec.push_back(fwd_func_decl);
      }
      ArrayRef<Type*> struct_types(tlb_struct_vec);
      // tlb_function->setBody(struct_types);
      StructType * tlb_struct = StructType::create(struct_types, "struct.tlb_function_new");

      // Get struct type pointers
      StructType * tlb_data = linkMod_templ->getTypeByName("struct.tlb_data");
      PointerType * tlb_data_Pty = PointerType::get(tlb_data, 0);
      // Modify tlb_function struct
      StructType * tlb_function = linkMod_templ->getTypeByName("struct.tlb_function");
      PointerType * tlb_func_Pty = PointerType::get(tlb_function, 0);

      PointerType * tlb_func_new_Pty = PointerType::get(tlb_struct, 0);

      // ===============================================================
      // Defining kernel launch information
      // ===============================================================
      for(Module::iterator fi = linkMod_templ->begin(); fi != linkMod_templ->end(); ++fi)
      {
        Function & f = *fi;

        // =============================================================
        // Defining kernel_set_arguments(void)
        // =============================================================
        if(f.getName().str().find("kernel_set_arguments") != std::string::npos) 
        {

          BasicBlock * entryBlock = BasicBlock::Create(linkMod_templContext, "entry", &f);
          IRBuilder<> Builder(entryBlock);

          // %tlb = alloca %struct.tlb_data*, align 4
          AllocaInst * tlb = Builder.CreateAlloca(tlb_data_Pty, 0, "tlb");
          tlb->setAlignment(4);
          // %tlb_func = alloca %struct.tlb_function*, align 4
          AllocaInst * tlb_func = Builder.CreateAlloca(tlb_func_Pty, 0, "tlb_func");
          tlb_func->setAlignment(4);
          // %args_offset = alloca i32, align 4
          AllocaInst * args_offset = Builder.CreateAlloca(int32, 0, "args_offset");
          args_offset->setAlignment(4);

          // Do not alloca non-pointer types
          std::vector<std::vector<AllocaInst*> > arg_allocas_vec;
          unsigned int str_id = 0;
          for(unsigned int ki = 0; ki < num_kernels; ++ki)
          {
            std::vector<AllocaInst*> kernel_arg_allocas;
            unsigned int num_args = cl_kernel_info->get_kernel_num_args().at(ki);

            for(unsigned int ai = 0; ai < num_args; ++ai, ++str_id)
            {
              std::string arg_name(arg_names.at(str_id));
              if(kernel_arg_types.at(ki).at(ai)->isPointerTy())
              {
                AllocaInst * arg_decl = Builder.CreateAlloca(int32, 0, "_" + arg_name);
                arg_decl->setAlignment(4);
                kernel_arg_allocas.push_back(arg_decl);
              }
              // Some dangerous null going on here, fix if have time
              else kernel_arg_allocas.push_back(NULL);
            }

            arg_allocas_vec.push_back(kernel_arg_allocas);
          }

          // get @key_data
          GlobalVariable * key_data = linkMod_templ->getNamedGlobal("key_data");
          LoadInst * ld_key_data = CreateLoadAligned(Builder, key_data, 4);
          Function * pthread_getspecific = linkMod_templ->getFunction("pthread_getspecific");
          CallInst * pthread_getspecific_call = Builder.CreateCall(pthread_getspecific, ld_key_data, "call"); // attr?
          Value * bc_tlb_data = Builder.CreateBitCast(pthread_getspecific_call, tlb_data_Pty);
          CreateStoreAligned(Builder, bc_tlb_data, tlb, 4);
          GlobalVariable * key_function = linkMod_templ->getNamedGlobal("_ZL12key_function");
          assert(key_function); // make sure mangled name exists in the future
          LoadInst * ld_key_function = CreateLoadAligned(Builder, key_function, 4);
          CallInst * pthread_getspecific_call2 = Builder.CreateCall(pthread_getspecific, ld_key_function, "call");
          Value * bc_tlb_func = Builder.CreateBitCast(pthread_getspecific_call2, tlb_func_Pty);
          CreateStoreAligned(Builder, bc_tlb_func, tlb_func, 4);
          CreateStoreAligned(Builder, const0, args_offset, 4);
          LoadInst * ld_tlb_data = CreateLoadAligned(Builder, tlb, 4);
          // is it really 13 all the time?
          Value * gep_kernel_idx = Builder.CreateConstInBoundsGEP2_32(ld_tlb_data, 0, 13, "kernel_idx");
          LoadInst * ld_kernel_idx = CreateLoadAligned(Builder, gep_kernel_idx, 4);

          // These basic blocks will be used for the switch
          BasicBlock * sw_default = BasicBlock::Create(linkMod_templContext, "sw.default", &f);
          BasicBlock * sw_epilog = BasicBlock::Create(linkMod_templContext, "sw.epilog", &f);

          SwitchInst * switch_default = Builder.CreateSwitch(ld_kernel_idx, sw_default, num_kernels);
          for(unsigned int cs = 0; cs < num_kernels; ++cs)
          {
            BasicBlock * sw_case = BasicBlock::Create(linkMod_templContext, "kern_set_args_case", &f, sw_default);
            Builder.SetInsertPoint(sw_case);

            // get kernel function pointer
            LoadInst * ld_tlb_func = CreateLoadAligned(Builder, tlb_func, 4);
            // Bitcast this to new struct
            Value * bc_ld_tlb_func = Builder.CreateBitCast(ld_tlb_func, tlb_func_new_Pty);
            Value * gep_tlb_func = Builder.CreateConstInBoundsGEP2_32(bc_ld_tlb_func, 0, cs, "func");
            unsigned int num_args = cl_kernel_info->get_kernel_num_args().at(cs);
            Value * gep_struct_func = Builder.CreateConstInBoundsGEP2_32(gep_tlb_func, 0, num_args, "_p2W8Ht");

            CreateStoreAligned(Builder, kernel_decl_vec.at(cs), gep_struct_func, 4);

            // Set argument private, take note of the size of arg type
            str_id = 0;
            for(unsigned int ai = 0; ai < num_args; ++ai, ++str_id)
            {
              Type * arg_type = kernel_arg_types.at(cs).at(ai);

              LoadInst * ld_tlb = CreateLoadAligned(Builder, tlb, 4);
              Value * gep_param_ctx = Builder.CreateConstInBoundsGEP2_32(ld_tlb, 0, 12, "param_ctx");
              Value * gep_args = Builder.CreateConstInBoundsGEP2_32(gep_param_ctx, 0, 0, "args");
              Value * gep_arraydecay = Builder.CreateConstInBoundsGEP2_32(gep_args, 0, 0, "arraydecay");
              LoadInst * ld_args_offset = CreateLoadAligned(Builder, args_offset, 4);
              Value * gep_add_ptr = Builder.CreateInBoundsGEP(gep_arraydecay, ld_args_offset, "add.ptr");

              // size of argument
              ConstantInt * argSize;
              // = ConstantInt::get(int32, 4);

              if(arg_type->isPointerTy())
              {
                Value * bc_add_ptr = Builder.CreateBitCast(gep_add_ptr, int32Ptr);
                LoadInst * ld_add_ptr = CreateLoadAligned(Builder, bc_add_ptr, 4);
                CreateStoreAligned(Builder, ld_add_ptr, arg_allocas_vec.at(cs).at(ai), 4);
                LoadInst * ld_arg = CreateLoadAligned(Builder, arg_allocas_vec.at(cs).at(ai), 4);
                Value * int2ptr_arg = Builder.CreateIntToPtr(ld_arg, kernel_arg_types.at(cs).at(ai));

                LoadInst * ld_tlb_func_arg = CreateLoadAligned(Builder, tlb_func, 4);
                Value * bc_tlb_func_arg = Builder.CreateBitCast(ld_tlb_func_arg, tlb_func_new_Pty);
                Value * gep_tlb_func_arg = Builder.CreateConstInBoundsGEP2_32(bc_tlb_func_arg, 0, cs, "func_02");
                Value * gep_arg = Builder.CreateConstInBoundsGEP2_32(gep_tlb_func_arg, 0, ai, arg_names.at(str_id));
                CreateStoreAligned(Builder, int2ptr_arg, gep_arg, 4);

                // TODO: currently hardcoded for 32 bit, make support for N-bit architectures
                argSize = ConstantInt::get(int32, 4);
              }
              else 
              {
                LoadInst * ld_tlb_func_arg = CreateLoadAligned(Builder, tlb_func, 4);
                Value * bc_tlb_func_arg = Builder.CreateBitCast(ld_tlb_func_arg, tlb_func_new_Pty);
                Value * gep_tlb_func_arg = Builder.CreateConstInBoundsGEP2_32(bc_tlb_func_arg, 0, cs, "func_02");
                Value * gep_arg = Builder.CreateConstInBoundsGEP2_32(gep_tlb_func_arg, 0, ai, arg_names.at(str_id));
                Value * bc_arg = Builder.CreateBitCast(gep_arg, int8Ptr);
                  StringRef llvm_memcpy_name = findApproxFunc(*linkMod_templ, "llvm.memcpy");
                  Function * llvm_memcpy = linkMod_templ->getFunction(llvm_memcpy_name);
                    // llvm.memcpy has argument that depends on arch size
                    Function::arg_iterator ai = llvm_memcpy->arg_begin();
                    ++ai; ++ai; //2nd, 3rd argument
                    Type * arg3_type = ai->getType();
                    unsigned int sizeOfArg3 = arg3_type->getPrimitiveSizeInBits();
                    IntegerType * size = IntegerType::get(GlobalContext, sizeOfArg3);
                  unsigned int bitWidth = arg_type->getPrimitiveSizeInBits();
                  assert(bitWidth > 0 && "Unsupported type. Cannot get PrimitiveSize");
                  ConstantInt * sizeofPtr = ConstantInt::get(size, bitWidth/8);

                Builder.CreateCall5(llvm_memcpy, bc_arg, gep_add_ptr, sizeofPtr, const1, constFalse);

                unsigned int argSize_primBytes= (arg_type->getPrimitiveSizeInBits())/8;
                argSize = ConstantInt::get(int32, argSize_primBytes);
              }

              LoadInst * ld_args_offset2 = CreateLoadAligned(Builder, args_offset, 4);
              Value * add_args_offset2 = Builder.CreateAdd(ld_args_offset2, argSize, "add");
              CreateStoreAligned(Builder, add_args_offset2, args_offset, 4);
            }

            Builder.CreateBr(sw_epilog);

            switch_default->addCase(ConstantInt::get(int32, cs), sw_case);
          }

          Builder.SetInsertPoint(sw_default);
          Builder.CreateBr(sw_epilog);

          Builder.SetInsertPoint(sw_epilog);
          Builder.CreateRetVoid();
          // f.dump(); DEBUG("");
        }

        // =============================================================
        // Defining kernel_launch(tlb_data, tlb_function)
        // =============================================================
        if(f.getName().str().find("kernel_launch") != std::string::npos)
        {

          // This function has two arguments:
          // %struct.tlb_data* %tlb, %struct.tlb_function* %tlb_func
          Function::arg_iterator ai = f.arg_begin();
          Argument &tlb = *ai;
          ++ai;
          Argument &tlb_func = *ai;

          BasicBlock * entryBlock = BasicBlock::Create(linkMod_templContext, "entry", &f);
          IRBuilder<> Builder(entryBlock);

          AllocaInst * tlb_addr = Builder.CreateAlloca(tlb_data_Pty, 0, "tlb.addr");
          tlb_addr->setAlignment(4);
          AllocaInst * tlb_func_addr = Builder.CreateAlloca(tlb_func_Pty, 0, "tlb_func.addr");
          tlb_func_addr->setAlignment(4);
          CreateStoreAligned(Builder, &tlb, tlb_addr, 4);
          CreateStoreAligned(Builder, &tlb_func, tlb_func_addr, 4);
          LoadInst * ld_tlb_data = CreateLoadAligned(Builder, tlb_addr, 4);
          Value * gep_kernel_idx = Builder.CreateConstInBoundsGEP2_32(ld_tlb_data, 0, 13, "kernel_idx");
          LoadInst * ld_kernel_idx = CreateLoadAligned(Builder, gep_kernel_idx, 4);

          BasicBlock * sw_epilog = BasicBlock::Create(linkMod_templContext, "sw.epilog", &f);

          SwitchInst * switch_default = Builder.CreateSwitch(ld_kernel_idx, sw_epilog, num_kernels);
          unsigned int str_id = 0;
          for(unsigned int cs = 0; cs < num_kernels; ++cs)
          {
            BasicBlock * sw_case = BasicBlock::Create(linkMod_templContext, "kernel_launch_case", &f, sw_epilog);
            Builder.SetInsertPoint(sw_case);

            unsigned int num_args = cl_kernel_info->get_kernel_num_args().at(cs);
            // reason <= is because the struct contains a function pointer at num_args index
            std::vector<Value *> call_args;
            for(unsigned int ai = 0; ai <= num_args; ++ai)
            {
              LoadInst * ld_tlb_func_addr = CreateLoadAligned(Builder, tlb_func_addr, 4);
              Value * bc_ld_tlb_func_addr = Builder.CreateBitCast(ld_tlb_func_addr, tlb_func_new_Pty);
              Value * gep_tlb_function = Builder.CreateConstInBoundsGEP2_32(bc_ld_tlb_func_addr, 0, cs, "func");
              Value * gep_func;
              if(ai < num_args) {
                gep_func = Builder.CreateConstInBoundsGEP2_32(gep_tlb_function, 0, ai, arg_names.at(str_id));
                ++str_id;
              }
              else {
                gep_func = Builder.CreateConstInBoundsGEP2_32(gep_tlb_function, 0, ai, "_p2W8Ht");
              }
              LoadInst * struc_elem = CreateLoadAligned(Builder, gep_func, 4);
              call_args.push_back(dyn_cast<Value>(struc_elem));
            }

            Value * func_ptr = call_args.back();
            call_args.pop_back();
            Builder.CreateCall(func_ptr, call_args);
            Builder.CreateBr(sw_epilog);
            switch_default->addCase(ConstantInt::get(int32, cs), sw_case);
          }

          Builder.SetInsertPoint(sw_epilog);
          Builder.CreateRetVoid();
          // f.dump(); DEBUG("");
        }

        // =============================================================
        // Defining kernel_fini(void)
        // =============================================================
        if(f.getName().str().find("kernel_fini") != std::string::npos)
        {
          BasicBlock * entryBlock = BasicBlock::Create(linkMod_templContext, "entry", &f);
          IRBuilder<> Builder(entryBlock);

          AllocaInst * tlb = Builder.CreateAlloca(tlb_data_Pty, 0, "tlb");
          tlb->setAlignment(4);
          AllocaInst * tlb_func = Builder.CreateAlloca(tlb_func_Pty, 0, "tlb_func");
          tlb_func->setAlignment(4);

          // get @key_data
          GlobalVariable * key_data = linkMod_templ->getNamedGlobal("key_data");
          LoadInst * ld_key_data = CreateLoadAligned(Builder, key_data, 4);
          Function * pthread_getspecific = linkMod_templ->getFunction("pthread_getspecific");
          CallInst * pthread_getspecific_call = Builder.CreateCall(pthread_getspecific, ld_key_data, "call");
          Value * bc_tlb_data = Builder.CreateBitCast(pthread_getspecific_call, tlb_data_Pty);
          CreateStoreAligned(Builder, bc_tlb_data, tlb, 4);
          GlobalVariable * key_function = linkMod_templ->getNamedGlobal("_ZL12key_function");
          assert(key_function); // make sure mangled name exists in the future
          LoadInst * ld_key_function = CreateLoadAligned(Builder, key_function, 4);
          CallInst * pthread_getspecific_call2 = Builder.CreateCall(pthread_getspecific, ld_key_function, "call");
          Value * bc_tlb_func = Builder.CreateBitCast(pthread_getspecific_call2, tlb_func_Pty);
          CreateStoreAligned(Builder, bc_tlb_func, tlb_func, 4);

          LoadInst * ld_tlb_data = CreateLoadAligned(Builder, tlb, 4);
          Value * gep_kernel_idx = Builder.CreateConstInBoundsGEP2_32(ld_tlb_data, 0, 13, "kernel_idx");
          LoadInst * ld_kernel_idx = CreateLoadAligned(Builder, gep_kernel_idx, 4);

          BasicBlock * sw_default = BasicBlock::Create(linkMod_templContext, "sw.default", &f);
          BasicBlock * sw_epilog = BasicBlock::Create(linkMod_templContext, "sw.epilog", &f);

          SwitchInst * switch_default = Builder.CreateSwitch(ld_kernel_idx, sw_default, num_kernels);
          for(unsigned int cs = 0; cs < num_kernels; ++cs)
          {
            BasicBlock * sw_case = BasicBlock::Create(linkMod_templContext, "kernel_fini_case", &f, sw_default);
            Builder.SetInsertPoint(sw_case);

            Builder.CreateBr(sw_epilog);

            switch_default->addCase(ConstantInt::get(int32, cs), sw_case);
          }

          Builder.SetInsertPoint(sw_default);
          Builder.CreateBr(sw_epilog);

          Builder.SetInsertPoint(sw_epilog);
          Builder.CreateRetVoid();
          // f.dump(); DEBUG("");
        }

      }

      // Get the number of cores passed in when generating template code
      // Grab it from the old struct
      GlobalVariable * tlb_func_pool = linkMod_templ->getNamedGlobal("_ZL13tlb_func_pool");
      ArrayType * arr = dyn_cast<ArrayType>(tlb_func_pool->getType()->getElementType());
      unsigned int num_cores = arr->getNumElements();

      // Setup new pool
      std::vector<Constant*> zeros(num_kernels, const0);
      std::vector<Constant*> zero_init(num_cores, ConstantStruct::get(tlb_struct, zeros));
      Constant * arr_tlb_func = ConstantArray::get(ArrayType::get(tlb_struct, num_cores), zero_init);
      GlobalVariable * tlb_func_pool_new = new GlobalVariable(*linkMod_templ, arr_tlb_func->getType(), false, GlobalValue::InternalLinkage, arr_tlb_func, "tlb_func_pool_new");
      tlb_func_pool_new->setAlignment(4);
      
      for(Module::iterator fi = linkMod_templ->begin(); fi != linkMod_templ->end(); ++fi)
      {
        Function & f = *fi;
        if(f.getName().str().find("dev_entry") != std::string::npos) 
        {
          Instruction * tlb_func = NULL;
          
          // Find location of tlb_func first, then break
          for(inst_iterator ii = inst_begin(f); ii != inst_end(f); ++ii)
          {
            Instruction & inst = *ii;
            if(inst.getName().equals("tlb_func")) {
              // This is referenced by store
              tlb_func = &inst;
              break;
            }
          }

          if(tlb_func == NULL) {
            assert("tlb_func not found under dev_entry! Something is wrong with the code.");
          }

          for(inst_iterator ii = inst_begin(f); ii != inst_end(f); ++ii)
          {
            Instruction & inst = *ii;
            IRBuilder<> Builder(&inst);

            if(GetElementPtrInst * gepInst = dyn_cast<GetElementPtrInst>(&inst)) {
              if(gepInst->getType() == tlb_func_Pty) {
                Builder.SetInsertPoint(&inst);
                // grab pointers for load and store instruction around gepInst
                inst_iterator ld_iter = ii;
                Instruction & ld_id_addr = *(--ld_iter);
                inst_iterator st_iter = ii;
                Instruction & st_tlb_func = *(++st_iter);

                // Create new set of instructions to point to new struct
                std::vector<Value *> idx;
                idx.push_back(const0);
                idx.push_back(&ld_id_addr);
                Value* arrayidx = Builder.CreateGEP(tlb_func_pool_new, idx, "arrayidx");
                Value* bc_tlb_func_new = Builder.CreateBitCast(arrayidx, tlb_func_Pty, "bc");
                CreateStoreAligned(Builder, bc_tlb_func_new, tlb_func, 4);

                // Delete old struct
                st_tlb_func.eraseFromParent();
                inst.eraseFromParent();
                tlb_func_pool->eraseFromParent();

                break;
              }
            }
            
          }
          // f.dump();
        }
      }

      if(verifyModule(*linkMod_templ)) {
        errs() << ": Error constructing Module!\n";
        return 1;
      } 
      else {
        std::string ErrorInfo;
        std::string filename(linkModID.str());
        filename.append(".bc");
        raw_fd_ostream out(filename.c_str(), ErrorInfo);
        DEBUG(errs() << "Generating... " << filename);
        WriteBitcodeToFile(linkMod_templ, out);
      }

      return false;

    }

  };

}

char LinkWriter::ID = 0;
static RegisterPass<LinkWriter> X("linkwrite", "Analyze OpenCL kernel and write launch information");
