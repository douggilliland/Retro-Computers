/*
 *  memcmp.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <string.h>

/*-------------------------------- memcmp() ---------------------------------*/

/*
 * memcmp compares the first count characers of the object pointed to by s1
 * to the first count characters of the object pointed to by s2.  memcmp()
 * returns an integer greater than, equal to or less than zero accordingly
 * as the object pointed to by s1 is greater than, equal to or less than the
 * object pointed to by s2.
 */

int memcmp(const void *s1, const void *s2, register size_t count)
{
    register const char *str1;
    register const char *str2;

    str1 = s1;
    str2 = s2;

    while( (*str1++ == *str2++) && (--count != -1) );
    if( *--str1 != *--str2 )
	count--;
    return((count != -1) ? (char)(*str1 - *str2) : 0);
}
