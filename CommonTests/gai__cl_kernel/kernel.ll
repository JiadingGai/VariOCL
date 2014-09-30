; ModuleID = '/home/jiading/Desktop/projects/socl-llvm/src/CommonTests/opencvall/ffa27da68a0e5268ecfac19328606c06.cl'
target datalayout = "e-p:32:32:32-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:64:128-a0:0:64-n32-S64"
target triple = "armv7--linux-androideabi"

@row_filter_C1_D0.LDS_DAT = internal global [16 x [33 x <4 x i8>]] zeroinitializer, align 4
@row_filter_C4_D0.LDS_DAT = internal global [16 x [33 x <4 x i8>]] zeroinitializer, align 4
@row_filter_C1_D5.LDS_DAT = internal global [16 x [33 x float]] zeroinitializer, align 4
@row_filter_C4_D5.LDS_DAT = internal global [16 x [33 x <4 x float>]] zeroinitializer, align 16

; Function Attrs: nounwind
define void @row_filter_C1_D0(i8* noalias %src, float* %dst, i32 %dst_cols, i32 %dst_rows, i32 %src_whole_cols, i32 %src_whole_rows, i32 %src_step_in_pixel, i32 %src_offset_x, i32 %src_offset_y, i32 %dst_step_in_pixel, i32 %radiusy, float* %mat_kernel) #0 {
entry:
  %src.addr = alloca i8*, align 4
  %dst.addr = alloca float*, align 4
  %dst_cols.addr = alloca i32, align 4
  %dst_rows.addr = alloca i32, align 4
  %src_whole_cols.addr = alloca i32, align 4
  %src_whole_rows.addr = alloca i32, align 4
  %src_step_in_pixel.addr = alloca i32, align 4
  %src_offset_x.addr = alloca i32, align 4
  %src_offset_y.addr = alloca i32, align 4
  %dst_step_in_pixel.addr = alloca i32, align 4
  %radiusy.addr = alloca i32, align 4
  %mat_kernel.addr = alloca float*, align 4
  %x = alloca i32, align 4
  %y = alloca i32, align 4
  %l_x = alloca i32, align 4
  %l_y = alloca i32, align 4
  %start_x = alloca i32, align 4
  %offset = alloca i32, align 4
  %start_y = alloca i32, align 4
  %start_addr = alloca i32, align 4
  %i = alloca i32, align 4
  %sum = alloca <4 x float>, align 16
  %temp = alloca [2 x <4 x i8>], align 4
  %not_all_in_range = alloca i32, align 4
  %index = alloca [2 x <4 x i32>], align 16
  %addr = alloca <4 x i32>, align 16
  %s_y = alloca i32, align 4
  %coerce = alloca <4 x i8>, align 4
  %coerce208 = alloca <4 x i8>, align 4
  %coerce216 = alloca <4 x i8>, align 4
  store i8* %src, i8** %src.addr, align 4
  store float* %dst, float** %dst.addr, align 4
  store i32 %dst_cols, i32* %dst_cols.addr, align 4
  store i32 %dst_rows, i32* %dst_rows.addr, align 4
  store i32 %src_whole_cols, i32* %src_whole_cols.addr, align 4
  store i32 %src_whole_rows, i32* %src_whole_rows.addr, align 4
  store i32 %src_step_in_pixel, i32* %src_step_in_pixel.addr, align 4
  store i32 %src_offset_x, i32* %src_offset_x.addr, align 4
  store i32 %src_offset_y, i32* %src_offset_y.addr, align 4
  store i32 %dst_step_in_pixel, i32* %dst_step_in_pixel.addr, align 4
  store i32 %radiusy, i32* %radiusy.addr, align 4
  store float* %mat_kernel, float** %mat_kernel.addr, align 4
  %call = call i32 @get_global_id(i32 0)
  %shl = shl i32 %call, 2
  store i32 %shl, i32* %x, align 4
  %call1 = call i32 @get_global_id(i32 1)
  store i32 %call1, i32* %y, align 4
  %call2 = call i32 @get_local_id(i32 0)
  store i32 %call2, i32* %l_x, align 4
  %call3 = call i32 @get_local_id(i32 1)
  store i32 %call3, i32* %l_y, align 4
  %0 = load i32* %x, align 4
  %1 = load i32* %src_offset_x.addr, align 4
  %add = add nsw i32 %0, %1
  %sub = sub nsw i32 %add, 2
  %and = and i32 %sub, -4
  store i32 %and, i32* %start_x, align 4
  %2 = load i32* %src_offset_x.addr, align 4
  %sub4 = sub nsw i32 %2, 2
  %and5 = and i32 %sub4, 3
  store i32 %and5, i32* %offset, align 4
  %3 = load i32* %y, align 4
  %4 = load i32* %src_offset_y.addr, align 4
  %add6 = add nsw i32 %3, %4
  %5 = load i32* %radiusy.addr, align 4
  %sub7 = sub nsw i32 %add6, %5
  store i32 %sub7, i32* %start_y, align 4
  %6 = load i32* %start_y, align 4
  %7 = load i32* %src_step_in_pixel.addr, align 4
  %8 = load i32* %start_x, align 4
  %call8 = call i32 @_Z11_socl_mad24iii(i32 %6, i32 %7, i32 %8)
  store i32 %call8, i32* %start_addr, align 4
  %9 = load i32* %start_x, align 4
  %cmp = icmp slt i32 %9, 0
  %conv = zext i1 %cmp to i32
  %10 = load i32* %start_x, align 4
  %add9 = add nsw i32 %10, 128
  %add10 = add nsw i32 %add9, 4
  %11 = load i32* %src_whole_cols.addr, align 4
  %cmp11 = icmp sgt i32 %add10, %11
  %conv12 = zext i1 %cmp11 to i32
  %or = or i32 %conv, %conv12
  %12 = load i32* %start_y, align 4
  %cmp13 = icmp slt i32 %12, 0
  %conv14 = zext i1 %cmp13 to i32
  %or15 = or i32 %or, %conv14
  %13 = load i32* %start_y, align 4
  %14 = load i32* %src_whole_rows.addr, align 4
  %cmp16 = icmp sge i32 %13, %14
  %conv17 = zext i1 %cmp16 to i32
  %or18 = or i32 %or15, %conv17
  store i32 %or18, i32* %not_all_in_range, align 4
  %15 = load i32* %not_all_in_range, align 4
  %tobool = icmp ne i32 %15, 0
  br i1 %tobool, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %if.then
  %16 = load i32* %i, align 4
  %cmp19 = icmp slt i32 %16, 2
  br i1 %cmp19, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %17 = load i32* %start_x, align 4
  %18 = load i32* %i, align 4
  %mul = mul nsw i32 %18, 16
  %mul21 = mul nsw i32 %mul, 4
  %add22 = add nsw i32 %17, %mul21
  %cmp23 = icmp slt i32 %add22, 0
  br i1 %cmp23, label %cond.true, label %cond.false

cond.true:                                        ; preds = %for.body
  br label %cond.end

cond.false:                                       ; preds = %for.body
  %19 = load i32* %start_x, align 4
  %20 = load i32* %i, align 4
  %mul25 = mul nsw i32 %20, 16
  %mul26 = mul nsw i32 %mul25, 4
  %add27 = add nsw i32 %19, %mul26
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i32 [ 0, %cond.true ], [ %add27, %cond.false ]
  %21 = load i32* %i, align 4
  %arrayidx = getelementptr inbounds [2 x <4 x i32>]* %index, i32 0, i32 %21
  %22 = load <4 x i32>* %arrayidx, align 16
  %23 = insertelement <4 x i32> %22, i32 %cond, i32 0
  store <4 x i32> %23, <4 x i32>* %arrayidx, align 16
  %24 = load i32* %start_x, align 4
  %25 = load i32* %i, align 4
  %mul28 = mul nsw i32 %25, 16
  %mul29 = mul nsw i32 %mul28, 4
  %add30 = add nsw i32 %24, %mul29
  %26 = load i32* %src_whole_cols.addr, align 4
  %cmp31 = icmp sge i32 %add30, %26
  br i1 %cmp31, label %cond.true33, label %cond.false35

cond.true33:                                      ; preds = %cond.end
  %27 = load i32* %src_whole_cols.addr, align 4
  %sub34 = sub nsw i32 %27, 1
  br label %cond.end37

cond.false35:                                     ; preds = %cond.end
  %28 = load i32* %i, align 4
  %arrayidx36 = getelementptr inbounds [2 x <4 x i32>]* %index, i32 0, i32 %28
  %29 = load <4 x i32>* %arrayidx36, align 16
  %30 = extractelement <4 x i32> %29, i32 0
  br label %cond.end37

cond.end37:                                       ; preds = %cond.false35, %cond.true33
  %cond38 = phi i32 [ %sub34, %cond.true33 ], [ %30, %cond.false35 ]
  %31 = load i32* %i, align 4
  %arrayidx39 = getelementptr inbounds [2 x <4 x i32>]* %index, i32 0, i32 %31
  %32 = load <4 x i32>* %arrayidx39, align 16
  %33 = insertelement <4 x i32> %32, i32 %cond38, i32 0
  store <4 x i32> %33, <4 x i32>* %arrayidx39, align 16
  %34 = load i32* %start_x, align 4
  %35 = load i32* %i, align 4
  %mul40 = mul nsw i32 %35, 16
  %mul41 = mul nsw i32 %mul40, 4
  %add42 = add nsw i32 %34, %mul41
  %add43 = add nsw i32 %add42, 1
  %cmp44 = icmp slt i32 %add43, 0
  br i1 %cmp44, label %cond.true46, label %cond.false47

cond.true46:                                      ; preds = %cond.end37
  br label %cond.end52

cond.false47:                                     ; preds = %cond.end37
  %36 = load i32* %start_x, align 4
  %37 = load i32* %i, align 4
  %mul48 = mul nsw i32 %37, 16
  %mul49 = mul nsw i32 %mul48, 4
  %add50 = add nsw i32 %36, %mul49
  %add51 = add nsw i32 %add50, 1
  br label %cond.end52

cond.end52:                                       ; preds = %cond.false47, %cond.true46
  %cond53 = phi i32 [ 0, %cond.true46 ], [ %add51, %cond.false47 ]
  %38 = load i32* %i, align 4
  %arrayidx54 = getelementptr inbounds [2 x <4 x i32>]* %index, i32 0, i32 %38
  %39 = load <4 x i32>* %arrayidx54, align 16
  %40 = insertelement <4 x i32> %39, i32 %cond53, i32 1
  store <4 x i32> %40, <4 x i32>* %arrayidx54, align 16
  %41 = load i32* %start_x, align 4
  %42 = load i32* %i, align 4
  %mul55 = mul nsw i32 %42, 16
  %mul56 = mul nsw i32 %mul55, 4
  %add57 = add nsw i32 %41, %mul56
  %add58 = add nsw i32 %add57, 1
  %43 = load i32* %src_whole_cols.addr, align 4
  %cmp59 = icmp sge i32 %add58, %43
  br i1 %cmp59, label %cond.true61, label %cond.false63

cond.true61:                                      ; preds = %cond.end52
  %44 = load i32* %src_whole_cols.addr, align 4
  %sub62 = sub nsw i32 %44, 1
  br label %cond.end65

cond.false63:                                     ; preds = %cond.end52
  %45 = load i32* %i, align 4
  %arrayidx64 = getelementptr inbounds [2 x <4 x i32>]* %index, i32 0, i32 %45
  %46 = load <4 x i32>* %arrayidx64, align 16
  %47 = extractelement <4 x i32> %46, i32 1
  br label %cond.end65

cond.end65:                                       ; preds = %cond.false63, %cond.true61
  %cond66 = phi i32 [ %sub62, %cond.true61 ], [ %47, %cond.false63 ]
  %48 = load i32* %i, align 4
  %arrayidx67 = getelementptr inbounds [2 x <4 x i32>]* %index, i32 0, i32 %48
  %49 = load <4 x i32>* %arrayidx67, align 16
  %50 = insertelement <4 x i32> %49, i32 %cond66, i32 1
  store <4 x i32> %50, <4 x i32>* %arrayidx67, align 16
  %51 = load i32* %start_x, align 4
  %52 = load i32* %i, align 4
  %mul68 = mul nsw i32 %52, 16
  %mul69 = mul nsw i32 %mul68, 4
  %add70 = add nsw i32 %51, %mul69
  %add71 = add nsw i32 %add70, 2
  %cmp72 = icmp slt i32 %add71, 0
  br i1 %cmp72, label %cond.true74, label %cond.false75

cond.true74:                                      ; preds = %cond.end65
  br label %cond.end80

cond.false75:                                     ; preds = %cond.end65
  %53 = load i32* %start_x, align 4
  %54 = load i32* %i, align 4
  %mul76 = mul nsw i32 %54, 16
  %mul77 = mul nsw i32 %mul76, 4
  %add78 = add nsw i32 %53, %mul77
  %add79 = add nsw i32 %add78, 2
  br label %cond.end80

cond.end80:                                       ; preds = %cond.false75, %cond.true74
  %cond81 = phi i32 [ 0, %cond.true74 ], [ %add79, %cond.false75 ]
  %55 = load i32* %i, align 4
  %arrayidx82 = getelementptr inbounds [2 x <4 x i32>]* %index, i32 0, i32 %55
  %56 = load <4 x i32>* %arrayidx82, align 16
  %57 = insertelement <4 x i32> %56, i32 %cond81, i32 2
  store <4 x i32> %57, <4 x i32>* %arrayidx82, align 16
  %58 = load i32* %start_x, align 4
  %59 = load i32* %i, align 4
  %mul83 = mul nsw i32 %59, 16
  %mul84 = mul nsw i32 %mul83, 4
  %add85 = add nsw i32 %58, %mul84
  %add86 = add nsw i32 %add85, 2
  %60 = load i32* %src_whole_cols.addr, align 4
  %cmp87 = icmp sge i32 %add86, %60
  br i1 %cmp87, label %cond.true89, label %cond.false91

cond.true89:                                      ; preds = %cond.end80
  %61 = load i32* %src_whole_cols.addr, align 4
  %sub90 = sub nsw i32 %61, 1
  br label %cond.end93

cond.false91:                                     ; preds = %cond.end80
  %62 = load i32* %i, align 4
  %arrayidx92 = getelementptr inbounds [2 x <4 x i32>]* %index, i32 0, i32 %62
  %63 = load <4 x i32>* %arrayidx92, align 16
  %64 = extractelement <4 x i32> %63, i32 2
  br label %cond.end93

cond.end93:                                       ; preds = %cond.false91, %cond.true89
  %cond94 = phi i32 [ %sub90, %cond.true89 ], [ %64, %cond.false91 ]
  %65 = load i32* %i, align 4
  %arrayidx95 = getelementptr inbounds [2 x <4 x i32>]* %index, i32 0, i32 %65
  %66 = load <4 x i32>* %arrayidx95, align 16
  %67 = insertelement <4 x i32> %66, i32 %cond94, i32 2
  store <4 x i32> %67, <4 x i32>* %arrayidx95, align 16
  %68 = load i32* %start_x, align 4
  %69 = load i32* %i, align 4
  %mul96 = mul nsw i32 %69, 16
  %mul97 = mul nsw i32 %mul96, 4
  %add98 = add nsw i32 %68, %mul97
  %add99 = add nsw i32 %add98, 3
  %cmp100 = icmp slt i32 %add99, 0
  br i1 %cmp100, label %cond.true102, label %cond.false103

cond.true102:                                     ; preds = %cond.end93
  br label %cond.end108

cond.false103:                                    ; preds = %cond.end93
  %70 = load i32* %start_x, align 4
  %71 = load i32* %i, align 4
  %mul104 = mul nsw i32 %71, 16
  %mul105 = mul nsw i32 %mul104, 4
  %add106 = add nsw i32 %70, %mul105
  %add107 = add nsw i32 %add106, 3
  br label %cond.end108

cond.end108:                                      ; preds = %cond.false103, %cond.true102
  %cond109 = phi i32 [ 0, %cond.true102 ], [ %add107, %cond.false103 ]
  %72 = load i32* %i, align 4
  %arrayidx110 = getelementptr inbounds [2 x <4 x i32>]* %index, i32 0, i32 %72
  %73 = load <4 x i32>* %arrayidx110, align 16
  %74 = insertelement <4 x i32> %73, i32 %cond109, i32 3
  store <4 x i32> %74, <4 x i32>* %arrayidx110, align 16
  %75 = load i32* %start_x, align 4
  %76 = load i32* %i, align 4
  %mul111 = mul nsw i32 %76, 16
  %mul112 = mul nsw i32 %mul111, 4
  %add113 = add nsw i32 %75, %mul112
  %add114 = add nsw i32 %add113, 3
  %77 = load i32* %src_whole_cols.addr, align 4
  %cmp115 = icmp sge i32 %add114, %77
  br i1 %cmp115, label %cond.true117, label %cond.false119

cond.true117:                                     ; preds = %cond.end108
  %78 = load i32* %src_whole_cols.addr, align 4
  %sub118 = sub nsw i32 %78, 1
  br label %cond.end121

cond.false119:                                    ; preds = %cond.end108
  %79 = load i32* %i, align 4
  %arrayidx120 = getelementptr inbounds [2 x <4 x i32>]* %index, i32 0, i32 %79
  %80 = load <4 x i32>* %arrayidx120, align 16
  %81 = extractelement <4 x i32> %80, i32 3
  br label %cond.end121

cond.end121:                                      ; preds = %cond.false119, %cond.true117
  %cond122 = phi i32 [ %sub118, %cond.true117 ], [ %81, %cond.false119 ]
  %82 = load i32* %i, align 4
  %arrayidx123 = getelementptr inbounds [2 x <4 x i32>]* %index, i32 0, i32 %82
  %83 = load <4 x i32>* %arrayidx123, align 16
  %84 = insertelement <4 x i32> %83, i32 %cond122, i32 3
  store <4 x i32> %84, <4 x i32>* %arrayidx123, align 16
  br label %for.inc

for.inc:                                          ; preds = %cond.end121
  %85 = load i32* %i, align 4
  %inc = add nsw i32 %85, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %86 = load i32* %start_y, align 4
  %cmp124 = icmp slt i32 %86, 0
  br i1 %cmp124, label %cond.true126, label %cond.false127

cond.true126:                                     ; preds = %for.end
  br label %cond.end128

cond.false127:                                    ; preds = %for.end
  %87 = load i32* %start_y, align 4
  br label %cond.end128

cond.end128:                                      ; preds = %cond.false127, %cond.true126
  %cond129 = phi i32 [ 0, %cond.true126 ], [ %87, %cond.false127 ]
  store i32 %cond129, i32* %s_y, align 4
  %88 = load i32* %start_y, align 4
  %89 = load i32* %src_whole_rows.addr, align 4
  %cmp130 = icmp sge i32 %88, %89
  br i1 %cmp130, label %cond.true132, label %cond.false134

cond.true132:                                     ; preds = %cond.end128
  %90 = load i32* %src_whole_rows.addr, align 4
  %sub133 = sub nsw i32 %90, 1
  br label %cond.end135

cond.false134:                                    ; preds = %cond.end128
  %91 = load i32* %s_y, align 4
  br label %cond.end135

cond.end135:                                      ; preds = %cond.false134, %cond.true132
  %cond136 = phi i32 [ %sub133, %cond.true132 ], [ %91, %cond.false134 ]
  store i32 %cond136, i32* %s_y, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond137

for.cond137:                                      ; preds = %for.inc153, %cond.end135
  %92 = load i32* %i, align 4
  %cmp138 = icmp slt i32 %92, 2
  br i1 %cmp138, label %for.body140, label %for.end155

for.body140:                                      ; preds = %for.cond137
  %93 = load i32* %s_y, align 4
  %splat.splatinsert = insertelement <4 x i32> undef, i32 %93, i32 0
  %splat.splat = shufflevector <4 x i32> %splat.splatinsert, <4 x i32> undef, <4 x i32> zeroinitializer
  %94 = load i32* %src_step_in_pixel.addr, align 4
  %splat.splatinsert141 = insertelement <4 x i32> undef, i32 %94, i32 0
  %splat.splat142 = shufflevector <4 x i32> %splat.splatinsert141, <4 x i32> undef, <4 x i32> zeroinitializer
  %95 = load i32* %i, align 4
  %arrayidx143 = getelementptr inbounds [2 x <4 x i32>]* %index, i32 0, i32 %95
  %96 = load <4 x i32>* %arrayidx143, align 16
  %call144 = call <4 x i32> @_Z11_socl_mad24Dv4_iS_S_(<4 x i32> %splat.splat, <4 x i32> %splat.splat142, <4 x i32> %96)
  store <4 x i32> %call144, <4 x i32>* %addr, align 16
  %97 = load <4 x i32>* %addr, align 16
  %98 = extractelement <4 x i32> %97, i32 0
  %99 = load i8** %src.addr, align 4
  %arrayidx145 = getelementptr inbounds i8* %99, i32 %98
  %100 = load i8* %arrayidx145, align 1
  %101 = load i32* %i, align 4
  %arrayidx146 = getelementptr inbounds [2 x <4 x i8>]* %temp, i32 0, i32 %101
  %102 = load <4 x i8>* %arrayidx146, align 4
  %103 = insertelement <4 x i8> %102, i8 %100, i32 0
  store <4 x i8> %103, <4 x i8>* %arrayidx146, align 4
  %104 = load <4 x i32>* %addr, align 16
  %105 = extractelement <4 x i32> %104, i32 1
  %106 = load i8** %src.addr, align 4
  %arrayidx147 = getelementptr inbounds i8* %106, i32 %105
  %107 = load i8* %arrayidx147, align 1
  %108 = load i32* %i, align 4
  %arrayidx148 = getelementptr inbounds [2 x <4 x i8>]* %temp, i32 0, i32 %108
  %109 = load <4 x i8>* %arrayidx148, align 4
  %110 = insertelement <4 x i8> %109, i8 %107, i32 1
  store <4 x i8> %110, <4 x i8>* %arrayidx148, align 4
  %111 = load <4 x i32>* %addr, align 16
  %112 = extractelement <4 x i32> %111, i32 2
  %113 = load i8** %src.addr, align 4
  %arrayidx149 = getelementptr inbounds i8* %113, i32 %112
  %114 = load i8* %arrayidx149, align 1
  %115 = load i32* %i, align 4
  %arrayidx150 = getelementptr inbounds [2 x <4 x i8>]* %temp, i32 0, i32 %115
  %116 = load <4 x i8>* %arrayidx150, align 4
  %117 = insertelement <4 x i8> %116, i8 %114, i32 2
  store <4 x i8> %117, <4 x i8>* %arrayidx150, align 4
  %118 = load <4 x i32>* %addr, align 16
  %119 = extractelement <4 x i32> %118, i32 3
  %120 = load i8** %src.addr, align 4
  %arrayidx151 = getelementptr inbounds i8* %120, i32 %119
  %121 = load i8* %arrayidx151, align 1
  %122 = load i32* %i, align 4
  %arrayidx152 = getelementptr inbounds [2 x <4 x i8>]* %temp, i32 0, i32 %122
  %123 = load <4 x i8>* %arrayidx152, align 4
  %124 = insertelement <4 x i8> %123, i8 %121, i32 3
  store <4 x i8> %124, <4 x i8>* %arrayidx152, align 4
  br label %for.inc153

for.inc153:                                       ; preds = %for.body140
  %125 = load i32* %i, align 4
  %inc154 = add nsw i32 %125, 1
  store i32 %inc154, i32* %i, align 4
  br label %for.cond137

for.end155:                                       ; preds = %for.cond137
  br label %if.end

if.else:                                          ; preds = %entry
  store i32 0, i32* %i, align 4
  br label %for.cond156

for.cond156:                                      ; preds = %for.inc165, %if.else
  %126 = load i32* %i, align 4
  %cmp157 = icmp slt i32 %126, 2
  br i1 %cmp157, label %for.body159, label %for.end167

for.body159:                                      ; preds = %for.cond156
  %127 = load i32* %start_addr, align 4
  %128 = load i32* %i, align 4
  %mul160 = mul nsw i32 %128, 16
  %mul161 = mul nsw i32 %mul160, 4
  %add162 = add nsw i32 %127, %mul161
  %129 = load i8** %src.addr, align 4
  %arrayidx163 = getelementptr inbounds i8* %129, i32 %add162
  %130 = bitcast i8* %arrayidx163 to <4 x i8>*
  %131 = load <4 x i8>* %130, align 4
  %132 = load i32* %i, align 4
  %arrayidx164 = getelementptr inbounds [2 x <4 x i8>]* %temp, i32 0, i32 %132
  store <4 x i8> %131, <4 x i8>* %arrayidx164, align 4
  br label %for.inc165

for.inc165:                                       ; preds = %for.body159
  %133 = load i32* %i, align 4
  %inc166 = add nsw i32 %133, 1
  store i32 %inc166, i32* %i, align 4
  br label %for.cond156

for.end167:                                       ; preds = %for.cond156
  br label %if.end

if.end:                                           ; preds = %for.end167, %for.end155
  store i32 0, i32* %i, align 4
  br label %for.cond168

for.cond168:                                      ; preds = %for.inc177, %if.end
  %134 = load i32* %i, align 4
  %cmp169 = icmp slt i32 %134, 2
  br i1 %cmp169, label %for.body171, label %for.end179

for.body171:                                      ; preds = %for.cond168
  %135 = load i32* %i, align 4
  %arrayidx172 = getelementptr inbounds [2 x <4 x i8>]* %temp, i32 0, i32 %135
  %136 = load <4 x i8>* %arrayidx172, align 4
  %137 = load i32* %l_x, align 4
  %138 = load i32* %i, align 4
  %mul173 = mul nsw i32 %138, 16
  %add174 = add nsw i32 %137, %mul173
  %139 = load i32* %l_y, align 4
  %arrayidx175 = getelementptr inbounds [16 x [33 x <4 x i8>]]* @row_filter_C1_D0.LDS_DAT, i32 0, i32 %139
  %arrayidx176 = getelementptr inbounds [33 x <4 x i8>]* %arrayidx175, i32 0, i32 %add174
  store <4 x i8> %136, <4 x i8>* %arrayidx176, align 4
  br label %for.inc177

for.inc177:                                       ; preds = %for.body171
  %140 = load i32* %i, align 4
  %inc178 = add nsw i32 %140, 1
  store i32 %inc178, i32* %i, align 4
  br label %for.cond168

for.end179:                                       ; preds = %for.cond168
  call void @barrier(i32 1)
  %141 = load i32* %l_x, align 4
  %142 = load i32* %l_y, align 4
  %arrayidx180 = getelementptr inbounds [16 x [33 x <4 x i8>]]* @row_filter_C1_D0.LDS_DAT, i32 0, i32 %142
  %arrayidx181 = getelementptr inbounds [33 x <4 x i8>]* %arrayidx180, i32 0, i32 %141
  %143 = bitcast <4 x i8>* %arrayidx181 to i8*
  %add.ptr = getelementptr inbounds i8* %143, i32 2
  %144 = load i32* %offset, align 4
  %add.ptr182 = getelementptr inbounds i8* %add.ptr, i32 %144
  %call183 = call <4 x i8> @_Z12_socl_vload4jPKU3AS0h(i32 0, i8* %add.ptr182)
  store <4 x i8> %call183, <4 x i8>* %coerce, align 4
  %145 = bitcast <4 x i8>* %coerce to i32*
  %146 = load i32* %145, align 1
  %call184 = call <4 x float> @_Z20_socl_convert_float4Dv4_h(i32 %146)
  %147 = load float** %mat_kernel.addr, align 4
  %arrayidx185 = getelementptr inbounds float* %147, i32 2
  %148 = load float* %arrayidx185, align 4
  %splat.splatinsert186 = insertelement <4 x float> undef, float %148, i32 0
  %splat.splat187 = shufflevector <4 x float> %splat.splatinsert186, <4 x float> undef, <4 x i32> zeroinitializer
  %mul188 = fmul <4 x float> %call184, %splat.splat187
  store <4 x float> %mul188, <4 x float>* %sum, align 16
  store i32 1, i32* %i, align 4
  br label %for.cond189

for.cond189:                                      ; preds = %for.inc224, %for.end179
  %149 = load i32* %i, align 4
  %cmp190 = icmp sle i32 %149, 2
  br i1 %cmp190, label %for.body192, label %for.end226

for.body192:                                      ; preds = %for.cond189
  %150 = load i32* %l_x, align 4
  %151 = load i32* %l_y, align 4
  %arrayidx193 = getelementptr inbounds [16 x [33 x <4 x i8>]]* @row_filter_C1_D0.LDS_DAT, i32 0, i32 %151
  %arrayidx194 = getelementptr inbounds [33 x <4 x i8>]* %arrayidx193, i32 0, i32 %150
  %152 = bitcast <4 x i8>* %arrayidx194 to i8*
  %add.ptr195 = getelementptr inbounds i8* %152, i32 2
  %153 = load i32* %offset, align 4
  %add.ptr196 = getelementptr inbounds i8* %add.ptr195, i32 %153
  %154 = load i32* %i, align 4
  %idx.neg = sub i32 0, %154
  %add.ptr197 = getelementptr inbounds i8* %add.ptr196, i32 %idx.neg
  %call198 = call <4 x i8> @_Z12_socl_vload4jPKU3AS0h(i32 0, i8* %add.ptr197)
  %arrayidx199 = getelementptr inbounds [2 x <4 x i8>]* %temp, i32 0, i32 0
  store <4 x i8> %call198, <4 x i8>* %arrayidx199, align 4
  %155 = load i32* %l_x, align 4
  %156 = load i32* %l_y, align 4
  %arrayidx200 = getelementptr inbounds [16 x [33 x <4 x i8>]]* @row_filter_C1_D0.LDS_DAT, i32 0, i32 %156
  %arrayidx201 = getelementptr inbounds [33 x <4 x i8>]* %arrayidx200, i32 0, i32 %155
  %157 = bitcast <4 x i8>* %arrayidx201 to i8*
  %add.ptr202 = getelementptr inbounds i8* %157, i32 2
  %158 = load i32* %offset, align 4
  %add.ptr203 = getelementptr inbounds i8* %add.ptr202, i32 %158
  %159 = load i32* %i, align 4
  %add.ptr204 = getelementptr inbounds i8* %add.ptr203, i32 %159
  %call205 = call <4 x i8> @_Z12_socl_vload4jPKU3AS0h(i32 0, i8* %add.ptr204)
  %arrayidx206 = getelementptr inbounds [2 x <4 x i8>]* %temp, i32 0, i32 1
  store <4 x i8> %call205, <4 x i8>* %arrayidx206, align 4
  %arrayidx207 = getelementptr inbounds [2 x <4 x i8>]* %temp, i32 0, i32 0
  %160 = load <4 x i8>* %arrayidx207, align 4
  store <4 x i8> %160, <4 x i8>* %coerce208, align 4
  %161 = bitcast <4 x i8>* %coerce208 to i32*
  %162 = load i32* %161, align 1
  %call209 = call <4 x float> @_Z20_socl_convert_float4Dv4_h(i32 %162)
  %163 = load i32* %i, align 4
  %sub210 = sub nsw i32 2, %163
  %164 = load float** %mat_kernel.addr, align 4
  %arrayidx211 = getelementptr inbounds float* %164, i32 %sub210
  %165 = load float* %arrayidx211, align 4
  %splat.splatinsert212 = insertelement <4 x float> undef, float %165, i32 0
  %splat.splat213 = shufflevector <4 x float> %splat.splatinsert212, <4 x float> undef, <4 x i32> zeroinitializer
  %arrayidx215 = getelementptr inbounds [2 x <4 x i8>]* %temp, i32 0, i32 1
  %166 = load <4 x i8>* %arrayidx215, align 4
  store <4 x i8> %166, <4 x i8>* %coerce216, align 4
  %167 = bitcast <4 x i8>* %coerce216 to i32*
  %168 = load i32* %167, align 1
  %call217 = call <4 x float> @_Z20_socl_convert_float4Dv4_h(i32 %168)
  %169 = load i32* %i, align 4
  %add218 = add nsw i32 2, %169
  %170 = load float** %mat_kernel.addr, align 4
  %arrayidx219 = getelementptr inbounds float* %170, i32 %add218
  %171 = load float* %arrayidx219, align 4
  %splat.splatinsert220 = insertelement <4 x float> undef, float %171, i32 0
  %splat.splat221 = shufflevector <4 x float> %splat.splatinsert220, <4 x float> undef, <4 x i32> zeroinitializer
  %mul222 = fmul <4 x float> %call217, %splat.splat221
  %172 = call <4 x float> @llvm.fmuladd.v4f32(<4 x float> %call209, <4 x float> %splat.splat213, <4 x float> %mul222)
  %173 = load <4 x float>* %sum, align 16
  %add223 = fadd <4 x float> %173, %172
  store <4 x float> %add223, <4 x float>* %sum, align 16
  br label %for.inc224

for.inc224:                                       ; preds = %for.body192
  %174 = load i32* %i, align 4
  %inc225 = add nsw i32 %174, 1
  store i32 %inc225, i32* %i, align 4
  br label %for.cond189

for.end226:                                       ; preds = %for.cond189
  %175 = load i32* %y, align 4
  %176 = load i32* %dst_step_in_pixel.addr, align 4
  %177 = load i32* %x, align 4
  %call227 = call i32 @_Z11_socl_mad24iii(i32 %175, i32 %176, i32 %177)
  store i32 %call227, i32* %start_addr, align 4
  %178 = load i32* %x, align 4
  %add228 = add nsw i32 %178, 3
  %179 = load i32* %dst_cols.addr, align 4
  %cmp229 = icmp slt i32 %add228, %179
  %conv230 = zext i1 %cmp229 to i32
  %180 = load i32* %y, align 4
  %181 = load i32* %dst_rows.addr, align 4
  %cmp231 = icmp slt i32 %180, %181
  %conv232 = zext i1 %cmp231 to i32
  %and233 = and i32 %conv230, %conv232
  %tobool234 = icmp ne i32 %and233, 0
  br i1 %tobool234, label %if.then235, label %if.else237

if.then235:                                       ; preds = %for.end226
  %182 = load <4 x float>* %sum, align 16
  %183 = load i32* %start_addr, align 4
  %184 = load float** %dst.addr, align 4
  %arrayidx236 = getelementptr inbounds float* %184, i32 %183
  %185 = bitcast float* %arrayidx236 to <4 x float>*
  store <4 x float> %182, <4 x float>* %185, align 16
  br label %if.end275

if.else237:                                       ; preds = %for.end226
  %186 = load i32* %x, align 4
  %add238 = add nsw i32 %186, 2
  %187 = load i32* %dst_cols.addr, align 4
  %cmp239 = icmp slt i32 %add238, %187
  %conv240 = zext i1 %cmp239 to i32
  %188 = load i32* %y, align 4
  %189 = load i32* %dst_rows.addr, align 4
  %cmp241 = icmp slt i32 %188, %189
  %conv242 = zext i1 %cmp241 to i32
  %and243 = and i32 %conv240, %conv242
  %tobool244 = icmp ne i32 %and243, 0
  br i1 %tobool244, label %if.then245, label %if.else251

if.then245:                                       ; preds = %if.else237
  %190 = load <4 x float>* %sum, align 16
  %191 = extractelement <4 x float> %190, i32 0
  %192 = load i32* %start_addr, align 4
  %193 = load float** %dst.addr, align 4
  %arrayidx246 = getelementptr inbounds float* %193, i32 %192
  store float %191, float* %arrayidx246, align 4
  %194 = load <4 x float>* %sum, align 16
  %195 = extractelement <4 x float> %194, i32 1
  %196 = load i32* %start_addr, align 4
  %add247 = add nsw i32 %196, 1
  %197 = load float** %dst.addr, align 4
  %arrayidx248 = getelementptr inbounds float* %197, i32 %add247
  store float %195, float* %arrayidx248, align 4
  %198 = load <4 x float>* %sum, align 16
  %199 = extractelement <4 x float> %198, i32 2
  %200 = load i32* %start_addr, align 4
  %add249 = add nsw i32 %200, 2
  %201 = load float** %dst.addr, align 4
  %arrayidx250 = getelementptr inbounds float* %201, i32 %add249
  store float %199, float* %arrayidx250, align 4
  br label %if.end274

if.else251:                                       ; preds = %if.else237
  %202 = load i32* %x, align 4
  %add252 = add nsw i32 %202, 1
  %203 = load i32* %dst_cols.addr, align 4
  %cmp253 = icmp slt i32 %add252, %203
  %conv254 = zext i1 %cmp253 to i32
  %204 = load i32* %y, align 4
  %205 = load i32* %dst_rows.addr, align 4
  %cmp255 = icmp slt i32 %204, %205
  %conv256 = zext i1 %cmp255 to i32
  %and257 = and i32 %conv254, %conv256
  %tobool258 = icmp ne i32 %and257, 0
  br i1 %tobool258, label %if.then259, label %if.else263

if.then259:                                       ; preds = %if.else251
  %206 = load <4 x float>* %sum, align 16
  %207 = extractelement <4 x float> %206, i32 0
  %208 = load i32* %start_addr, align 4
  %209 = load float** %dst.addr, align 4
  %arrayidx260 = getelementptr inbounds float* %209, i32 %208
  store float %207, float* %arrayidx260, align 4
  %210 = load <4 x float>* %sum, align 16
  %211 = extractelement <4 x float> %210, i32 1
  %212 = load i32* %start_addr, align 4
  %add261 = add nsw i32 %212, 1
  %213 = load float** %dst.addr, align 4
  %arrayidx262 = getelementptr inbounds float* %213, i32 %add261
  store float %211, float* %arrayidx262, align 4
  br label %if.end273

if.else263:                                       ; preds = %if.else251
  %214 = load i32* %x, align 4
  %215 = load i32* %dst_cols.addr, align 4
  %cmp264 = icmp slt i32 %214, %215
  %conv265 = zext i1 %cmp264 to i32
  %216 = load i32* %y, align 4
  %217 = load i32* %dst_rows.addr, align 4
  %cmp266 = icmp slt i32 %216, %217
  %conv267 = zext i1 %cmp266 to i32
  %and268 = and i32 %conv265, %conv267
  %tobool269 = icmp ne i32 %and268, 0
  br i1 %tobool269, label %if.then270, label %if.end272

if.then270:                                       ; preds = %if.else263
  %218 = load <4 x float>* %sum, align 16
  %219 = extractelement <4 x float> %218, i32 0
  %220 = load i32* %start_addr, align 4
  %221 = load float** %dst.addr, align 4
  %arrayidx271 = getelementptr inbounds float* %221, i32 %220
  store float %219, float* %arrayidx271, align 4
  br label %if.end272

if.end272:                                        ; preds = %if.then270, %if.else263
  br label %if.end273

if.end273:                                        ; preds = %if.end272, %if.then259
  br label %if.end274

if.end274:                                        ; preds = %if.end273, %if.then245
  br label %if.end275

if.end275:                                        ; preds = %if.end274, %if.then235
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
  %src.addr = alloca <4 x i8>*, align 4
  %dst.addr = alloca <4 x float>*, align 4
  %dst_cols.addr = alloca i32, align 4
  %dst_rows.addr = alloca i32, align 4
  %src_whole_cols.addr = alloca i32, align 4
  %src_whole_rows.addr = alloca i32, align 4
  %src_step_in_pixel.addr = alloca i32, align 4
  %src_offset_x.addr = alloca i32, align 4
  %src_offset_y.addr = alloca i32, align 4
  %dst_step_in_pixel.addr = alloca i32, align 4
  %radiusy.addr = alloca i32, align 4
  %mat_kernel.addr = alloca float*, align 4
  %x = alloca i32, align 4
  %y = alloca i32, align 4
  %l_x = alloca i32, align 4
  %l_y = alloca i32, align 4
  %start_x = alloca i32, align 4
  %start_y = alloca i32, align 4
  %start_addr = alloca i32, align 4
  %i = alloca i32, align 4
  %sum = alloca <4 x float>, align 16
  %temp = alloca [2 x <4 x i8>], align 4
  %index = alloca [2 x i32], align 4
  %s_x = alloca i32, align 4
  %s_y = alloca i32, align 4
  %coerce = alloca <4 x i8>, align 4
  %coerce71 = alloca <4 x i8>, align 4
  %coerce79 = alloca <4 x i8>, align 4
  store <4 x i8>* %src, <4 x i8>** %src.addr, align 4
  store <4 x float>* %dst, <4 x float>** %dst.addr, align 4
  store i32 %dst_cols, i32* %dst_cols.addr, align 4
  store i32 %dst_rows, i32* %dst_rows.addr, align 4
  store i32 %src_whole_cols, i32* %src_whole_cols.addr, align 4
  store i32 %src_whole_rows, i32* %src_whole_rows.addr, align 4
  store i32 %src_step_in_pixel, i32* %src_step_in_pixel.addr, align 4
  store i32 %src_offset_x, i32* %src_offset_x.addr, align 4
  store i32 %src_offset_y, i32* %src_offset_y.addr, align 4
  store i32 %dst_step_in_pixel, i32* %dst_step_in_pixel.addr, align 4
  store i32 %radiusy, i32* %radiusy.addr, align 4
  store float* %mat_kernel, float** %mat_kernel.addr, align 4
  %call = call i32 @get_global_id(i32 0)
  store i32 %call, i32* %x, align 4
  %call1 = call i32 @get_global_id(i32 1)
  store i32 %call1, i32* %y, align 4
  %call2 = call i32 @get_local_id(i32 0)
  store i32 %call2, i32* %l_x, align 4
  %call3 = call i32 @get_local_id(i32 1)
  store i32 %call3, i32* %l_y, align 4
  %0 = load i32* %x, align 4
  %1 = load i32* %src_offset_x.addr, align 4
  %add = add nsw i32 %0, %1
  %sub = sub nsw i32 %add, 2
  store i32 %sub, i32* %start_x, align 4
  %2 = load i32* %y, align 4
  %3 = load i32* %src_offset_y.addr, align 4
  %add4 = add nsw i32 %2, %3
  %4 = load i32* %radiusy.addr, align 4
  %sub5 = sub nsw i32 %add4, %4
  store i32 %sub5, i32* %start_y, align 4
  %5 = load i32* %start_y, align 4
  %6 = load i32* %src_step_in_pixel.addr, align 4
  %7 = load i32* %start_x, align 4
  %call6 = call i32 @_Z11_socl_mad24iii(i32 %5, i32 %6, i32 %7)
  store i32 %call6, i32* %start_addr, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %8 = load i32* %i, align 4
  %cmp = icmp slt i32 %8, 2
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %9 = load i32* %start_x, align 4
  %10 = load i32* %i, align 4
  %mul = mul nsw i32 %10, 16
  %add7 = add nsw i32 %9, %mul
  %cmp8 = icmp slt i32 %add7, 0
  br i1 %cmp8, label %cond.true, label %cond.false

cond.true:                                        ; preds = %for.body
  br label %cond.end

cond.false:                                       ; preds = %for.body
  %11 = load i32* %start_x, align 4
  %12 = load i32* %i, align 4
  %mul9 = mul nsw i32 %12, 16
  %add10 = add nsw i32 %11, %mul9
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i32 [ 0, %cond.true ], [ %add10, %cond.false ]
  store i32 %cond, i32* %s_x, align 4
  %13 = load i32* %start_x, align 4
  %14 = load i32* %i, align 4
  %mul11 = mul nsw i32 %14, 16
  %add12 = add nsw i32 %13, %mul11
  %15 = load i32* %src_whole_cols.addr, align 4
  %cmp13 = icmp sge i32 %add12, %15
  br i1 %cmp13, label %cond.true14, label %cond.false16

cond.true14:                                      ; preds = %cond.end
  %16 = load i32* %src_whole_cols.addr, align 4
  %sub15 = sub nsw i32 %16, 1
  br label %cond.end17

cond.false16:                                     ; preds = %cond.end
  %17 = load i32* %s_x, align 4
  br label %cond.end17

cond.end17:                                       ; preds = %cond.false16, %cond.true14
  %cond18 = phi i32 [ %sub15, %cond.true14 ], [ %17, %cond.false16 ]
  store i32 %cond18, i32* %s_x, align 4
  %18 = load i32* %start_y, align 4
  %cmp19 = icmp slt i32 %18, 0
  br i1 %cmp19, label %cond.true20, label %cond.false21

cond.true20:                                      ; preds = %cond.end17
  br label %cond.end22

cond.false21:                                     ; preds = %cond.end17
  %19 = load i32* %start_y, align 4
  br label %cond.end22

cond.end22:                                       ; preds = %cond.false21, %cond.true20
  %cond23 = phi i32 [ 0, %cond.true20 ], [ %19, %cond.false21 ]
  store i32 %cond23, i32* %s_y, align 4
  %20 = load i32* %start_y, align 4
  %21 = load i32* %src_whole_rows.addr, align 4
  %cmp24 = icmp sge i32 %20, %21
  br i1 %cmp24, label %cond.true25, label %cond.false27

cond.true25:                                      ; preds = %cond.end22
  %22 = load i32* %src_whole_rows.addr, align 4
  %sub26 = sub nsw i32 %22, 1
  br label %cond.end28

cond.false27:                                     ; preds = %cond.end22
  %23 = load i32* %s_y, align 4
  br label %cond.end28

cond.end28:                                       ; preds = %cond.false27, %cond.true25
  %cond29 = phi i32 [ %sub26, %cond.true25 ], [ %23, %cond.false27 ]
  store i32 %cond29, i32* %s_y, align 4
  %24 = load i32* %s_y, align 4
  %25 = load i32* %src_step_in_pixel.addr, align 4
  %26 = load i32* %s_x, align 4
  %call30 = call i32 @_Z11_socl_mad24iii(i32 %24, i32 %25, i32 %26)
  %27 = load i32* %i, align 4
  %arrayidx = getelementptr inbounds [2 x i32]* %index, i32 0, i32 %27
  store i32 %call30, i32* %arrayidx, align 4
  br label %for.inc

for.inc:                                          ; preds = %cond.end28
  %28 = load i32* %i, align 4
  %inc = add nsw i32 %28, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  store i32 0, i32* %i, align 4
  br label %for.cond31

for.cond31:                                       ; preds = %for.inc37, %for.end
  %29 = load i32* %i, align 4
  %cmp32 = icmp slt i32 %29, 2
  br i1 %cmp32, label %for.body33, label %for.end39

for.body33:                                       ; preds = %for.cond31
  %30 = load i32* %i, align 4
  %arrayidx34 = getelementptr inbounds [2 x i32]* %index, i32 0, i32 %30
  %31 = load i32* %arrayidx34, align 4
  %32 = load <4 x i8>** %src.addr, align 4
  %arrayidx35 = getelementptr inbounds <4 x i8>* %32, i32 %31
  %33 = load <4 x i8>* %arrayidx35, align 4
  %34 = load i32* %i, align 4
  %arrayidx36 = getelementptr inbounds [2 x <4 x i8>]* %temp, i32 0, i32 %34
  store <4 x i8> %33, <4 x i8>* %arrayidx36, align 4
  br label %for.inc37

for.inc37:                                        ; preds = %for.body33
  %35 = load i32* %i, align 4
  %inc38 = add nsw i32 %35, 1
  store i32 %inc38, i32* %i, align 4
  br label %for.cond31

for.end39:                                        ; preds = %for.cond31
  store i32 0, i32* %i, align 4
  br label %for.cond40

for.cond40:                                       ; preds = %for.inc48, %for.end39
  %36 = load i32* %i, align 4
  %cmp41 = icmp slt i32 %36, 2
  br i1 %cmp41, label %for.body42, label %for.end50

for.body42:                                       ; preds = %for.cond40
  %37 = load i32* %i, align 4
  %arrayidx43 = getelementptr inbounds [2 x <4 x i8>]* %temp, i32 0, i32 %37
  %38 = load <4 x i8>* %arrayidx43, align 4
  %39 = load i32* %l_x, align 4
  %40 = load i32* %i, align 4
  %mul44 = mul nsw i32 %40, 16
  %add45 = add nsw i32 %39, %mul44
  %41 = load i32* %l_y, align 4
  %arrayidx46 = getelementptr inbounds [16 x [33 x <4 x i8>]]* @row_filter_C4_D0.LDS_DAT, i32 0, i32 %41
  %arrayidx47 = getelementptr inbounds [33 x <4 x i8>]* %arrayidx46, i32 0, i32 %add45
  store <4 x i8> %38, <4 x i8>* %arrayidx47, align 4
  br label %for.inc48

for.inc48:                                        ; preds = %for.body42
  %42 = load i32* %i, align 4
  %inc49 = add nsw i32 %42, 1
  store i32 %inc49, i32* %i, align 4
  br label %for.cond40

for.end50:                                        ; preds = %for.cond40
  call void @barrier(i32 1)
  %43 = load i32* %l_x, align 4
  %add51 = add nsw i32 %43, 2
  %44 = load i32* %l_y, align 4
  %arrayidx52 = getelementptr inbounds [16 x [33 x <4 x i8>]]* @row_filter_C4_D0.LDS_DAT, i32 0, i32 %44
  %arrayidx53 = getelementptr inbounds [33 x <4 x i8>]* %arrayidx52, i32 0, i32 %add51
  %45 = load <4 x i8>* %arrayidx53, align 4
  store <4 x i8> %45, <4 x i8>* %coerce, align 4
  %46 = bitcast <4 x i8>* %coerce to i32*
  %47 = load i32* %46, align 1
  %call54 = call <4 x float> @_Z20_socl_convert_float4Dv4_h(i32 %47)
  %48 = load float** %mat_kernel.addr, align 4
  %arrayidx55 = getelementptr inbounds float* %48, i32 2
  %49 = load float* %arrayidx55, align 4
  %splat.splatinsert = insertelement <4 x float> undef, float %49, i32 0
  %splat.splat = shufflevector <4 x float> %splat.splatinsert, <4 x float> undef, <4 x i32> zeroinitializer
  %mul56 = fmul <4 x float> %call54, %splat.splat
  store <4 x float> %mul56, <4 x float>* %sum, align 16
  store i32 1, i32* %i, align 4
  br label %for.cond57

for.cond57:                                       ; preds = %for.inc87, %for.end50
  %50 = load i32* %i, align 4
  %cmp58 = icmp sle i32 %50, 2
  br i1 %cmp58, label %for.body59, label %for.end89

for.body59:                                       ; preds = %for.cond57
  %51 = load i32* %l_x, align 4
  %add60 = add nsw i32 %51, 2
  %52 = load i32* %i, align 4
  %sub61 = sub nsw i32 %add60, %52
  %53 = load i32* %l_y, align 4
  %arrayidx62 = getelementptr inbounds [16 x [33 x <4 x i8>]]* @row_filter_C4_D0.LDS_DAT, i32 0, i32 %53
  %arrayidx63 = getelementptr inbounds [33 x <4 x i8>]* %arrayidx62, i32 0, i32 %sub61
  %54 = load <4 x i8>* %arrayidx63, align 4
  %arrayidx64 = getelementptr inbounds [2 x <4 x i8>]* %temp, i32 0, i32 0
  store <4 x i8> %54, <4 x i8>* %arrayidx64, align 4
  %55 = load i32* %l_x, align 4
  %add65 = add nsw i32 %55, 2
  %56 = load i32* %i, align 4
  %add66 = add nsw i32 %add65, %56
  %57 = load i32* %l_y, align 4
  %arrayidx67 = getelementptr inbounds [16 x [33 x <4 x i8>]]* @row_filter_C4_D0.LDS_DAT, i32 0, i32 %57
  %arrayidx68 = getelementptr inbounds [33 x <4 x i8>]* %arrayidx67, i32 0, i32 %add66
  %58 = load <4 x i8>* %arrayidx68, align 4
  %arrayidx69 = getelementptr inbounds [2 x <4 x i8>]* %temp, i32 0, i32 1
  store <4 x i8> %58, <4 x i8>* %arrayidx69, align 4
  %arrayidx70 = getelementptr inbounds [2 x <4 x i8>]* %temp, i32 0, i32 0
  %59 = load <4 x i8>* %arrayidx70, align 4
  store <4 x i8> %59, <4 x i8>* %coerce71, align 4
  %60 = bitcast <4 x i8>* %coerce71 to i32*
  %61 = load i32* %60, align 1
  %call72 = call <4 x float> @_Z20_socl_convert_float4Dv4_h(i32 %61)
  %62 = load i32* %i, align 4
  %sub73 = sub nsw i32 2, %62
  %63 = load float** %mat_kernel.addr, align 4
  %arrayidx74 = getelementptr inbounds float* %63, i32 %sub73
  %64 = load float* %arrayidx74, align 4
  %splat.splatinsert75 = insertelement <4 x float> undef, float %64, i32 0
  %splat.splat76 = shufflevector <4 x float> %splat.splatinsert75, <4 x float> undef, <4 x i32> zeroinitializer
  %arrayidx78 = getelementptr inbounds [2 x <4 x i8>]* %temp, i32 0, i32 1
  %65 = load <4 x i8>* %arrayidx78, align 4
  store <4 x i8> %65, <4 x i8>* %coerce79, align 4
  %66 = bitcast <4 x i8>* %coerce79 to i32*
  %67 = load i32* %66, align 1
  %call80 = call <4 x float> @_Z20_socl_convert_float4Dv4_h(i32 %67)
  %68 = load i32* %i, align 4
  %add81 = add nsw i32 2, %68
  %69 = load float** %mat_kernel.addr, align 4
  %arrayidx82 = getelementptr inbounds float* %69, i32 %add81
  %70 = load float* %arrayidx82, align 4
  %splat.splatinsert83 = insertelement <4 x float> undef, float %70, i32 0
  %splat.splat84 = shufflevector <4 x float> %splat.splatinsert83, <4 x float> undef, <4 x i32> zeroinitializer
  %mul85 = fmul <4 x float> %call80, %splat.splat84
  %71 = call <4 x float> @llvm.fmuladd.v4f32(<4 x float> %call72, <4 x float> %splat.splat76, <4 x float> %mul85)
  %72 = load <4 x float>* %sum, align 16
  %add86 = fadd <4 x float> %72, %71
  store <4 x float> %add86, <4 x float>* %sum, align 16
  br label %for.inc87

for.inc87:                                        ; preds = %for.body59
  %73 = load i32* %i, align 4
  %inc88 = add nsw i32 %73, 1
  store i32 %inc88, i32* %i, align 4
  br label %for.cond57

for.end89:                                        ; preds = %for.cond57
  %74 = load i32* %x, align 4
  %75 = load i32* %dst_cols.addr, align 4
  %cmp90 = icmp slt i32 %74, %75
  %conv = zext i1 %cmp90 to i32
  %76 = load i32* %y, align 4
  %77 = load i32* %dst_rows.addr, align 4
  %cmp91 = icmp slt i32 %76, %77
  %conv92 = zext i1 %cmp91 to i32
  %and = and i32 %conv, %conv92
  %tobool = icmp ne i32 %and, 0
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %for.end89
  %78 = load i32* %y, align 4
  %79 = load i32* %dst_step_in_pixel.addr, align 4
  %80 = load i32* %x, align 4
  %call93 = call i32 @_Z11_socl_mad24iii(i32 %78, i32 %79, i32 %80)
  store i32 %call93, i32* %start_addr, align 4
  %81 = load <4 x float>* %sum, align 16
  %82 = load i32* %start_addr, align 4
  %83 = load <4 x float>** %dst.addr, align 4
  %arrayidx94 = getelementptr inbounds <4 x float>* %83, i32 %82
  store <4 x float> %81, <4 x float>* %arrayidx94, align 16
  br label %if.end

if.end:                                           ; preds = %if.then, %for.end89
  ret void
}

; Function Attrs: nounwind
define void @row_filter_C1_D5(float* noalias %src, float* %dst, i32 %dst_cols, i32 %dst_rows, i32 %src_whole_cols, i32 %src_whole_rows, i32 %src_step_in_pixel, i32 %src_offset_x, i32 %src_offset_y, i32 %dst_step_in_pixel, i32 %radiusy, float* %mat_kernel) #0 {
entry:
  %src.addr = alloca float*, align 4
  %dst.addr = alloca float*, align 4
  %dst_cols.addr = alloca i32, align 4
  %dst_rows.addr = alloca i32, align 4
  %src_whole_cols.addr = alloca i32, align 4
  %src_whole_rows.addr = alloca i32, align 4
  %src_step_in_pixel.addr = alloca i32, align 4
  %src_offset_x.addr = alloca i32, align 4
  %src_offset_y.addr = alloca i32, align 4
  %dst_step_in_pixel.addr = alloca i32, align 4
  %radiusy.addr = alloca i32, align 4
  %mat_kernel.addr = alloca float*, align 4
  %x = alloca i32, align 4
  %y = alloca i32, align 4
  %l_x = alloca i32, align 4
  %l_y = alloca i32, align 4
  %start_x = alloca i32, align 4
  %start_y = alloca i32, align 4
  %start_addr = alloca i32, align 4
  %i = alloca i32, align 4
  %sum = alloca float, align 4
  %temp = alloca [2 x float], align 4
  %index = alloca [2 x i32], align 4
  %s_x = alloca i32, align 4
  %s_y = alloca i32, align 4
  store float* %src, float** %src.addr, align 4
  store float* %dst, float** %dst.addr, align 4
  store i32 %dst_cols, i32* %dst_cols.addr, align 4
  store i32 %dst_rows, i32* %dst_rows.addr, align 4
  store i32 %src_whole_cols, i32* %src_whole_cols.addr, align 4
  store i32 %src_whole_rows, i32* %src_whole_rows.addr, align 4
  store i32 %src_step_in_pixel, i32* %src_step_in_pixel.addr, align 4
  store i32 %src_offset_x, i32* %src_offset_x.addr, align 4
  store i32 %src_offset_y, i32* %src_offset_y.addr, align 4
  store i32 %dst_step_in_pixel, i32* %dst_step_in_pixel.addr, align 4
  store i32 %radiusy, i32* %radiusy.addr, align 4
  store float* %mat_kernel, float** %mat_kernel.addr, align 4
  %call = call i32 @get_global_id(i32 0)
  store i32 %call, i32* %x, align 4
  %call1 = call i32 @get_global_id(i32 1)
  store i32 %call1, i32* %y, align 4
  %call2 = call i32 @get_local_id(i32 0)
  store i32 %call2, i32* %l_x, align 4
  %call3 = call i32 @get_local_id(i32 1)
  store i32 %call3, i32* %l_y, align 4
  %0 = load i32* %x, align 4
  %1 = load i32* %src_offset_x.addr, align 4
  %add = add nsw i32 %0, %1
  %sub = sub nsw i32 %add, 2
  store i32 %sub, i32* %start_x, align 4
  %2 = load i32* %y, align 4
  %3 = load i32* %src_offset_y.addr, align 4
  %add4 = add nsw i32 %2, %3
  %4 = load i32* %radiusy.addr, align 4
  %sub5 = sub nsw i32 %add4, %4
  store i32 %sub5, i32* %start_y, align 4
  %5 = load i32* %start_y, align 4
  %6 = load i32* %src_step_in_pixel.addr, align 4
  %7 = load i32* %start_x, align 4
  %call6 = call i32 @_Z11_socl_mad24iii(i32 %5, i32 %6, i32 %7)
  store i32 %call6, i32* %start_addr, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %8 = load i32* %i, align 4
  %cmp = icmp slt i32 %8, 2
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %9 = load i32* %start_x, align 4
  %10 = load i32* %i, align 4
  %mul = mul nsw i32 %10, 16
  %add7 = add nsw i32 %9, %mul
  %cmp8 = icmp slt i32 %add7, 0
  br i1 %cmp8, label %cond.true, label %cond.false

cond.true:                                        ; preds = %for.body
  br label %cond.end

cond.false:                                       ; preds = %for.body
  %11 = load i32* %start_x, align 4
  %12 = load i32* %i, align 4
  %mul9 = mul nsw i32 %12, 16
  %add10 = add nsw i32 %11, %mul9
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i32 [ 0, %cond.true ], [ %add10, %cond.false ]
  store i32 %cond, i32* %s_x, align 4
  %13 = load i32* %start_x, align 4
  %14 = load i32* %i, align 4
  %mul11 = mul nsw i32 %14, 16
  %add12 = add nsw i32 %13, %mul11
  %15 = load i32* %src_whole_cols.addr, align 4
  %cmp13 = icmp sge i32 %add12, %15
  br i1 %cmp13, label %cond.true14, label %cond.false16

cond.true14:                                      ; preds = %cond.end
  %16 = load i32* %src_whole_cols.addr, align 4
  %sub15 = sub nsw i32 %16, 1
  br label %cond.end17

cond.false16:                                     ; preds = %cond.end
  %17 = load i32* %s_x, align 4
  br label %cond.end17

cond.end17:                                       ; preds = %cond.false16, %cond.true14
  %cond18 = phi i32 [ %sub15, %cond.true14 ], [ %17, %cond.false16 ]
  store i32 %cond18, i32* %s_x, align 4
  %18 = load i32* %start_y, align 4
  %cmp19 = icmp slt i32 %18, 0
  br i1 %cmp19, label %cond.true20, label %cond.false21

cond.true20:                                      ; preds = %cond.end17
  br label %cond.end22

cond.false21:                                     ; preds = %cond.end17
  %19 = load i32* %start_y, align 4
  br label %cond.end22

cond.end22:                                       ; preds = %cond.false21, %cond.true20
  %cond23 = phi i32 [ 0, %cond.true20 ], [ %19, %cond.false21 ]
  store i32 %cond23, i32* %s_y, align 4
  %20 = load i32* %start_y, align 4
  %21 = load i32* %src_whole_rows.addr, align 4
  %cmp24 = icmp sge i32 %20, %21
  br i1 %cmp24, label %cond.true25, label %cond.false27

cond.true25:                                      ; preds = %cond.end22
  %22 = load i32* %src_whole_rows.addr, align 4
  %sub26 = sub nsw i32 %22, 1
  br label %cond.end28

cond.false27:                                     ; preds = %cond.end22
  %23 = load i32* %s_y, align 4
  br label %cond.end28

cond.end28:                                       ; preds = %cond.false27, %cond.true25
  %cond29 = phi i32 [ %sub26, %cond.true25 ], [ %23, %cond.false27 ]
  store i32 %cond29, i32* %s_y, align 4
  %24 = load i32* %s_y, align 4
  %25 = load i32* %src_step_in_pixel.addr, align 4
  %26 = load i32* %s_x, align 4
  %call30 = call i32 @_Z11_socl_mad24iii(i32 %24, i32 %25, i32 %26)
  %27 = load i32* %i, align 4
  %arrayidx = getelementptr inbounds [2 x i32]* %index, i32 0, i32 %27
  store i32 %call30, i32* %arrayidx, align 4
  br label %for.inc

for.inc:                                          ; preds = %cond.end28
  %28 = load i32* %i, align 4
  %inc = add nsw i32 %28, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  store i32 0, i32* %i, align 4
  br label %for.cond31

for.cond31:                                       ; preds = %for.inc37, %for.end
  %29 = load i32* %i, align 4
  %cmp32 = icmp slt i32 %29, 2
  br i1 %cmp32, label %for.body33, label %for.end39

for.body33:                                       ; preds = %for.cond31
  %30 = load i32* %i, align 4
  %arrayidx34 = getelementptr inbounds [2 x i32]* %index, i32 0, i32 %30
  %31 = load i32* %arrayidx34, align 4
  %32 = load float** %src.addr, align 4
  %arrayidx35 = getelementptr inbounds float* %32, i32 %31
  %33 = load float* %arrayidx35, align 4
  %34 = load i32* %i, align 4
  %arrayidx36 = getelementptr inbounds [2 x float]* %temp, i32 0, i32 %34
  store float %33, float* %arrayidx36, align 4
  br label %for.inc37

for.inc37:                                        ; preds = %for.body33
  %35 = load i32* %i, align 4
  %inc38 = add nsw i32 %35, 1
  store i32 %inc38, i32* %i, align 4
  br label %for.cond31

for.end39:                                        ; preds = %for.cond31
  store i32 0, i32* %i, align 4
  br label %for.cond40

for.cond40:                                       ; preds = %for.inc48, %for.end39
  %36 = load i32* %i, align 4
  %cmp41 = icmp slt i32 %36, 2
  br i1 %cmp41, label %for.body42, label %for.end50

for.body42:                                       ; preds = %for.cond40
  %37 = load i32* %i, align 4
  %arrayidx43 = getelementptr inbounds [2 x float]* %temp, i32 0, i32 %37
  %38 = load float* %arrayidx43, align 4
  %39 = load i32* %l_x, align 4
  %40 = load i32* %i, align 4
  %mul44 = mul nsw i32 %40, 16
  %add45 = add nsw i32 %39, %mul44
  %41 = load i32* %l_y, align 4
  %arrayidx46 = getelementptr inbounds [16 x [33 x float]]* @row_filter_C1_D5.LDS_DAT, i32 0, i32 %41
  %arrayidx47 = getelementptr inbounds [33 x float]* %arrayidx46, i32 0, i32 %add45
  store float %38, float* %arrayidx47, align 4
  br label %for.inc48

for.inc48:                                        ; preds = %for.body42
  %42 = load i32* %i, align 4
  %inc49 = add nsw i32 %42, 1
  store i32 %inc49, i32* %i, align 4
  br label %for.cond40

for.end50:                                        ; preds = %for.cond40
  call void @barrier(i32 1)
  %43 = load i32* %l_x, align 4
  %add51 = add nsw i32 %43, 2
  %44 = load i32* %l_y, align 4
  %arrayidx52 = getelementptr inbounds [16 x [33 x float]]* @row_filter_C1_D5.LDS_DAT, i32 0, i32 %44
  %arrayidx53 = getelementptr inbounds [33 x float]* %arrayidx52, i32 0, i32 %add51
  %45 = load float* %arrayidx53, align 4
  %46 = load float** %mat_kernel.addr, align 4
  %arrayidx54 = getelementptr inbounds float* %46, i32 2
  %47 = load float* %arrayidx54, align 4
  %mul55 = fmul float %45, %47
  store float %mul55, float* %sum, align 4
  store i32 1, i32* %i, align 4
  br label %for.cond56

for.cond56:                                       ; preds = %for.inc78, %for.end50
  %48 = load i32* %i, align 4
  %cmp57 = icmp sle i32 %48, 2
  br i1 %cmp57, label %for.body58, label %for.end80

for.body58:                                       ; preds = %for.cond56
  %49 = load i32* %l_x, align 4
  %add59 = add nsw i32 %49, 2
  %50 = load i32* %i, align 4
  %sub60 = sub nsw i32 %add59, %50
  %51 = load i32* %l_y, align 4
  %arrayidx61 = getelementptr inbounds [16 x [33 x float]]* @row_filter_C1_D5.LDS_DAT, i32 0, i32 %51
  %arrayidx62 = getelementptr inbounds [33 x float]* %arrayidx61, i32 0, i32 %sub60
  %52 = load float* %arrayidx62, align 4
  %arrayidx63 = getelementptr inbounds [2 x float]* %temp, i32 0, i32 0
  store float %52, float* %arrayidx63, align 4
  %53 = load i32* %l_x, align 4
  %add64 = add nsw i32 %53, 2
  %54 = load i32* %i, align 4
  %add65 = add nsw i32 %add64, %54
  %55 = load i32* %l_y, align 4
  %arrayidx66 = getelementptr inbounds [16 x [33 x float]]* @row_filter_C1_D5.LDS_DAT, i32 0, i32 %55
  %arrayidx67 = getelementptr inbounds [33 x float]* %arrayidx66, i32 0, i32 %add65
  %56 = load float* %arrayidx67, align 4
  %arrayidx68 = getelementptr inbounds [2 x float]* %temp, i32 0, i32 1
  store float %56, float* %arrayidx68, align 4
  %arrayidx69 = getelementptr inbounds [2 x float]* %temp, i32 0, i32 0
  %57 = load float* %arrayidx69, align 4
  %58 = load i32* %i, align 4
  %sub70 = sub nsw i32 2, %58
  %59 = load float** %mat_kernel.addr, align 4
  %arrayidx71 = getelementptr inbounds float* %59, i32 %sub70
  %60 = load float* %arrayidx71, align 4
  %arrayidx73 = getelementptr inbounds [2 x float]* %temp, i32 0, i32 1
  %61 = load float* %arrayidx73, align 4
  %62 = load i32* %i, align 4
  %add74 = add nsw i32 2, %62
  %63 = load float** %mat_kernel.addr, align 4
  %arrayidx75 = getelementptr inbounds float* %63, i32 %add74
  %64 = load float* %arrayidx75, align 4
  %mul76 = fmul float %61, %64
  %65 = call float @llvm.fmuladd.f32(float %57, float %60, float %mul76)
  %66 = load float* %sum, align 4
  %add77 = fadd float %66, %65
  store float %add77, float* %sum, align 4
  br label %for.inc78

for.inc78:                                        ; preds = %for.body58
  %67 = load i32* %i, align 4
  %inc79 = add nsw i32 %67, 1
  store i32 %inc79, i32* %i, align 4
  br label %for.cond56

for.end80:                                        ; preds = %for.cond56
  %68 = load i32* %x, align 4
  %69 = load i32* %dst_cols.addr, align 4
  %cmp81 = icmp slt i32 %68, %69
  %conv = zext i1 %cmp81 to i32
  %70 = load i32* %y, align 4
  %71 = load i32* %dst_rows.addr, align 4
  %cmp82 = icmp slt i32 %70, %71
  %conv83 = zext i1 %cmp82 to i32
  %and = and i32 %conv, %conv83
  %tobool = icmp ne i32 %and, 0
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %for.end80
  %72 = load i32* %y, align 4
  %73 = load i32* %dst_step_in_pixel.addr, align 4
  %74 = load i32* %x, align 4
  %call84 = call i32 @_Z11_socl_mad24iii(i32 %72, i32 %73, i32 %74)
  store i32 %call84, i32* %start_addr, align 4
  %75 = load float* %sum, align 4
  %76 = load i32* %start_addr, align 4
  %77 = load float** %dst.addr, align 4
  %arrayidx85 = getelementptr inbounds float* %77, i32 %76
  store float %75, float* %arrayidx85, align 4
  br label %if.end

if.end:                                           ; preds = %if.then, %for.end80
  ret void
}

; Function Attrs: nounwind readnone
declare float @llvm.fmuladd.f32(float, float, float) #2

; Function Attrs: nounwind
define void @row_filter_C4_D5(<4 x float>* noalias %src, <4 x float>* %dst, i32 %dst_cols, i32 %dst_rows, i32 %src_whole_cols, i32 %src_whole_rows, i32 %src_step_in_pixel, i32 %src_offset_x, i32 %src_offset_y, i32 %dst_step_in_pixel, i32 %radiusy, float* %mat_kernel) #0 {
entry:
  %src.addr = alloca <4 x float>*, align 4
  %dst.addr = alloca <4 x float>*, align 4
  %dst_cols.addr = alloca i32, align 4
  %dst_rows.addr = alloca i32, align 4
  %src_whole_cols.addr = alloca i32, align 4
  %src_whole_rows.addr = alloca i32, align 4
  %src_step_in_pixel.addr = alloca i32, align 4
  %src_offset_x.addr = alloca i32, align 4
  %src_offset_y.addr = alloca i32, align 4
  %dst_step_in_pixel.addr = alloca i32, align 4
  %radiusy.addr = alloca i32, align 4
  %mat_kernel.addr = alloca float*, align 4
  %x = alloca i32, align 4
  %y = alloca i32, align 4
  %l_x = alloca i32, align 4
  %l_y = alloca i32, align 4
  %start_x = alloca i32, align 4
  %start_y = alloca i32, align 4
  %start_addr = alloca i32, align 4
  %i = alloca i32, align 4
  %sum = alloca <4 x float>, align 16
  %temp = alloca [2 x <4 x float>], align 16
  %index = alloca [2 x i32], align 4
  %s_x = alloca i32, align 4
  %s_y = alloca i32, align 4
  store <4 x float>* %src, <4 x float>** %src.addr, align 4
  store <4 x float>* %dst, <4 x float>** %dst.addr, align 4
  store i32 %dst_cols, i32* %dst_cols.addr, align 4
  store i32 %dst_rows, i32* %dst_rows.addr, align 4
  store i32 %src_whole_cols, i32* %src_whole_cols.addr, align 4
  store i32 %src_whole_rows, i32* %src_whole_rows.addr, align 4
  store i32 %src_step_in_pixel, i32* %src_step_in_pixel.addr, align 4
  store i32 %src_offset_x, i32* %src_offset_x.addr, align 4
  store i32 %src_offset_y, i32* %src_offset_y.addr, align 4
  store i32 %dst_step_in_pixel, i32* %dst_step_in_pixel.addr, align 4
  store i32 %radiusy, i32* %radiusy.addr, align 4
  store float* %mat_kernel, float** %mat_kernel.addr, align 4
  %call = call i32 @get_global_id(i32 0)
  store i32 %call, i32* %x, align 4
  %call1 = call i32 @get_global_id(i32 1)
  store i32 %call1, i32* %y, align 4
  %call2 = call i32 @get_local_id(i32 0)
  store i32 %call2, i32* %l_x, align 4
  %call3 = call i32 @get_local_id(i32 1)
  store i32 %call3, i32* %l_y, align 4
  %0 = load i32* %x, align 4
  %1 = load i32* %src_offset_x.addr, align 4
  %add = add nsw i32 %0, %1
  %sub = sub nsw i32 %add, 2
  store i32 %sub, i32* %start_x, align 4
  %2 = load i32* %y, align 4
  %3 = load i32* %src_offset_y.addr, align 4
  %add4 = add nsw i32 %2, %3
  %4 = load i32* %radiusy.addr, align 4
  %sub5 = sub nsw i32 %add4, %4
  store i32 %sub5, i32* %start_y, align 4
  %5 = load i32* %start_y, align 4
  %6 = load i32* %src_step_in_pixel.addr, align 4
  %7 = load i32* %start_x, align 4
  %call6 = call i32 @_Z11_socl_mad24iii(i32 %5, i32 %6, i32 %7)
  store i32 %call6, i32* %start_addr, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %8 = load i32* %i, align 4
  %cmp = icmp slt i32 %8, 2
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %9 = load i32* %start_x, align 4
  %10 = load i32* %i, align 4
  %mul = mul nsw i32 %10, 16
  %add7 = add nsw i32 %9, %mul
  %cmp8 = icmp slt i32 %add7, 0
  br i1 %cmp8, label %cond.true, label %cond.false

cond.true:                                        ; preds = %for.body
  br label %cond.end

cond.false:                                       ; preds = %for.body
  %11 = load i32* %start_x, align 4
  %12 = load i32* %i, align 4
  %mul9 = mul nsw i32 %12, 16
  %add10 = add nsw i32 %11, %mul9
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i32 [ 0, %cond.true ], [ %add10, %cond.false ]
  store i32 %cond, i32* %s_x, align 4
  %13 = load i32* %start_x, align 4
  %14 = load i32* %i, align 4
  %mul11 = mul nsw i32 %14, 16
  %add12 = add nsw i32 %13, %mul11
  %15 = load i32* %src_whole_cols.addr, align 4
  %cmp13 = icmp sge i32 %add12, %15
  br i1 %cmp13, label %cond.true14, label %cond.false16

cond.true14:                                      ; preds = %cond.end
  %16 = load i32* %src_whole_cols.addr, align 4
  %sub15 = sub nsw i32 %16, 1
  br label %cond.end17

cond.false16:                                     ; preds = %cond.end
  %17 = load i32* %s_x, align 4
  br label %cond.end17

cond.end17:                                       ; preds = %cond.false16, %cond.true14
  %cond18 = phi i32 [ %sub15, %cond.true14 ], [ %17, %cond.false16 ]
  store i32 %cond18, i32* %s_x, align 4
  %18 = load i32* %start_y, align 4
  %cmp19 = icmp slt i32 %18, 0
  br i1 %cmp19, label %cond.true20, label %cond.false21

cond.true20:                                      ; preds = %cond.end17
  br label %cond.end22

cond.false21:                                     ; preds = %cond.end17
  %19 = load i32* %start_y, align 4
  br label %cond.end22

cond.end22:                                       ; preds = %cond.false21, %cond.true20
  %cond23 = phi i32 [ 0, %cond.true20 ], [ %19, %cond.false21 ]
  store i32 %cond23, i32* %s_y, align 4
  %20 = load i32* %start_y, align 4
  %21 = load i32* %src_whole_rows.addr, align 4
  %cmp24 = icmp sge i32 %20, %21
  br i1 %cmp24, label %cond.true25, label %cond.false27

cond.true25:                                      ; preds = %cond.end22
  %22 = load i32* %src_whole_rows.addr, align 4
  %sub26 = sub nsw i32 %22, 1
  br label %cond.end28

cond.false27:                                     ; preds = %cond.end22
  %23 = load i32* %s_y, align 4
  br label %cond.end28

cond.end28:                                       ; preds = %cond.false27, %cond.true25
  %cond29 = phi i32 [ %sub26, %cond.true25 ], [ %23, %cond.false27 ]
  store i32 %cond29, i32* %s_y, align 4
  %24 = load i32* %s_y, align 4
  %25 = load i32* %src_step_in_pixel.addr, align 4
  %26 = load i32* %s_x, align 4
  %call30 = call i32 @_Z11_socl_mad24iii(i32 %24, i32 %25, i32 %26)
  %27 = load i32* %i, align 4
  %arrayidx = getelementptr inbounds [2 x i32]* %index, i32 0, i32 %27
  store i32 %call30, i32* %arrayidx, align 4
  br label %for.inc

for.inc:                                          ; preds = %cond.end28
  %28 = load i32* %i, align 4
  %inc = add nsw i32 %28, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  store i32 0, i32* %i, align 4
  br label %for.cond31

for.cond31:                                       ; preds = %for.inc37, %for.end
  %29 = load i32* %i, align 4
  %cmp32 = icmp slt i32 %29, 2
  br i1 %cmp32, label %for.body33, label %for.end39

for.body33:                                       ; preds = %for.cond31
  %30 = load i32* %i, align 4
  %arrayidx34 = getelementptr inbounds [2 x i32]* %index, i32 0, i32 %30
  %31 = load i32* %arrayidx34, align 4
  %32 = load <4 x float>** %src.addr, align 4
  %arrayidx35 = getelementptr inbounds <4 x float>* %32, i32 %31
  %33 = load <4 x float>* %arrayidx35, align 16
  %34 = load i32* %i, align 4
  %arrayidx36 = getelementptr inbounds [2 x <4 x float>]* %temp, i32 0, i32 %34
  store <4 x float> %33, <4 x float>* %arrayidx36, align 16
  br label %for.inc37

for.inc37:                                        ; preds = %for.body33
  %35 = load i32* %i, align 4
  %inc38 = add nsw i32 %35, 1
  store i32 %inc38, i32* %i, align 4
  br label %for.cond31

for.end39:                                        ; preds = %for.cond31
  store i32 0, i32* %i, align 4
  br label %for.cond40

for.cond40:                                       ; preds = %for.inc48, %for.end39
  %36 = load i32* %i, align 4
  %cmp41 = icmp slt i32 %36, 2
  br i1 %cmp41, label %for.body42, label %for.end50

for.body42:                                       ; preds = %for.cond40
  %37 = load i32* %i, align 4
  %arrayidx43 = getelementptr inbounds [2 x <4 x float>]* %temp, i32 0, i32 %37
  %38 = load <4 x float>* %arrayidx43, align 16
  %39 = load i32* %l_x, align 4
  %40 = load i32* %i, align 4
  %mul44 = mul nsw i32 %40, 16
  %add45 = add nsw i32 %39, %mul44
  %41 = load i32* %l_y, align 4
  %arrayidx46 = getelementptr inbounds [16 x [33 x <4 x float>]]* @row_filter_C4_D5.LDS_DAT, i32 0, i32 %41
  %arrayidx47 = getelementptr inbounds [33 x <4 x float>]* %arrayidx46, i32 0, i32 %add45
  store <4 x float> %38, <4 x float>* %arrayidx47, align 16
  br label %for.inc48

for.inc48:                                        ; preds = %for.body42
  %42 = load i32* %i, align 4
  %inc49 = add nsw i32 %42, 1
  store i32 %inc49, i32* %i, align 4
  br label %for.cond40

for.end50:                                        ; preds = %for.cond40
  call void @barrier(i32 1)
  %43 = load i32* %l_x, align 4
  %add51 = add nsw i32 %43, 2
  %44 = load i32* %l_y, align 4
  %arrayidx52 = getelementptr inbounds [16 x [33 x <4 x float>]]* @row_filter_C4_D5.LDS_DAT, i32 0, i32 %44
  %arrayidx53 = getelementptr inbounds [33 x <4 x float>]* %arrayidx52, i32 0, i32 %add51
  %45 = load <4 x float>* %arrayidx53, align 16
  %46 = load float** %mat_kernel.addr, align 4
  %arrayidx54 = getelementptr inbounds float* %46, i32 2
  %47 = load float* %arrayidx54, align 4
  %splat.splatinsert = insertelement <4 x float> undef, float %47, i32 0
  %splat.splat = shufflevector <4 x float> %splat.splatinsert, <4 x float> undef, <4 x i32> zeroinitializer
  %mul55 = fmul <4 x float> %45, %splat.splat
  store <4 x float> %mul55, <4 x float>* %sum, align 16
  store i32 1, i32* %i, align 4
  br label %for.cond56

for.cond56:                                       ; preds = %for.inc82, %for.end50
  %48 = load i32* %i, align 4
  %cmp57 = icmp sle i32 %48, 2
  br i1 %cmp57, label %for.body58, label %for.end84

for.body58:                                       ; preds = %for.cond56
  %49 = load i32* %l_x, align 4
  %add59 = add nsw i32 %49, 2
  %50 = load i32* %i, align 4
  %sub60 = sub nsw i32 %add59, %50
  %51 = load i32* %l_y, align 4
  %arrayidx61 = getelementptr inbounds [16 x [33 x <4 x float>]]* @row_filter_C4_D5.LDS_DAT, i32 0, i32 %51
  %arrayidx62 = getelementptr inbounds [33 x <4 x float>]* %arrayidx61, i32 0, i32 %sub60
  %52 = load <4 x float>* %arrayidx62, align 16
  %arrayidx63 = getelementptr inbounds [2 x <4 x float>]* %temp, i32 0, i32 0
  store <4 x float> %52, <4 x float>* %arrayidx63, align 16
  %53 = load i32* %l_x, align 4
  %add64 = add nsw i32 %53, 2
  %54 = load i32* %i, align 4
  %add65 = add nsw i32 %add64, %54
  %55 = load i32* %l_y, align 4
  %arrayidx66 = getelementptr inbounds [16 x [33 x <4 x float>]]* @row_filter_C4_D5.LDS_DAT, i32 0, i32 %55
  %arrayidx67 = getelementptr inbounds [33 x <4 x float>]* %arrayidx66, i32 0, i32 %add65
  %56 = load <4 x float>* %arrayidx67, align 16
  %arrayidx68 = getelementptr inbounds [2 x <4 x float>]* %temp, i32 0, i32 1
  store <4 x float> %56, <4 x float>* %arrayidx68, align 16
  %arrayidx69 = getelementptr inbounds [2 x <4 x float>]* %temp, i32 0, i32 0
  %57 = load <4 x float>* %arrayidx69, align 16
  %58 = load i32* %i, align 4
  %sub70 = sub nsw i32 2, %58
  %59 = load float** %mat_kernel.addr, align 4
  %arrayidx71 = getelementptr inbounds float* %59, i32 %sub70
  %60 = load float* %arrayidx71, align 4
  %splat.splatinsert72 = insertelement <4 x float> undef, float %60, i32 0
  %splat.splat73 = shufflevector <4 x float> %splat.splatinsert72, <4 x float> undef, <4 x i32> zeroinitializer
  %arrayidx75 = getelementptr inbounds [2 x <4 x float>]* %temp, i32 0, i32 1
  %61 = load <4 x float>* %arrayidx75, align 16
  %62 = load i32* %i, align 4
  %add76 = add nsw i32 2, %62
  %63 = load float** %mat_kernel.addr, align 4
  %arrayidx77 = getelementptr inbounds float* %63, i32 %add76
  %64 = load float* %arrayidx77, align 4
  %splat.splatinsert78 = insertelement <4 x float> undef, float %64, i32 0
  %splat.splat79 = shufflevector <4 x float> %splat.splatinsert78, <4 x float> undef, <4 x i32> zeroinitializer
  %mul80 = fmul <4 x float> %61, %splat.splat79
  %65 = call <4 x float> @llvm.fmuladd.v4f32(<4 x float> %57, <4 x float> %splat.splat73, <4 x float> %mul80)
  %66 = load <4 x float>* %sum, align 16
  %add81 = fadd <4 x float> %66, %65
  store <4 x float> %add81, <4 x float>* %sum, align 16
  br label %for.inc82

for.inc82:                                        ; preds = %for.body58
  %67 = load i32* %i, align 4
  %inc83 = add nsw i32 %67, 1
  store i32 %inc83, i32* %i, align 4
  br label %for.cond56

for.end84:                                        ; preds = %for.cond56
  %68 = load i32* %x, align 4
  %69 = load i32* %dst_cols.addr, align 4
  %cmp85 = icmp slt i32 %68, %69
  %conv = zext i1 %cmp85 to i32
  %70 = load i32* %y, align 4
  %71 = load i32* %dst_rows.addr, align 4
  %cmp86 = icmp slt i32 %70, %71
  %conv87 = zext i1 %cmp86 to i32
  %and = and i32 %conv, %conv87
  %tobool = icmp ne i32 %and, 0
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %for.end84
  %72 = load i32* %y, align 4
  %73 = load i32* %dst_step_in_pixel.addr, align 4
  %74 = load i32* %x, align 4
  %call88 = call i32 @_Z11_socl_mad24iii(i32 %72, i32 %73, i32 %74)
  store i32 %call88, i32* %start_addr, align 4
  %75 = load <4 x float>* %sum, align 16
  %76 = load i32* %start_addr, align 4
  %77 = load <4 x float>** %dst.addr, align 4
  %arrayidx89 = getelementptr inbounds <4 x float>* %77, i32 %76
  store <4 x float> %75, <4 x float>* %arrayidx89, align 16
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
