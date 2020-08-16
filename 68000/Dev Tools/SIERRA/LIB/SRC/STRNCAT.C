/*
 *  strncat.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <string.h>

/*----------------------------- strncat() -----------------------------------*/

/*
 * strncat is a stadard C library function that appends not more than count
 * characters (the null terminator and the characters that follow are not
 * appended) from the string pointed to by s2 to the end of the string
 * pointed to by s1.  The initial character of s2 overwrites the null
 * terminator of s1.  A null terminator is always appended to the end of s1.
 * If copying takes place between overlapping objects, the behavior is]
 * undefined.
 */

char *strncat
(
register char *s1,
register const char *s2,
register size_t count
)
{
    register long base;

    base = (long)s1;

    while( *s1++ );
    s1--;
    if( count-- )
	while( (*s1++ = *s2++) && (--count != -1) );
    if( count == -1 )
	*s1 = '\0';
    return((char *)base);
}
