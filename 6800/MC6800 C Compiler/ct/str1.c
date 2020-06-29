struct {
  int x;
  int *y;
} *p;

main() {
  ++p->y;
}
