; ModuleID = 'forifbarrier1.cl'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.tlb_data = type { i32, [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], i32, i32, i32 }

@TLB = common global %struct.tlb_data zeroinitializer, align 4

; Function Attrs: nounwind uwtable
define void @forifbarrier1(i32 %n) #0 {
entry:
  %n.addr = alloca i32, align 4
  %lid0 = alloca i32, align 4
  %lsz0 = alloca i32, align 4
  %lid1 = alloca i32, align 4
  %lsz1 = alloca i32, align 4
  %lid2 = alloca i32, align 4
  %lsz2 = alloca i32, align 4
  %i = alloca i32, align 4
  store i32 %n, i32* %n.addr, align 4
  %call = call i32 @get_local_id(i32 0)
  store i32 %call, i32* %lid0, align 4
  %call1 = call i32 @get_local_size(i32 0)
  store i32 %call1, i32* %lsz0, align 4
  %call2 = call i32 @get_local_id(i32 1)
  store i32 %call2, i32* %lid1, align 4
  %call3 = call i32 @get_local_size(i32 1)
  store i32 %call3, i32* %lsz1, align 4
  %call4 = call i32 @get_local_id(i32 2)
  store i32 %call4, i32* %lid2, align 4
  %call5 = call i32 @get_local_size(i32 2)
  store i32 %call5, i32* %lsz2, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i32* %i, align 4
  %cmp = icmp slt i32 %0, 10
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  call void @barrier(i32 1)
  %1 = load i32* %lid0, align 4
  call void @A(i32 %1)
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %2 = load i32* %i, align 4
  %inc = add nsw i32 %2, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  ret void
}

declare i32 @get_local_id(i32) #1

declare i32 @get_local_size(i32) #1

declare void @barrier(i32) #1

declare void @A(i32) #1

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!opencl.kernels = !{!0}
!llvm.ident = !{!1}

!0 = metadata !{void (i32)* @forifbarrier1}
!1 = metadata !{metadata !"clang version 3.4 (tags/RELEASE_34/final)"}
