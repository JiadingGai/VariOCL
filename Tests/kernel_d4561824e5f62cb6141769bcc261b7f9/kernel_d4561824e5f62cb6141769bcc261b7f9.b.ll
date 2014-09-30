; ModuleID = 'kernel_d4561824e5f62cb6141769bcc261b7f9.b.cl'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.tlb_data = type { i32, [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], i32, i32, i32 }

@compute_sum_with_localmem.tmp_sum = internal global [512 x i32] zeroinitializer, align 16
@TLB = common global %struct.tlb_data zeroinitializer, align 4

; Function Attrs: nounwind uwtable
define void @compute_sum_with_localmem(i32* %a, i32 %n, i32* %sum) #0 {
entry:
  %a.addr = alloca i32*, align 8
  %n.addr = alloca i32, align 4
  %sum.addr = alloca i32*, align 8
  %tid = alloca i32, align 4
  %lsize = alloca i32, align 4
  %i = alloca i32, align 4
  %sum13 = alloca i32, align 4
  store i32* %a, i32** %a.addr, align 8
  store i32 %n, i32* %n.addr, align 4
  store i32* %sum, i32** %sum.addr, align 8
  %call = call i32 @get_local_id(i32 0)
  store i32 %call, i32* %tid, align 4
  %call1 = call i32 @get_local_size(i32 0)
  store i32 %call1, i32* %lsize, align 4
  %0 = load i32* %tid, align 4
  %idxprom = sext i32 %0 to i64
  %arrayidx = getelementptr inbounds [512 x i32]* @compute_sum_with_localmem.tmp_sum, i32 0, i64 %idxprom
  store i32 0, i32* %arrayidx, align 4
  %1 = load i32* %tid, align 4
  store i32 %1, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %2 = load i32* %i, align 4
  %3 = load i32* %n.addr, align 4
  %cmp = icmp slt i32 %2, %3
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %4 = load i32* %i, align 4
  %idxprom2 = sext i32 %4 to i64
  %5 = load i32** %a.addr, align 8
  %arrayidx3 = getelementptr inbounds i32* %5, i64 %idxprom2
  %6 = load i32* %arrayidx3, align 4
  %7 = load i32* %tid, align 4
  %idxprom4 = sext i32 %7 to i64
  %arrayidx5 = getelementptr inbounds [512 x i32]* @compute_sum_with_localmem.tmp_sum, i32 0, i64 %idxprom4
  %8 = load i32* %arrayidx5, align 4
  %add = add nsw i32 %8, %6
  store i32 %add, i32* %arrayidx5, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %9 = load i32* %lsize, align 4
  %10 = load i32* %i, align 4
  %add6 = add nsw i32 %10, %9
  store i32 %add6, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %11 = load i32* %lsize, align 4
  %cmp7 = icmp eq i32 %11, 1
  br i1 %cmp7, label %if.then, label %if.end10

if.then:                                          ; preds = %for.end
  %12 = load i32* %tid, align 4
  %cmp8 = icmp eq i32 %12, 0
  br i1 %cmp8, label %if.then9, label %if.end

if.then9:                                         ; preds = %if.then
  %13 = load i32* getelementptr inbounds ([512 x i32]* @compute_sum_with_localmem.tmp_sum, i32 0, i64 0), align 4
  %14 = load i32** %sum.addr, align 8
  store i32 %13, i32* %14, align 4
  br label %if.end

if.end:                                           ; preds = %if.then9, %if.then
  br label %if.end35

if.end10:                                         ; preds = %for.end
  br label %do.body

do.body:                                          ; preds = %do.cond, %if.end10
  call void @barrier(i32 1)
  %15 = load i32* %tid, align 4
  %16 = load i32* %lsize, align 4
  %div = sdiv i32 %16, 2
  %cmp11 = icmp slt i32 %15, %div
  br i1 %cmp11, label %if.then12, label %if.end30

if.then12:                                        ; preds = %do.body
  %17 = load i32* %tid, align 4
  %idxprom14 = sext i32 %17 to i64
  %arrayidx15 = getelementptr inbounds [512 x i32]* @compute_sum_with_localmem.tmp_sum, i32 0, i64 %idxprom14
  %18 = load i32* %arrayidx15, align 4
  store i32 %18, i32* %sum13, align 4
  %19 = load i32* %lsize, align 4
  %and = and i32 %19, 1
  %tobool = icmp ne i32 %and, 0
  br i1 %tobool, label %land.lhs.true, label %if.end22

land.lhs.true:                                    ; preds = %if.then12
  %20 = load i32* %tid, align 4
  %cmp16 = icmp eq i32 %20, 0
  br i1 %cmp16, label %if.then17, label %if.end22

if.then17:                                        ; preds = %land.lhs.true
  %21 = load i32* %tid, align 4
  %22 = load i32* %lsize, align 4
  %add18 = add nsw i32 %21, %22
  %sub = sub nsw i32 %add18, 1
  %idxprom19 = sext i32 %sub to i64
  %arrayidx20 = getelementptr inbounds [512 x i32]* @compute_sum_with_localmem.tmp_sum, i32 0, i64 %idxprom19
  %23 = load i32* %arrayidx20, align 4
  %24 = load i32* %sum13, align 4
  %add21 = add nsw i32 %24, %23
  store i32 %add21, i32* %sum13, align 4
  br label %if.end22

if.end22:                                         ; preds = %if.then17, %land.lhs.true, %if.then12
  %25 = load i32* %sum13, align 4
  %26 = load i32* %tid, align 4
  %27 = load i32* %lsize, align 4
  %div23 = sdiv i32 %27, 2
  %add24 = add nsw i32 %26, %div23
  %idxprom25 = sext i32 %add24 to i64
  %arrayidx26 = getelementptr inbounds [512 x i32]* @compute_sum_with_localmem.tmp_sum, i32 0, i64 %idxprom25
  %28 = load i32* %arrayidx26, align 4
  %add27 = add nsw i32 %25, %28
  %29 = load i32* %tid, align 4
  %idxprom28 = sext i32 %29 to i64
  %arrayidx29 = getelementptr inbounds [512 x i32]* @compute_sum_with_localmem.tmp_sum, i32 0, i64 %idxprom28
  store i32 %add27, i32* %arrayidx29, align 4
  br label %if.end30

if.end30:                                         ; preds = %if.end22, %do.body
  %30 = load i32* %lsize, align 4
  %div31 = sdiv i32 %30, 2
  store i32 %div31, i32* %lsize, align 4
  br label %do.cond

do.cond:                                          ; preds = %if.end30
  %31 = load i32* %lsize, align 4
  %tobool32 = icmp ne i32 %31, 0
  br i1 %tobool32, label %do.body, label %do.end

do.end:                                           ; preds = %do.cond
  %32 = load i32* %tid, align 4
  %cmp33 = icmp eq i32 %32, 0
  br i1 %cmp33, label %if.then34, label %if.end35

if.then34:                                        ; preds = %do.end
  %33 = load i32* getelementptr inbounds ([512 x i32]* @compute_sum_with_localmem.tmp_sum, i32 0, i64 0), align 4
  %34 = load i32** %sum.addr, align 8
  store i32 %33, i32* %34, align 4
  br label %if.end35

if.end35:                                         ; preds = %if.end, %if.then34, %do.end
  ret void
}

declare i32 @get_local_id(i32) #1

declare i32 @get_local_size(i32) #1

declare void @barrier(i32) #1

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!opencl.kernels = !{!0}
!llvm.ident = !{!1}

!0 = metadata !{void (i32*, i32, i32*)* @compute_sum_with_localmem}
!1 = metadata !{metadata !"clang version 3.4 (tags/RELEASE_34/final)"}
