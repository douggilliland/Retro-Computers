/*
 *  fillbuf.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdio.h>

#ifndef FILE_IO
#ifndef MULTI_CHANNEL

/*=============================== DIRECT_IO =================================*/

int getchx(void);

extern int _raw_mode;

static void getbuf(FILE *);
static int readx(int, void *, unsigned int);

/*------------------------------- _fillbuf() --------------------------------*/

/*
 * _fillbuf, as defined below, is for simple character-by-character I/O.
 * _fillbuf() is used by the getc() macro.  _fillbuf() allows functions like
 * printf() which make use of the _iob structure array to operate in a simple
 * environment.	 Note, that since a static array is used for buffering, it
 * will not support more than a single input stream.
 */

#define B_BUFSIZE   128

int _fillbuf(register FILE *fp)
{
    /* If there was a previous call to ungetc(), clear the flag, */
    /* reset ->cnt and return the ungotten character.		 */

    if( fp->flags & _UNGCH ) {
	fp->flags &= ~_UNGCH;
	fp->cnt = fp->save_cnt;
	return(fp->ungch);
    }

    if( (fp->flags) & (_IOEOF | _IOSTRING | _IOERR) ) {
	fp->cnt = 0;
	return(EOF);
    }

    if( fp->base == NULL )
	getbuf(fp);

    fp->ptr = fp->base;
    fp->cnt = readx(0, fp->base, B_BUFSIZE);

    if( fp->cnt-- <= 0 ) {
	if( fp->cnt == -1 )
	    fp->flags |= _IOEOF;
	else
	    fp->flags |= _IOERR;
	fp->cnt = 0;
	return(EOF);
    }
    return( (unsigned char)*fp->ptr++ );
}

/*-------------------------------- getbuf() ---------------------------------*/

static void getbuf(register FILE *fp)
{
    static char local_buf[B_BUFSIZE];

    fp->base = local_buf;
}

/*--------------------------------- readx() ---------------------------------*/

/*
 * readx, as defined below, is a simple terminal I/O read function.  readx()
 * fills the specified buffer with characters until count character are read,
 * or until a carriage return '\r' is entered.	The return value is the
 * number of characters written. 
 *
 * In COOKED mode (default) input processing is performed for:
 *
 * KILL-LINE		control-x, 0x18
 * ERASE		'\b', backspace, control-h, 0x8
 * CARRIAGE-RETURN	'\r', 0xd
 * CONTROL-D		control-d, 0x4
 * CONTROL-C		control-c, 0x3
 *
 * RAW mode can be set by ioctl().
 */

static int readx(int fd, void *buf, register unsigned int count)
{
    register int c;
    register char *ptr;
    static short end_of_file;

    if( end_of_file ) {
	end_of_file = 0;
	return(0);
    }

    for( ptr = buf; count > 0; ) {
	c = getchx();
	if( !_raw_mode ) {
	    c &= 0x7f;
	    switch( c ) {
	    case '\r':			    /* carriage-return */
		putchx(c);
		*ptr++ = '\n';
		putchx('\n');
		goto end_line;
	    case 0x4:			    /* control-d */
		putchx('^');
		putchx('D');
		end_of_file = (ptr != buf);
		goto end_line;
	    case 0x3:			    /* control-c */
		exit(1);
	    case '\b':			    /* erase */
		if( ptr > buf ) {
		    putchx('\b');
		    putchx(' ');
		    putchx('\b');
		    *--ptr = '\0';
		    count++;
		}
		break;
	    case 0x18:			    /* kill, control-x */
		while( ptr > buf ) {
		    putchx('\b');
		    putchx(' ');
		    putchx('\b');
		    *--ptr = '\0';
		    count++;
		}
		break;
	    default:
		putchx(c);
		*ptr++ = c;
		count--;
		break;
	    }
	}
	else
	    *ptr++ = c;
    }
end_line:
    return(ptr - (char *)buf);
}

#else

/*======================= DIRECT_IO (MULTI_CHANNEL) =========================*/

int getchx(void);
int getchx1(void);
int getchx2(void);
void putchx1(long);
void putchx2(long);

extern int _raw_mode;

static void getbuf(FILE *);
static int readx(int, void *, unsigned int);

/*------------------------------- _fillbuf() --------------------------------*/

/*
 * _fillbuf, as defined below, is for simple character-by-character I/O.
 * _fillbuf() is used by the getc() macro.  _fillbuf() allows functions like
 * printf() which make use of the _iob structure array to operate in a simple
 * environment.	 Note, that since a static array is used for buffering, it
 * will not support more than a single input stream.
 */

#define B_BUFSIZE   128

int _fillbuf(register FILE *fp)
{
    /* If there was a previous call to ungetc(), clear the flag, */
    /* reset ->cnt and return the ungotten character.		 */

    if( fp->flags & _UNGCH ) {
	fp->flags &= ~_UNGCH;
	fp->cnt = fp->save_cnt;
	return(fp->ungch);
    }

    if( (fp->flags) & (_IOEOF | _IOSTRING | _IOERR) ) {
	fp->cnt = 0;
	return(EOF);
    }

    if( fp->base == NULL )
	getbuf(fp);

    fp->ptr = fp->base;
    fp->cnt = readx(fp->fd, fp->base, B_BUFSIZE);

    if( fp->cnt-- <= 0 ) {
	if( fp->cnt == -1 )
	    fp->flags |= _IOEOF;
	else
	    fp->flags |= _IOERR;
	fp->cnt = 0;
	return(EOF);
    }
    return( (unsigned char)*fp->ptr++ );
}

/*-------------------------------- getbuf() ---------------------------------*/

static void getbuf(register FILE *fp)
{
    static char local_buf[B_BUFSIZE];
    static char local_buf1[B_BUFSIZE];
    static char local_buf2[B_BUFSIZE];

    switch( fp->fd ) {
    case 3:
	fp->base = local_buf1;
	break;
    case 5:
	fp->base = local_buf2;
	break;
    case 0:
    default:
	fp->base = local_buf;
    }
}

/*--------------------------------- readx() ---------------------------------*/

/*
 * readx, as defined below, is a simple terminal I/O read function.  readx()
 * fills the specified buffer with characters until count character are read,
 * or until a carriage return '\r' is entered.	The return value is the
 * number of characters written. 
 *
 * In COOKED mode (default) input processing is performed for:
 *
 * KILL-LINE		control-x, 0x18
 * ERASE		'\b', backspace, control-h, 0x8
 * CARRIAGE-RETURN	'\r', 0xd
 * CONTROL-D		control-d, 0x4
 * CONTROL-C		control-c, 0x3
 *
 * RAW mode can be set by ioctl().
 */

static int readx(int fd, void *buf, register unsigned int count)
{
    register int c;
    register char *ptr;
    int (*in)(void);
    void (*out)(int);
    static char end_of_file[FOPEN_MAX];

    switch( fd ) {
    case 3:
	in = getchx1;
	out = putchx1;
	break;
    case 5:
	in = getchx2;
	out = putchx2;
	break;
    case 1:
    case 2:
    default:
	in = getchx;
	out = putchx;
    }

    if( end_of_file[fd] ) {
	end_of_file[fd] = 0;
	return(0);
    }

    for( ptr = buf; count > 0; ) {
	c = in();
	if( !_raw_mode ) {
	    c &= 0x7f;
	    switch( c ) {
	    case '\r':			    /* carriage-return */
		out(c);
		*ptr++ = '\n';
		out('\n');
		goto end_line;
	    case 0x4:			    /* control-d */
		out('^');
		out('D');
		end_of_file[fd] = (ptr != buf);
		goto end_line;
	    case 0x3:			    /* control-c */
		exit(1);
	    case '\b':			    /* erase */
		if( ptr > buf ) {
		    out('\b');
		    out(' ');
		    out('\b');
		    *--ptr = '\0';
		    count++;
		}
		break;
	    case 0x18:			    /* kill, control-x */
		while( ptr > buf ) {
		    out('\b');
		    out(' ');
		    out('\b');
		    *--ptr = '\0';
		    count++;
		}
		break;
	    default:
		out(c);
		*ptr++ = c;
		count--;
		break;
	    }
	}
	else
	    *ptr++ = c;
    }
end_line:
    return(ptr - (char *)buf);
}

#endif
#else

/*================================ FILE_IO ==================================*/

#include <stdlib.h>

static void getbuf(FILE *);

/*------------------------------ _fillbuf() ---------------------------------*/

/*
 * _fillbuf is a utility function used by the buffered read functions in
 * the standard C library via reads through macro getc().  _fillbuf() is
 * called to replenish the buffer belonging to a read or read/write stream,
 * pointed to by fp, whenever the buffer is empty  It is the responsibility
 * of the user to ensure that the buffer is empty, since its previous
 * contents will be overwritten by _fillbuf().	If the stream is completely
 * unbuffered (no buffering -- even character-at-a-time), then _fillbuf()
 * attempts to allocate a buffer for the stream; if this fails, the stream is
 * assigned a one-character buffer in the _iob struct and input is designated
 * unbuffered.	If an I/O error exists on the stream, an I/O error occurs
 * while replenishing the buffer, or _fillbuf() detects an invalid stream;
 * EOF is returned.  If successful, the first character read is returned and
 * the buffer pointer is set to point at the next character.
 */

int _fillbuf(register FILE *fp)
{
    /* If there was a previous call to ungetc(), clear the flag, */
    /* reset ->cnt and return the ungotten character.		 */

    if( fp->flags & _UNGCH ) {
	fp->flags &= ~_UNGCH;
	fp->cnt = fp->save_cnt;
	return(fp->ungch);
    }

    if( fp->flags & _IORW )
	fp->flags |= _IOREAD;

    if( (fp->flags & (_IOEOF | _IOERR | _IOSTRING)) ||
    !(fp->flags & _IOREAD) ) {
	fp->cnt = 0;
	return(EOF);
    }

    /* if writing to stdin and stdout or stderr is line buffered, flush */

    if( fp == stdin ) {
	if( stdout->flags & _IOLBF )
	    fflush(stdout);
	if( stderr->flags & _IOLBF )
	    fflush(stderr);
    }

    /* if no buffer has been assigned, call getbuf() to get a buffer */

    if( fp->base == NULL )
	getbuf(fp);

    fp->ptr = fp->base;
    fp->cnt = read(fp->fd, fp->base, (fp->flags & _IONBF) ? 1: fp->bufsize);
    if( fp->cnt-- <= 0 ) {
	if( fp->cnt == -1 ) {
	    fp->flags |= _IOEOF;
	    if( fp->flags & _IORW )
		fp->flags &= ~_IOREAD;
	}
	else
	    fp->flags |= _IOERR;
	fp->cnt = 0;
	return(EOF);
    }
    return( (unsigned char)*fp->ptr++ );
}

/*------------------------------- getbuf() ----------------------------------*/

static void getbuf(FILE *fp)
{
    if( (fp->flags & _IONBF) || 
    (fp->base = malloc(BUFSIZ * sizeof(char))) == NULL ) {

	/* no buffering or malloc() failed */

	fp->base = &(fp->ungch);
	if( !(fp->flags & _IONBF) ) {
	    fp->flags &= ~(_IOFBF | _IOLBF);
	    fp->flags |= _IONBF;
	}
    }
    else {
	if( !(fp->flags & _IOLBF) )
	    fp->flags |= _IOFBF;
	fp->flags |= _IOMYBUF;
	fp->bufsize = BUFSIZ;
    }
}
#endif
