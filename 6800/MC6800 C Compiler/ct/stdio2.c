#include <stdio.h>

FILE _iob[_NFILE] = {
  {NULL, 0, NULL, _READ, 0},
  {NULL, 0, NULL, _WRITE, 1},
  {NULL, 0, NULL, _WRITE | _UNBUF, 2 }
};

main() {
  int a;

  a=10;
}
