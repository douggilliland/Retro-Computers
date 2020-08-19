/*
 *  strcpy.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <string.h>

/*------------------------------- strcpy () ---------------------------------*/
/*
 * strcpy copies the string pointed to by s2 (including the null terminator)
 * into the array pointed to be s1.  If the memory pointed to be s1 and s2
 * overlap, the behavior is undefined.	The value of s1 is returned.
 */

char *strcpy(register char *s1, register const char *s2)
{
    long base;

    base = (long)s1;
    while( *s1++ = *s2++ );
    return((char*)base);
}
