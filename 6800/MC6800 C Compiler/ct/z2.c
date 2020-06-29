main() {
  int a;
  char *xx;
  typedef struct { int ss[10], aa;} SS;
  SS **pp;
  int *f();

  a=(*pp)+1;
  a=((SS *)xx)+1;
  a=((int *)xx)+1;
  a=((SS *)(f(xx+1))+1);
}
