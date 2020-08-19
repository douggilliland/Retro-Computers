/*
 *  fopen.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdio.h>
#include <io.h>

/*-------------------------------- fopen() ----------------------------------*/

/*
 * fopen opens the file whose name is the string pointed to by filename,
 * and associates a stream with it.  The argument mode_string points to
 * one of the following strings:
 *
 * r	open file for reading
 * w	truncate to zero length or create file for writing
 * a	append - open or create file for writing at end-of-file
 * r+	open file for update (reading and writing)
 * w+	truncate to zero length or create file for update
 * a+	append - open or create file for update, writing at end-of-file
 *
 * b or t can be added to any of the above six strings to specify that the
 * file be opened in binary or text mode respectively. Note, r+b and rb+
 * (for example) are both accepted and have the same meaning.
 *
 * Opening a file with read mode ('r' as the first character) fails if the
 * file does not exist or cannot be read.  Opening a file with append mode
 * ('a' as the first character) causes all subsequent writes to the file to
 * be forced to the then current end-of-file, regardless of intervening
 * calls to fseek().
 *
 * When a file is opened with update mode ('+' as the second or third
 * character), both input and output may be performed on the associated
 * stream.  However, output may not be directly followed by input without an
 * intervening call call to fflush() or to a file positioning function
 * (fseek(), fsetpos() or rewind()), and input may not be directly followed
 * by output without an intervening call to a file positioning function,
 * unless the input operation encounters and end-of-file.  The error and
 * end-of-file indicators are creared when a stream is opened.	fopen()
 * returns a pointer to the object controlling the stream.  If the open
 * operation fails, fopen() returns a null pointer.
 *
 * Usage:
 *
 *	FILE *fopen(const char *filename, const char mode_string)
 *
 *	filename ----- the name of the file to be opened
 *	mode_string -- the 1, 2 or 3 character string describing the
 *		       attributes of the file being opened
 *	return ------- a pointer to the stream associated with the open
 *		       file is returned.  On error a null pointer is returned.
 *
 * The function open() called by fopen() is not supplied by Sierra C.
 * The values of the MACRO flags passed to open() are defined in the
 * standard include header io.h; those values may have to be redefined
 * to operate correctly with the selected open() routine.  The MACRO
 * FOPEN_MAX determines the maximum number of FILE structures and it is
 * defined in the standard include header stdio.h.
 */

FILE *fopen(const char *filename, register const char *mode_string)
{
    register FILE *fp;
    register int fd;
    register int fp_flags;
    register int mode;
    register int mode_char;

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
	    
    /* find a free FILE structure for stream */

    for( fp = _iob; fp < (_iob + FOPEN_MAX); fp++ )
	if( !(fp->flags & (_IOREAD | _IOWRITE | _IORW)) )
	    break;

    /* no free FILE structures */

    if( fp >= (_iob + FOPEN_MAX) )
	return(NULL);

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
