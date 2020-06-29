#include "getchar2.c"
#include "putchar2.c"
#include "printf.c"
#include "getline.c"

main() {
  char line[256];
  int len, total;

  total = 0;
  while ((len = getline(line, 256)) > 0) {
    printf("%4d: %s",len-1,line);
    total += len;
  }
  printf("Total character count is %d.\n",total);
  flush();
}
