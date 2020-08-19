/*
 *  memmove.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <string.h>

/*-------------------------------- memmove() --------------------------------*/

/*
 * memmove copies count characters from the object pointed to by s2 into the
 * object pointed to by s1.  The copying takes place as if the count
 * characters from the object pointed to by s2 are copied into a buffer that
 * does not overlap the objects pointed to by either s1 or s2, and then count
 * characters from the buffer are copied into the object pointed to by s2.
 * memmove() returns the value of s1.
 *
 * If it is known that the objects do not overlap, a much faster (but larger)
 * function memcpy() can be used.
 */

void *memmove(void *s1, const void *s2, register size_t count)
{
    register char *ptr1;
    register char *ptr2;

    ptr1 = s1;
    ptr2 = s2;

    if( ptr2 > ptr1 ) {
	while( --count != -1 )
	    *ptr1++ = *ptr2++;
	return(s1);
    }

    ptr2 += count;
    ptr1 += count;
    while( --count != -1 )
	*--ptr1 = *--ptr2;
    return(s1);
}
