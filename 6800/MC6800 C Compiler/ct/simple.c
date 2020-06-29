int test;

main() {
  int a,b;
  static s;

  a = b + 1;
  b = 100;
  a = a + b;
  s = test + a;
}
