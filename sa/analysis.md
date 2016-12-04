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



**2. 检查能力到什么程度（程序存在哪些特征时检查不出来）?**


**3. 检查的实现机制是什么？列出相关的源码位置和主要处理流程**


**4. （可选）从实现机制上分析，为什么检查不出来上述问题2的解答中所列的特征？**


**5. （可选）如果想增强检查能力，可以怎么做？**