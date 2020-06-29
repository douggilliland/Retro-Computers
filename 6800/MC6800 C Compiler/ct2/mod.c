#include "putchar2.c"
#include "printf.c"

main() {
  int a,b;

  for(a=-5; a<6; a++)
    for(b=-5; b<6; b++)
      printf("a = %2d b = %2d a/b = %2d a%%b = %2d\n",a,b,a/b,a%b);
  flush();
}
