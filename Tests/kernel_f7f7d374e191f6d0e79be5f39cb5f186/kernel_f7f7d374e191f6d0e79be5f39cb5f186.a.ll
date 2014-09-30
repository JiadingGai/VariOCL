; ModuleID = 'kernel_f7f7d374e191f6d0e79be5f39cb5f186.a.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@.str = private unnamed_addr constant [2 x i8] c"(\00", align 1
@.str1 = private unnamed_addr constant [4 x i8] c"%d,\00", align 1
@.str2 = private unnamed_addr constant [3 x i8] c")\0A\00", align 1

; Function Attrs: nounwind uwtable
define i32 @main(i32 %argc, i8** %argv) #0 {
entry:
  %retval = alloca i32, align 4
  %argc.addr = alloca i32, align 4
  %argv.addr = alloca i8**, align 8
  %sSharedStorage = alloca [2048 x i32], align 16
  %src = alloca [2048 x i32], align 16
  %results = alloca [2048 x i32], align 16
  %i = alloca i32, align 4
  %lsz = alloca i32, align 4
  %saved_stack = alloca i8*
  %tid = alloca i32, align 4
  %i14 = alloca i32, align 4
  %j = alloca i32, align 4
  %cleanup.dest.slot = alloca i32
  store i32 0, i32* %retval
  store i32 %argc, i32* %argc.addr, align 4
  store i8** %argv, i8*** %argv.addr, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i32* %i, align 4
  %cmp = icmp slt i32 %0, 2048
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %1 = load i32* %i, align 4
  %2 = load i32* %i, align 4
  %idxprom = sext i32 %2 to i64
  %arrayidx = getelementptr inbounds [2048 x i32]* %src, i32 0, i64 %idxprom
  store i32 %1, i32* %arrayidx, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %3 = load i32* %i, align 4
  %inc = add nsw i32 %3, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  store i32 256, i32* %lsz, align 4
  %4 = load i32* %lsz, align 4
  %5 = zext i32 %4 to i64
  %6 = call i8* @llvm.stacksave()
  store i8* %6, i8** %saved_stack
  %vla = alloca i32, i64 %5, align 16
  %7 = load i32* %lsz, align 4
  %8 = zext i32 %7 to i64
  %vla1 = alloca i32, i64 %8, align 16
  store i32 0, i32* %tid, align 4
  br label %for.cond2

for.cond2:                                        ; preds = %for.inc9, %for.end
  %9 = load i32* %tid, align 4
  %10 = load i32* %lsz, align 4
  %cmp3 = icmp slt i32 %9, %10
  br i1 %cmp3, label %for.body4, label %for.end11

for.body4:                                        ; preds = %for.cond2
  %11 = load i32* %tid, align 4
  %12 = load i32* %tid, align 4
  %idxprom5 = sext i32 %12 to i64
  %arrayidx6 = getelementptr inbounds i32* %vla, i64 %idxprom5
  store i32 %11, i32* %arrayidx6, align 4
  %13 = load i32* %tid, align 4
  %idxprom7 = sext i32 %13 to i64
  %arrayidx8 = getelementptr inbounds i32* %vla1, i64 %idxprom7
  store i32 0, i32* %arrayidx8, align 4
  br label %for.inc9

for.inc9:                                         ; preds = %for.body4
  %14 = load i32* %tid, align 4
  %inc10 = add nsw i32 %14, 1
  store i32 %inc10, i32* %tid, align 4
  br label %for.cond2

for.end11:                                        ; preds = %for.cond2
  %arraydecay = getelementptr inbounds [2048 x i32]* %sSharedStorage, i32 0, i32 0
  %arraydecay12 = getelementptr inbounds [2048 x i32]* %src, i32 0, i32 0
  %arraydecay13 = getelementptr inbounds [2048 x i32]* %results, i32 0, i32 0
  %call = call i32 (i32*, i32*, i32*, i32*, i32*, ...)* bitcast (i32 (...)* @test_fn to i32 (i32*, i32*, i32*, i32*, i32*, ...)*)(i32* %arraydecay, i32* %arraydecay12, i32* %vla, i32* %vla1, i32* %arraydecay13)
  store i32 0, i32* %i14, align 4
  br label %for.cond15

for.cond15:                                       ; preds = %for.inc29, %for.end11
  %15 = load i32* %i14, align 4
  %cmp16 = icmp slt i32 %15, 256
  br i1 %cmp16, label %for.body17, label %for.end31

for.body17:                                       ; preds = %for.cond15
  %call18 = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([2 x i8]* @.str, i32 0, i32 0))
  store i32 0, i32* %j, align 4
  br label %for.cond19

for.cond19:                                       ; preds = %for.inc25, %for.body17
  %16 = load i32* %j, align 4
  %cmp20 = icmp slt i32 %16, 8
  br i1 %cmp20, label %for.body21, label %for.end27

for.body21:                                       ; preds = %for.cond19
  %17 = load i32* %i14, align 4
  %mul = mul nsw i32 %17, 8
  %18 = load i32* %j, align 4
  %add = add nsw i32 %mul, %18
  %idxprom22 = sext i32 %add to i64
  %arrayidx23 = getelementptr inbounds [2048 x i32]* %results, i32 0, i64 %idxprom22
  %19 = load i32* %arrayidx23, align 4
  %call24 = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([4 x i8]* @.str1, i32 0, i32 0), i32 %19)
  br label %for.inc25

for.inc25:                                        ; preds = %for.body21
  %20 = load i32* %j, align 4
  %inc26 = add nsw i32 %20, 1
  store i32 %inc26, i32* %j, align 4
  br label %for.cond19

for.end27:                                        ; preds = %for.cond19
  %call28 = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([3 x i8]* @.str2, i32 0, i32 0))
  br label %for.inc29

for.inc29:                                        ; preds = %for.end27
  %21 = load i32* %i14, align 4
  %inc30 = add nsw i32 %21, 1
  store i32 %inc30, i32* %i14, align 4
  br label %for.cond15

for.end31:                                        ; preds = %for.cond15
  store i32 0, i32* %retval
  store i32 1, i32* %cleanup.dest.slot
  %22 = load i8** %saved_stack
  call void @llvm.stackrestore(i8* %22)
  %23 = load i32* %retval
  ret i32 %23
}

; Function Attrs: nounwind
declare i8* @llvm.stacksave() #1

declare i32 @test_fn(...) #2

declare i32 @printf(i8*, ...) #2

; Function Attrs: nounwind
declare void @llvm.stackrestore(i8*) #1

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind }
attributes #2 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = metadata !{metadata !"clang version 3.4 (tags/RELEASE_34/final)"}
