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
extern short strindx, label;
extern short contyp;
extern long convalu;

extern struct sstack *strngloc;
extern char *nxtstr, strngbf[], esctab[];
extern struct sstack strstck[];
extern struct toktab dchtab[];
extern struct toktab eqctab[];
extern struct toktab chrtab[];

/* get next token */

getok() {
  short tempch;

  if (!curtok) {
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
      case '-':
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
      case '<':
      case '>':
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

/* process string constant token */

dostring() {
  register char *p;
  char ch;

  p = nxtstr;
  strstck[strindx].stlbl = ++label;
  strstck[strindx].stptr = p;
  strngloc = &strstck[strindx++];
  while ((ch = getnch())!='"' && ch!='\n' && ch!=FILE_END) {
    curchar = 0;
    if (ch=='\\') {
      ch = getnch();
      if (class==NUMBER && ch<'8')
        ch = stoctal();
      else {
        curchar = 0;
        if (ch != '\n')
          ch = fndesc(ch);
        else
          ch = 0;
      }
    }
    if (ch)
      *p++ = ch;
  }
  *p++ = '\0';
  curchar = 0;
  if (ch != '"')
    rptern(42);
  if (p >= &strngbf[MAXSTRNG])
    error(1);    /* string overflow */
  nxtstr = p;
  return(STC);
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

  convalu = 0L;
  ch = getnch();
  if (ch == '0') {
    curchar = 0;
    ch = getnch();
    if (class == ALPHA) {
      if ((ch & 0x5f) == 'X') {
        curchar = 0;
        gethex();
      }
    }
    else
      getoct();
  }
  else
    getdec();
  ch = getnch();
  if (class==ALPHA && (ch & 0x5f)=='L') {
    contyp = LONG;
    curchar = 0;
  }
  else
    setctyp();
  return(CON);
}

/* check for escaped character */

fndesc(ch)
int ch;
{
  register char *p;

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

getoct() {
  short ch;

  while ((ch=getnch())<'8' && class==NUMBER) {
    curchar = 0;
    convalu = (convalu << 3) | (ch & 0x07);
  }
}

/* process decimal constant */

getdec() {
  short ch;

  while (ch=getnch(), class==NUMBER) {
    curchar = 0;
    convalu = (convalu * 10) + (ch & 0x0f);
  }
}

/* process hex constant */

gethex() {
  short ch;

  while (ch=getnch(), class==NUMBER || (class==ALPHA
    && ((ch&0x5f) < 'G'))) {
    curchar = 0;
    if (class == ALPHA)
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

