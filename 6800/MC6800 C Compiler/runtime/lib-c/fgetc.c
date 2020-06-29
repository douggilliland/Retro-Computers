/*
     int fgetc(stream)
          FILE *stream;

          This function returns the integer representation
          of the (unsigned) character from the input stream
          referenced by "stream" if any, EOF if none.

     Arguments:
          stream    A(iob) describing input stream

     Revision History:
          06/13/84 kpm - New
          05/13/85 ljn - Added support for update modes.
*/

#include "machine.h"
#include <stdio.h>

int fgetc(stream)
     register  FILE     *stream;
{
     REGISTER  int       i;

     if (stream->_flag & _LASTWRITE)
        {
         stream->_flag |= _ERR;
         return(EOF);
        }
    /*
     * If we did not do a read last then we'll have to fill the buffer.
     * This is necessary because after seeks on a file open for update
     * we do not know if the guy is going to read or write next, so
     * we cannot set the count properly.
     */
     if ((stream->_flag & _UPDATE) && !(stream->_flag & _LASTREAD))
        {
         stream->_cnt = 0;
        }

     /*   If a character has been "ungotten" on this
          stream, return the "ungotten" character
     */
     if (stream->_save != EOF)
     {
          i = stream->_save;       /* Get ungotten char */
          stream->_save = EOF;     /* No ungotten char now */
     }
     else
          i = ((--(stream->_cnt) >= 0) ?
               (int) ((unsigned char) *(stream->_ptr)++) :
               _fillbuf(stream));
     stream->_flag |= _LASTREAD;
     return(i);
}
