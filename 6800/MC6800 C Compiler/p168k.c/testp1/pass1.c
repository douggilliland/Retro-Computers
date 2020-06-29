/*
* This file contains all external symbol definitions, the basic i/o
* routines, and the main calling loop.
*/

/*
#info 68000 UniFLEX (R) C Compiler - pass1
#info Version 2.51, Released March 13, 1985
#info Copyright (C) 1984, 1985 by
#info Technical Systems Consultants, Inc.
#info All rights reserved.
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

int pp_if_result;
short errcnt;
short curchar;
short curtok;
short dtype;
char lstflg;
char dclass;
char blklev;
char pmlsf;
char fndcf;
char deftyp;
char sukey;
char ilopt;
char nobopt;
char absflag;
char qopt;
char optf;
char uopt;
char inexplst;
short tempch;
short ptrcnt;
short opcount;
short retlab;
short argoff;
short datareg;
short addrreg;
short nxtarg;
short nxtaut;
short inztyp;
int *nxtdim;
int *subsptr;
short label;
char cspace;
char nocomf;
char funnum;
char dpflag;
char nokey;
short funtype;
short lastmem;
short strhdr;
short strtag;
short strofs;
short strptr;
short brklab;
short conlab;
short deflab;
short flptreg;
int *nxtsw;
int *cswmrk;
short ferrs;
short erofset;
short strsize;
short fpvars;
char swflag;
char matlev;
char strnum;
char strcount;
short namsize;
char strnum2;
short strhdr2;
int enumval;
int value;
short hdrlab;
int *cursubs;
int *nxtcon;
char thisop;
short strloc;
char swexp;
char rtexp;
char cmexfl;
char doqmf;
int ioff;
int fstr;
char doingfld;
char fieldoff;
char initfld;
int crntfld;
unsigned lwr;
unsigned upr;
unsigned aft;
unsigned fieldval;
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
struct symtab *inzsym;
struct symtab absdec;
struct symtab **tos;
struct symtab *topsst;
int contab[NUMCON];
struct symtab strings[SSLEN];
struct symtab *nxtsst;
struct symtab *astack[ASLEN];
struct infost *ptinfo;
struct infost stinfo[STNEST];
struct express emat[MATLEN];
short contyp;
long convalu;
long fconvalu;
int *nxtfrc;
struct express *nxtfor;
int frctab[FORCON];
struct express fortab[FORNUM];
struct symtab *symloc;
struct symtab *funnam;
struct symtab *argptr;
struct symtab *endprms;
int dimstk[DMLEN];
int swttab[SWLEN];
char strngbf[MAXSTRNG];
char esctab[] = {'n','\n','t','\t','b','\b','r','\r','f','\f','v','\v','\0'};
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
  '{', LCB,
  '}', RCB,
  '[', LSB,
  ']', RSB,
  '|', BOR,
  '^', XOR,
  '~', COM,
  '\\', BKS,
  '\0', 0 };

char fasttbl[] = {
  NOT,DQU,BAD,BAD,MOD,AND,SQU,LPR,RPR,MUL,ADD,CMA,SUB,DOT,DIV,
  BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,COL,SMC,LES,ASN,GRT,QUM};

/* constants for expressions */

int onecon[] = { (INT<<8)|CONST, 1};

#ifdef PROFILE
char prbufr[65536/32];
#endif

/* Main pass1 loop */

main(argc, argv)
int argc;
char *argv[];
{
#ifdef PROFILE
  doprof(prbufr, sizeof(prbufr));
#endif
  if (prs(argc, argv) != 0) {
    perror("Can't preset!\n");
    exit(255);
  }
  initial();
  loop();
  errrpt();
#ifdef PROFILE
  dumpit(prbufr, sizeof(prbufr));
#endif
}

#ifdef PROFILE
doprof(addr, size)
char *addr;
int size;
{
  profil(addr, size, 0, 64);
}

dumpit(addr, size)
char *addr;
int size;
{
  int fd;
  fd = creat("p1.profile", 0x3f);
  write(fd, addr, size);
  close(fd);
}
#endif

/* Initialize all variables and open files */

initial() {
  extern fout;

/*if ((fout = creat("cc_temp", 0x3f)) < 0) {
    perror("Can't create IL file.\n");
    exit(255);
  } */
  fout = 3;
  errcnt = 0;
  doqmf = 0;
  if ((ferrs=open("/bin/cpasses/p1-errors", 0)) < 0) {
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
    finit();
    domodule(name);
  }
  flush();
}

/* initialize pass1 for new file */

finit() {
  curtok = curchar = label = 0;
  tempch = swflag = matlev = brklab = conlab = 0;
  absflag = retlab = deflab = 0;
  nxtsw = swttab;
  nxtsst = strings;
  nxtdim = dimstk;
  if ((fstr = creat("cc_strings", 0x3f)) < 0) {
    perror("Can't create STRING file.\n");
    exit(255);
  }
  close(fstr);
  fstr = open("cc_strings", 2);
  unlink("cc_strings");
}

/* flush strings file */

flstr() {
  short i;

  if (optf)
    outtext();
  else
    outdata();
  flush();
  lseek(fstr, 0L, 0);
  while (i=read(fstr, _obuf, 512))
    write(fout, _obuf, i);
  close(fstr);
  outtext();
}

/* Give final error report */

errrpt() {
  if (errcnt) {
    outil(1, "%u error(s) detected.\n", errcnt);
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
  if (n < 100)
    n += 150;
  pfilerr(1, n, 0);
  flush();
  exit(255);
}

/* temp error routine */

rptern(num)
int num;
{
  pfilerr(0, num, 0);
  outil(1, ".\n");
  return(FALSE);
}

/* report warning */

rptwrn(num)
int num;
{
  pfilerr(0, num, 1);
  outil(1, ".\n");
  return(FALSE);
}

/* print file error */

pfilerr(flag, num, warn)
int flag, num, warn;
{
  if (!warn)
    errcnt++;
  if (!lstflg)
    pfile();
  pline();
  lseek(ferrs, (long)((num-1)*2), 0);
  if (read(ferrs, &erofset, 2) == 2) {
    lseek(ferrs, (long) erofset, 0);
    if (read(ferrs, strngbf, 128) > 0) {
      if (flag) {
        flush();
        outil(2, "** FATAL ERROR: %s.\n", &strngbf[2]);
        flush();
      }
      else {
        if (warn)
          outil(1, "** Warning: %s", &strngbf[2]);
        else
          outil(1, "** Error: %s", &strngbf[2]);
      }
      return;
    }
  }
  outil(1, "** Error number %d.\n", num);
}

/* print error with symbol name */

rpters(num)
int num;
{
  pfilerr(0, num, 0);
  if (symloc)
    outil(1, ": %0n.\n", symloc->sname);
  else
    outil(1, ".\n");
  return(FALSE);
}

/* print error with operand */

rptero(num, op)
int num;
struct classo *op;
{
  pfilerr(0, num, 0);
  if (!(op->onode) && !(op->ocflag))
    outil(1, ": %0n.\n", op->oloc.sym->sname);
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
  while (getok()!=SMC && curtok!=FILE_END)
    curtok = 0;
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
  while (getok()!=SMC && curtok!=FILE_END)
    curtok = 0;
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
  else {
    if ((errcnt && ilopt==0) || nobopt)
      return;
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
        rn--;
      }
      if (!(f & F_Z))
        putchar('\0');
      continue;
    case 's':
      s = (char *) *ap++;
      if (f & F_L) {
        while (strsize) {
          c = *s++ & 0377;
          if (c)
            putchar(c);
          strsize--;
        }
      }
      else {
        while (*s) {
          c = *s++ & 0377;
          putchar(c);
          if (p && --p <= 0)
            break;
        }
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

