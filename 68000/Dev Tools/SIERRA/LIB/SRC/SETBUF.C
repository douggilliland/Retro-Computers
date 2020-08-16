/*
 *  setbuf.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdio.h>

/*-------------------------------- setbuf() ---------------------------------*/

/*
 * setbuf functions the same as setvbuf(fp, buf, _IOFBF, BUFSIZ) if buf
 * is not a null pointer, and the same as setvbuf(fp, NULL, _IONBF, 0) if
 * buf is a null pointer.
 *
 * Usage:
 *
 *	void setbuf(FILE *fp, char *buf)
 *
 *	pf --- pointer to the FILE structure to which buffering
 *	       is to be assigned
 *	buf -- pointer to the buffer to be assigned to FILE structure
 *	       assocciated with fp
 */

void setbuf(FILE *fp, char *buf)
{
    if( buf )
	(void)setvbuf(fp, buf, _IOFBF, BUFSIZ);
    else
	(void)setvbuf(fp, NULL, _IONBF, 0);
}
