/*
     int ungetc(c, stream)
          int       c;
          FILE     *stream;

          Push the character represented by <c>
          back onto the stream referenced by <stream>.

     Arguments:
          c         Character to push
          stream    A(FILE describing stream)

     Returns: int
          c

     Revision History:
          06/08/84 kpm - New
*/

#include "machine.h"
#include <stdio.h>

int ungetc(c, stream)
     REGISTER  int       c;
     register  FILE     *stream;
{
     if ((stream->_flag & _READ) && (c != EOF))
          stream->_save = c;
     else c = EOF;
     return(c);
}
