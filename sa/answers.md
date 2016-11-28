**简要说明`test.c`、`AST.svg`、`CFG.svg`和`ExplodedGraph.svg`之间的联系与区别**

`test.c`是程序的源代码。`AST.svg`由源代码生成，展示了整棵抽象语法树。`CFG.avg`是整个程序的流程图，箭头展示了不同代码块之间的跳转关系。`ExplodedGraph.svg`是分析器沿所有路径进行symbolic execution得到的状态图，其中包含了每个状态详细的信息。