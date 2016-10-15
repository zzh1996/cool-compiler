class A {
};

Class BB__ inherits A {
};

class Test{
    test():Int{1};
    t2:Int;
    t3:Int<-3;
    t4(a:Int):Int{1};
    t5(a:Int,b:Int):Int{1};
    t6():Int{{
        a<-1;
        a.test();
        a.test(1);
        a.test(1,2,3);
        a@Int.test();
        a@Int.test(1);
        a();
        a(1);
        if a then b else c fi;
        if a then b else if c then d else e fi fi;
        if if a then b else c fi then d else e fi;
        if a then if b then c else d fi else e fi;
        while a loop b pool;
        while while a loop b pool loop c pool;
        while a loop while b loop c pool pool;
        {1;};
        {1;2;};
        new Int;
        isvoid 1;
        a+b;
        a-b;
        a*b;
        a/b;
        a<b;
        a<=b;
        a=b;
        ~a;
        not a;
        (a);
        a+b+c+d;
        a<-b<-c<-d;
        a+b*c/d-e<f-not~e*isvoid isvoid new Int;
        a*(b+c)+((d))+(e*(f-g));
        123;
        "abc";
        true;
        let a:Int in 1;
        let a:Int <- 1 in 1;
        let a:Int, b:Int in 1;
        let a:Int <- c, b:Object <- d in a+b+c+d;
        let a:Int in let b:Int in c;
        let a:Int in a + let b:Int in b;
        (let a:Int in a) + let b:Int in b;
        case a of
            c:Int => b;
            d:Object => e;
        esac;
        {a;{b;c;{e;};};d;};
    }};
};