define i32 @fib(i32 %n){
    %iszero = icmp eq i32 %n, 0
    br i1 %iszero, label %retzero, label %noretzero
retzero:
    ret i32 0
noretzero:
    %isone = icmp eq i32 %n, 1
    br i1 %isone, label %retone, label %noretone
retone:
    ret i32 1
noretone:
    %nm2 = sub i32 %n, 2
    %r1 = call i32 @fib(i32 %nm2)
    %nm1 = sub i32 %n, 1
    %r2 = call i32 @fib(i32 %nm1)
    %sum = add i32 %r1, %r2
    ret i32 %sum
}

@str = private unnamed_addr constant [4 x i8] c"%d\0A\00"

declare i32 @printf(i8*, ...)
declare i32 @atoi(i8*)

define i32 @main(i32 %argc, i8** %argv){
    %argv1 = getelementptr i8*, i8** %argv, i64 1
    %numstr = load i8*, i8** %argv1
    %num = call i32 @atoi(i8* %numstr)
    %retv = call i32 @fib(i32 %num)
    %fmt = getelementptr [4 x i8], [4 x i8]* @str, i32 0, i32 0
    call i32 (i8*, ...) @printf(i8* %fmt, i32 %retv)
    ret i32 0
}
