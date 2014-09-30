; ModuleID = 'kernel_f7f7d374e191f6d0e79be5f39cb5f186.b.cl'
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
define void @test_fn(i32* %sSharedStorage, i32* %src, i32* %offsets, i32* %alignmentOffsets, i32* %results) #0 {
entry:
  %sSharedStorage.addr = alloca i32*, align 8
  %src.addr = alloca i32*, align 8
  %offsets.addr = alloca i32*, align 8
  %alignmentOffsets.addr = alloca i32*, align 8
  %results.addr = alloca i32*, align 8
  %tid = alloca i32, align 4
  %lid = alloca i32, align 4
  %i = alloca i32, align 4
  %tmp = alloca [8 x i32], align 16
  %i10 = alloca i32, align 4
  store i32* %sSharedStorage, i32** %sSharedStorage.addr, align 8
  store i32* %src, i32** %src.addr, align 8
  store i32* %offsets, i32** %offsets.addr, align 8
  store i32* %alignmentOffsets, i32** %alignmentOffsets.addr, align 8
  store i32* %results, i32** %results.addr, align 8
  %call = call i32 @get_global_id(i32 0)
  store i32 %call, i32* %tid, align 4
  %call1 = call i32 @get_local_id(i32 0)
  store i32 %call1, i32* %lid, align 4
  %0 = load i32* %lid, align 4
  %cmp = icmp eq i32 %0, 0
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %if.then
  %1 = load i32* %i, align 4
  %cmp2 = icmp slt i32 %1, 2048
  br i1 %cmp2, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %2 = load i32* %i, align 4
  %idxprom = sext i32 %2 to i64
  %3 = load i32** %src.addr, align 8
  %arrayidx = getelementptr inbounds i32* %3, i64 %idxprom
  %4 = load i32* %arrayidx, align 4
  %5 = load i32* %i, align 4
  %idxprom3 = sext i32 %5 to i64
  %6 = load i32** %sSharedStorage.addr, align 8
  %arrayidx4 = getelementptr inbounds i32* %6, i64 %idxprom3
  store i32 %4, i32* %arrayidx4, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %7 = load i32* %i, align 4
  %inc = add nsw i32 %7, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  br label %if.end

if.end:                                           ; preds = %for.end, %entry
  call void @barrier(i32 1)
  %8 = load i32* %tid, align 4
  %idxprom5 = sext i32 %8 to i64
  %9 = load i32** %offsets.addr, align 8
  %arrayidx6 = getelementptr inbounds i32* %9, i64 %idxprom5
  %10 = load i32* %arrayidx6, align 4
  %11 = load i32** %sSharedStorage.addr, align 8
  %12 = load i32* %tid, align 4
  %idxprom7 = sext i32 %12 to i64
  %13 = load i32** %alignmentOffsets.addr, align 8
  %arrayidx8 = getelementptr inbounds i32* %13, i64 %idxprom7
  %14 = load i32* %arrayidx8, align 4
  %idx.ext = zext i32 %14 to i64
  %add.ptr = getelementptr inbounds i32* %11, i64 %idx.ext
  %arraydecay = getelementptr inbounds [8 x i32]* %tmp, i32 0, i32 0
  call void @vload8(i32 %10, i32* %add.ptr, i32* %arraydecay)
  store i32 0, i32* %i10, align 4
  br label %for.cond11

for.cond11:                                       ; preds = %for.inc18, %if.end
  %15 = load i32* %i10, align 4
  %cmp12 = icmp slt i32 %15, 8
  br i1 %cmp12, label %for.body13, label %for.end20

for.body13:                                       ; preds = %for.cond11
  %16 = load i32* %i10, align 4
  %idxprom14 = sext i32 %16 to i64
  %arrayidx15 = getelementptr inbounds [8 x i32]* %tmp, i32 0, i64 %idxprom14
  %17 = load i32* %arrayidx15, align 4
  %18 = load i32* %tid, align 4
  %mul = mul nsw i32 %18, 8
  %19 = load i32* %i10, align 4
  %add = add nsw i32 %mul, %19
  %idxprom16 = sext i32 %add to i64
  %20 = load i32** %results.addr, align 8
  %arrayidx17 = getelementptr inbounds i32* %20, i64 %idxprom16
  store i32 %17, i32* %arrayidx17, align 4
  br label %for.inc18

for.inc18:                                        ; preds = %for.body13
  %21 = load i32* %i10, align 4
  %inc19 = add nsw i32 %21, 1
  store i32 %inc19, i32* %i10, align 4
  br label %for.cond11

for.end20:                                        ; preds = %for.cond11
  ret void
}

declare i32 @get_global_id(i32) #1

declare i32 @get_local_id(i32) #1

declare void @barrier(i32) #1

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!opencl.kernels = !{!0}
!llvm.ident = !{!1}

!0 = metadata !{void (i32*, i32*, i32*, i32*, i32*)* @test_fn}
!1 = metadata !{metadata !"clang version 3.4 (tags/RELEASE_34/final)"}
