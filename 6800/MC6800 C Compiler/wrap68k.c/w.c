#ifdef M6809
#info 6809 UniFLEX (R) C Compiler
#else
#info 68010 UniFLEX (R) C Compiler
#endif
#info Version 1.2:00, Released May 28, 1985
#info Copyright (C) 1985 by
#info Technical Systems Consultants, Inc.
#info All rights reserved.
#ifndef M6809
#tstmp
#endif
#include "putchar.c"
#include "printf.c"
#include "wrap.h"
#include <sys/signal.h>
#ifndef M6809
#include <sys/systat.h>
#endif


char *p1args[P1ARGS];
char *p2args[P2ARGS];
char *ldargs[LDARGS];
char *asargs[ASARGS];
char *cpargs[P1ARGS];
char *opargs[4];
char tifile[64];
char tafile[64];
char trfile[64];
char tofile[64];
char tpfile[64];
char aoname[64];
char loname[64];
char ldstrings[1024];
char *ifile;
char *afile;
char *rfile;
char *ofile;
char *sfile;
char *pfile;
int p1index;
int p2index;
int ldindex;
int asindex;
int opindex;
int cpindex;
int asname;
int ldname;
char oneflag;
char delafil;
char delrfil;
char **argptr;
char *nxtstr;
char optL;
char optn;
char optr;
char opta;
char opto;
char optq;
char optt;
char optc;
char opts;
char optS;
char optb;
char optN;
char opti;
char optm;
char optD;
char optd;
char optp;
char optP;
char optI;
char optO;
char optE;
char optf;
char optF;
char optl;
char optM;
char optR;
char optv;
int ferr;
int (*oldsig)();
int filec;
int cfilec;
int afilec;
int rfilec;
int pfilec;
char num[8];

char strL[] = "+L";
char strn[] = "+n";
char strN[] = "+N";
char strq[] = "+q";
char strt[] = "+t";
char strc[] = "+c";
char strs[] = "+s";
char strb[] = "+b";
char strm[] = "+m";
char strd[] = "+d";
char strp[] = "+p";
char strI[] = "+I";
char strE[] = "+E";
char strf[] = "+f";
char strF[] = "+F";
char strM[] = "+ur";
char strw[] = "+w";
char strU[] = "+U";

char difile[] = "/tmp/cifXXXXX";
char dafile[] = "/tmp/cafXXXXX";
char drfile[] = "/tmp/crfXXXXX";
char dpfile[] = "/tmp/cpfXXXXX";
char dopfile[] = "/tmp/cofXXXXX";

#ifndef M6809
struct sstat stat_buf;
#endif

int (*signal())();

main(argc, argv)
int argc;
char *argv[];
{
  char *p;
  char **argv2;

  oldsig = signal(2,1);
  argptr = argv2 = argv;
  pfilec = rfilec = afilec = cfilec = filec = 0;
  if (argc < 2) {
    printf(2, "Syntax error - file name expected.\n");
    flush();
    exit(255);
  }
  p1args[p1index++] = P1NAME;
  p2args[p2index++] = P2NAME;
  ldargs[ldindex++] = LNAME;
  asargs[asindex++] = ANAME;
  cpargs[cpindex++] = CPNAME;
  opargs[opindex++] = ONAME;
  nxtstr = ldstrings;
  while (p = *++argv2) {
    if (*p == '+')
      doopts(p);
  }
  if (optr || optR || optI || opta || optP)
    oneflag = 1;
  else
    oneflag = 0;
  if (optr && optR)
    incopt('r', 'R');
  if (optn && optI)
    incopt('n', 'I');
  if (optn && opta)
    incopt('n', 'a');
  if (optn && optr)
    incopt('n', 'r');
  if (optn && optR)
    incopt('n', 'R');
  if (optn && opto)
    incopt('n', 'o');
  if (optn && optM)
    incopt('n', 'M');
  if (optI && opta)
    incopt('I', 'a');
  if (optI && optr)
    incopt('I', 'r');
  if (optI && optR)
    incopt('I', 'R');
  if (optI && opto)
    incopt('I', 'o');
  if (optI && optM)
    incopt('I', 'M');
  if (opta && optr)
    incopt('a', 'r');
  if (opta && optR)
    incopt('a', 'R');
  if (opta && opto)
    incopt('a', 'o');
  if (opta && optM)
    incopt('a', 'M');
  if (optr && opto)
    incopt('r', 'o');
  if (optr & optM)
    incopt('r', 'M');
  if (optR && optM)
    incopt('R', 'M');
  if (opts && optS)
    incopt('s', 'S');
  if (optp && optP)
    incopt('p', 'P');
  if (optP && optI)
    incopt('P', 'I');
  if (optP && opta)
    incopt('P', 'a');
  if (optP && optr)
    incopt('P', 'r');
  asargs[asindex++] = "+eu";
#ifndef M6809
  ldargs[ldindex++] = "+c=C"; /* Source code type - LJN 9/11/84 */
#else
  asargs[asindex++] = "+2179";
#endif
#ifndef M6809
  if (opts==0 && optS==0) {
    sysstat(&stat_buf);
    if (stat_buf.ss_hdwr[0] & SS_VM) {
      opts++;
      p2args[p2index++] = strs;
    }
  }
#endif
  if (!optM) {
   /*
    * Changed 1/28/85 LJN - Include one library or the other
    * not both.
    */
#ifndef M6809
    if (opts)
      ldargs[ldindex++] = "+il=clibs";
    else
      ldargs[ldindex++] = "+il=clib";
#else
    ldargs[ldindex++] = "+l=clib";
#endif
    ldargs[ldindex++] = "+l=cmathlib";
    ldargs[ldindex++] = "/lib/Cwrapper.r";
#ifdef M6809
    ldargs[ldindex++] = "+n";
#endif
  }
  else {
    ldargs[ldindex++] = "+i";
  }
  argv2 = argv;
  while (p = *++argv2) {
    if (*p != '+')
      dofile(p);
  }
  asname = asindex++;
  if (!opto)
    ldname = ldindex++;
  if (!filec)
    ferror("Syntax error: no file names specified.\n");
  if (ferr) {
    ferror("C compilation aborted.\n");
    flush();
    exit(255);
  }
  if (optv) {
#ifdef M6809
    printf("6809 C Compiler - copyright (C) 1985 by \n");
#else
    printf("68010 C Compiler - copyright (C) 1984, 1985 by\n");
#endif
    printf("Technical Systems Consultants, Inc.\n");
  }
  makeid();
  makedef();
  compile();
  flush();
}

/* process options pointed at by 'p' */

doopts(p)
char *p;
{
  char och;

  while (och = *++p) {
    switch (och) {
      case 'L':
        p1args[p1index++] = strL;
        if (p1index >= P1ARGS) {
          toom('L');
          p1index = 1;
        }
        cpargs[cpindex++] = strL;
        break;
      case 'n':
        optn++;
        p1args[p1index++] = strn;
        if (p1index >= P1ARGS) {
          toom('n');
          p1index = 1;
        }
        break;
      case 'N':
        optN++;
        p1args[p1index++] = strN;
        if (p1index >= P1ARGS) {
          toom('N');
          p1index = 1;
        }
        cpargs[cpindex++] = strN;
        break;
      case 'r':
        optr++;
        break;
      case 'a':
        opta++;
        break;
      case 'o':
        if (*++p != '=')
          ferror("The 'o' option must be followed with '=name'.\n");
        if (opto)
          ferror("The '+o=name' option must appear only once.\n");
        opto++;
        ldname = ldindex++;
        ofile = ++p;
        while(*p)
          p++;
        p--;
        if (ldindex >= LDARGS) {
          toom('o');
          ldindex = 1;
        }
        break;
      case 'q':
        optq++;
        p1args[p1index++] = strq;
        if (p1index >= P1ARGS) {
          toom('q');
          p1index = 1;
        }
        break;
      case 't':
        ldargs[ldindex++] = strt;
        if (ldindex >= LDARGS) {
          toom('t');
          ldindex = 1;
        }
        break;
      case 'c':
        p2args[p2index++] = strc;
        if (p2index >= P2ARGS) {
          toom('c');
          p2index = 1;
        }
        break;
      case 's':
        p2args[p2index++] = strs;
        opts++;
        if (p2index >= P2ARGS) {
          toom('s');
          p2index = 1;
        }
        break;
      case 'S':
        optS++;
        break;
      case 'b':
        p2args[p2index++] = strb;
        if (p2index >= P2ARGS) {
          toom('b');
          p2index = 1;
        }
        break;
      case 'm':
        ldargs[ldindex++] = strm;
        if (ldindex >= LDARGS) {
          toom('m');
          ldindex = 1;
        }
        break;
      case 'i':
        p--;
        if (*p != '+')
          ferror("The '+i' option must appear by itself.\n");
        p1args[p1index++] = p;
        cpargs[cpindex++] = p;
        while (*p)
          p++;
        p--;
        if (p1index >= P1ARGS) {
          toom('i');
          p1index = 1;
        }
        break;
      case 'D':
        p--;
        if (*p != '+')
          ferror("The '+D' option must appear by itself.\n");
        p1args[p1index++] = p;
        cpargs[cpindex++] = p;
        while (*p)
          p++;
        p--;
        if (p1index >= P1ARGS) {
          toom('D');
          p1index = 1;
        }
        break;
      case 'd':
        p2args[p2index++] = strd;
        if (p2index >= P2ARGS) {
          toom('d');
          p2index = 1;
        }
        break;
      case 'f':
        optf++;
        p1args[p1index++] = strf;
        p2args[p2index++] = strf;
        if (p1index >= P1ARGS) {
          toom('f');
          p1index = 1;
        }
        if (p2index >= P2ARGS) {
          toom('f');
          p2index = 1;
        }
        break;
      case 'p':
        optp++;
        break;
      case 'P':
        optP++;
        break;
      case 'I':
        optI++;
        p1args[p1index++] = strI;
        if (p1index >= P1ARGS) {
          toom('I');
          p1index = 1;
        }
        break;
      case 'U':
        p1args[p1index++] = strU;
        if (p1index >= P1ARGS) {
          toom('U');
          p1index = 1;
        }
        break;
      case 'O':
        optO++;
        break;
      case 'E':
        p2args[p2index++] = strE;
        if (p2index >= P2ARGS) {
          toom('E');
          p2index = 1;
        }
        break;
      case 'F':
        p2args[p2index++] = strF;
        if (p2index >= P2ARGS) {
          toom('E');
          p2index = 1;
        }
        break;
      case 'x':
        if (*++p != '=') {
          ferror("The 'x' option must be followed with '='.\n");
          break;
        }
        *p = '+';
        ldargs[ldindex++] = p;
        if (ldindex >= LDARGS) {
          toom('x');
          ldindex = 1;
        }
        while (*p)
          p++;
        p--;
        break;
      case 'l':
        p--;
        if (*p != '+')
          ferror("The 'l' option must appear by itself.\n");
        ldargs[ldindex++] = p;
        if (ldindex >= LDARGS) {
          toom('l');
          ldindex = 1;
        }
        while (*p)
          p++;
        p--;
        break;
      case 'M':
        optM++;
        ldargs[ldindex++] = strM;
        if (ldindex >= LDARGS) {
          toom('M');
          ldindex = 1;
        }
        break;
      case 'R':
        optR++;
        break;
      case 'v':
        optv++;
        break;
      case 'w':
        p1args[p1index++] = strw;
        if (p1index >= P1ARGS) {
          toom('w');
          p1index = 1;
        }
        cpargs[cpindex++] = strw;
        break;
      default:
        printf(2, "Invalid option: '%c'.\n", och);
        ferr++;
        break;
    }
  }
}

/* process file p */

dofile(p)
register char *p;
{
  register char *p2;
  int size;

  p2 = p;
  while (*++p2);
  if (*(p2-2) != '.') {
    printf(2,"Unknown suffix type in '%s'.\n", p);
    ferr++;
    filec++;
    return;
  }
  switch (*(p2-1)) {
    case 'p':
    case 'c':
      if (!oneflag) {
        if ((optp || optP) && *(p2-1)=='c')
          cpargs[cpindex++] = p;
        else
          p1args[p1index++] = p;
        if (p1index >= P1ARGS) {
          p1index = 1;
          printf(2,"Too many arguments at file '%s'.\n", p);
          ferr++;
        }
      }
      filec++;
      if (*(p2-1) == 'c')
        cfilec++;
      else
        pfilec++;
      break;
    case 'r':
      if (optr) {
        printf(2, "Illegal file type '%s' for '+r' option.\n", p);
        ferr++;
      }
      if (optI) {
        printf(2, "Illegal file type '%s' for '+I' option.\n", p);
        ferr++;
      }
      if (opta) {
        printf(2, "Illegal file type '%s' for '+r' option.\n", p);
        ferr++;
      }
      if (optn) {
        printf(2, "Illegal file type '%s' for '+n' option.\n", p);
        ferr++;
      }
      if (!oneflag) {
        ldargs[ldindex++] = p;
        if (ldindex >= LDARGS) {
          ldindex = 1;
          printf(2,"Too many arguments at file '%s'.\n", p);
          ferr++;
        }
      }
      filec++;
      rfilec++;
      break;
    case 'a':
      if (optI) {
        printf(2, "Illegal file type '%s' for '+I' option.\n", p);
        ferr++;
      }
      if (opta) {
        printf(2, "Illegal file type '%s' for '+a' option.\n", p);
        ferr++;
      }
      if (optn) {
        printf(2, "Illegal file type '%s' for '+n' option.\n", p);
        ferr++;
      }
      if (optr==0 && optR==0) {
        printf(2, "Illegal file type '%s' - must use '+r' option.\n", p);
        ferr++;
      }
      if (!oneflag) {
        asargs[asindex++] = p;
        if (asindex >= ASARGS) {
          asindex = 1;
          printf(2,"Too many arguments at file '%s'.\n", p);
          ferr++;
        }
      }
      filec++;
      afilec++;
      break;
    default:
      printf(2,"Unknown suffix type in '%s'.\n", p);
      ferr++;
      filec++;
      break;
  }
}

/* report fatal error */

ferror(er)
char *er;
{
  printf(2, "%s", er);
  ferr++;
}

/* report incompatible options */

incopt(c1, c2)
char c1;
char c2;
{
  printf(2, "Incompatible options: '%c' and '%c'.\n", c1, c2);
  ferr++;
}

/* report too many arguments */

toom(c)
char c;
{
  printf(2, "Too many arguments at '+%c' option.\n", c);
  ferr++;
}

/* make default file names */

makedef() {
  short i;

  for (i=8; i<13; i++) {
    difile[i] = 'X';
    dafile[i] = 'X';
    drfile[i] = 'X';
    dpfile[i] = 'X';
    dopfile[i] = 'X';
  }
  mktemp(difile);
  mktemp(dafile);
  mktemp(drfile);
  mktemp(dpfile);
  mktemp(dopfile);
}

/* make file names for various passes and options */

makefiles(c) {
  short i;
  register char *p1, *p2;

  delafil = delrfil = 0;
  if (sfile) {
    setnam(sfile, tifile, 'i');
    setnam(sfile, tafile, 'a');
    setnam(sfile, trfile, 'r');
    setnam(sfile, tpfile, 'p');
    setnam(sfile, tofile, '\0');
  }
  if (optI)
    ifile = tifile;
  else
    ifile = difile;
  if (opta || c=='a')
    afile = tafile;
  else {
    afile = dafile;
    delafil++;
  }
  if (optP)
    pfile = tpfile;
  else
    pfile = dpfile;
  if (optr || optR)
    rfile = trfile;
  else {
    rfile = drfile;
    delrfil++;
  }
  if (filec==1 && (cfilec==1) && !opto && !optM)
    ofile = tofile;
  else if (optM && !opto)
    ofile = "output.r";
  else if (!opto)
    ofile = "output";
  aoname[0] = loname[0] = '+';
  aoname[1] = 'o';
  loname[1] = 'o';
  aoname[2] = loname[2] = '=';
  p1 = &aoname[3];
  p2 = rfile;
  while (*p1++ = *p2++);
  asargs[asname] = aoname;
  p1 = &loname[3];
  p2 = ofile;
  while (*p1++ = *p2++);
  ldargs[ldname] = loname;
}

/* set up file names */

setnam(p1, p2, c)
char *p1, *p2, c;
{
  while (*p2++ = *p1++);
  if (c)
    *(p2-2) = c;
  else
    *(p2-3) = '\0';
}

/* make temp file name */

mktemp(name)
register char *name;
{
  register char *p1;

  while (*name != 'X')
    name++;
  p1 = num;
  while (*name++ = *p1++);
}

/* make task id ascii nummber */

makeid() {
  short id;
  register char *p1;
  char flag = 0;

  id = getpid();
  p1 = num;
  if (id/10000) {
    *p1++ = (id/10000) + '0';
    id %= 10000;
    flag++;
  }
  if (flag || id/1000) {
    *p1++ = (id/1000) + '0';
    id %= 1000;
    flag++;
  }
  if (flag || id/100) {
    *p1++ = (id/100) + '0';
    id %= 100;
    flag++;
  }
  if (flag || id/10) {
    *p1++ = (id/10) + '0';
    id %= 10;
  }
  *p1++ = id + '0';
  *p1 = '\0';
}

/* process files */

compile() {
  register char *p;

  if (!oneflag) {
    if (optp)
      sfile = cpargs[cpindex-1];
    else
      sfile = p1args[p1index-1];
    doit(0);
  }
  else {
    while (p = *++argptr) {
      if (*p != '+') {
        sfile = p1args[p1index] = cpargs[cpindex] = p;
        while (*p++);
        doit(*(p-2));
      }
    }
    if (optP)
      return;
    if (!optr)
      doit(1);
  }
}

/* do actual compilation passes */

doit(c) {
  register char *p1, *p2;
  makefiles(c);
  asargs[asindex] = 0;
  if (optp || optP) {
    if ((c=='c') || (!c && cfilec)) {
      docprep();
      if (optP)
        return;
      p1args[p1index] = pfile;
    }
  }
  if ((c=='c') || (c=='p') || (!c && cfilec)) {
    dopass1();
    if (optn || optI)
      return;
    dopass2();
    asargs[asindex] = afile;
    opargs[opindex] = afile;
    afilec++;
  }
  if (opta || optI) {
    if (optO && afilec && c!=1)
      dooptim();
    return;
  }
  if (afilec && c!=1 && c!='r') {
    if (c == 'a') {
      asargs[asindex] = afile;
      opargs[opindex] = afile;
    }
    if (optO && c!='a')
      dooptim();
    doasmb();
    ldargs[ldindex++] = nxtstr;
    p1 = nxtstr;
    p2 = rfile;
    while (*p1++ = *p2++);
    nxtstr = p1;
    rfilec++;
  }
  if (c == 'r') {
    ldargs[ldindex++] = p1 = nxtstr;
    p2 = sfile;
    while (*p1++ = *p2++);
    nxtstr = p1;
  }
  if (c <= 1) {
    dolink();
  }
}

/* report */

report(p)
char *p[];
{
  while(*p)
    printf("  %s\n", *p++);
  flush();
}

/* do stand alone preprocessor */

docprep() {
  int fd;

  if (optv)
    verb("Cprep", &cpargs[1]);
  if (fork() == 0) {
    signal(2, oldsig);
    close(1);
    fd = creat(pfile, 0x03);
    if (fd != 1) {
      ferror("Can't create cprep output file.\n");
      flush();
      exit(255);
    }
    execv("/bin/cpasses/cprep", cpargs);
    ferror("Can't execute cprep.\n");
    flush();
    unlink(pfile);
    exit(255);
  }
  wait(&fd);
  if (fd) {
    if (!optP)
      unlink(pfile);
    rptterm(fd);
    exit(fd);
  }
}

/* do pass1 */

dopass1() {
  int fd;

  if (optv)
    verb("Pass1", &p1args[1]);
  if (fork() == 0) {
    signal(2, oldsig);
    if (!optn) {
      fd = creat(ifile, 0x03);
      if (fd != 3) {
        ferror("Can't create intermediate file.\n");
        flush();
        exit(255);
      }
    }
#ifdef DEBUG
    execv("/source/cc/pass1/p1.new", p1args);
#else
    execv("/bin/cpasses/cpass1", p1args);
#endif
    ferror("Can't execute pass1.\n");
    flush();
    unlink(ifile);
    exit(255);
  }
  wait(&fd);
  if (pfile == dpfile)
    unlink(dpfile);
  if (fd) {
    if (!optI)
      unlink(ifile);
    rptterm(fd);
    exit(fd>>8);
  }
}

/* do verbode message */

verb(nam, args)
char *nam;
char **args;
{
  printf("%s", nam);
  while (*args)
    printf(" %s", *args++);
  putchar('\n');
  flush();
}

/* do pass2 */

dopass2() {
  int fd;

  if (optv)
    verb("Pass2", &p2args[1]);
  if (fork() == 0) {
    signal(2, oldsig);
    fd = open(ifile, 0);
    if (fd != 3) {
      ferror("Can't open intermediate file.\n");
      flush();
      unlink(ifile);
      exit(255);
    }
    fd = creat(afile, 0x03);
    if (fd != 4) {
      ferror("Can't create assembler file.\n");
      flush();
      unlink(ifile);
      exit(255);
    }
#ifdef DEBUG
    execv("/source/cc/pass2/p2.new", p2args);
#else
    execv("/bin/cpasses/cpass2", p2args);
#endif
    ferror("Can't execute pass2.\n");
    flush();
    unlink(ifile);
    unlink(afile);
    exit(255);
  }
  wait(&fd);
  unlink(ifile);
  if (fd) {
    unlink(afile);
    rptterm(fd);
    exit(fd>>8);
  }
}

/* do assembly */

doasmb() {
  int fd;

  if (optv)
    verb("Asmb", &asargs[1]);
  if (fork() == 0) {
    signal(2, oldsig);
#ifdef M6809
    execv("/bin/relasmb", asargs);
#else
    execv("/bin/rel68k", asargs);
#endif
    ferror("Can't execute assembler.\n");
    flush();
    if (delafil)
      unlink(afile);
    exit(255);
  }
  wait(&fd);
  if (delafil)
    unlink(afile);
  if (fd) {
    unlink(rfile);
    rptterm(fd);
    exit(fd>>8);
  }
}

/* run optimizer */

dooptim() {
  int fd;
  int fd2;

  if (optv)
    verb("Optim", &opargs[1]);
  if (fork() == 0) {
    signal(2, oldsig);
#ifdef M6809
  close(1);
  fd2 = creat(dopfile,3);
  if (fd2 != 1) {
    ferror("Can't create optimizer output file.\n");
    exit(255);
  }
#endif
#ifdef M6809
    execv("/bin/cpasses/optim", opargs);
#else
    execv("/bin/cpasses/optim68k", opargs);
#endif
    ferror("Can't execute optimizer.\n");
    flush();
    if (delafil)
      unlink(afile);
    exit(255);
  }
  wait(&fd);
#ifdef M6809
  unlink(afile);
  link(dopfile,afile);
  unlink(dopfile);
#endif
  if (fd) {
    unlink(rfile);
    rptterm(fd);
    exit(fd>>8);
  }
}

/* do link */

dolink() {
  int fd;

  if (optv)
    verb("Link", &ldargs[1]);
  if (fork() == 0) {
    signal(2, oldsig);
#ifdef M6809
    execv("/bin/link-edit", ldargs);
#else
    execv("/bin/load68k", ldargs);
#endif
    ferror("Can't execute linker.\n");
    flush();
    if (delrfil)
      unlink(rfile);
    exit(255);
  }
  wait(&fd);
  if (delrfil)
    unlink(rfile);
  if (fd) {
    unlink(ofile);
    rptterm(fd);
    exit(fd>>8);
  }
}

rptterm(stat) {
    int       st;       /* scratch for holding status */
     register  char      *m;       /* message pointer */
     register  char      *m1;      /* message pointer */

     st = (stat & 0x7F);   /* extract status */
     m = 0;
     m1 = "";
     switch(st) {
     case 0:
          return;
     case SIGHUP:
          m = "Hangup.";
          break;
     case SIGINT:
          m = "INTERRUPT!";
          break;
     case SIGQUIT:
          m = "Quit.";
          break;
     case SIGKILL:
          m = "Killed.";
          break;
     case SIGPIPE:
          m = "Pipe.";
          break;
     case SIGALRM:
          m = "Alarm.";
          break;
     case SIGTERM:
          m = "Terminated.";
          break;
#ifdef M6809
     case SIGEMT:
          m = "EMT trap.";
          break;
     case SIGSYS:
           m = "Memory Fault.";
          break;
     case SIGTRAP:
          m = "EMT2 trap.";
          break;
     case 9:
          m = "Time Limit.";
          break;
#else
     case SIGEMT:
          m = "EMT $Axxx emulation.";
          break;
     case SIGSWAP:
          m = "Swap error.";
          break;
     case SIGTRACE:
          m = "Trace.";
          break;
     case SIGTRAPV:
          m = "TRAPV instruction.";
          break;
     case SIGCHK:
          m = "CHK instruction.";
          break;
     case SIGEMT2:
          m = "EMT $Fxxx emulation.";
          break;
     case SIGTRAP1:
          m = "TRAP #1 instruction.";
          break;
     case SIGTRAP2:
          m = "TRAP #2 instruction.";
          break;
     case SIGTRAP3:
          m = "TRAP #3 instruction.";
          break;
     case SIGTRAP4:
          m = "TRAP #4 instruction.";
          break;
     case SIGTRAP5:
          m = "TRAP #5 instruction.";
          break;
     case SIGTRAP6:
          m = "TRAP #6 instruction.";
          break;
     case SIGPAR:
          m = "Parity error.";
          break;
     case SIGILL:
          m = "Illegal instruction.";
          break;
     case SIGDIV:
          m = "DIVIDE by 0.";
          break;
     case SIGPRIV:
          m = "Privileged instruction.";
          break;
     case SIGADDR:
          m = "Address error.";
          break;
     case SIGDEAD:
          m = "Dead child.";
          break;
     case SIGWRIT:
          m = "Write to READ-ONLY memory.";
          break;
     case SIGEXEC:
          m = "Execute from STACK/DATA space.";
          break;
     case SIGBND:
          m = "Segmentation violation.";
          break;
     case SIGUSR1:
          m = "User defined interrupt #1.";
          break;
     case SIGUSR2:
          m = "User defined interrupt #2.";
          break;
     case SIGUSR3:
          m = "User defined interrupt #3.";
          break;
#endif
     default:
          printf(2,"Interrupt number %d",st);
          m = "";
          break;
     }
     if( (stat & 0x80) != 0) m1 = " (Core dumped)";
     printf(2,"%s%s\n",m,m1);
     flush();
}
