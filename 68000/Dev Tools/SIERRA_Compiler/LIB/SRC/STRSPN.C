/*
 *  strspn.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <string.h>

/*--------------------------------- strspn() --------------------------------*/

/*
 * strspn determines the length of the maximum intial segment of the null-
 * terminated string pointed to by s1 which consists entirely of characters
 * from the null-terminated string pointed to by s2.  strspn() returns the
 * length of the segment.
 */

size_t strspn(register const char *s1, register const char *s2)
{
    register size_t count;
    register char c;
    register const char *ptr;

    count = 0;
    while( c = *s1++ ) {
	for( ptr = s2; (*ptr != c) && *ptr; ptr++ );
	if( !*ptr )
	    break;
	count++;
    }
    return(count);
}
