/* file defineing io buffer pool */

#include <stdio.h>

FILE _iob[_NFILE] = {
  { NULL, 0, NULL, _READ, 0, -1},  /* stdin */
  { NULL, 0, NULL, _WRITE, 1, -1}, /* stdout */
  { NULL, 0, NULL, _WRITE|_UNBUF, 2 , -1} /* stderr */
};

