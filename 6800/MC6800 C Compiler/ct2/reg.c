main() {
  int a,b,*p1,*p2;
  register int *p;

  p=p1;
  if (p<100) a=1;
  p2=p;
  fun(p1,p2,p);
  fun(p,p1,p2);
}
