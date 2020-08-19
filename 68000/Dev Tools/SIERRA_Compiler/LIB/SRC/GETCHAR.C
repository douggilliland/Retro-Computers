/*
 *  getchar.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdio.h>

/*------------------------------ getchar() ----------------------------------*/

/*
 * getchar is equivalent to getc() with the argument stdin.  getchar()
 * returns the next character from the input stream pointed to by stdin.
 * If the stream is at end-of_file, the end-of-file indicator for the stream
 * is set and EOF is returned.	If a read error occurs, the error indicator
 * for the stream is set and EOF is again returned.
 */

int (getchar)(void)
{
    return(getc(stdin));
}
