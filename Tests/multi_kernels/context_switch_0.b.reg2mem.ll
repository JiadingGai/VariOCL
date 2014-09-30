; ModuleID = '<stdin>'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.tlb_data = type { i32, [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], i32, i32, i32 }

@TLB = common global %struct.tlb_data zeroinitializer, align 4

; Function Attrs: nounwind uwtable
define void @b(i32* %A, i32* %B, i32* %C, i32 %n) #0 {
entry.barrier:
  %add7.reg2mem = alloca i32
  %k.0.reg2mem = alloca i32
  %j.0.reg2mem = alloca i32
  %i.0.reg2mem = alloca i32
  %call4.reg2mem = alloca i32
  %call3.reg2mem = alloca i32
  %call2.reg2mem = alloca i32
  %call1.reg2mem = alloca i32
  %call.reg2mem = alloca i32
  %k.0.reg2mem9 = alloca i32
  %j.0.reg2mem11 = alloca i32
  %i.0.reg2mem13 = alloca i32
  %"reg2mem alloca point" = bitcast i32 0 to i32
  call void @barrier(i32 0)
  br label %entry

entry:                                            ; preds = %entry.barrier
  %call = call i32 @get_local_size(i32 0) #2
  store i32 %call, i32* %call.reg2mem
  %call1 = call i32 @get_local_size(i32 1) #2
  store i32 %call1, i32* %call1.reg2mem
  %call.reload8 = load i32* %call.reg2mem
  %cmp = icmp sgt i32 %call.reload8, 0
  br i1 %cmp, label %if.then, label %entry.if.end.mxpa.b4.barrier_crit_edge

entry.if.end.mxpa.b4.barrier_crit_edge:           ; preds = %entry
  store i32 0, i32* %k.0.reg2mem9
  store i32 0, i32* %j.0.reg2mem11
  store i32 0, i32* %i.0.reg2mem13
  br label %if.end.mxpa.b4.barrier

if.then:                                          ; preds = %entry
  %call2 = call i32 @get_local_id(i32 0) #2
  store i32 %call2, i32* %call2.reg2mem
  %call3 = call i32 @get_local_id(i32 1) #2
  store i32 %call3, i32* %call3.reg2mem
  %call4 = call i32 @get_local_id(i32 2) #2
  store i32 %call4, i32* %call4.reg2mem
  %call4.reload = load i32* %call4.reg2mem
  %call3.reload = load i32* %call3.reg2mem
  %call2.reload = load i32* %call2.reg2mem
  store i32 %call4.reload, i32* %k.0.reg2mem9
  store i32 %call3.reload, i32* %j.0.reg2mem11
  store i32 %call2.reload, i32* %i.0.reg2mem13
  br label %if.end.mxpa.b4.barrier

if.end.mxpa.b4.barrier:                           ; preds = %entry.if.end.mxpa.b4.barrier_crit_edge, %if.then
  %i.0.reload14 = load i32* %i.0.reg2mem13
  %j.0.reload12 = load i32* %j.0.reg2mem11
  %k.0.reload10 = load i32* %k.0.reg2mem9
  store i32 %i.0.reload14, i32* %i.0.reg2mem
  store i32 %j.0.reload12, i32* %j.0.reg2mem
  store i32 %k.0.reload10, i32* %k.0.reg2mem
  br label %if.end

if.end:                                           ; preds = %if.end.mxpa.b4.barrier
  call void @barrier(i32 0) #2
  br label %if.end.mxpa.after.barrier

if.end.mxpa.after.barrier:                        ; preds = %if.end
  %k.0.reload4 = load i32* %k.0.reg2mem
  %call.reload7 = load i32* %call.reg2mem
  %mul = mul nsw i32 %k.0.reload4, %call.reload7
  %call1.reload = load i32* %call1.reg2mem
  %mul5 = mul nsw i32 %mul, %call1.reload
  %j.0.reload5 = load i32* %j.0.reg2mem
  %call.reload = load i32* %call.reg2mem
  %mul6 = mul nsw i32 %j.0.reload5, %call.reload
  %add = add nsw i32 %mul5, %mul6
  %i.0.reload6 = load i32* %i.0.reg2mem
  %add7 = add nsw i32 %add, %i.0.reload6
  store i32 %add7, i32* %add7.reg2mem
  %add7.reload3 = load i32* %add7.reg2mem
  %cmp8 = icmp slt i32 %add7.reload3, %n
  br i1 %cmp8, label %if.then9, label %if.end.mxpa.after.barrier.if.end14_crit_edge

if.end.mxpa.after.barrier.if.end14_crit_edge:     ; preds = %if.end.mxpa.after.barrier
  br label %if.end14

if.then9:                                         ; preds = %if.end.mxpa.after.barrier
  %add7.reload2 = load i32* %add7.reg2mem
  %idxprom = sext i32 %add7.reload2 to i64
  %arrayidx = getelementptr inbounds i32* %A, i64 %idxprom
  %i.0.reload = load i32* %i.0.reg2mem
  store i32 %i.0.reload, i32* %arrayidx, align 4
  %add7.reload1 = load i32* %add7.reg2mem
  %idxprom10 = sext i32 %add7.reload1 to i64
  %arrayidx11 = getelementptr inbounds i32* %B, i64 %idxprom10
  %j.0.reload = load i32* %j.0.reg2mem
  store i32 %j.0.reload, i32* %arrayidx11, align 4
  %add7.reload = load i32* %add7.reg2mem
  %idxprom12 = sext i32 %add7.reload to i64
  %arrayidx13 = getelementptr inbounds i32* %C, i64 %idxprom12
  %k.0.reload = load i32* %k.0.reg2mem
  store i32 %k.0.reload, i32* %arrayidx13, align 4
  br label %if.end14

if.end14:                                         ; preds = %if.end.mxpa.after.barrier.if.end14_crit_edge, %if.then9
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
