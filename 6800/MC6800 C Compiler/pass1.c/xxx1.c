struct st1 {
  int a1,b1,c1,d1;
};

struct st1 s1, s2;
struct {
  int gg,hh,jj;
} sss2;

main() {
  struct st1 *p1, *p2;
  int a;
  struct st1 fun();
  union {
  int x,y;
} fun2();

  s1 = s2;
  a = (s1=s2).b1;
  *p1 = *p2;
  s1 = fun();
  fun2(s1);
  *(p1+2) = *(4+p2);
}

struct st1 fun4() {
  int a;
  a = 10;
  return (s2);
}
