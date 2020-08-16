/*
 *  feof.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdio.h>

/*----------------------------------- feof() --------------------------------*/

/*
 * feof test the end-of-file indicator fro the stream pointed to by fp.
 * feof() return non-zero if and only if the end-of-file indicator is set
 * for stream pointed to by fp.
 */

int (feof)(FILE *fp)
{
    return(feof(fp));
}

