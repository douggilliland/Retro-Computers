/*
* This file contains all external symbol definitions, the basic i/o
* routines, and the main calling loop.
*/

#include "putchar.c"
#include "il.h"
#include "vil.h"

#define ERROR (-1)
#define IBFSIZ 513
#define F_Z     01      /* leading zeroes */
#define F_S     02      /* signed */
#define F_L     04      /* left-justify */

int fd;                        /* file descriptor */
int eofflg;                    /* end of file flag */
int nxtlab;                    /* local label generator */
int revcon;                    /* reverse conditional flag */
char extra;                    /* loose character box */
char extflg;                   /* extra character flag */
char flabtyp;                  /* temp for label type */
char sawcnd;                   /* saw a conditional op flag */
char *bufptr;                  /* basic i/o buffer pointer */
char *bufend;                  /* i/o buffer end marker */
int stklev;                    /* stack level counter */
int stksiz;                    /* current stack size counter */
int condit;                    /* type of conditional for compares */
int flabnum;                   /* temp for label number */
char ccok;                     /* cc status for code generation */
char brntyp;                   /* flag for branch type */
char unscom;                   /* flag to denote unsigned compare */
char dvalid;                   /* flag to denote D reg contents still valid */
int lstlev;                    /* last expression entry used */
int explev;                    /* current expression level */
int locop1;                    /* location of operand 1 */
int locop2;                    /* location of operand 2 */
int incloc;                    /* location of auto inc variable */
int localv;                    /* local label generation cell */
int *orp;                      /* stack pointer for OR operators */
int *andp;                     /* stack pointer for AND operators */
int *cndp;                     /* stack pointer for CND operators */
int andstk[NUMLOG];            /* stack for AND operators */
int orstk[NUMLOG];             /* stack for OR operators */
int cndstk[NUMLOG];            /* stack for CND operators */
int curopr;                    /* current operator */
int curtyp;                    /* current result type */
struct express *dcont;         /* D register contents */
struct addreg *xcont;          /* X register contents */
struct dstruct dloc;           /* origin of D register value */
char ibuf[IBFSIZ];             /* input buffer */
char namebuf[1024];              /* temp buffer for building names */
struct express exptbl[MAXEXP]; /* expression matrix */
struct addreg adregs[NUMADR];  /* address register array */
int retlab;                    /* return function label */

/*
* Branch arrays for conditionals.
*/

char *bar1[6] = {"beq","bne","blt","bgt","ble","bge"};
char *bar2[6] = {"bne","beq","bge","ble","bgt","blt"};
char *bar3[6] = {"beq","bne","blo","bhi","bls","bhs"};
char *bar4[6] = {"bne","beq","bhs","bls","bhi","blo"};

/* Main pass2 loop */

main(argc, argv)
int argc;
char *argv[];
{
  if (argc==1)
    initial("cc_temp");
  else
    initial(*++argv);
  loop();
  flush();
}

/* Do pass2 initialization */

initial(nm)
char *nm;
{
  char *fname;
  char *oname;

  fname = nm;
  if ((fd = open(fname, 0)) == ERROR) {
    perror("Can't open intermediate file: pass2 aborted.\n");
    abort();
  }
  eofflg = 0;
  bufptr = &ibuf[IBFSIZ];
  bufend = bufptr;
  extra = 0;
  extflg = 0;
  fout = 1;
  nxtlab = 10000;
}

/* Get next character from I file. */

nextc() {
  int count;

  if (bufptr == bufend) {
    if ((count = read(fd,&ibuf[1],IBFSIZ-1)) < 0) {
      perror("Error reading intermediate file - pass 2 aborted!\n");
      exit(255);
    }
    bufend = &ibuf[1] + count;
    bufptr = &ibuf[1];
    if (count == 0)
      return(EOF);
  }
  return((*bufptr++) & 0xFF);
}

/* Get next word from I file. */

nextw() {
  int char1, char2;

  if ((char1 = nextc()) == EOF)
    badfile();
  if ((char2 = nextc()) == EOF)
    badfile();
  return((char1 << 8) | char2);
}

/* Get string from I file. */

char *nexts(string)
char *string;
{
  char chr;
  register char *pointer;

  pointer = string;
  while (chr = nextc()) {
    if (chr == EOF)
      badfile();
    *pointer++ = chr;
  }
  *pointer = 0;
  return(string);
}

/* Return character to input buffer. */

rtrnc(ch)
int ch;
{
  *--bufptr = ch;
}

/* Get next expression byte. */

expb() {
  int tok;

  if ((tok = nextc()) == EOF)
    badfile();
  return(tok);
}

/* Get next expression word. */

expw() {
  return(nextw());
}

/* Report bad I file and abort. */

badfile() {

  perror("Bad intermediate file - pass2 aborted.\n");
  abort();
}

/* Print error message to std error. */

perror(msg)
char *msg;
{
  outcode(2, msg);
}

/* Output code to assembler file - essentially a "printf". */

outcode(args) {
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
    if (c == '0') {
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
    case 'l':
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
      num:  _num(*ap++, c, p, f);
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

static _num(an, ab, ap, af) {
  register unsigned n, b;
  register char *p;
  int neg;
  char buf[17];

  p = &buf[17];
  n = an;
  b = ab;
  neg = 0;
  if ((af & F_S) && an < 0) {
    neg++;
    n = -n;
    --ap;
  }
  *--p = '\0';
  do {
    *--p = "0123456789ABCDEF"[n % b];
    --ap;
  } while (n /= b);
  n = ' ';
  if ((af & (F_Z | F_L)) == F_Z)
    n = '0';
  else if (neg) {
    *--p = '-';
    neg = 0;
  }
  if ((af & F_L) == 0)
    while (--ap >= 0)
      *--p = n;
  if (neg)
    *--p = '-';
  while (*p)
    putchar(*p++);
  while (--ap >= 0)
    putchar(n);
}

