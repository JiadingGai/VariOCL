; ModuleID = '<stdin>'
target datalayout = "e-p:32:32:32-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:64:128-a0:0:64-n32-S64"
target triple = "armv7--linux-androideabi"

; Function Attrs: noinline nounwind
define void @row_filter_C1_D0(i8* noalias %src, float* %dst, i32 %dst_cols, i32 %dst_rows, i32 %src_whole_cols, i32 %src_whole_rows, i32 %src_step_in_pixel, i32 %src_offset_x, i32 %src_offset_y, i32 %dst_step_in_pixel, i32 %radiusy, float* %mat_kernel) #0 {
entry.barrier:
  %get_local_size16 = call i32 @get_local_size(i32 0)
  %get_local_size17 = call i32 @get_local_size(i32 1)
  %get_local_size18 = call i32 @get_local_size(i32 2)
  %get_local_size = call i32 @get_local_size(i32 0)
  %get_group_id = call i32 @get_group_id(i32 0)
  %get_global_offset = call i32 @get_global_offset(i32 0)
  %get_local_size12 = call i32 @get_local_size(i32 1)
  %get_group_id13 = call i32 @get_group_id(i32 1)
  %get_global_offset15 = call i32 @get_global_offset(i32 1)
  %get_local_size45 = call i32 @get_local_size(i32 0)
  %get_local_size54 = call i32 @get_local_size(i32 1)
  %get_local_size63 = call i32 @get_local_size(i32 2)
  %get_local_size26 = call i32 @get_local_size(i32 0)
  %get_local_size31 = call i32 @get_local_size(i32 1)
  %get_local_size37 = call i32 @get_local_size(i32 2)
  %localmem.LDS_DAT = alloca [16 x [33 x <4 x i8>]], align 4
  %0 = mul i32 %get_local_size18, %get_local_size17
  %Flat3DSize = mul i32 %0, %get_local_size16
  %sum.0.ex_phi.gaispill = alloca <4 x float>, i32 %Flat3DSize, align 64
  %i.4.ex_phi.gaispill = alloca i32, i32 %Flat3DSize, align 64
  %i.3.ex_phi.gaispill = alloca i32, i32 %Flat3DSize, align 64
  %i.2.ex_phi.gaispill = alloca i32, i32 %Flat3DSize, align 64
  %i.1.ex_phi.gaispill = alloca i32, i32 %Flat3DSize, align 64
  %cond122.ex_phi.gaispill = alloca i32, i32 %Flat3DSize, align 64
  %cond94.ex_phi.gaispill = alloca i32, i32 %Flat3DSize, align 64
  %cond66.ex_phi.gaispill = alloca i32, i32 %Flat3DSize, align 64
  %cond38.ex_phi.gaispill = alloca i32, i32 %Flat3DSize, align 64
  %i.0.ex_phi.gaispill = alloca i32, i32 %Flat3DSize, align 64
  %temp.gaispill = alloca [2 x <4 x i8>], i32 %Flat3DSize, align 64
  %index.gaispill = alloca [2 x <4 x i32>], i32 %Flat3DSize, align 64
  %shl.gaispill = alloca i32, i32 %Flat3DSize, align 64
  %.gaispill = alloca i32, i32 %Flat3DSize, align 64
  %call2.gaispill = alloca i32, i32 %Flat3DSize, align 64
  %call3.gaispill = alloca i32, i32 %Flat3DSize, align 64
  %and5.gaispill = alloca i32, i32 %Flat3DSize, align 64
  br label %mxpa.lp.body58

mxpa.lp.body58:                                   ; preds = %entry.barrier, %mxpa.latch57
  %IV262 = phi i32 [ 0, %entry.barrier ], [ %IV2_inc64, %mxpa.latch57 ]
  br label %mxpa.lp.body49

mxpa.lp.body49:                                   ; preds = %mxpa.lp.body58, %mxpa.latch48
  %IV153 = phi i32 [ 0, %mxpa.lp.body58 ], [ %IV1_inc55, %mxpa.latch48 ]
  br label %mxpa.lp.body40

mxpa.lp.body40:                                   ; preds = %mxpa.lp.body49, %mxpa.latch39
  %IV044 = phi i32 [ 0, %mxpa.lp.body49 ], [ %IV0_inc46, %mxpa.latch39 ]
  %1 = mul i32 %IV153, %get_local_size16
  %2 = mul i32 %IV262, %get_local_size16
  %3 = mul i32 %2, %get_local_size17
  %4 = add i32 %3, %1
  %FlatIdx25 = add i32 %4, %IV044
  %5 = mul i32 %get_local_size, %get_group_id
  %6 = add i32 %5, %IV044
  %7 = add i32 %6, %get_global_offset
  %shl = shl i32 %7, 2
  %8 = getelementptr i32* %shl.gaispill, i32 %FlatIdx25
  store i32 %shl, i32* %8
  %9 = mul i32 %get_local_size12, %get_group_id13
  %10 = add i32 %9, %IV153
  %11 = add i32 %10, %get_global_offset15
  %12 = getelementptr i32* %.gaispill, i32 %FlatIdx25
  store i32 %11, i32* %12
  %13 = getelementptr i32* %call2.gaispill, i32 %FlatIdx25
  store i32 %IV044, i32* %13
  %14 = getelementptr i32* %call3.gaispill, i32 %FlatIdx25
  store i32 %IV153, i32* %14
  %15 = getelementptr i32* %shl.gaispill, i32 %FlatIdx25
  %16 = load i32* %15
  %add = add nsw i32 %16, %src_offset_x
  %sub = add nsw i32 %add, -2
  %and = and i32 %sub, -4
  %sub4 = add nsw i32 %src_offset_x, 2
  %and5 = and i32 %sub4, 3
  %17 = getelementptr i32* %and5.gaispill, i32 %FlatIdx25
  store i32 %and5, i32* %17
  %18 = getelementptr i32* %.gaispill, i32 %FlatIdx25
  %19 = load i32* %18
  %add6 = add nsw i32 %19, %src_offset_y
  %sub7 = sub nsw i32 %add6, %radiusy
  %call8 = call i32 @_Z11_socl_mad24iii(i32 %sub7, i32 %src_step_in_pixel, i32 %and) #3
  %and.lobit = lshr i32 %sub, 31
  %add10 = add nsw i32 %and, 132
  %cmp11 = icmp sgt i32 %add10, %src_whole_cols
  %conv12 = zext i1 %cmp11 to i32
  %or = or i32 %and.lobit, %conv12
  %sub7.lobit = lshr i32 %sub7, 31
  %or15 = or i32 %or, %sub7.lobit
  %cmp16 = icmp sge i32 %sub7, %src_whole_rows
  %conv17 = zext i1 %cmp16 to i32
  %or18 = or i32 %or15, %conv17
  %tobool = icmp eq i32 %or18, 0
  br i1 %tobool, label %for.cond156.preheader, label %for.cond.preheader

for.cond156.preheader:                            ; preds = %mxpa.lp.body40
  %20 = getelementptr i32* %i.2.ex_phi.gaispill, i32 %FlatIdx25
  store i32 0, i32* %20
  %21 = getelementptr i32* %i.2.ex_phi.gaispill, i32 %FlatIdx25
  br label %for.cond156.r_entry

for.cond.preheader:                               ; preds = %mxpa.lp.body40
  %22 = getelementptr i32* %i.0.ex_phi.gaispill, i32 %FlatIdx25
  store i32 0, i32* %22
  %23 = getelementptr i32* %i.0.ex_phi.gaispill, i32 %FlatIdx25
  br label %for.cond.r_entry

for.cond.r_entry:                                 ; preds = %for.cond.preheader, %cond.end121
  %24 = load i32* %23
  %cmp19 = icmp slt i32 %24, 2
  br i1 %cmp19, label %for.body.r_entry, label %for.end

for.body.r_entry:                                 ; preds = %for.cond.r_entry
  %mul21 = shl i32 %24, 6
  %add22 = add nsw i32 %and, %mul21
  %cmp23 = icmp slt i32 %add22, 0
  %cond = select i1 %cmp23, i32 0, i32 %add22
  %25 = getelementptr [2 x <4 x i32>]* %index.gaispill, i32 %FlatIdx25
  %arrayidx = getelementptr inbounds [2 x <4 x i32>]* %25, i32 0, i32 %24
  %26 = load <4 x i32>* %arrayidx, align 16
  %27 = insertelement <4 x i32> %26, i32 %cond, i32 0
  store <4 x i32> %27, <4 x i32>* %arrayidx, align 16
  %mul29 = shl i32 %24, 6
  %add30 = add nsw i32 %and, %mul29
  %cmp31 = icmp slt i32 %add30, %src_whole_cols
  br i1 %cmp31, label %cond.false35, label %cond.true33

cond.true33:                                      ; preds = %for.body.r_entry
  %sub34 = add nsw i32 %src_whole_cols, -1
  %28 = getelementptr i32* %cond38.ex_phi.gaispill, i32 %FlatIdx25
  store i32 %sub34, i32* %28
  br label %cond.end37.r_entry

cond.false35:                                     ; preds = %for.body.r_entry
  %29 = getelementptr [2 x <4 x i32>]* %index.gaispill, i32 %FlatIdx25
  %arrayidx36 = getelementptr inbounds [2 x <4 x i32>]* %29, i32 0, i32 %24
  %30 = load <4 x i32>* %arrayidx36, align 16
  %31 = extractelement <4 x i32> %30, i32 0
  %32 = getelementptr i32* %cond38.ex_phi.gaispill, i32 %FlatIdx25
  store i32 %31, i32* %32
  br label %cond.end37.r_entry

cond.end37.r_entry:                               ; preds = %cond.false35, %cond.true33
  %33 = getelementptr i32* %cond38.ex_phi.gaispill, i32 %FlatIdx25
  %34 = load i32* %33
  %35 = getelementptr [2 x <4 x i32>]* %index.gaispill, i32 %FlatIdx25
  %arrayidx39 = getelementptr inbounds [2 x <4 x i32>]* %35, i32 0, i32 %24
  %36 = load <4 x i32>* %arrayidx39, align 16
  %37 = insertelement <4 x i32> %36, i32 %34, i32 0
  store <4 x i32> %37, <4 x i32>* %arrayidx39, align 16
  %mul41 = shl i32 %24, 6
  %add42 = add nsw i32 %and, %mul41
  %add43 = or i32 %add42, 1
  %cmp44 = icmp slt i32 %add43, 0
  %cond53 = select i1 %cmp44, i32 0, i32 %add43
  %38 = getelementptr [2 x <4 x i32>]* %index.gaispill, i32 %FlatIdx25
  %arrayidx54 = getelementptr inbounds [2 x <4 x i32>]* %38, i32 0, i32 %24
  %39 = load <4 x i32>* %arrayidx54, align 16
  %40 = insertelement <4 x i32> %39, i32 %cond53, i32 1
  store <4 x i32> %40, <4 x i32>* %arrayidx54, align 16
  %mul56 = shl i32 %24, 6
  %add57 = add nsw i32 %and, %mul56
  %add58 = or i32 %add57, 1
  %cmp59 = icmp slt i32 %add58, %src_whole_cols
  br i1 %cmp59, label %cond.false63, label %cond.true61

cond.true61:                                      ; preds = %cond.end37.r_entry
  %sub62 = add nsw i32 %src_whole_cols, -1
  %41 = getelementptr i32* %cond66.ex_phi.gaispill, i32 %FlatIdx25
  store i32 %sub62, i32* %41
  br label %cond.end65.r_entry

cond.false63:                                     ; preds = %cond.end37.r_entry
  %42 = getelementptr [2 x <4 x i32>]* %index.gaispill, i32 %FlatIdx25
  %arrayidx64 = getelementptr inbounds [2 x <4 x i32>]* %42, i32 0, i32 %24
  %43 = load <4 x i32>* %arrayidx64, align 16
  %44 = extractelement <4 x i32> %43, i32 1
  %45 = getelementptr i32* %cond66.ex_phi.gaispill, i32 %FlatIdx25
  store i32 %44, i32* %45
  br label %cond.end65.r_entry

cond.end65.r_entry:                               ; preds = %cond.false63, %cond.true61
  %46 = getelementptr i32* %cond66.ex_phi.gaispill, i32 %FlatIdx25
  %47 = load i32* %46
  %48 = getelementptr [2 x <4 x i32>]* %index.gaispill, i32 %FlatIdx25
  %arrayidx67 = getelementptr inbounds [2 x <4 x i32>]* %48, i32 0, i32 %24
  %49 = load <4 x i32>* %arrayidx67, align 16
  %50 = insertelement <4 x i32> %49, i32 %47, i32 1
  store <4 x i32> %50, <4 x i32>* %arrayidx67, align 16
  %mul69 = shl i32 %24, 6
  %add70 = add nsw i32 %and, %mul69
  %add71 = or i32 %add70, 2
  %cmp72 = icmp slt i32 %add71, 0
  %cond81 = select i1 %cmp72, i32 0, i32 %add71
  %51 = getelementptr [2 x <4 x i32>]* %index.gaispill, i32 %FlatIdx25
  %arrayidx82 = getelementptr inbounds [2 x <4 x i32>]* %51, i32 0, i32 %24
  %52 = load <4 x i32>* %arrayidx82, align 16
  %53 = insertelement <4 x i32> %52, i32 %cond81, i32 2
  store <4 x i32> %53, <4 x i32>* %arrayidx82, align 16
  %mul84 = shl i32 %24, 6
  %add85 = add nsw i32 %and, %mul84
  %add86 = or i32 %add85, 2
  %cmp87 = icmp slt i32 %add86, %src_whole_cols
  br i1 %cmp87, label %cond.false91, label %cond.true89

cond.true89:                                      ; preds = %cond.end65.r_entry
  %sub90 = add nsw i32 %src_whole_cols, -1
  %54 = getelementptr i32* %cond94.ex_phi.gaispill, i32 %FlatIdx25
  store i32 %sub90, i32* %54
  br label %cond.end93.r_entry

cond.false91:                                     ; preds = %cond.end65.r_entry
  %55 = getelementptr [2 x <4 x i32>]* %index.gaispill, i32 %FlatIdx25
  %arrayidx92 = getelementptr inbounds [2 x <4 x i32>]* %55, i32 0, i32 %24
  %56 = load <4 x i32>* %arrayidx92, align 16
  %57 = extractelement <4 x i32> %56, i32 2
  %58 = getelementptr i32* %cond94.ex_phi.gaispill, i32 %FlatIdx25
  store i32 %57, i32* %58
  br label %cond.end93.r_entry

cond.end93.r_entry:                               ; preds = %cond.false91, %cond.true89
  %59 = getelementptr i32* %cond94.ex_phi.gaispill, i32 %FlatIdx25
  %60 = load i32* %59
  %61 = getelementptr [2 x <4 x i32>]* %index.gaispill, i32 %FlatIdx25
  %arrayidx95 = getelementptr inbounds [2 x <4 x i32>]* %61, i32 0, i32 %24
  %62 = load <4 x i32>* %arrayidx95, align 16
  %63 = insertelement <4 x i32> %62, i32 %60, i32 2
  store <4 x i32> %63, <4 x i32>* %arrayidx95, align 16
  %mul97 = shl i32 %24, 6
  %add98 = add nsw i32 %and, %mul97
  %add99 = or i32 %add98, 3
  %cmp100 = icmp slt i32 %add99, 0
  %cond109 = select i1 %cmp100, i32 0, i32 %add99
  %64 = getelementptr [2 x <4 x i32>]* %index.gaispill, i32 %FlatIdx25
  %arrayidx110 = getelementptr inbounds [2 x <4 x i32>]* %64, i32 0, i32 %24
  %65 = load <4 x i32>* %arrayidx110, align 16
  %66 = insertelement <4 x i32> %65, i32 %cond109, i32 3
  store <4 x i32> %66, <4 x i32>* %arrayidx110, align 16
  %mul112 = shl i32 %24, 6
  %add113 = add nsw i32 %and, %mul112
  %add114 = or i32 %add113, 3
  %cmp115 = icmp slt i32 %add114, %src_whole_cols
  br i1 %cmp115, label %cond.false119, label %cond.true117

cond.true117:                                     ; preds = %cond.end93.r_entry
  %sub118 = add nsw i32 %src_whole_cols, -1
  %67 = getelementptr i32* %cond122.ex_phi.gaispill, i32 %FlatIdx25
  store i32 %sub118, i32* %67
  br label %cond.end121

cond.false119:                                    ; preds = %cond.end93.r_entry
  %68 = getelementptr [2 x <4 x i32>]* %index.gaispill, i32 %FlatIdx25
  %arrayidx120 = getelementptr inbounds [2 x <4 x i32>]* %68, i32 0, i32 %24
  %69 = load <4 x i32>* %arrayidx120, align 16
  %70 = extractelement <4 x i32> %69, i32 3
  %71 = getelementptr i32* %cond122.ex_phi.gaispill, i32 %FlatIdx25
  store i32 %70, i32* %71
  br label %cond.end121

cond.end121:                                      ; preds = %cond.true117, %cond.false119
  %72 = getelementptr i32* %cond122.ex_phi.gaispill, i32 %FlatIdx25
  %73 = load i32* %72
  %74 = getelementptr [2 x <4 x i32>]* %index.gaispill, i32 %FlatIdx25
  %arrayidx123 = getelementptr inbounds [2 x <4 x i32>]* %74, i32 0, i32 %24
  %75 = load <4 x i32>* %arrayidx123, align 16
  %76 = insertelement <4 x i32> %75, i32 %73, i32 3
  store <4 x i32> %76, <4 x i32>* %arrayidx123, align 16
  %inc = add nsw i32 %24, 1
  %77 = getelementptr i32* %i.0.ex_phi.gaispill, i32 %FlatIdx25
  store i32 %inc, i32* %77
  br label %for.cond.r_entry

for.end:                                          ; preds = %for.cond.r_entry
  %cmp124 = icmp slt i32 %sub7, 0
  %.sub7 = select i1 %cmp124, i32 0, i32 %sub7
  %cmp130 = icmp sge i32 %sub7, %src_whole_rows
  %sub133 = add nsw i32 %src_whole_rows, -1
  %cond136 = select i1 %cmp130, i32 %sub133, i32 %.sub7
  %78 = getelementptr i32* %i.1.ex_phi.gaispill, i32 %FlatIdx25
  store i32 0, i32* %78
  %79 = getelementptr i32* %i.1.ex_phi.gaispill, i32 %FlatIdx25
  br label %for.cond137.r_entry

for.cond137.r_entry:                              ; preds = %for.end, %for.body140
  %80 = load i32* %79
  %cmp138 = icmp slt i32 %80, 2
  br i1 %cmp138, label %for.body140, label %for.cond168.preheader

for.cond168.preheader:                            ; preds = %for.cond137.r_entry, %for.cond156.r_entry
  %81 = getelementptr i32* %i.3.ex_phi.gaispill, i32 %FlatIdx25
  store i32 0, i32* %81
  %82 = getelementptr i32* %i.3.ex_phi.gaispill, i32 %FlatIdx25
  br label %for.cond168.r_entry

for.body140:                                      ; preds = %for.cond137.r_entry
  %splat.splatinsert = insertelement <4 x i32> undef, i32 %cond136, i32 0
  %splat.splat = shufflevector <4 x i32> %splat.splatinsert, <4 x i32> undef, <4 x i32> zeroinitializer
  %splat.splatinsert141 = insertelement <4 x i32> undef, i32 %src_step_in_pixel, i32 0
  %splat.splat142 = shufflevector <4 x i32> %splat.splatinsert141, <4 x i32> undef, <4 x i32> zeroinitializer
  %83 = getelementptr [2 x <4 x i32>]* %index.gaispill, i32 %FlatIdx25
  %arrayidx143 = getelementptr inbounds [2 x <4 x i32>]* %83, i32 0, i32 %80
  %84 = load <4 x i32>* %arrayidx143, align 16
  %call144 = call <4 x i32> @_Z11_socl_mad24Dv4_iS_S_(<4 x i32> %splat.splat, <4 x i32> %splat.splat142, <4 x i32> %84) #3
  %85 = extractelement <4 x i32> %call144, i32 0
  %arrayidx145 = getelementptr inbounds i8* %src, i32 %85
  %86 = load i8* %arrayidx145, align 1
  %87 = getelementptr [2 x <4 x i8>]* %temp.gaispill, i32 %FlatIdx25
  %arrayidx146 = getelementptr inbounds [2 x <4 x i8>]* %87, i32 0, i32 %80
  %88 = load <4 x i8>* %arrayidx146, align 4
  %89 = insertelement <4 x i8> %88, i8 %86, i32 0
  store <4 x i8> %89, <4 x i8>* %arrayidx146, align 4
  %90 = extractelement <4 x i32> %call144, i32 1
  %arrayidx147 = getelementptr inbounds i8* %src, i32 %90
  %91 = load i8* %arrayidx147, align 1
  %92 = getelementptr [2 x <4 x i8>]* %temp.gaispill, i32 %FlatIdx25
  %arrayidx148 = getelementptr inbounds [2 x <4 x i8>]* %92, i32 0, i32 %80
  %93 = insertelement <4 x i8> %89, i8 %91, i32 1
  store <4 x i8> %93, <4 x i8>* %arrayidx148, align 4
  %94 = extractelement <4 x i32> %call144, i32 2
  %arrayidx149 = getelementptr inbounds i8* %src, i32 %94
  %95 = load i8* %arrayidx149, align 1
  %96 = getelementptr [2 x <4 x i8>]* %temp.gaispill, i32 %FlatIdx25
  %arrayidx150 = getelementptr inbounds [2 x <4 x i8>]* %96, i32 0, i32 %80
  %97 = insertelement <4 x i8> %93, i8 %95, i32 2
  store <4 x i8> %97, <4 x i8>* %arrayidx150, align 4
  %98 = extractelement <4 x i32> %call144, i32 3
  %arrayidx151 = getelementptr inbounds i8* %src, i32 %98
  %99 = load i8* %arrayidx151, align 1
  %100 = getelementptr [2 x <4 x i8>]* %temp.gaispill, i32 %FlatIdx25
  %arrayidx152 = getelementptr inbounds [2 x <4 x i8>]* %100, i32 0, i32 %80
  %101 = insertelement <4 x i8> %97, i8 %99, i32 3
  store <4 x i8> %101, <4 x i8>* %arrayidx152, align 4
  %inc154 = add nsw i32 %80, 1
  %102 = getelementptr i32* %i.1.ex_phi.gaispill, i32 %FlatIdx25
  store i32 %inc154, i32* %102
  br label %for.cond137.r_entry

for.cond156.r_entry:                              ; preds = %for.cond156.preheader, %for.body159
  %103 = load i32* %21
  %cmp157 = icmp slt i32 %103, 2
  br i1 %cmp157, label %for.body159, label %for.cond168.preheader

for.body159:                                      ; preds = %for.cond156.r_entry
  %mul161 = shl i32 %103, 6
  %add162 = add nsw i32 %call8, %mul161
  %arrayidx163 = getelementptr inbounds i8* %src, i32 %add162
  %104 = bitcast i8* %arrayidx163 to <4 x i8>*
  %105 = load <4 x i8>* %104, align 4
  %106 = getelementptr [2 x <4 x i8>]* %temp.gaispill, i32 %FlatIdx25
  %arrayidx164 = getelementptr inbounds [2 x <4 x i8>]* %106, i32 0, i32 %103
  store <4 x i8> %105, <4 x i8>* %arrayidx164, align 4
  %inc166 = add nsw i32 %103, 1
  %107 = getelementptr i32* %i.2.ex_phi.gaispill, i32 %FlatIdx25
  store i32 %inc166, i32* %107
  br label %for.cond156.r_entry

for.cond168.r_entry:                              ; preds = %for.cond168.preheader, %for.body171
  %108 = load i32* %82
  %cmp169 = icmp slt i32 %108, 2
  br i1 %cmp169, label %for.body171, label %mxpa.latch39

for.body171:                                      ; preds = %for.cond168.r_entry
  %109 = getelementptr [2 x <4 x i8>]* %temp.gaispill, i32 %FlatIdx25
  %arrayidx172 = getelementptr inbounds [2 x <4 x i8>]* %109, i32 0, i32 %108
  %110 = load <4 x i8>* %arrayidx172, align 4
  %mul173 = shl nsw i32 %108, 4
  %111 = getelementptr i32* %call2.gaispill, i32 %FlatIdx25
  %112 = load i32* %111
  %add174 = add nsw i32 %112, %mul173
  %113 = getelementptr i32* %call3.gaispill, i32 %FlatIdx25
  %114 = load i32* %113
  %arrayidx176 = getelementptr inbounds [16 x [33 x <4 x i8>]]* %localmem.LDS_DAT, i32 0, i32 %114, i32 %add174
  store <4 x i8> %110, <4 x i8>* %arrayidx176, align 4
  %inc178 = add nsw i32 %108, 1
  %115 = getelementptr i32* %i.3.ex_phi.gaispill, i32 %FlatIdx25
  store i32 %inc178, i32* %115
  br label %for.cond168.r_entry

mxpa.latch39:                                     ; preds = %for.cond168.r_entry
  %IV0_inc46 = add i32 %IV044, 1
  %CmpResult47 = icmp ult i32 %IV0_inc46, %get_local_size45
  br i1 %CmpResult47, label %mxpa.lp.body40, label %mxpa.latch48

mxpa.latch48:                                     ; preds = %mxpa.latch39
  %IV1_inc55 = add i32 %IV153, 1
  %CmpResult56 = icmp ult i32 %IV1_inc55, %get_local_size54
  br i1 %CmpResult56, label %mxpa.lp.body49, label %mxpa.latch57

mxpa.latch57:                                     ; preds = %mxpa.latch48
  %IV2_inc64 = add i32 %IV262, 1
  %CmpResult65 = icmp ult i32 %IV2_inc64, %get_local_size63
  br i1 %CmpResult65, label %mxpa.lp.body58, label %mxpa.lp.body34

mxpa.lp.body34:                                   ; preds = %mxpa.latch33, %mxpa.latch57
  %IV2 = phi i32 [ %IV2_inc, %mxpa.latch33 ], [ 0, %mxpa.latch57 ]
  br label %mxpa.lp.body28

mxpa.lp.body28:                                   ; preds = %mxpa.lp.body34, %mxpa.latch27
  %IV1 = phi i32 [ 0, %mxpa.lp.body34 ], [ %IV1_inc, %mxpa.latch27 ]
  br label %mxpa.lp.body

mxpa.lp.body:                                     ; preds = %mxpa.lp.body28, %mxpa.latch
  %IV0 = phi i32 [ 0, %mxpa.lp.body28 ], [ %IV0_inc, %mxpa.latch ]
  %116 = mul i32 %IV1, %get_local_size16
  %117 = mul i32 %IV2, %get_local_size16
  %118 = mul i32 %117, %get_local_size17
  %119 = add i32 %118, %116
  %FlatIdx = add i32 %119, %IV0
  %120 = getelementptr i32* %and5.gaispill, i32 %FlatIdx
  %121 = load i32* %120
  %add.ptr.sum = add i32 %121, 2
  %122 = getelementptr i32* %call2.gaispill, i32 %FlatIdx
  %123 = load i32* %122
  %124 = getelementptr i32* %call3.gaispill, i32 %FlatIdx
  %125 = load i32* %124
  %add.ptr182 = getelementptr inbounds [16 x [33 x <4 x i8>]]* %localmem.LDS_DAT, i32 0, i32 %125, i32 %123, i32 %add.ptr.sum
  %call183 = call <4 x i8> @_Z12_socl_vload4jPKU3AS0h(i32 0, i8* %add.ptr182) #3
  %126 = bitcast <4 x i8> %call183 to i32
  %call184 = call <4 x float> @_Z20_socl_convert_float4Dv4_h(i32 %126) #3
  %arrayidx185 = getelementptr inbounds float* %mat_kernel, i32 2
  %127 = load float* %arrayidx185, align 4
  %splat.splatinsert186 = insertelement <4 x float> undef, float %127, i32 0
  %splat.splat187 = shufflevector <4 x float> %splat.splatinsert186, <4 x float> undef, <4 x i32> zeroinitializer
  %mul188 = fmul <4 x float> %call184, %splat.splat187
  %128 = getelementptr i32* %i.4.ex_phi.gaispill, i32 %FlatIdx
  store i32 1, i32* %128
  %129 = getelementptr <4 x float>* %sum.0.ex_phi.gaispill, i32 %FlatIdx
  store <4 x float> %mul188, <4 x float>* %129
  %130 = getelementptr i32* %i.4.ex_phi.gaispill, i32 %FlatIdx
  br label %for.cond189.r_entry

for.cond189.r_entry:                              ; preds = %mxpa.lp.body, %for.body192
  %131 = load i32* %130
  %132 = getelementptr <4 x float>* %sum.0.ex_phi.gaispill, i32 %FlatIdx
  %133 = load <4 x float>* %132
  %cmp190 = icmp slt i32 %131, 3
  br i1 %cmp190, label %for.body192, label %for.end226.r_entry

for.body192:                                      ; preds = %for.cond189.r_entry
  %134 = getelementptr i32* %and5.gaispill, i32 %FlatIdx
  %135 = load i32* %134
  %add.ptr195.sum = add i32 %135, 2
  %add.ptr196.sum = sub i32 %add.ptr195.sum, %131
  %136 = getelementptr i32* %call2.gaispill, i32 %FlatIdx
  %137 = load i32* %136
  %138 = getelementptr i32* %call3.gaispill, i32 %FlatIdx
  %139 = load i32* %138
  %add.ptr197 = getelementptr inbounds [16 x [33 x <4 x i8>]]* %localmem.LDS_DAT, i32 0, i32 %139, i32 %137, i32 %add.ptr196.sum
  %call198 = call <4 x i8> @_Z12_socl_vload4jPKU3AS0h(i32 0, i8* %add.ptr197) #3
  %140 = getelementptr [2 x <4 x i8>]* %temp.gaispill, i32 %FlatIdx
  %arrayidx199 = getelementptr inbounds [2 x <4 x i8>]* %140, i32 0, i32 0
  store <4 x i8> %call198, <4 x i8>* %arrayidx199, align 4
  %141 = getelementptr i32* %and5.gaispill, i32 %FlatIdx
  %142 = load i32* %141
  %add.ptr202.sum = add i32 %142, 2
  %add.ptr203.sum = add i32 %add.ptr202.sum, %131
  %143 = getelementptr i32* %call2.gaispill, i32 %FlatIdx
  %144 = load i32* %143
  %145 = getelementptr i32* %call3.gaispill, i32 %FlatIdx
  %146 = load i32* %145
  %add.ptr204 = getelementptr inbounds [16 x [33 x <4 x i8>]]* %localmem.LDS_DAT, i32 0, i32 %146, i32 %144, i32 %add.ptr203.sum
  %call205 = call <4 x i8> @_Z12_socl_vload4jPKU3AS0h(i32 0, i8* %add.ptr204) #3
  %147 = getelementptr [2 x <4 x i8>]* %temp.gaispill, i32 %FlatIdx
  %arrayidx206 = getelementptr inbounds [2 x <4 x i8>]* %147, i32 0, i32 1
  store <4 x i8> %call205, <4 x i8>* %arrayidx206, align 4
  %148 = getelementptr [2 x <4 x i8>]* %temp.gaispill, i32 %FlatIdx
  %arrayidx207 = getelementptr inbounds [2 x <4 x i8>]* %148, i32 0, i32 0
  %149 = load <4 x i8>* %arrayidx207, align 4
  %150 = bitcast <4 x i8> %149 to i32
  %call209 = call <4 x float> @_Z20_socl_convert_float4Dv4_h(i32 %150) #3
  %sub210 = sub nsw i32 2, %131
  %arrayidx211 = getelementptr inbounds float* %mat_kernel, i32 %sub210
  %151 = load float* %arrayidx211, align 4
  %splat.splatinsert212 = insertelement <4 x float> undef, float %151, i32 0
  %splat.splat213 = shufflevector <4 x float> %splat.splatinsert212, <4 x float> undef, <4 x i32> zeroinitializer
  %152 = getelementptr [2 x <4 x i8>]* %temp.gaispill, i32 %FlatIdx
  %arrayidx215 = getelementptr inbounds [2 x <4 x i8>]* %152, i32 0, i32 1
  %153 = load <4 x i8>* %arrayidx215, align 4
  %154 = bitcast <4 x i8> %153 to i32
  %call217 = call <4 x float> @_Z20_socl_convert_float4Dv4_h(i32 %154) #3
  %add218 = add nsw i32 %131, 2
  %arrayidx219 = getelementptr inbounds float* %mat_kernel, i32 %add218
  %155 = load float* %arrayidx219, align 4
  %splat.splatinsert220 = insertelement <4 x float> undef, float %155, i32 0
  %splat.splat221 = shufflevector <4 x float> %splat.splatinsert220, <4 x float> undef, <4 x i32> zeroinitializer
  %mul222 = fmul <4 x float> %call217, %splat.splat221
  %156 = call <4 x float> @llvm.fmuladd.v4f32(<4 x float> %call209, <4 x float> %splat.splat213, <4 x float> %mul222)
  %add223 = fadd <4 x float> %133, %156
  %inc225 = add nsw i32 %131, 1
  %157 = getelementptr i32* %i.4.ex_phi.gaispill, i32 %FlatIdx
  store i32 %inc225, i32* %157
  %158 = getelementptr <4 x float>* %sum.0.ex_phi.gaispill, i32 %FlatIdx
  store <4 x float> %add223, <4 x float>* %158
  br label %for.cond189.r_entry

for.end226.r_entry:                               ; preds = %for.cond189.r_entry
  %159 = getelementptr i32* %shl.gaispill, i32 %FlatIdx
  %160 = load i32* %159
  %161 = getelementptr i32* %.gaispill, i32 %FlatIdx
  %162 = load i32* %161
  %call227 = call i32 @_Z11_socl_mad24iii(i32 %162, i32 %dst_step_in_pixel, i32 %160) #3
  %163 = getelementptr i32* %shl.gaispill, i32 %FlatIdx
  %164 = load i32* %163
  %add2282 = or i32 %164, 3
  %cmp229 = icmp slt i32 %add2282, %dst_cols
  %165 = getelementptr i32* %.gaispill, i32 %FlatIdx
  %166 = load i32* %165
  %cmp231 = icmp slt i32 %166, %dst_rows
  %and2333 = and i1 %cmp229, %cmp231
  br i1 %and2333, label %if.then235, label %if.else237.r_entry

if.then235:                                       ; preds = %for.end226.r_entry
  %arrayidx236 = getelementptr inbounds float* %dst, i32 %call227
  %167 = bitcast float* %arrayidx236 to <4 x float>*
  store <4 x float> %133, <4 x float>* %167, align 16
  br label %mxpa.latch

if.else237.r_entry:                               ; preds = %for.end226.r_entry
  %168 = getelementptr i32* %shl.gaispill, i32 %FlatIdx
  %169 = load i32* %168
  %add2384 = or i32 %169, 2
  %cmp239 = icmp slt i32 %add2384, %dst_cols
  %170 = getelementptr i32* %.gaispill, i32 %FlatIdx
  %171 = load i32* %170
  %cmp241 = icmp slt i32 %171, %dst_rows
  %and2435 = and i1 %cmp239, %cmp241
  br i1 %and2435, label %if.then245, label %if.else251.r_entry

if.then245:                                       ; preds = %if.else237.r_entry
  %172 = extractelement <4 x float> %133, i32 0
  %arrayidx246 = getelementptr inbounds float* %dst, i32 %call227
  store float %172, float* %arrayidx246, align 4
  %173 = extractelement <4 x float> %133, i32 1
  %add247 = add nsw i32 %call227, 1
  %arrayidx248 = getelementptr inbounds float* %dst, i32 %add247
  store float %173, float* %arrayidx248, align 4
  %174 = extractelement <4 x float> %133, i32 2
  %add249 = add nsw i32 %call227, 2
  %arrayidx250 = getelementptr inbounds float* %dst, i32 %add249
  store float %174, float* %arrayidx250, align 4
  br label %mxpa.latch

if.else251.r_entry:                               ; preds = %if.else237.r_entry
  %175 = getelementptr i32* %shl.gaispill, i32 %FlatIdx
  %176 = load i32* %175
  %add2526 = or i32 %176, 1
  %cmp253 = icmp slt i32 %add2526, %dst_cols
  %177 = getelementptr i32* %.gaispill, i32 %FlatIdx
  %178 = load i32* %177
  %cmp255 = icmp slt i32 %178, %dst_rows
  %and2577 = and i1 %cmp253, %cmp255
  br i1 %and2577, label %if.then259, label %if.else263.r_entry

if.then259:                                       ; preds = %if.else251.r_entry
  %179 = extractelement <4 x float> %133, i32 0
  %arrayidx260 = getelementptr inbounds float* %dst, i32 %call227
  store float %179, float* %arrayidx260, align 4
  %180 = extractelement <4 x float> %133, i32 1
  %add261 = add nsw i32 %call227, 1
  %arrayidx262 = getelementptr inbounds float* %dst, i32 %add261
  store float %180, float* %arrayidx262, align 4
  br label %mxpa.latch

if.else263.r_entry:                               ; preds = %if.else251.r_entry
  %181 = getelementptr i32* %shl.gaispill, i32 %FlatIdx
  %182 = load i32* %181
  %cmp264 = icmp slt i32 %182, %dst_cols
  %183 = getelementptr i32* %.gaispill, i32 %FlatIdx
  %184 = load i32* %183
  %cmp266 = icmp slt i32 %184, %dst_rows
  %and2688 = and i1 %cmp264, %cmp266
  br i1 %and2688, label %if.then270, label %mxpa.latch

if.then270:                                       ; preds = %if.else263.r_entry
  %185 = extractelement <4 x float> %133, i32 0
  %arrayidx271 = getelementptr inbounds float* %dst, i32 %call227
  store float %185, float* %arrayidx271, align 4
  br label %mxpa.latch

mxpa.latch:                                       ; preds = %if.then235, %if.then259, %if.then270, %if.else263.r_entry, %if.then245
  %IV0_inc = add i32 %IV0, 1
  %CmpResult = icmp ult i32 %IV0_inc, %get_local_size26
  br i1 %CmpResult, label %mxpa.lp.body, label %mxpa.latch27

mxpa.latch27:                                     ; preds = %mxpa.latch
  %IV1_inc = add i32 %IV1, 1
  %CmpResult32 = icmp ult i32 %IV1_inc, %get_local_size31
  br i1 %CmpResult32, label %mxpa.lp.body28, label %mxpa.latch33

mxpa.latch33:                                     ; preds = %mxpa.latch27
  %IV2_inc = add i32 %IV2, 1
  %CmpResult38 = icmp ult i32 %IV2_inc, %get_local_size37
  br i1 %CmpResult38, label %mxpa.lp.body34, label %exit.barrier

exit.barrier:                                     ; preds = %mxpa.latch33
  ret void
}

declare i32 @_Z11_socl_mad24iii(i32, i32, i32) #1

declare <4 x i32> @_Z11_socl_mad24Dv4_iS_S_(<4 x i32>, <4 x i32>, <4 x i32>) #1

declare <4 x float> @_Z20_socl_convert_float4Dv4_h(i32) #1

declare <4 x i8> @_Z12_socl_vload4jPKU3AS0h(i32, i8*) #1

; Function Attrs: nounwind readnone
declare <4 x float> @llvm.fmuladd.v4f32(<4 x float>, <4 x float>, <4 x float>) #2

; Function Attrs: noinline nounwind
define void @row_filter_C4_D0(<4 x i8>* noalias %src, <4 x float>* %dst, i32 %dst_cols, i32 %dst_rows, i32 %src_whole_cols, i32 %src_whole_rows, i32 %src_step_in_pixel, i32 %src_offset_x, i32 %src_offset_y, i32 %dst_step_in_pixel, i32 %radiusy, float* %mat_kernel) #0 {
entry.barrier:
  %get_local_size6 = call i32 @get_local_size(i32 0)
  %get_local_size7 = call i32 @get_local_size(i32 1)
  %get_local_size8 = call i32 @get_local_size(i32 2)
  %get_local_size = call i32 @get_local_size(i32 0)
  %get_group_id = call i32 @get_group_id(i32 0)
  %get_global_offset = call i32 @get_global_offset(i32 0)
  %get_local_size2 = call i32 @get_local_size(i32 1)
  %get_group_id3 = call i32 @get_group_id(i32 1)
  %get_global_offset5 = call i32 @get_global_offset(i32 1)
  %get_local_size36 = call i32 @get_local_size(i32 0)
  %get_local_size45 = call i32 @get_local_size(i32 1)
  %get_local_size54 = call i32 @get_local_size(i32 2)
  %get_local_size17 = call i32 @get_local_size(i32 0)
  %get_local_size22 = call i32 @get_local_size(i32 1)
  %get_local_size28 = call i32 @get_local_size(i32 2)
  %localmem.LDS_DAT = alloca [16 x [33 x <4 x i8>]], align 4
  %0 = mul i32 %get_local_size8, %get_local_size7
  %Flat3DSize = mul i32 %0, %get_local_size6
  %sum.0.ex_phi.gaispill = alloca <4 x float>, i32 %Flat3DSize, align 64
  %i.3.ex_phi.gaispill = alloca i32, i32 %Flat3DSize, align 64
  %i.2.ex_phi.gaispill = alloca i32, i32 %Flat3DSize, align 64
  %i.1.ex_phi.gaispill = alloca i32, i32 %Flat3DSize, align 64
  %i.0.ex_phi.gaispill = alloca i32, i32 %Flat3DSize, align 64
  %temp.gaispill = alloca [2 x <4 x i8>], i32 %Flat3DSize, align 64
  %index.gaispill = alloca [2 x i32], i32 %Flat3DSize, align 64
  %.gaispill = alloca i32, i32 %Flat3DSize, align 64
  %.gaispill16 = alloca i32, i32 %Flat3DSize, align 64
  %call2.gaispill = alloca i32, i32 %Flat3DSize, align 64
  %call3.gaispill = alloca i32, i32 %Flat3DSize, align 64
  br label %mxpa.lp.body49

mxpa.lp.body49:                                   ; preds = %entry.barrier, %mxpa.latch48
  %IV253 = phi i32 [ 0, %entry.barrier ], [ %IV2_inc55, %mxpa.latch48 ]
  br label %mxpa.lp.body40

mxpa.lp.body40:                                   ; preds = %mxpa.lp.body49, %mxpa.latch39
  %IV144 = phi i32 [ 0, %mxpa.lp.body49 ], [ %IV1_inc46, %mxpa.latch39 ]
  br label %mxpa.lp.body31

mxpa.lp.body31:                                   ; preds = %mxpa.lp.body40, %mxpa.latch30
  %IV035 = phi i32 [ 0, %mxpa.lp.body40 ], [ %IV0_inc37, %mxpa.latch30 ]
  %1 = mul i32 %IV144, %get_local_size6
  %2 = mul i32 %IV253, %get_local_size6
  %3 = mul i32 %2, %get_local_size7
  %4 = add i32 %3, %1
  %FlatIdx15 = add i32 %4, %IV035
  %5 = mul i32 %get_local_size, %get_group_id
  %6 = add i32 %5, %IV035
  %7 = add i32 %6, %get_global_offset
  %8 = getelementptr i32* %.gaispill, i32 %FlatIdx15
  store i32 %7, i32* %8
  %9 = mul i32 %get_local_size2, %get_group_id3
  %10 = add i32 %9, %IV144
  %11 = add i32 %10, %get_global_offset5
  %12 = getelementptr i32* %.gaispill16, i32 %FlatIdx15
  store i32 %11, i32* %12
  %13 = getelementptr i32* %call2.gaispill, i32 %FlatIdx15
  store i32 %IV035, i32* %13
  %14 = getelementptr i32* %call3.gaispill, i32 %FlatIdx15
  store i32 %IV144, i32* %14
  %15 = getelementptr i32* %.gaispill, i32 %FlatIdx15
  %16 = load i32* %15
  %add = add nsw i32 %16, %src_offset_x
  %sub = add nsw i32 %add, -2
  %17 = getelementptr i32* %.gaispill16, i32 %FlatIdx15
  %18 = load i32* %17
  %add4 = add nsw i32 %18, %src_offset_y
  %sub5 = sub nsw i32 %add4, %radiusy
  %call6 = call i32 @_Z11_socl_mad24iii(i32 %sub5, i32 %src_step_in_pixel, i32 %sub) #3
  %19 = getelementptr i32* %i.0.ex_phi.gaispill, i32 %FlatIdx15
  store i32 0, i32* %19
  %20 = getelementptr i32* %i.0.ex_phi.gaispill, i32 %FlatIdx15
  br label %for.cond.r_entry

for.cond.r_entry:                                 ; preds = %mxpa.lp.body31, %for.body
  %21 = load i32* %20
  %cmp = icmp slt i32 %21, 2
  br i1 %cmp, label %for.body, label %for.cond31.preheader

for.cond31.preheader:                             ; preds = %for.cond.r_entry
  %22 = getelementptr i32* %i.1.ex_phi.gaispill, i32 %FlatIdx15
  store i32 0, i32* %22
  %23 = getelementptr i32* %i.1.ex_phi.gaispill, i32 %FlatIdx15
  br label %for.cond31.r_entry

for.body:                                         ; preds = %for.cond.r_entry
  %mul = shl nsw i32 %21, 4
  %add7 = add nsw i32 %sub, %mul
  %cmp8 = icmp slt i32 %add7, 0
  %cond = select i1 %cmp8, i32 0, i32 %add7
  %mul11 = shl nsw i32 %21, 4
  %add12 = add nsw i32 %sub, %mul11
  %cmp13 = icmp sge i32 %add12, %src_whole_cols
  %sub15 = add nsw i32 %src_whole_cols, -1
  %cond18 = select i1 %cmp13, i32 %sub15, i32 %cond
  %cmp19 = icmp slt i32 %sub5, 0
  %.sub5 = select i1 %cmp19, i32 0, i32 %sub5
  %cmp24 = icmp sge i32 %sub5, %src_whole_rows
  %sub26 = add nsw i32 %src_whole_rows, -1
  %cond29 = select i1 %cmp24, i32 %sub26, i32 %.sub5
  %call30 = call i32 @_Z11_socl_mad24iii(i32 %cond29, i32 %src_step_in_pixel, i32 %cond18) #3
  %24 = getelementptr [2 x i32]* %index.gaispill, i32 %FlatIdx15
  %arrayidx = getelementptr inbounds [2 x i32]* %24, i32 0, i32 %21
  store i32 %call30, i32* %arrayidx, align 4
  %inc = add nsw i32 %21, 1
  %25 = getelementptr i32* %i.0.ex_phi.gaispill, i32 %FlatIdx15
  store i32 %inc, i32* %25
  br label %for.cond.r_entry

for.cond31.r_entry:                               ; preds = %for.cond31.preheader, %for.body33
  %26 = load i32* %23
  %cmp32 = icmp slt i32 %26, 2
  br i1 %cmp32, label %for.body33, label %for.cond40.preheader

for.cond40.preheader:                             ; preds = %for.cond31.r_entry
  %27 = getelementptr i32* %i.2.ex_phi.gaispill, i32 %FlatIdx15
  store i32 0, i32* %27
  %28 = getelementptr i32* %i.2.ex_phi.gaispill, i32 %FlatIdx15
  br label %for.cond40.r_entry

for.body33:                                       ; preds = %for.cond31.r_entry
  %29 = getelementptr [2 x i32]* %index.gaispill, i32 %FlatIdx15
  %arrayidx34 = getelementptr inbounds [2 x i32]* %29, i32 0, i32 %26
  %30 = load i32* %arrayidx34, align 4
  %arrayidx35 = getelementptr inbounds <4 x i8>* %src, i32 %30
  %31 = load <4 x i8>* %arrayidx35, align 4
  %32 = getelementptr [2 x <4 x i8>]* %temp.gaispill, i32 %FlatIdx15
  %arrayidx36 = getelementptr inbounds [2 x <4 x i8>]* %32, i32 0, i32 %26
  store <4 x i8> %31, <4 x i8>* %arrayidx36, align 4
  %inc38 = add nsw i32 %26, 1
  %33 = getelementptr i32* %i.1.ex_phi.gaispill, i32 %FlatIdx15
  store i32 %inc38, i32* %33
  br label %for.cond31.r_entry

for.cond40.r_entry:                               ; preds = %for.cond40.preheader, %for.body42
  %34 = load i32* %28
  %cmp41 = icmp slt i32 %34, 2
  br i1 %cmp41, label %for.body42, label %mxpa.latch30

for.body42:                                       ; preds = %for.cond40.r_entry
  %35 = getelementptr [2 x <4 x i8>]* %temp.gaispill, i32 %FlatIdx15
  %arrayidx43 = getelementptr inbounds [2 x <4 x i8>]* %35, i32 0, i32 %34
  %36 = load <4 x i8>* %arrayidx43, align 4
  %mul44 = shl nsw i32 %34, 4
  %37 = getelementptr i32* %call2.gaispill, i32 %FlatIdx15
  %38 = load i32* %37
  %add45 = add nsw i32 %38, %mul44
  %39 = getelementptr i32* %call3.gaispill, i32 %FlatIdx15
  %40 = load i32* %39
  %arrayidx47 = getelementptr inbounds [16 x [33 x <4 x i8>]]* %localmem.LDS_DAT, i32 0, i32 %40, i32 %add45
  store <4 x i8> %36, <4 x i8>* %arrayidx47, align 4
  %inc49 = add nsw i32 %34, 1
  %41 = getelementptr i32* %i.2.ex_phi.gaispill, i32 %FlatIdx15
  store i32 %inc49, i32* %41
  br label %for.cond40.r_entry

mxpa.latch30:                                     ; preds = %for.cond40.r_entry
  %IV0_inc37 = add i32 %IV035, 1
  %CmpResult38 = icmp ult i32 %IV0_inc37, %get_local_size36
  br i1 %CmpResult38, label %mxpa.lp.body31, label %mxpa.latch39

mxpa.latch39:                                     ; preds = %mxpa.latch30
  %IV1_inc46 = add i32 %IV144, 1
  %CmpResult47 = icmp ult i32 %IV1_inc46, %get_local_size45
  br i1 %CmpResult47, label %mxpa.lp.body40, label %mxpa.latch48

mxpa.latch48:                                     ; preds = %mxpa.latch39
  %IV2_inc55 = add i32 %IV253, 1
  %CmpResult56 = icmp ult i32 %IV2_inc55, %get_local_size54
  br i1 %CmpResult56, label %mxpa.lp.body49, label %mxpa.lp.body25

mxpa.lp.body25:                                   ; preds = %mxpa.latch24, %mxpa.latch48
  %IV2 = phi i32 [ %IV2_inc, %mxpa.latch24 ], [ 0, %mxpa.latch48 ]
  br label %mxpa.lp.body19

mxpa.lp.body19:                                   ; preds = %mxpa.lp.body25, %mxpa.latch18
  %IV1 = phi i32 [ 0, %mxpa.lp.body25 ], [ %IV1_inc, %mxpa.latch18 ]
  br label %mxpa.lp.body

mxpa.lp.body:                                     ; preds = %mxpa.lp.body19, %mxpa.latch
  %IV0 = phi i32 [ 0, %mxpa.lp.body19 ], [ %IV0_inc, %mxpa.latch ]
  %42 = mul i32 %IV1, %get_local_size6
  %43 = mul i32 %IV2, %get_local_size6
  %44 = mul i32 %43, %get_local_size7
  %45 = add i32 %44, %42
  %FlatIdx = add i32 %45, %IV0
  %46 = getelementptr i32* %call2.gaispill, i32 %FlatIdx
  %47 = load i32* %46
  %add51 = add nsw i32 %47, 2
  %48 = getelementptr i32* %call3.gaispill, i32 %FlatIdx
  %49 = load i32* %48
  %arrayidx53 = getelementptr inbounds [16 x [33 x <4 x i8>]]* %localmem.LDS_DAT, i32 0, i32 %49, i32 %add51
  %50 = load <4 x i8>* %arrayidx53, align 4
  %51 = bitcast <4 x i8> %50 to i32
  %call54 = call <4 x float> @_Z20_socl_convert_float4Dv4_h(i32 %51) #3
  %arrayidx55 = getelementptr inbounds float* %mat_kernel, i32 2
  %52 = load float* %arrayidx55, align 4
  %splat.splatinsert = insertelement <4 x float> undef, float %52, i32 0
  %splat.splat = shufflevector <4 x float> %splat.splatinsert, <4 x float> undef, <4 x i32> zeroinitializer
  %mul56 = fmul <4 x float> %call54, %splat.splat
  %53 = getelementptr i32* %i.3.ex_phi.gaispill, i32 %FlatIdx
  store i32 1, i32* %53
  %54 = getelementptr <4 x float>* %sum.0.ex_phi.gaispill, i32 %FlatIdx
  store <4 x float> %mul56, <4 x float>* %54
  %55 = getelementptr i32* %i.3.ex_phi.gaispill, i32 %FlatIdx
  br label %for.cond57.r_entry

for.cond57.r_entry:                               ; preds = %mxpa.lp.body, %for.body59
  %56 = load i32* %55
  %57 = getelementptr <4 x float>* %sum.0.ex_phi.gaispill, i32 %FlatIdx
  %58 = load <4 x float>* %57
  %cmp58 = icmp slt i32 %56, 3
  br i1 %cmp58, label %for.body59, label %for.end89.r_entry

for.body59:                                       ; preds = %for.cond57.r_entry
  %59 = getelementptr i32* %call2.gaispill, i32 %FlatIdx
  %60 = load i32* %59
  %add60 = add nsw i32 %60, 2
  %sub61 = sub nsw i32 %add60, %56
  %61 = getelementptr i32* %call3.gaispill, i32 %FlatIdx
  %62 = load i32* %61
  %arrayidx63 = getelementptr inbounds [16 x [33 x <4 x i8>]]* %localmem.LDS_DAT, i32 0, i32 %62, i32 %sub61
  %63 = load <4 x i8>* %arrayidx63, align 4
  %64 = getelementptr [2 x <4 x i8>]* %temp.gaispill, i32 %FlatIdx
  %arrayidx64 = getelementptr inbounds [2 x <4 x i8>]* %64, i32 0, i32 0
  store <4 x i8> %63, <4 x i8>* %arrayidx64, align 4
  %65 = getelementptr i32* %call2.gaispill, i32 %FlatIdx
  %66 = load i32* %65
  %add65 = add nsw i32 %66, 2
  %add66 = add nsw i32 %add65, %56
  %67 = getelementptr i32* %call3.gaispill, i32 %FlatIdx
  %68 = load i32* %67
  %arrayidx68 = getelementptr inbounds [16 x [33 x <4 x i8>]]* %localmem.LDS_DAT, i32 0, i32 %68, i32 %add66
  %69 = load <4 x i8>* %arrayidx68, align 4
  %70 = getelementptr [2 x <4 x i8>]* %temp.gaispill, i32 %FlatIdx
  %arrayidx69 = getelementptr inbounds [2 x <4 x i8>]* %70, i32 0, i32 1
  store <4 x i8> %69, <4 x i8>* %arrayidx69, align 4
  %71 = getelementptr [2 x <4 x i8>]* %temp.gaispill, i32 %FlatIdx
  %arrayidx70 = getelementptr inbounds [2 x <4 x i8>]* %71, i32 0, i32 0
  %72 = load <4 x i8>* %arrayidx70, align 4
  %73 = bitcast <4 x i8> %72 to i32
  %call72 = call <4 x float> @_Z20_socl_convert_float4Dv4_h(i32 %73) #3
  %sub73 = sub nsw i32 2, %56
  %arrayidx74 = getelementptr inbounds float* %mat_kernel, i32 %sub73
  %74 = load float* %arrayidx74, align 4
  %splat.splatinsert75 = insertelement <4 x float> undef, float %74, i32 0
  %splat.splat76 = shufflevector <4 x float> %splat.splatinsert75, <4 x float> undef, <4 x i32> zeroinitializer
  %75 = getelementptr [2 x <4 x i8>]* %temp.gaispill, i32 %FlatIdx
  %arrayidx78 = getelementptr inbounds [2 x <4 x i8>]* %75, i32 0, i32 1
  %76 = load <4 x i8>* %arrayidx78, align 4
  %77 = bitcast <4 x i8> %76 to i32
  %call80 = call <4 x float> @_Z20_socl_convert_float4Dv4_h(i32 %77) #3
  %add81 = add nsw i32 %56, 2
  %arrayidx82 = getelementptr inbounds float* %mat_kernel, i32 %add81
  %78 = load float* %arrayidx82, align 4
  %splat.splatinsert83 = insertelement <4 x float> undef, float %78, i32 0
  %splat.splat84 = shufflevector <4 x float> %splat.splatinsert83, <4 x float> undef, <4 x i32> zeroinitializer
  %mul85 = fmul <4 x float> %call80, %splat.splat84
  %79 = call <4 x float> @llvm.fmuladd.v4f32(<4 x float> %call72, <4 x float> %splat.splat76, <4 x float> %mul85)
  %add86 = fadd <4 x float> %58, %79
  %inc88 = add nsw i32 %56, 1
  %80 = getelementptr i32* %i.3.ex_phi.gaispill, i32 %FlatIdx
  store i32 %inc88, i32* %80
  %81 = getelementptr <4 x float>* %sum.0.ex_phi.gaispill, i32 %FlatIdx
  store <4 x float> %add86, <4 x float>* %81
  br label %for.cond57.r_entry

for.end89.r_entry:                                ; preds = %for.cond57.r_entry
  %82 = getelementptr i32* %.gaispill, i32 %FlatIdx
  %83 = load i32* %82
  %cmp90 = icmp slt i32 %83, %dst_cols
  %84 = getelementptr i32* %.gaispill16, i32 %FlatIdx
  %85 = load i32* %84
  %cmp91 = icmp slt i32 %85, %dst_rows
  %and1 = and i1 %cmp90, %cmp91
  br i1 %and1, label %if.then, label %mxpa.latch

if.then:                                          ; preds = %for.end89.r_entry
  %86 = getelementptr i32* %.gaispill, i32 %FlatIdx
  %87 = load i32* %86
  %88 = getelementptr i32* %.gaispill16, i32 %FlatIdx
  %89 = load i32* %88
  %call93 = call i32 @_Z11_socl_mad24iii(i32 %89, i32 %dst_step_in_pixel, i32 %87) #3
  %arrayidx94 = getelementptr inbounds <4 x float>* %dst, i32 %call93
  store <4 x float> %58, <4 x float>* %arrayidx94, align 16
  br label %mxpa.latch

mxpa.latch:                                       ; preds = %for.end89.r_entry, %if.then
  %IV0_inc = add i32 %IV0, 1
  %CmpResult = icmp ult i32 %IV0_inc, %get_local_size17
  br i1 %CmpResult, label %mxpa.lp.body, label %mxpa.latch18

mxpa.latch18:                                     ; preds = %mxpa.latch
  %IV1_inc = add i32 %IV1, 1
  %CmpResult23 = icmp ult i32 %IV1_inc, %get_local_size22
  br i1 %CmpResult23, label %mxpa.lp.body19, label %mxpa.latch24

mxpa.latch24:                                     ; preds = %mxpa.latch18
  %IV2_inc = add i32 %IV2, 1
  %CmpResult29 = icmp ult i32 %IV2_inc, %get_local_size28
  br i1 %CmpResult29, label %mxpa.lp.body25, label %exit.barrier

exit.barrier:                                     ; preds = %mxpa.latch24
  ret void
}

; Function Attrs: noinline nounwind
define void @row_filter_C1_D5(float* noalias %src, float* %dst, i32 %dst_cols, i32 %dst_rows, i32 %src_whole_cols, i32 %src_whole_rows, i32 %src_step_in_pixel, i32 %src_offset_x, i32 %src_offset_y, i32 %dst_step_in_pixel, i32 %radiusy, float* %mat_kernel) #0 {
entry.barrier:
  %get_local_size6 = call i32 @get_local_size(i32 0)
  %get_local_size7 = call i32 @get_local_size(i32 1)
  %get_local_size8 = call i32 @get_local_size(i32 2)
  %get_local_size = call i32 @get_local_size(i32 0)
  %get_group_id = call i32 @get_group_id(i32 0)
  %get_global_offset = call i32 @get_global_offset(i32 0)
  %get_local_size2 = call i32 @get_local_size(i32 1)
  %get_group_id3 = call i32 @get_group_id(i32 1)
  %get_global_offset5 = call i32 @get_global_offset(i32 1)
  %get_local_size36 = call i32 @get_local_size(i32 0)
  %get_local_size45 = call i32 @get_local_size(i32 1)
  %get_local_size54 = call i32 @get_local_size(i32 2)
  %get_local_size17 = call i32 @get_local_size(i32 0)
  %get_local_size22 = call i32 @get_local_size(i32 1)
  %get_local_size28 = call i32 @get_local_size(i32 2)
  %localmem.LDS_DAT = alloca [16 x [33 x float]], align 4
  %0 = mul i32 %get_local_size8, %get_local_size7
  %Flat3DSize = mul i32 %0, %get_local_size6
  %sum.0.ex_phi.gaispill = alloca float, i32 %Flat3DSize, align 64
  %i.3.ex_phi.gaispill = alloca i32, i32 %Flat3DSize, align 64
  %i.2.ex_phi.gaispill = alloca i32, i32 %Flat3DSize, align 64
  %i.1.ex_phi.gaispill = alloca i32, i32 %Flat3DSize, align 64
  %i.0.ex_phi.gaispill = alloca i32, i32 %Flat3DSize, align 64
  %temp.gaispill = alloca [2 x float], i32 %Flat3DSize, align 64
  %index.gaispill = alloca [2 x i32], i32 %Flat3DSize, align 64
  %.gaispill = alloca i32, i32 %Flat3DSize, align 64
  %.gaispill16 = alloca i32, i32 %Flat3DSize, align 64
  %call2.gaispill = alloca i32, i32 %Flat3DSize, align 64
  %call3.gaispill = alloca i32, i32 %Flat3DSize, align 64
  br label %mxpa.lp.body49

mxpa.lp.body49:                                   ; preds = %entry.barrier, %mxpa.latch48
  %IV253 = phi i32 [ 0, %entry.barrier ], [ %IV2_inc55, %mxpa.latch48 ]
  br label %mxpa.lp.body40

mxpa.lp.body40:                                   ; preds = %mxpa.lp.body49, %mxpa.latch39
  %IV144 = phi i32 [ 0, %mxpa.lp.body49 ], [ %IV1_inc46, %mxpa.latch39 ]
  br label %mxpa.lp.body31

mxpa.lp.body31:                                   ; preds = %mxpa.lp.body40, %mxpa.latch30
  %IV035 = phi i32 [ 0, %mxpa.lp.body40 ], [ %IV0_inc37, %mxpa.latch30 ]
  %1 = mul i32 %IV144, %get_local_size6
  %2 = mul i32 %IV253, %get_local_size6
  %3 = mul i32 %2, %get_local_size7
  %4 = add i32 %3, %1
  %FlatIdx15 = add i32 %4, %IV035
  %5 = mul i32 %get_local_size, %get_group_id
  %6 = add i32 %5, %IV035
  %7 = add i32 %6, %get_global_offset
  %8 = getelementptr i32* %.gaispill, i32 %FlatIdx15
  store i32 %7, i32* %8
  %9 = mul i32 %get_local_size2, %get_group_id3
  %10 = add i32 %9, %IV144
  %11 = add i32 %10, %get_global_offset5
  %12 = getelementptr i32* %.gaispill16, i32 %FlatIdx15
  store i32 %11, i32* %12
  %13 = getelementptr i32* %call2.gaispill, i32 %FlatIdx15
  store i32 %IV035, i32* %13
  %14 = getelementptr i32* %call3.gaispill, i32 %FlatIdx15
  store i32 %IV144, i32* %14
  %15 = getelementptr i32* %.gaispill, i32 %FlatIdx15
  %16 = load i32* %15
  %add = add nsw i32 %16, %src_offset_x
  %sub = add nsw i32 %add, -2
  %17 = getelementptr i32* %.gaispill16, i32 %FlatIdx15
  %18 = load i32* %17
  %add4 = add nsw i32 %18, %src_offset_y
  %sub5 = sub nsw i32 %add4, %radiusy
  %call6 = call i32 @_Z11_socl_mad24iii(i32 %sub5, i32 %src_step_in_pixel, i32 %sub) #3
  %19 = getelementptr i32* %i.0.ex_phi.gaispill, i32 %FlatIdx15
  store i32 0, i32* %19
  %20 = getelementptr i32* %i.0.ex_phi.gaispill, i32 %FlatIdx15
  br label %for.cond.r_entry

for.cond.r_entry:                                 ; preds = %mxpa.lp.body31, %for.body
  %21 = load i32* %20
  %cmp = icmp slt i32 %21, 2
  br i1 %cmp, label %for.body, label %for.cond31.preheader

for.cond31.preheader:                             ; preds = %for.cond.r_entry
  %22 = getelementptr i32* %i.1.ex_phi.gaispill, i32 %FlatIdx15
  store i32 0, i32* %22
  %23 = getelementptr i32* %i.1.ex_phi.gaispill, i32 %FlatIdx15
  br label %for.cond31.r_entry

for.body:                                         ; preds = %for.cond.r_entry
  %mul = shl nsw i32 %21, 4
  %add7 = add nsw i32 %sub, %mul
  %cmp8 = icmp slt i32 %add7, 0
  %cond = select i1 %cmp8, i32 0, i32 %add7
  %mul11 = shl nsw i32 %21, 4
  %add12 = add nsw i32 %sub, %mul11
  %cmp13 = icmp sge i32 %add12, %src_whole_cols
  %sub15 = add nsw i32 %src_whole_cols, -1
  %cond18 = select i1 %cmp13, i32 %sub15, i32 %cond
  %cmp19 = icmp slt i32 %sub5, 0
  %.sub5 = select i1 %cmp19, i32 0, i32 %sub5
  %cmp24 = icmp sge i32 %sub5, %src_whole_rows
  %sub26 = add nsw i32 %src_whole_rows, -1
  %cond29 = select i1 %cmp24, i32 %sub26, i32 %.sub5
  %call30 = call i32 @_Z11_socl_mad24iii(i32 %cond29, i32 %src_step_in_pixel, i32 %cond18) #3
  %24 = getelementptr [2 x i32]* %index.gaispill, i32 %FlatIdx15
  %arrayidx = getelementptr inbounds [2 x i32]* %24, i32 0, i32 %21
  store i32 %call30, i32* %arrayidx, align 4
  %inc = add nsw i32 %21, 1
  %25 = getelementptr i32* %i.0.ex_phi.gaispill, i32 %FlatIdx15
  store i32 %inc, i32* %25
  br label %for.cond.r_entry

for.cond31.r_entry:                               ; preds = %for.cond31.preheader, %for.body33
  %26 = load i32* %23
  %cmp32 = icmp slt i32 %26, 2
  br i1 %cmp32, label %for.body33, label %for.cond40.preheader

for.cond40.preheader:                             ; preds = %for.cond31.r_entry
  %27 = getelementptr i32* %i.2.ex_phi.gaispill, i32 %FlatIdx15
  store i32 0, i32* %27
  %28 = getelementptr i32* %i.2.ex_phi.gaispill, i32 %FlatIdx15
  br label %for.cond40.r_entry

for.body33:                                       ; preds = %for.cond31.r_entry
  %29 = getelementptr [2 x i32]* %index.gaispill, i32 %FlatIdx15
  %arrayidx34 = getelementptr inbounds [2 x i32]* %29, i32 0, i32 %26
  %30 = load i32* %arrayidx34, align 4
  %arrayidx35 = getelementptr inbounds float* %src, i32 %30
  %31 = load float* %arrayidx35, align 4
  %32 = getelementptr [2 x float]* %temp.gaispill, i32 %FlatIdx15
  %arrayidx36 = getelementptr inbounds [2 x float]* %32, i32 0, i32 %26
  store float %31, float* %arrayidx36, align 4
  %inc38 = add nsw i32 %26, 1
  %33 = getelementptr i32* %i.1.ex_phi.gaispill, i32 %FlatIdx15
  store i32 %inc38, i32* %33
  br label %for.cond31.r_entry

for.cond40.r_entry:                               ; preds = %for.cond40.preheader, %for.body42
  %34 = load i32* %28
  %cmp41 = icmp slt i32 %34, 2
  br i1 %cmp41, label %for.body42, label %mxpa.latch30

for.body42:                                       ; preds = %for.cond40.r_entry
  %35 = getelementptr [2 x float]* %temp.gaispill, i32 %FlatIdx15
  %arrayidx43 = getelementptr inbounds [2 x float]* %35, i32 0, i32 %34
  %36 = load float* %arrayidx43, align 4
  %mul44 = shl nsw i32 %34, 4
  %37 = getelementptr i32* %call2.gaispill, i32 %FlatIdx15
  %38 = load i32* %37
  %add45 = add nsw i32 %38, %mul44
  %39 = getelementptr i32* %call3.gaispill, i32 %FlatIdx15
  %40 = load i32* %39
  %arrayidx47 = getelementptr inbounds [16 x [33 x float]]* %localmem.LDS_DAT, i32 0, i32 %40, i32 %add45
  store float %36, float* %arrayidx47, align 4
  %inc49 = add nsw i32 %34, 1
  %41 = getelementptr i32* %i.2.ex_phi.gaispill, i32 %FlatIdx15
  store i32 %inc49, i32* %41
  br label %for.cond40.r_entry

mxpa.latch30:                                     ; preds = %for.cond40.r_entry
  %IV0_inc37 = add i32 %IV035, 1
  %CmpResult38 = icmp ult i32 %IV0_inc37, %get_local_size36
  br i1 %CmpResult38, label %mxpa.lp.body31, label %mxpa.latch39

mxpa.latch39:                                     ; preds = %mxpa.latch30
  %IV1_inc46 = add i32 %IV144, 1
  %CmpResult47 = icmp ult i32 %IV1_inc46, %get_local_size45
  br i1 %CmpResult47, label %mxpa.lp.body40, label %mxpa.latch48

mxpa.latch48:                                     ; preds = %mxpa.latch39
  %IV2_inc55 = add i32 %IV253, 1
  %CmpResult56 = icmp ult i32 %IV2_inc55, %get_local_size54
  br i1 %CmpResult56, label %mxpa.lp.body49, label %mxpa.lp.body25

mxpa.lp.body25:                                   ; preds = %mxpa.latch24, %mxpa.latch48
  %IV2 = phi i32 [ %IV2_inc, %mxpa.latch24 ], [ 0, %mxpa.latch48 ]
  br label %mxpa.lp.body19

mxpa.lp.body19:                                   ; preds = %mxpa.lp.body25, %mxpa.latch18
  %IV1 = phi i32 [ 0, %mxpa.lp.body25 ], [ %IV1_inc, %mxpa.latch18 ]
  br label %mxpa.lp.body

mxpa.lp.body:                                     ; preds = %mxpa.lp.body19, %mxpa.latch
  %IV0 = phi i32 [ 0, %mxpa.lp.body19 ], [ %IV0_inc, %mxpa.latch ]
  %42 = mul i32 %IV1, %get_local_size6
  %43 = mul i32 %IV2, %get_local_size6
  %44 = mul i32 %43, %get_local_size7
  %45 = add i32 %44, %42
  %FlatIdx = add i32 %45, %IV0
  %46 = getelementptr i32* %call2.gaispill, i32 %FlatIdx
  %47 = load i32* %46
  %add51 = add nsw i32 %47, 2
  %48 = getelementptr i32* %call3.gaispill, i32 %FlatIdx
  %49 = load i32* %48
  %arrayidx53 = getelementptr inbounds [16 x [33 x float]]* %localmem.LDS_DAT, i32 0, i32 %49, i32 %add51
  %50 = load float* %arrayidx53, align 4
  %arrayidx54 = getelementptr inbounds float* %mat_kernel, i32 2
  %51 = load float* %arrayidx54, align 4
  %mul55 = fmul float %50, %51
  %52 = getelementptr i32* %i.3.ex_phi.gaispill, i32 %FlatIdx
  store i32 1, i32* %52
  %53 = getelementptr float* %sum.0.ex_phi.gaispill, i32 %FlatIdx
  store float %mul55, float* %53
  %54 = getelementptr i32* %i.3.ex_phi.gaispill, i32 %FlatIdx
  br label %for.cond56.r_entry

for.cond56.r_entry:                               ; preds = %mxpa.lp.body, %for.body58
  %55 = load i32* %54
  %56 = getelementptr float* %sum.0.ex_phi.gaispill, i32 %FlatIdx
  %57 = load float* %56
  %cmp57 = icmp slt i32 %55, 3
  br i1 %cmp57, label %for.body58, label %for.end80.r_entry

for.body58:                                       ; preds = %for.cond56.r_entry
  %58 = getelementptr i32* %call2.gaispill, i32 %FlatIdx
  %59 = load i32* %58
  %add59 = add nsw i32 %59, 2
  %sub60 = sub nsw i32 %add59, %55
  %60 = getelementptr i32* %call3.gaispill, i32 %FlatIdx
  %61 = load i32* %60
  %arrayidx62 = getelementptr inbounds [16 x [33 x float]]* %localmem.LDS_DAT, i32 0, i32 %61, i32 %sub60
  %62 = load float* %arrayidx62, align 4
  %63 = getelementptr [2 x float]* %temp.gaispill, i32 %FlatIdx
  %arrayidx63 = getelementptr inbounds [2 x float]* %63, i32 0, i32 0
  store float %62, float* %arrayidx63, align 4
  %64 = getelementptr i32* %call2.gaispill, i32 %FlatIdx
  %65 = load i32* %64
  %add64 = add nsw i32 %65, 2
  %add65 = add nsw i32 %add64, %55
  %66 = getelementptr i32* %call3.gaispill, i32 %FlatIdx
  %67 = load i32* %66
  %arrayidx67 = getelementptr inbounds [16 x [33 x float]]* %localmem.LDS_DAT, i32 0, i32 %67, i32 %add65
  %68 = load float* %arrayidx67, align 4
  %69 = getelementptr [2 x float]* %temp.gaispill, i32 %FlatIdx
  %arrayidx68 = getelementptr inbounds [2 x float]* %69, i32 0, i32 1
  store float %68, float* %arrayidx68, align 4
  %70 = getelementptr [2 x float]* %temp.gaispill, i32 %FlatIdx
  %arrayidx69 = getelementptr inbounds [2 x float]* %70, i32 0, i32 0
  %71 = load float* %arrayidx69, align 4
  %sub70 = sub nsw i32 2, %55
  %arrayidx71 = getelementptr inbounds float* %mat_kernel, i32 %sub70
  %72 = load float* %arrayidx71, align 4
  %73 = getelementptr [2 x float]* %temp.gaispill, i32 %FlatIdx
  %arrayidx73 = getelementptr inbounds [2 x float]* %73, i32 0, i32 1
  %74 = load float* %arrayidx73, align 4
  %add74 = add nsw i32 %55, 2
  %arrayidx75 = getelementptr inbounds float* %mat_kernel, i32 %add74
  %75 = load float* %arrayidx75, align 4
  %mul76 = fmul float %74, %75
  %76 = call float @llvm.fmuladd.f32(float %71, float %72, float %mul76)
  %add77 = fadd float %57, %76
  %inc79 = add nsw i32 %55, 1
  %77 = getelementptr i32* %i.3.ex_phi.gaispill, i32 %FlatIdx
  store i32 %inc79, i32* %77
  %78 = getelementptr float* %sum.0.ex_phi.gaispill, i32 %FlatIdx
  store float %add77, float* %78
  br label %for.cond56.r_entry

for.end80.r_entry:                                ; preds = %for.cond56.r_entry
  %79 = getelementptr i32* %.gaispill, i32 %FlatIdx
  %80 = load i32* %79
  %cmp81 = icmp slt i32 %80, %dst_cols
  %81 = getelementptr i32* %.gaispill16, i32 %FlatIdx
  %82 = load i32* %81
  %cmp82 = icmp slt i32 %82, %dst_rows
  %and1 = and i1 %cmp81, %cmp82
  br i1 %and1, label %if.then, label %mxpa.latch

if.then:                                          ; preds = %for.end80.r_entry
  %83 = getelementptr i32* %.gaispill, i32 %FlatIdx
  %84 = load i32* %83
  %85 = getelementptr i32* %.gaispill16, i32 %FlatIdx
  %86 = load i32* %85
  %call84 = call i32 @_Z11_socl_mad24iii(i32 %86, i32 %dst_step_in_pixel, i32 %84) #3
  %arrayidx85 = getelementptr inbounds float* %dst, i32 %call84
  store float %57, float* %arrayidx85, align 4
  br label %mxpa.latch

mxpa.latch:                                       ; preds = %for.end80.r_entry, %if.then
  %IV0_inc = add i32 %IV0, 1
  %CmpResult = icmp ult i32 %IV0_inc, %get_local_size17
  br i1 %CmpResult, label %mxpa.lp.body, label %mxpa.latch18

mxpa.latch18:                                     ; preds = %mxpa.latch
  %IV1_inc = add i32 %IV1, 1
  %CmpResult23 = icmp ult i32 %IV1_inc, %get_local_size22
  br i1 %CmpResult23, label %mxpa.lp.body19, label %mxpa.latch24

mxpa.latch24:                                     ; preds = %mxpa.latch18
  %IV2_inc = add i32 %IV2, 1
  %CmpResult29 = icmp ult i32 %IV2_inc, %get_local_size28
  br i1 %CmpResult29, label %mxpa.lp.body25, label %exit.barrier

exit.barrier:                                     ; preds = %mxpa.latch24
  ret void
}

; Function Attrs: nounwind readnone
declare float @llvm.fmuladd.f32(float, float, float) #2

; Function Attrs: noinline nounwind
define void @row_filter_C4_D5(<4 x float>* noalias %src, <4 x float>* %dst, i32 %dst_cols, i32 %dst_rows, i32 %src_whole_cols, i32 %src_whole_rows, i32 %src_step_in_pixel, i32 %src_offset_x, i32 %src_offset_y, i32 %dst_step_in_pixel, i32 %radiusy, float* %mat_kernel) #0 {
entry.barrier:
  %get_local_size6 = call i32 @get_local_size(i32 0)
  %get_local_size7 = call i32 @get_local_size(i32 1)
  %get_local_size8 = call i32 @get_local_size(i32 2)
  %get_local_size = call i32 @get_local_size(i32 0)
  %get_group_id = call i32 @get_group_id(i32 0)
  %get_global_offset = call i32 @get_global_offset(i32 0)
  %get_local_size2 = call i32 @get_local_size(i32 1)
  %get_group_id3 = call i32 @get_group_id(i32 1)
  %get_global_offset5 = call i32 @get_global_offset(i32 1)
  %get_local_size36 = call i32 @get_local_size(i32 0)
  %get_local_size45 = call i32 @get_local_size(i32 1)
  %get_local_size54 = call i32 @get_local_size(i32 2)
  %get_local_size17 = call i32 @get_local_size(i32 0)
  %get_local_size22 = call i32 @get_local_size(i32 1)
  %get_local_size28 = call i32 @get_local_size(i32 2)
  %localmem.LDS_DAT = alloca [16 x [33 x <4 x float>]], align 16
  %0 = mul i32 %get_local_size8, %get_local_size7
  %Flat3DSize = mul i32 %0, %get_local_size6
  %sum.0.ex_phi.gaispill = alloca <4 x float>, i32 %Flat3DSize, align 64
  %i.3.ex_phi.gaispill = alloca i32, i32 %Flat3DSize, align 64
  %i.2.ex_phi.gaispill = alloca i32, i32 %Flat3DSize, align 64
  %i.1.ex_phi.gaispill = alloca i32, i32 %Flat3DSize, align 64
  %i.0.ex_phi.gaispill = alloca i32, i32 %Flat3DSize, align 64
  %temp.gaispill = alloca [2 x <4 x float>], i32 %Flat3DSize, align 64
  %index.gaispill = alloca [2 x i32], i32 %Flat3DSize, align 64
  %.gaispill = alloca i32, i32 %Flat3DSize, align 64
  %.gaispill16 = alloca i32, i32 %Flat3DSize, align 64
  %call2.gaispill = alloca i32, i32 %Flat3DSize, align 64
  %call3.gaispill = alloca i32, i32 %Flat3DSize, align 64
  br label %mxpa.lp.body49

mxpa.lp.body49:                                   ; preds = %entry.barrier, %mxpa.latch48
  %IV253 = phi i32 [ 0, %entry.barrier ], [ %IV2_inc55, %mxpa.latch48 ]
  br label %mxpa.lp.body40

mxpa.lp.body40:                                   ; preds = %mxpa.lp.body49, %mxpa.latch39
  %IV144 = phi i32 [ 0, %mxpa.lp.body49 ], [ %IV1_inc46, %mxpa.latch39 ]
  br label %mxpa.lp.body31

mxpa.lp.body31:                                   ; preds = %mxpa.lp.body40, %mxpa.latch30
  %IV035 = phi i32 [ 0, %mxpa.lp.body40 ], [ %IV0_inc37, %mxpa.latch30 ]
  %1 = mul i32 %IV144, %get_local_size6
  %2 = mul i32 %IV253, %get_local_size6
  %3 = mul i32 %2, %get_local_size7
  %4 = add i32 %3, %1
  %FlatIdx15 = add i32 %4, %IV035
  %5 = mul i32 %get_local_size, %get_group_id
  %6 = add i32 %5, %IV035
  %7 = add i32 %6, %get_global_offset
  %8 = getelementptr i32* %.gaispill, i32 %FlatIdx15
  store i32 %7, i32* %8
  %9 = mul i32 %get_local_size2, %get_group_id3
  %10 = add i32 %9, %IV144
  %11 = add i32 %10, %get_global_offset5
  %12 = getelementptr i32* %.gaispill16, i32 %FlatIdx15
  store i32 %11, i32* %12
  %13 = getelementptr i32* %call2.gaispill, i32 %FlatIdx15
  store i32 %IV035, i32* %13
  %14 = getelementptr i32* %call3.gaispill, i32 %FlatIdx15
  store i32 %IV144, i32* %14
  %15 = getelementptr i32* %.gaispill, i32 %FlatIdx15
  %16 = load i32* %15
  %add = add nsw i32 %16, %src_offset_x
  %sub = add nsw i32 %add, -2
  %17 = getelementptr i32* %.gaispill16, i32 %FlatIdx15
  %18 = load i32* %17
  %add4 = add nsw i32 %18, %src_offset_y
  %sub5 = sub nsw i32 %add4, %radiusy
  %call6 = call i32 @_Z11_socl_mad24iii(i32 %sub5, i32 %src_step_in_pixel, i32 %sub) #3
  %19 = getelementptr i32* %i.0.ex_phi.gaispill, i32 %FlatIdx15
  store i32 0, i32* %19
  %20 = getelementptr i32* %i.0.ex_phi.gaispill, i32 %FlatIdx15
  br label %for.cond.r_entry

for.cond.r_entry:                                 ; preds = %mxpa.lp.body31, %for.body
  %21 = load i32* %20
  %cmp = icmp slt i32 %21, 2
  br i1 %cmp, label %for.body, label %for.cond31.preheader

for.cond31.preheader:                             ; preds = %for.cond.r_entry
  %22 = getelementptr i32* %i.1.ex_phi.gaispill, i32 %FlatIdx15
  store i32 0, i32* %22
  %23 = getelementptr i32* %i.1.ex_phi.gaispill, i32 %FlatIdx15
  br label %for.cond31.r_entry

for.body:                                         ; preds = %for.cond.r_entry
  %mul = shl nsw i32 %21, 4
  %add7 = add nsw i32 %sub, %mul
  %cmp8 = icmp slt i32 %add7, 0
  %cond = select i1 %cmp8, i32 0, i32 %add7
  %mul11 = shl nsw i32 %21, 4
  %add12 = add nsw i32 %sub, %mul11
  %cmp13 = icmp sge i32 %add12, %src_whole_cols
  %sub15 = add nsw i32 %src_whole_cols, -1
  %cond18 = select i1 %cmp13, i32 %sub15, i32 %cond
  %cmp19 = icmp slt i32 %sub5, 0
  %.sub5 = select i1 %cmp19, i32 0, i32 %sub5
  %cmp24 = icmp sge i32 %sub5, %src_whole_rows
  %sub26 = add nsw i32 %src_whole_rows, -1
  %cond29 = select i1 %cmp24, i32 %sub26, i32 %.sub5
  %call30 = call i32 @_Z11_socl_mad24iii(i32 %cond29, i32 %src_step_in_pixel, i32 %cond18) #3
  %24 = getelementptr [2 x i32]* %index.gaispill, i32 %FlatIdx15
  %arrayidx = getelementptr inbounds [2 x i32]* %24, i32 0, i32 %21
  store i32 %call30, i32* %arrayidx, align 4
  %inc = add nsw i32 %21, 1
  %25 = getelementptr i32* %i.0.ex_phi.gaispill, i32 %FlatIdx15
  store i32 %inc, i32* %25
  br label %for.cond.r_entry

for.cond31.r_entry:                               ; preds = %for.cond31.preheader, %for.body33
  %26 = load i32* %23
  %cmp32 = icmp slt i32 %26, 2
  br i1 %cmp32, label %for.body33, label %for.cond40.preheader

for.cond40.preheader:                             ; preds = %for.cond31.r_entry
  %27 = getelementptr i32* %i.2.ex_phi.gaispill, i32 %FlatIdx15
  store i32 0, i32* %27
  %28 = getelementptr i32* %i.2.ex_phi.gaispill, i32 %FlatIdx15
  br label %for.cond40.r_entry

for.body33:                                       ; preds = %for.cond31.r_entry
  %29 = getelementptr [2 x i32]* %index.gaispill, i32 %FlatIdx15
  %arrayidx34 = getelementptr inbounds [2 x i32]* %29, i32 0, i32 %26
  %30 = load i32* %arrayidx34, align 4
  %arrayidx35 = getelementptr inbounds <4 x float>* %src, i32 %30
  %31 = load <4 x float>* %arrayidx35, align 16
  %32 = getelementptr [2 x <4 x float>]* %temp.gaispill, i32 %FlatIdx15
  %arrayidx36 = getelementptr inbounds [2 x <4 x float>]* %32, i32 0, i32 %26
  store <4 x float> %31, <4 x float>* %arrayidx36, align 16
  %inc38 = add nsw i32 %26, 1
  %33 = getelementptr i32* %i.1.ex_phi.gaispill, i32 %FlatIdx15
  store i32 %inc38, i32* %33
  br label %for.cond31.r_entry

for.cond40.r_entry:                               ; preds = %for.cond40.preheader, %for.body42
  %34 = load i32* %28
  %cmp41 = icmp slt i32 %34, 2
  br i1 %cmp41, label %for.body42, label %mxpa.latch30

for.body42:                                       ; preds = %for.cond40.r_entry
  %35 = getelementptr [2 x <4 x float>]* %temp.gaispill, i32 %FlatIdx15
  %arrayidx43 = getelementptr inbounds [2 x <4 x float>]* %35, i32 0, i32 %34
  %36 = load <4 x float>* %arrayidx43, align 16
  %mul44 = shl nsw i32 %34, 4
  %37 = getelementptr i32* %call2.gaispill, i32 %FlatIdx15
  %38 = load i32* %37
  %add45 = add nsw i32 %38, %mul44
  %39 = getelementptr i32* %call3.gaispill, i32 %FlatIdx15
  %40 = load i32* %39
  %arrayidx47 = getelementptr inbounds [16 x [33 x <4 x float>]]* %localmem.LDS_DAT, i32 0, i32 %40, i32 %add45
  store <4 x float> %36, <4 x float>* %arrayidx47, align 16
  %inc49 = add nsw i32 %34, 1
  %41 = getelementptr i32* %i.2.ex_phi.gaispill, i32 %FlatIdx15
  store i32 %inc49, i32* %41
  br label %for.cond40.r_entry

mxpa.latch30:                                     ; preds = %for.cond40.r_entry
  %IV0_inc37 = add i32 %IV035, 1
  %CmpResult38 = icmp ult i32 %IV0_inc37, %get_local_size36
  br i1 %CmpResult38, label %mxpa.lp.body31, label %mxpa.latch39

mxpa.latch39:                                     ; preds = %mxpa.latch30
  %IV1_inc46 = add i32 %IV144, 1
  %CmpResult47 = icmp ult i32 %IV1_inc46, %get_local_size45
  br i1 %CmpResult47, label %mxpa.lp.body40, label %mxpa.latch48

mxpa.latch48:                                     ; preds = %mxpa.latch39
  %IV2_inc55 = add i32 %IV253, 1
  %CmpResult56 = icmp ult i32 %IV2_inc55, %get_local_size54
  br i1 %CmpResult56, label %mxpa.lp.body49, label %mxpa.lp.body25

mxpa.lp.body25:                                   ; preds = %mxpa.latch24, %mxpa.latch48
  %IV2 = phi i32 [ %IV2_inc, %mxpa.latch24 ], [ 0, %mxpa.latch48 ]
  br label %mxpa.lp.body19

mxpa.lp.body19:                                   ; preds = %mxpa.lp.body25, %mxpa.latch18
  %IV1 = phi i32 [ 0, %mxpa.lp.body25 ], [ %IV1_inc, %mxpa.latch18 ]
  br label %mxpa.lp.body

mxpa.lp.body:                                     ; preds = %mxpa.lp.body19, %mxpa.latch
  %IV0 = phi i32 [ 0, %mxpa.lp.body19 ], [ %IV0_inc, %mxpa.latch ]
  %42 = mul i32 %IV1, %get_local_size6
  %43 = mul i32 %IV2, %get_local_size6
  %44 = mul i32 %43, %get_local_size7
  %45 = add i32 %44, %42
  %FlatIdx = add i32 %45, %IV0
  %46 = getelementptr i32* %call2.gaispill, i32 %FlatIdx
  %47 = load i32* %46
  %add51 = add nsw i32 %47, 2
  %48 = getelementptr i32* %call3.gaispill, i32 %FlatIdx
  %49 = load i32* %48
  %arrayidx53 = getelementptr inbounds [16 x [33 x <4 x float>]]* %localmem.LDS_DAT, i32 0, i32 %49, i32 %add51
  %50 = load <4 x float>* %arrayidx53, align 16
  %arrayidx54 = getelementptr inbounds float* %mat_kernel, i32 2
  %51 = load float* %arrayidx54, align 4
  %splat.splatinsert = insertelement <4 x float> undef, float %51, i32 0
  %splat.splat = shufflevector <4 x float> %splat.splatinsert, <4 x float> undef, <4 x i32> zeroinitializer
  %mul55 = fmul <4 x float> %50, %splat.splat
  %52 = getelementptr i32* %i.3.ex_phi.gaispill, i32 %FlatIdx
  store i32 1, i32* %52
  %53 = getelementptr <4 x float>* %sum.0.ex_phi.gaispill, i32 %FlatIdx
  store <4 x float> %mul55, <4 x float>* %53
  %54 = getelementptr i32* %i.3.ex_phi.gaispill, i32 %FlatIdx
  br label %for.cond56.r_entry

for.cond56.r_entry:                               ; preds = %mxpa.lp.body, %for.body58
  %55 = load i32* %54
  %56 = getelementptr <4 x float>* %sum.0.ex_phi.gaispill, i32 %FlatIdx
  %57 = load <4 x float>* %56
  %cmp57 = icmp slt i32 %55, 3
  br i1 %cmp57, label %for.body58, label %for.end84.r_entry

for.body58:                                       ; preds = %for.cond56.r_entry
  %58 = getelementptr i32* %call2.gaispill, i32 %FlatIdx
  %59 = load i32* %58
  %add59 = add nsw i32 %59, 2
  %sub60 = sub nsw i32 %add59, %55
  %60 = getelementptr i32* %call3.gaispill, i32 %FlatIdx
  %61 = load i32* %60
  %arrayidx62 = getelementptr inbounds [16 x [33 x <4 x float>]]* %localmem.LDS_DAT, i32 0, i32 %61, i32 %sub60
  %62 = load <4 x float>* %arrayidx62, align 16
  %63 = getelementptr [2 x <4 x float>]* %temp.gaispill, i32 %FlatIdx
  %arrayidx63 = getelementptr inbounds [2 x <4 x float>]* %63, i32 0, i32 0
  store <4 x float> %62, <4 x float>* %arrayidx63, align 16
  %64 = getelementptr i32* %call2.gaispill, i32 %FlatIdx
  %65 = load i32* %64
  %add64 = add nsw i32 %65, 2
  %add65 = add nsw i32 %add64, %55
  %66 = getelementptr i32* %call3.gaispill, i32 %FlatIdx
  %67 = load i32* %66
  %arrayidx67 = getelementptr inbounds [16 x [33 x <4 x float>]]* %localmem.LDS_DAT, i32 0, i32 %67, i32 %add65
  %68 = load <4 x float>* %arrayidx67, align 16
  %69 = getelementptr [2 x <4 x float>]* %temp.gaispill, i32 %FlatIdx
  %arrayidx68 = getelementptr inbounds [2 x <4 x float>]* %69, i32 0, i32 1
  store <4 x float> %68, <4 x float>* %arrayidx68, align 16
  %70 = getelementptr [2 x <4 x float>]* %temp.gaispill, i32 %FlatIdx
  %arrayidx69 = getelementptr inbounds [2 x <4 x float>]* %70, i32 0, i32 0
  %71 = load <4 x float>* %arrayidx69, align 16
  %sub70 = sub nsw i32 2, %55
  %arrayidx71 = getelementptr inbounds float* %mat_kernel, i32 %sub70
  %72 = load float* %arrayidx71, align 4
  %splat.splatinsert72 = insertelement <4 x float> undef, float %72, i32 0
  %splat.splat73 = shufflevector <4 x float> %splat.splatinsert72, <4 x float> undef, <4 x i32> zeroinitializer
  %73 = getelementptr [2 x <4 x float>]* %temp.gaispill, i32 %FlatIdx
  %arrayidx75 = getelementptr inbounds [2 x <4 x float>]* %73, i32 0, i32 1
  %74 = load <4 x float>* %arrayidx75, align 16
  %add76 = add nsw i32 %55, 2
  %arrayidx77 = getelementptr inbounds float* %mat_kernel, i32 %add76
  %75 = load float* %arrayidx77, align 4
  %splat.splatinsert78 = insertelement <4 x float> undef, float %75, i32 0
  %splat.splat79 = shufflevector <4 x float> %splat.splatinsert78, <4 x float> undef, <4 x i32> zeroinitializer
  %mul80 = fmul <4 x float> %74, %splat.splat79
  %76 = call <4 x float> @llvm.fmuladd.v4f32(<4 x float> %71, <4 x float> %splat.splat73, <4 x float> %mul80)
  %add81 = fadd <4 x float> %57, %76
  %inc83 = add nsw i32 %55, 1
  %77 = getelementptr i32* %i.3.ex_phi.gaispill, i32 %FlatIdx
  store i32 %inc83, i32* %77
  %78 = getelementptr <4 x float>* %sum.0.ex_phi.gaispill, i32 %FlatIdx
  store <4 x float> %add81, <4 x float>* %78
  br label %for.cond56.r_entry

for.end84.r_entry:                                ; preds = %for.cond56.r_entry
  %79 = getelementptr i32* %.gaispill, i32 %FlatIdx
  %80 = load i32* %79
  %cmp85 = icmp slt i32 %80, %dst_cols
  %81 = getelementptr i32* %.gaispill16, i32 %FlatIdx
  %82 = load i32* %81
  %cmp86 = icmp slt i32 %82, %dst_rows
  %and1 = and i1 %cmp85, %cmp86
  br i1 %and1, label %if.then, label %mxpa.latch

if.then:                                          ; preds = %for.end84.r_entry
  %83 = getelementptr i32* %.gaispill, i32 %FlatIdx
  %84 = load i32* %83
  %85 = getelementptr i32* %.gaispill16, i32 %FlatIdx
  %86 = load i32* %85
  %call88 = call i32 @_Z11_socl_mad24iii(i32 %86, i32 %dst_step_in_pixel, i32 %84) #3
  %arrayidx89 = getelementptr inbounds <4 x float>* %dst, i32 %call88
  store <4 x float> %57, <4 x float>* %arrayidx89, align 16
  br label %mxpa.latch

mxpa.latch:                                       ; preds = %for.end84.r_entry, %if.then
  %IV0_inc = add i32 %IV0, 1
  %CmpResult = icmp ult i32 %IV0_inc, %get_local_size17
  br i1 %CmpResult, label %mxpa.lp.body, label %mxpa.latch18

mxpa.latch18:                                     ; preds = %mxpa.latch
  %IV1_inc = add i32 %IV1, 1
  %CmpResult23 = icmp ult i32 %IV1_inc, %get_local_size22
  br i1 %CmpResult23, label %mxpa.lp.body19, label %mxpa.latch24

mxpa.latch24:                                     ; preds = %mxpa.latch18
  %IV2_inc = add i32 %IV2, 1
  %CmpResult29 = icmp ult i32 %IV2_inc, %get_local_size28
  br i1 %CmpResult29, label %mxpa.lp.body25, label %exit.barrier

exit.barrier:                                     ; preds = %mxpa.latch24
  ret void
}

declare i32 @get_local_size(i32)

declare i32 @get_group_id(i32)

declare i32 @get_global_offset(i32)

attributes #0 = { noinline nounwind "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-frame-pointer-elim-non-leaf"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-frame-pointer-elim-non-leaf"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind readnone }
attributes #3 = { nounwind }

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
