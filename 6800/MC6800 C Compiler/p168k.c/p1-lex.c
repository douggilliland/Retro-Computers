/*
* This file contains the lexical analyzer.
*/

#include "pass1.h"
#include "il.h"
#include "class.h"
#include "nxtchr.h"

/* external definitions */

extern short curchar, curtok;
extern short class;
extern short tempch;
extern short label;
extern short contyp;
extern short strsize;
extern short fpvars;
extern char uopt;
extern char dpflag;
extern long convalu;
extern long fconvalu;
extern char strngbf[], esctab[];
extern struct toktab dchtab[];
extern struct toktab eqctab[];
extern struct toktab chrtab[];
extern char fasttbl[];

/* get next token */

getok() {
  register short tch;

  if (!curtok) {
    if (tempch == FILE_END)
      return(curtok = FILE_END);
    while ((tch = tempch = getnch()) >=0 && tempch <= ' ')
      curchar = 0;
    if (class == NUMBER)
      return(curtok = docon());
    curchar = 0;
    if (tch=='.') {
      getnch();
      if (class == NUMBER) {
        dpflag++;
        return(curtok = docon());
      }
    }
    if (class == ALPHA) {
      return(curtok = BAD);
}
    switch (tch) {
      case FILE_END:
        return(curtok = FILE_END);
      case END_IF:
        return(curtok = END_IF);
      case IDENT:
        return(curtok = donam());
      case KEYWORD:
        return(curtok = dokey());
      case '"':
        return(curtok = dostring());
      case '\'':
        return(curtok = doscon());
      case '-':   /* check for arrow */
        if (getnch() == '>') {
          curchar = 0;
          return(curtok = ARO);
        }
      case '=':
      case '+':
      case '&':
      case '|':
      case '<':
      case '>':
        if (tch == getnch()) {
          curchar = 0;
          return(curtok = findtok(tch, dchtab));
        }
        if (tch == '<' || tch == '>') {
          if (getnch() == '=') {
            curchar = 0;
            return(curtok = findtok(tch, eqctab));
          }
        }
        return(curtok = fasttok(tch, chrtab));
      case '!':
        if (getnch() == '=') {
          curchar = 0;
          return(curtok = findtok(tch, eqctab));
        }
      default:
        return(curtok = fasttok(tch, chrtab));
    }
  }
  return(curtok);
}

/* do fast find of token if can */

fasttok(ch, table)
register int ch;
struct toktab table[];
{
  register char qtok;
  if (ch > '?')
    return(findtok(ch, table));
  qtok = fasttbl[ch - '!'];
  if (qtok>=ADD && qtok<=XOR)
    if (getnch() == '=') {
      curchar = 0;
      return(qtok + (ADA-ADD));
    }
  return(qtok);
}

/* find token for charchter passed in table specified */

findtok(ch, table)
register int ch;
struct toktab table[];
{
  register struct toktab *p;
  register char qtok;

  p = table;
  while (p->ch) {
    if (ch == p->ch) {
      qtok = p->tok;
      if (qtok >= ADD && qtok <= XOR)
        if (getnch() == '=') {
          curchar = 0;
          return(qtok + (ADA-ADD));
        }
      return(qtok);
    }
    p++;
  }
  return(BAD);
}

/* process string constant token */

dostring() {
  register char *p;
  char ch;
  short flag;

  p = strngbf;
  flag = 0;
  strsize = 1;
  while ((ch = getnch())!='"' && ch!='\n' && ch!=FILE_END) {
    curchar = 0;
    flag = 0;
    if (ch=='\\') {
      ch = getnch();
      if (class==NUMBER && ch<'8') {
        ch = stoctal();
        flag++;
      }
      else {
        curchar = 0;
        if (ch != '\n')
          ch = fndesc(ch);
        else
          ch = 0;
      }
    }
    if (ch || flag) {
      *p++ = ch;
      strsize++;
    }
  }
  *p++ = '\0';
  curchar = 0;
  if (ch != '"')
    rptern(42);
  if (p >= &strngbf[MAXSTRNG])
    error(126);    /* string overflow */
  return(STC);
}

/* process a character constant */

doscon() {
  short ch;
  char flag = 0;

  convalu = 0L;
  while ((ch = getnch())!='\'' && ch!='\n' && ch!=FILE_END) {
    curchar = 0;
    if (ch == '\\') {
      ch = getnch();
      if (class==NUMBER && ch<'8') {
        ch = stoctal();
        flag++;
      }
      else {
        if (ch != '\n') {
          flag++;
          ch = fndesc(ch);
        }
        curchar = 0;
      }
    }
    else {
      flag++;
    }
    if (flag)
      convalu = (convalu<<8) | ch;
  }
  if (!flag)
    rptern(43);
  if (ch != '\'')
    rptern(43);
  curchar = 0;
  if (!(convalu & 0xffffff00L))
    contyp = CHR;
  else
    setctyp();
  return(CON);
}

dokey() {
  curchar = 0;
  return(KEY);
}
donam() {
  curchar = 0;
  return(VAR);
}

/* process numeric constant */

docon() {
  short ch;
  char hflag, eflag, dflag, nbuf[48];
  register char *p;

  hflag = eflag = dflag = 0;
  p = nbuf;
  fconvalu = convalu = 0L;
  if (dpflag) {
    *p++ = '.';
    dflag++;
  }
  if (!dpflag) {
    ch = getnch();
    if (ch == '0') {
      curchar = 0;
      ch = getnch();
      if (class == ALPHA) {
        if ((ch & 0x5f) == 'X') {
          curchar = 0;
          hflag++;
        }
        else
          *p++ = '0';
      }
      else
        *p++ = '0';
    }
  }
  dpflag = 0;
  while (TRUE) {
    ch = getnch();
    if (class == NUMBER) {
      *p++ = ch;
      curchar = 0;
    }
    else if (class == ALPHA) {
      if ((ch & 0x5f) == 'L')
        break;
      if (hflag) {
        if ((ch & 0x5f) < 'G') {
          *p++ = (ch & 0x5f);
          curchar = 0;
        }
        else
          break;
      }
      else {
        if ((ch & 0x5f) == 'E') {
          if (eflag)
            return(errnum(107));
          eflag++;
          *p++ = (ch & 0x5f);
          curchar = 0;
          ch = getnch();
          if (ch=='+' || ch=='-') {
            curchar = 0;
            *p++ = ch;
          }
        }
        else
          break;
      }
    }
    else {
      if (ch == '.') {
        if (eflag)
          return(errnum(107));
        if (dflag)
          return(errnum(107));
        dflag++;
        *p++ = ch;
        curchar = 0;
      }
      else
        break;
    }
  }
  *p++ = 0;
  if (hflag)
    gethex(nbuf);
  else if (dflag || eflag)
    getfloat(nbuf);
  else if (nbuf[0] == '0')
    getoct(nbuf);
  else
    getdec(nbuf);
  if (!(dflag || eflag)) {
    ch = getnch();
    if (class==ALPHA && (ch & 0x5f)=='L') {
      contyp = LONG;
      curchar = 0;
    }
    else
      setctyp();
  }
  ch = getnch();
  if (class != SEPAR) {
    rptern(108);
    curchar = 0;
    for (getnch(); class!=SEPAR; curchar=0, getnch());
  }
  return(CON);
}

/* check for escaped character */

fndesc(ch)
int ch;
{
  register char *p;

  if (uopt && ch=='n')
    return('\012');
  p = esctab;
  while (*p) {
    if (ch == *p++)
      return(*p);
    p++;
  }
  return(ch);
}

/* get octal constant for string constant */

stoctal() {
  int num;
  short ch;

  num = 0;
  while ((ch=getnch())<'8' && class==NUMBER) {
    curchar = 0;
    num = (num*8) + (ch & 0x07);
  }
  return(num & 0xff);
}

/* process octal constant */

getoct(buf)
char buf[];
{
  register char *p;

  p = buf;
  while (*p) {
    if (*p > '7')
      return(rptern(108));
    convalu = (convalu << 3) | (*p++ & 0x07);
  }
}

/* process decimal constant */

getdec(buf)
char buf[];
{
  register char *p;

  p = buf;
  while (*p) {
    convalu = (convalu * 10) + (*p++ & 0x0f);
  }
}

/* process hex constant */

gethex(buf)
char buf[];
{
  register char *p;
  char ch;

  p = buf;
  while (ch = *p++) {
    if (ch > '9')
      ch = ch - '7';
    convalu = (convalu << 4) | (ch & 0x0f);
  }
}

/* set constant type */

setctyp() {
  if (!(convalu & 0xffff0000L))
    contyp = ONEWORD;
  else
    contyp = TWOWORDS;
}

/* process float constant */

getfloat(buf)
char buf[];
{
  int stat;

  stat = chrdbl(buf, &convalu);
  if (stat > 0)
    rptern(109);
  else if (stat < 0)
    rptern(107);
  contyp = DUBLE;
  fpvars = 1;
}

/* report error in constant */

errnum(num) {
  rptern(num);
  for (getnch(); class!=SEPAR; curchar=0, getnch());
  return(CON);
}

