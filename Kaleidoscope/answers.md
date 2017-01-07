### 词法分析

**解释函数 `gettok()` 如何向调用者传递 `token` 类别、`token` 语义值（数字值、变量名）**

`enum Token`定义了token的类别， `gettok()`返回的int值是`enum Token`中的一种。token的语义值根据token类型的不同使用`IdentifierStr`（对应`tok_identifier`）、`NumVal`（对应`tok_number`）等全局变量传递。

### 语法分析和 AST 的构建

**解释 `ExprAST` 里的 `virtual` 的作用，在继承时的原理（解释 vtable).`virtual` 在 MP1 的 support code 里面也出现了. 这个问题是希望大家理解 C++ 的继承.**

C++中如果一个类要被继承，那么它的析构函数必须是虚函数，否则通过基类的指针delete派生类对象时，会错误地调用基类的析构函数，会导致派生类的资源无法被释放。虚函数的指针放在vtable里，调用虚函数时根据类的实例的vtable来确定调用的函数的地址，以保证通过基类指针调用虚函数时也会调用派生类的函数。

**解释代码里的 `<std::unique_ptr>` 和为什么要使用它？**

 `<std::unique_ptr>`是C++智能指针中的一种，unique代表一个对象的指针只能有一份，指针生存期结束被析构时会销毁对应的对象，以保证没有内存泄露。这里`<std::unique_ptr>`代表了一种“拥有”的关系，代表这个对象由这个类管理，可以保证任何情况下指针指向的对象的空间都可以正常被释放。

**阅读 `src/toy.cpp` 中的 `MainLoop` 及其调用的函数. 阅读 `HandleDefinition` 和 `HandleTopLevelExpression` ，忽略 `Codegen` 部分，说明两者对应的 AST 结构.**

`HandleDefinition`对应AST中的`FunctionAST`，由函数定义的原型和表达式构成。`HandleTopLevelExpression`也生成`FunctionAST`，表达式为其对应表达式，函数原型名字是`__anon_expr`，参数列表为空。

**Kaleidoscope 如何在 Lexer 和 Parser 间传递信息？（token、语义值、用什么函数和变量）**

在parser中使用`getNextToken`函数，这个函数除了返回token的类型，还将其放在全局变量`CurTok`里。标识符保存在全局变量`IdentifierStr`里，数值常量保存在`NumVal`里。

**Kaleidoscope 如何处理算符优先级（重点解释 `ParseBinOpRHS` ）？解释`a*b*c`、`a*b+c`、`a+b*c`分别是如何被分析处理的？**

双目运算符的优先级保存在`BinopPrecedence`里，`GetTokPrecedence`函数用于获取一个运算符的优先级。解析表达式时首先使用`ParsePrimary`解析一个操作数，然后调用`ParseBinOpRHS`，以0和已经解析的操作数为参数。`ParseBinOpRHS`的第一个参数表示继续读取这个表达式的优先级下界。如果下一个运算符优先级低于这个下界，那么就需要终止当前的函数，只返回LHS。否则，继续处理这个双目运算符，判断第二个操作数之后的运算符的优先级，如果比中间运算符的优先级高，则需要递归调用`ParseBinOpRHS`，把当前的RHS作为新的二元表达式的LHS处理。递归调用时`TokPrec `要+1，保证了出现连续相同运算符时后一个运算符优先级一定更低，即实现了左结合。

`a*b*c`：调用`ParsePrimary`读入`a`，`*`的优先级是40大于0，再用`ParsePrimary`读入`b`，由于40不小于40，所以生成LHS：`a*b`。下一次循环中仍然是`*`的优先级是40大于0，再用`ParsePrimary`读入`c`，由于40不小于40，所以生成LHS：`(a*b)*c`。下一次循环读入-1，返回LHS。

`a*b+c`：`a*b`和上面例子相同，读入`+`时优先级为20，不大于40，仍然和上例一样，生成`(a*b)+c`。

`a+b*c`：依次读入`a`、`+`、`b`后读入`*`，优先级为40大于`+`的20，所以递归调用`ParseBinOpRHS`，以`b`作为LHS，21作为`ExprPrec`（+1保证了以后读到`+`会返回）。新的`ParseBinOpRHS`中处理`*`时优先级高于21，所以不返回，继续读`c`作为RHS，然后读到优先级-1返回`b*c`，之前的`ParseBinOpRHS`把`b*c`作为RHS，最终返回`a+(b*c)`。


**解释 `Error`、`ErrorP` 的作用，举例说明它们在语法分析中的应用。**

`LogError`生成`ExprAST`的指针，值为`nullptr`表示错误，同时输出错误信息。`LogErrorP`和`LogError`相同，唯一的区别是它用于`PrototypeAST`的错误。例如`ParseParenExpr`中解析表达式括号不匹配时，使用`LogError`输出错误信息、`ParsePrototype`中函数名的位置不是`tok_identifier`时输出错误信息。

**Kaleidoscope 不支持声明变量和给变量赋值，那么变量的作用是什么？**

变量可以作为函数的参数传递，也可以作为循环变量参与计算。

### 中间代码生成

**解释教程 3.2 节中 `Module`、`IRBuilder<>` 的作用；**

`Module`用作LLVM IR生成代码的顶层结构，包含了函数和全局变量，是所有生成的IR的内存的所有者。

`IRBuilder<>`提供很多方法供我们方便地生成各种LLVM IR，也帮助保存了当前插入IR的位置。

**为何使用常量时用的函数名都是 `get` 而不是 `create` ？**

在LLVM IR中常量是不重复、共享的，所以仅在没有时才会创建，在已有时只是获取。

**简要说明声明和定义一个函数的过程**

声明一个函数：先以返回类型、参数类型列表、是否vararg为参数调用` FunctionType::get`得到函数的原型，在以函数原型、可链接性、名字、Module为参数使用`Function::Create`创建函数声明。

定义一个函数：首先`TheModule->getFunction`获取是否已经有了函数的声明，没有的话用`Proto->codegen`生成一个。然后创建一个叫`entry`的BasicBlock，开始向其中插入IR，将参数名记录在`NamedValues`以供函数中查询。然后调用Body的`codegen`生成函数体、创建返回值的语句、使用`verifyFunction`检查代码的一致性即可。

**文中提到了 visitor pattern, 虽然这里没有用到, 但是是一个很重要的设计模式, 请调研后给出解释( 字数不作限制).**

访问者模式是一种设计模式，用于把算法与数据分离。在拥有很多个不同类型对象的结构中，每个类定义`accept`函数，接受`visitor`为参数，递归调用每个子元素的`accept`函数。每个`accept`函数中还要调用`visitor`的`visit`方法。对于不同类型的类可以使用不同的`visit`方法。这样可以实现对整个结构中不同种类元素的遍历。