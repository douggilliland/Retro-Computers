int *a1, **a2, ***a3, ****a4, *****a5;

main () {
  int i;
  int *p;

  i=*a1;
  i=**a2;
  i=***a3;
  i=****a4;
  i=*****a5;
  p=a1;
  p=*a2;
  p=**a3;
  p=***a4;
  p=****a5;
}
