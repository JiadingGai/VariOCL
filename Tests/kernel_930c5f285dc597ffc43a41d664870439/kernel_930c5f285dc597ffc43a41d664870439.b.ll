; ModuleID = 'kernel_930c5f285dc597ffc43a41d664870439.b.cl'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.tlb_data = type { i32, [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], i32, i32, i32 }

@TLB = common global %struct.tlb_data zeroinitializer, align 4

; Function Attrs: nounwind uwtable
define void @vload8(i32 %offset, i32* %p, i32* %out) #0 {
entry:
  %offset.addr = alloca i32, align 4
  %p.addr = alloca i32*, align 8
  %out.addr = alloca i32*, align 8
  %i = alloca i32, align 4
  store i32 %offset, i32* %offset.addr, align 4
  store i32* %p, i32** %p.addr, align 8
  store i32* %out, i32** %out.addr, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i32* %i, align 4
  %cmp = icmp slt i32 %0, 8
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %1 = load i32* %offset.addr, align 4
  %mul = mul i32 %1, 8
  %2 = load i32* %i, align 4
  %add = add i32 %mul, %2
  %idxprom = zext i32 %add to i64
  %3 = load i32** %p.addr, align 8
  %arrayidx = getelementptr inbounds i32* %3, i64 %idxprom
  %4 = load i32* %arrayidx, align 4
  %5 = load i32* %i, align 4
  %idxprom1 = sext i32 %5 to i64
  %6 = load i32** %out.addr, align 8
  %arrayidx2 = getelementptr inbounds i32* %6, i64 %idxprom1
  store i32 %4, i32* %arrayidx2, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %7 = load i32* %i, align 4
  %inc = add nsw i32 %7, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @hadd(i32 %x, i32 %y) #0 {
entry:
  %x.addr = alloca i32, align 4
  %y.addr = alloca i32, align 4
  store i32 %x, i32* %x.addr, align 4
  store i32 %y, i32* %y.addr, align 4
  %0 = load i32* %x.addr, align 4
  %1 = load i32* %y.addr, align 4
  %add = add nsw i32 %0, %1
  %shr = ashr i32 %add, 1
  ret i32 %shr
}

; Function Attrs: nounwind uwtable
define void @compute_sum(i32* %a, i32 %n, i32* %tmp_sum, i32* %sum) #0 {
entry:
  %a.addr = alloca i32*, align 8
  %n.addr = alloca i32, align 4
  %tmp_sum.addr = alloca i32*, align 8
  %sum.addr = alloca i32*, align 8
  %tid = alloca i32, align 4
  %lsize = alloca i32, align 4
  %i = alloca i32, align 4
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
  %call7 = call i32 @hadd(i32 %13, i32 1)
  store i32 %call7, i32* %i, align 4
  br label %for.cond8

for.cond8:                                        ; preds = %for.inc19, %for.end
  %14 = load i32* %lsize, align 4
  %cmp9 = icmp sgt i32 %14, 1
  br i1 %cmp9, label %for.body10, label %for.end21

for.body10:                                       ; preds = %for.cond8
  call void @barrier(i32 1)
  %15 = load i32* %tid, align 4
  %16 = load i32* %i, align 4
  %add11 = add nsw i32 %15, %16
  %17 = load i32* %lsize, align 4
  %cmp12 = icmp slt i32 %add11, %17
  br i1 %cmp12, label %if.then, label %if.end

if.then:                                          ; preds = %for.body10
  %18 = load i32* %tid, align 4
  %19 = load i32* %i, align 4
  %add13 = add nsw i32 %18, %19
  %idxprom14 = sext i32 %add13 to i64
  %20 = load i32** %tmp_sum.addr, align 8
  %arrayidx15 = getelementptr inbounds i32* %20, i64 %idxprom14
  %21 = load i32* %arrayidx15, align 4
  %22 = load i32* %tid, align 4
  %idxprom16 = sext i32 %22 to i64
  %23 = load i32** %tmp_sum.addr, align 8
  %arrayidx17 = getelementptr inbounds i32* %23, i64 %idxprom16
  %24 = load i32* %arrayidx17, align 4
  %add18 = add nsw i32 %24, %21
  store i32 %add18, i32* %arrayidx17, align 4
  br label %if.end

if.end:                                           ; preds = %if.then, %for.body10
  %25 = load i32* %i, align 4
  store i32 %25, i32* %lsize, align 4
  br label %for.inc19

for.inc19:                                        ; preds = %if.end
  %26 = load i32* %i, align 4
  %call20 = call i32 @hadd(i32 %26, i32 1)
  store i32 %call20, i32* %i, align 4
  br label %for.cond8

for.end21:                                        ; preds = %for.cond8
  %27 = load i32* %tid, align 4
  %cmp22 = icmp eq i32 %27, 0
  br i1 %cmp22, label %if.then23, label %if.end25

if.then23:                                        ; preds = %for.end21
  %28 = load i32** %tmp_sum.addr, align 8
  %arrayidx24 = getelementptr inbounds i32* %28, i64 0
  %29 = load i32* %arrayidx24, align 4
  %30 = load i32** %sum.addr, align 8
  store i32 %29, i32* %30, align 4
  br label %if.end25

if.end25:                                         ; preds = %if.then23, %for.end21
  ret void
}

declare i32 @get_local_id(i32) #1

declare i32 @get_local_size(i32) #1

declare void @barrier(i32) #1

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!opencl.kernels = !{!0}
!llvm.ident = !{!1}

!0 = metadata !{void (i32*, i32, i32*, i32*)* @compute_sum}
!1 = metadata !{metadata !"clang version 3.4 (tags/RELEASE_34/final)"}
