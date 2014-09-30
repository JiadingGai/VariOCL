; ModuleID = 'vector_add_kernel.b.cl'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.tlb_data = type { i32, [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], i32, i32, i32 }

@xDim = global i32 1, align 4
@yDim = global i32 2, align 4
@zDim = global i32 4, align 4
@xid = global i32 0, align 4
@yid = global i32 0, align 4
@zid = global i32 0, align 4
@TLB = common global %struct.tlb_data zeroinitializer, align 4

; Function Attrs: nounwind uwtable
define void @vector_add(i32* %A, i32* %B, i32* %C, i32 %n) #0 {
entry:
  %A.addr = alloca i32*, align 8
  %B.addr = alloca i32*, align 8
  %C.addr = alloca i32*, align 8
  %n.addr = alloca i32, align 4
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %k = alloca i32, align 4
  %idx = alloca i32, align 4
  store i32* %A, i32** %A.addr, align 8
  store i32* %B, i32** %B.addr, align 8
  store i32* %C, i32** %C.addr, align 8
  store i32 %n, i32* %n.addr, align 4
  %call = call i32 @get_local_id(i32 0)
  store i32 %call, i32* %i, align 4
  %call1 = call i32 @get_local_id(i32 1)
  store i32 %call1, i32* %j, align 4
  %call2 = call i32 @get_local_id(i32 2)
  store i32 %call2, i32* %k, align 4
  %0 = load i32* %k, align 4
  %1 = load i32* @xDim, align 4
  %mul = mul nsw i32 %0, %1
  %2 = load i32* @yDim, align 4
  %mul3 = mul nsw i32 %mul, %2
  %3 = load i32* %j, align 4
  %4 = load i32* @xDim, align 4
  %mul4 = mul nsw i32 %3, %4
  %add = add nsw i32 %mul3, %mul4
  %5 = load i32* %i, align 4
  %add5 = add nsw i32 %add, %5
  store i32 %add5, i32* %idx, align 4
  %6 = load i32* %idx, align 4
  %7 = load i32* %n.addr, align 4
  %cmp = icmp slt i32 %6, %7
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %8 = load i32* %idx, align 4
  %idxprom = sext i32 %8 to i64
  %9 = load i32** %A.addr, align 8
  %arrayidx = getelementptr inbounds i32* %9, i64 %idxprom
  %10 = load i32* %arrayidx, align 4
  %11 = load i32* %idx, align 4
  %idxprom6 = sext i32 %11 to i64
  %12 = load i32** %B.addr, align 8
  %arrayidx7 = getelementptr inbounds i32* %12, i64 %idxprom6
  %13 = load i32* %arrayidx7, align 4
  %add8 = add nsw i32 %10, %13
  %14 = load i32* %idx, align 4
  %idxprom9 = sext i32 %14 to i64
  %15 = load i32** %C.addr, align 8
  %arrayidx10 = getelementptr inbounds i32* %15, i64 %idxprom9
  store i32 %add8, i32* %arrayidx10, align 4
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  call void @barrier(i32 1)
  %16 = load i32* %idx, align 4
  %17 = load i32* %n.addr, align 4
  %cmp11 = icmp sgt i32 %16, %17
  br i1 %cmp11, label %if.then12, label %if.else

if.then12:                                        ; preds = %if.end
  br label %return

if.else:                                          ; preds = %if.end
  %18 = load i32* %idx, align 4
  %19 = load i32* %n.addr, align 4
  %cmp13 = icmp slt i32 %18, %19
  br i1 %cmp13, label %if.then14, label %if.else22

if.then14:                                        ; preds = %if.else
  %20 = load i32* %idx, align 4
  %idxprom15 = sext i32 %20 to i64
  %21 = load i32** %A.addr, align 8
  %arrayidx16 = getelementptr inbounds i32* %21, i64 %idxprom15
  %22 = load i32* %arrayidx16, align 4
  %23 = load i32* %idx, align 4
  %idxprom17 = sext i32 %23 to i64
  %24 = load i32** %B.addr, align 8
  %arrayidx18 = getelementptr inbounds i32* %24, i64 %idxprom17
  %25 = load i32* %arrayidx18, align 4
  %add19 = add nsw i32 %22, %25
  %26 = load i32* %idx, align 4
  %idxprom20 = sext i32 %26 to i64
  %27 = load i32** %C.addr, align 8
  %arrayidx21 = getelementptr inbounds i32* %27, i64 %idxprom20
  store i32 %add19, i32* %arrayidx21, align 4
  br label %if.end23

if.else22:                                        ; preds = %if.else
  br label %return

if.end23:                                         ; preds = %if.then14
  br label %if.end24

if.end24:                                         ; preds = %if.end23
  br label %return

return:                                           ; preds = %if.end24, %if.else22, %if.then12
  ret void
}

declare i32 @get_local_id(i32) #1

declare void @barrier(i32) #1

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!opencl.kernels = !{!0}
!llvm.ident = !{!1}

!0 = metadata !{void (i32*, i32*, i32*, i32)* @vector_add}
!1 = metadata !{metadata !"clang version 3.4 (tags/RELEASE_34/final)"}
