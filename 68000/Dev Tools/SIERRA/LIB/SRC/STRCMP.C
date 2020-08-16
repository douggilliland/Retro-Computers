/*
 *  strcmp.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <string.h>

/*-------------------------------- strcmp() ---------------------------------*/

/*
 * strcmp compares the string pointed to be s1 to the string pointed to by
 * s2.	strcmp() returns an integer greater than, equal to, or less than zero,
 * corresponding to the string pointed to by s1 being greater than, equal to,
 * or less than the string pointed to by s2.
 */

int strcmp(register const char *s1, register const char *s2)
{
    register char c;

    while( c = *s2++ )
	if( *s1++ != c )
	    return((char)(*--s1 - c));
    return(*s1);
}
