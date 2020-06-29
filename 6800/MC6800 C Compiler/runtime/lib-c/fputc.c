/*
     int fputc(c, stream)
          char  c;
          FILE *stream;

          Puts the value "c" onto the output
          stream referenced by "stream"; returns
          "(int)(unsigned)c" if successful,
          EOF if not.

     Arguments:
          c         Character
          stream    A(iob) describing output stream

     Revision History:
          06/13/84 kpm - New
          05/13/85 ljn - Added support for update modes.
*/
#include  "machine.h"
#include  <stdio.h>

int fputc(c, stream)
     REGISTER  char      c;
     register  FILE     *stream;
{
     REGISTER  int       rtnval;

     if (stream->_flag & _LASTREAD)
        {
         stream->_flag |= _ERR;
         return(EOF);
        }
    /*
     * Check and see if we did a write last. If not we've got room
     * in the buffer. This can happen after seeks.
     */
     if ((!(stream->_flag & _LASTWRITE)) && (stream->_ptr))
        {
         stream->_cnt = BUFSIZ;
         stream->_ptr = stream->_base;
        }

     rtnval = (--stream->_cnt >= 0) ?
              (int)(unsigned) (*stream->_ptr++ = c) :
              _flushbuf(c, stream);

     /*
          If the character written was an end-of-line
          character and this stream's flags indicate to
          flush after writing EOL, flush the stream
          [See setbuf(3S) in UNIX V5 manual]
     */
     if ((rtnval == EOL) && (stream->_flag & _FLEOL))
          if (fflush(stream) == EOF) rtnval = EOF;

     stream->_flag |= _LASTWRITE;
     return(rtnval);
}
