/*
 *  tmpfile.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdio.h>

/*------------------------------- tmpfile() ---------------------------------*/

/*
 * tmpfile creates a tempory binary file that will automatically be removed
 * when it is closed or when the program terminates.  The file is opened for
 * update with "wb+" mode.  tmpfile() returns a pointer to the stream
 * associated with the created file.  A null pointer is returned if the
 * file cannot be created.
 *
 * The function tmpnam() used to create the temporary filename is not
 * supplied with Sierra C.
 */

FILE *tmpfile(void)
{
    FILE *fp;
    char *ptr;

    if( ptr = tmpnam(NULL) ) {
	fp = fopen(ptr, "w+");
	if( fp )
	    fp->flags |= _TMPFILE;
    }
    return(fp);
}
