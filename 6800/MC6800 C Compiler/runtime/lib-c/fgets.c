/*
     char *fgets(s, n, iop)
          char    *s;
          int      n;
          FILE    *iop;

          This function characters from the stream
          referenced by <iop> into the buffer pointed
          to by <s>.  It stops reading characters
          when <n>-1 characters have been read or the
          character read was an EOL character.  The
          characters are terminated by a NULL.  The
          function returns a pointer to the buffer
          if successful or NULL if an I/O error occurred.

     Arguments:
          s         A(target buffer)
          n         Size of target buffer
          iop       A(FILE describing I/O stream)

     Returns:  char *
          A(buffer) if successful, NULL if error.

     Revision History:

*/

#include "machine.h"
#include <stdio.h>

char *fgets(s, n, iop)
     char    *s;
     int      n;
     FILE    *iop;
{
     register  char     *cs = s;
     REGISTER  int       c;
     REGISTER  int       nn = n;
     REGISTER  FILE     *stream = iop;

     while ((--nn > 0) && ((c = getc(stream)) != EOF))
          if ((*cs++ = c) == EOL)
               break;
     *cs = '\0';

     return(((c == EOF) && (cs == s)) ? NULL : s);
}
