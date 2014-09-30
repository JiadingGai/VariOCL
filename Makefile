CPP := g++
CPPFLAGS = -Wall -g
RTTIFLAG := -fno-rtti
LLVMCONFIG := llvm-config
LLVMCOMPONENTS := #--libs bitwriter
LLVMCPPFLAGS := $(shell $(LLVMCONFIG) --cxxflags)
LLVMLDFLAGS := $(shell $(LLVMCONFIG) --ldflags $(LLVMCOMPONENTS))
LLVMVER := LLVM_34

MYUTIL = barrier_inst.cpp \
         barrier_utils.cpp \
         kernel_info_reader.cpp

MYPASS = LoopInserter.cpp \
         hive_off_barrier.cpp \
         context_spill.cpp \
         inline_devicefn.cpp \
         triplet_invariance_analysis.cpp \
         ControlDependence.cpp \
         OpenClAl.cpp \
         ThreadInvariance.cpp \
         IsolateRegions.cpp \
         kernel_info.cpp \
         ImplicitLoopBarriers.cpp \
         LoopBarriers.cpp \
         ImplicitConditionalBarriers.cpp \
         BarrierTailReplication.cpp \
         control_dependence.cpp \
         break_phi_to_alloca.cpp \
         split_bb_at_condbr.cpp \
         ImplicitCdgBarriers.cpp \
         test_modifier.cpp \
         BreakConstantGEPs.cpp 

UTIL_OBJS=$(MYUTIL:.cpp=.o)
PASS_OBJS=$(MYPASS:.cpp=.o)
SOS=$(PASS_OBJS:.o=.so)

all:$(SOS)
%.so:$(UTIL_OBJS) %.o
	$(CPP) -shared -o $@ $^ $(LLVMLDFLAGS) -Wall
%.o:%.cpp 
	$(CPP) -fPIC -g -c $^ $(LLVMCPPFLAGS) -Wall -D$(LLVMVER)
clean:
	rm -f *.so *.o *.bc *.gch *.dot .*.sw*

