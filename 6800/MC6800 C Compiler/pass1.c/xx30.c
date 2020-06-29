int f1(), f2(), f3(), f4(), f5();

int (* fun[])() = {
  f1, f2, f3, f4, f5};

main() {
  int a;
  int i;

  a = (* fun[i])();
}
