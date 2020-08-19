/*
 *  strpbrk.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <string.h>

/*-------------------------------- strpbrk() --------------------------------*/

/*
 * strpbrk locates the first occurrence in a null-terminated string pointed
 * to s1 any character from the null-terminated string pointed to by s2.  A
 * pointer to the character is returned or a null pointer if no characters
 * from s2 appear in s1.
 */

char *strpbrk(register const char *s1, const char *s2)
{
    register const char *ptr;
    register long char_set;
    register char c;

    char_set = (long)s2;
    while( c = *s1++ ) {
	for( ptr = (const char *)char_set ; (*ptr != c) && *ptr; ptr++ );
	if( *ptr )
	    return((char *)(s1 - 1));
    }
    return(NULL);
}
