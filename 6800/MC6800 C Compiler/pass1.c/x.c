struct st1 {
  int a,b,c;
  int f1:2, f2:4, f3:25, f4:3, f5:6;
  int f6:1;
  int d;
  int g1:1, :3, g2:4;
  int g3:2, :0;
  int h1:3, h2:4;
  int e,f;
};

struct st1 s;
struct st1 s2 = {
  10, 10, 10, 1, 1, 1, 1, 1, 1, 10, 1, 1, 1, 1, 1, 10, 10};

struct {
  int a,b,c;
  unsigned x:1, y:1, z:1;
  int k;
} ss3 = {100, 100, 100, 1, 0, 1, 100};

main() {
  int i,j;
  i = s.c;
  i = s.d;
  i = s.e;
  i = s.f;
  i = sizeof(struct st1);
  i = s.g2;
  i = s.h1;
  s.g2 = i;
  s.g2 = s.h2;
  s.g2 += 1;
  s.g2 += s.h2;
  i = &s.h2;
}
