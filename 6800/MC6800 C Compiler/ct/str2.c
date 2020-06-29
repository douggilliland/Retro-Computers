
struct {
  struct {
    char aaa[3];
    unsigned size;
  } s;
  int x1, x2;
} s2;

main() {
  int a;

  a = s2.s.size;
}
