**3.1.5 简要说明`test.c`、`AST.svg`、`CFG.svg`和`ExplodedGraph.svg`之间的联系与区别**

`test.c`是程序的源代码。`AST.svg`由源代码生成，展示了整棵抽象语法树。`CFG.avg`是整个程序的流程图，箭头展示了不同代码块之间的跳转关系。`ExplodedGraph.svg`是分析器沿所有路径进行symbolic execution得到的状态，其中包含了每个状态详细的信息。

**3.2.1  Checker 对于程序的分析主要在 AST 上还是在 CFG 上进行？**

当然是CFG。

**3.2.2 Checker 在分析程序时需要记录程序状态，这些状态一般保存在哪里？**

checker保存的状态位于`GenericDataMap`

**3.2.3简要解释分析器在分析下面程序片段时的过程，在过程中产生了哪些symbolic values? 它们的关系是什么？**

`int x = 3`中会生成代表常量3的SVal，赋值过程中将其绑定到x的MemRegion。`y=4`同理。

`int *p = &x;`把x的地址生成一个SVal（而x不会，因为取地址没有lvalue到rvalue的转换）。把`&x`这个symbolic expression叫做`$0`，在赋值时将这个SVal与p的MemRegion绑定。

`int z = *(p + 1);`中，先把p转换为rvalue，生成一个SVal，代表p的当前值，这个symbol叫`$1`。然后也有一个SVal代表常数1。计算`p+1`时生成新的SVal，叫`$2`。解引用时又生成新的SVal，叫`$3`。最后将`*(p+1)`转换为rvalue，生成新的SVal，叫做`$4`，赋值将其当前值与z的MemRegion绑定。