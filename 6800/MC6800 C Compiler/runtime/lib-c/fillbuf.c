/*
     int _fillbuf(stream)
          FILE *stream;

          This function refreshes the buffer associated
          with the input stream referenced by "stream".  It
          returns "(int) (unsigned) c" where c is the first
          character read, if any, or EOF if none.

          The function allocates a buffer to the stream
          if none is associated with it.

   Revision History:
      06/??/84 kpm - New.
      05/14/85 ljn - Added support for update modes.
      06/03/85 ljn - Set FLEOL if stream is a pipe (too).
*/

#include "machine.h"
#include <stdio.h>

int _fillbuf(stream)
     register  FILE               *stream;
{
               unsigned char       c;
     REGISTER  int                 i;
     REGISTER  FILE               *fp;

               char     *malloc();
               int       isatty();

     /*
       Make sure the stream is active with no EOF or error.
       If not, immediately return EOF
     */

     if (((stream->_flag & _READ) == 0) ||
         ((stream->_flag & (_EOF|_ERR)) != 0)) return(EOF);

     /*
       If the input stream has not been initialized,
       (the stream is buffered but has no buffer)
       initialize it by determining if it is attached
       to a terminal and by allocating to it a buffer
     */

     if (!(stream->_flag & _UNBUF) &&
         (stream->_base == NULL))
     {
          if (_termorpipe(fileno(stream))) stream->_flag |= _FLEOL;
          if ((stream->_base = malloc(BUFSIZ)) == NULL)
               stream->_flag |= _UNBUF;
          else
               stream->_flag |= _BIGBUF;
     }

     /*
       If the input stream is a terminal (_FLEOL set),
       flush all output streams with _FLEOL set (indicates
       that they are buffered and attached to a terminal)
     */

     if (stream->_flag & _FLEOL)
          for (fp = &_iob[0] ; fp < &_iob[_NFILE] ; fp++)
               if ((fp->_flag & _WRITE) &&
                   (fp->_flag & _FLEOL)) fflush(fp);

     /*
       Buffered or unbuffered I/O ??
     */
     if (stream->_flag & _UNBUF)
     {
       /*
         Unbuffered I/O.  Read another character from the
         input file.  If successful, return the character,
         otherwise return EOF (setting flags accordingly)
       */
       i = read(stream->_fd, &c, 1);
       if (i == 1) return(c);
       else
       {
         stream->_flag |= (i == 0) ? _EOF : _ERR;
         return(EOF);
       }
     }
     else
     {
       /*
         Buffered I/O
         Attempt to read a block's worth of data from the
         input file
       */
       stream->_ptr = stream->_base;
       stream->_cnt = read(stream->_fd, stream->_ptr, BUFSIZ);

       /*
         If we got data from the input file, consume the first
         character, returning it
       */
       if (--stream->_cnt >= 0)
         return((int)(unsigned char) *stream->_ptr++);

       /*
         Got no data from the input file.  Set the stream's flags
         to indicate EOF or error (whichever happened) and return
         EOF (remember, we've decremented the count!)
       */
       stream->_flag |= (stream->_cnt == -1) ? _EOF : _ERR;
       return(EOF);
     }
}
