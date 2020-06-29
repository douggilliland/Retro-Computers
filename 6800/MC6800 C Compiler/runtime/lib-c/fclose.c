/*
     File includes:

          int fflush(stream)
               FILE     *stream;

          int fclose(stream)
               FILE     *stream;
*/

/*
     Common definitions
*/

#include "machine.h"
#include <stdio.h>

/*----------------------------------------------------------------*/


/*
     int fflush(stream)
          FILE *stream;

          This function flushes the data in the I/O
          stream <stream>'s buffer to the associated
          file.  It returns 0 if successful, EOF
          if not.

     Arguments:
          stream:   A(block describing I/O stream)

     Returns:
          0 if successful, EOF if not

     Errors:
        - Stream not opened for write access
        - Error reported by write() call

     Routine History:
          06/11/84 kpm - New
          05/14/85 ljn - Added support for update modes.

*/

int fflush(stream)
     register  FILE     *stream;
{
     REGISTER  int       i;
     REGISTER  int       rtnval = 0;

     /*
          Make sure there is a buffer to flush
          If the stream is not open for writing,
          report an error.  Otherwise, if the I/O
          is unbuffered, no buffer has been alloc'd,
          or the buffer is empty, do nothing
     */
     if (stream->_flag & _WRITE)
          if (!(stream->_flag & _UNBUF) &&
               (stream->_ptr != NULL) &&
               (stream->_cnt < BUFSIZ) &&
               (stream->_flag & _LASTWRITE))
          {
               /*
                * If the file is open for append, we must
                * make sure we're at the EOF before writing.
                */
                if (stream->_flag & _APPEND)
                   {
                   /*
                    * Have to call "lseek" rather than "fseek" since
                    * "fseek" can call us. It does not really make sense
                    * to have a terminal open for update, but if we
                    * are flushing a terminal buffer we don't want to
                    * do an lseek.
                    */
                    if (!isatty(stream->_fd))
                       if (lseek(stream->_fd, 0L, 2) == -1)
                          rtnval = EOF;
                   }

               /*
                    Flush the buffer and reset the stream
                    description block to indicate the buffer
                    is empty
               */
               if (rtnval != EOF)
                  {
                   i = BUFSIZ - ((stream->_cnt >= 0) ? stream->_cnt : 0);
                   rtnval = (write(stream->_fd, stream->_base, i) == i) ?
                                  0 : EOF;
                   stream->_ptr = stream->_base;
                   stream->_cnt = BUFSIZ;
                  }
          }
          else rtnval = 0;
     else rtnval = EOF;

     return(rtnval);
}


/*******************************************************************/


/*
     int fclose(stream)
          FILE *stream;

          This function closes the standard I/O stream
          <stream>.  It flushes the output buffer (if the
          stream is opened for write access), closes the
          file associated with the stream, then releases
          any resources allocated to the stream

     Arguments:
          stream    Pointer to the _iob describing the stream

     Returns: int
          0 if successful, EOF if error

     Revision History:
          06/11/84 kpm - New
          05/13/85 ljn - Added support for update modes.

*/

int fclose(stream)
     register  FILE     *stream;
{
     REGISTER  int       rtnval;


     rtnval = 0;
     if (stream->_flag & (_READ | _WRITE))
     {
          /*
               Flush the buffer if the stream being closed
               is open for writing
          */
          if (((stream->_flag & _WRITE) && (!(stream->_flag & _UPDATE))) ||
              ((stream->_flag & _UPDATE) && (stream->_flag & _LASTWRITE)))
             rtnval = fflush(stream);

          /*
               Close the file associated with the stream
          */
          if (close(stream->_fd) != 0) rtnval = EOF;

          /*
               Release the resources allocated to the stream
          */
          if (stream->_flag & _BIGBUF) free(stream->_base);

          /*
               Reset the buffer describing the stream
          */
          stream->_ptr   = NULL;
          stream->_flag  = 0;
          stream->_fd    = -1;
     }
     else rtnval = EOF;     /* set "errno" someday */

     return(rtnval);
}
