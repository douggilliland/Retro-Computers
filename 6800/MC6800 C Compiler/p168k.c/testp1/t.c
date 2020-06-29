struct st1 { int a,b,c,d;};
main() {
  register struct st1 *s;
  int i;
  s = f();
  i = 1;
  s = i;
  i = 1;
}
