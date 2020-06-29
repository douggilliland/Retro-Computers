#

/*
 *
 * printf([fd,] fmt[, arg, arg, ... ])
 *
 *      Miniature version of standard library printf,
 *      calls putchar to do the actual writing.
 *
 *      Supports:
 *              %b      unsigned binary
 *              %c      character
 *              %d      signed decimal
 *              %h      unsigned hexadecimal (%x)
 *              %o      unsigned octal
 *              %s      string
 *              %u      unsigned decimal
 *              %x      unsigned hexadecimal (%h)
 *
 *      If putchar.c is #include'd, it should precede
 *      this file, so the macro will be invoked.
 *
 *      Calls: putchar
 *
 *      References: fout
 */

#define F_Z     01      /* leading zeroes */
#define F_S     02      /* signed */
#define F_L     04      /* left-justify */

printf(args) {
        extern fout;
        register *ap, c;
        register char *s, *af;
        int p, f, sfout;

        ap = &args;
        f = *ap;
        sfout = -1;
        if ((unsigned) f < 20) {
                ++ap;
                if (f != fout) {
                        flush();
                        sfout = fout;
                        fout = f;
                }
        }
        af = (char *) *ap++;
        for (;;) {
                while ((c = *af++) != '%') {
                        if (!c)
                                break;
                        putchar(c);
                }
                if (c == '\0')
                        break;
                c = *af++;
                p = 0;
                f = 0;
                if (c == '-') {
                        f |= F_L;
                        c = *af++;
                }
                if (c == 'l') {
                        f |= F_Z;
                        c = *af++;
                }
                while ('0' <= c && c <= '9') {
                        p = p * 10 + c - '0';
                        c = *af++;
                }
                if (c == '.') {
                        c = *af++;
                        while ('0' <= c && c <= '9')
                                c = *af++;
                }
                if (c == '\0')
                        break;
                switch (c) {
                case 'd':
                        f |= F_S;
                case 'u':
                        c = 10;
                        goto num;
                case 'o':
                        c = 8;
                        goto num;
                case 'b':
                        c = 2;
                        goto num;
                case 'h':
                case 'x':
                        c = 16;
            num:        _num(ap++, c, p, f);
                        if (f & F_Z)
                          ap++;
                        continue;
                case 'c':
                        c = *ap++ & 0177;
                        putchar(c);
                        --p;
                        while (--p >= 0)
                                putchar(' ');
                        continue;
                case 's':
                        s = (char *) *ap++;
                        while (*s) {
                                c = *s++ & 0177;
                                putchar(c);
                                if (p && --p <= 0)
                                        break;
                        }
                        while (--p >= 0)
                                putchar(' ');
                        continue;
                }
                putchar(c);
        }
        if (sfout >= 0) {
                flush();
                fout = sfout;
        }
}

static _num(an, ab, ap, af)
int *an;
{
        unsigned b;
        unsigned long n;
        char n2;
        register char *p;
        int neg;
        char buf[36];

        p = &buf[36];
        if (af & F_Z)
          n = *((long *)an);
        else
          n = *an;
        b = ab;
        neg = 0;
        if ((af & F_S) && *an < 0) {
                neg++;
                n = -n;
                --ap;
        }
        *--p = '\0';
        do {
                *--p = "0123456789ABCDEF"[n % b];
                --ap;
        } while (n /= b);
        n2 = ' ';
        if (neg) {
                *--p = '-';
                neg = 0;
        }
        if ((af & F_L) == 0)
                while (--ap >= 0)
                        *--p = n2;
        if (neg)
                *--p = '-';
        while (*p)
                putchar(*p++);
        while (--ap >= 0)
                putchar(n2);
}

#undef F_Z
#undef F_S
#undef F_L

#include "putchar.c"

