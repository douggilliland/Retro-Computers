/*
 *  fsetpos.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdio.h>
#include <errno.h>

/*-------------------------------- fsetpos() --------------------------------*/

/*
 * fsetpos set the file position indicator for the stream pointed to by fp
 * according to the value of the object pointed to by position, which must
 * be a value obtained from an earlier call to fgetpos() on the same stream.
 * A successful call to fsetpos() clears the end-of-file indicator for the
 * stream and undoes any effects of ungetc() on the same stream.  After
 * a call to fsetpos(), the next operation on an update stream may be either
 * input or output.  If successful, fsetpos() returns zero.  On failure,
 * fsetpos() returns non-zero and stores macro EBADF in errno.
 *
 * Usage:
 *
 *	int fsetpos( FILE *fp, const fpos_t *position)
 *
 *	fp -------- pointer to the stream
 *	position -- pointer to the object containing the information obtained
 *		    from a call to fgetpos() needed to reposition file
 *		    position indicator.
 *	return ---- zero on success and non-zero on failure
 */ 

int fsetpos(FILE *fp, const fpos_t *position)
{
    if( fseek(fp, *position, SEEK_SET) ) {
	errno = EBADF;
	return(-1);
    }
    return(0);
}
