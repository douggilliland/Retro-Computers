struct st1 {
  int a,b,c,d,e;
};

struct st1 s1[10];

main() {
  int i,j,k;

  fun(&s1[i].d);
  j = &s1[i].d;
}
