/*
 *  strcspn.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <string.h>

/*-------------------------------- strcspn() --------------------------------*/

/*
 * strcspn computes the length of the maximum initial segment of the string
 * pointed to be s1 which consists entirely of characters NOT from the
 * string pointed to by s2.  strcspn() returns the length of the segment.
 */

size_t strcspn(register const char *s1, register const char *s2)
{
    register const char *ptr;
    register size_t count;

    for( count = 0; *s1; s1++, count++ ) {
	for( ptr = s2; (*ptr != *s1) && *ptr; ptr++ );
	if( *ptr )
	    break;
    }
    return(count);
}
