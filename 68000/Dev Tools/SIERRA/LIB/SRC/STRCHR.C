/*
 *  strchr.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <string.h>

/*------------------------------- strchr() ----------------------------------*/

/*
 * strchr locates the first occurrence of c (converted to a character) in the
 * the string pointed to by str.  The null terminator is considered part of
 * the string.	A pointer to the located character is returned, or a null
 * pointer if the character can not be located in the string.
 */

char *strchr(register const char *str, register int c)
{
    while( (*str != (char)c) && *str ) 
	str++;
    return( (*str == (char)c) ? (char *)str : NULL );
}

