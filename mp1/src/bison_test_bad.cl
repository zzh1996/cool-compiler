(*
 *  execute "coolc bad.cl" to see the error messages that the coolc parser
 *  generates
 *
 *  execute "myparser bad.cl" to see the error messages that your parser
 *  generates
 *)

(* no error *)
class A {
};

(* error:  b is not a type identifier *)
Class b inherits A {
};

(* error:  a is not a type identifier *)
Class C inherits a {
};

(* error:  keyword inherits is misspelled *)
Class D inherts A {
};

(* error:  closing brace is missing *)
Class E inherits A {
;

class Test1{
    test():Int{{
        a<-A;
    }};
};

class Test2{
    A:Int;
    a:Int;
};

class Test3{
    test1():Int{{
        1;A;2;3;+;
    }};

    test2():Int{
        a(1,2,3,)
    };

    test3():Int{
        a(,1,2,3)
    };

    test4():Int{
        a(1;2;)
    };

    test5():Int{{

    }};

    Test6():Int{
        1
    };

    Test7:Int;

    test8:int;

    test9():Int{
        1;
    };

    test10():Int{

    };
};

class Test4{
    f1():Int{
        case of
            a:Int=>1;
        esac
    };

    f2():Int{
        x<-
    };

    f3():Int{
        x@.f()
    };

    f4():Int{
        x=y=z
    };

    f5():Int{{
        ;1;
    }};

    f6():Int{{
        let a:Int<-A in a;
    }};

    f7():Int{{
        if 1 then 1 fi;
    }};

    f8():Int{{
        if 1 then 1 else fi;
    }};

    f9():Int{{
        if 1 then 1 else 1;
    }};

    f10():Int{{
        if 1 then else 1 fi;
    }};

    f11():Int{{
        isvoid A;
    }};

    f12():Int{{
        new a;
    }};

    f13():Int{{
        while 1 loop 1 loop;
    }};

    f14():Int{{
        while 1 pool 1 pool;
    }};

    f14():Int{{
        while 1 pool;
    }};
};
