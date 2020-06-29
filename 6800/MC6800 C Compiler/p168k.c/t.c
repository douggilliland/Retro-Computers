long l;
int i;
main() {
  l = 1L;
  i = 3;
  l <<= i;
  abort(l);
}
