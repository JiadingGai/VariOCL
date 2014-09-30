; ModuleID = 'bar_fence.b.cl'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.tlb_data = type { i32, [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], i32, i32, i32 }

@TLB = common global %struct.tlb_data zeroinitializer, align 4

; Function Attrs: nounwind uwtable
define void @bar_fence(i32* %sum_wg, i32* %sum_per_wi, i32* %Sum_final) #0 {
entry:
  %sum_wg.addr = alloca i32*, align 8
  %sum_per_wi.addr = alloca i32*, align 8
  %Sum_final.addr = alloca i32*, align 8
  %gid = alloca i32, align 4
  %lid = alloca i32, align 4
  %lsz = alloca i32, align 4
  %sum = alloca i32, align 4
  %start = alloca i32, align 4
  %i = alloca i32, align 4
  %tmp = alloca i32, align 4
  %i8 = alloca i32, align 4
  %final = alloca i32, align 4
  %i24 = alloca i32, align 4
  store i32* %sum_wg, i32** %sum_wg.addr, align 8
  store i32* %sum_per_wi, i32** %sum_per_wi.addr, align 8
  store i32* %Sum_final, i32** %Sum_final.addr, align 8
  %call = call i32 @get_group_id(i32 0)
  store i32 %call, i32* %gid, align 4
  %call1 = call i32 @get_local_id(i32 0)
  store i32 %call1, i32* %lid, align 4
  %call2 = call i32 @get_local_size(i32 0)
  store i32 %call2, i32* %lsz, align 4
  store i32 0, i32* %sum, align 4
  %0 = load i32* %gid, align 4
  %mul = mul nsw i32 %0, 10000
  %1 = load i32* %lid, align 4
  %mul3 = mul nsw i32 %1, 100
  %add = add nsw i32 %mul, %mul3
  store i32 %add, i32* %start, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %2 = load i32* %i, align 4
  %cmp = icmp slt i32 %2, 100
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %3 = load i32* %start, align 4
  %4 = load i32* %sum, align 4
  %add4 = add nsw i32 %4, %3
  store i32 %add4, i32* %sum, align 4
  %5 = load i32* %start, align 4
  %inc = add nsw i32 %5, 1
  store i32 %inc, i32* %start, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %6 = load i32* %i, align 4
  %inc5 = add nsw i32 %6, 1
  store i32 %inc5, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %7 = load i32* %sum, align 4
  %8 = load i32* %lid, align 4
  %idxprom = sext i32 %8 to i64
  %9 = load i32** %sum_per_wi.addr, align 8
  %arrayidx = getelementptr inbounds i32* %9, i64 %idxprom
  store i32 %7, i32* %arrayidx, align 4
  call void @barrier(i32 1)
  %10 = load i32* %lid, align 4
  %cmp6 = icmp eq i32 %10, 0
  br i1 %cmp6, label %if.then, label %if.end

if.then:                                          ; preds = %for.end
  store i32 0, i32* %tmp, align 4
  store i32 0, i32* %i8, align 4
  br label %for.cond9

for.cond9:                                        ; preds = %for.inc15, %if.then
  %11 = load i32* %i8, align 4
  %12 = load i32* %lsz, align 4
  %cmp10 = icmp slt i32 %11, %12
  br i1 %cmp10, label %for.body11, label %for.end17

for.body11:                                       ; preds = %for.cond9
  %13 = load i32* %i8, align 4
  %idxprom12 = sext i32 %13 to i64
  %14 = load i32** %sum_per_wi.addr, align 8
  %arrayidx13 = getelementptr inbounds i32* %14, i64 %idxprom12
  %15 = load i32* %arrayidx13, align 4
  %16 = load i32* %tmp, align 4
  %add14 = add nsw i32 %16, %15
  store i32 %add14, i32* %tmp, align 4
  br label %for.inc15

for.inc15:                                        ; preds = %for.body11
  %17 = load i32* %i8, align 4
  %inc16 = add nsw i32 %17, 1
  store i32 %inc16, i32* %i8, align 4
  br label %for.cond9

for.end17:                                        ; preds = %for.cond9
  %18 = load i32* %tmp, align 4
  %19 = load i32* %gid, align 4
  %idxprom18 = sext i32 %19 to i64
  %20 = load i32** %sum_wg.addr, align 8
  %arrayidx19 = getelementptr inbounds i32* %20, i64 %idxprom18
  store i32 %18, i32* %arrayidx19, align 4
  br label %if.end

if.end:                                           ; preds = %for.end17, %for.end
  call void @barrier(i32 1)
  %21 = load i32* %gid, align 4
  %cmp20 = icmp eq i32 %21, 0
  br i1 %cmp20, label %if.then21, label %if.end34

if.then21:                                        ; preds = %if.end
  store i32 0, i32* %final, align 4
  store i32 0, i32* %i24, align 4
  br label %for.cond25

for.cond25:                                       ; preds = %for.inc31, %if.then21
  %22 = load i32* %i24, align 4
  %cmp26 = icmp slt i32 %22, 1
  br i1 %cmp26, label %for.body27, label %for.end33

for.body27:                                       ; preds = %for.cond25
  %23 = load i32* %i24, align 4
  %idxprom28 = sext i32 %23 to i64
  %24 = load i32** %sum_wg.addr, align 8
  %arrayidx29 = getelementptr inbounds i32* %24, i64 %idxprom28
  %25 = load i32* %arrayidx29, align 4
  %26 = load i32* %final, align 4
  %add30 = add nsw i32 %26, %25
  store i32 %add30, i32* %final, align 4
  br label %for.inc31

for.inc31:                                        ; preds = %for.body27
  %27 = load i32* %i24, align 4
  %inc32 = add nsw i32 %27, 1
  store i32 %inc32, i32* %i24, align 4
  br label %for.cond25

for.end33:                                        ; preds = %for.cond25
  %28 = load i32* %final, align 4
  %29 = load i32** %Sum_final.addr, align 8
  store i32 %28, i32* %29, align 4
  br label %if.end34

if.end34:                                         ; preds = %for.end33, %if.end
  ret void
}

declare i32 @get_group_id(i32) #1

declare i32 @get_local_id(i32) #1

declare i32 @get_local_size(i32) #1

declare void @barrier(i32) #1

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!opencl.kernels = !{!0}
!llvm.ident = !{!1}

!0 = metadata !{void (i32*, i32*, i32*)* @bar_fence}
!1 = metadata !{metadata !"clang version 3.4 (tags/RELEASE_34/final)"}
