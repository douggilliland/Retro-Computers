/*
* Expression parsing routines
*/

#include "il.h"
#include "pass1.h"

extern int *cursubs, contab[];
extern short curtok;
extern struct symtab strings[], *nxtsst, *astack[];
extern struct symtab **tos;
extern struct symtab *symloc;
extern short token, strloc;
extern short contyp;
extern long convalu;
extern int *nxtdim, *nxtcon, dimstk[];
extern char strnum, matlev;
extern struct sstack *strngloc;
extern int onecon[];
extern struct symtab absdec;
extern struct express *nxtmat;
extern int *nxtfrc, frctab[];
extern struct express *nxtfor, fortab[];
extern struct express emat[];
extern char swexp, rtexp;

/* parse an expression */

exp() {
  if (!bildmat())
    return(FALSE);
  if (swexp) {
    enteru(SWT);
    swexp = 0;
  }
  if (rtexp) {
    enteru(RET);
    rtexp = 0;
  }
  if (!matlev)
    enteru(LOD);
  outexp();
  outstrg();
  return(TRUE);
}

/* parse a parenthetical expression */

pexp() {
  if (getok() != LPR)
    rptern(33);
  else
    curtok = 0;
  exp();
  if (getok() != RPR)
    return(rptern(66));
  curtok = 0;
  return(TRUE);
}

/* parse a for expression */

forexp() {
  register char *fp;
  register char *ep;
  register int *fcp;
  register int *ecp;

  if (!bildmat())
    return(FALSE);
  if (!matlev)
    enteru(LOD);
  for (fp=nxtfor, ep=emat; ep<nxtmat;)
    *fp++ = *ep++;
  nxtfor = fp;
  for (fcp=nxtfrc, ecp=contab; ecp<nxtcon;)
    *fcp++ = *ecp++;
  nxtfrc = fcp;
  if (nxtfor > &fortab[FORNUM]) {
    error(137);
  }
  if (nxtfrc > &frctab[FORCON]) {
    error(137);
  }
  outstrg();
  return(TRUE);
}

/* generate for expression */

genforex(fmrk, cmrk)
char *fmrk;
int *cmrk;
{
  register char *fp;
  register char *ep;
  register int *fcp;
  register int *ecp;

  if (fmrk == nxtfor)
    return(TRUE);
  for (ep=emat, fp=fmrk; fp<nxtfor;)
    *ep++ = *fp++;
  nxtmat = ep;
  *ep = 0;
  nxtfor = fmrk;
  for (ecp=contab, fcp=cmrk; fcp<nxtfrc;)
    *ecp++ = *fcp++;
  nxtcon = ecp;
  nxtfrc = cmrk;
  outexp();
  return(TRUE);
}

/* priority level 15 - comma operator */

exp15() {
  if (!exp14())
    return(FALSE);
  if (getok() != CMA)
    return(TRUE);
  curtok = 0;
  entera(CMA);
  return(exp15());
}

/* priority level 14 - assignment operators */

exp14() {
  short tok;

  if (!exp13())
    return(FALSE);
  while (getok()>=ADA && curtok<=ASN) {
    tok = curtok;
    curtok = 0;
    if (!exp14())
      return(FALSE);
    enterb(tok);
  }
  return(TRUE);
}

/* priority level 13 - conditional operator */

exp13() {
  register struct express *p;
  char flag, tm;
  struct express *tn, *result1;
  int *ip;

  if (!exp12())
    return(FALSE);
  while (getok() == QUM) {
    curtok = 0;
    flag = 0;
    makeload();
    p = nxtmat-1;
    if ((unsigned)(p->mo1loc) > 255)
      if (isconst(p->mo1loc->stype)) {
        ip = p->mo1loc;
        if (*(ip + (SIZINT/2)))
          flag=1;
        else
          flag=2;
        nxtmat--;
        matlev--;
        tos--;
        p->moprtr = 0;
      }
    if (!flag)
      entera(CXB);
    tn = nxtmat;
    tm = matlev;
    if (!exp14())
      return(FALSE);
    if (getok() != COL)
      return(FALSE);
    curtok = 0;
    if (flag == 2) {
      nxtmat = tn;
      matlev = tm;
      tos--;
    }
    else if (flag == 1) {
      tn = nxtmat;
      tm = matlev;
    }
    else {
      enteru(ENC);
      result1 = (nxtmat-1);
      entera(CBR);
    }
    if (!exp14())
      return(FALSE);
    if (flag == 1) {
      nxtmat = tn;
      matlev = tm;
      tn->moprtr = 0;
      tos--;
    }
    else if (!flag) {
      enteru(ENC);
      p = nxtmat-1;
      cvtqum(p, result1);
      enteru(CEN);
    }
  }
  return(TRUE);
}

/* priority level 12 - logical or operator */

exp12() {
  if (!exp11())
    return(FALSE);
  while (getok() == LOR) {
    curtok = 0;
    putorb();
    if (!exp11())
      return(FALSE);
    putore();
  }
  return(TRUE);
}

/* priority level 11 - logical and operator */

exp11() {
  if (!exp10())
    return(FALSE);
  while (getok() == LND) {
    curtok = 0;
    putanb();
    if (!exp10())
      return(FALSE);
    putane();
  }
  return(TRUE);
}

/* priority level 10 - bitwise or operator */

exp10() {
  if (!exp9())
    return(FALSE);
  while (getok() == BOR) {
    curtok = 0;
    if (!exp9())
      return(FALSE);
    enterb(BOR);
  }
  return(TRUE);
}

/* priority level 9 - exclusive or operator */

exp9() {
  if (!exp8())
    return(FALSE);
  while (getok() == XOR) {
    curtok = 0;
    if (!exp8())
      return(FALSE);
    enterb(XOR);
  }
  return(TRUE);
}

/* priority level 8 - bitwise and operator */

exp8() {
  if (!exp7())
    return(FALSE);
  while (getok() == AND) {
    curtok = 0;
    if (!exp7())
      return(FALSE);
    enterb(AND);
  }
  return(TRUE);
}

/* priority level 7 - equality operators */

exp7() {
  short tok;

  if (!exp6())
    return(FALSE);
  while (getok()==EQU || curtok==NEQ) {
    tok = curtok;
    curtok = 0;
    if (!exp6())
      return(FALSE);
    enterb(tok);
  }
  return(TRUE);
}

/* priority level 6 - relational operators */

exp6() {
  short tok;

  if (!exp5())
    return(FALSE);
  while (getok()>=LEQ && curtok<=GRT) {
    tok = curtok;
    curtok = 0;
    if (!exp5())
      return(FALSE);
    enterb(tok);
  }
  return(TRUE);
}

/* priority level 5 - shift operators */

exp5() {
  short tok;

  if (!exp4())
    return(FALSE);
  while (getok()==SHL || curtok==SHR) {
    tok = curtok;
    curtok = 0;
    if (!exp4())
      return(FALSE);
    enterb(tok);
  }
  return(TRUE);
}

/* priority level 4 - add and subtract operators */

exp4() {
  short tok;

  if (!exp3())
    return(FALSE);
  while (getok()==ADD || curtok==SUB) {
    tok = curtok;
    curtok = 0;
    if (!exp3())
      return(FALSE);
    enterb(tok);
  }
  return(TRUE);
}

/* priority level 3 - multiplicative operators */

exp3() {
  short tok;

  if (!exp2())
    return(FALSE);
  while (getok()==MUL || curtok==DIV || curtok==MOD) {
    tok = curtok;
    curtok = 0;
    if (!exp2())
      return(FALSE);
    enterb(tok);
  }
  return(TRUE);
}

/* priority level 2 - unary operators */

exp2() {
  short tok;
  int *makone();

  switch (getok()) {
    case FPP:
    case FMM:
      tok = curtok;
      curtok = 0;
      if (!exp2())
        return(FALSE);
      *tos++ = makone();
      enterb(tok);
      tok = 0;
      break;
    case MUL:
      tok = IND;
      break;
    case AND:
      tok = ADR;
      break;
    case NOT:
      tok = NOT;
      break;
    case SUB:
      tok = UNM;
      break;
    case COM:
      tok = COM;
      break;
    case KEY:
      if (token == 22) /* is it sizeof? */
        psizeof();
      tok = 0;
      break;
    default:
      if (!exp1())
        return(FALSE);
      tok = 0;
  }
  if (tok) {
    curtok = 0;
    if (!exp2())
      return(FALSE);
    enteru(tok);
  }
  if (getok()==FPP || curtok==FMM) {
    *tos++ = makone();
    enterb(curtok + 2);
    curtok = 0;
    /* adding May 23, 1984 - to solve w++[10] */
    return(primexp());
  }
  return(TRUE);
}

/* priority level 1 - operands */

exp1() {
  switch (getok()) {
    case VAR:
      return(xvar());
    case CON:
      return(xcon());
    case STC:
      return(xstr());
    case LPR:
      return(xsub());
    default:
      return(rptern(44));
  }
}

/* process a variable operand */

xvar() {
  int *savesub;
  short temptok;
  short ttyp;

  temptok = curtok;
  curtok = 0;
  if (temptok != STC)
    if (!(symloc = looksym(SIDENT)))
      symloc = addsym(SIDENT);
  if (symloc->sclass == TYPDF)
    return(rptern(59));
  if (symloc->sclass == MOE) {
    contyp = INT;
    convalu = (long) symloc->sstore;
    return(xcon());
  }
  *tos++ = symloc;
  if (tos > &astack[ASLEN])
    error(138);
/*if (symloc->sstrct) {  */
  ttyp = symloc->stype & 0x0f;
  if (ttyp==STRUCT || ttyp==UNION) {
    strnum = symloc->sstrnum;
    strloc = symloc->sstrct;
  }
  savesub = cursubs;
  if (symloc->ssubs)
    cursubs = symloc->ssubs;
  else
    cursubs = 0;
  if (!primexp())
    return(FALSE);
  if (savesub)
    cursubs = savesub;
  return(TRUE);
}

/* process a constant operand */

xcon() {
  curtok = 0;
  pshcon();
  return(primexp());
}

/* push constant onto stack */

pshcon() {
  int *p;

  p = nxtcon;
  *p++ = (contyp << 8) | CONST;
  if ((contyp>=LONG) || (SIZINT==4)) {
    *p++ = (int) (convalu>>16);
    *p++ = (int) convalu;
  }
  else
    *p++ = (int) convalu;
  if (p >= &contab[NUMCON])
    error(139);
  *tos++ = nxtcon;
  nxtcon = p;
  if (tos > &astack[ASLEN])
    error(138);
}

/* process string constant operand */

xstr() {
  short size;
  char *p;

  if (nxtsst >= &strings[SSLEN])
    error(133);
  symloc = nxtsst++;
  symloc->sclass = STAT;
  symloc->stype = (ARAY<<4) | CHR;
  symloc->sstore = strngloc->stlbl;
  symloc->ssubs = nxtdim;
  p = strngloc->stptr;
  for (size = 1; *p; p++, size++);
  *nxtdim++ = size;
  *nxtdim++ = (-1);
  if (nxtdim >= &dimstk[DMLEN])
    error(135);
  return(xvar());
}

/* process sub expression */

xsub() {
  short typ;
  int *makone();
  short mtyp;
  short tnum, tstr;

  tnum = tstr = 0;
  curtok = 0;
  if (tsttyp()) {
    typnam();
    if (getok() != RPR)
      rptern(45);
    else
      curtok = 0;
    typ = symloc->stype;
    mtyp = typ & 0x0f;
    if (mtyp==STRUCT || mtyp==UNION) {
      tnum = symloc->sstrnum;
      tstr = symloc->sstrct;
    }
    exp2();
    enteru(CVC);
    (nxtmat-1)->mttype = typ;
    if (tnum) {
      strnum = tnum;
      strloc = tstr;
    }
    if (getok()==FPP || curtok==FMM) {
      *tos++ = makone();
      enterb(curtok+2);
      curtok = 0;
    }
    return(TRUE);
  }
  exp15();
  if (getok() != RPR)
    rptern(45);
  else
    curtok = 0;
  return(primexp());
}

/* process primary expression */

primexp() {
  short savenum;
  short savstr;

  switch(getok()) {
    case LSB:
      curtok = 0;
      savenum = strnum;
      savstr = strloc;
      strnum = 0;
      exp15();
      strnum = savenum;
      strloc = savstr;
      if (getok() != RSB)
        rptern(46);
      else
        curtok = 0;
      if (*cursubs != (-1))
        cursubs++;
      enterb(ADD);
      enteru(IND);
      return(primexp());
    case LPR:
      curtok = 0;
      if (symloc && !symloc->sclass) {
        symloc->sclass = EXTN;
        symloc->stype = (FNCT<<4) | INT;
      }
      entern(SPL);
      savenum = strnum;
      savstr = strloc;
      explst();
      if (getok() != RPR)
        rptern(47);
      else
        curtok = 0;
      enteru(CAL);
      strnum = savenum;
      strloc = savstr;
      return(primexp());
    case ARO:
      curtok = 0;
      enteru(IND);
    case DOT:
      curtok = 0;
      return(strident());
    default:
      return(TRUE);
  }
}

/* parse expression list */

explst() {
  if (getok() == RPR)
    return(TRUE);
  while (TRUE) {
    entern(SPR);
    exp14();
    entera(PRM);
    if (getok() != CMA)
      return(TRUE);
    curtok = 0;
  }
}

/* process a structure member identifier */

strident() {
  int *savesub;
  short ttyp;

  savesub = cursubs;
  if (getok() != VAR)
    return(rpters(49));
  curtok = 0;
  if (!(symloc = looksym(SMEMBER))) {
    rptern(49);
  }
  else {
    if (symloc->ssubs)
      cursubs = symloc->ssubs;
  /*if (symloc->sstrct) { */
    ttyp = symloc->stype & 0x0f;
    if (ttyp==STRUCT || ttyp==UNION) {
      strnum = symloc->sstrnum;
      strloc = symloc->sstrct;
    }
  }
  *tos++ = symloc;
  enterb(DOT);
  if (!primexp())
    return(FALSE);
  if (savesub)
    cursubs = savesub;
  return(TRUE);
}

/* parse sizeof expression */

psizeof() {
  char parflag, done;

  parflag = done = curtok = 0;
  if (getok() == LPR) {
    parflag++;
    curtok = 0;
    if (tsttyp()) {
      symloc = 0;
      typnam();
      done++;
    }
  }
  if (!done) {
    if (getok() != VAR)
      rptern(63);
    else {
      symloc = looksym(SIDENT);
      if (parflag)
        curtok = 0;
    }
  }
  if (parflag)
    if (getok() != RPR)
      rptern(48);
  if (!symloc)
    rptern(63);
  else {
    convalu = sizeit(symloc);
  }
  contyp = UNSND;
  return(xcon());
}

/* make and put the value one onto constant stack */

int *makone() {
  int *p1, *p2;

  p1 = p2 = nxtcon;
  *p1++ = (INT<<8) | CONST;
  if (SIZINT == 4)
    *p1++ = 0;
  *p1++ = 1;
  nxtcon = p1;
  return(p2);
}

