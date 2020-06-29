struct s1 {
  int a1,a2,a3;
  struct {
    int b,b2,b3;
  } a4, d;
  int a5,a6;
};

struct s1 str;
main() {
  int a;
  a = str.a4.b2;
  a = str.d.b3 + 2;
}
