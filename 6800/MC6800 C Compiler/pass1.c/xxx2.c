struct st1 {
  int a1,a2,a3,a4;
  struct {
    int f1,f2;
    struct st2 *ps;
  } s;
};
struct st2 {
  int g,h,j;
};
struct st1 s1, s2;
struct st1 *fun();
struct st1 ar1[10];
struct st1 fun2();
main() {
  int a,b;
register struct st1 *p1;
register struct st2 *p2;
  (p1 + p2->h)->a2 = 10;
  a = ar1[p2->h].s.f2;
  a = (p1 = p2)->s.f2;
  if (fun(p2)->a2 == fun(p2)->a2)
    a=10;
  p1->s.ps->h = p1->s.f1;
  a = fun2(p2->h).a2;
  s2 = fun2(p2->h);
  if (fun2()) a=10;
  if (s1 == s2) a=10;
}
