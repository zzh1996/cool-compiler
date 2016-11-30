**3.1.5 简要说明`test.c`、`AST.svg`、`CFG.svg`和`ExplodedGraph.svg`之间的联系与区别**

`test.c`是程序的源代码。`AST.svg`由源代码生成，展示了整棵抽象语法树。`CFG.avg`是整个程序的流程图，箭头展示了不同代码块之间的跳转关系。`ExplodedGraph.svg`是分析器沿所有路径进行symbolic execution得到的状态，其中包含了每个状态详细的信息。由于CFG中同一个节点在ExplodedGraph中状态可以不同，所以ExplodedGraph会包含更多节点，产生更多分支。

**3.2.1  Checker 对于程序的分析主要在 AST 上还是在 CFG 上进行？**

当然是CFG。

**3.2.2 Checker 在分析程序时需要记录程序状态，这些状态一般保存在哪里？**

checker保存的状态位于`GenericDataMap`

**3.2.3简要解释分析器在分析下面程序片段时的过程，在过程中产生了哪些symbolic values? 它们的关系是什么？**

`int x = 3`中会生成代表常量3的SVal，赋值过程中将其绑定到x的MemRegion。`y=4`同理。

`int *p = &x;`把x的地址生成一个SVal（而x不会，因为取地址没有lvalue到rvalue的转换）。把`&x`这个symbolic expression叫做`$0`，在赋值时将这个SVal与p的MemRegion绑定。

`int z = *(p + 1);`中，先把p转换为rvalue，生成一个SVal，代表p的当前值，这个symbol叫`$1`。然后也有一个SVal代表常数1。计算`p+1`时生成新的SVal，叫`$2`。解引用时又生成新的SVal，叫`$3`。最后将`*(p+1)`转换为rvalue，生成新的SVal，叫做`$4`，赋值将其当前值与z的MemRegion绑定。

**3.3.1 LLVM 大量使用了 C++11/14的智能指针，请简要描述几种智能指针的特点、使用场合，如有疑问也可以记录在报告中.**

unique_ptr：全局只有一份引用，不可复制，指针被析构时所指向对象即销毁，语义上代表所有权，适合只有一份引用的情况。

shared_ptr：全局可以有多个指针指向相同对象，使用引用计数管理内存，引用计数为0时销毁对象，适合被多者引用的情况。

weak_ptr：和shared_ptr类似，但不增加引用计数，语义上其指向对象随时可被销毁，适合没有"所属权"的情况或者会导致循环引用的情况。

**3.3.2 LLVM 不使用 C++ 的运行时类型推断（RTTI），理由是什么？LLVM 提供了怎样的机制来代替它？**

理由是减少代码和可执行文件的大小，同时也可以提高执行效率。LLVM提供了`isa<>`、`cast<>`、`dyn_cast<> `模板来实现RTTI。

**3.3.3 如果你想写一个函数，它的参数既可以是数组，也可以是std::vector，那么你可以声明该参数为什么类型？如果你希望同时接受 C 风格字符串和 std::string 呢？**

数组：`llvm::ArrayRef`，字符串：`llvm::StringRef`（`std::string`也可以，但效率不高）。

**3.3.4 你有时会在cpp文件中看到匿名命名空间的使用，这是出于什么考虑？**

匿名命名空间可以让里面的内容（尤其是class，因为变量和函数都可以用static）仅对当前翻译单元可见，可以避免名称冲突。

**3.4.1 这个 checker 对于什么对象保存了哪些状态？保存在哪里？**

保存了文件指针的StreamState（有Opened和Closed两种状态），保存在`ProgramState`里（实际上位于CFG节点的state中）。

**3.4.2 状态在哪些时候会发生变化？**

`fopen`被调用时设定其返回的文件指针状态为Opened，`fclose`被调用时设定其参数的状态为Closed。对于dead symbol和escaped symbol（例如传给了一个有可能关闭文件的函数），删除其状态。 

**3.4.3 在哪些地方有对状态的检查？**

`fclose`调用时检查状态是否已经是Closed，如果是则是重复关闭。`checkDeadSymbols`中判断`isLeaked`时检查文件指针是否仍为Opened状态，如果是则是Leak。

**3.4.4 函数`SimpleStreamChecker::checkPointerEscape`的逻辑是怎样的？实现了什么功能？用在什么地方？**

函数的逻辑：如果指针是直接作为参数传入函数，并且函数保证不关闭文件，那么不需要做处理，状态保持原状即可。否则这个指针将无法继续分析，把所有这样的指针的状态移除。实现的功能就是当无法继续追踪一个指针时，就不再追踪它，以防止误报。当analyzer发现指针赋值给全局变量或者传入了无法分析的函数等情况时，这个函数会被调用。

**3.4.5 根据以上认识，你认为这个简单的checker能够识别出怎样的bug？又有哪些局限性？请给出测试程序及相关的说明。**

请参考`sschecker_test.c`文件。`double_close`函数是文件重复关闭，`double_close_with_condition`在某些条件下（a!=0）会重复关闭文件。`leak`中打开的文件未关闭，`leak_with_condition`在某些条件下文件不会被关闭。以上情况这个checker都可以检测出来。`close_if_success`是判断文件指针不为NULL时才关闭文件，这种情况下不会报leak，因为不关闭文件的分支下可以推断出f一定是NULL。这个checker有一些局限性，举例如下：`escape1`是把指针f传给了do_something函数，即使实际上do_something中不关闭文件，checker也不会报leak，因为checker无法判断do_something做了什么，这就导致了指针p产生escape。同理，`escape2`中f被赋值给一个全局变量，checker也无法继续追踪。但是，当指针f传给一些保证不会关闭文件的函数时，checker可以继续正常报leak，例如`no_escape`中的fgetc就可以保证不会关闭文件。

**3.5.1 增加一个checker需要增加哪些文件？需要对哪些文件进行修改？**

在`lib/StaticAnalyzer/Checkers`中增加checker的实现（.cpp文件），其中包含一段注册代码。在`lib/StaticAnalyzer/Checkers/Checkers.td`中增加checker的描述，包括它应该归属的package名。在`lib/StaticAnalyzer/Checkers/CMakeLists.txt`中添加源码的文件名。

**3.5.2 阅读`clang/include/clang/StaticAnalyzer/Checkers/CMakeLists.txt`，解释其中的 clang_tablegen 函数的作用。**

**3.5.3 `.td`文件在clang中出现多次，比如这里的`clang/include/clang/StaticAnalyzer/Checkers/Checkers.td`。这类文件的作用是什么？它是怎样生成C++头文件或源文件的？这个机制有什么好处？**

