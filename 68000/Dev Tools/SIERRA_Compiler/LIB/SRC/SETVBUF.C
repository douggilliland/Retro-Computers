/*
 *  setvbuf.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdio.h>
#include <stdlib.h>

/*--------------------------------- setvbuf() -------------------------------*/
									
/*
 * setvbuf may be used only after the stream pointed to by fp has been
 * associated with an open file and before any other operation has is
 * performed on the stream.  The argument mode determines how the stream
 * will be buffered:
 *
 * _IOFBF   input/output is fully buffered
 * _IOLBF   input/output is line buffered
 * _IONBF   input/output is not buffered at all
 *
 * If buf is not a null pointer, the array it points to may be used instead
 * of a buffer allocated by setvbuf().	The argument size specified the size
 * of the array.  setvbuf() returns zero on success, or non-zero if an
 * invalid value is specified for mode or the request cannot be honored.
 *
 * Usage:
 *
 *	int setvbuf(FILE *fp, char *buf, int mode, size_t size)
 *
 *	fp ------ pointer to the stream assoicated with the file
 *	buf ----- pointer to the array to be used as the FILE buffer
 *	mode ---- how the stream is to be buffered (full, line, none)
 *	size ---- size of the buffer pointed to by buf
 *	return -- returns zero on success, non-zero on failure
 */

int setvbuf(FILE *fp, char *buf, int mode, size_t size)
{
    /* If the mode is not one of _IOFBF, _IOLBF or _IONBF, return an error. */
    /* If a buffer is specified, and size is zero or less, return an error. */
    /* If a buffer has previously been assigned (fp->_base != NULL), return */
    /* an error.							    */

    if( ((mode != _IOFBF) && (mode != _IOLBF) && (mode != _IONBF)) ||
    (buf && (size <= 0)) || fp->base )
	return(-1);

    /* assign buffer to FILE structure */

    if( (mode != _IONBF) && size ) {
	if( !buf )
	    buf = malloc(size);
	fp->base = buf;
	fp->ptr = buf;
	fp->bufsize = size;
    }

    /* clear and reset buffering mode */

    fp->flags &= ~(_IOFBF | _IOLBF | _IONBF);
    fp->flags |= mode;

    return(0);
}
