main() {
  int *p1, *p2;
  int a,b,c;
  a = *p1--;
  a = *--p1;
  *p2++ *= *p1++;
  *++p2 *= *p1++;
  a = *p1++ * *p2++;
  *++p2 *= a;
  *(p2+a+b+c) *= *(p1+a+b+c);
  *(p2+a+b+c) *= *(p1+a+b+c) + *(p2+a+b+c);
}
