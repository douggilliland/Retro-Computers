/*
 *  fwrite.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdio.h>

/*------------------------------- fwrite() ----------------------------------*/

/*
 * fwrite writes, from the array pointed to by ptr, up to nbr_elements
 * whose size is specified by size.  The elements are write to the stream
 * pointed to by fp.  The file position indicator for the stream (if defined)
 * is advanced by the number of characters successfully writen.	 If an error
 * occurs, the resulting value of the file position indicator for the
 * stream is indeterminite.  fwrite() returns the number of elements
 * successfully writen, which will be less than nbr_elements only if a write
 * error is encountered.
 *
 * Usage:
 *
 *	size_t fwrite(const void *ptr, size_t size, size_t nbr_elements,
 *	FILE *stream)
 *
 *	ptr ----------- pointer to the array to write from
 *	size ---------- the size of each element to write
 *	nbr_elements -- the number of elements to write
 *	fp ------------- pointer to the file i/o structure
 *	return -------- the number of elements successfully written
 */

size_t fwrite(const void *ptr, size_t size, size_t nbr_elements,
register FILE *fp)
{
    register int bytes_remaining;
    register char *ptr1;
    int elements_written;
    int c;

    ptr1 = ptr;
    elements_written = 0;

    if( size && nbr_elements ) {
	while( elements_written < nbr_elements ) {
	    bytes_remaining = size;
	    while( bytes_remaining-- ) {
		c = *ptr1++;
		if( putc(c, fp) == EOF )
		    return(elements_written);
	    }
	    elements_written++;
	}
    }
    return(elements_written);
}
