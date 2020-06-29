#define CONST 7

char count;

main() {
  int a,b,c;
  int d;

  c=26+CONST;
  for (d=10000; d; --d) {
    count = 10;
    while (--count) {
      a=max(100,d,1);
     b=c*512;
  }
  }
}

max(a,b,c) {
  int m;

  m=(a>b) ? a : b;
  return((m>c) ? m : c);
}
