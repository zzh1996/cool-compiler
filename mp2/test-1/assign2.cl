class Main {
  main(): Int {
    let a:Int <- 1 in {
      let b:Int in {
        a<-2;
      };
      a;
    }
  };
};
