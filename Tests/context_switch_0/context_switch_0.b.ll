; ModuleID = 'context_switch_0.b.cl'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.tlb_data = type { i32, [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], i32, i32, i32 }

@TLB = common global %struct.tlb_data zeroinitializer, align 4

; Function Attrs: nounwind uwtable
define void @b(i32* %A, i32* %B, i32* %C, i32 %n) #0 {
entry:
  %A.addr = alloca i32*, align 8
  %B.addr = alloca i32*, align 8
  %C.addr = alloca i32*, align 8
  %n.addr = alloca i32, align 4
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %k = alloca i32, align 4
  %xDim = alloca i32, align 4
  %yDim = alloca i32, align 4
  %idx = alloca i32, align 4
  store i32* %A, i32** %A.addr, align 8
  store i32* %B, i32** %B.addr, align 8
  store i32* %C, i32** %C.addr, align 8
  store i32 %n, i32* %n.addr, align 4
  store i32 0, i32* %i, align 4
  store i32 0, i32* %j, align 4
  store i32 0, i32* %k, align 4
  %call = call i32 @get_local_size(i32 0)
  store i32 %call, i32* %xDim, align 4
  %call1 = call i32 @get_local_size(i32 1)
  store i32 %call1, i32* %yDim, align 4
  %0 = load i32* %xDim, align 4
  %cmp = icmp sgt i32 %0, 0
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %call2 = call i32 @get_local_id(i32 0)
  store i32 %call2, i32* %i, align 4
  %call3 = call i32 @get_local_id(i32 1)
  store i32 %call3, i32* %j, align 4
  %call4 = call i32 @get_local_id(i32 2)
  store i32 %call4, i32* %k, align 4
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  call void @barrier(i32 0)
  %1 = load i32* %k, align 4
  %2 = load i32* %xDim, align 4
  %mul = mul nsw i32 %1, %2
  %3 = load i32* %yDim, align 4
  %mul5 = mul nsw i32 %mul, %3
  %4 = load i32* %j, align 4
  %5 = load i32* %xDim, align 4
  %mul6 = mul nsw i32 %4, %5
  %add = add nsw i32 %mul5, %mul6
  %6 = load i32* %i, align 4
  %add7 = add nsw i32 %add, %6
  store i32 %add7, i32* %idx, align 4
  %7 = load i32* %idx, align 4
  %8 = load i32* %n.addr, align 4
  %cmp8 = icmp slt i32 %7, %8
  br i1 %cmp8, label %if.then9, label %if.end14

if.then9:                                         ; preds = %if.end
  %9 = load i32* %i, align 4
  %10 = load i32* %idx, align 4
  %idxprom = sext i32 %10 to i64
  %11 = load i32** %A.addr, align 8
  %arrayidx = getelementptr inbounds i32* %11, i64 %idxprom
  store i32 %9, i32* %arrayidx, align 4
  %12 = load i32* %j, align 4
  %13 = load i32* %idx, align 4
  %idxprom10 = sext i32 %13 to i64
  %14 = load i32** %B.addr, align 8
  %arrayidx11 = getelementptr inbounds i32* %14, i64 %idxprom10
  store i32 %12, i32* %arrayidx11, align 4
  %15 = load i32* %k, align 4
  %16 = load i32* %idx, align 4
  %idxprom12 = sext i32 %16 to i64
  %17 = load i32** %C.addr, align 8
  %arrayidx13 = getelementptr inbounds i32* %17, i64 %idxprom12
  store i32 %15, i32* %arrayidx13, align 4
  br label %if.end14

if.end14:                                         ; preds = %if.then9, %if.end
  ret void
}

declare i32 @get_local_size(i32) #1

declare i32 @get_local_id(i32) #1

declare void @barrier(i32) #1

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!opencl.kernels = !{!0}
!llvm.ident = !{!1}

!0 = metadata !{void (i32*, i32*, i32*, i32)* @b}
!1 = metadata !{metadata !"clang version 3.4 (tags/RELEASE_34/final)"}
