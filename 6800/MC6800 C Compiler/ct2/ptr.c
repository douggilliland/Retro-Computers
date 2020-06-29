int *extv;
int ar1[10][10];
int *ar2[10][10];

main() {
  register *r;
  int *a,*b,*c;
  char *d,*e,*f;
  static *statv;
  int array[10];
  int array2[10][10];
  int a1,a2,a3;
  static ar3[10][10];
  static *ar4[10][10];

  fun(a,d,"12345");
  fun(statv,extv,"This is a test.");
  fun2(array,a);
  fun2(&a1,*a);
  *a=*b+*c;
  a=&a1;
  a=b;
  a=b+2;
  a1=array[5]+a2;
  a1=array2[5][3]+100;
  array[2]=array[3];
  a1=array[a2];
  a1=array[a2+10]+array[a3+2];
  array2[2][3]=10;
  array2[a1+2][a2+3]=array2[2][a1*2]+array[a1*4];
  ar1[a1+10][*ar2[a1][4]] = ar3[a1+10][*ar4[*a][*b+1]];
}
