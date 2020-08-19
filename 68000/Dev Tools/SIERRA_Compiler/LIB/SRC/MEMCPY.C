/*
 *  memcpy.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <string.h>

/*--------------------------------- memcpy() --------------------------------*/

/*
 * memcpy is a standard C library function which performs fast memory
 * from a source buffer to a destination buffer.  memcpy() does as much of
 * the data transfer as possible using integer assignments, and minimizes
 * loop overhead by grouping several assignments within each control loop.
 * For the most efficient copy, buffer alignments must permit integer
 * transfers.  For instance, if one begins at an odd address, and the other
 * begins at an even address, it is not possible to do integer data
 * transfers.  On the other hand, if the buffer locations are equal mod 2,
 * int data type transfers can be used.
 *
 * (1) Alignment of the buffers is checked first.  If they are both at
 * even or both at odd addresses, 0-3 byte copies are done to align the
 * destination buffer to a long boundary.  Otherwise control moves to the
 * byte transfer part of the function.	(2) Next, 0-7 int copies are done so
 * that the remaining number of integers to be copied is a multiple of 8.
 * (3) Integer copies are done 8 at a time within a single loop.  (4) The
 * remaining bytes are copied using the same algorithm.
 *
 * Usage:
 *
 *	void *memcpy(void *dest, const void *src, size_t count)
 *
 *	dest ---- a pointer to the destination location
 *	src ----- a pointer to the source location
 *	count --- the number of bytes to be initialized
 *	return -- returns the value of dest
 */

void *memcpy(void *dest, const void *src, register size_t count)
{
    register long *idest;
    register long *isource;
    register long num_iter;
    register long num_longs;
    register char *dest1;
    register char *source;

    source = src;
    dest1 = dest;

    if( (long)count < 0 )
	count = 0;

    /* Test to see if buffer boundaries allow integer transfers.  If so, */
    /* do the alignment, otherwise, skip to the byte transfer part of	 */
    /* of the function.							 */

    if( !((dest1 - source) & 0x1) && (count >= 4) ) {
	switch( (int)dest1 & 0x3 ) {
	case 1: *dest1++ = *source++; --count;
	case 2: *dest1++ = *source++; --count;
	case 3: *dest1++ = *source++; --count;
	}

	num_longs = count >> 2;
	num_iter = num_longs >> 3;
	idest = (long *)dest1;
	isource = (long *)source;

	switch( num_longs & 0x07 ) {	
	    while( --num_iter != -1 ) {
		*idest++ = *isource++;
	case 7: *idest++ = *isource++;
	case 6: *idest++ = *isource++;
	case 5: *idest++ = *isource++;
	case 4: *idest++ = *isource++;
	case 3: *idest++ = *isource++;
	case 2: *idest++ = *isource++;
	case 1: *idest++ = *isource++;
	case 0: ;
	    }
	}

	dest1 = (char *)idest;
	source = (char *)isource;

	/* there are at most 3 characters left -- copy them */

	switch( count & 0x3 ) {
	case 3: *dest1++ = *source++;
	case 2: *dest1++ = *source++;
	case 1: *dest1++ = *source++;
	}
    }
    else {
	num_iter = count >> 3;

	/* Reaching here indicates boundaries were not equal mod 2 or */
	/* there were fewer than 4 bytes to be transfered.	      */

	switch(count & 0x7) {
	    while( --num_iter != -1 ) {
		*dest1++ = *source++;
	case 7: *dest1++ = *source++;
	case 6: *dest1++ = *source++;
	case 5: *dest1++ = *source++;
	case 4: *dest1++ = *source++;
	case 3: *dest1++ = *source++;
	case 2: *dest1++ = *source++;
	case 1: *dest1++ = *source++;
	case 0: ;
	    }
	}
    }
    return(dest);
}
