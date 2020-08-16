/*
 *  fseek.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdio.h>
#include <io.h>
#include <errno.h>

/*--------------------------------- fseek() ---------------------------------*/

/*
 * fseek sets the file position indicator for the stream pointed to by fp.
 * The request to update the file position pointer is relative to the
 * beginning of the file, the end of the file, or the current position in
 * the file.  The actual repositioning of the system file pointer is done by
 * a call to lseek(); the task of fseek() is to ensure that the FILE
 * structure remains synchronized with its associated file.  If possible,
 * read buffers are preserved by avoiding the call to lseek() and modifying
 * the ptr and cnt members instead to reflect the new position in the file.
 * Write buffers are always flushed before the file pointer is repositioned.
 * The character pushed back by an ungetc() call is no longer available after
 * an fseek() call.
 *
 * Since either input or output operations may be performed on an update
 * stream after a call to fseek(), these streams require some special
 * handling.  fseek() never attempts to preserve read buffers on update
 * streams, since, if the next I/O call is a write, the buffer would appear
 * non-empty and thus the accuracy of the FILE structure would be permanently
 * lost.  fseek() leaves update streams empty so that the next call to a
 * formatted I/O will generate a call to _fillbuf() (in the case of an input
 * operation) or _flushbuf() (in the case of an output operation); these
 * functions will prepare the stream for the requested I/O operation.
 *
 * fseek() returns 0 if the file pointer is repositioned successfully,
 * else EOF.
 *
 * Usage:
 *
 *	fseek(FILE *fp, long offset, int whence)
 *
 *	fp ------ pointer to the FILE structure associated with the stream
 *		  that is to be repositioned
 *	offset -- the amount to offset the file pointer measured in bytes in
 *		  current implementation, otherwise measured in the units of
 *		  the return value of ftell()
 *	whence -- a code describing the location relative to which the file
 *		  pointer is to be repositioned in the amount of offset
 *		  0 - offset file pointer relative to beginning of file
 *		  1 - offset file pointer relative to current position
 *		  2 - offset file pointer relative to end of file
 */

int fseek(register FILE *fp, long offset, int whence)
{
    register long distance;

    /* clear the ungetc() flag and restore the count */

    if( fp->flags & _UNGCH ) {
	fp->flags &= ~_UNGCH;
	fp->cnt = fp->save_cnt;
    }

    /* check validity of FILE structure and whence argument */

    if( !(fp->flags & (_IOREAD | _IOWRITE | _IORW)) || 
    (fp->flags & _IOERR) || (whence < 0) || (whence > 2) )
	return(EOF);

    fp->flags &= ~_IOEOF;

    /* process read buffers */

    if( fp->flags & _IOREAD ) {
	if( !(fp->flags & (_IONBF | _IORW)) && fp->base && (whence < 2) ) {

	    /* try to preserve the buffer */

	    distance = offset;
	    if( fp->flags & _IOLBF )
		fp->cnt = fp->base + fp->bufsize - fp->ptr;

	    /* If measuring from the start of the file, determine what the */
	    /* distance is from current position.			   */

	    if( whence == 0 )
		distance -= lseek(fp->fd, 0L, 1) - fp->cnt;

	    /* If the seek can take place within the existing buffer, adjust */
	    /* the ptr and cnt FILE members to reflect the seek then return. */

	    if (fp->cnt >= 0 && ((fp->base - fp->ptr) <= distance) &&
	    (distance <= fp->cnt) ) {
		fp->ptr += distance;
		if( fp->flags & _IOLBF )
		    fp->cnt = 0;
		else
		    fp->cnt -= distance;
		return(0);
	    }
	}
	/* if this is a read/write file, tune off the read flag */

	if( fp->flags & _IORW )
	    fp->flags &= ~_IOREAD;

	/* If seek is from current position, adjust offset to be the */
	/* offset from the file position.			     */

	if( whence == 1 )
	    offset -= fp->cnt;

	/* clear the buffer */

	fp->cnt = 0;
	fp->ptr = fp->base;

	/* Note that the buffer doesn't contain any characters that are not */
	/* already a part of the file.	Because the read flag was on, the   */
	/* last operation on the file was a read, therefore no new	    */
	/* characters are in the buffer.				    */
    }

    /* process write buffers */

    else {

	/* fflush() sets   ptr = base	and   cnt = 0 */

	if( fflush(fp) == EOF )
	    return(-1);

	/* because a read may follow, clear the write flag */

	if( fp->flags & _IORW )
	    fp->flags &= ~_IOWRITE;
    }
    return( (lseek(fp->fd, offset, whence) == -1) ? -1 : 0 );
}

/*-------------------------------- ftell() ----------------------------------*/

/*
 * ftell obtains the current value of the file position indicator for the
 * stream pointed to by fp.  For a binary file, the value is the number of
 * characters from the beginning of the file.  For a text file, the position
 * indicator contains unspecified information, usable by fseek() for
 * returning the file position indicator for the file to its position at the
 * time of the call to ftell(); the difference between two such return
 * values is not necessarily the ni\umber of characters written or read.
 * If successful, ftell() returns the current value of the file position
 * indicator for the file.  On failure, ftell() returns -1L and stores
 * the value of macro EBADF in errno.
 */

long ftell(FILE *fp)
{
    register int offset;
    long lseek_value;

    if( !(fp->flags & (_IOREAD | _IOWRITE | _IORW)) ) {
	errno = EBADF;
	return(-1);
    }

    if( fp->cnt < 0 )
	fp->cnt = 0;
    if( (fp->flags & _IONBF) || (fp->base == NULL) )
	offset = 0;
    else if( fp->flags & _IOREAD )
	offset = -fp->cnt;
    else
	offset = fp->ptr - fp->base;

    if( (lseek_value = lseek(fp->fd, 0L, 1)) == -1L ) {
	errno = EBADF;
	return(-1);
    }

    return(lseek_value + offset + (fp->flags & _UNGCH) ? 1: 0);
}

/*-------------------------------- rewind() ---------------------------------*/

/*
 * rewind sets the file position indicator for the stream pointed to by fp
 * to the beginning of the file.  rewind() performas the same operation as
 * fseek(fp, 0L, 0) except that the error indicator fro fp is also cleared.
 */

void rewind(FILE *fp)
{
    clearerr(fp);
    fseek(fp, 0L, 0);
}
