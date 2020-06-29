/*
     int puts(s)
          char *s;

          This function writes the null-terminated character
          string pointed to by <s> to the standard-output
          stream, followed by an end-of-line character.

     Arguments:
          s         A(null-terminated char string)

     Returns:  int
          EOF if error, 0 if no error

     Revision History:
          06/08/84 kpm - New

*/

#include "machine.h"
#include <stdio.h>

int puts(s)
     register  char     *s;
{
     REGISTER  char      c;


     while(c = *s++) if (putchar(c) == EOF) return(EOF);
     if (putchar(EOL) == EOF) return(EOF);
     return(0);
}
