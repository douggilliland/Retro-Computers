/*
 *  ungetc.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdio.h>

void _getbuf(FILE *);

/*-------------------------------- ungetc() ---------------------------------*/

/*
 * ungetc pushes the character specified by c (converted to an unsigned
 * character) back onto the input stream pointed to by fp.  The pushed-back
 * character will be returned by subsequent reads on the stream in the
 * reverse order of their pushing.  A successful intervening call (with the
 * stream pointed to by fp) to a file positioning function (fseek(),
 * fsetpos() or rewind()) discards any pushed-back characters from the
 * stream.  The external storage corresponding to the stream is unchanged.
 *
 * One character of pushback is guaranteed.  If ungetc() is called too many
 * times without a intervening read or file positionaing operation, the
 * operation may fail.	If the value of c equals the macro EOF, the operation
 * fails and the input stream is unchanged.
 *
 * A successful call to ungetc() clears the end-of-file indicator for the
 * stream.  The value of the file position indicator for the stream after
 * reading or discarding all pushed-back characters shall be the same as it
 * was before the characters were pushed back.	The file position indicator
 * is decremented by each successful call to ungetc(); if the value was zero
 * before a call, it is indeterminate after the call.
 *
 * ungetc() returns the character pushed back after conversion, or EOF if
 * the operation fails.
 */

int ungetc(int c, register FILE *fp)
{
    if( (c == EOF) || (fp->flags & _IOWRITE) )
	return(EOF);

    fp->ungch = c;
    fp->save_cnt = fp->cnt;
    fp->cnt = 0;
    fp->flags |= _UNGCH;
    fp->flags &= ~_IOEOF;
    return(c);
}

