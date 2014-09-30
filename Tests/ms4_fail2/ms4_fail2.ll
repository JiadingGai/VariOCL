; ModuleID = 'ms4_fail2.cl'
target datalayout = "e-p:32:32:32-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v16:16:16-v24:32:32-v32:32:32-v48:64:64-v64:64:64-v96:128:128-v128:128:128-v192:256:256-v256:256:256-v512:512:512-v1024:1024:1024"
target triple = "spir-unknown-unknown"

@boxFilter_C4_D5.temp = internal addrspace(3) global [2 x [256 x <4 x float>]] zeroinitializer, align 16

; Function Attrs: nounwind
define void @boxFilter_C4_D5(<4 x float> addrspace(1)* noalias %src, <4 x float> addrspace(1)* %dst, float %alpha, i32 %src_offset, i32 %src_whole_rows, i32 %src_whole_cols, i32 %src_step, i32 %dst_offset, i32 %dst_rows, i32 %dst_cols, i32 %dst_step) #0 {
entry:
  %src.addr = alloca <4 x float> addrspace(1)*, align 4
  %dst.addr = alloca <4 x float> addrspace(1)*, align 4
  %alpha.addr = alloca float, align 4
  %src_offset.addr = alloca i32, align 4
  %src_whole_rows.addr = alloca i32, align 4
  %src_whole_cols.addr = alloca i32, align 4
  %src_step.addr = alloca i32, align 4
  %dst_offset.addr = alloca i32, align 4
  %dst_rows.addr = alloca i32, align 4
  %dst_cols.addr = alloca i32, align 4
  %dst_step.addr = alloca i32, align 4
  %col = alloca i32, align 4
  %gX = alloca i32, align 4
  %gY = alloca i32, align 4
  %src_x_off = alloca i32, align 4
  %src_y_off = alloca i32, align 4
  %dst_x_off = alloca i32, align 4
  %dst_y_off = alloca i32, align 4
  %startX = alloca i32, align 4
  %startY = alloca i32, align 4
  %dst_startX = alloca i32, align 4
  %dst_startY = alloca i32, align 4
  %data = alloca [4 x <4 x float>], align 16
  %con = alloca i8, align 1
  %ss = alloca <4 x float>, align 16
  %i = alloca i32, align 4
  %cur_col = alloca i32, align 4
  %.compoundliteral = alloca <4 x float>, align 16
  %sum0 = alloca <4 x float>, align 16
  %sum1 = alloca <4 x float>, align 16
  %sum2 = alloca <4 x float>, align 16
  %i41 = alloca i32, align 4
  %posX = alloca i32, align 4
  %posY = alloca i32, align 4
  %tmp_sum = alloca [2 x <4 x float>], align 16
  %k = alloca i32, align 4
  %i65 = alloca i32, align 4
  %i80 = alloca i32, align 4
  store <4 x float> addrspace(1)* %src, <4 x float> addrspace(1)** %src.addr, align 4
  store <4 x float> addrspace(1)* %dst, <4 x float> addrspace(1)** %dst.addr, align 4
  store float %alpha, float* %alpha.addr, align 4
  store i32 %src_offset, i32* %src_offset.addr, align 4
  store i32 %src_whole_rows, i32* %src_whole_rows.addr, align 4
  store i32 %src_whole_cols, i32* %src_whole_cols.addr, align 4
  store i32 %src_step, i32* %src_step.addr, align 4
  store i32 %dst_offset, i32* %dst_offset.addr, align 4
  store i32 %dst_rows, i32* %dst_rows.addr, align 4
  store i32 %dst_cols, i32* %dst_cols.addr, align 4
  store i32 %dst_step, i32* %dst_step.addr, align 4
  %call = call i32 @get_local_id(i32 0) #3
  store i32 %call, i32* %col, align 4
  %call1 = call i32 @get_group_id(i32 0) #3
  store i32 %call1, i32* %gX, align 4
  %call2 = call i32 @get_group_id(i32 1) #3
  store i32 %call2, i32* %gY, align 4
  %0 = load i32* %src_offset.addr, align 4
  %1 = load i32* %src_step.addr, align 4
  %rem = srem i32 %0, %1
  %shr = ashr i32 %rem, 4
  store i32 %shr, i32* %src_x_off, align 4
  %2 = load i32* %src_offset.addr, align 4
  %3 = load i32* %src_step.addr, align 4
  %div = sdiv i32 %2, %3
  store i32 %div, i32* %src_y_off, align 4
  %4 = load i32* %dst_offset.addr, align 4
  %5 = load i32* %dst_step.addr, align 4
  %rem3 = srem i32 %4, %5
  %shr4 = ashr i32 %rem3, 4
  store i32 %shr4, i32* %dst_x_off, align 4
  %6 = load i32* %dst_offset.addr, align 4
  %7 = load i32* %dst_step.addr, align 4
  %div5 = sdiv i32 %6, %7
  store i32 %div5, i32* %dst_y_off, align 4
  %8 = load i32* %gX, align 4
  %mul = mul nsw i32 %8, 254
  %sub = sub nsw i32 %mul, 1
  %9 = load i32* %src_x_off, align 4
  %add = add nsw i32 %sub, %9
  store i32 %add, i32* %startX, align 4
  %10 = load i32* %gY, align 4
  %shl = shl i32 %10, 1
  %sub6 = sub nsw i32 %shl, 1
  %11 = load i32* %src_y_off, align 4
  %add7 = add nsw i32 %sub6, %11
  store i32 %add7, i32* %startY, align 4
  %12 = load i32* %gX, align 4
  %mul8 = mul nsw i32 %12, 254
  %13 = load i32* %dst_x_off, align 4
  %add9 = add nsw i32 %mul8, %13
  store i32 %add9, i32* %dst_startX, align 4
  %14 = load i32* %gY, align 4
  %shl10 = shl i32 %14, 1
  %15 = load i32* %dst_y_off, align 4
  %add11 = add nsw i32 %shl10, %15
  store i32 %add11, i32* %dst_startY, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %16 = load i32* %i, align 4
  %cmp = icmp slt i32 %16, 4
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %17 = load i32* %startX, align 4
  %18 = load i32* %col, align 4
  %add12 = add nsw i32 %17, %18
  %cmp13 = icmp sge i32 %add12, 0
  br i1 %cmp13, label %land.lhs.true, label %land.end

land.lhs.true:                                    ; preds = %for.body
  %19 = load i32* %startX, align 4
  %20 = load i32* %col, align 4
  %add14 = add nsw i32 %19, %20
  %21 = load i32* %src_whole_cols.addr, align 4
  %cmp15 = icmp slt i32 %add14, %21
  br i1 %cmp15, label %land.lhs.true16, label %land.end

land.lhs.true16:                                  ; preds = %land.lhs.true
  %22 = load i32* %startY, align 4
  %23 = load i32* %i, align 4
  %add17 = add nsw i32 %22, %23
  %cmp18 = icmp sge i32 %add17, 0
  br i1 %cmp18, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %land.lhs.true16
  %24 = load i32* %startY, align 4
  %25 = load i32* %i, align 4
  %add19 = add nsw i32 %24, %25
  %26 = load i32* %src_whole_rows.addr, align 4
  %cmp20 = icmp slt i32 %add19, %26
  br label %land.end

land.end:                                         ; preds = %land.rhs, %land.lhs.true16, %land.lhs.true, %for.body
  %27 = phi i1 [ false, %land.lhs.true16 ], [ false, %land.lhs.true ], [ false, %for.body ], [ %cmp20, %land.rhs ]
  %frombool = zext i1 %27 to i8
  store i8 %frombool, i8* %con, align 1
  %28 = load i32* %startX, align 4
  %29 = load i32* %col, align 4
  %add21 = add nsw i32 %28, %29
  %30 = load i32* %src_whole_cols.addr, align 4
  %call22 = call i32 bitcast (i32 (...)* @clamp to i32 (i32, i32, i32)*)(i32 %add21, i32 0, i32 %30) #3
  store i32 %call22, i32* %cur_col, align 4
  %31 = load i32* %startY, align 4
  %32 = load i32* %i, align 4
  %add23 = add nsw i32 %31, %32
  %33 = load i32* %src_whole_rows.addr, align 4
  %cmp24 = icmp slt i32 %add23, %33
  br i1 %cmp24, label %land.lhs.true25, label %cond.false

land.lhs.true25:                                  ; preds = %land.end
  %34 = load i32* %startY, align 4
  %35 = load i32* %i, align 4
  %add26 = add nsw i32 %34, %35
  %cmp27 = icmp sge i32 %add26, 0
  br i1 %cmp27, label %land.lhs.true28, label %cond.false

land.lhs.true28:                                  ; preds = %land.lhs.true25
  %36 = load i32* %cur_col, align 4
  %cmp29 = icmp sge i32 %36, 0
  br i1 %cmp29, label %land.lhs.true30, label %cond.false

land.lhs.true30:                                  ; preds = %land.lhs.true28
  %37 = load i32* %cur_col, align 4
  %38 = load i32* %src_whole_cols.addr, align 4
  %cmp31 = icmp slt i32 %37, %38
  br i1 %cmp31, label %cond.true, label %cond.false

cond.true:                                        ; preds = %land.lhs.true30
  %39 = load i32* %startY, align 4
  %40 = load i32* %i, align 4
  %add32 = add nsw i32 %39, %40
  %41 = load i32* %src_step.addr, align 4
  %shr33 = ashr i32 %41, 4
  %mul34 = mul nsw i32 %add32, %shr33
  %42 = load i32* %cur_col, align 4
  %add35 = add nsw i32 %mul34, %42
  %43 = load <4 x float> addrspace(1)** %src.addr, align 4
  %arrayidx = getelementptr inbounds <4 x float> addrspace(1)* %43, i32 %add35
  %44 = load <4 x float> addrspace(1)* %arrayidx, align 16
  br label %cond.end

cond.false:                                       ; preds = %land.lhs.true30, %land.lhs.true28, %land.lhs.true25, %land.end
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi <4 x float> [ %44, %cond.true ], [ zeroinitializer, %cond.false ]
  store <4 x float> %cond, <4 x float>* %ss, align 16
  %45 = load i8* %con, align 1
  %tobool = trunc i8 %45 to i1
  br i1 %tobool, label %cond.true36, label %cond.false37

cond.true36:                                      ; preds = %cond.end
  %46 = load <4 x float>* %ss, align 16
  br label %cond.end38

cond.false37:                                     ; preds = %cond.end
  store <4 x float> zeroinitializer, <4 x float>* %.compoundliteral
  %47 = load <4 x float>* %.compoundliteral
  br label %cond.end38

cond.end38:                                       ; preds = %cond.false37, %cond.true36
  %cond39 = phi <4 x float> [ %46, %cond.true36 ], [ %47, %cond.false37 ]
  %48 = load i32* %i, align 4
  %arrayidx40 = getelementptr inbounds [4 x <4 x float>]* %data, i32 0, i32 %48
  store <4 x float> %cond39, <4 x float>* %arrayidx40, align 16
  br label %for.inc

for.inc:                                          ; preds = %cond.end38
  %49 = load i32* %i, align 4
  %inc = add nsw i32 %49, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  store <4 x float> zeroinitializer, <4 x float>* %sum0, align 16
  store <4 x float> zeroinitializer, <4 x float>* %sum1, align 16
  store <4 x float> zeroinitializer, <4 x float>* %sum2, align 16
  store i32 1, i32* %i41, align 4
  br label %for.cond42

for.cond42:                                       ; preds = %for.inc47, %for.end
  %50 = load i32* %i41, align 4
  %cmp43 = icmp slt i32 %50, 3
  br i1 %cmp43, label %for.body44, label %for.end49

for.body44:                                       ; preds = %for.cond42
  %51 = load i32* %i41, align 4
  %arrayidx45 = getelementptr inbounds [4 x <4 x float>]* %data, i32 0, i32 %51
  %52 = load <4 x float>* %arrayidx45, align 16
  %53 = load <4 x float>* %sum0, align 16
  %add46 = fadd <4 x float> %53, %52
  store <4 x float> %add46, <4 x float>* %sum0, align 16
  br label %for.inc47

for.inc47:                                        ; preds = %for.body44
  %54 = load i32* %i41, align 4
  %inc48 = add nsw i32 %54, 1
  store i32 %inc48, i32* %i41, align 4
  br label %for.cond42

for.end49:                                        ; preds = %for.cond42
  %55 = load <4 x float>* %sum0, align 16
  %arrayidx50 = getelementptr inbounds [4 x <4 x float>]* %data, i32 0, i32 0
  %56 = load <4 x float>* %arrayidx50, align 16
  %add51 = fadd <4 x float> %55, %56
  store <4 x float> %add51, <4 x float>* %sum1, align 16
  %57 = load <4 x float>* %sum0, align 16
  %arrayidx52 = getelementptr inbounds [4 x <4 x float>]* %data, i32 0, i32 3
  %58 = load <4 x float>* %arrayidx52, align 16
  %add53 = fadd <4 x float> %57, %58
  store <4 x float> %add53, <4 x float>* %sum2, align 16
  %59 = load <4 x float>* %sum1, align 16
  %60 = load i32* %col, align 4
  %arrayidx54 = getelementptr inbounds [256 x <4 x float>] addrspace(3)* getelementptr inbounds ([2 x [256 x <4 x float>]] addrspace(3)* @boxFilter_C4_D5.temp, i32 0, i32 0), i32 0, i32 %60
  store <4 x float> %59, <4 x float> addrspace(3)* %arrayidx54, align 16
  %61 = load <4 x float>* %sum2, align 16
  %62 = load i32* %col, align 4
  %arrayidx55 = getelementptr inbounds [256 x <4 x float>] addrspace(3)* getelementptr inbounds ([2 x [256 x <4 x float>]] addrspace(3)* @boxFilter_C4_D5.temp, i32 0, i32 1), i32 0, i32 %62
  store <4 x float> %61, <4 x float> addrspace(3)* %arrayidx55, align 16
  call void @barrier(i32 1) #3
  %63 = load i32* %col, align 4
  %cmp56 = icmp slt i32 %63, 254
  br i1 %cmp56, label %if.then, label %if.end106

if.then:                                          ; preds = %for.end49
  %64 = load i32* %col, align 4
  %add57 = add nsw i32 %64, 1
  store i32 %add57, i32* %col, align 4
  %65 = load i32* %dst_startX, align 4
  %66 = load i32* %dst_x_off, align 4
  %sub58 = sub nsw i32 %65, %66
  %67 = load i32* %col, align 4
  %add59 = add nsw i32 %sub58, %67
  %sub60 = sub nsw i32 %add59, 1
  store i32 %sub60, i32* %posX, align 4
  %68 = load i32* %gY, align 4
  %shl61 = shl i32 %68, 1
  store i32 %shl61, i32* %posY, align 4
  %69 = bitcast [2 x <4 x float>]* %tmp_sum to i8*
  call void @llvm.memset.p0i8.i32(i8* %69, i8 0, i32 32, i32 16, i1 false)
  store i32 0, i32* %k, align 4
  br label %for.cond62

for.cond62:                                       ; preds = %for.inc77, %if.then
  %70 = load i32* %k, align 4
  %cmp63 = icmp slt i32 %70, 2
  br i1 %cmp63, label %for.body64, label %for.end79

for.body64:                                       ; preds = %for.cond62
  store i32 -1, i32* %i65, align 4
  br label %for.cond66

for.cond66:                                       ; preds = %for.inc74, %for.body64
  %71 = load i32* %i65, align 4
  %cmp67 = icmp sle i32 %71, 1
  br i1 %cmp67, label %for.body68, label %for.end76

for.body68:                                       ; preds = %for.cond66
  %72 = load i32* %col, align 4
  %73 = load i32* %i65, align 4
  %add69 = add nsw i32 %72, %73
  %74 = load i32* %k, align 4
  %arrayidx70 = getelementptr inbounds [2 x [256 x <4 x float>]] addrspace(3)* @boxFilter_C4_D5.temp, i32 0, i32 %74
  %arrayidx71 = getelementptr inbounds [256 x <4 x float>] addrspace(3)* %arrayidx70, i32 0, i32 %add69
  %75 = load <4 x float> addrspace(3)* %arrayidx71, align 16
  %76 = load i32* %k, align 4
  %arrayidx72 = getelementptr inbounds [2 x <4 x float>]* %tmp_sum, i32 0, i32 %76
  %77 = load <4 x float>* %arrayidx72, align 16
  %add73 = fadd <4 x float> %77, %75
  store <4 x float> %add73, <4 x float>* %arrayidx72, align 16
  br label %for.inc74

for.inc74:                                        ; preds = %for.body68
  %78 = load i32* %i65, align 4
  %inc75 = add nsw i32 %78, 1
  store i32 %inc75, i32* %i65, align 4
  br label %for.cond66

for.end76:                                        ; preds = %for.cond66
  br label %for.inc77

for.inc77:                                        ; preds = %for.end76
  %79 = load i32* %k, align 4
  %inc78 = add nsw i32 %79, 1
  store i32 %inc78, i32* %k, align 4
  br label %for.cond62

for.end79:                                        ; preds = %for.cond62
  store i32 0, i32* %i80, align 4
  br label %for.cond81

for.cond81:                                       ; preds = %for.inc103, %for.end79
  %80 = load i32* %i80, align 4
  %cmp82 = icmp slt i32 %80, 2
  br i1 %cmp82, label %for.body83, label %for.end105

for.body83:                                       ; preds = %for.cond81
  %81 = load i32* %posX, align 4
  %cmp84 = icmp sge i32 %81, 0
  br i1 %cmp84, label %land.lhs.true85, label %if.end

land.lhs.true85:                                  ; preds = %for.body83
  %82 = load i32* %posX, align 4
  %83 = load i32* %dst_cols.addr, align 4
  %cmp86 = icmp slt i32 %82, %83
  br i1 %cmp86, label %land.lhs.true87, label %if.end

land.lhs.true87:                                  ; preds = %land.lhs.true85
  %84 = load i32* %posY, align 4
  %85 = load i32* %i80, align 4
  %add88 = add nsw i32 %84, %85
  %cmp89 = icmp sge i32 %add88, 0
  br i1 %cmp89, label %land.lhs.true90, label %if.end

land.lhs.true90:                                  ; preds = %land.lhs.true87
  %86 = load i32* %posY, align 4
  %87 = load i32* %i80, align 4
  %add91 = add nsw i32 %86, %87
  %88 = load i32* %dst_rows.addr, align 4
  %cmp92 = icmp slt i32 %add91, %88
  br i1 %cmp92, label %if.then93, label %if.end

if.then93:                                        ; preds = %land.lhs.true90
  %89 = load i32* %i80, align 4
  %arrayidx94 = getelementptr inbounds [2 x <4 x float>]* %tmp_sum, i32 0, i32 %89
  %90 = load <4 x float>* %arrayidx94, align 16
  %91 = load float* %alpha.addr, align 4
  %splat.splatinsert = insertelement <4 x float> undef, float %91, i32 0
  %splat.splat = shufflevector <4 x float> %splat.splatinsert, <4 x float> undef, <4 x i32> zeroinitializer
  %div95 = fdiv <4 x float> %90, %splat.splat, !fpmath !7
  %92 = load i32* %dst_startY, align 4
  %93 = load i32* %i80, align 4
  %add96 = add nsw i32 %92, %93
  %94 = load i32* %dst_step.addr, align 4
  %shr97 = ashr i32 %94, 4
  %mul98 = mul nsw i32 %add96, %shr97
  %95 = load i32* %dst_startX, align 4
  %add99 = add nsw i32 %mul98, %95
  %96 = load i32* %col, align 4
  %add100 = add nsw i32 %add99, %96
  %sub101 = sub nsw i32 %add100, 1
  %97 = load <4 x float> addrspace(1)** %dst.addr, align 4
  %arrayidx102 = getelementptr inbounds <4 x float> addrspace(1)* %97, i32 %sub101
  store <4 x float> %div95, <4 x float> addrspace(1)* %arrayidx102, align 16
  br label %if.end

if.end:                                           ; preds = %if.then93, %land.lhs.true90, %land.lhs.true87, %land.lhs.true85, %for.body83
  br label %for.inc103

for.inc103:                                       ; preds = %if.end
  %98 = load i32* %i80, align 4
  %inc104 = add nsw i32 %98, 1
  store i32 %inc104, i32* %i80, align 4
  br label %for.cond81

for.end105:                                       ; preds = %for.cond81
  br label %if.end106

if.end106:                                        ; preds = %for.end105, %for.end49
  ret void
}

declare i32 @get_local_id(i32) #1

declare i32 @get_group_id(i32) #1

declare i32 @clamp(...) #1

declare void @barrier(i32) #1

; Function Attrs: nounwind
declare void @llvm.memset.p0i8.i32(i8* nocapture, i8, i32, i32, i1) #2

attributes #0 = { nounwind "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-realign-stack" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-realign-stack" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind }
attributes #3 = { nobuiltin }

!opencl.kernels = !{!0}
!llvm.ident = !{!6}

!0 = metadata !{void (<4 x float> addrspace(1)*, <4 x float> addrspace(1)*, float, i32, i32, i32, i32, i32, i32, i32, i32)* @boxFilter_C4_D5, metadata !1, metadata !2, metadata !3, metadata !4, metadata !5}
!1 = metadata !{metadata !"kernel_arg_addr_space", i32 1, i32 1, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0}
!2 = metadata !{metadata !"kernel_arg_access_qual", metadata !"none", metadata !"none", metadata !"none", metadata !"none", metadata !"none", metadata !"none", metadata !"none", metadata !"none", metadata !"none", metadata !"none", metadata !"none"}
!3 = metadata !{metadata !"kernel_arg_type", metadata !"float4*", metadata !"float4*", metadata !"float", metadata !"int", metadata !"int", metadata !"int", metadata !"int", metadata !"int", metadata !"int", metadata !"int", metadata !"int"}
!4 = metadata !{metadata !"kernel_arg_type_qual", metadata !"restrict const", metadata !"", metadata !"", metadata !"", metadata !"", metadata !"", metadata !"", metadata !"", metadata !"", metadata !"", metadata !""}
!5 = metadata !{metadata !"kernel_arg_name", metadata !"src", metadata !"dst", metadata !"alpha", metadata !"src_offset", metadata !"src_whole_rows", metadata !"src_whole_cols", metadata !"src_step", metadata !"dst_offset", metadata !"dst_rows", metadata !"dst_cols", metadata !"dst_step"}
!6 = metadata !{metadata !"clang version 3.4 (tags/RELEASE_34/final)"}
!7 = metadata !{float 2.500000e+00}
