main() {
  int a,b;
  int r;
  unsigned c;
  int ar[10][10];
  int *p;
  p = &r;
  b = 1;
  *p = 1;
  for(c=0; c<60000; c++)
    a = ar[b][*p + fun(1)];
}

fun(a) {
  int b,c,d;
  c = 1;
  return (b = a ? c : d);
}
