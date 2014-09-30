#!/bin/bash
LLVM_BIN=$(llvm-config --bindir)
DOT_VIEWER=xdot
PDIR=$(pwd)
make clean;make -j12


if [ $? -ne 0 ]
then
    echo "MXPA: BUILDing FAILed"
    exit 1
else
    case "$1" in

    0) TEST=kernel_26ab1acf10f33a2a19ebb171cec0a30c
       TDIR=Tests/$TEST
       KRNLNM=compute_sum_with_localmem
       xDim=8
       yDim=1
       zDim=1
       ;;    
    1) TEST=kernel_d4561824e5f62cb6141769bcc261b7f9
       TDIR=Tests/$TEST
       KRNLNM=compute_sum_with_localmem
       xDim=8
       yDim=1
       zDim=1
       ;;
    2) TEST=context_switch_0
       TDIR=Tests/$TEST
       KRNLNM=b
       xDim=1
       yDim=2
       zDim=4
       ;;
    3) TEST=kernel_f7f7d374e191f6d0e79be5f39cb5f186
       TDIR=Tests/$TEST
       KRNLNM=test_fn
       xDim=256
       yDim=1
       zDim=1
       ;;
    4) TEST=vector_add_kernel
       TDIR=Tests/$TEST
       KRNLNM=vector_add
       xDim=1
       yDim=2
       zDim=4
       ;;
    5) TEST=bar_fence
       TDIR=Tests/$TEST
       KRNLNM=bar_fence
       xDim=8
       yDim=1
       zDim=1
       ;;
    6) TEST=local_memtest
       TDIR=Tests/$TEST
       KRNLNM=bar
       xDim=8
       yDim=1
       zDim=1
       ;;
    7) TEST=kernel_930c5f285dc597ffc43a41d664870439
       TDIR=Tests/$TEST
       KRNLNM=compute_sum
       xDim=8
       yDim=1
       zDim=1
       ;;
    8) TEST=mm
       TDIR=Tests/$TEST
       KRNLNM=matrixMul
       xDim=4
       yDim=4
       zDim=1
       ;;
    9) TEST=ms51
       TDIR=Tests/$TEST
       KRNLNM=ms51
       xDim=8
       yDim=1
       zDim=1
       ;;
    10) TEST=natlop_2exits
       TDIR=Tests/$TEST
       KRNLNM=natlop_2exits
       xDim=1
       yDim=2
       zDim=4
       ;;
    *) echo "Test case number $1 is not processed"
       exit;
       ;;
    esac
 
    cd $TDIR
    rm -f *.bc *.ll
    pkill $DOT_VIEWER

    echo "\n\n -> Go modify the test_modifier pass for the test case $TEST [OK]?!"
#read  YN

    $LLVM_BIN/clang -S -O0 -emit-llvm -o $TEST.a.ll $TEST.a.c
    $LLVM_BIN/llvm-as $TEST.a.ll
    
    $LLVM_BIN/clang -S -O0 -emit-llvm -o $TEST.b.ll -x cl $TEST.b.cl
    
#$LLVM_BIN/opt -S  -mem2reg -mergereturn -loop-simplify -instcombine -load $PDIR/BreakConstantGEPs.so -load $PDIR/IsolateRegions.so -load $PDIR/inline_devicefn.so -load $PDIR/break_phi_to_alloca.so -load $PDIR/triplet_invariance_analysis.so -load $PDIR/ImplicitLoopBarriers.so -load $PDIR/ImplicitConditionalBarriers.so -load $PDIR/LoopBarriers.so  -load $PDIR/BarrierTailReplication.so -load $PDIR/hive_off_barrier.so -load $PDIR/control_dependence.so -load $PDIR/split_bb_at_condbr.so -load $PDIR/LoopInserter.so -break-constgeps -mxpa_inliner -always-inline -mxpa_IPBreakPhi -isolate-regions -implicit-loop-barriers -implicit-cond-barriers -loop-barriers -view-regions -barriertails -mxpa_hiveoffbarrier -mxpa_triplet_invariance_analysis -mxpa_IPLoopInserter -debug-only=mxpa_ms5 < $TEST.b.ll 
    $LLVM_BIN/opt -S -mem2reg -mergereturn -globaldce -simplifycfg -loop-simplify -load $PDIR/BreakConstantGEPs.so -load $PDIR/IsolateRegions.so -load $PDIR/inline_devicefn.so -load $PDIR/control_dependence.so -load $PDIR/break_phi_to_alloca.so -load $PDIR/triplet_invariance_analysis.so -load $PDIR/ImplicitLoopBarriers.so -load $PDIR/ImplicitConditionalBarriers.so -load $PDIR/LoopBarriers.so -load $PDIR/ImplicitCdgBarriers.so -load $PDIR/BarrierTailReplication.so -load $PDIR/hive_off_barrier.so -load $PDIR/split_bb_at_condbr.so -load $PDIR/LoopInserter.so -break-constgeps -mxpa_inliner -always-inline -mxpa_IPBreakPhi -isolate-regions -mxpa_implicit-cdg-barriers -implicit-cond-barriers -loop-barriers -barriertails -mxpa_hiveoffbarrier -mxpa_triplet_invariance_analysis -mxpa_IPLoopInserter < $TEST.b.ll 
#    $LLVM_BIN/opt -S  -mem2reg -mergereturn -loop-simplify -instcombine -load $PDIR/BreakConstantGEPs.so -load $PDIR/IsolateRegions.so -load $PDIR/inline_devicefn.so -load $PDIR/break_phi_to_alloca.so -load $PDIR/triplet_invariance_analysis.so -load $PDIR/control_dependence.so -load $PDIR/ImplicitCdgBarriers.so -load $PDIR/BarrierTailReplication.so -load $PDIR/hive_off_barrier.so -load $PDIR/control_dependence.so -load $PDIR/split_bb_at_condbr.so -load $PDIR/LoopInserter.so -break-constgeps -mxpa_inliner -always-inline -mxpa_IPBreakPhi -view-regions -isolate-regions -mxpa_implicit-cdg-barriers -view-regions -barriertails -mxpa_hiveoffbarrier -mxpa_triplet_invariance_analysis -mxpa_IPLoopInserter -debug-only=mxpa_ms5 < $TEST.b.ll 

 
    echo "**********************  4. Modify the gen code **********************"
    opt -load $PDIR/test_modifier.so -mxpa_testmod -local-size=$xDim $yDim $zDim __cl_kernel.bc > tmp.bc
    mv tmp.bc __cl_kernel.bc
    llvm-link $TEST.a.bc __cl_kernel.bc > main.bc
    lli < main.bc

fi

