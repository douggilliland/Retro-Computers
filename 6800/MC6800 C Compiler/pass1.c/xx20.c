main() {
  int a,b,c,d;
  int *p1, *p2;
  char c1;
  a = b ? c1 : b+d;
  a = b ? b+d: c1;
  p1 = a ? p2 : 0;
  p1 = a ? 0 : p2;
}
