; ModuleID = '<stdin>'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.tlb_data = type { i32, [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], [3 x i32], i32, i32, i32 }

@TLB = common global %struct.tlb_data zeroinitializer, align 4

; Function Attrs: nounwind uwtable
define void @b(i32* %A, i32* %B, i32* %C, i32 %n) #0 {
entry.barrier:
  %get_local_size = call i32 @get_local_size(i32 0)
  %get_local_size1 = call i32 @get_local_size(i32 1)
  %get_local_size2 = call i32 @get_local_size(i32 2)
  %0 = mul i32 %get_local_size2, %get_local_size1
  %Flat3DSize = mul i32 %0, %get_local_size
  %add7.3Dspill = alloca i32, i32 %Flat3DSize
  %k.0.3Dspill = alloca i32, i32 %Flat3DSize
  %j.0.3Dspill = alloca i32, i32 %Flat3DSize
  %i.0.3Dspill = alloca i32, i32 %Flat3DSize
  %call4.3Dspill = alloca i32, i32 %Flat3DSize
  %call3.3Dspill = alloca i32, i32 %Flat3DSize
  %call2.3Dspill = alloca i32, i32 %Flat3DSize
  %call1.3Dspill = alloca i32, i32 %Flat3DSize
  %call.3Dspill = alloca i32, i32 %Flat3DSize
  %k.0.3Dspill130 = alloca i32, i32 %Flat3DSize
  %j.0.3Dspill145 = alloca i32, i32 %Flat3DSize
  %i.0.3Dspill160 = alloca i32, i32 %Flat3DSize
  %"value spilling alloca point" = bitcast i32 0 to i32
  call void @barrier(i32 0)
  br label %entry

entry:                                            ; preds = %entry.barrier
  %call = call i32 @get_local_size(i32 0) #2
  %get_local_id125 = call i32 @get_local_id(i32 0)
  %get_local_id126 = call i32 @get_local_id(i32 1)
  %get_local_id127 = call i32 @get_local_id(i32 2)
  %1 = mul i32 %get_local_id126, %get_local_size
  %2 = mul i32 %get_local_id127, %get_local_size
  %3 = mul i32 %2, %get_local_size1
  %4 = add i32 %3, %1
  %FlatIdx128 = add i32 %4, %get_local_id125
  %call.3Dspill.gep129 = getelementptr i32* %call.3Dspill, i32 %FlatIdx128
  store i32 %call, i32* %call.3Dspill.gep129
  %call1 = call i32 @get_local_size(i32 1) #2
  %get_local_id104 = call i32 @get_local_id(i32 0)
  %get_local_id105 = call i32 @get_local_id(i32 1)
  %get_local_id106 = call i32 @get_local_id(i32 2)
  %5 = mul i32 %get_local_id105, %get_local_size
  %6 = mul i32 %get_local_id106, %get_local_size
  %7 = mul i32 %6, %get_local_size1
  %8 = add i32 %7, %5
  %FlatIdx107 = add i32 %8, %get_local_id104
  %call1.3Dspill.gep108 = getelementptr i32* %call1.3Dspill, i32 %FlatIdx107
  store i32 %call1, i32* %call1.3Dspill.gep108
  %get_local_id119 = call i32 @get_local_id(i32 0)
  %get_local_id120 = call i32 @get_local_id(i32 1)
  %get_local_id121 = call i32 @get_local_id(i32 2)
  %9 = mul i32 %get_local_id120, %get_local_size
  %10 = mul i32 %get_local_id121, %get_local_size
  %11 = mul i32 %10, %get_local_size1
  %12 = add i32 %11, %9
  %FlatIdx122 = add i32 %12, %get_local_id119
  %call.3Dspill.gep123 = getelementptr i32* %call.3Dspill, i32 %FlatIdx122
  %call.3Dspill3dreload124 = load i32* %call.3Dspill.gep123
  %cmp = icmp sgt i32 %call.3Dspill3dreload124, 0
  br i1 %cmp, label %if.then, label %entry.if.end.mxpa.b4.barrier_crit_edge

entry.if.end.mxpa.b4.barrier_crit_edge:           ; preds = %entry
  %get_local_id135 = call i32 @get_local_id(i32 0)
  %get_local_id136 = call i32 @get_local_id(i32 1)
  %get_local_id137 = call i32 @get_local_id(i32 2)
  %13 = mul i32 %get_local_id136, %get_local_size
  %14 = mul i32 %get_local_id137, %get_local_size
  %15 = mul i32 %14, %get_local_size1
  %16 = add i32 %15, %13
  %FlatIdx138 = add i32 %16, %get_local_id135
  %k.0.3Dspill130.gep139 = getelementptr i32* %k.0.3Dspill130, i32 %FlatIdx138
  store i32 0, i32* %k.0.3Dspill130.gep139
  %get_local_id150 = call i32 @get_local_id(i32 0)
  %get_local_id151 = call i32 @get_local_id(i32 1)
  %get_local_id152 = call i32 @get_local_id(i32 2)
  %17 = mul i32 %get_local_id151, %get_local_size
  %18 = mul i32 %get_local_id152, %get_local_size
  %19 = mul i32 %18, %get_local_size1
  %20 = add i32 %19, %17
  %FlatIdx153 = add i32 %20, %get_local_id150
  %j.0.3Dspill145.gep154 = getelementptr i32* %j.0.3Dspill145, i32 %FlatIdx153
  store i32 0, i32* %j.0.3Dspill145.gep154
  %get_local_id165 = call i32 @get_local_id(i32 0)
  %get_local_id166 = call i32 @get_local_id(i32 1)
  %get_local_id167 = call i32 @get_local_id(i32 2)
  %21 = mul i32 %get_local_id166, %get_local_size
  %22 = mul i32 %get_local_id167, %get_local_size
  %23 = mul i32 %22, %get_local_size1
  %24 = add i32 %23, %21
  %FlatIdx168 = add i32 %24, %get_local_id165
  %i.0.3Dspill160.gep169 = getelementptr i32* %i.0.3Dspill160, i32 %FlatIdx168
  store i32 0, i32* %i.0.3Dspill160.gep169
  br label %if.end.mxpa.b4.barrier

if.then:                                          ; preds = %entry
  %call2 = call i32 @get_local_id(i32 0) #2
  %get_local_id95 = call i32 @get_local_id(i32 0)
  %get_local_id96 = call i32 @get_local_id(i32 1)
  %get_local_id97 = call i32 @get_local_id(i32 2)
  %25 = mul i32 %get_local_id96, %get_local_size
  %26 = mul i32 %get_local_id97, %get_local_size
  %27 = mul i32 %26, %get_local_size1
  %28 = add i32 %27, %25
  %FlatIdx98 = add i32 %28, %get_local_id95
  %call2.3Dspill.gep99 = getelementptr i32* %call2.3Dspill, i32 %FlatIdx98
  store i32 %call2, i32* %call2.3Dspill.gep99
  %call3 = call i32 @get_local_id(i32 1) #2
  %get_local_id86 = call i32 @get_local_id(i32 0)
  %get_local_id87 = call i32 @get_local_id(i32 1)
  %get_local_id88 = call i32 @get_local_id(i32 2)
  %29 = mul i32 %get_local_id87, %get_local_size
  %30 = mul i32 %get_local_id88, %get_local_size
  %31 = mul i32 %30, %get_local_size1
  %32 = add i32 %31, %29
  %FlatIdx89 = add i32 %32, %get_local_id86
  %call3.3Dspill.gep90 = getelementptr i32* %call3.3Dspill, i32 %FlatIdx89
  store i32 %call3, i32* %call3.3Dspill.gep90
  %call4 = call i32 @get_local_id(i32 2) #2
  %get_local_id77 = call i32 @get_local_id(i32 0)
  %get_local_id78 = call i32 @get_local_id(i32 1)
  %get_local_id79 = call i32 @get_local_id(i32 2)
  %33 = mul i32 %get_local_id78, %get_local_size
  %34 = mul i32 %get_local_id79, %get_local_size
  %35 = mul i32 %34, %get_local_size1
  %36 = add i32 %35, %33
  %FlatIdx80 = add i32 %36, %get_local_id77
  %call4.3Dspill.gep81 = getelementptr i32* %call4.3Dspill, i32 %FlatIdx80
  store i32 %call4, i32* %call4.3Dspill.gep81
  %get_local_id73 = call i32 @get_local_id(i32 0)
  %get_local_id74 = call i32 @get_local_id(i32 1)
  %get_local_id75 = call i32 @get_local_id(i32 2)
  %37 = mul i32 %get_local_id74, %get_local_size
  %38 = mul i32 %get_local_id75, %get_local_size
  %39 = mul i32 %38, %get_local_size1
  %40 = add i32 %39, %37
  %FlatIdx76 = add i32 %40, %get_local_id73
  %call4.3Dspill.gep = getelementptr i32* %call4.3Dspill, i32 %FlatIdx76
  %call4.3Dspill3dreload = load i32* %call4.3Dspill.gep
  %get_local_id82 = call i32 @get_local_id(i32 0)
  %get_local_id83 = call i32 @get_local_id(i32 1)
  %get_local_id84 = call i32 @get_local_id(i32 2)
  %41 = mul i32 %get_local_id83, %get_local_size
  %42 = mul i32 %get_local_id84, %get_local_size
  %43 = mul i32 %42, %get_local_size1
  %44 = add i32 %43, %41
  %FlatIdx85 = add i32 %44, %get_local_id82
  %call3.3Dspill.gep = getelementptr i32* %call3.3Dspill, i32 %FlatIdx85
  %call3.3Dspill3dreload = load i32* %call3.3Dspill.gep
  %get_local_id91 = call i32 @get_local_id(i32 0)
  %get_local_id92 = call i32 @get_local_id(i32 1)
  %get_local_id93 = call i32 @get_local_id(i32 2)
  %45 = mul i32 %get_local_id92, %get_local_size
  %46 = mul i32 %get_local_id93, %get_local_size
  %47 = mul i32 %46, %get_local_size1
  %48 = add i32 %47, %45
  %FlatIdx94 = add i32 %48, %get_local_id91
  %call2.3Dspill.gep = getelementptr i32* %call2.3Dspill, i32 %FlatIdx94
  %call2.3Dspill3dreload = load i32* %call2.3Dspill.gep
  %get_local_id131 = call i32 @get_local_id(i32 0)
  %get_local_id132 = call i32 @get_local_id(i32 1)
  %get_local_id133 = call i32 @get_local_id(i32 2)
  %49 = mul i32 %get_local_id132, %get_local_size
  %50 = mul i32 %get_local_id133, %get_local_size
  %51 = mul i32 %50, %get_local_size1
  %52 = add i32 %51, %49
  %FlatIdx134 = add i32 %52, %get_local_id131
  %k.0.3Dspill130.gep = getelementptr i32* %k.0.3Dspill130, i32 %FlatIdx134
  store i32 %call4.3Dspill3dreload, i32* %k.0.3Dspill130.gep
  %get_local_id146 = call i32 @get_local_id(i32 0)
  %get_local_id147 = call i32 @get_local_id(i32 1)
  %get_local_id148 = call i32 @get_local_id(i32 2)
  %53 = mul i32 %get_local_id147, %get_local_size
  %54 = mul i32 %get_local_id148, %get_local_size
  %55 = mul i32 %54, %get_local_size1
  %56 = add i32 %55, %53
  %FlatIdx149 = add i32 %56, %get_local_id146
  %j.0.3Dspill145.gep = getelementptr i32* %j.0.3Dspill145, i32 %FlatIdx149
  store i32 %call3.3Dspill3dreload, i32* %j.0.3Dspill145.gep
  %get_local_id161 = call i32 @get_local_id(i32 0)
  %get_local_id162 = call i32 @get_local_id(i32 1)
  %get_local_id163 = call i32 @get_local_id(i32 2)
  %57 = mul i32 %get_local_id162, %get_local_size
  %58 = mul i32 %get_local_id163, %get_local_size
  %59 = mul i32 %58, %get_local_size1
  %60 = add i32 %59, %57
  %FlatIdx164 = add i32 %60, %get_local_id161
  %i.0.3Dspill160.gep = getelementptr i32* %i.0.3Dspill160, i32 %FlatIdx164
  store i32 %call2.3Dspill3dreload, i32* %i.0.3Dspill160.gep
  br label %if.end.mxpa.b4.barrier

if.end.mxpa.b4.barrier:                           ; preds = %entry.if.end.mxpa.b4.barrier_crit_edge, %if.then
  %get_local_id170 = call i32 @get_local_id(i32 0)
  %get_local_id171 = call i32 @get_local_id(i32 1)
  %get_local_id172 = call i32 @get_local_id(i32 2)
  %61 = mul i32 %get_local_id171, %get_local_size
  %62 = mul i32 %get_local_id172, %get_local_size
  %63 = mul i32 %62, %get_local_size1
  %64 = add i32 %63, %61
  %FlatIdx173 = add i32 %64, %get_local_id170
  %i.0.3Dspill160.gep174 = getelementptr i32* %i.0.3Dspill160, i32 %FlatIdx173
  %i.0.3Dspill1603dreload = load i32* %i.0.3Dspill160.gep174
  %get_local_id155 = call i32 @get_local_id(i32 0)
  %get_local_id156 = call i32 @get_local_id(i32 1)
  %get_local_id157 = call i32 @get_local_id(i32 2)
  %65 = mul i32 %get_local_id156, %get_local_size
  %66 = mul i32 %get_local_id157, %get_local_size
  %67 = mul i32 %66, %get_local_size1
  %68 = add i32 %67, %65
  %FlatIdx158 = add i32 %68, %get_local_id155
  %j.0.3Dspill145.gep159 = getelementptr i32* %j.0.3Dspill145, i32 %FlatIdx158
  %j.0.3Dspill1453dreload = load i32* %j.0.3Dspill145.gep159
  %get_local_id140 = call i32 @get_local_id(i32 0)
  %get_local_id141 = call i32 @get_local_id(i32 1)
  %get_local_id142 = call i32 @get_local_id(i32 2)
  %69 = mul i32 %get_local_id141, %get_local_size
  %70 = mul i32 %get_local_id142, %get_local_size
  %71 = mul i32 %70, %get_local_size1
  %72 = add i32 %71, %69
  %FlatIdx143 = add i32 %72, %get_local_id140
  %k.0.3Dspill130.gep144 = getelementptr i32* %k.0.3Dspill130, i32 %FlatIdx143
  %k.0.3Dspill1303dreload = load i32* %k.0.3Dspill130.gep144
  %get_local_id68 = call i32 @get_local_id(i32 0)
  %get_local_id69 = call i32 @get_local_id(i32 1)
  %get_local_id70 = call i32 @get_local_id(i32 2)
  %73 = mul i32 %get_local_id69, %get_local_size
  %74 = mul i32 %get_local_id70, %get_local_size
  %75 = mul i32 %74, %get_local_size1
  %76 = add i32 %75, %73
  %FlatIdx71 = add i32 %76, %get_local_id68
  %i.0.3Dspill.gep72 = getelementptr i32* %i.0.3Dspill, i32 %FlatIdx71
  store i32 %i.0.3Dspill1603dreload, i32* %i.0.3Dspill.gep72
  %get_local_id53 = call i32 @get_local_id(i32 0)
  %get_local_id54 = call i32 @get_local_id(i32 1)
  %get_local_id55 = call i32 @get_local_id(i32 2)
  %77 = mul i32 %get_local_id54, %get_local_size
  %78 = mul i32 %get_local_id55, %get_local_size
  %79 = mul i32 %78, %get_local_size1
  %80 = add i32 %79, %77
  %FlatIdx56 = add i32 %80, %get_local_id53
  %j.0.3Dspill.gep57 = getelementptr i32* %j.0.3Dspill, i32 %FlatIdx56
  store i32 %j.0.3Dspill1453dreload, i32* %j.0.3Dspill.gep57
  %get_local_id38 = call i32 @get_local_id(i32 0)
  %get_local_id39 = call i32 @get_local_id(i32 1)
  %get_local_id40 = call i32 @get_local_id(i32 2)
  %81 = mul i32 %get_local_id39, %get_local_size
  %82 = mul i32 %get_local_id40, %get_local_size
  %83 = mul i32 %82, %get_local_size1
  %84 = add i32 %83, %81
  %FlatIdx41 = add i32 %84, %get_local_id38
  %k.0.3Dspill.gep42 = getelementptr i32* %k.0.3Dspill, i32 %FlatIdx41
  store i32 %k.0.3Dspill1303dreload, i32* %k.0.3Dspill.gep42
  br label %if.end

if.end:                                           ; preds = %if.end.mxpa.b4.barrier
  call void @barrier(i32 0) #2
  br label %if.end.mxpa.after.barrier

if.end.mxpa.after.barrier:                        ; preds = %if.end
  %get_local_id32 = call i32 @get_local_id(i32 0)
  %get_local_id33 = call i32 @get_local_id(i32 1)
  %get_local_id34 = call i32 @get_local_id(i32 2)
  %85 = mul i32 %get_local_id33, %get_local_size
  %86 = mul i32 %get_local_id34, %get_local_size
  %87 = mul i32 %86, %get_local_size1
  %88 = add i32 %87, %85
  %FlatIdx35 = add i32 %88, %get_local_id32
  %k.0.3Dspill.gep36 = getelementptr i32* %k.0.3Dspill, i32 %FlatIdx35
  %k.0.3Dspill3dreload37 = load i32* %k.0.3Dspill.gep36
  %get_local_id113 = call i32 @get_local_id(i32 0)
  %get_local_id114 = call i32 @get_local_id(i32 1)
  %get_local_id115 = call i32 @get_local_id(i32 2)
  %89 = mul i32 %get_local_id114, %get_local_size
  %90 = mul i32 %get_local_id115, %get_local_size
  %91 = mul i32 %90, %get_local_size1
  %92 = add i32 %91, %89
  %FlatIdx116 = add i32 %92, %get_local_id113
  %call.3Dspill.gep117 = getelementptr i32* %call.3Dspill, i32 %FlatIdx116
  %call.3Dspill3dreload118 = load i32* %call.3Dspill.gep117
  %mul = mul nsw i32 %k.0.3Dspill3dreload37, %call.3Dspill3dreload118
  %get_local_id100 = call i32 @get_local_id(i32 0)
  %get_local_id101 = call i32 @get_local_id(i32 1)
  %get_local_id102 = call i32 @get_local_id(i32 2)
  %93 = mul i32 %get_local_id101, %get_local_size
  %94 = mul i32 %get_local_id102, %get_local_size
  %95 = mul i32 %94, %get_local_size1
  %96 = add i32 %95, %93
  %FlatIdx103 = add i32 %96, %get_local_id100
  %call1.3Dspill.gep = getelementptr i32* %call1.3Dspill, i32 %FlatIdx103
  %call1.3Dspill3dreload = load i32* %call1.3Dspill.gep
  %mul5 = mul nsw i32 %mul, %call1.3Dspill3dreload
  %get_local_id47 = call i32 @get_local_id(i32 0)
  %get_local_id48 = call i32 @get_local_id(i32 1)
  %get_local_id49 = call i32 @get_local_id(i32 2)
  %97 = mul i32 %get_local_id48, %get_local_size
  %98 = mul i32 %get_local_id49, %get_local_size
  %99 = mul i32 %98, %get_local_size1
  %100 = add i32 %99, %97
  %FlatIdx50 = add i32 %100, %get_local_id47
  %j.0.3Dspill.gep51 = getelementptr i32* %j.0.3Dspill, i32 %FlatIdx50
  %j.0.3Dspill3dreload52 = load i32* %j.0.3Dspill.gep51
  %get_local_id109 = call i32 @get_local_id(i32 0)
  %get_local_id110 = call i32 @get_local_id(i32 1)
  %get_local_id111 = call i32 @get_local_id(i32 2)
  %101 = mul i32 %get_local_id110, %get_local_size
  %102 = mul i32 %get_local_id111, %get_local_size
  %103 = mul i32 %102, %get_local_size1
  %104 = add i32 %103, %101
  %FlatIdx112 = add i32 %104, %get_local_id109
  %call.3Dspill.gep = getelementptr i32* %call.3Dspill, i32 %FlatIdx112
  %call.3Dspill3dreload = load i32* %call.3Dspill.gep
  %mul6 = mul nsw i32 %j.0.3Dspill3dreload52, %call.3Dspill3dreload
  %add = add nsw i32 %mul5, %mul6
  %get_local_id62 = call i32 @get_local_id(i32 0)
  %get_local_id63 = call i32 @get_local_id(i32 1)
  %get_local_id64 = call i32 @get_local_id(i32 2)
  %105 = mul i32 %get_local_id63, %get_local_size
  %106 = mul i32 %get_local_id64, %get_local_size
  %107 = mul i32 %106, %get_local_size1
  %108 = add i32 %107, %105
  %FlatIdx65 = add i32 %108, %get_local_id62
  %i.0.3Dspill.gep66 = getelementptr i32* %i.0.3Dspill, i32 %FlatIdx65
  %i.0.3Dspill3dreload67 = load i32* %i.0.3Dspill.gep66
  %add7 = add nsw i32 %add, %i.0.3Dspill3dreload67
  %get_local_id23 = call i32 @get_local_id(i32 0)
  %get_local_id24 = call i32 @get_local_id(i32 1)
  %get_local_id25 = call i32 @get_local_id(i32 2)
  %109 = mul i32 %get_local_id24, %get_local_size
  %110 = mul i32 %get_local_id25, %get_local_size
  %111 = mul i32 %110, %get_local_size1
  %112 = add i32 %111, %109
  %FlatIdx26 = add i32 %112, %get_local_id23
  %add7.3Dspill.gep27 = getelementptr i32* %add7.3Dspill, i32 %FlatIdx26
  store i32 %add7, i32* %add7.3Dspill.gep27
  %get_local_id17 = call i32 @get_local_id(i32 0)
  %get_local_id18 = call i32 @get_local_id(i32 1)
  %get_local_id19 = call i32 @get_local_id(i32 2)
  %113 = mul i32 %get_local_id18, %get_local_size
  %114 = mul i32 %get_local_id19, %get_local_size
  %115 = mul i32 %114, %get_local_size1
  %116 = add i32 %115, %113
  %FlatIdx20 = add i32 %116, %get_local_id17
  %add7.3Dspill.gep21 = getelementptr i32* %add7.3Dspill, i32 %FlatIdx20
  %add7.3Dspill3dreload22 = load i32* %add7.3Dspill.gep21
  %cmp8 = icmp slt i32 %add7.3Dspill3dreload22, %n
  br i1 %cmp8, label %if.then9, label %if.end.mxpa.after.barrier.if.end14_crit_edge

if.end.mxpa.after.barrier.if.end14_crit_edge:     ; preds = %if.end.mxpa.after.barrier
  br label %if.end14

if.then9:                                         ; preds = %if.end.mxpa.after.barrier
  %get_local_id11 = call i32 @get_local_id(i32 0)
  %get_local_id12 = call i32 @get_local_id(i32 1)
  %get_local_id13 = call i32 @get_local_id(i32 2)
  %117 = mul i32 %get_local_id12, %get_local_size
  %118 = mul i32 %get_local_id13, %get_local_size
  %119 = mul i32 %118, %get_local_size1
  %120 = add i32 %119, %117
  %FlatIdx14 = add i32 %120, %get_local_id11
  %add7.3Dspill.gep15 = getelementptr i32* %add7.3Dspill, i32 %FlatIdx14
  %add7.3Dspill3dreload16 = load i32* %add7.3Dspill.gep15
  %idxprom = sext i32 %add7.3Dspill3dreload16 to i64
  %arrayidx = getelementptr inbounds i32* %A, i64 %idxprom
  %get_local_id58 = call i32 @get_local_id(i32 0)
  %get_local_id59 = call i32 @get_local_id(i32 1)
  %get_local_id60 = call i32 @get_local_id(i32 2)
  %121 = mul i32 %get_local_id59, %get_local_size
  %122 = mul i32 %get_local_id60, %get_local_size
  %123 = mul i32 %122, %get_local_size1
  %124 = add i32 %123, %121
  %FlatIdx61 = add i32 %124, %get_local_id58
  %i.0.3Dspill.gep = getelementptr i32* %i.0.3Dspill, i32 %FlatIdx61
  %i.0.3Dspill3dreload = load i32* %i.0.3Dspill.gep
  store i32 %i.0.3Dspill3dreload, i32* %arrayidx, align 4
  %get_local_id5 = call i32 @get_local_id(i32 0)
  %get_local_id6 = call i32 @get_local_id(i32 1)
  %get_local_id7 = call i32 @get_local_id(i32 2)
  %125 = mul i32 %get_local_id6, %get_local_size
  %126 = mul i32 %get_local_id7, %get_local_size
  %127 = mul i32 %126, %get_local_size1
  %128 = add i32 %127, %125
  %FlatIdx8 = add i32 %128, %get_local_id5
  %add7.3Dspill.gep9 = getelementptr i32* %add7.3Dspill, i32 %FlatIdx8
  %add7.3Dspill3dreload10 = load i32* %add7.3Dspill.gep9
  %idxprom10 = sext i32 %add7.3Dspill3dreload10 to i64
  %arrayidx11 = getelementptr inbounds i32* %B, i64 %idxprom10
  %get_local_id43 = call i32 @get_local_id(i32 0)
  %get_local_id44 = call i32 @get_local_id(i32 1)
  %get_local_id45 = call i32 @get_local_id(i32 2)
  %129 = mul i32 %get_local_id44, %get_local_size
  %130 = mul i32 %get_local_id45, %get_local_size
  %131 = mul i32 %130, %get_local_size1
  %132 = add i32 %131, %129
  %FlatIdx46 = add i32 %132, %get_local_id43
  %j.0.3Dspill.gep = getelementptr i32* %j.0.3Dspill, i32 %FlatIdx46
  %j.0.3Dspill3dreload = load i32* %j.0.3Dspill.gep
  store i32 %j.0.3Dspill3dreload, i32* %arrayidx11, align 4
  %get_local_id = call i32 @get_local_id(i32 0)
  %get_local_id3 = call i32 @get_local_id(i32 1)
  %get_local_id4 = call i32 @get_local_id(i32 2)
  %133 = mul i32 %get_local_id3, %get_local_size
  %134 = mul i32 %get_local_id4, %get_local_size
  %135 = mul i32 %134, %get_local_size1
  %136 = add i32 %135, %133
  %FlatIdx = add i32 %136, %get_local_id
  %add7.3Dspill.gep = getelementptr i32* %add7.3Dspill, i32 %FlatIdx
  %add7.3Dspill3dreload = load i32* %add7.3Dspill.gep
  %idxprom12 = sext i32 %add7.3Dspill3dreload to i64
  %arrayidx13 = getelementptr inbounds i32* %C, i64 %idxprom12
  %get_local_id28 = call i32 @get_local_id(i32 0)
  %get_local_id29 = call i32 @get_local_id(i32 1)
  %get_local_id30 = call i32 @get_local_id(i32 2)
  %137 = mul i32 %get_local_id29, %get_local_size
  %138 = mul i32 %get_local_id30, %get_local_size
  %139 = mul i32 %138, %get_local_size1
  %140 = add i32 %139, %137
  %FlatIdx31 = add i32 %140, %get_local_id28
  %k.0.3Dspill.gep = getelementptr i32* %k.0.3Dspill, i32 %FlatIdx31
  %k.0.3Dspill3dreload = load i32* %k.0.3Dspill.gep
  store i32 %k.0.3Dspill3dreload, i32* %arrayidx13, align 4
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
