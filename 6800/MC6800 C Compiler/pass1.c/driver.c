/*
* This file contains all external symbol definitions, the basic i/o
* routines, and the main calling loop.
*/

#include "putchar.c"
#include "il.h"
#include "pass1.h"
#include "nxtchr.h"

#define ERROR (-1)
#define F_Z     01      /* leading zeroes */
#define F_S     02      /* signed */
#define F_L     04      /* left-justify */

/* global variable definitions */

int lstflg;
int pp_if_result;
int errcnt;
int curchar;
int curtok;
int dtype;
char dclass;
char blklev;
char pmlsf;
char fndcf;
char deftyp;
char sukey;
char absflag;
int qopt;
int ptrcnt;
int opcount;
int retlab;
int argoff;
int datareg;
int addrreg;
int nxtarg;
int nxtaut;
int *nxtdim;
int *subsptr;
int label;
char cspace;
char nocomf;
int lastmem;
int strhdr;
int strtag;
int strofs;
int strptr;
int brklab;
int conlab;
int deflab;
int *nxtsw;
int ferrs;
unsigned erofset;
char swflag;
char matlev;
char strnum;
char strcount;
int enumval;
int value;
int hdrlab;
int *cursubs;
int *nxtcon;
char thisop;
int strloc;
char swexp;
char rtexp;
char cmexfl;
int ioff;
int fstr;
struct symtab *iname;
char ibindx;
char iwindx;
char ilindx;
char ilbindx;
char ibstk[16];
short iwstk[16];
long ilstk[16];
struct ilab ilbstk[16];
struct symtab pszsym;
struct classo *op1;
struct classo *op2;
struct classo classes[2];
struct express *nxtmat;
struct symtab *typdfsym;
struct symtab absdec;
struct symtab **tos;
int contab[NUMCON];
struct symtab strings[SSLEN];
struct symtab *nxtsst;
struct symtab *astack[ASLEN];
struct infost *ptinfo;
struct infost stinfo[STNEST];
struct express emat[MATLEN];
int strindx;
int contyp;
long convalu;
char *nxtstr;
int *nxtfrc;
struct express *nxtfor;
int frctab[FORCON];
struct express fortab[FORNUM];
struct symtab *symloc;
struct symtab *funnam;
struct symtab *argptr;
int dimstk[DMLEN];
int swttab[SWLEN];
char strngbf[MAXSTRNG];
struct sstack *strngloc;
struct sstack strstck[NUMSTRNG];
char esctab[] = {'n','\n','t','\t','b','\b','r','\r','f','\f','\0'};
char clstbl[] = {AUTO, STAT, REG, EXTN, TYPDF};
char typtab[] = {INT, CHR, LONG, SHORT, UNS, FLOAT,
                 DUBLE, STRUCT, UNION, ENUM, VOID};

/* token arrays */

struct toktab dchtab[] = {
  '=', EQU,
  '+', FPP,
  '-', FMM,
  '&', LND,
  '|', LOR,
  '<', SHL,
  '>', SHR,
  '\0', 0 };

struct toktab eqctab[] = {
  '<', LEQ,
  '>', GEQ,
  '!', NEQ,
  '\0', 0 };

struct toktab chrtab[] = {
  ';', SMC,
  '{', LCB,
  '}', RCB,
  '[', LSB,
  ']', RSB,
  '(', LPR,
  ')', RPR,
  '+', ADD,
  '-', SUB,
  '*', MUL,
  '/', DIV,
  '%', MOD,
  '=', ASN,
  '>', GRT,
  '<', LES,
  '!', NOT,
  '\'', SQU,
  '"', DQU,
  ',', CMA,
  '.', DOT,
  '&', AND,
  '|', BOR,
  '^', XOR,
  '~', COM,
  '?', QUM,
  '\\', BKS,
  ':', COL,
  '\0', 0 };

/* constants for expressions */

int onecon[] = { (INT<<8)|CONST, 1};

/* Main pass1 loop */

main(argc, argv)
int argc;
char *argv[];
{

  if (prs(argc, argv) != 0) {
    perror("Can't preset!\n");
    exit(255);
  }
  loop();
}

ppcexp() {}

/* Initialize all variables and open files */

initial() {
  extern fout;

  if ((fout = creat("cc_temp", 0x3f)) < 0) {
    perror("Can't create IL file.\n");
    exit(255);
  }
  errcnt = 0;
  if ((fstr = creat("cc_strings", 0x3f)) < 0) {
    perror("Can't create STRING file.\n");
    exit(255);
  }
  close(fstr);
  fstr = open("cc_strings", 2);
  unlink("cc_strings");
  if ((ferrs=open("/source/cc/pass1.c/p1-errors", 0)) < 0) {
    perror("Can't open errors file.\n");
    exit(255);
  }
}

/* Main pass1 loop */

loop() {
  char *name;
  char *nxtfil();


/*lstflg = 1;  */
  while (name = nxtfil()) {
    while (getnch() != FILE_END)
      curchar = 0;
  }
  flush();
}

/* initialize pass1 for new file */

finit() {
  curtok = curchar = strindx = label = 0;
  swflag = matlev = brklab = conlab = 0;
  absflag = retlab = deflab = 0;
  nxtsw = swttab;
  nxtstr = strngbf;
  nxtsst = strings;
  nxtdim = dimstk;
  lseek(fstr, 0L, 0);
}

/* flush strings file */

flstr() {
  int i;

  flush();
  lseek(fstr, 0L, 0);
  while (i=read(fstr, _obuf, 512))
    write(fout, _obuf, i);
}

/* Give final error report */

errrpt() {
  if (errcnt) {
    outil(1, "%u errors detected.\n", errcnt);
    flush();
    exit(255);
  }
}

/* Print error message to std error. */

perror(msg)
char *msg;
{
  outil(2, msg);
}

/* fatal error processor */

error(n)
int n;
{
  outil(2, "Fatal error #%d.\n", n);
  flush();
abort();
  exit(255);
}

/* standard error handler */

rpterr(msg)
char *msg;
{
  outil(1,"%s\n", msg);
}

/* temp error routine */

rptern(num)
int num;
{
  pfilerr(num);
  outil(1, ".\n");
  return(FALSE);
}

/* print file error */

pfilerr(num)
int num;
{
  errcnt++;
  if (!lstflg)
    pfile();
  pline();
  lseek(ferrs, (long)((num-1)*2), 0);
  if (read(ferrs, &erofset, 2) == 2) {
    lseek(ferrs, (long) erofset, 0);
    if (read(ferrs, strngbf, 128) > 0) {
      outil(1, "** Error: %s", &strngbf[2]);
      return;
    }
  }
  outil(1, "** Error number %d.\n", num);
}

/* print error with symbol name */

rpters(num)
int num;
{
  pfilerr(num);
  if (symloc)
    outil(1, ": %n.\n", symloc->sname);
  else
    outil(1, ".\n");
  return(FALSE);
}

/* print error with operand */

rptero(num, op)
int num;
struct classo *op;
{
  pfilerr(num);
  if (!(op->onode) && !(op->ocflag))
    outil(1, ": %n.\n", op->oloc.sym->sname);
  else
    outil(1, ".\n");
  return(FALSE);
}

/* report error and find semicolon */

rptfnd(num)
int num;
{
  fndsc();
  return(rptern(num));
}

/* report error and find semicolon */

rptsfnd(num)
int num;
{
  fndsc();
  return(rpters(num));
}

/* find next semicolon */

fndsc() {
}

/* report error and eat semicolon */

rpteat(num)
int num;
{
  eatsc();
  return(rptern(num));
}

/* find and eat the next semicolon */

eatsc() {
  curtok = 0;
}

/* print string */

pstrng(str)
char *str;
{
  outil(1,"%s",str);
}

/* temp ppcexp */

/* Output code to il file - essentially a "printf". */

outil(args) {
  extern fout;
  register *ap, c;
  register char *s, *af;
  int p, f, sfout;
  unsigned rn;

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
    case 'r':
      rn = *ap++;
      putchar(rn>>8);
      putchar(rn & 0xff);
      continue;
    case 'c':
      c = *ap++ & 0377;
      putchar(c);
      --p;
      while (--p >= 0)
        putchar(' ');
      continue;
    case 'n':
      s = (char *) *ap++;
      rn = 8;
      while (*s && rn) {
        putchar(*s++ & 0377);
        --rn;
      }
      putchar('\0');
      continue;
    case 's':
      s = (char *) *ap++;
      while (*s) {
        c = *s++ & 0377;
        putchar(c);
        if (p && --p <= 0)
          break;
      }
      while (--p >= 0)
        putchar(' ');
      if (f & F_Z)
        putchar('\0');
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

