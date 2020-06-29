/*
     int _flushbuf(c, stream)
          char      c;
          FILE     *stream;

          If the standard I/O stream referenced by <stream>
          is unbuffered, the character <c> is written
          to the stream.  Otherwise, the buffer associated
          with the stream is flushed to the stream, the
          buffer is reinitialized, and the character <c>
          is written to the buffer.

          To flush a buffer to its associated stream,
          use fflush().

     Arguments:
          c         Next character to be written
          stream    Pointer to stream information

     Returns:  int
          The number of characters written, or EOF if error

     Revision History:
          06/12/84 kpm - Modified from old TSC _flushbuf()
          05/14/85 ljn - Added support for update modes.
          06/03/85 ljn - Set FLEOL if stream is a pipe (too).
*/

#include "machine.h"
#include <stdio.h>


int _flushbuf(c, stream)
               unsigned char       c;
     register  FILE               *stream;
{
     REGISTER  int                 i;
               char     *malloc();


     /* Buffered or unbuffered I/O ?? */

     if (stream->_flag & _UNBUF)
     {
           i = 0;
          /*
           * If were open for append we may have to seek to EOF.
           */
           if ((stream->_flag & _APPEND) &&
               (!(stream->_flag & _LASTWRITE)))
              {
               if (!isatty(stream->_fd))
                  if (lseek(stream->_fd, 0L, 2) == -1)
                     i = EOF;
              }
          /* Unbuffered, just write the character */
          if (i != EOF)
             i = ((write(stream->_fd, &c, 1) == 1) ? c : EOF);
          stream->_cnt = 0;
     }

     else
     {
          /* Is there a buffer associated with the stream ? */
          if (stream->_base == NULL)
          {
               /* No, try to make one */
               if ((stream->_base = malloc(BUFSIZ)) == NULL)
               {
                    /* No buffer available, unbuffered I/O */
                    stream->_flag |= _UNBUF;
                    i = 0;
                   /*
                    * If were open for append we may have to seek to EOF.
                    */
                    if ((stream->_flag & _APPEND) &&
                        (!(stream->_flag & _LASTWRITE)))
                       {
                        if (!isatty(stream->_fd))
                           if (lseek(stream->_fd, 0L, 2) == -1)
                              i = EOF;
                       }
                    if (i != EOF)
                       i = ((write(stream->_fd, &c, 1) == 1) ? c : EOF);
                    stream->_cnt = 0;
               }
               else
               {
                    /* Got a buffer.  Set up (don't write tho) */
                    stream->_cnt = BUFSIZ - 1;
                    stream->_ptr = stream->_base;
                    *stream->_ptr++ = c;
                    stream->_flag |= _BIGBUF |
                                     (_termorpipe(stream->_fd)? _FLEOL : 0);
                    i = (int) c;
               }
          }
          else
          {
               /*
                    Buffer already associated with the stream.
                    Flush it to the file.

                    If _LASTWRITE is clear, the buffer is empty.
                    (We either just did a seek or this is the first
                    operation on a stream that was "setbuf'd")
               */
               i = 0;
               if (stream->_flag & _LASTWRITE)
                  {
                   if (stream->_flag & _APPEND)
                      {
                       if (!isatty(stream->_fd))
                          if (lseek(stream->_fd, 0L, 2) == -1)
                             i = EOF;
                      }
                   if (i != EOF)
                      {
                       i = BUFSIZ - ((stream->_cnt > 0) ? stream->_cnt : 0);
                       if (write(stream->_fd, stream->_base, i) != i)
                           i = EOF;
                       else
                          {
                          /* Reset buffer and stuff char in it */
                           stream->_cnt = BUFSIZ - 1;
                           stream->_ptr = stream->_base;
                           *stream->_ptr++ = c;
                           i = c;
                         }
                      }
                  }
               else
               {
                    /* Reset buffer and stuff char in it */
                    stream->_cnt = BUFSIZ - 1;
                    stream->_ptr = stream->_base;
                    *stream->_ptr++ = c;
                    i = c;
               }
          }
     }

     return(i);
}
