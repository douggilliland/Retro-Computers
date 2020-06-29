main() {
  int a,b;
  unsigned c;
  int ar[10][10];
  int *p;
  b = 1;
  *p = 1;
  for(c=0; c<60000; c++) {
    a = ar[b][*p + *p];
    a = a ? c : b;
    if (a==10 || a==20 || a==30 || a==40 || a==50)
      b=1;
  }
}
