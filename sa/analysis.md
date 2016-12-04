**除了这些缺陷以外, clang静态分析器还有哪些缺陷?**

正如[官网中这个网页](http://clang-analyzer.llvm.org/open_projects.html)所提到的，clang静态分析器还有很多缺陷。

- 没有对系统库的很多类建模

  例如下面的代码

  ```c++
  #include<iostream>

  using namespace std;

  void foo(string a) {
      int *pi = 0;
      if (a.size()>2)
          pi = new int;
      if (a.size()>1)
          delete pi;
  }

  void foo2(int a) {
      int *pi = 0;
      if (a>2)
          pi = new int;
      if (a>1)
          delete pi;
  }
  ```

  `NewDeleteLeaks`这个checker会对`foo`报`Potential leak of memory pointed to by 'pi'`警告，但是不会对`foo2`报错，就说明checker对`string::size()`的定义一无所知。

- `new`和`delete`无法跟踪到构造函数和析构函数

  ```c++
  class C{
      int *p;
  public:
      C(){p=new int();}
      ~C(){}
  };

  void foo() {
      C* c=new C();
      delete c;
      int *p = new int();
  }
  ```

  以上代码只有`int *p = new int();`这里一处报告泄露，因为`new`和`delete`无法跟踪到C的构造函数和析构函数，C内的内存泄露不会被发现。

- 无法分析异常处理

  ```c++
  #include<iostream>

  void foo() {
      int *p = new int();
      std::string("abc").substr(10); // throws std::length_error
      delete p;
  }

  int main(){
      try{
          foo();
      }catch(...){
          return 0;
      }
      return 0;
  }
  ```

  抛出异常后`delete p;`不会执行，会产生内存泄漏，但checker没有报错。

当然除此之外还会有很多其他的缺陷，在此就不一一例举了。



**以动态内存、或文件等资源有关的缺陷检查为例，对clang 静态分析器进行如下使用和分析工作：**

**1. 是否能检查该类缺陷?**

我选择的是`alpha.unix.Stream`这个checker。这个checker的主要目的是跟踪使用`fopen`打开的文件的状态，它可以报告很多问题，例如：

- 调用`fopen`后未检查返回值是否是NULL就使用文件

  ```c
  void f(){
      FILE *p=fopen("test","w");
      ftell(p); //Stream pointer might be NULL
      fclose(p);
  }
  ```

- 调用文件相关API的参数类型有误（例如`fseek`的第三个参数）

  ```c
  void f2(){
      FILE *p=fopen("test","w");
      fseek(p,1,3); //The whence argument to fseek() should be SEEK_SET, SEEK_END, or SEEK_CUR
      fclose(p);
  }
  ```

- 文件被关闭多次

  ```c
  void f3(){
      FILE *p=fopen("test","w");
      fclose(p);
      fclose(p); //Try to close a file Descriptor already closed. Cause undefined behaviour
  }
  ```

- 打开的文件没有被关闭

  ```c
  void f4(){
      FILE *p=fopen("test","w");
  } //Opened File never closed. Potential Resource leak
  ```

使用`clang --analyze -Xanalyzer -analyzer-checker=alpha.unix.Stream streamtest.c`可以检测出以上所有错误。

**2. 检查能力到什么程度（程序存在哪些特征时检查不出来）?**

- 只支持部分文件相关函数。经测试，`fprintf`、`fscanf`等函数就不支持。

  ```c
  void f(){
      FILE *p=fopen("test","w");
      fprintf(p,"test");
      fclose(p);
  }
  ```

  这段代码就不会报`Stream pointer might be NULL`警告。

  ```c
  int foo(){
      FILE *f=fopen("test","r");
      if(f){
          fcloseall();
          fclose(f);
      }
  }

  ```

  `fcloseall`函数也不支持。以上代码中`f`显然被关闭了两次，但不会报warning。

- `fclose`的参数可能为NULL或一定为NULL时不会报错。

  ```c
  void foo(){
      FILE *p=fopen("test1","r");
      fclose(p);
  }

  void foo2(){
      fclose(NULL);
  }
  ```

  这两个函数都不会报错。

- 存在escape时有可能误报

  ```c
  void do_something();

  void escape1(){
      FILE *f=fopen("test","r");
      do_something(f);
  }
  ```

  这段代码中checker看不到`do_something`的定义，checker默认为`do_something`不会关闭文件，所以报leak。（而与之前的SimpleStreamChecker不同，SimpleStreamChecker不会报leak。）如果`do_something`中关闭了文件则是误报。

  ```
  FILE *global_f;

  void escape2(){
      FILE *f=fopen("test","r");
      global_f=f;
  }
  ```

  这段代码中`f`传给了全局变量，所以没有报leak，即使全局变量`global_f`从未被关闭。


**3. 检查的实现机制是什么？列出相关的源码位置和主要处理流程**


**4. （可选）从实现机制上分析，为什么检查不出来上述问题2的解答中所列的特征？**

- 有些文件相关函数不支持的问题：


**5. （可选）如果想增强检查能力，可以怎么做？**