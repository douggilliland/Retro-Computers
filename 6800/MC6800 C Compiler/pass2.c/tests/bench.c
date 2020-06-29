int a,b,c,d;
int i,j;
main() {
  for (i=0; i<10000; i++) {
    a=10;
    b = a * 16;
    b = a * 256;
    a++;
    b = a / 256;
    b = a / b;
    b = a * b;
  }
}
