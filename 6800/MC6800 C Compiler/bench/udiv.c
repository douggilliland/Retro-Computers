#include "putchar.c"
#include "printf.c"

main() {
  unsigned a,b,c;

  b = 50;
  for (a=0; a<60000; a+=1000)
    printf("a=%u      b=%u      a/b=%u\n",a,b,a/b);
}
