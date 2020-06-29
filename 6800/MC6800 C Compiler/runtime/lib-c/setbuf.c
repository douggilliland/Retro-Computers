/*
     void setbuf(stream, buf)
          FILE     *stream;
          char     *buf;

          This function sets the buffering for the standard
          I/O stream referenced by <stream>.  If the buffer
          pointer <buf> is NULL, the stream is set to
          unbuffered I/O, otherwise it is set to buffered
          I/O with <buf> as the address of its buffer.

          The buffer <buf> is assumed to be atleast
          BUFSIZ (defined in "stdio.h") bytes long.

     Arguments:
          stream    A(FILE describing stream)
          buf       A(buffer for buffering I/O)

     Notes:
        - setbuf() should be used on a stream before any
          i/o is preformed on the stream.  If I/O has been
          performed on the stream, the current buffering
          will be lost

     Routine History:
          06/14/84 kpm - New
          06/03/85 ljn - Set FLEOL if stream is a pipe (too).
*/

#include "machine.h"
#include <stdio.h>

void setbuf(stream, buf)
     register  FILE     *stream;
     REGISTER  char     *buf;
{

     /*   Buffered or unbuffered ?? */
     if (buf == NULL)
     {
          /* Unbuffered */
          stream->_cnt   = 0;
          stream->_flag &= ~_BIGBUF;
          stream->_flag |= _UNBUF;
     }
     else
     {
          /* Buffered */
          stream->_cnt   = (stream->_flag & _WRITE) ? BUFSIZ : 0;
          stream->_flag &= ~(_UNBUF | _BIGBUF);
          stream->_base  = buf;
          stream->_ptr   = buf;
     }

     /*
       If the stream is open (it should be!), if it is attached
       to a terminal, set the _FLEOL flag.  If _READ, this
       indicates that all buffered output streams with _FLEOL
       set are flushed whenever input from the terminal is
       requested.  If _WRITE, this indicates that the stream
       is buffered and attached to a terminal.
     */

     if (((stream->_flag & _READ) ||
          ((stream->_flag & _WRITE) && !(stream->_flag & _UNBUF))) &&
         _termorpipe(fileno(stream)))
          stream->_flag |= _FLEOL;
}
