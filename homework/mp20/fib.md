遇到的问题：

- `error: constant expression type mismatch  @str = private unnamed_addr constant [4 x i8] c"%d\n\00"`

  将`%d\n\00`改为`%d\0A\00`即可。LLVM IR的字符串常量中没有`\n`

- `call i32 @printf`时报printf类型错误，改成`call i32 (i8*, ...) @printf`即可。但为何call其他函数时不用把参数列表的类型写进去？？？

- 执行`llvm-as < fib-m.ll | lli`产生segmentation fault。用gdb分析了好半天，发现这个程序不带参数运行时atoi必然会崩溃。编译成可执行文件后带参数执行就一切正常。


翻译中比较重要的部分

- `getelementptr`比较难理解，查了一下[文档](http://llvm.org/releases/3.9.0/docs/LangRef.html)之后明白了用法，知道它只是用来算地址的，访存还需要自己写load，就很容易了。