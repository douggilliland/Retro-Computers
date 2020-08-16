/*
 *  putchar.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdio.h>

/*------------------------------- putchar() ---------------------------------*/

/*
 * putchar wtites the character specified by c (converted to an unsigned
 * char) to the output stream pointed to by stdout, at the position
 * indicated by the associated file position indicator for stdout (if
 * defined), and advances the indicator appropriately.
 */

int (putchar)(int c)
{
    return(putc(c, stdout));
}
