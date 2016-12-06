#include<iostream>

using namespace std;

class __attribute__((packed)) A{
public:
    char a;
    void fa(){}
};

class __attribute__((packed)) B:virtual public A{
public:
    char b;
    void fb(){}
};

class __attribute__((packed)) C:virtual public A{
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
    d.a; //no error
    d.fd();
    d.fc();
    d.fb();
    d.C::fa();
    d.B::fa();
    d.fa(); //no error
#define addr(x) cout<<((char*)(&(x))-(char*)(&d))<<endl;
    addr(d.d)
    addr(d.c)
    addr(d.b)
    addr(d.C::a)
    addr(d.B::a)
    printf("%x\n",(void*)(d.*&D::fd));
    printf("%x\n",(void*)(d.*&D::fc));
    printf("%x\n",(void*)(d.*&D::fb));
    printf("%x\n",(void*)(d.*&D::fa));
    cout<<sizeof(D)<<endl;
    cout<<sizeof(C)<<endl;
    cout<<sizeof(B)<<endl;
    cout<<sizeof(A)<<endl;
    cout<<&d<<endl;
    cout<<*(void**)((char*)&d)<<endl;
    cout<<*(void**)((char*)&d+9)<<endl;
}
