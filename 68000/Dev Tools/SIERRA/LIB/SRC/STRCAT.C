/*
 *  strcat.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <string.h>

/*----------------------------- strcat() ------------------------------------*/

/*
 * strcat is a stadard C library function that appends a copy of the string
 * pointed to s2 (including the null terminator) to the end of the string
 * pointed to by s1.  The initial character of s2 overwrites the null
 * terminator of s1.  If copying takes place between overlapping objects,
 * the behavior is undefined.
 */

char *strcat(register char *s1, register const char *s2)
{
    register long base;

    base = (long)s1;
    while( *s1++ );
    s1--;
    while( *s1++ = *s2++ );
    return((char *)base);
}
