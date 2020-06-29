main() {
  int a,b,c;
  char d;

  for(a=10000; a; --a) {
    d=a;
    switch( d&0xf ) {
     case 0: b=fun(a);
             break;
     case 1:
     case 2:
     case 3:
     case 12: b=fun(a-1);
             break;
     case 4: b=a>>8;
             break;
     case 5:
     case 7: c=fun(fun(b+d));
             break;
     default: c=fun(10);
    }
  }
}

fun(x) {
  int y,z;

  y=z=x&0x5555;
  return (x+y);
}
