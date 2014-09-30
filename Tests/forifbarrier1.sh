#!/bin/bash
clang -S -O0 -emit-llvm -o forifbarrier1.ll -x cl forifbarrier1.cl
opt -S -mem2reg -mergereturn -globaldce -simplifycfg -loop-simplify -instcombine -inline < forifbarrier1.ll > forifbarrier1.2.ll

#opt -S -load ../triplet_invariance_analysis.so -mxpa_triplet_invariance_analysis -load ../ImplicitLoopBarriers.so -implicit-loop-barriers -load ../hive_off_barrier.so -mxpa_hiveoffbarrier < forifbarrier1.2.ll > forifbarrier1.3.ll
opt -S -load ../LoopBarriers.so -loop-barriers  < forifbarrier1.2.ll > forifbarrier1.3.ll
#opt -S -load ../ImplicitConditionalBarriers.so -implicit-cond-barriers -load ../LoopBarriers.so -loop-barriers -load ../BarrierTailReplication.so -barriertails -load ../hive_off_barrier.so -mxpa_hiveoffbarrier < forifbarrier1.2.ll > forifbarrier1.3.ll
#opt -S -load ../BarrierTailReplication.so -barriertails  -load ../hive_off_barrier.so -mxpa_hiveoffbarrier < forifbarrier1.2.ll > forifbarrier1.3.ll
opt -S -view-regions < forifbarrier1.3.ll
