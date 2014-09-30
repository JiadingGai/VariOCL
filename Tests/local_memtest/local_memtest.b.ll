; ModuleID = 'local_memtest.b.cl'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.tlb_data = type { i32, [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], i32, i32, i32 }

@local_memtest.lbuf = internal global [30 x i32] zeroinitializer, align 16
@TLB = common global %struct.tlb_data zeroinitializer, align 4

; Function Attrs: nounwind uwtable
define void @local_memtest(i32* %in, i32* %out) #0 {
entry:
  %in.addr = alloca i32*, align 8
  %out.addr = alloca i32*, align 8
  %idx = alloca i32, align 4
  %lsz = alloca i32, align 4
  store i32* %in, i32** %in.addr, align 8
  store i32* %out, i32** %out.addr, align 8
  %call = call i32 @get_local_id(i32 0)
  store i32 %call, i32* %idx, align 4
  %call1 = call i32 @get_local_size(i32 0)
  store i32 %call1, i32* %lsz, align 4
  %0 = load i32* %idx, align 4
  %1 = load i32* %lsz, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %2 = load i32* %idx, align 4
  %idxprom = sext i32 %2 to i64
  %3 = load i32** %in.addr, align 8
  %arrayidx = getelementptr inbounds i32* %3, i64 %idxprom
  %4 = load i32* %arrayidx, align 4
  %5 = load i32* %idx, align 4
  %idxprom2 = sext i32 %5 to i64
  %arrayidx3 = getelementptr inbounds [30 x i32]* @local_memtest.lbuf, i32 0, i64 %idxprom2
  store i32 %4, i32* %arrayidx3, align 4
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  call void @barrier(i32 1)
  %6 = load i32* %idx, align 4
  %add = add nsw i32 %6, 1
  %7 = load i32* %lsz, align 4
  %rem = srem i32 %add, %7
  %idxprom4 = sext i32 %rem to i64
  %arrayidx5 = getelementptr inbounds [30 x i32]* @local_memtest.lbuf, i32 0, i64 %idxprom4
  %8 = load i32* %arrayidx5, align 4
  %9 = load i32* %idx, align 4
  %idxprom6 = sext i32 %9 to i64
  %10 = load i32** %out.addr, align 8
  %arrayidx7 = getelementptr inbounds i32* %10, i64 %idxprom6
  store i32 %8, i32* %arrayidx7, align 4
  ret void
}

declare i32 @get_local_id(i32) #1

declare i32 @get_local_size(i32) #1

declare void @barrier(i32) #1

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!opencl.kernels = !{!0}
!llvm.ident = !{!1}

!0 = metadata !{void (i32*, i32*)* @local_memtest}
!1 = metadata !{metadata !"clang version 3.4 (tags/RELEASE_34/final)"}
