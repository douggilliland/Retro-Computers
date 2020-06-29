main() {
  int *p1,*p2;
  int i;

  i=p1-p2;
  i=p2-p1;
  i=(p1+1)-p2;
  i=p1-(p2+1);
  i=&i-&p1;
  i=p1-&i;
}
