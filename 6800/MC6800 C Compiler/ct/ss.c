struct ss {
  char DATA;
  char STATUS;
};
main() {

  int a;
  int * ACIA;

  ACIA = 0xe008;
  a = ACIA.STATUS;
}
