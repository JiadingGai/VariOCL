; ModuleID = '<stdin>'
target datalayout = "e-p:32:32:32-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:64:128-a0:0:64-n32-S64"
target triple = "armv7--linux-androideabi"

@row_filter_C1_D0.LDS_DAT = internal global [16 x [33 x <4 x i8>]] zeroinitializer, align 4
@row_filter_C4_D0.LDS_DAT = internal global [16 x [33 x <4 x i8>]] zeroinitializer, align 4
@row_filter_C1_D5.LDS_DAT = internal global [16 x [33 x float]] zeroinitializer, align 4
@row_filter_C4_D5.LDS_DAT = internal global [16 x [33 x <4 x float>]] zeroinitializer, align 16

; Function Attrs: nounwind
define void @row_filter_C1_D0(i8* noalias %src, float* %dst, i32 %dst_cols, i32 %dst_rows, i32 %src_whole_cols, i32 %src_whole_rows, i32 %src_step_in_pixel, i32 %src_offset_x, i32 %src_offset_y, i32 %dst_step_in_pixel, i32 %radiusy, float* %mat_kernel) #0 {
entry:
  %temp = alloca [2 x <4 x i8>], align 4
  %index = alloca [2 x <4 x i32>], align 16
  %coerce = alloca <4 x i8>, align 4
  %coerce208 = alloca <4 x i8>, align 4
  %coerce216 = alloca <4 x i8>, align 4
  %call = call i32 @get_global_id(i32 0)
  %shl = shl i32 %call, 2
  %call1 = call i32 @get_global_id(i32 1)
  %call2 = call i32 @get_local_id(i32 0)
  %call3 = call i32 @get_local_id(i32 1)
  %add = add nsw i32 %shl, %src_offset_x
  %sub = sub nsw i32 %add, 2
  %and = and i32 %sub, -4
  %sub4 = sub nsw i32 %src_offset_x, 2
  %and5 = and i32 %sub4, 3
  %add6 = add nsw i32 %call1, %src_offset_y
  %sub7 = sub nsw i32 %add6, %radiusy
  %call8 = call i32 @_Z11_socl_mad24iii(i32 %sub7, i32 %src_step_in_pixel, i32 %and)
  %cmp = icmp slt i32 %and, 0
  %conv = zext i1 %cmp to i32
  %add9 = add nsw i32 %and, 128
  %add10 = add nsw i32 %add9, 4
  %cmp11 = icmp sgt i32 %add10, %src_whole_cols
  %conv12 = zext i1 %cmp11 to i32
  %or = or i32 %conv, %conv12
  %cmp13 = icmp slt i32 %sub7, 0
  %conv14 = zext i1 %cmp13 to i32
  %or15 = or i32 %or, %conv14
  %cmp16 = icmp sge i32 %sub7, %src_whole_rows
  %conv17 = zext i1 %cmp16 to i32
  %or18 = or i32 %or15, %conv17
  %tobool = icmp ne i32 %or18, 0
  br i1 %tobool, label %for.cond, label %for.cond156

for.cond:                                         ; preds = %entry, %cond.end121
  %i.0 = phi i32 [ %inc, %cond.end121 ], [ 0, %entry ]
  %cmp19 = icmp slt i32 %i.0, 2
  br i1 %cmp19, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %mul = mul nsw i32 %i.0, 16
  %mul21 = mul nsw i32 %mul, 4
  %add22 = add nsw i32 %and, %mul21
  %cmp23 = icmp slt i32 %add22, 0
  %cond = select i1 %cmp23, i32 0, i32 %add22
  %arrayidx = getelementptr inbounds [2 x <4 x i32>]* %index, i32 0, i32 %i.0
  %0 = load <4 x i32>* %arrayidx, align 16
  %1 = insertelement <4 x i32> %0, i32 %cond, i32 0
  store <4 x i32> %1, <4 x i32>* %arrayidx, align 16
  %mul28 = mul nsw i32 %i.0, 16
  %mul29 = mul nsw i32 %mul28, 4
  %add30 = add nsw i32 %and, %mul29
  %cmp31 = icmp sge i32 %add30, %src_whole_cols
  br i1 %cmp31, label %cond.true33, label %cond.false35

cond.true33:                                      ; preds = %for.body
  %sub34 = sub nsw i32 %src_whole_cols, 1
  br label %cond.end37

cond.false35:                                     ; preds = %for.body
  %arrayidx36 = getelementptr inbounds [2 x <4 x i32>]* %index, i32 0, i32 %i.0
  %2 = load <4 x i32>* %arrayidx36, align 16
  %3 = extractelement <4 x i32> %2, i32 0
  br label %cond.end37

cond.end37:                                       ; preds = %cond.false35, %cond.true33
  %cond38 = phi i32 [ %sub34, %cond.true33 ], [ %3, %cond.false35 ]
  %arrayidx39 = getelementptr inbounds [2 x <4 x i32>]* %index, i32 0, i32 %i.0
  %4 = load <4 x i32>* %arrayidx39, align 16
  %5 = insertelement <4 x i32> %4, i32 %cond38, i32 0
  store <4 x i32> %5, <4 x i32>* %arrayidx39, align 16
  %mul40 = mul nsw i32 %i.0, 16
  %mul41 = mul nsw i32 %mul40, 4
  %add42 = add nsw i32 %and, %mul41
  %add43 = add nsw i32 %add42, 1
  %cmp44 = icmp slt i32 %add43, 0
  %cond53 = select i1 %cmp44, i32 0, i32 %add43
  %arrayidx54 = getelementptr inbounds [2 x <4 x i32>]* %index, i32 0, i32 %i.0
  %6 = load <4 x i32>* %arrayidx54, align 16
  %7 = insertelement <4 x i32> %6, i32 %cond53, i32 1
  store <4 x i32> %7, <4 x i32>* %arrayidx54, align 16
  %mul55 = mul nsw i32 %i.0, 16
  %mul56 = mul nsw i32 %mul55, 4
  %add57 = add nsw i32 %and, %mul56
  %add58 = add nsw i32 %add57, 1
  %cmp59 = icmp sge i32 %add58, %src_whole_cols
  br i1 %cmp59, label %cond.true61, label %cond.false63

cond.true61:                                      ; preds = %cond.end37
  %sub62 = sub nsw i32 %src_whole_cols, 1
  br label %cond.end65

cond.false63:                                     ; preds = %cond.end37
  %arrayidx64 = getelementptr inbounds [2 x <4 x i32>]* %index, i32 0, i32 %i.0
  %8 = load <4 x i32>* %arrayidx64, align 16
  %9 = extractelement <4 x i32> %8, i32 1
  br label %cond.end65

cond.end65:                                       ; preds = %cond.false63, %cond.true61
  %cond66 = phi i32 [ %sub62, %cond.true61 ], [ %9, %cond.false63 ]
  %arrayidx67 = getelementptr inbounds [2 x <4 x i32>]* %index, i32 0, i32 %i.0
  %10 = load <4 x i32>* %arrayidx67, align 16
  %11 = insertelement <4 x i32> %10, i32 %cond66, i32 1
  store <4 x i32> %11, <4 x i32>* %arrayidx67, align 16
  %mul68 = mul nsw i32 %i.0, 16
  %mul69 = mul nsw i32 %mul68, 4
  %add70 = add nsw i32 %and, %mul69
  %add71 = add nsw i32 %add70, 2
  %cmp72 = icmp slt i32 %add71, 0
  %cond81 = select i1 %cmp72, i32 0, i32 %add71
  %arrayidx82 = getelementptr inbounds [2 x <4 x i32>]* %index, i32 0, i32 %i.0
  %12 = load <4 x i32>* %arrayidx82, align 16
  %13 = insertelement <4 x i32> %12, i32 %cond81, i32 2
  store <4 x i32> %13, <4 x i32>* %arrayidx82, align 16
  %mul83 = mul nsw i32 %i.0, 16
  %mul84 = mul nsw i32 %mul83, 4
  %add85 = add nsw i32 %and, %mul84
  %add86 = add nsw i32 %add85, 2
  %cmp87 = icmp sge i32 %add86, %src_whole_cols
  br i1 %cmp87, label %cond.true89, label %cond.false91

cond.true89:                                      ; preds = %cond.end65
  %sub90 = sub nsw i32 %src_whole_cols, 1
  br label %cond.end93

cond.false91:                                     ; preds = %cond.end65
  %arrayidx92 = getelementptr inbounds [2 x <4 x i32>]* %index, i32 0, i32 %i.0
  %14 = load <4 x i32>* %arrayidx92, align 16
  %15 = extractelement <4 x i32> %14, i32 2
  br label %cond.end93

cond.end93:                                       ; preds = %cond.false91, %cond.true89
  %cond94 = phi i32 [ %sub90, %cond.true89 ], [ %15, %cond.false91 ]
  %arrayidx95 = getelementptr inbounds [2 x <4 x i32>]* %index, i32 0, i32 %i.0
  %16 = load <4 x i32>* %arrayidx95, align 16
  %17 = insertelement <4 x i32> %16, i32 %cond94, i32 2
  store <4 x i32> %17, <4 x i32>* %arrayidx95, align 16
  %mul96 = mul nsw i32 %i.0, 16
  %mul97 = mul nsw i32 %mul96, 4
  %add98 = add nsw i32 %and, %mul97
  %add99 = add nsw i32 %add98, 3
  %cmp100 = icmp slt i32 %add99, 0
  %cond109 = select i1 %cmp100, i32 0, i32 %add99
  %arrayidx110 = getelementptr inbounds [2 x <4 x i32>]* %index, i32 0, i32 %i.0
  %18 = load <4 x i32>* %arrayidx110, align 16
  %19 = insertelement <4 x i32> %18, i32 %cond109, i32 3
  store <4 x i32> %19, <4 x i32>* %arrayidx110, align 16
  %mul111 = mul nsw i32 %i.0, 16
  %mul112 = mul nsw i32 %mul111, 4
  %add113 = add nsw i32 %and, %mul112
  %add114 = add nsw i32 %add113, 3
  %cmp115 = icmp sge i32 %add114, %src_whole_cols
  br i1 %cmp115, label %cond.true117, label %cond.false119

cond.true117:                                     ; preds = %cond.end93
  %sub118 = sub nsw i32 %src_whole_cols, 1
  br label %cond.end121

cond.false119:                                    ; preds = %cond.end93
  %arrayidx120 = getelementptr inbounds [2 x <4 x i32>]* %index, i32 0, i32 %i.0
  %20 = load <4 x i32>* %arrayidx120, align 16
  %21 = extractelement <4 x i32> %20, i32 3
  br label %cond.end121

cond.end121:                                      ; preds = %cond.false119, %cond.true117
  %cond122 = phi i32 [ %sub118, %cond.true117 ], [ %21, %cond.false119 ]
  %arrayidx123 = getelementptr inbounds [2 x <4 x i32>]* %index, i32 0, i32 %i.0
  %22 = load <4 x i32>* %arrayidx123, align 16
  %23 = insertelement <4 x i32> %22, i32 %cond122, i32 3
  store <4 x i32> %23, <4 x i32>* %arrayidx123, align 16
  %inc = add nsw i32 %i.0, 1
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %cmp124 = icmp slt i32 %sub7, 0
  %.sub7 = select i1 %cmp124, i32 0, i32 %sub7
  %cmp130 = icmp sge i32 %sub7, %src_whole_rows
  %sub133 = sub nsw i32 %src_whole_rows, 1
  %cond136 = select i1 %cmp130, i32 %sub133, i32 %.sub7
  br label %for.cond137

for.cond137:                                      ; preds = %for.end, %for.body140
  %i.1 = phi i32 [ %inc154, %for.body140 ], [ 0, %for.end ]
  %cmp138 = icmp slt i32 %i.1, 2
  br i1 %cmp138, label %for.body140, label %for.cond168

for.body140:                                      ; preds = %for.cond137
  %splat.splatinsert = insertelement <4 x i32> undef, i32 %cond136, i32 0
  %splat.splat = shufflevector <4 x i32> %splat.splatinsert, <4 x i32> undef, <4 x i32> zeroinitializer
  %splat.splatinsert141 = insertelement <4 x i32> undef, i32 %src_step_in_pixel, i32 0
  %splat.splat142 = shufflevector <4 x i32> %splat.splatinsert141, <4 x i32> undef, <4 x i32> zeroinitializer
  %arrayidx143 = getelementptr inbounds [2 x <4 x i32>]* %index, i32 0, i32 %i.1
  %24 = load <4 x i32>* %arrayidx143, align 16
  %call144 = call <4 x i32> @_Z11_socl_mad24Dv4_iS_S_(<4 x i32> %splat.splat, <4 x i32> %splat.splat142, <4 x i32> %24)
  %25 = extractelement <4 x i32> %call144, i32 0
  %arrayidx145 = getelementptr inbounds i8* %src, i32 %25
  %26 = load i8* %arrayidx145, align 1
  %arrayidx146 = getelementptr inbounds [2 x <4 x i8>]* %temp, i32 0, i32 %i.1
  %27 = load <4 x i8>* %arrayidx146, align 4
  %28 = insertelement <4 x i8> %27, i8 %26, i32 0
  store <4 x i8> %28, <4 x i8>* %arrayidx146, align 4
  %29 = extractelement <4 x i32> %call144, i32 1
  %arrayidx147 = getelementptr inbounds i8* %src, i32 %29
  %30 = load i8* %arrayidx147, align 1
  %arrayidx148 = getelementptr inbounds [2 x <4 x i8>]* %temp, i32 0, i32 %i.1
  %31 = load <4 x i8>* %arrayidx148, align 4
  %32 = insertelement <4 x i8> %31, i8 %30, i32 1
  store <4 x i8> %32, <4 x i8>* %arrayidx148, align 4
  %33 = extractelement <4 x i32> %call144, i32 2
  %arrayidx149 = getelementptr inbounds i8* %src, i32 %33
  %34 = load i8* %arrayidx149, align 1
  %arrayidx150 = getelementptr inbounds [2 x <4 x i8>]* %temp, i32 0, i32 %i.1
  %35 = load <4 x i8>* %arrayidx150, align 4
  %36 = insertelement <4 x i8> %35, i8 %34, i32 2
  store <4 x i8> %36, <4 x i8>* %arrayidx150, align 4
  %37 = extractelement <4 x i32> %call144, i32 3
  %arrayidx151 = getelementptr inbounds i8* %src, i32 %37
  %38 = load i8* %arrayidx151, align 1
  %arrayidx152 = getelementptr inbounds [2 x <4 x i8>]* %temp, i32 0, i32 %i.1
  %39 = load <4 x i8>* %arrayidx152, align 4
  %40 = insertelement <4 x i8> %39, i8 %38, i32 3
  store <4 x i8> %40, <4 x i8>* %arrayidx152, align 4
  %inc154 = add nsw i32 %i.1, 1
  br label %for.cond137

for.cond156:                                      ; preds = %entry, %for.body159
  %i.2 = phi i32 [ %inc166, %for.body159 ], [ 0, %entry ]
  %cmp157 = icmp slt i32 %i.2, 2
  br i1 %cmp157, label %for.body159, label %for.cond168

for.body159:                                      ; preds = %for.cond156
  %mul160 = mul nsw i32 %i.2, 16
  %mul161 = mul nsw i32 %mul160, 4
  %add162 = add nsw i32 %call8, %mul161
  %arrayidx163 = getelementptr inbounds i8* %src, i32 %add162
  %41 = bitcast i8* %arrayidx163 to <4 x i8>*
  %42 = load <4 x i8>* %41, align 4
  %arrayidx164 = getelementptr inbounds [2 x <4 x i8>]* %temp, i32 0, i32 %i.2
  store <4 x i8> %42, <4 x i8>* %arrayidx164, align 4
  %inc166 = add nsw i32 %i.2, 1
  br label %for.cond156

for.cond168:                                      ; preds = %for.cond137, %for.cond156, %for.body171
  %i.3 = phi i32 [ %inc178, %for.body171 ], [ 0, %for.cond156 ], [ 0, %for.cond137 ]
  %cmp169 = icmp slt i32 %i.3, 2
  br i1 %cmp169, label %for.body171, label %for.end179

for.body171:                                      ; preds = %for.cond168
  %arrayidx172 = getelementptr inbounds [2 x <4 x i8>]* %temp, i32 0, i32 %i.3
  %43 = load <4 x i8>* %arrayidx172, align 4
  %mul173 = mul nsw i32 %i.3, 16
  %add174 = add nsw i32 %call2, %mul173
  %arrayidx175 = getelementptr inbounds [16 x [33 x <4 x i8>]]* @row_filter_C1_D0.LDS_DAT, i32 0, i32 %call3
  %arrayidx176 = getelementptr inbounds [33 x <4 x i8>]* %arrayidx175, i32 0, i32 %add174
  store <4 x i8> %43, <4 x i8>* %arrayidx176, align 4
  %inc178 = add nsw i32 %i.3, 1
  br label %for.cond168

for.end179:                                       ; preds = %for.cond168
  call void @barrier(i32 1)
  %arrayidx180 = getelementptr inbounds [16 x [33 x <4 x i8>]]* @row_filter_C1_D0.LDS_DAT, i32 0, i32 %call3
  %arrayidx181 = getelementptr inbounds [33 x <4 x i8>]* %arrayidx180, i32 0, i32 %call2
  %44 = bitcast <4 x i8>* %arrayidx181 to i8*
  %add.ptr = getelementptr inbounds i8* %44, i32 2
  %add.ptr182 = getelementptr inbounds i8* %add.ptr, i32 %and5
  %call183 = call <4 x i8> @_Z12_socl_vload4jPKU3AS0h(i32 0, i8* %add.ptr182)
  store <4 x i8> %call183, <4 x i8>* %coerce, align 4
  %45 = bitcast <4 x i8>* %coerce to i32*
  %46 = load i32* %45, align 1
  %call184 = call <4 x float> @_Z20_socl_convert_float4Dv4_h(i32 %46)
  %arrayidx185 = getelementptr inbounds float* %mat_kernel, i32 2
  %47 = load float* %arrayidx185, align 4
  %splat.splatinsert186 = insertelement <4 x float> undef, float %47, i32 0
  %splat.splat187 = shufflevector <4 x float> %splat.splatinsert186, <4 x float> undef, <4 x i32> zeroinitializer
  %mul188 = fmul <4 x float> %call184, %splat.splat187
  br label %for.cond189

for.cond189:                                      ; preds = %for.body192, %for.end179
  %i.4 = phi i32 [ 1, %for.end179 ], [ %inc225, %for.body192 ]
  %sum.0 = phi <4 x float> [ %mul188, %for.end179 ], [ %add223, %for.body192 ]
  %cmp190 = icmp sle i32 %i.4, 2
  br i1 %cmp190, label %for.body192, label %for.end226

for.body192:                                      ; preds = %for.cond189
  %arrayidx193 = getelementptr inbounds [16 x [33 x <4 x i8>]]* @row_filter_C1_D0.LDS_DAT, i32 0, i32 %call3
  %arrayidx194 = getelementptr inbounds [33 x <4 x i8>]* %arrayidx193, i32 0, i32 %call2
  %48 = bitcast <4 x i8>* %arrayidx194 to i8*
  %add.ptr195 = getelementptr inbounds i8* %48, i32 2
  %add.ptr196 = getelementptr inbounds i8* %add.ptr195, i32 %and5
  %idx.neg = sub i32 0, %i.4
  %add.ptr197 = getelementptr inbounds i8* %add.ptr196, i32 %idx.neg
  %call198 = call <4 x i8> @_Z12_socl_vload4jPKU3AS0h(i32 0, i8* %add.ptr197)
  %arrayidx199 = getelementptr inbounds [2 x <4 x i8>]* %temp, i32 0, i32 0
  store <4 x i8> %call198, <4 x i8>* %arrayidx199, align 4
  %arrayidx200 = getelementptr inbounds [16 x [33 x <4 x i8>]]* @row_filter_C1_D0.LDS_DAT, i32 0, i32 %call3
  %arrayidx201 = getelementptr inbounds [33 x <4 x i8>]* %arrayidx200, i32 0, i32 %call2
  %49 = bitcast <4 x i8>* %arrayidx201 to i8*
  %add.ptr202 = getelementptr inbounds i8* %49, i32 2
  %add.ptr203 = getelementptr inbounds i8* %add.ptr202, i32 %and5
  %add.ptr204 = getelementptr inbounds i8* %add.ptr203, i32 %i.4
  %call205 = call <4 x i8> @_Z12_socl_vload4jPKU3AS0h(i32 0, i8* %add.ptr204)
  %arrayidx206 = getelementptr inbounds [2 x <4 x i8>]* %temp, i32 0, i32 1
  store <4 x i8> %call205, <4 x i8>* %arrayidx206, align 4
  %arrayidx207 = getelementptr inbounds [2 x <4 x i8>]* %temp, i32 0, i32 0
  %50 = load <4 x i8>* %arrayidx207, align 4
  store <4 x i8> %50, <4 x i8>* %coerce208, align 4
  %51 = bitcast <4 x i8>* %coerce208 to i32*
  %52 = load i32* %51, align 1
  %call209 = call <4 x float> @_Z20_socl_convert_float4Dv4_h(i32 %52)
  %sub210 = sub nsw i32 2, %i.4
  %arrayidx211 = getelementptr inbounds float* %mat_kernel, i32 %sub210
  %53 = load float* %arrayidx211, align 4
  %splat.splatinsert212 = insertelement <4 x float> undef, float %53, i32 0
  %splat.splat213 = shufflevector <4 x float> %splat.splatinsert212, <4 x float> undef, <4 x i32> zeroinitializer
  %arrayidx215 = getelementptr inbounds [2 x <4 x i8>]* %temp, i32 0, i32 1
  %54 = load <4 x i8>* %arrayidx215, align 4
  store <4 x i8> %54, <4 x i8>* %coerce216, align 4
  %55 = bitcast <4 x i8>* %coerce216 to i32*
  %56 = load i32* %55, align 1
  %call217 = call <4 x float> @_Z20_socl_convert_float4Dv4_h(i32 %56)
  %add218 = add nsw i32 2, %i.4
  %arrayidx219 = getelementptr inbounds float* %mat_kernel, i32 %add218
  %57 = load float* %arrayidx219, align 4
  %splat.splatinsert220 = insertelement <4 x float> undef, float %57, i32 0
  %splat.splat221 = shufflevector <4 x float> %splat.splatinsert220, <4 x float> undef, <4 x i32> zeroinitializer
  %mul222 = fmul <4 x float> %call217, %splat.splat221
  %58 = call <4 x float> @llvm.fmuladd.v4f32(<4 x float> %call209, <4 x float> %splat.splat213, <4 x float> %mul222)
  %add223 = fadd <4 x float> %sum.0, %58
  %inc225 = add nsw i32 %i.4, 1
  br label %for.cond189

for.end226:                                       ; preds = %for.cond189
  %call227 = call i32 @_Z11_socl_mad24iii(i32 %call1, i32 %dst_step_in_pixel, i32 %shl)
  %add228 = add nsw i32 %shl, 3
  %cmp229 = icmp slt i32 %add228, %dst_cols
  %conv230 = zext i1 %cmp229 to i32
  %cmp231 = icmp slt i32 %call1, %dst_rows
  %conv232 = zext i1 %cmp231 to i32
  %and233 = and i32 %conv230, %conv232
  %tobool234 = icmp ne i32 %and233, 0
  br i1 %tobool234, label %if.then235, label %if.else237

if.then235:                                       ; preds = %for.end226
  %arrayidx236 = getelementptr inbounds float* %dst, i32 %call227
  %59 = bitcast float* %arrayidx236 to <4 x float>*
  store <4 x float> %sum.0, <4 x float>* %59, align 16
  br label %if.end275

if.else237:                                       ; preds = %for.end226
  %add238 = add nsw i32 %shl, 2
  %cmp239 = icmp slt i32 %add238, %dst_cols
  %conv240 = zext i1 %cmp239 to i32
  %cmp241 = icmp slt i32 %call1, %dst_rows
  %conv242 = zext i1 %cmp241 to i32
  %and243 = and i32 %conv240, %conv242
  %tobool244 = icmp ne i32 %and243, 0
  br i1 %tobool244, label %if.then245, label %if.else251

if.then245:                                       ; preds = %if.else237
  %60 = extractelement <4 x float> %sum.0, i32 0
  %arrayidx246 = getelementptr inbounds float* %dst, i32 %call227
  store float %60, float* %arrayidx246, align 4
  %61 = extractelement <4 x float> %sum.0, i32 1
  %add247 = add nsw i32 %call227, 1
  %arrayidx248 = getelementptr inbounds float* %dst, i32 %add247
  store float %61, float* %arrayidx248, align 4
  %62 = extractelement <4 x float> %sum.0, i32 2
  %add249 = add nsw i32 %call227, 2
  %arrayidx250 = getelementptr inbounds float* %dst, i32 %add249
  store float %62, float* %arrayidx250, align 4
  br label %if.end275

if.else251:                                       ; preds = %if.else237
  %add252 = add nsw i32 %shl, 1
  %cmp253 = icmp slt i32 %add252, %dst_cols
  %conv254 = zext i1 %cmp253 to i32
  %cmp255 = icmp slt i32 %call1, %dst_rows
  %conv256 = zext i1 %cmp255 to i32
  %and257 = and i32 %conv254, %conv256
  %tobool258 = icmp ne i32 %and257, 0
  br i1 %tobool258, label %if.then259, label %if.else263

if.then259:                                       ; preds = %if.else251
  %63 = extractelement <4 x float> %sum.0, i32 0
  %arrayidx260 = getelementptr inbounds float* %dst, i32 %call227
  store float %63, float* %arrayidx260, align 4
  %64 = extractelement <4 x float> %sum.0, i32 1
  %add261 = add nsw i32 %call227, 1
  %arrayidx262 = getelementptr inbounds float* %dst, i32 %add261
  store float %64, float* %arrayidx262, align 4
  br label %if.end275

if.else263:                                       ; preds = %if.else251
  %cmp264 = icmp slt i32 %shl, %dst_cols
  %conv265 = zext i1 %cmp264 to i32
  %cmp266 = icmp slt i32 %call1, %dst_rows
  %conv267 = zext i1 %cmp266 to i32
  %and268 = and i32 %conv265, %conv267
  %tobool269 = icmp ne i32 %and268, 0
  br i1 %tobool269, label %if.then270, label %if.end275

if.then270:                                       ; preds = %if.else263
  %65 = extractelement <4 x float> %sum.0, i32 0
  %arrayidx271 = getelementptr inbounds float* %dst, i32 %call227
  store float %65, float* %arrayidx271, align 4
  br label %if.end275

if.end275:                                        ; preds = %if.then245, %if.else263, %if.then270, %if.then259, %if.then235
  ret void
}

declare i32 @get_global_id(i32) #1

declare i32 @get_local_id(i32) #1

declare i32 @_Z11_socl_mad24iii(i32, i32, i32) #1

declare <4 x i32> @_Z11_socl_mad24Dv4_iS_S_(<4 x i32>, <4 x i32>, <4 x i32>) #1

declare void @barrier(i32) #1

declare <4 x float> @_Z20_socl_convert_float4Dv4_h(i32) #1

declare <4 x i8> @_Z12_socl_vload4jPKU3AS0h(i32, i8*) #1

; Function Attrs: nounwind readnone
declare <4 x float> @llvm.fmuladd.v4f32(<4 x float>, <4 x float>, <4 x float>) #2

; Function Attrs: nounwind
define void @row_filter_C4_D0(<4 x i8>* noalias %src, <4 x float>* %dst, i32 %dst_cols, i32 %dst_rows, i32 %src_whole_cols, i32 %src_whole_rows, i32 %src_step_in_pixel, i32 %src_offset_x, i32 %src_offset_y, i32 %dst_step_in_pixel, i32 %radiusy, float* %mat_kernel) #0 {
entry:
  %temp = alloca [2 x <4 x i8>], align 4
  %index = alloca [2 x i32], align 4
  %coerce = alloca <4 x i8>, align 4
  %coerce71 = alloca <4 x i8>, align 4
  %coerce79 = alloca <4 x i8>, align 4
  %call = call i32 @get_global_id(i32 0)
  %call1 = call i32 @get_global_id(i32 1)
  %call2 = call i32 @get_local_id(i32 0)
  %call3 = call i32 @get_local_id(i32 1)
  %add = add nsw i32 %call, %src_offset_x
  %sub = sub nsw i32 %add, 2
  %add4 = add nsw i32 %call1, %src_offset_y
  %sub5 = sub nsw i32 %add4, %radiusy
  %call6 = call i32 @_Z11_socl_mad24iii(i32 %sub5, i32 %src_step_in_pixel, i32 %sub)
  br label %for.cond

for.cond:                                         ; preds = %for.body, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc, %for.body ]
  %cmp = icmp slt i32 %i.0, 2
  br i1 %cmp, label %for.body, label %for.cond31

for.body:                                         ; preds = %for.cond
  %mul = mul nsw i32 %i.0, 16
  %add7 = add nsw i32 %sub, %mul
  %cmp8 = icmp slt i32 %add7, 0
  %cond = select i1 %cmp8, i32 0, i32 %add7
  %mul11 = mul nsw i32 %i.0, 16
  %add12 = add nsw i32 %sub, %mul11
  %cmp13 = icmp sge i32 %add12, %src_whole_cols
  %sub15 = sub nsw i32 %src_whole_cols, 1
  %cond18 = select i1 %cmp13, i32 %sub15, i32 %cond
  %cmp19 = icmp slt i32 %sub5, 0
  %.sub5 = select i1 %cmp19, i32 0, i32 %sub5
  %cmp24 = icmp sge i32 %sub5, %src_whole_rows
  %sub26 = sub nsw i32 %src_whole_rows, 1
  %cond29 = select i1 %cmp24, i32 %sub26, i32 %.sub5
  %call30 = call i32 @_Z11_socl_mad24iii(i32 %cond29, i32 %src_step_in_pixel, i32 %cond18)
  %arrayidx = getelementptr inbounds [2 x i32]* %index, i32 0, i32 %i.0
  store i32 %call30, i32* %arrayidx, align 4
  %inc = add nsw i32 %i.0, 1
  br label %for.cond

for.cond31:                                       ; preds = %for.cond, %for.body33
  %i.1 = phi i32 [ %inc38, %for.body33 ], [ 0, %for.cond ]
  %cmp32 = icmp slt i32 %i.1, 2
  br i1 %cmp32, label %for.body33, label %for.cond40

for.body33:                                       ; preds = %for.cond31
  %arrayidx34 = getelementptr inbounds [2 x i32]* %index, i32 0, i32 %i.1
  %0 = load i32* %arrayidx34, align 4
  %arrayidx35 = getelementptr inbounds <4 x i8>* %src, i32 %0
  %1 = load <4 x i8>* %arrayidx35, align 4
  %arrayidx36 = getelementptr inbounds [2 x <4 x i8>]* %temp, i32 0, i32 %i.1
  store <4 x i8> %1, <4 x i8>* %arrayidx36, align 4
  %inc38 = add nsw i32 %i.1, 1
  br label %for.cond31

for.cond40:                                       ; preds = %for.cond31, %for.body42
  %i.2 = phi i32 [ %inc49, %for.body42 ], [ 0, %for.cond31 ]
  %cmp41 = icmp slt i32 %i.2, 2
  br i1 %cmp41, label %for.body42, label %for.end50

for.body42:                                       ; preds = %for.cond40
  %arrayidx43 = getelementptr inbounds [2 x <4 x i8>]* %temp, i32 0, i32 %i.2
  %2 = load <4 x i8>* %arrayidx43, align 4
  %mul44 = mul nsw i32 %i.2, 16
  %add45 = add nsw i32 %call2, %mul44
  %arrayidx46 = getelementptr inbounds [16 x [33 x <4 x i8>]]* @row_filter_C4_D0.LDS_DAT, i32 0, i32 %call3
  %arrayidx47 = getelementptr inbounds [33 x <4 x i8>]* %arrayidx46, i32 0, i32 %add45
  store <4 x i8> %2, <4 x i8>* %arrayidx47, align 4
  %inc49 = add nsw i32 %i.2, 1
  br label %for.cond40

for.end50:                                        ; preds = %for.cond40
  call void @barrier(i32 1)
  %add51 = add nsw i32 %call2, 2
  %arrayidx52 = getelementptr inbounds [16 x [33 x <4 x i8>]]* @row_filter_C4_D0.LDS_DAT, i32 0, i32 %call3
  %arrayidx53 = getelementptr inbounds [33 x <4 x i8>]* %arrayidx52, i32 0, i32 %add51
  %3 = load <4 x i8>* %arrayidx53, align 4
  store <4 x i8> %3, <4 x i8>* %coerce, align 4
  %4 = bitcast <4 x i8>* %coerce to i32*
  %5 = load i32* %4, align 1
  %call54 = call <4 x float> @_Z20_socl_convert_float4Dv4_h(i32 %5)
  %arrayidx55 = getelementptr inbounds float* %mat_kernel, i32 2
  %6 = load float* %arrayidx55, align 4
  %splat.splatinsert = insertelement <4 x float> undef, float %6, i32 0
  %splat.splat = shufflevector <4 x float> %splat.splatinsert, <4 x float> undef, <4 x i32> zeroinitializer
  %mul56 = fmul <4 x float> %call54, %splat.splat
  br label %for.cond57

for.cond57:                                       ; preds = %for.body59, %for.end50
  %i.3 = phi i32 [ 1, %for.end50 ], [ %inc88, %for.body59 ]
  %sum.0 = phi <4 x float> [ %mul56, %for.end50 ], [ %add86, %for.body59 ]
  %cmp58 = icmp sle i32 %i.3, 2
  br i1 %cmp58, label %for.body59, label %for.end89

for.body59:                                       ; preds = %for.cond57
  %add60 = add nsw i32 %call2, 2
  %sub61 = sub nsw i32 %add60, %i.3
  %arrayidx62 = getelementptr inbounds [16 x [33 x <4 x i8>]]* @row_filter_C4_D0.LDS_DAT, i32 0, i32 %call3
  %arrayidx63 = getelementptr inbounds [33 x <4 x i8>]* %arrayidx62, i32 0, i32 %sub61
  %7 = load <4 x i8>* %arrayidx63, align 4
  %arrayidx64 = getelementptr inbounds [2 x <4 x i8>]* %temp, i32 0, i32 0
  store <4 x i8> %7, <4 x i8>* %arrayidx64, align 4
  %add65 = add nsw i32 %call2, 2
  %add66 = add nsw i32 %add65, %i.3
  %arrayidx67 = getelementptr inbounds [16 x [33 x <4 x i8>]]* @row_filter_C4_D0.LDS_DAT, i32 0, i32 %call3
  %arrayidx68 = getelementptr inbounds [33 x <4 x i8>]* %arrayidx67, i32 0, i32 %add66
  %8 = load <4 x i8>* %arrayidx68, align 4
  %arrayidx69 = getelementptr inbounds [2 x <4 x i8>]* %temp, i32 0, i32 1
  store <4 x i8> %8, <4 x i8>* %arrayidx69, align 4
  %arrayidx70 = getelementptr inbounds [2 x <4 x i8>]* %temp, i32 0, i32 0
  %9 = load <4 x i8>* %arrayidx70, align 4
  store <4 x i8> %9, <4 x i8>* %coerce71, align 4
  %10 = bitcast <4 x i8>* %coerce71 to i32*
  %11 = load i32* %10, align 1
  %call72 = call <4 x float> @_Z20_socl_convert_float4Dv4_h(i32 %11)
  %sub73 = sub nsw i32 2, %i.3
  %arrayidx74 = getelementptr inbounds float* %mat_kernel, i32 %sub73
  %12 = load float* %arrayidx74, align 4
  %splat.splatinsert75 = insertelement <4 x float> undef, float %12, i32 0
  %splat.splat76 = shufflevector <4 x float> %splat.splatinsert75, <4 x float> undef, <4 x i32> zeroinitializer
  %arrayidx78 = getelementptr inbounds [2 x <4 x i8>]* %temp, i32 0, i32 1
  %13 = load <4 x i8>* %arrayidx78, align 4
  store <4 x i8> %13, <4 x i8>* %coerce79, align 4
  %14 = bitcast <4 x i8>* %coerce79 to i32*
  %15 = load i32* %14, align 1
  %call80 = call <4 x float> @_Z20_socl_convert_float4Dv4_h(i32 %15)
  %add81 = add nsw i32 2, %i.3
  %arrayidx82 = getelementptr inbounds float* %mat_kernel, i32 %add81
  %16 = load float* %arrayidx82, align 4
  %splat.splatinsert83 = insertelement <4 x float> undef, float %16, i32 0
  %splat.splat84 = shufflevector <4 x float> %splat.splatinsert83, <4 x float> undef, <4 x i32> zeroinitializer
  %mul85 = fmul <4 x float> %call80, %splat.splat84
  %17 = call <4 x float> @llvm.fmuladd.v4f32(<4 x float> %call72, <4 x float> %splat.splat76, <4 x float> %mul85)
  %add86 = fadd <4 x float> %sum.0, %17
  %inc88 = add nsw i32 %i.3, 1
  br label %for.cond57

for.end89:                                        ; preds = %for.cond57
  %cmp90 = icmp slt i32 %call, %dst_cols
  %conv = zext i1 %cmp90 to i32
  %cmp91 = icmp slt i32 %call1, %dst_rows
  %conv92 = zext i1 %cmp91 to i32
  %and = and i32 %conv, %conv92
  %tobool = icmp ne i32 %and, 0
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %for.end89
  %call93 = call i32 @_Z11_socl_mad24iii(i32 %call1, i32 %dst_step_in_pixel, i32 %call)
  %arrayidx94 = getelementptr inbounds <4 x float>* %dst, i32 %call93
  store <4 x float> %sum.0, <4 x float>* %arrayidx94, align 16
  br label %if.end

if.end:                                           ; preds = %if.then, %for.end89
  ret void
}

; Function Attrs: nounwind
define void @row_filter_C1_D5(float* noalias %src, float* %dst, i32 %dst_cols, i32 %dst_rows, i32 %src_whole_cols, i32 %src_whole_rows, i32 %src_step_in_pixel, i32 %src_offset_x, i32 %src_offset_y, i32 %dst_step_in_pixel, i32 %radiusy, float* %mat_kernel) #0 {
entry:
  %temp = alloca [2 x float], align 4
  %index = alloca [2 x i32], align 4
  %call = call i32 @get_global_id(i32 0)
  %call1 = call i32 @get_global_id(i32 1)
  %call2 = call i32 @get_local_id(i32 0)
  %call3 = call i32 @get_local_id(i32 1)
  %add = add nsw i32 %call, %src_offset_x
  %sub = sub nsw i32 %add, 2
  %add4 = add nsw i32 %call1, %src_offset_y
  %sub5 = sub nsw i32 %add4, %radiusy
  %call6 = call i32 @_Z11_socl_mad24iii(i32 %sub5, i32 %src_step_in_pixel, i32 %sub)
  br label %for.cond

for.cond:                                         ; preds = %for.body, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc, %for.body ]
  %cmp = icmp slt i32 %i.0, 2
  br i1 %cmp, label %for.body, label %for.cond31

for.body:                                         ; preds = %for.cond
  %mul = mul nsw i32 %i.0, 16
  %add7 = add nsw i32 %sub, %mul
  %cmp8 = icmp slt i32 %add7, 0
  %cond = select i1 %cmp8, i32 0, i32 %add7
  %mul11 = mul nsw i32 %i.0, 16
  %add12 = add nsw i32 %sub, %mul11
  %cmp13 = icmp sge i32 %add12, %src_whole_cols
  %sub15 = sub nsw i32 %src_whole_cols, 1
  %cond18 = select i1 %cmp13, i32 %sub15, i32 %cond
  %cmp19 = icmp slt i32 %sub5, 0
  %.sub5 = select i1 %cmp19, i32 0, i32 %sub5
  %cmp24 = icmp sge i32 %sub5, %src_whole_rows
  %sub26 = sub nsw i32 %src_whole_rows, 1
  %cond29 = select i1 %cmp24, i32 %sub26, i32 %.sub5
  %call30 = call i32 @_Z11_socl_mad24iii(i32 %cond29, i32 %src_step_in_pixel, i32 %cond18)
  %arrayidx = getelementptr inbounds [2 x i32]* %index, i32 0, i32 %i.0
  store i32 %call30, i32* %arrayidx, align 4
  %inc = add nsw i32 %i.0, 1
  br label %for.cond

for.cond31:                                       ; preds = %for.cond, %for.body33
  %i.1 = phi i32 [ %inc38, %for.body33 ], [ 0, %for.cond ]
  %cmp32 = icmp slt i32 %i.1, 2
  br i1 %cmp32, label %for.body33, label %for.cond40

for.body33:                                       ; preds = %for.cond31
  %arrayidx34 = getelementptr inbounds [2 x i32]* %index, i32 0, i32 %i.1
  %0 = load i32* %arrayidx34, align 4
  %arrayidx35 = getelementptr inbounds float* %src, i32 %0
  %1 = load float* %arrayidx35, align 4
  %arrayidx36 = getelementptr inbounds [2 x float]* %temp, i32 0, i32 %i.1
  store float %1, float* %arrayidx36, align 4
  %inc38 = add nsw i32 %i.1, 1
  br label %for.cond31

for.cond40:                                       ; preds = %for.cond31, %for.body42
  %i.2 = phi i32 [ %inc49, %for.body42 ], [ 0, %for.cond31 ]
  %cmp41 = icmp slt i32 %i.2, 2
  br i1 %cmp41, label %for.body42, label %for.end50

for.body42:                                       ; preds = %for.cond40
  %arrayidx43 = getelementptr inbounds [2 x float]* %temp, i32 0, i32 %i.2
  %2 = load float* %arrayidx43, align 4
  %mul44 = mul nsw i32 %i.2, 16
  %add45 = add nsw i32 %call2, %mul44
  %arrayidx46 = getelementptr inbounds [16 x [33 x float]]* @row_filter_C1_D5.LDS_DAT, i32 0, i32 %call3
  %arrayidx47 = getelementptr inbounds [33 x float]* %arrayidx46, i32 0, i32 %add45
  store float %2, float* %arrayidx47, align 4
  %inc49 = add nsw i32 %i.2, 1
  br label %for.cond40

for.end50:                                        ; preds = %for.cond40
  call void @barrier(i32 1)
  %add51 = add nsw i32 %call2, 2
  %arrayidx52 = getelementptr inbounds [16 x [33 x float]]* @row_filter_C1_D5.LDS_DAT, i32 0, i32 %call3
  %arrayidx53 = getelementptr inbounds [33 x float]* %arrayidx52, i32 0, i32 %add51
  %3 = load float* %arrayidx53, align 4
  %arrayidx54 = getelementptr inbounds float* %mat_kernel, i32 2
  %4 = load float* %arrayidx54, align 4
  %mul55 = fmul float %3, %4
  br label %for.cond56

for.cond56:                                       ; preds = %for.body58, %for.end50
  %i.3 = phi i32 [ 1, %for.end50 ], [ %inc79, %for.body58 ]
  %sum.0 = phi float [ %mul55, %for.end50 ], [ %add77, %for.body58 ]
  %cmp57 = icmp sle i32 %i.3, 2
  br i1 %cmp57, label %for.body58, label %for.end80

for.body58:                                       ; preds = %for.cond56
  %add59 = add nsw i32 %call2, 2
  %sub60 = sub nsw i32 %add59, %i.3
  %arrayidx61 = getelementptr inbounds [16 x [33 x float]]* @row_filter_C1_D5.LDS_DAT, i32 0, i32 %call3
  %arrayidx62 = getelementptr inbounds [33 x float]* %arrayidx61, i32 0, i32 %sub60
  %5 = load float* %arrayidx62, align 4
  %arrayidx63 = getelementptr inbounds [2 x float]* %temp, i32 0, i32 0
  store float %5, float* %arrayidx63, align 4
  %add64 = add nsw i32 %call2, 2
  %add65 = add nsw i32 %add64, %i.3
  %arrayidx66 = getelementptr inbounds [16 x [33 x float]]* @row_filter_C1_D5.LDS_DAT, i32 0, i32 %call3
  %arrayidx67 = getelementptr inbounds [33 x float]* %arrayidx66, i32 0, i32 %add65
  %6 = load float* %arrayidx67, align 4
  %arrayidx68 = getelementptr inbounds [2 x float]* %temp, i32 0, i32 1
  store float %6, float* %arrayidx68, align 4
  %arrayidx69 = getelementptr inbounds [2 x float]* %temp, i32 0, i32 0
  %7 = load float* %arrayidx69, align 4
  %sub70 = sub nsw i32 2, %i.3
  %arrayidx71 = getelementptr inbounds float* %mat_kernel, i32 %sub70
  %8 = load float* %arrayidx71, align 4
  %arrayidx73 = getelementptr inbounds [2 x float]* %temp, i32 0, i32 1
  %9 = load float* %arrayidx73, align 4
  %add74 = add nsw i32 2, %i.3
  %arrayidx75 = getelementptr inbounds float* %mat_kernel, i32 %add74
  %10 = load float* %arrayidx75, align 4
  %mul76 = fmul float %9, %10
  %11 = call float @llvm.fmuladd.f32(float %7, float %8, float %mul76)
  %add77 = fadd float %sum.0, %11
  %inc79 = add nsw i32 %i.3, 1
  br label %for.cond56

for.end80:                                        ; preds = %for.cond56
  %cmp81 = icmp slt i32 %call, %dst_cols
  %conv = zext i1 %cmp81 to i32
  %cmp82 = icmp slt i32 %call1, %dst_rows
  %conv83 = zext i1 %cmp82 to i32
  %and = and i32 %conv, %conv83
  %tobool = icmp ne i32 %and, 0
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %for.end80
  %call84 = call i32 @_Z11_socl_mad24iii(i32 %call1, i32 %dst_step_in_pixel, i32 %call)
  %arrayidx85 = getelementptr inbounds float* %dst, i32 %call84
  store float %sum.0, float* %arrayidx85, align 4
  br label %if.end

if.end:                                           ; preds = %if.then, %for.end80
  ret void
}

; Function Attrs: nounwind readnone
declare float @llvm.fmuladd.f32(float, float, float) #2

; Function Attrs: nounwind
define void @row_filter_C4_D5(<4 x float>* noalias %src, <4 x float>* %dst, i32 %dst_cols, i32 %dst_rows, i32 %src_whole_cols, i32 %src_whole_rows, i32 %src_step_in_pixel, i32 %src_offset_x, i32 %src_offset_y, i32 %dst_step_in_pixel, i32 %radiusy, float* %mat_kernel) #0 {
entry:
  %temp = alloca [2 x <4 x float>], align 16
  %index = alloca [2 x i32], align 4
  %call = call i32 @get_global_id(i32 0)
  %call1 = call i32 @get_global_id(i32 1)
  %call2 = call i32 @get_local_id(i32 0)
  %call3 = call i32 @get_local_id(i32 1)
  %add = add nsw i32 %call, %src_offset_x
  %sub = sub nsw i32 %add, 2
  %add4 = add nsw i32 %call1, %src_offset_y
  %sub5 = sub nsw i32 %add4, %radiusy
  %call6 = call i32 @_Z11_socl_mad24iii(i32 %sub5, i32 %src_step_in_pixel, i32 %sub)
  br label %for.cond

for.cond:                                         ; preds = %for.body, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc, %for.body ]
  %cmp = icmp slt i32 %i.0, 2
  br i1 %cmp, label %for.body, label %for.cond31

for.body:                                         ; preds = %for.cond
  %mul = mul nsw i32 %i.0, 16
  %add7 = add nsw i32 %sub, %mul
  %cmp8 = icmp slt i32 %add7, 0
  %cond = select i1 %cmp8, i32 0, i32 %add7
  %mul11 = mul nsw i32 %i.0, 16
  %add12 = add nsw i32 %sub, %mul11
  %cmp13 = icmp sge i32 %add12, %src_whole_cols
  %sub15 = sub nsw i32 %src_whole_cols, 1
  %cond18 = select i1 %cmp13, i32 %sub15, i32 %cond
  %cmp19 = icmp slt i32 %sub5, 0
  %.sub5 = select i1 %cmp19, i32 0, i32 %sub5
  %cmp24 = icmp sge i32 %sub5, %src_whole_rows
  %sub26 = sub nsw i32 %src_whole_rows, 1
  %cond29 = select i1 %cmp24, i32 %sub26, i32 %.sub5
  %call30 = call i32 @_Z11_socl_mad24iii(i32 %cond29, i32 %src_step_in_pixel, i32 %cond18)
  %arrayidx = getelementptr inbounds [2 x i32]* %index, i32 0, i32 %i.0
  store i32 %call30, i32* %arrayidx, align 4
  %inc = add nsw i32 %i.0, 1
  br label %for.cond

for.cond31:                                       ; preds = %for.cond, %for.body33
  %i.1 = phi i32 [ %inc38, %for.body33 ], [ 0, %for.cond ]
  %cmp32 = icmp slt i32 %i.1, 2
  br i1 %cmp32, label %for.body33, label %for.cond40

for.body33:                                       ; preds = %for.cond31
  %arrayidx34 = getelementptr inbounds [2 x i32]* %index, i32 0, i32 %i.1
  %0 = load i32* %arrayidx34, align 4
  %arrayidx35 = getelementptr inbounds <4 x float>* %src, i32 %0
  %1 = load <4 x float>* %arrayidx35, align 16
  %arrayidx36 = getelementptr inbounds [2 x <4 x float>]* %temp, i32 0, i32 %i.1
  store <4 x float> %1, <4 x float>* %arrayidx36, align 16
  %inc38 = add nsw i32 %i.1, 1
  br label %for.cond31

for.cond40:                                       ; preds = %for.cond31, %for.body42
  %i.2 = phi i32 [ %inc49, %for.body42 ], [ 0, %for.cond31 ]
  %cmp41 = icmp slt i32 %i.2, 2
  br i1 %cmp41, label %for.body42, label %for.end50

for.body42:                                       ; preds = %for.cond40
  %arrayidx43 = getelementptr inbounds [2 x <4 x float>]* %temp, i32 0, i32 %i.2
  %2 = load <4 x float>* %arrayidx43, align 16
  %mul44 = mul nsw i32 %i.2, 16
  %add45 = add nsw i32 %call2, %mul44
  %arrayidx46 = getelementptr inbounds [16 x [33 x <4 x float>]]* @row_filter_C4_D5.LDS_DAT, i32 0, i32 %call3
  %arrayidx47 = getelementptr inbounds [33 x <4 x float>]* %arrayidx46, i32 0, i32 %add45
  store <4 x float> %2, <4 x float>* %arrayidx47, align 16
  %inc49 = add nsw i32 %i.2, 1
  br label %for.cond40

for.end50:                                        ; preds = %for.cond40
  call void @barrier(i32 1)
  %add51 = add nsw i32 %call2, 2
  %arrayidx52 = getelementptr inbounds [16 x [33 x <4 x float>]]* @row_filter_C4_D5.LDS_DAT, i32 0, i32 %call3
  %arrayidx53 = getelementptr inbounds [33 x <4 x float>]* %arrayidx52, i32 0, i32 %add51
  %3 = load <4 x float>* %arrayidx53, align 16
  %arrayidx54 = getelementptr inbounds float* %mat_kernel, i32 2
  %4 = load float* %arrayidx54, align 4
  %splat.splatinsert = insertelement <4 x float> undef, float %4, i32 0
  %splat.splat = shufflevector <4 x float> %splat.splatinsert, <4 x float> undef, <4 x i32> zeroinitializer
  %mul55 = fmul <4 x float> %3, %splat.splat
  br label %for.cond56

for.cond56:                                       ; preds = %for.body58, %for.end50
  %i.3 = phi i32 [ 1, %for.end50 ], [ %inc83, %for.body58 ]
  %sum.0 = phi <4 x float> [ %mul55, %for.end50 ], [ %add81, %for.body58 ]
  %cmp57 = icmp sle i32 %i.3, 2
  br i1 %cmp57, label %for.body58, label %for.end84

for.body58:                                       ; preds = %for.cond56
  %add59 = add nsw i32 %call2, 2
  %sub60 = sub nsw i32 %add59, %i.3
  %arrayidx61 = getelementptr inbounds [16 x [33 x <4 x float>]]* @row_filter_C4_D5.LDS_DAT, i32 0, i32 %call3
  %arrayidx62 = getelementptr inbounds [33 x <4 x float>]* %arrayidx61, i32 0, i32 %sub60
  %5 = load <4 x float>* %arrayidx62, align 16
  %arrayidx63 = getelementptr inbounds [2 x <4 x float>]* %temp, i32 0, i32 0
  store <4 x float> %5, <4 x float>* %arrayidx63, align 16
  %add64 = add nsw i32 %call2, 2
  %add65 = add nsw i32 %add64, %i.3
  %arrayidx66 = getelementptr inbounds [16 x [33 x <4 x float>]]* @row_filter_C4_D5.LDS_DAT, i32 0, i32 %call3
  %arrayidx67 = getelementptr inbounds [33 x <4 x float>]* %arrayidx66, i32 0, i32 %add65
  %6 = load <4 x float>* %arrayidx67, align 16
  %arrayidx68 = getelementptr inbounds [2 x <4 x float>]* %temp, i32 0, i32 1
  store <4 x float> %6, <4 x float>* %arrayidx68, align 16
  %arrayidx69 = getelementptr inbounds [2 x <4 x float>]* %temp, i32 0, i32 0
  %7 = load <4 x float>* %arrayidx69, align 16
  %sub70 = sub nsw i32 2, %i.3
  %arrayidx71 = getelementptr inbounds float* %mat_kernel, i32 %sub70
  %8 = load float* %arrayidx71, align 4
  %splat.splatinsert72 = insertelement <4 x float> undef, float %8, i32 0
  %splat.splat73 = shufflevector <4 x float> %splat.splatinsert72, <4 x float> undef, <4 x i32> zeroinitializer
  %arrayidx75 = getelementptr inbounds [2 x <4 x float>]* %temp, i32 0, i32 1
  %9 = load <4 x float>* %arrayidx75, align 16
  %add76 = add nsw i32 2, %i.3
  %arrayidx77 = getelementptr inbounds float* %mat_kernel, i32 %add76
  %10 = load float* %arrayidx77, align 4
  %splat.splatinsert78 = insertelement <4 x float> undef, float %10, i32 0
  %splat.splat79 = shufflevector <4 x float> %splat.splatinsert78, <4 x float> undef, <4 x i32> zeroinitializer
  %mul80 = fmul <4 x float> %9, %splat.splat79
  %11 = call <4 x float> @llvm.fmuladd.v4f32(<4 x float> %7, <4 x float> %splat.splat73, <4 x float> %mul80)
  %add81 = fadd <4 x float> %sum.0, %11
  %inc83 = add nsw i32 %i.3, 1
  br label %for.cond56

for.end84:                                        ; preds = %for.cond56
  %cmp85 = icmp slt i32 %call, %dst_cols
  %conv = zext i1 %cmp85 to i32
  %cmp86 = icmp slt i32 %call1, %dst_rows
  %conv87 = zext i1 %cmp86 to i32
  %and = and i32 %conv, %conv87
  %tobool = icmp ne i32 %and, 0
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %for.end84
  %call88 = call i32 @_Z11_socl_mad24iii(i32 %call1, i32 %dst_step_in_pixel, i32 %call)
  %arrayidx89 = getelementptr inbounds <4 x float>* %dst, i32 %call88
  store <4 x float> %sum.0, <4 x float>* %arrayidx89, align 16
  br label %if.end

if.end:                                           ; preds = %if.then, %for.end84
  ret void
}

attributes #0 = { nounwind "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-frame-pointer-elim-non-leaf"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-frame-pointer-elim-non-leaf"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind readnone }

!opencl.kernels = !{!0, !7, !9, !11}

!0 = metadata !{void (i8*, float*, i32, i32, i32, i32, i32, i32, i32, i32, i32, float*)* @row_filter_C1_D0, metadata !1, metadata !2, metadata !3, metadata !4, metadata !5, metadata !6}
!1 = metadata !{metadata !"kernel_arg_addr_space", i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0}
!2 = metadata !{metadata !"kernel_arg_access_qual", metadata !"none", metadata !"none", metadata !"none", metadata !"none", metadata !"none", metadata !"none", metadata !"none", metadata !"none", metadata !"none", metadata !"none", metadata !"none", metadata !"none"}
!3 = metadata !{metadata !"kernel_arg_type", metadata !"uchar*", metadata !"float*", metadata !"int", metadata !"int", metadata !"int", metadata !"int", metadata !"int", metadata !"int", metadata !"int", metadata !"int", metadata !"int", metadata !"float*"}
!4 = metadata !{metadata !"kernel_arg_type_qual", metadata !"restrict const", metadata !"", metadata !"const", metadata !"const", metadata !"const", metadata !"const", metadata !"const", metadata !"const", metadata !"const", metadata !"const", metadata !"const", metadata !"const"}
!5 = metadata !{metadata !"kernel_arg_name", metadata !"src", metadata !"dst", metadata !"dst_cols", metadata !"dst_rows", metadata !"src_whole_cols", metadata !"src_whole_rows", metadata !"src_step_in_pixel", metadata !"src_offset_x", metadata !"src_offset_y", metadata !"dst_step_in_pixel", metadata !"radiusy", metadata !"mat_kernel"}
!6 = metadata !{metadata !"reqd_work_group_size", i32 16, i32 16, i32 1}
!7 = metadata !{void (<4 x i8>*, <4 x float>*, i32, i32, i32, i32, i32, i32, i32, i32, i32, float*)* @row_filter_C4_D0, metadata !1, metadata !2, metadata !8, metadata !4, metadata !5, metadata !6}
!8 = metadata !{metadata !"kernel_arg_type", metadata !"uchar4*", metadata !"float4*", metadata !"int", metadata !"int", metadata !"int", metadata !"int", metadata !"int", metadata !"int", metadata !"int", metadata !"int", metadata !"int", metadata !"float*"}
!9 = metadata !{void (float*, float*, i32, i32, i32, i32, i32, i32, i32, i32, i32, float*)* @row_filter_C1_D5, metadata !1, metadata !2, metadata !10, metadata !4, metadata !5, metadata !6}
!10 = metadata !{metadata !"kernel_arg_type", metadata !"float*", metadata !"float*", metadata !"int", metadata !"int", metadata !"int", metadata !"int", metadata !"int", metadata !"int", metadata !"int", metadata !"int", metadata !"int", metadata !"float*"}
!11 = metadata !{void (<4 x float>*, <4 x float>*, i32, i32, i32, i32, i32, i32, i32, i32, i32, float*)* @row_filter_C4_D5, metadata !1, metadata !2, metadata !12, metadata !4, metadata !5, metadata !6}
!12 = metadata !{metadata !"kernel_arg_type", metadata !"float4*", metadata !"float4*", metadata !"int", metadata !"int", metadata !"int", metadata !"int", metadata !"int", metadata !"int", metadata !"int", metadata !"int", metadata !"int", metadata !"float*"}
