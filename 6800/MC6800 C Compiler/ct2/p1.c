main() {
  char *pc;
  int a, *pi;
  long *pl;
  int array[10][10];
  int (*pa1)[10];
  int (*pa2)[5][4];
  struct s {
    int xx,yy,zz,qq,ff;
  } s1;
  struct s *ps;
  int **pp;

  a=pc+2;
  a=pi+2;
  a=pl+2;
  a=pa1+2;
  a=pa2+2;
  a=ps+2;
  a=pp+2;
  a=sizeof array;
}
