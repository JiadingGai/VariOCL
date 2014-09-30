; ModuleID = 'kernel_26ab1acf10f33a2a19ebb171cec0a30c.a.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@main.A = private unnamed_addr constant [8 x i32] [i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8], align 16
@.str = private unnamed_addr constant [10 x i8] c"sum = %d\0A\00", align 1

; Function Attrs: nounwind uwtable
define i32 @main(i32 %argc, i8** %argv) #0 {
entry:
  %retval = alloca i32, align 4
  %argc.addr = alloca i32, align 4
  %argv.addr = alloca i8**, align 8
  %A = alloca [8 x i32], align 16
  %n = alloca i32, align 4
  %sum = alloca i32, align 4
  %tmp_sum = alloca [512 x i32], align 16
  store i32 0, i32* %retval
  store i32 %argc, i32* %argc.addr, align 4
  store i8** %argv, i8*** %argv.addr, align 8
  %0 = bitcast [8 x i32]* %A to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %0, i8* bitcast ([8 x i32]* @main.A to i8*), i64 32, i32 16, i1 false)
  store i32 8, i32* %n, align 4
  store i32 0, i32* %sum, align 4
  %arraydecay = getelementptr inbounds [8 x i32]* %A, i32 0, i32 0
  %1 = load i32* %n, align 4
  %arraydecay1 = getelementptr inbounds [512 x i32]* %tmp_sum, i32 0, i32 0
  %call = call i32 (i32*, i32, i32*, i32*, ...)* bitcast (i32 (...)* @compute_sum_with_localmem to i32 (i32*, i32, i32*, i32*, ...)*)(i32* %arraydecay, i32 %1, i32* %arraydecay1, i32* %sum)
  %2 = load i32* %sum, align 4
  %call2 = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([10 x i8]* @.str, i32 0, i32 0), i32 %2)
  ret i32 0
}

; Function Attrs: nounwind
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture, i8* nocapture readonly, i64, i32, i1) #1

declare i32 @compute_sum_with_localmem(...) #2

declare i32 @printf(i8*, ...) #2

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind }
attributes #2 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = metadata !{metadata !"clang version 3.4 (tags/RELEASE_34/final)"}
