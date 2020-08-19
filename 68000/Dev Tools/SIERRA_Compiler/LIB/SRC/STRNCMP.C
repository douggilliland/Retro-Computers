/*
 *  strncmp.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <string.h>

/*-------------------------------- strcnmp() --------------------------------*/

/*
 * strncmp compares not more than count characters (characters following the
 * null terminator are not compared) from the string pointed to by s1 to the
 * string pointed to by s2.  strncmp() returns an integer greater than, equal
 * to, or less than zero, corresponding to the possibly null-terminated
 * string pointed to by s1 being greater than, equal to, or less than the
 * the possibly null-terminated string pointed to by s2.
 */

int strncmp(register const char *s1, register const char *s2, size_t count)
{
    while( (*s1 == *s2) && (--count != -1) ) {
	if( !*s1++ )
	    return(0);
	s2++;
    }
    if( *s1 != *s2 )
	count--;
    return((count != -1) ? (char)(*s1 - *s2) : 0);
}
