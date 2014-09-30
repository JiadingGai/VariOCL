; ModuleID = 'kernel_26ab1acf10f33a2a19ebb171cec0a30c.b.cl'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.tlb_data = type { i32, [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], i32, i32, i32 }

@TLB = common global %struct.tlb_data zeroinitializer, align 4

; Function Attrs: nounwind uwtable
define void @compute_sum_with_localmem(i32* %a, i32 %n, i32* %tmp_sum, i32* %sum) #0 {
entry:
  %a.addr = alloca i32*, align 8
  %n.addr = alloca i32, align 4
  %tmp_sum.addr = alloca i32*, align 8
  %sum.addr = alloca i32*, align 8
  %tid = alloca i32, align 4
  %lsize = alloca i32, align 4
  %i = alloca i32, align 4
  %sum14 = alloca i32, align 4
  store i32* %a, i32** %a.addr, align 8
  store i32 %n, i32* %n.addr, align 4
  store i32* %tmp_sum, i32** %tmp_sum.addr, align 8
  store i32* %sum, i32** %sum.addr, align 8
  %call = call i32 @get_local_id(i32 0)
  store i32 %call, i32* %tid, align 4
  %call1 = call i32 @get_local_size(i32 0)
  store i32 %call1, i32* %lsize, align 4
  %0 = load i32* %tid, align 4
  %idxprom = sext i32 %0 to i64
  %1 = load i32** %tmp_sum.addr, align 8
  %arrayidx = getelementptr inbounds i32* %1, i64 %idxprom
  store i32 0, i32* %arrayidx, align 4
  %2 = load i32* %tid, align 4
  store i32 %2, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %3 = load i32* %i, align 4
  %4 = load i32* %n.addr, align 4
  %cmp = icmp slt i32 %3, %4
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %5 = load i32* %i, align 4
  %idxprom2 = sext i32 %5 to i64
  %6 = load i32** %a.addr, align 8
  %arrayidx3 = getelementptr inbounds i32* %6, i64 %idxprom2
  %7 = load i32* %arrayidx3, align 4
  %8 = load i32* %tid, align 4
  %idxprom4 = sext i32 %8 to i64
  %9 = load i32** %tmp_sum.addr, align 8
  %arrayidx5 = getelementptr inbounds i32* %9, i64 %idxprom4
  %10 = load i32* %arrayidx5, align 4
  %add = add nsw i32 %10, %7
  store i32 %add, i32* %arrayidx5, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %11 = load i32* %lsize, align 4
  %12 = load i32* %i, align 4
  %add6 = add nsw i32 %12, %11
  store i32 %add6, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %13 = load i32* %lsize, align 4
  %cmp7 = icmp eq i32 %13, 1
  br i1 %cmp7, label %if.then, label %if.end11

if.then:                                          ; preds = %for.end
  %14 = load i32* %tid, align 4
  %cmp8 = icmp eq i32 %14, 0
  br i1 %cmp8, label %if.then9, label %if.end

if.then9:                                         ; preds = %if.then
  %15 = load i32** %tmp_sum.addr, align 8
  %arrayidx10 = getelementptr inbounds i32* %15, i64 0
  %16 = load i32* %arrayidx10, align 4
  %17 = load i32** %sum.addr, align 8
  store i32 %16, i32* %17, align 4
  br label %if.end

if.end:                                           ; preds = %if.then9, %if.then
  br label %if.end37

if.end11:                                         ; preds = %for.end
  br label %do.body

do.body:                                          ; preds = %do.cond, %if.end11
  call void @barrier(i32 1)
  %18 = load i32* %tid, align 4
  %19 = load i32* %lsize, align 4
  %div = sdiv i32 %19, 2
  %cmp12 = icmp slt i32 %18, %div
  br i1 %cmp12, label %if.then13, label %if.end31

if.then13:                                        ; preds = %do.body
  %20 = load i32* %tid, align 4
  %idxprom15 = sext i32 %20 to i64
  %21 = load i32** %tmp_sum.addr, align 8
  %arrayidx16 = getelementptr inbounds i32* %21, i64 %idxprom15
  %22 = load i32* %arrayidx16, align 4
  store i32 %22, i32* %sum14, align 4
  %23 = load i32* %lsize, align 4
  %and = and i32 %23, 1
  %tobool = icmp ne i32 %and, 0
  br i1 %tobool, label %land.lhs.true, label %if.end23

land.lhs.true:                                    ; preds = %if.then13
  %24 = load i32* %tid, align 4
  %cmp17 = icmp eq i32 %24, 0
  br i1 %cmp17, label %if.then18, label %if.end23

if.then18:                                        ; preds = %land.lhs.true
  %25 = load i32* %tid, align 4
  %26 = load i32* %lsize, align 4
  %add19 = add nsw i32 %25, %26
  %sub = sub nsw i32 %add19, 1
  %idxprom20 = sext i32 %sub to i64
  %27 = load i32** %tmp_sum.addr, align 8
  %arrayidx21 = getelementptr inbounds i32* %27, i64 %idxprom20
  %28 = load i32* %arrayidx21, align 4
  %29 = load i32* %sum14, align 4
  %add22 = add nsw i32 %29, %28
  store i32 %add22, i32* %sum14, align 4
  br label %if.end23

if.end23:                                         ; preds = %if.then18, %land.lhs.true, %if.then13
  %30 = load i32* %sum14, align 4
  %31 = load i32* %tid, align 4
  %32 = load i32* %lsize, align 4
  %div24 = sdiv i32 %32, 2
  %add25 = add nsw i32 %31, %div24
  %idxprom26 = sext i32 %add25 to i64
  %33 = load i32** %tmp_sum.addr, align 8
  %arrayidx27 = getelementptr inbounds i32* %33, i64 %idxprom26
  %34 = load i32* %arrayidx27, align 4
  %add28 = add nsw i32 %30, %34
  %35 = load i32* %tid, align 4
  %idxprom29 = sext i32 %35 to i64
  %36 = load i32** %tmp_sum.addr, align 8
  %arrayidx30 = getelementptr inbounds i32* %36, i64 %idxprom29
  store i32 %add28, i32* %arrayidx30, align 4
  br label %if.end31

if.end31:                                         ; preds = %if.end23, %do.body
  %37 = load i32* %lsize, align 4
  %div32 = sdiv i32 %37, 2
  store i32 %div32, i32* %lsize, align 4
  br label %do.cond

do.cond:                                          ; preds = %if.end31
  %38 = load i32* %lsize, align 4
  %tobool33 = icmp ne i32 %38, 0
  br i1 %tobool33, label %do.body, label %do.end

do.end:                                           ; preds = %do.cond
  %39 = load i32* %tid, align 4
  %cmp34 = icmp eq i32 %39, 0
  br i1 %cmp34, label %if.then35, label %if.end37

if.then35:                                        ; preds = %do.end
  %40 = load i32** %tmp_sum.addr, align 8
  %arrayidx36 = getelementptr inbounds i32* %40, i64 0
  %41 = load i32* %arrayidx36, align 4
  %42 = load i32** %sum.addr, align 8
  store i32 %41, i32* %42, align 4
  br label %if.end37

if.end37:                                         ; preds = %if.end, %if.then35, %do.end
  ret void
}

declare i32 @get_local_id(i32) #1

declare i32 @get_local_size(i32) #1

declare void @barrier(i32) #1

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!opencl.kernels = !{!0}
!llvm.ident = !{!1}

!0 = metadata !{void (i32*, i32, i32*, i32*)* @compute_sum_with_localmem}
!1 = metadata !{metadata !"clang version 3.4 (tags/RELEASE_34/final)"}
