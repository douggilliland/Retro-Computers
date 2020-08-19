/*
 *  strstr.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <string.h>

/*-------------------------------- strstr() ---------------------------------*/

/*
 * strstr locates in the string pointed to by s1 the first occurrence of the
 * sequence of characters (excluding the null terminator) in the string
 * pointed to by s2.  strstr() returns a pointer to the located string, or a
 * null pointer if the sequence is not found in the string.  If s2 points to
 * a zero-length string, s1 is returned.
 */

char *strstr(const char *s1, const char *s2)
{
    register char *ptr1;
    register const char *ptr2;

    while( *s1 ) {
	ptr1 = (char *)s1;
	ptr2 = s2;
	while( (*ptr1++ == *ptr2) && *ptr2 )
	    ptr2++;
	if( *ptr2 == '\0' )
	xit:
	    return((char *)s1);
	s1++;
    }
    s1 = NULL;
    goto xit;
}
