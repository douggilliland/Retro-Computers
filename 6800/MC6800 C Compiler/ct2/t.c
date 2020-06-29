main() {
  int a,b;
  register int **p;

  a=**p;
  p=*100;
  **p=10;
}
