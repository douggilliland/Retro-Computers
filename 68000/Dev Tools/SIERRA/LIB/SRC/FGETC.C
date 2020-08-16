/*
 *  fgetc.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdio.h>

/*-------------------------------- fgetc() ----------------------------------*/

/*
 * fgetc obtains the next character (if present) as an unsigned character
 * converted to an int, from the input stream pointed to by fp, and advances
 * the associated file position indicator for the stream (if defined).
 * fgetc() returns the next character from the input stream pointed to by fp.
 * If the stream is at end-of-file, the end-of-file indicator for the stream
 * is set and and fgetc() returns EOF.	If a read error occurs, the error
 * indicator for the stream is set and fgetc() returns EOF.  Note, an
 * end-of-file and a read error can be differentiated by the use of the
 * feof() and ferror() functions.
 */

int fgetc(FILE *fp)
{
    return(getc(fp));
}
