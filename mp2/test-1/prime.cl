class Main {
  main(): Int {
    let n:Int<-2,c:Int<-0 in{
      while c<100 loop{
        let prime:Bool<-true,i:Int<-2 in{
          while i*i<=n loop{
            if n/i*i=n then
              prime<-false
            else false fi;
            i<-i+1;
          } pool;
          if prime then
            c<-c+1
          else 0 fi;
        };
        n<-n+1;
      } pool;
      n-1;
    }
  };
};
