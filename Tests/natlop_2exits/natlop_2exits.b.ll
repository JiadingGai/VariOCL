; ModuleID = 'natlop_2exits.b.cl'
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
define void @natlop_2exits() #0 {
entry:
  %k = alloca i32, align 4
  %i = alloca i32, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i32* %i, align 4
  %cmp = icmp slt i32 %0, 10
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %call = call i32 @get_local_id(i32 0)
  store i32 %call, i32* %k, align 4
  %1 = load i32* %k, align 4
  %2 = load i32* @xDim, align 4
  %cmp1 = icmp sgt i32 %1, %2
  br i1 %cmp1, label %if.then, label %if.else

if.then:                                          ; preds = %for.body
  %3 = load i32* %k, align 4
  %call2 = call i32 (i32, ...)* bitcast (i32 (...)* @A to i32 (i32, ...)*)(i32 %3)
  br label %if.end

if.else:                                          ; preds = %for.body
  %call3 = call i32 (...)* @B()
  br label %if.end7

if.end:                                           ; preds = %if.then
  br label %for.inc

for.inc:                                          ; preds = %if.end
  %4 = load i32* %i, align 4
  %inc = add nsw i32 %4, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  call void @barrier(i32 1)
  %5 = load i32* %k, align 4
  %cmp4 = icmp eq i32 %5, 0
  br i1 %cmp4, label %if.then5, label %if.end7

if.then5:                                         ; preds = %for.end
  %6 = load i32* %k, align 4
  %call6 = call i32 (i32, ...)* bitcast (i32 (...)* @C to i32 (i32, ...)*)(i32 %6)
  br label %if.end7

if.end7:                                          ; preds = %if.else, %if.then5, %for.end
  ret void
}

declare i32 @get_local_id(i32) #1

declare i32 @A(...) #1

declare i32 @B(...) #1

declare void @barrier(i32) #1

declare i32 @C(...) #1

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!opencl.kernels = !{!0}
!llvm.ident = !{!1}

!0 = metadata !{void ()* @natlop_2exits}
!1 = metadata !{metadata !"clang version 3.4 (tags/RELEASE_34/final)"}
