struct s1 {
  int a1,a2,a3,a4;
};
struct s2 {
  int b1,b2,b3,b4;
};
extern struct s2 blah[];
main() {
  register struct s1 *p1, *p2;
  int r1,r2;
  p1->a3++;
  p2->a3++;
  fun(r1);
  fun(r2);
}
