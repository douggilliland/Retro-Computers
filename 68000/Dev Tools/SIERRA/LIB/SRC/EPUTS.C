/*
 *  eputs.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdio.h>

/*--------------------------------- _eputs() ---------------------------------*/

/*
 * _eputs writes the string pointed to by stderr.  The terminating null
 * character is not written.  _eputs() returns EOF if a write error occurs;
 * otherwise it returns a non-negative value.
 */ 

int _eputs(const char *string)
{
    return(fputs(string, stderr));
}
