/*
* This file contains the lexical analyzer.
*/

#include "cp.h"
#include "il.h"
#include "class.h"
#include "nxtchr.h"

/* macro definitions */

#define getnch() (curchar ? curchar : (curchar = nxtchr()))

/* external definitions */

extern short curchar, curtok;
extern short class;
extern short tempch;
extern long convalu;
extern char esctab[];
extern struct toktab dchtab[];
extern struct toktab eqctab[];
extern struct toktab chrtab[];

/* get next token */

getok() {

  if (!curtok) {
    if (tempch == FILE_END)
      return(curtok = FILE_END);
    while ((tempch = getnch()) >=0 && tempch <= ' ')
      curchar = 0;
    if (class == NUMBER)
      return(curtok = docon());
    curchar = 0;
    if (class == ALPHA) {
      return(curtok = BAD);
}
    switch (tempch) {
      case FILE_END:
        return(curtok = FILE_END);
      case END_IF:
        return(curtok = END_IF);
      case '\'':
        return(curtok = doscon());
      case '=':
      case '+':
      case '&':
      case '|':
      case '<':
      case '>':
        if (tempch == getnch()) {
          curchar = 0;
          return(curtok = findtok(tempch, dchtab));
        }
        if (tempch == '<' || tempch == '>') {
          if (getnch() == '=') {
            curchar = 0;
            return(curtok = findtok(tempch, eqctab));
          }
        }
        return(curtok = findtok(tempch, chrtab));
      case '!':
        if (getnch() == '=') {
          curchar = 0;
          return(curtok = findtok(tempch, eqctab));
        }
      default:
        return(curtok = findtok(tempch, chrtab));
    }
  }
  return(curtok);
}

/* find token for charchter passed in table specified */

findtok(ch, table)
int ch;
struct toktab table[];
{
  register struct toktab *p;

  p = table;
  while (p->ch) {
    if (ch == p->ch) {
      if (p->tok >= ADD && p->tok <= XOR)
        if (getnch() == '=') {
          curchar = 0;
          return(p->tok + (ADA-ADD));
        }
      return(p->tok);
    }
    p++;
  }
  return(BAD);
}

/* process a character constant */

doscon() {
  short ch;

  convalu = 0L;
  while ((ch = getnch())!='\'' && ch!='\n' && ch!=FILE_END) {
    curchar = 0;
    if (ch == '\\') {
      ch = getnch();
      if (class==NUMBER && ch<'8')
        ch = stoctal();
      else {
        ch = fndesc(ch);
        curchar = 0;
      }
    }
    convalu = (convalu<<8) | ch;
  }
  if (ch != '\'') {
    return(FALSE);
  }
  curchar = 0;
  return(CON);
}

/* process numeric constant */

docon() {
  short ch;
  char hflag, nbuf[48];
  register char *p;

  hflag = 0;
  p = nbuf;
  convalu = 0L;
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
      else
        break;
    }
    else
      break;
  }
  *p++ = 0;
  if (hflag)
    gethex(nbuf);
  else if (nbuf[0] == '0')
    getoct(nbuf);
  else
    getdec(nbuf);
  ch = getnch();
  if (class==ALPHA && (ch & 0x5f)=='L') {
    curchar = 0;
  }
  ch = getnch();
  if (class != SEPAR) {
    curchar = 0;
    return(FALSE);
  }
  return(CON);
}

/* check for escaped character */

fndesc(ch)
int ch;
{
  register char *p;

/*if (uopt && ch=='n')
    return('\012');  */
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
    if (*p > '7') {
      return(FALSE);
    }
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
