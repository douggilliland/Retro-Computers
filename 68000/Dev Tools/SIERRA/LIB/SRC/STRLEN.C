/*
 *  strlen.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <string.h>
#include <stddef.h>

/*------------------------------ strlen() -----------------------------------*

/*
 * strlen is a standard C library function that returns an integer equal to
 * the length (number of characters not including the terminating null) of
 * the string.	A null is returned if the string is empty.
 */

size_t strlen(const char *string)
{
    register char *ptr;

    ptr = (char *)string;
    while( *ptr++ );
    ptr--;
    return(ptr - (char *)string);
}

