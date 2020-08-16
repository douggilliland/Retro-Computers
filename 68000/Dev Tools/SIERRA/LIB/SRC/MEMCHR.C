/*
 *  memchr.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <string.h>

/*-------------------------------- memchr() ---------------------------------*/

/*
 * memchr locates the first occurrence of c (converted to an unsigned char)
 * in the initial count characters (each interpreted as an unsigned char) of
 * the object pointed to by s.	memchr() returns a pointer to the located
 * character, or a null pointer if the character does not exist in the object
 * pointed to be s.
 */

void *memchr(const void *s, int c, register size_t count)
{
    register unsigned char ch;
    register unsigned char *ptr;

    ch = c;
    ptr = (unsigned char *)s;

    while( (*ptr++ != ch) && (--count != -1) );

    if( (*--ptr == ch) && (count == 0) )
	return(NULL);

    return( (count == -1) ? NULL : (void *)ptr );
}
