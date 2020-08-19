/*
 *  ferror.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdio.h>

/*---------------------------------- ferror() ------------------------------*/

/*
 * ferror tests the error indicator for the stream pointed to by fp.
 * ferror() returns non-zero if and only if the error indicator is set for
 * the stream pointed to by fp.
 */

int (ferror)(FILE *fp)
{
    return(ferror(fp));
}

