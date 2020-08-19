/*
 *  fputs.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdio.h>

/*--------------------------------- fputs() ---------------------------------*/

/*
 * fputs writes the string pointed to by string to the stream pointed to by
 * fp.	The terminating null character is not written.	fputs() returns EOF
 * if a write error occurs; otherwise it returns a non-negative value.
 */ 

int fputs(const char *string, register FILE *fp)
{
    register int c;
    register int error_flag;

    error_flag = 0;
    while( c = *string++ )
	error_flag = putc(c, fp);
    if( error_flag != EOF )
	error_flag = 0;
    return(error_flag);
}
