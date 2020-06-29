#include "putchar.c"
#include "printf.c"

main() {
  int a,b;
  for (a= -10; a<=10; a++)
    for (b= -10; b<=10; b++)
      printf("a=%d,  b=%d,  a*b=%d\n",a,b,a*b);
}
