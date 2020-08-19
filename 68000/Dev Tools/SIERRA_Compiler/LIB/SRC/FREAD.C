/*
 *  fread.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdio.h>

/*-------------------------------- fread() ----------------------------------*/

/*
 * fread reads, into the array pointed to by ptr, up to nbr_elements
 * whose size is specified by size.  The elements are read from the stream
 * pointed to by fp.  The file position indicator for the stream (if defined)
 * is advanced by the number of characters successfully read.  If an error
 * occurs, the resulting value of the file position indicator for the
 * stream is indeterminite.  fread() returns the number of elements
 * successfully read, which may be less than nbr_elements if a read error or
 * end-of_file is encountered.	If size or nbr_elements is zero, fread()
 * returns zero and the contents of the array and the stream remain unchanged.
 *
 * Usage:
 *
 *	size_t fread(void *ptr, size_t size, size_t nbr_elements, FILE *stream)
 *
 *	ptr ----------- pointer to the array to read into
 *	size ---------- the size of each element to be read
 *	nbr_elements -- the number of elements to read
 *	fp ------------- pointer to the file i/o structure
 *	return -------- the number of elements successfully read
 */

size_t fread(void *ptr, size_t size, size_t nbr_elements, register FILE *fp)
{
    register int bytes_remaining;
    register char *ptr1;
    int elements_read;
    int c;

    ptr1 = ptr;
    elements_read = 0;

    if( size && nbr_elements ) {
	while( elements_read < nbr_elements ) {
	    bytes_remaining = size;
	    while( bytes_remaining-- ) {
		if( (c = getc(fp)) == EOF )
		    return(elements_read);
		*ptr1++ = c;
	    }
	    elements_read++;
	}
    }
    return(elements_read);
}
