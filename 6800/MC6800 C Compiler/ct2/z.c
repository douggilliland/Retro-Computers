#include "putchar2.c"
#include "printf2.c"
main() {
  char c;

  c='\0370';
  printf("char = %h\r",c);
  flush();
}
