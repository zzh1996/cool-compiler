#include<iostream>

using namespace std;

class __attribute__((packed)) A{
public:
    char a;
    void fa(){}
};

class __attribute__((packed)) B:public A{
public:
    char b;
    void fb(){}
};

class __attribute__((packed)) C:public A{
public:
    char c;
    void fc(){}
};

class __attribute__((packed)) D:public B,public C{
public:
    char d;
    void fd(){}
};


int main(){
    D d;
    d.d;
    d.c;
    d.b;
    d.C::a;
    d.B::a;
    d.fd();
    d.fc();
    d.fb();
    d.C::fa();
    d.B::fa();
#define addr(x) cout<<((char*)(&(x))-(char*)(&d))<<endl;
    addr(d.d)
    addr(d.c)
    addr(d.b)
    addr(d.C::a)
    addr(d.B::a)
    printf("%x\n",(void*)(d.*&D::fd));
    printf("%x\n",(void*)(d.*&D::fc));
    printf("%x\n",(void*)(d.*&D::fb));
    void (C::*p1)()=&C::fa;
    printf("%x\n",(void*)(d.*p1));
    void (C::*p2)()=&B::fa;
    printf("%x\n",(void*)(d.*p2));
    cout<<sizeof(D)<<endl;
    cout<<sizeof(C)<<endl;
    cout<<sizeof(B)<<endl;
    cout<<sizeof(A)<<endl;
}
