/*
 *  fclose.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdio.h>

/*-------------------------------- fclose() ---------------------------------*/

/*
 * fclose causes the stream pointed to by fp to be flushed and the associated
 * file to be closed.  Any unwritten buffered data for the stream are
 * delivered to the host environment to be written to the file.	 The stream
 * is disassociated from the file.  If the associated file was automatically
 * allocated, it is deallocated.  fclose() returns zero if the stream is was
 * successfully closed, and EOF if any errors were detected.
 */

fclose(register FILE *fp)
{
    register int error_flag;

    if( (fp->flags & _IOERR) ||
    !(fp->flags & (_IOREAD | _IOWRITE | _IORW)) )
	error_flag = EOF;
    else {
	error_flag = fflush(fp);
	if( fp->flags & _IOMYBUF )
	    free(fp->base);
#if 0
	/* remove the tmpfile */

	if( fp->flags & _TMPFILE ) {
	    if( fdremove(fp->fd) );
		error_flag = EOF;
	}
	else
#endif
	if( close(fp->fd) )
	    error_flag = EOF;
    }

    fp->cnt = 0;
    fp->ptr = NULL;
    fp->base = NULL;
    fp->flags = 0;	    /* flag stream as available */

    return(error_flag);
}
