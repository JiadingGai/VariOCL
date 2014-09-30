; ModuleID = '<stdin>'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.tlb_data = type { i32, [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], i32, i32, i32 }

@TLB = common global %struct.tlb_data zeroinitializer, align 4

; Function Attrs: nounwind uwtable
define void @b(i32* %A, i32* %B, i32* %C, i32 %n) #0 {
entry.barrier:
  call void @barrier(i32 0)
  br label %entry

entry:                                            ; preds = %entry.barrier
  %call = call i32 @get_local_size(i32 0) #2
  %call1 = call i32 @get_local_size(i32 1) #2
  %cmp = icmp sgt i32 %call, 0
  br i1 %cmp, label %if.then, label %if.end.mxpa.b4.barrier

if.then:                                          ; preds = %entry
  %call2 = call i32 @get_local_id(i32 0) #2
  %call3 = call i32 @get_local_id(i32 1) #2
  %call4 = call i32 @get_local_id(i32 2) #2
  br label %if.end.mxpa.b4.barrier

if.end.mxpa.b4.barrier:                           ; preds = %if.then, %entry
  %i.0 = phi i32 [ %call2, %if.then ], [ 0, %entry ]
  %j.0 = phi i32 [ %call3, %if.then ], [ 0, %entry ]
  %k.0 = phi i32 [ %call4, %if.then ], [ 0, %entry ]
  br label %if.end

if.end:                                           ; preds = %if.end.mxpa.b4.barrier
  call void @barrier(i32 0) #2
  br label %if.end.mxpa.after.barrier

if.end.mxpa.after.barrier:                        ; preds = %if.end
  %mul = mul nsw i32 %k.0, %call
  %mul5 = mul nsw i32 %mul, %call1
  %mul6 = mul nsw i32 %j.0, %call
  %add = add nsw i32 %mul5, %mul6
  %add7 = add nsw i32 %add, %i.0
  %cmp8 = icmp slt i32 %add7, %n
  br i1 %cmp8, label %if.then9, label %if.end14

if.then9:                                         ; preds = %if.end.mxpa.after.barrier
  %idxprom = sext i32 %add7 to i64
  %arrayidx = getelementptr inbounds i32* %A, i64 %idxprom
  store i32 %i.0, i32* %arrayidx, align 4
  %idxprom10 = sext i32 %add7 to i64
  %arrayidx11 = getelementptr inbounds i32* %B, i64 %idxprom10
  store i32 %j.0, i32* %arrayidx11, align 4
  %idxprom12 = sext i32 %add7 to i64
  %arrayidx13 = getelementptr inbounds i32* %C, i64 %idxprom12
  store i32 %k.0, i32* %arrayidx13, align 4
  br label %if.end14

if.end14:                                         ; preds = %if.then9, %if.end.mxpa.after.barrier
  br label %exit.barrier.mxpa.b4.barrier

exit.barrier.mxpa.b4.barrier:                     ; preds = %if.end14
  br label %exit.barrier

exit.barrier:                                     ; preds = %exit.barrier.mxpa.b4.barrier
  call void @barrier(i32 0)
  ret void
}

declare i32 @get_local_size(i32) #1

declare i32 @get_local_id(i32) #1

declare void @barrier(i32) #1

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind }

!opencl.kernels = !{!0}

!0 = metadata !{void (i32*, i32*, i32*, i32)* @b}
