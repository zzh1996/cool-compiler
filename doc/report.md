# 设计调测分析报告

### 总述

MP1中完成了cool语言的lexer和parser，除了支持cool的全部语法外，在基本要求之上还可以处理很多其他错误，例如feature和formal的大小写问题、if和while表达式的错误等等。

MP2中完成了cool编译器的后端，可以由AST生成llvm IR指令，实现的是MP2要求中的COOL语言子集，包括int和bool常量、算术和比较运算、let、if、while、赋值和除数为0的运行时错误处理。

### 问题与解决

MP1中的问题与解决请看`mp1/answers.txt`和`mp1/src/README.md`

MP2中遇到的问题列举如下：

- main中printf使用的格式字符串一开始放在了main函数里，导致出错，改到main前面即可。（放在`CgenClassTable::code_module`函数的`codeGenMainmain`和`code_main`之间。）
- 想要`[25 x i8]*`类型，用`op_arr_type(INT8,25)`再`get_ptr_type`不行，用`op_arr_type(INT8_PTR,25)`就可以。其中参考了operand和value_printer的具体实现。
- 程序崩溃，用gdb调试很长时间，发现`ValuePrinter vp`没有给出stream。
- if分支语句的实现中发现value_printer不支持phi，所以申请一块栈上的空间用于保存每个分支的结果。
- if的false部分执行完毕后不加跳转，直接进入读取结果的部分，导致出错，查了一些资料发现是basic block的要求，所以即便是强制跳转到下一条指令也必须写出来。
- 写测试程序的时候循环中有if语句，循环次数过多，导致if申请的空间过多，栈溢出。减小循环次数即可。这个问题在不使用phi的情况下还没想出一个好的解决方案。
- 在test-1中带优化make，会报opt命令的参数错误，可能是由于llvm新版本和旧的参数不兼容。

### 设计实现

MP1的设计实现请看`mp1/answers.txt`和`mp1/src/README.md`

MP2的整体思路是对AST递归生成llvm IR，生成llvm IR的代码已经在value_printer中提供了。

由于只需要支持Main类的main函数，所以写一个main函数把Main_main包装起来，调用Main_main后再调用printf将Main_main的返回值输出。

之后就是每种表达式的代码生成。

算术运算和比较运算比较简单，以加法为例：

`return vp.add(e1->code(env),e2->code(env));`

先递归生成两个操作数的代码，然后生成这两个operand的相加指令即可。

int和bool常量的生成也很简单，以int为例：

`return int_value(atoi(token->get_string()));`

直接把int的值这个token转换为整数，作为operand返回即可。

block表达式的代码生成就是对每个子表达式生成代码，然后返回最后一个表达式的结果。

对于let表达式，先获取新变量的类型，然后申请对应大小的空间，再计算初始值。如果没有初始值，则使用0（对于int）或者false（对于bool）作为初始值，然后将这个初始值存储到新申请的空间里面去。之后使用`env->add_local`将这个新变量加入符号表，执行let表达式的body，再使用`env->kill_local`恢复原来的符号表。

对于OBJECT表达式（即一个变量），使用`env->lookup`找到其所在的内存地址，然后load即可。

对于赋值表达式，使用`env->lookup`找到其所在的内存地址后计算右值，然后将右值store再地址中。

if和while是最复杂的两种表达式。

对于if，先根据then后面表达式的类型确定整个if表达式的类型，然后为其申请内存空间。然后计算条件部分（pred）的值，根据这个值生成条件跳转语句。之后分别生成true的语句块和false的语句块。这两个语句块执行完毕后都把结果保存进之前申请的内存空间中，并跳转到endif标签处。endif标签会读取之前申请的内存空间中的值并返回。生成标签的部分调用`new_label`函数，每个if使用新的整数后缀以保证标签不重复。

拿`if 1<2 then 3 else 4 fi`举例，其llvm IR汇编代码如下：

```assembly
	%vtpm.0 = icmp slt i32 1, 2
	%vtpm.1 = alloca i32
	br i1 %vtpm.0, label %true0, label %false0

true0:
	store i32 3, i32* %vtpm.1
	br label %endif0

false0:
	store i32 4, i32* %vtpm.1
	br label %endif0

endif0:
	%vtpm.2 = load i32, i32* %vtpm.1
	ret i32 %vtpm.2
```

while语句与if语句较为类似，区别在于不用申请空间，而且跳转的标签不一样。while语句生成的结构大致是：先跳转到pred_label，即循环的开始，这里计算循环条件，如果条件满足则跳转至循环体body_label，否则调到循环结束endloop_label。循环体执行后跳回循环的最开始pred_label，判断循环条件，进行下一轮循环。循环结束处返回0（MP2的要求）。

以`while 1<2 loop 1+1 pool;`为例，其llvm IR汇编代码如下：

```assembly
	br label %pred0

pred0:
	%vtpm.0 = icmp slt i32 1, 2
	br i1 %vtpm.0, label %body0, label %endloop0

body0:
	%vtpm.1 = add i32 1, 1
	br label %pred0

endloop0:
	ret i32 0
```

除此之外，还有一个除数为0的运行时错误处理。在除法运算中，计算两个操作数之后，插入比较语句来比较除数和0的关系，如果相等则调用abort函数终止程序执行，如果不等则正常进行除法。此处的跳转逻辑相当于之前的if语句。

在`mp2/test-1`中，写了很多测试文件，对每种类型的表达式进行了全面的测试，而且还有一个综合测试程序`prime.cl`，程序执行结果都与预期一致。

### 参考资料

- http://llvm.org/docs/Passes.html#mem2reg-promote-memory-to-register
- http://llvm.org/docs/doxygen/html/classllvm_1_1BasicBlock.html
- http://llvm.org/docs/tutorial/LangImpl05.html#llvm-ir-for-if-then-else
- http://releases.llvm.org/3.9.0/docs/LangRef.html
- https://github.com/invictusjs/cool-llvm/tree/master/codegen/test-1
- https://github.com/CharlieMartell/Compiler-Construction/blob/master/mps/mp3/src/cgen.cc
- https://github.com/invictusjs/cool-llvm/blob/master/codegen/src/cgen.cc

