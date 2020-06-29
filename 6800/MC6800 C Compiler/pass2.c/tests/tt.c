#include <stdio.h>
main() {
  extern int errno;
  errno = 3;
  perror("Test");
  errno = 3;
  perror(0);
}
