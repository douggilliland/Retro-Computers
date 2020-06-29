/*
 *      V2.09 80/08/05 16:19    (C) Copyright MCMLXXIX tgi
 *
 * getchar(), ungetchar(char), peekchar()
 *
 *      Getchar returns the next character from the input
 *      stream from file descriptor *fin* (default is 0).
 *      If a read error or end of file is read
 *      EOF is returned.  All characters are
 *      returned without sign extension, so
 *      EOF is a distinct value.
 *
 *      Ungetchar pushes back the argument character.
 *      Except for use of peekchar(),
 *      enough space for one character pushback is
 *      guaranteed, however, depending on the current
 *      buffer situation, more may be pushed.
 *      Ungetchar will return EOF if the pushback was
 *      unsuccessful.
 *
 *      Peekchar returns the next character from the
 *      input stream, without removing it from the
 *      queue.  This allows "peeking" at the next
 *      character without grabbing it.
 *
 *      The input is managed via a one-block (512 byte)
 *      buffer, and read system calls are issued as necessary.
 *
 *      If FLUSH is #define'd, a flush() will be issued before
 *      every read() call.
 *
 *      Additionally, getchar() and ungetchar() MACROS
 *      are defined to further aid efficiency.
 *
 *      Calls: read
 */

#ifndef EOF
#define EOF     -1
#endif

int     fin     = 0;
int     _ibytes = 0;
char    _ibuf[512];
char    *_ipos  = _ibuf;
int     _ipeek;

_filbuf() {
        flush();
        _ipos = _ibuf;
        if ((_ibytes = read(fin, _ibuf, sizeof _ibuf)) <= 0)
                return(EOF);
        --_ibytes;
        return(*_ipos++ & 0377);
}

getchar() {
#define getchar() (--_ibytes>=0?*_ipos++&0377:_filbuf())
        return(getchar());
}

ungetchar(c) {
#define ungetchar(x) (_ipos>_ibuf?(_ibytes++,((*--_ipos=(x))&0377)):EOF)
        return(ungetchar(c));
}

peekchar() {
#define peekchar() (_ibytes>0?*_ipos&0377:((_ipeek=_filbuf())==EOF?EOF:(_ibytes++,(*--_ipos=_ipeek)&0377)))
        return(peekchar());
}
