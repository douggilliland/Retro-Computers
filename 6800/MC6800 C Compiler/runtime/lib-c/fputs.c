/*
     int fputs(s, stream)
          char *s;
          FILE *stream;

          This function writes the null-terminated character
          string pointed to by <s> to the I/O stream
          <stream>.

     Arguments:
          s         A(null-terminated char string)
          stream    A(FILE describing i/o stream)

     Returns:  int
          EOF if error, 0 if no error

     Revision History:
          06/08/84 kpm - New

*/
#include "machine.h"
#include <stdio.h>

int fputs(s, stream)
     register  char     *s;
     REGISTER  FILE     *stream;
{
     REGISTER  char      c;


     while(c = *s++) if (putc(c, stream) == EOF) return(EOF);
     return(0);
}
