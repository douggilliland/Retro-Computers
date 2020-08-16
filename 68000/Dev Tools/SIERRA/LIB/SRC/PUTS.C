/*
 *  puts.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdio.h>

/*--------------------------------- puts() ----------------------------------*/

/*
 * puts writes the specified string to stdout followed by a newline
 */

int puts(register const char *str)
{
    while( *str )
	putchar(*str++);
    return(putchar('\n'));
}
