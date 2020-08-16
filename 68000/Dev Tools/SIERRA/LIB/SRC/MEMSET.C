/*
 *  memset.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <string.h>

/*--------------------------------- memset() --------------------------------*/

/*
 * memset is a standard C library function which initializes a memory area
 * with a specified character.	memset() does as much of the initialization
 * as possible using integer assignments, and minimizes loop overhead by
 * grouping several assignments within each control loop.  Note, memset() has
 * a smaller but slower counterpart _memset() in the library that is about
 * 10 times slower than this version.
 *
 * Usage:
 *
 *	void *memset(void *dest, int c, size_t count)
 *
 *	dest ---- a pointer to the destination location
 *	c ------- the character with which the memory is to be initialized
 *	count --- the number of bytes to be initialized
 *	return -- returns the value of dest
 */

void *memset(void *dest, register int c, register size_t count)
{
    register long *ldest;
    register long fourbytes;
    register long num_long_iter;
    register long num_longs;
    register long temp;
    register char *dest1;

    dest1 = dest;

    if( count <= 3 )
	goto three_or_less;

    temp = (unsigned char)c;
    fourbytes = temp;
    fourbytes += temp << 8;
    fourbytes += fourbytes << 16;

    switch( (int)dest1 & 0x03 ) {	/* align to an integer boundary */
    case 1: *dest1++ = c; --count;
    case 2: *dest1++ = c; --count;
    case 3: *dest1++ = c; --count;
    }
    num_longs = count >> 2;		/* remaining number of longs	*/
    num_long_iter = num_longs >> 3;	/* number of 8-at-a-time loops	*/
    ldest = (long *)dest1;

    /* align to multiple of 8 assignments at a time using switch */

    switch( num_longs & 0x7 ) {

	while( --num_long_iter != -1 ) {
	    *ldest++ = fourbytes;
    case 7: *ldest++ = fourbytes;
    case 6: *ldest++ = fourbytes;
    case 5: *ldest++ = fourbytes;
    case 4: *ldest++ = fourbytes;
    case 3: *ldest++ = fourbytes;
    case 2: *ldest++ = fourbytes;
    case 1: *ldest++ = fourbytes;
    case 0: ;
	}
    }

    dest1 = (char *)ldest;

    /* there are now at most 3 characters remaining */

three_or_less:
    switch( (int)count & 0x3 ) {
	case 3:	*dest1++ = c;
	case 2:	*dest1++ = c;
	case 1:	*dest1++ = c;
    }

    return(dest);
}
