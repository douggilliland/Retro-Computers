/*
 *  strncpy.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <string.h>

/*------------------------------- strncpy() ---------------------------------*/

/*
 * strncpy is a standard C library function.  It copies the first count
 * characters of the string s2 into the string s1.  If s2 contains fewer than
 * count characters, strncpy() null pads the remaining places in s1 up to the nth
 * place.  If count is 0 no change results.  A pointer to s1 is returned.
 * If s1 and s2 overlap, results are unpredictable.
 */

char *strncpy(char *s1, const char *s2, size_t count)
{
    long base;
    register long count1;

    base = (long)s1;
    count1 = count;
    while( (--count1 >= 0) && (*s1++ = *s2++) );
    while( --count1 >= 0 )
	*s1++ = '\0';
    return((char *)base);
}
