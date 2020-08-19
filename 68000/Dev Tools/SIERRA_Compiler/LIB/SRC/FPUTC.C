/*
 *  fputc.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdio.h>

/*--------------------------------- fputc() ---------------------------------*/

/*
 * fputc writes the character specified by c  (converted to an unsigned
 * character) to the output stream pointed to by fp, at the position
 * indicated by the associated file position indicator for the stream (if
 * defined), and advances the indicator appropriately.	If the file cannot
 * support positioning requests, or if the stream was opened with append
 * mode, the character is appended to the output stream.  fputc() returns
 * the character written.  If a write error occurs, the error indicator for
 * the stream is set and fputc() returns EOF.
 */

int fputc(int c, FILE *fp)
{
    return(putc(c, fp));
}
