; ModuleID = 'mm.a.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@main.aMatrix = private unnamed_addr constant [16 x i32] [i32 1, i32 4, i32 3, i32 2, i32 2, i32 5, i32 6, i32 7, i32 3, i32 6, i32 8, i32 3, i32 1, i32 5, i32 3, i32 8], align 16
@main.bMatrix = private unnamed_addr constant [16 x i32] [i32 7, i32 8, i32 9, i32 4, i32 7, i32 1, i32 3, i32 2, i32 6, i32 3, i32 7, i32 1, i32 7, i32 3, i32 5, i32 2], align 16
@.str = private unnamed_addr constant [8 x i8] c"%d(%d) \00", align 1
@.str1 = private unnamed_addr constant [2 x i8] c"\0A\00", align 1
@.str2 = private unnamed_addr constant [31 x i8] c"Matrix Multiplication FAILED!\0A\00", align 1
@.str3 = private unnamed_addr constant [31 x i8] c"Matrix Multiplication PASSED!\0A\00", align 1

; Function Attrs: nounwind uwtable
define i32 @main(i32 %argc, i8** %argv) #0 {
entry:
  %retval = alloca i32, align 4
  %argc.addr = alloca i32, align 4
  %argv.addr = alloca i8**, align 8
  %wA = alloca i32, align 4
  %wB = alloca i32, align 4
  %aMatrix = alloca [16 x i32], align 16
  %bMatrix = alloca [16 x i32], align 16
  %product = alloca [16 x i32], align 16
  %golden = alloca [16 x i32], align 16
  %IsPassed = alloca i32, align 4
  %row = alloca i32, align 4
  %col = alloca i32, align 4
  %inner = alloca i32, align 4
  store i32 0, i32* %retval
  store i32 %argc, i32* %argc.addr, align 4
  store i8** %argv, i8*** %argv.addr, align 8
  store i32 4, i32* %wA, align 4
  store i32 4, i32* %wB, align 4
  %0 = bitcast [16 x i32]* %aMatrix to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %0, i8* bitcast ([16 x i32]* @main.aMatrix to i8*), i64 64, i32 16, i1 false)
  %1 = bitcast [16 x i32]* %bMatrix to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %1, i8* bitcast ([16 x i32]* @main.bMatrix to i8*), i64 64, i32 16, i1 false)
  %2 = bitcast [16 x i32]* %product to i8*
  call void @llvm.memset.p0i8.i64(i8* %2, i8 0, i64 64, i32 16, i1 false)
  %3 = bitcast [16 x i32]* %golden to i8*
  call void @llvm.memset.p0i8.i64(i8* %3, i8 0, i64 64, i32 16, i1 false)
  %arraydecay = getelementptr inbounds [16 x i32]* %product, i32 0, i32 0
  %arraydecay1 = getelementptr inbounds [16 x i32]* %aMatrix, i32 0, i32 0
  %arraydecay2 = getelementptr inbounds [16 x i32]* %bMatrix, i32 0, i32 0
  %4 = load i32* %wA, align 4
  %5 = load i32* %wB, align 4
  %call = call i32 (i32*, i32*, i32*, i32, i32, ...)* bitcast (i32 (...)* @matrixMul to i32 (i32*, i32*, i32*, i32, i32, ...)*)(i32* %arraydecay, i32* %arraydecay1, i32* %arraydecay2, i32 %4, i32 %5)
  store i32 1, i32* %IsPassed, align 4
  store i32 0, i32* %row, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc41, %entry
  %6 = load i32* %row, align 4
  %cmp = icmp slt i32 %6, 4
  br i1 %cmp, label %for.body, label %for.end43

for.body:                                         ; preds = %for.cond
  store i32 0, i32* %col, align 4
  br label %for.cond3

for.cond3:                                        ; preds = %for.inc37, %for.body
  %7 = load i32* %col, align 4
  %cmp4 = icmp slt i32 %7, 4
  br i1 %cmp4, label %for.body5, label %for.end39

for.body5:                                        ; preds = %for.cond3
  store i32 0, i32* %inner, align 4
  br label %for.cond6

for.cond6:                                        ; preds = %for.inc, %for.body5
  %8 = load i32* %inner, align 4
  %cmp7 = icmp slt i32 %8, 4
  br i1 %cmp7, label %for.body8, label %for.end

for.body8:                                        ; preds = %for.cond6
  %9 = load i32* %row, align 4
  %mul = mul nsw i32 %9, 4
  %10 = load i32* %inner, align 4
  %add = add nsw i32 %mul, %10
  %idxprom = sext i32 %add to i64
  %arrayidx = getelementptr inbounds [16 x i32]* %aMatrix, i32 0, i64 %idxprom
  %11 = load i32* %arrayidx, align 4
  %12 = load i32* %inner, align 4
  %mul9 = mul nsw i32 %12, 4
  %13 = load i32* %col, align 4
  %add10 = add nsw i32 %mul9, %13
  %idxprom11 = sext i32 %add10 to i64
  %arrayidx12 = getelementptr inbounds [16 x i32]* %bMatrix, i32 0, i64 %idxprom11
  %14 = load i32* %arrayidx12, align 4
  %mul13 = mul nsw i32 %11, %14
  %15 = load i32* %row, align 4
  %mul14 = mul nsw i32 %15, 4
  %16 = load i32* %col, align 4
  %add15 = add nsw i32 %mul14, %16
  %idxprom16 = sext i32 %add15 to i64
  %arrayidx17 = getelementptr inbounds [16 x i32]* %golden, i32 0, i64 %idxprom16
  %17 = load i32* %arrayidx17, align 4
  %add18 = add nsw i32 %17, %mul13
  store i32 %add18, i32* %arrayidx17, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body8
  %18 = load i32* %inner, align 4
  %inc = add nsw i32 %18, 1
  store i32 %inc, i32* %inner, align 4
  br label %for.cond6

for.end:                                          ; preds = %for.cond6
  %19 = load i32* %row, align 4
  %mul19 = mul nsw i32 %19, 4
  %20 = load i32* %col, align 4
  %add20 = add nsw i32 %mul19, %20
  %idxprom21 = sext i32 %add20 to i64
  %arrayidx22 = getelementptr inbounds [16 x i32]* %product, i32 0, i64 %idxprom21
  %21 = load i32* %arrayidx22, align 4
  %22 = load i32* %row, align 4
  %mul23 = mul nsw i32 %22, 4
  %23 = load i32* %col, align 4
  %add24 = add nsw i32 %mul23, %23
  %idxprom25 = sext i32 %add24 to i64
  %arrayidx26 = getelementptr inbounds [16 x i32]* %golden, i32 0, i64 %idxprom25
  %24 = load i32* %arrayidx26, align 4
  %call27 = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([8 x i8]* @.str, i32 0, i32 0), i32 %21, i32 %24)
  %25 = load i32* %row, align 4
  %mul28 = mul nsw i32 %25, 4
  %26 = load i32* %col, align 4
  %add29 = add nsw i32 %mul28, %26
  %idxprom30 = sext i32 %add29 to i64
  %arrayidx31 = getelementptr inbounds [16 x i32]* %product, i32 0, i64 %idxprom30
  %27 = load i32* %arrayidx31, align 4
  %28 = load i32* %row, align 4
  %mul32 = mul nsw i32 %28, 4
  %29 = load i32* %col, align 4
  %add33 = add nsw i32 %mul32, %29
  %idxprom34 = sext i32 %add33 to i64
  %arrayidx35 = getelementptr inbounds [16 x i32]* %golden, i32 0, i64 %idxprom34
  %30 = load i32* %arrayidx35, align 4
  %cmp36 = icmp ne i32 %27, %30
  br i1 %cmp36, label %if.then, label %if.end

if.then:                                          ; preds = %for.end
  store i32 0, i32* %IsPassed, align 4
  br label %if.end

if.end:                                           ; preds = %if.then, %for.end
  br label %for.inc37

for.inc37:                                        ; preds = %if.end
  %31 = load i32* %col, align 4
  %inc38 = add nsw i32 %31, 1
  store i32 %inc38, i32* %col, align 4
  br label %for.cond3

for.end39:                                        ; preds = %for.cond3
  %call40 = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([2 x i8]* @.str1, i32 0, i32 0))
  br label %for.inc41

for.inc41:                                        ; preds = %for.end39
  %32 = load i32* %row, align 4
  %inc42 = add nsw i32 %32, 1
  store i32 %inc42, i32* %row, align 4
  br label %for.cond

for.end43:                                        ; preds = %for.cond
  %33 = load i32* %IsPassed, align 4
  %tobool = icmp ne i32 %33, 0
  br i1 %tobool, label %if.else, label %if.then44

if.then44:                                        ; preds = %for.end43
  %call45 = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([31 x i8]* @.str2, i32 0, i32 0))
  br label %if.end47

if.else:                                          ; preds = %for.end43
  %call46 = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([31 x i8]* @.str3, i32 0, i32 0))
  br label %if.end47

if.end47:                                         ; preds = %if.else, %if.then44
  ret i32 0
}

; Function Attrs: nounwind
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture, i8* nocapture readonly, i64, i32, i1) #1

; Function Attrs: nounwind
declare void @llvm.memset.p0i8.i64(i8* nocapture, i8, i64, i32, i1) #1

declare i32 @matrixMul(...) #2

declare i32 @printf(i8*, ...) #2

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind }
attributes #2 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = metadata !{metadata !"clang version 3.4 (tags/RELEASE_34/final)"}
