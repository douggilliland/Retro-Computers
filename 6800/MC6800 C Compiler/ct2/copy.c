#include "getchar2.c"
#include "putchar2.c"

main() {
  char c;

  while ((c=getchar()) != EOF) putchar(c);
  flush();
}
