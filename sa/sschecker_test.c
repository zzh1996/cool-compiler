#include<stdio.h>

void double_close(){
    FILE *f=fopen("test","r");
    fclose(f);
    fclose(f);
}

void double_close_with_condition(int a){
    FILE *f=fopen("test","r");
    fclose(f);
    if(a)
        fclose(f);
}

void leak(){
    FILE *f=fopen("test","r");
}

void leak_with_condition(int a){
    FILE *f=fopen("test","r");
    if(a)
        fclose(f);
}

void close_if_success(){
    FILE *f=fopen("test","r");
    if(f)
        fclose(f); //no warning
}

void do_something();

void escape1(){
    FILE *f=fopen("test","r");
    do_something(f);
} //no leak warning

FILE *global_f;

void escape2(){
    FILE *f=fopen("test","r");
    global_f=f;
} //no leak warning

void no_escape(){
    FILE *f=fopen("test","r");
    fgetc(f);
} //leak
