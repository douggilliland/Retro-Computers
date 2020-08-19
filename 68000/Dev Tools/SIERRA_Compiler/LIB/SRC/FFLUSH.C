/*
 *  fflush.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdio.h>

/*--------------------------------- fflush() --------------------------------*/

/*
 * fflush causes any unwritten data for a stream to be delivered to the
 * host environment to be written to a file, if the fp points to an output
 * or update stream in which the most recent operation was not input.  If fp
 * is a null pointer, fflush() performs this flushing action on all streams
 * for which the behavior is defined.  fflush() returns zero if successful,
 * else it returns EOF if a write error occurs.
 */

int fflush(register FILE *fp)
{
    register int write_count;

    /* flush all open streams if fp is a null pointer */

    if( fp == NULL ) {
	for( fp = _iob; fp < (_iob + FOPEN_MAX); fp++ )
	    if( fp->flags & (_IOREAD | _IOWRITE | _IORW) )
		fflush(fp);
    }

    /* undo the effect of a previous call to ungetc() */

    if( fp->flags & _UNGCH ) {
	fp->flags &= ~_UNGCH;
	fp->cnt = fp->save_cnt;
    }

    /* do not flush a file which has an I/O error or is unbuffered */

    if( !(fp->flags & (_IOERR | _IONBF)) ) {

	/* If this file was written on the last access, and other conditions */
	/* check, try writing the buffer.  Return error on failure.  If this */
	/* is an append stream, force the read/write pointer to EOF.	     */

	if( (fp->flags & _IOWRITE) && fp->base &&
	((write_count = fp->ptr - fp->base) > 0) ) {
	    if( (fp->flags & _IOAPPEND) && (lseek(fp->fd, 0L, 2) == -1) )
		return(EOF);
	    if( write(fp->fd, fp->base, write_count) != write_count ) {
		fp->flags |= _IOERR;
		fp->cnt = 0;
		return(EOF);
	    }

	    /* reset pointer to start of buffer */

	    fp->ptr = fp->base;

	    /* if file is rd/wr, prepare for possible read on next access */

	    if( fp->flags & _IORW )
		fp->flags &= ~_IOWRITE;

	    /* Set cnt to 0 even though in full buffered cases it could be  */
	    /* set to _bufsize.	 This provides error checking if an attempt */
	    /* is made to read a write only stream after calling fflush().  */

	    fp->cnt = 0;
	}

	/* If the stream is read/write and the read flag is on, call */
	/* fseek() to readjust everything.  In this case, the low    */
	/* level read/write pointer is synchronized to prepare for a */
	/* possible switch to writing.				     */

	else if( fp->flags & (_IOREAD | _IORW) == (_IOREAD | _IORW) )
	    fseek(fp, 0L, SEEK_CUR);
    }
    return(0);
}
