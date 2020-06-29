int aaa,bbb;
char *ppp, ccc[2][4];

struct {
  int ddd,eee;
  char fff[10];
} sss;

main() {
  int a;

  a=sizeof ccc[1][1];
  a=sizeof ccc[1];
  a=sizeof(aaa);
  a=sizeof ppp;
  a=sizeof ccc;
  a=sizeof sss;
}
