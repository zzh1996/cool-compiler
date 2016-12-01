### 词法分析

**解释函数 `gettok()` 如何向调用者传递 `token` 类别、`token` 语义值（数字值、变量名）**



### 语法分析和 AST 的构建

**解释 `ExprAST` 里的 `virtual` 的作用，在继承时的原理（解释 vtable).`virtual` 在 MP1 的 support code 里面也出现了. 这个问题是希望大家理解 C++ 的继承.**



**解释代码里的 `<std::unique_ptr>` 和为什么要使用它？**



**阅读 `src/toy.cpp` 中的 `MainLoop` 及其调用的函数. 阅读 `HandleDefinition` 和 `HandleTopLevelExpression` ，忽略 `Codegen` 部分，说明两者对应的 AST 结构.**



**Kaleidoscope 如何在 Lexer 和 Parser 间传递信息？（token、语义值、用什么函数和变量）**



**Kaleidoscope 如何处理算符优先级（重点解释 `ParseBinOpRHS` ）？解释`a*b*c`、`a*b+c`、`a+b*c`分别是如何被分析处理的？**


**解释 `Error`、`ErrorP` 的作用，举例说明它们在语法分析中的应用。**
**Kaleidoscope 不支持声明变量和给变量赋值，那么变量的作用是什么？**



### 中间代码生成

**解释教程 3.2 节中 `Module`、`IRBuilder<>` 的作用；**



**为何使用常量时用的函数名都是 `get` 而不是 `create` ？**



**简要说明声明和定义一个函数的过程**



**文中提到了 visitor pattern, 虽然这里没有用到, 但是是一个很重要的设计模式, 请调研后给出解释( 字数不作限制).**

