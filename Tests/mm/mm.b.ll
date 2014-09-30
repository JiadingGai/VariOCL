; ModuleID = 'mm.b.cl'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.tlb_data = type { i32, [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], i32, i32, i32 }

@matrixMul.As = internal global [4 x [4 x i32]] zeroinitializer, align 16
@matrixMul.Bs = internal global [4 x [4 x i32]] zeroinitializer, align 16
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
define void @matrixMul(i32* %C, i32* %A, i32* %B, i32 %wA, i32 %wB) #0 {
entry:
  %C.addr = alloca i32*, align 8
  %A.addr = alloca i32*, align 8
  %B.addr = alloca i32*, align 8
  %wA.addr = alloca i32, align 4
  %wB.addr = alloca i32, align 4
  %bx = alloca i32, align 4
  %by = alloca i32, align 4
  %tx = alloca i32, align 4
  %ty = alloca i32, align 4
  %aBegin = alloca i32, align 4
  %aEnd = alloca i32, align 4
  %aStep = alloca i32, align 4
  %bBegin = alloca i32, align 4
  %bEnd = alloca i32, align 4
  %bStep = alloca i32, align 4
  %Csub = alloca i32, align 4
  %a = alloca i32, align 4
  %b = alloca i32, align 4
  %k = alloca i32, align 4
  %c = alloca i32, align 4
  store i32* %C, i32** %C.addr, align 8
  store i32* %A, i32** %A.addr, align 8
  store i32* %B, i32** %B.addr, align 8
  store i32 %wA, i32* %wA.addr, align 4
  store i32 %wB, i32* %wB.addr, align 4
  %call = call i32 @get_group_id(i32 0)
  store i32 %call, i32* %bx, align 4
  %call1 = call i32 @get_group_id(i32 1)
  store i32 %call1, i32* %by, align 4
  %call2 = call i32 @get_local_id(i32 0)
  store i32 %call2, i32* %tx, align 4
  %call3 = call i32 @get_local_id(i32 1)
  store i32 %call3, i32* %ty, align 4
  %0 = load i32* %wA.addr, align 4
  %mul = mul nsw i32 %0, 4
  %1 = load i32* %by, align 4
  %mul4 = mul nsw i32 %mul, %1
  store i32 %mul4, i32* %aBegin, align 4
  %2 = load i32* %aBegin, align 4
  %3 = load i32* %wA.addr, align 4
  %add = add nsw i32 %2, %3
  %sub = sub nsw i32 %add, 1
  store i32 %sub, i32* %aEnd, align 4
  store i32 4, i32* %aStep, align 4
  %4 = load i32* %bx, align 4
  %mul5 = mul nsw i32 4, %4
  store i32 %mul5, i32* %bBegin, align 4
  %5 = load i32* %bBegin, align 4
  %6 = load i32* %wB.addr, align 4
  %add6 = add nsw i32 %5, %6
  %sub7 = sub nsw i32 %add6, 1
  store i32 %sub7, i32* %bEnd, align 4
  %7 = load i32* %wB.addr, align 4
  %mul8 = mul nsw i32 4, %7
  store i32 %mul8, i32* %bStep, align 4
  store i32 0, i32* %Csub, align 4
  %8 = load i32* %aBegin, align 4
  store i32 %8, i32* %a, align 4
  %9 = load i32* %bBegin, align 4
  store i32 %9, i32* %b, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc38, %entry
  %10 = load i32* %a, align 4
  %11 = load i32* %aEnd, align 4
  %cmp = icmp sle i32 %10, %11
  br i1 %cmp, label %for.body, label %for.end41

for.body:                                         ; preds = %for.cond
  %12 = load i32* %a, align 4
  %13 = load i32* %wA.addr, align 4
  %14 = load i32* %ty, align 4
  %mul9 = mul nsw i32 %13, %14
  %add10 = add nsw i32 %12, %mul9
  %15 = load i32* %tx, align 4
  %add11 = add nsw i32 %add10, %15
  %idxprom = sext i32 %add11 to i64
  %16 = load i32** %A.addr, align 8
  %arrayidx = getelementptr inbounds i32* %16, i64 %idxprom
  %17 = load i32* %arrayidx, align 4
  %18 = load i32* %tx, align 4
  %idxprom12 = sext i32 %18 to i64
  %19 = load i32* %ty, align 4
  %idxprom13 = sext i32 %19 to i64
  %arrayidx14 = getelementptr inbounds [4 x [4 x i32]]* @matrixMul.As, i32 0, i64 %idxprom13
  %arrayidx15 = getelementptr inbounds [4 x i32]* %arrayidx14, i32 0, i64 %idxprom12
  store i32 %17, i32* %arrayidx15, align 4
  %20 = load i32* %b, align 4
  %21 = load i32* %wB.addr, align 4
  %22 = load i32* %ty, align 4
  %mul16 = mul nsw i32 %21, %22
  %add17 = add nsw i32 %20, %mul16
  %23 = load i32* %tx, align 4
  %add18 = add nsw i32 %add17, %23
  %idxprom19 = sext i32 %add18 to i64
  %24 = load i32** %B.addr, align 8
  %arrayidx20 = getelementptr inbounds i32* %24, i64 %idxprom19
  %25 = load i32* %arrayidx20, align 4
  %26 = load i32* %tx, align 4
  %idxprom21 = sext i32 %26 to i64
  %27 = load i32* %ty, align 4
  %idxprom22 = sext i32 %27 to i64
  %arrayidx23 = getelementptr inbounds [4 x [4 x i32]]* @matrixMul.Bs, i32 0, i64 %idxprom22
  %arrayidx24 = getelementptr inbounds [4 x i32]* %arrayidx23, i32 0, i64 %idxprom21
  store i32 %25, i32* %arrayidx24, align 4
  call void @barrier(i32 1)
  store i32 0, i32* %k, align 4
  br label %for.cond25

for.cond25:                                       ; preds = %for.inc, %for.body
  %28 = load i32* %k, align 4
  %cmp26 = icmp slt i32 %28, 4
  br i1 %cmp26, label %for.body27, label %for.end

for.body27:                                       ; preds = %for.cond25
  %29 = load i32* %k, align 4
  %idxprom28 = sext i32 %29 to i64
  %30 = load i32* %ty, align 4
  %idxprom29 = sext i32 %30 to i64
  %arrayidx30 = getelementptr inbounds [4 x [4 x i32]]* @matrixMul.As, i32 0, i64 %idxprom29
  %arrayidx31 = getelementptr inbounds [4 x i32]* %arrayidx30, i32 0, i64 %idxprom28
  %31 = load i32* %arrayidx31, align 4
  %32 = load i32* %tx, align 4
  %idxprom32 = sext i32 %32 to i64
  %33 = load i32* %k, align 4
  %idxprom33 = sext i32 %33 to i64
  %arrayidx34 = getelementptr inbounds [4 x [4 x i32]]* @matrixMul.Bs, i32 0, i64 %idxprom33
  %arrayidx35 = getelementptr inbounds [4 x i32]* %arrayidx34, i32 0, i64 %idxprom32
  %34 = load i32* %arrayidx35, align 4
  %mul36 = mul nsw i32 %31, %34
  %35 = load i32* %Csub, align 4
  %add37 = add nsw i32 %35, %mul36
  store i32 %add37, i32* %Csub, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body27
  %36 = load i32* %k, align 4
  %inc = add nsw i32 %36, 1
  store i32 %inc, i32* %k, align 4
  br label %for.cond25

for.end:                                          ; preds = %for.cond25
  call void @barrier(i32 1)
  br label %for.inc38

for.inc38:                                        ; preds = %for.end
  %37 = load i32* %aStep, align 4
  %38 = load i32* %a, align 4
  %add39 = add nsw i32 %38, %37
  store i32 %add39, i32* %a, align 4
  %39 = load i32* %bStep, align 4
  %40 = load i32* %b, align 4
  %add40 = add nsw i32 %40, %39
  store i32 %add40, i32* %b, align 4
  br label %for.cond

for.end41:                                        ; preds = %for.cond
  %41 = load i32* %wB.addr, align 4
  %mul42 = mul nsw i32 %41, 4
  %42 = load i32* %by, align 4
  %mul43 = mul nsw i32 %mul42, %42
  %43 = load i32* %bx, align 4
  %mul44 = mul nsw i32 4, %43
  %add45 = add nsw i32 %mul43, %mul44
  store i32 %add45, i32* %c, align 4
  %44 = load i32* %Csub, align 4
  %45 = load i32* %c, align 4
  %46 = load i32* %wB.addr, align 4
  %47 = load i32* %ty, align 4
  %mul46 = mul nsw i32 %46, %47
  %add47 = add nsw i32 %45, %mul46
  %48 = load i32* %tx, align 4
  %add48 = add nsw i32 %add47, %48
  %idxprom49 = sext i32 %add48 to i64
  %49 = load i32** %C.addr, align 8
  %arrayidx50 = getelementptr inbounds i32* %49, i64 %idxprom49
  store i32 %44, i32* %arrayidx50, align 4
  ret void
}

declare i32 @get_group_id(i32) #1

declare i32 @get_local_id(i32) #1

declare void @barrier(i32) #1

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!opencl.kernels = !{!0}
!llvm.ident = !{!1}

!0 = metadata !{void (i32*, i32*, i32*, i32, i32)* @matrixMul}
!1 = metadata !{metadata !"clang version 3.4 (tags/RELEASE_34/final)"}
