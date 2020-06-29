#include "putchar2.c"
#include "printf.c"

main() {
  int a,b;

  printf("\r        Test of 'printf' function.\r\r");
  a=0;
  while (a++ < 100) {
    printf("The value of 'a' is: %d\r",a);
    printf(" -- binary = %b, octal = %o, hex = %x\r",a,a,a);
  }
  flush();
}
