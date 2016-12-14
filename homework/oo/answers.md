### 作业1

`repeated_inheritance.cpp`是重复继承的例子，其中没有用虚函数。由于使用了gcc的特性，需要用g++编译。`__attribute__((packed))`用于关闭对齐用的padding，方便分析内存布局。程序中B和C类都继承了A类，D类继承和B和C两个类。从程序输出的地址偏移可以看出，D类大小为5字节，这5字节分别保存了：a1、b、a2、c、d，其中a1和a2是两份A类的数据成员。这说明在种重复继承的情形下被重复继承的类有多个实例。

把这个程序做一些改动，改为虚继承（在B和C继承A的地方加virtual关键字），得到`virtual_inheritance.cpp`。程序输出的结果有了变化。根据输出的地址偏移可以分析内存布局。D类大小20字节。`d.B::a`和`d.C::a`地址相同，说明A类只有一个。而且通过`d.a`访问a没有报错（之前一种情况会报错，因为不知道你指的是哪个a）。内存布局：一个指针、b、一个指针、c、d、a。这说明在种重复继承的情形下被重复继承的类有唯一的实例。

从函数的地址可以看出， 只要是同一个函数，地址就是相同的。不会因为继承而为子类生成一个新的函数。

对vtable分析了很久，在虚继承的情况下一直没有搞清楚数据的布局。但是通过阅读很多文章，弄懂了其中的大致原理。这里就不深入分析vtable了。一篇不错的文章：http://www.drdobbs.com/cpp/multiple-inheritance-considered-useful/184402074

总结：C++中继承具有相同父类的两个类就会出现重复继承，公共父类具有两份数据，不能直接通过名字操作公共父类的成员，需要显示指明，例如`d.B::a`和`d.C::a`。B和C继承A时使用虚继承，就可以避免这种问题，公共父类只有一份，可以直接通过名字操作父类（因为此时没有歧义），但是公共父类不属于B或C，需要在D的构造函数指明如何初始化。

遇到的问题：

- 不知道如何输出函数的地址。使用[这个网页](http://stackoverflow.com/questions/3068144/print-address-of-virtual-member-function)的办法解决。
- 因为数据有对齐的padding，所以不方便分析数据布局，使用gcc的`__attribute__((packed))`关闭对齐。
- 程序输出的数据成员地址不直观，改为输出偏移量，并且数据成员都使用char类型。
- 当重复继承时，ABCD类中都定义变量a，如何从D类的对象直接访问A类的a（不用强制类型转换）？未解决，但不影响分析。



### 作业2

多写几个不同类型的函数，看编译后的名称和函数的对应关系：

| 函数                                       | 符号                   |
| ---------------------------------------- | -------------------- |
| `void A::test() const`                   | `_ZNK1A4testEv`      |
| `void A::test(int)`                      | `_ZN1A4testEi`       |
| `void A::test(int,int)`                  | `_ZN1A4testEii`      |
| `int A::test(int,int,int)`               | `_ZN1A4testEiii`     |
| `void A::test(int,double,char,int*,int&)` | `_ZN1A4testEidcPiRi` |
| `void A::fa()`                           | `_ZN1A2faEv`         |
| `void B::fb()`                           | `_ZN1B2fbEv`         |

可以看出名字变换的规律：

都以`_ZN`开头，如果是const函数则有`K`，然后是类名和函数名，最后是参数列表。类名和函数名都以数字开头，表示这部分的长度，接下来是真正的名字。参数列表以`E`开头，`v`代表空，`i`代表int，`Pi`代表指向int的指针等等。函数的返回类型并没有体现在名字中，我认为这应该是由于函数重载只取决于参数列表和是否为const，仅仅返回类型不同的函数不能构成重载。

动态链接时，printf的调用对应的汇编是`call   770 <printf@plt>`。cout本身是一个对象，使用cout输出时调用的是`basic_ostream`类的`operator<<`函数，汇编中也是一个函数调用，例如`call   780 <_ZNSolsEj@plt>`。

静态链接时，printf的调用是`call   80fada0 <_IO_printf>`，cout输出时的函数调用是`call   804e5e0 <_ZNSolsEj>`。

观察动态链接和静态链接时的区别，发现动态链接的函数名后面有个`@plt`。查询资料可以得知，PLT是procedure linkage table，保存了动态加载的链接库中函数的位置，这样动态链接库就可以多个进程共享一份而不是每个进程自己加载一份了。

#### 书面总结面向对象语言中类成员被编译的特征，静态和动态连接产生的代码特征。

面向对象语言中类成员被编译时，会根据它所在的namespace、类的名字、函数的参数、是否为const等信息唯一对应一个变换后的名字，保证了在函数重载时这个变换后的名字不会重复。调用函数时额外把当前对象的地址也当做参数传进去，即this指针。

动态链接的代码会通过PLT调用动态加载的函数，代码中不包含库函数的实现。静态链接的代码直接调用自己中包含的库函数实现。

#### 参考资料

http://stackoverflow.com/questions/1150748/g-generated-assembly-looks-ugly

http://stackoverflow.com/questions/5469274/what-does-plt-mean-here

