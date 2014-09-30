#!/bin/bash
CONFDIR=/home/jiading/Desktop/projects/OpenCL_1_1_Tests_r16810_mxpa
PDIR=/home/jiading/Desktop/projects/socl-llvm/src
LLVM_BIN=$(llvm-config --bindir)
ALLCLFILES=$(find $CONFDIR -name *.cl)


Count=0
for afilepath in $ALLCLFILES
do
  afilename=${afilepath##*/}

  NumBarrier=$(grep -c "barrier" $afilepath)

  if [ $NumBarrier -gt 0 ]; then
    echo "----------------> $Count : $afilename has $NumBarrier barriers ($afilepath)."
    Count=$((Count+1))

    $LLVM_BIN/clang -cc1 -triple spir-unknown-unknown -cl-kernel-arg-info -cl-fast-relaxed-math -cl-std=CL1.2 -S -O0 -emit-llvm -Wno-implicit-function-declaration -fno-builtin -include /home/jiading/Desktop/tmp/socl-llvm/include/opencl_runtime.h -o $afilename.ll -x cl $afilepath  -DDOUBLE_SUPPORT

    $LLVM_BIN/opt -S  -mem2reg -mergereturn -loop-simplify -instcombine -load $PDIR/inline_devicefn.so -load $PDIR/break_phi_to_alloca.so -load $PDIR/triplet_invariance_analysis.so -load $PDIR/ImplicitLoopBarriers.so -load $PDIR/ImplicitConditionalBarriers.so -load $PDIR/LoopBarriers.so  -load $PDIR/BarrierTailReplication.so -load $PDIR/hive_off_barrier.so -load $PDIR/control_dependence.so -load $PDIR/LoopInserter.so -mxpa_inliner -always-inline -mxpa_IPBreakPhi -implicit-loop-barriers -implicit-cond-barriers -loop-barriers -barriertails -mxpa_hiveoffbarrier -mxpa_triplet_invariance_analysis -mxpa_IPLoopInserter -debug-only=ms5 < $afilename.ll 

  fi

done

echo "Final count = $Count"
