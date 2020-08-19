/*
 *  fgetpos.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdio.h>

/*-------------------------------- fgetpos() --------------------------------*/

/*
 * fgetpos stores the current value of the file positioning indicator for
 * the stream pointed to by fp in the object pointed to by position.  The
 * value stored contains unspecified information usable by fsetpos() for
 * repositioning the stream to its position at the time of the call to
 * fgetpos().  If successful, fgetpos() returns zero.  If it failed,
 * fgetpos() returns a non-zero value and stores the value of the macro
 * EBADF (defined in errno.h) in errno.
 */

int fgetpos(FILE *fp, fpos_t *position)
{
    return( ((*position = ftell(fp)) == -1) ? -1 : 0 );
}
