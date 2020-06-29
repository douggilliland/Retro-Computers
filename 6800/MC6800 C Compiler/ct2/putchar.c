#

/*
 *      V1.24 80/08/05 16:25    (C) Copyright MCMLXXIX tgi
 *
 * putchar(char), flush()
 *
 *      Putchar places the argument character onto the output
 *      stream from file descriptor *fout* (default is 1).
 *      If a write error occurs, ERROR is returned.
 *      The argument character is returned without
 *      sign extension, so ERROR is a distinct value.
 *
 *      Flush writes out any data remaining in the buffer.
 *
 *      _cleanup is called by the library exit routine,
 *      hence a flush is guaranteed on a normal exit.
 *
 *      The output is managed via a one-block (512 byte)
 *      buffer, and write system calls are issued as necessary.
 *
 *      In addition, a putchar(c) MACRO is defined to further
 *      aid efficiency.
 *
 *      Calls: write
 */

#ifndef ERROR
#define ERROR   -1
#endif

int     fout    = 1;
char    _obuf[512];
char    *_opos  = _obuf;

flush() {
        register n;

        n = _opos - _obuf;
        _opos = _obuf;
        if (n > 0)
                if (write(fout, _obuf, n) != n)
                        return(ERROR);
        return(0);
}

_flsbuf(c) {
        if (flush() == ERROR)
                return(ERROR);
        *_opos++ = c;
        return(c);
}

#ifndef CLEANUP
_cleanup() {
        flush();
}
#endif

putchar(c) {
#define putchar(x) (_opos<&_obuf[sizeof _obuf]?((*_opos++=(x))&0377):_flsbuf((x)))
        return(putchar(c));
}
