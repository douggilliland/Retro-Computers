/*
 *  strchr.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <string.h>

/*------------------------------- strchr() ----------------------------------*/

/*
 * strchr locates the last occurrence of c (converted to a character) in the
 * the string pointed to by str.  The null terminator is considered part of
 * the string.	A pointer to the located character is returned, or a null
 * pointer if the character can not be located in the string.
 */

char *strrchr(register const char *str, register int c)
{
    register char *ptr;

    ptr = NULL;
    do {
	if( (char)c == *str )
	    ptr = (char *)str;
    } while( *str++ );
    return(ptr);
}
