/*
 * fwrite ---
 *
 * Revision History -
 *       06/??/84 kpm - New
 *       05/13/85 ljn - Added support for update modes.
 */
#include "machine.h"
#include <stdio.h>

int fwrite(ptr, size, nitems, fp)
register char *ptr;            /* data to be written */
REGISTER int size;             /* size of data items */
REGISTER int nitems;           /* number of data items */
REGISTER FILE *fp;             /* file pointer */
{
 REGISTER int numwritten = 0;
 REGISTER int sizecnt;
 REGISTER int numcopy;
 REGISTER char *bptr;

 if (fp->_flag & _LASTREAD)
    {
    /*
     * File is open for update and we're trying to do a write directly
     * after a read. This is an error.
     */
     fp->_flag |= _ERR;
     return(0);
    }
/*
 * Check and see if we did a write last. If not we've got room in the
 * buffer. This can happen after seeks.
 */
 if ((!(fp->_flag & _LASTWRITE)) && (fp->_ptr))
    {
     fp->_cnt = BUFSIZ;
     fp->_ptr = fp->_base;
    }

 while (nitems-- > 0)
    {
     sizecnt = size;
     while (sizecnt > 0)
        {
        /*
         * Write as much as possible into the buffer.
         * If there is space in the buffer for the whole
         * item, then copy the whole item adjust the buffer
         * count and clear the remaining size. Otherwise,
         * copy until the buffer is full.
         */
         if (sizecnt <= fp->_cnt)
            {
             numcopy = sizecnt;
             fp->_cnt -= numcopy;
             sizecnt = 0;
            }
         else
            {
             numcopy = fp->_cnt;
             sizecnt -= numcopy;
             fp->_cnt = 0;
            }
        /*
         * Set the buffer ptr then copy the data to the buffer.
         * After copying, reset the buffer ptr to the current
         * position.
         */
         bptr = fp->_ptr;
         while (numcopy)
            {
             *bptr++ = *ptr++;
             --numcopy;
            }
         fp->_ptr = bptr;
        /*
         * If there is still more to write, then we've copied
         * to the end of the buffer and we'll have to call
         * flushbuf to clean things up.
         */
         if (sizecnt)
            {
             if (_flushbuf(*ptr++,fp) == EOF)
                {
                /*
                 * Record the fact that we're doing a write here for files open for update.
                 */
                 fp->_flag |= _LASTWRITE;
                 return(numwritten);
                }
             --sizecnt;
            }
        }
     ++numwritten;
    }
/*
 * Record the fact that we're doing a write here for files open for update.
 */
 fp->_flag |= _LASTWRITE;
 return(numwritten);
}
