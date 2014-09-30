; ModuleID = 'ms51.b.cl'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.tlb_data = type { i32, [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], i32, i32, i32 }

@TLB = common global %struct.tlb_data zeroinitializer, align 4

; Function Attrs: nounwind uwtable
define void @ms51(i32* %A, i32* %B, i32 %n) #0 {
entry:
  %A.addr = alloca i32*, align 8
  %B.addr = alloca i32*, align 8
  %n.addr = alloca i32, align 4
  %tid = alloca i32, align 4
  %lsz = alloca i32, align 4
  %i = alloca i32, align 4
  store i32* %A, i32** %A.addr, align 8
  store i32* %B, i32** %B.addr, align 8
  store i32 %n, i32* %n.addr, align 4
  store i32 0, i32* %tid, align 4
  %call = call i32 @get_local_size(i32 0)
  store i32 %call, i32* %lsz, align 4
  %0 = load i32* %lsz, align 4
  %cmp = icmp sgt i32 %0, 1
  br i1 %cmp, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %call1 = call i32 @get_local_id(i32 0)
  store i32 %call1, i32* %tid, align 4
  %1 = load i32* %tid, align 4
  %rem = srem i32 %1, 2
  %tobool = icmp ne i32 %rem, 0
  br i1 %tobool, label %if.then2, label %if.end

if.then2:                                         ; preds = %if.then
  %2 = load i32* %tid, align 4
  %3 = load i32* %tid, align 4
  %idxprom = sext i32 %3 to i64
  %4 = load i32** %A.addr, align 8
  %arrayidx = getelementptr inbounds i32* %4, i64 %idxprom
  store i32 %2, i32* %arrayidx, align 4
  br label %if.end

if.end:                                           ; preds = %if.then2, %if.then
  call void @barrier(i32 0)
  br label %if.end5

if.else:                                          ; preds = %entry
  %5 = load i32* %tid, align 4
  %idxprom3 = sext i32 %5 to i64
  %6 = load i32** %A.addr, align 8
  %arrayidx4 = getelementptr inbounds i32* %6, i64 %idxprom3
  store i32 -1, i32* %arrayidx4, align 4
  br label %if.end5

if.end5:                                          ; preds = %if.else, %if.end
  call void @barrier(i32 0)
  %7 = load i32* %tid, align 4
  %cmp6 = icmp eq i32 %7, 0
  br i1 %cmp6, label %if.then7, label %if.end13

if.then7:                                         ; preds = %if.end5
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %if.then7
  %8 = load i32* %i, align 4
  %9 = load i32* %lsz, align 4
  %cmp8 = icmp slt i32 %8, %9
  br i1 %cmp8, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %10 = load i32* %i, align 4
  %idxprom9 = sext i32 %10 to i64
  %11 = load i32** %A.addr, align 8
  %arrayidx10 = getelementptr inbounds i32* %11, i64 %idxprom9
  %12 = load i32* %arrayidx10, align 4
  %13 = load i32* %i, align 4
  %idxprom11 = sext i32 %13 to i64
  %14 = load i32** %B.addr, align 8
  %arrayidx12 = getelementptr inbounds i32* %14, i64 %idxprom11
  store i32 %12, i32* %arrayidx12, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %15 = load i32* %i, align 4
  %inc = add nsw i32 %15, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  br label %if.end13

if.end13:                                         ; preds = %for.end, %if.end5
  ret void
}

declare i32 @get_local_size(i32) #1

declare i32 @get_local_id(i32) #1

declare void @barrier(i32) #1

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!opencl.kernels = !{!0}
!llvm.ident = !{!1}

!0 = metadata !{void (i32*, i32*, i32)* @ms51}
!1 = metadata !{metadata !"clang version 3.4 (tags/RELEASE_34/final)"}
