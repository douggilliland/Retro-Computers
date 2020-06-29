/*
 * fread ----
 *
 * Revision History -
 *       06/??/84 kpm - New
 *       05/13/85 ljn - Added support for update modes.
 */
#include "machine.h"
#include <stdio.h>

int fread(ptr,size,nitems,fp)
register char *ptr;              /* where to put the stuff */
REGISTER int size;               /* size of the items to be read */
REGISTER int nitems;             /* number of items to read */
REGISTER FILE *fp;               /* file from which to read */
{
 REGISTER int numread = 0;       /* number of items read */
 REGISTER int sizecnt;           /* size counter */
 REGISTER int numcopy;           /* hold return from getc */
 REGISTER char *bptr;            /* ptr into iobuf */


/*
 * Special case, size <= 0.
 * Just return
 */
 if (size <= 0)
    return(0);

 if (fp->_flag & _LASTWRITE)
    {
    /*
     * File was opened for update and we're trying to do a read following
     * a write. This is an error.
     */
     fp->_flag |= _ERR;
     return(0);
    }
/*
 * Check and see if we did a read last. If not we've got to fill the
 * buffer. This can happen after seeks.
 */
 if ((fp->_flag & _UPDATE) && !(fp->_flag & _LASTREAD))
    {
     fp->_cnt = 0;
    }

/*
 * Read the first item specially.  Must be able
 * to correctly handle an "ungotten" character
 * on the stream
 */
 if (fp->_save != EOF)
    if (nitems-- > 0)
    {
       *ptr++ = (char) fp->_save;
       fp->_save = EOF;
       sizecnt = size - 1;
       while (sizecnt > 0)
       {
          if (sizecnt <= fp->_cnt)
          {
             numcopy = sizecnt;
             fp->_cnt -= numcopy;
             sizecnt = 0;
          }
          else
          {
             numcopy = (fp->_cnt > 0) ? fp->_cnt : 0;
             sizecnt -= numcopy;
             fp->_cnt = 0;
          }
          bptr = fp->_ptr;
          if (numcopy) while (numcopy--) *ptr++ = *bptr++;
          fp->_ptr = bptr;
          if (sizecnt)
          {
             if ((numcopy = _fillbuf(fp)) == EOF)
                {
                /*
                 * If we've hit EOF then turn off the last read bit
                 * to allow a write to a file opened for update.
                 */
                 fp->_flag &= ~_LASTREAD;
                 return(numread);
                }
             *ptr++ = numcopy;
             --sizecnt;
          }
       }
       numread = 1;
    }

/*
 * Always copy as much as possible from the buffer,
 * and call fillbuf when we run out.
 */
 while (nitems-- > 0)
    {
     sizecnt = size;
     while (sizecnt > 0)
        {
        /*
         * Is there enough in the buffer? If so adjust the count,
         * clear the loop ctr and set the number of bytes to be
         * copied. If not, copy only what's left in the buffer,
         * adjust the loop ctr and clear the buffer ctr.
         */
         if (sizecnt <= fp->_cnt)
            {
             numcopy = sizecnt;
             fp->_cnt -= numcopy;
             sizecnt = 0;
            }
         else
            {
             numcopy = (fp->_cnt > 0) ? fp->_cnt : 0;
             sizecnt -= numcopy;
             fp->_cnt = 0;
            }
        /*
         * Set the buffer ptr and copy the number of bytes
         * specified. After the loop, reset the buffer ptr
         * to the current position.
         */
         bptr = fp->_ptr;
         if (numcopy) while (numcopy--) *ptr++ = *bptr++;
         fp->_ptr = bptr;
        /*
         * If there is still data to be read for this item,
         * then we are at the end of the buffer and have to
         * call fillbuf to get more. Fillbuf returns the first
         * character in the buffer (or EOF) and adjusts the
         * ptr and ctr.
         */
         if (sizecnt)
            {
             if ((numcopy = _fillbuf(fp)) == EOF)
                {
                /*
                 * If we've hit EOF then turn off the last read bit
                 * to allow a write to a file opened for update.
                 */
                 fp->_flag &= ~_LASTREAD;
                 return(numread);
                }
             *ptr++ = numcopy;
             --sizecnt;
            }
        }
     ++numread;
    }
/*
 * Record the fact that we just did a read for files opened for update.
 */
 fp->_flag |= _LASTREAD;
 return(numread);
}
