#include "putchar.c"
#include "printf.c"

main() {
  printf("Test Program #1.\n");
  printf("This is a test %d.\n",100);
  printf(2,"Test output to stderr.\n");
  flush();
}
