/*
 *  freopen.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdio.h>
#include <io.h>

/*------------------------------- freopen() ---------------------------------*/

/*
 * freopen opens the file whose name is the string pointed to by filename
 * and associates the stream pointed to by fp with it.	The mode_string
 * argument is used just as in the fopen() function.  freopen() first
 * attempts to close any file that is associated with the specified stream.
 * Failure to close the file successfully is ignored.  The error and the
 * end-of-file indicators for the stream are cleared.  freopen() returns
 * a the value of the stream.  If the open operation fails, a null pointer
 * is returned.
 *
 * Usage:
 *
 *	FILE *freopen(const char *filename, const char mode_string, FILE *fp)
 *
 *	filename ----- the name of the file to be opened
 *	mode_string -- the 1, 2 or 3 character string describing the
 *		       attributes of the file being opened
 *	fp ----------- a pointer to the stream to be reopened	    
 *	return ------- a pointer to the stream associated with the open
 *		       file is returned.  On error a null pointer is returned.
 */

FILE *freopen(const char *filename, register const char *mode_string,
register FILE *fp)
{
    register int fd;
    register int fp_flags;
    register int mode;
    register int mode_char;

    fclose(fp);

    /* parse mode argument, return null pointer if invalid */

    mode = 0;
    fp_flags = 0;
    mode_char = *mode_string++;
 
    /* illegal mode character */

    if( (mode_char != 'r') && (mode_char != 'w') && (mode_char != 'a') )
	return(NULL);

    /* set text or binary mode if specified */

    if( *mode_string == 't' ) {
	mode_string++;
	mode |= O_TEXT;
    }
    else if( *mode_string == 'b' ) {
	mode_string++;
	mode |= O_BINARY;
    }

    if( *mode_string ) {
	if( *mode_string++ == '+' ) {
	    if( mode_char == 'a' ) {
		mode |= O_APPEND | O_RDWR | O_CREAT;
		fp_flags |= _IORW | _IOAPPEND | _IOWRITE;
	    }
	    else if( mode_char == 'w' ) {
		mode |= O_TRUNC | O_RDWR | O_CREAT;
		fp_flags |= _IORW | _IOWRITE;
	    }
	    else {
		mode |= O_RDWR;
		fp_flags |= _IORW | _IOREAD;
	    }
	}
	else
	    return(NULL);

	/* set text or binary mode if specified */

	if( *mode_string == 't' ) {
	    mode_string++;
	    mode |= O_TEXT;
	}
	else if( *mode_string == 'b' ) {
	    mode_string++;
	    mode |= O_BINARY;
	}

	/* invalid mode string */

	if( *mode_string )
	    return(NULL);
    }
    else {
	if( mode_char == 'a' ) {
	    mode |= O_APPEND | O_WRONLY | O_CREAT;
	    fp_flags |= _IOWRITE | _IOAPPEND;
	}
	else if( mode_char == 'w' ) {
	    mode |= O_TRUNC | O_WRONLY | O_CREAT;
	    fp_flags |= _IOWRITE;
	}
	else {
	    mode |= O_RDONLY;
	    fp_flags |= _IOREAD;
	}
    }
	    
    /* open (or create) file */

    if( (fd = open(filename, mode, READ_P | WRITE_P)) == -1 )
	return(NULL);

    /* initialize fp */

    fp->cnt = 0;
    fp->base = NULL;
    fp->fd = fd;
    fp->flags = fp_flags;
    return(fp);
}
