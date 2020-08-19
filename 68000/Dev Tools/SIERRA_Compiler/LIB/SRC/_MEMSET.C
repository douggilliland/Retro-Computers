/*
 *  _memset.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <string.h>

/*-------------------------------- _memset() --------------------------------*

/*
 * _memset is a standard C library function which initializes a memory area
 * with a specified character.
 *
 * Usage:
 *
 *	void *_memset(void *dest, int c, size_t count)
 *
 *	dest ---- a pointer to the destination location
 *	c ------- the character with which the memory is to be initialized
 *	count --- the number of bytes to be initialized
 *	return -- returns the value of dest
 *
 * Note: _memset() is a smaller but slower version of memset().	 _memset()
 * is faster for short copies, but is about ten times slower than memset()
 * on longer copies.
 */

void *_memset(void *dest, register int c, register size_t count)
{
    register char *dest1;

    dest1 = dest;
    while( --count != -1 )
	*dest1++ = c;
    return(dest);
}

