main() {
  int a;
  char b = {a + 100};
  register int *ptr = a+b+10;

  a = tree(b)+ptr;
}
