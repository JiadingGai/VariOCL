#!/bin/bash
PDIR=/home/jiading/Desktop/projects/socl-llvm/src/

opt -S  -mem2reg -mergereturn -loop-simplify -instcombine -load $PDIR/inline_devicefn.so -load $PDIR/break_phi_to_alloca.so -load $PDIR/triplet_invariance_analysis.so -load $PDIR/ImplicitLoopBarriers.so -load $PDIR/ImplicitConditionalBarriers.so -load $PDIR/LoopBarriers.so  -load $PDIR/BarrierTailReplication.so -load $PDIR/hive_off_barrier.so -load $PDIR/control_dependence.so -load $PDIR/LoopInserter.so -mxpa_inliner -always-inline -mxpa_IPBreakPhi -implicit-loop-barriers -implicit-cond-barriers -loop-barriers -barriertails -mxpa_hiveoffbarrier -mxpa_triplet_invariance_analysis -mxpa_IPLoopInserter < b.ll
