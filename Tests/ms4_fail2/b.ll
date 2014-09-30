; ModuleID = 'ms4_fail2.cl'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.tlb_data = type { i32, [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], i32, i32, i32 }

@boxFilter_C4_D5.temp = internal global [2 x [256 x <4 x float>]] zeroinitializer, align 16
@TLB = common global %struct.tlb_data zeroinitializer, align 4

; Function Attrs: nounwind uwtable
define void @boxFilter_C4_D5(<4 x float>* noalias %src, <4 x float>* %dst, float %alpha, i32 %src_offset, i32 %src_whole_rows, i32 %src_whole_cols, i32 %src_step, i32 %dst_offset, i32 %dst_rows, i32 %dst_cols, i32 %dst_step) #0 {
entry:
  %src.addr = alloca <4 x float>*, align 8
  %dst.addr = alloca <4 x float>*, align 8
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
  %i42 = alloca i32, align 4
  %posX = alloca i32, align 4
  %posY = alloca i32, align 4
  %tmp_sum = alloca [2 x <4 x float>], align 16
  %k = alloca i32, align 4
  %i69 = alloca i32, align 4
  %i87 = alloca i32, align 4
  store <4 x float>* %src, <4 x float>** %src.addr, align 8
  store <4 x float>* %dst, <4 x float>** %dst.addr, align 8
  store float %alpha, float* %alpha.addr, align 4
  store i32 %src_offset, i32* %src_offset.addr, align 4
  store i32 %src_whole_rows, i32* %src_whole_rows.addr, align 4
  store i32 %src_whole_cols, i32* %src_whole_cols.addr, align 4
  store i32 %src_step, i32* %src_step.addr, align 4
  store i32 %dst_offset, i32* %dst_offset.addr, align 4
  store i32 %dst_rows, i32* %dst_rows.addr, align 4
  store i32 %dst_cols, i32* %dst_cols.addr, align 4
  store i32 %dst_step, i32* %dst_step.addr, align 4
  %call = call i32 @get_local_id(i32 0)
  store i32 %call, i32* %col, align 4
  %call1 = call i32 @get_group_id(i32 0)
  store i32 %call1, i32* %gX, align 4
  %call2 = call i32 @get_group_id(i32 1)
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
  %call22 = call i32 (i32, i32, i32, ...)* bitcast (i32 (...)* @clamp to i32 (i32, i32, i32, ...)*)(i32 %add21, i32 0, i32 %30)
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
  %idxprom = sext i32 %add35 to i64
  %43 = load <4 x float>** %src.addr, align 8
  %arrayidx = getelementptr inbounds <4 x float>* %43, i64 %idxprom
  %44 = load <4 x float>* %arrayidx, align 16
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
  %idxprom40 = sext i32 %48 to i64
  %arrayidx41 = getelementptr inbounds [4 x <4 x float>]* %data, i32 0, i64 %idxprom40
  store <4 x float> %cond39, <4 x float>* %arrayidx41, align 16
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
  store i32 1, i32* %i42, align 4
  br label %for.cond43

for.cond43:                                       ; preds = %for.inc49, %for.end
  %50 = load i32* %i42, align 4
  %cmp44 = icmp slt i32 %50, 3
  br i1 %cmp44, label %for.body45, label %for.end51

for.body45:                                       ; preds = %for.cond43
  %51 = load i32* %i42, align 4
  %idxprom46 = sext i32 %51 to i64
  %arrayidx47 = getelementptr inbounds [4 x <4 x float>]* %data, i32 0, i64 %idxprom46
  %52 = load <4 x float>* %arrayidx47, align 16
  %53 = load <4 x float>* %sum0, align 16
  %add48 = fadd <4 x float> %53, %52
  store <4 x float> %add48, <4 x float>* %sum0, align 16
  br label %for.inc49

for.inc49:                                        ; preds = %for.body45
  %54 = load i32* %i42, align 4
  %inc50 = add nsw i32 %54, 1
  store i32 %inc50, i32* %i42, align 4
  br label %for.cond43

for.end51:                                        ; preds = %for.cond43
  %55 = load <4 x float>* %sum0, align 16
  %arrayidx52 = getelementptr inbounds [4 x <4 x float>]* %data, i32 0, i64 0
  %56 = load <4 x float>* %arrayidx52, align 16
  %add53 = fadd <4 x float> %55, %56
  store <4 x float> %add53, <4 x float>* %sum1, align 16
  %57 = load <4 x float>* %sum0, align 16
  %arrayidx54 = getelementptr inbounds [4 x <4 x float>]* %data, i32 0, i64 3
  %58 = load <4 x float>* %arrayidx54, align 16
  %add55 = fadd <4 x float> %57, %58
  store <4 x float> %add55, <4 x float>* %sum2, align 16
  %59 = load <4 x float>* %sum1, align 16
  %60 = load i32* %col, align 4
  %idxprom56 = sext i32 %60 to i64
  %arrayidx57 = getelementptr inbounds [256 x <4 x float>]* getelementptr inbounds ([2 x [256 x <4 x float>]]* @boxFilter_C4_D5.temp, i32 0, i64 0), i32 0, i64 %idxprom56
  store <4 x float> %59, <4 x float>* %arrayidx57, align 16
  %61 = load <4 x float>* %sum2, align 16
  %62 = load i32* %col, align 4
  %idxprom58 = sext i32 %62 to i64
  %arrayidx59 = getelementptr inbounds [256 x <4 x float>]* getelementptr inbounds ([2 x [256 x <4 x float>]]* @boxFilter_C4_D5.temp, i32 0, i64 1), i32 0, i64 %idxprom58
  store <4 x float> %61, <4 x float>* %arrayidx59, align 16
  call void @barrier(i32 1)
  %63 = load i32* %col, align 4
  %cmp60 = icmp slt i32 %63, 254
  br i1 %cmp60, label %if.then, label %if.end115

if.then:                                          ; preds = %for.end51
  %64 = load i32* %col, align 4
  %add61 = add nsw i32 %64, 1
  store i32 %add61, i32* %col, align 4
  %65 = load i32* %dst_startX, align 4
  %66 = load i32* %dst_x_off, align 4
  %sub62 = sub nsw i32 %65, %66
  %67 = load i32* %col, align 4
  %add63 = add nsw i32 %sub62, %67
  %sub64 = sub nsw i32 %add63, 1
  store i32 %sub64, i32* %posX, align 4
  %68 = load i32* %gY, align 4
  %shl65 = shl i32 %68, 1
  store i32 %shl65, i32* %posY, align 4
  %69 = bitcast [2 x <4 x float>]* %tmp_sum to i8*
  call void @llvm.memset.p0i8.i64(i8* %69, i8 0, i64 32, i32 16, i1 false)
  store i32 0, i32* %k, align 4
  br label %for.cond66

for.cond66:                                       ; preds = %for.inc84, %if.then
  %70 = load i32* %k, align 4
  %cmp67 = icmp slt i32 %70, 2
  br i1 %cmp67, label %for.body68, label %for.end86

for.body68:                                       ; preds = %for.cond66
  store i32 -1, i32* %i69, align 4
  br label %for.cond70

for.cond70:                                       ; preds = %for.inc81, %for.body68
  %71 = load i32* %i69, align 4
  %cmp71 = icmp sle i32 %71, 1
  br i1 %cmp71, label %for.body72, label %for.end83

for.body72:                                       ; preds = %for.cond70
  %72 = load i32* %col, align 4
  %73 = load i32* %i69, align 4
  %add73 = add nsw i32 %72, %73
  %idxprom74 = sext i32 %add73 to i64
  %74 = load i32* %k, align 4
  %idxprom75 = sext i32 %74 to i64
  %arrayidx76 = getelementptr inbounds [2 x [256 x <4 x float>]]* @boxFilter_C4_D5.temp, i32 0, i64 %idxprom75
  %arrayidx77 = getelementptr inbounds [256 x <4 x float>]* %arrayidx76, i32 0, i64 %idxprom74
  %75 = load <4 x float>* %arrayidx77, align 16
  %76 = load i32* %k, align 4
  %idxprom78 = sext i32 %76 to i64
  %arrayidx79 = getelementptr inbounds [2 x <4 x float>]* %tmp_sum, i32 0, i64 %idxprom78
  %77 = load <4 x float>* %arrayidx79, align 16
  %add80 = fadd <4 x float> %77, %75
  store <4 x float> %add80, <4 x float>* %arrayidx79, align 16
  br label %for.inc81

for.inc81:                                        ; preds = %for.body72
  %78 = load i32* %i69, align 4
  %inc82 = add nsw i32 %78, 1
  store i32 %inc82, i32* %i69, align 4
  br label %for.cond70

for.end83:                                        ; preds = %for.cond70
  br label %for.inc84

for.inc84:                                        ; preds = %for.end83
  %79 = load i32* %k, align 4
  %inc85 = add nsw i32 %79, 1
  store i32 %inc85, i32* %k, align 4
  br label %for.cond66

for.end86:                                        ; preds = %for.cond66
  store i32 0, i32* %i87, align 4
  br label %for.cond88

for.cond88:                                       ; preds = %for.inc112, %for.end86
  %80 = load i32* %i87, align 4
  %cmp89 = icmp slt i32 %80, 2
  br i1 %cmp89, label %for.body90, label %for.end114

for.body90:                                       ; preds = %for.cond88
  %81 = load i32* %posX, align 4
  %cmp91 = icmp sge i32 %81, 0
  br i1 %cmp91, label %land.lhs.true92, label %if.end

land.lhs.true92:                                  ; preds = %for.body90
  %82 = load i32* %posX, align 4
  %83 = load i32* %dst_cols.addr, align 4
  %cmp93 = icmp slt i32 %82, %83
  br i1 %cmp93, label %land.lhs.true94, label %if.end

land.lhs.true94:                                  ; preds = %land.lhs.true92
  %84 = load i32* %posY, align 4
  %85 = load i32* %i87, align 4
  %add95 = add nsw i32 %84, %85
  %cmp96 = icmp sge i32 %add95, 0
  br i1 %cmp96, label %land.lhs.true97, label %if.end

land.lhs.true97:                                  ; preds = %land.lhs.true94
  %86 = load i32* %posY, align 4
  %87 = load i32* %i87, align 4
  %add98 = add nsw i32 %86, %87
  %88 = load i32* %dst_rows.addr, align 4
  %cmp99 = icmp slt i32 %add98, %88
  br i1 %cmp99, label %if.then100, label %if.end

if.then100:                                       ; preds = %land.lhs.true97
  %89 = load i32* %i87, align 4
  %idxprom101 = sext i32 %89 to i64
  %arrayidx102 = getelementptr inbounds [2 x <4 x float>]* %tmp_sum, i32 0, i64 %idxprom101
  %90 = load <4 x float>* %arrayidx102, align 16
  %91 = load float* %alpha.addr, align 4
  %splat.splatinsert = insertelement <4 x float> undef, float %91, i32 0
  %splat.splat = shufflevector <4 x float> %splat.splatinsert, <4 x float> undef, <4 x i32> zeroinitializer
  %div103 = fdiv <4 x float> %90, %splat.splat, !fpmath !2
  %92 = load i32* %dst_startY, align 4
  %93 = load i32* %i87, align 4
  %add104 = add nsw i32 %92, %93
  %94 = load i32* %dst_step.addr, align 4
  %shr105 = ashr i32 %94, 4
  %mul106 = mul nsw i32 %add104, %shr105
  %95 = load i32* %dst_startX, align 4
  %add107 = add nsw i32 %mul106, %95
  %96 = load i32* %col, align 4
  %add108 = add nsw i32 %add107, %96
  %sub109 = sub nsw i32 %add108, 1
  %idxprom110 = sext i32 %sub109 to i64
  %97 = load <4 x float>** %dst.addr, align 8
  %arrayidx111 = getelementptr inbounds <4 x float>* %97, i64 %idxprom110
  store <4 x float> %div103, <4 x float>* %arrayidx111, align 16
  br label %if.end

if.end:                                           ; preds = %if.then100, %land.lhs.true97, %land.lhs.true94, %land.lhs.true92, %for.body90
  br label %for.inc112

for.inc112:                                       ; preds = %if.end
  %98 = load i32* %i87, align 4
  %inc113 = add nsw i32 %98, 1
  store i32 %inc113, i32* %i87, align 4
  br label %for.cond88

for.end114:                                       ; preds = %for.cond88
  br label %if.end115

if.end115:                                        ; preds = %for.end114, %for.end51
  ret void
}

declare i32 @get_local_id(i32) #1

declare i32 @get_group_id(i32) #1

declare i32 @clamp(...) #1

declare void @barrier(i32) #1

; Function Attrs: nounwind
declare void @llvm.memset.p0i8.i64(i8* nocapture, i8, i64, i32, i1) #2

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind }

!opencl.kernels = !{!0}
!llvm.ident = !{!1}

!0 = metadata !{void (<4 x float>*, <4 x float>*, float, i32, i32, i32, i32, i32, i32, i32, i32)* @boxFilter_C4_D5}
!1 = metadata !{metadata !"clang version 3.4 (tags/RELEASE_34/final)"}
!2 = metadata !{float 2.500000e+00}
