/*
 *  flushbuf.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdio.h>

#ifndef FILE_IO
#ifndef MULTI_CHANNEL

/*=============================== DIRECT_IO =================================*/

/*------------------------------ _flushbuf() --------------------------------*/

/*
 * _flushbuf, as defined below, is for simple serial I/O.  FILE member _cnt
 * is forced to 0 to guarantee that _flushbuf is called for every characters.
 * _flushbuf() does convert new-line chracters into carriage-return
 * new-line chracter pairs.
 */

int _flushbuf(unsigned char c, register FILE *fp)
{
    fp->cnt = 0;    /* force _flushbuf() to be called for every character */
    if( c == '\n' )
	putchx('\r');
    putchx(c);
    return(c);
}

#else

/*======================= DIRECT_IO (MULTI_CHANNEL) =========================*/

void putchx1(long);
void putchx2(long);

/*------------------------------ _flushbuf() --------------------------------*/

/*
 * _flushbuf, as defined below, is for simple serial I/O.  FILE member _cnt
 * is forced to 0 to guarantee that _flushbuf is called for every characters.
 * _flushbuf() does convert new-line chracters into carriage-return
 * new-line chracter pairs.
 */

int _flushbuf(unsigned char c, register FILE *fp)
{
    void (*out)(int);
    
    switch( fp->fd ) {
    case 4:
	out = putchx1;
	break;
    case 6:
	out = putchx2;
	break;
    case 1:
    case 2:
    default:
	out = putchx;
    }

    fp->cnt = 0;    /* force _flushbuf() to be called for every character */
    if( c == '\n' )
	out('\r');
    out(c);
    return(c);
}

/*------------------------------- _init_io() --------------------------------*/

/*
 * _init_io assigns file descriptor values (fp->fd) to the default input
 * and output streams
 */

void _init_io(void)
{
    stdin->fd = 0;
    stdout->fd = 1;
    stderr->fd = 2;
    stdin1->fd = 3;
    stdout1->fd = 4;
    stdin2->fd = 5;
    stdout2->fd = 6;
}

#endif
#else

/*================================ FILE_IO ==================================*/

#include <stdlib.h>

/*------------------------------ _flushbuf() --------------------------------*/

/*
 * _flushbuf is a utility function used by the buffered write functions in
 * the standard C library via writes through macro putc().  _flushbuf()
 * writes the contents of the buffer associated with the stream pointed to
 * by fp to the associated output file and writes the character c to the
 * first position of the newly-emptied buffer.	If the pointed to stream
 * has not yet been assigned any buffering, _flushbuf() attempts to allocate
 * buffer space by calling malloc().  If malloc() fails, output on the stream
 * is unbuffered.  If an I/O error exists on the stream, an I/O error occurs
 * while flushing the buffer, or _flushbuf() detects an invalid stream, EOF
 * is returned.	 If successful, the character c is returned.
 */   

int _flushbuf(unsigned char c, register FILE *fp)
{
    register int count_to_write;
    register int count_written;
    unsigned char ch;

    /* if this is a read/write stream, set the write flag */

    if( fp->flags & _IORW ) {
	fp->flags |= _IOWRITE;
	fp->flags &= ~(_IOREAD | _IOEOF);
    }

    if( (fp->flags & (_IOERR | _IOSTRING)) || !(fp->flags & _IOWRITE) )
	return(EOF);

    /* if stream was opened with "a" mode, all writes occur at end-of-file */

    if( (fp->flags & _IOAPPEND) && (lseek(fp->fd, 0L, SEEK_END) == -1) )
	return(EOF);

buf_select:	    

    /* unbuffered I/O  ---  _IONBF */

    if( fp->flags & _IONBF ) {
	ch = c;
	fp->cnt = 0;			    /* force flush everytime */
	count_to_write = 1;
	count_written = write(fp->fd, &ch, 1);
    }

    /* buffer has already been assigned */

    else if( fp->base ) {

	/* line buffered  ---  _IOLBF */

	if( fp->flags & _IOLBF) {
	    *fp->ptr++ = c;
	    if( (c == '\n') || ((fp->ptr - fp->base) >= fp->bufsize) ) {
		count_to_write = fp->ptr - fp->base;
		count_written = write(fp->fd, fp->base, count_to_write);
		fp->ptr = fp->base;
	    }
	    else {
		count_to_write = 0;
		count_written = 0;
	    }
	    fp->cnt = 0;		    /* force flush everytime */
	}

	/* full buffering  --- _IOFBF */

	else {
	    if( (count_to_write = fp->ptr - fp->base) > 0 )
		count_written = write(fp->fd, fp->base, count_to_write);
	    else {
		count_written = 0;
		count_to_write = 0;
	    }
	    fp->cnt = fp->bufsize - 1;
	    fp->ptr = fp->base;
	    *fp->ptr++ = c;
	}
    }

    /* buffering has not been assigned */

    else {
	if( (fp->base = malloc(BUFSIZ)) == NULL ) {

	    /* malloc() failed, use unbuffered I/O */

	    fp->flags &= ~(_IOFBF | _IOLBF);
	    fp->flags |= _IONBF;
	}
	else {
	    fp->bufsize = BUFSIZ;	    /* size of allocated buffer	    */
	    fp->ptr = fp->base;
	    fp->flags |= _IOMYBUF;	    /* flag close() to free buffer  */
	    if( !(fp->flags & _IOLBF) )	/* if line buffering not set,	*/
		fp->flags |= _IOFBF;	    /* then set full buffer flag    */
	}
	goto buf_select;		    /* try again to write character */
    }

    if( count_written != count_to_write ) {
	fp->flags |= _IOERR;
	fp->cnt = 0;
	return(EOF);
    }
    return(c);
}
#endif
