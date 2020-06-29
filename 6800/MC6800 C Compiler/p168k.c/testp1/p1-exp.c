/*
* Expression parsing routines
*/

#include "il.h"
#include "pass1.h"

extern int *cursubs, contab[];
extern short curtok;
extern short label;
extern short strsize;
extern struct symtab strings[], *nxtsst, *astack[];
extern struct symtab **tos;
extern struct symtab *symloc;
extern short token, strloc;
extern short contyp;
extern char nokey;
extern char doqmf;
extern char inexplst;
extern unsigned lwr;
extern long convalu;
extern long fconvalu;
extern int *nxtdim, *nxtcon, dimstk[];
extern char strnum, matlev;
extern struct symtab *typdfsym;
extern int onecon[];
extern struct symtab absdec;
extern struct express *nxtmat;
extern int *nxtfrc, frctab[];
extern char strngbf[];
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
  if (tos != astack)
    makeload();
  outexp();
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
  if (tos != astack)
    makeload();
  for (fp=nxtfor, ep=emat; ep<nxtmat;)
    *fp++ = *ep++;
  nxtfor = fp;
  for (fcp=nxtfrc, ecp=contab; ecp<nxtcon;)
    *fcp++ = *ecp++;
  nxtfrc = fcp;
  if (nxtfor > &fortab[FORNUM]) {
    error(122);
  }
  if (nxtfrc > &frctab[FORCON]) {
    error(122);
  }
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
  int st;

  if (!exp14())
    return(FALSE);
  if (inexplst)
    return(TRUE);
  if (getok() != CMA)
    return(TRUE);
  curtok = 0;
  entera(CMA);
  *tos++ = (struct symtab *) matlev;
  st = exp15();
  tos--;
  *(tos-1) = *tos;
  return(st);
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
        if (*(ip + 1))
          flag=1;
        else
          flag=2;
        nxtmat--;
        matlev--;
        tos--;
        p->moprtr = 0;
      }
    if (!flag) {
      fndstsub();
      p = &emat[(int)lwr - 2];
      doqmf++;
      nodecvt(INT, p);
      doqmf = 0;
      (++p)->moprtr = SAV;
      p->mo1loc = NULL;
      matlev++;
      nxtmat++;
      putanb();
    }
    tn = nxtmat;
    tm = matlev;
    if (!exp15())
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
      tos++;
      putane();
      *(tos-1) = (struct symtab *) matlev;
    }
    if (!exp15())
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
      tos--;
      *(tos-1) = *tos;
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
  short tt;

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
  short temptok;
  short ttyp;
  register struct symtab *sym;

  temptok = curtok;
  curtok = 0;
  if (temptok != STC)
    if (!(symloc = looksym(SIDENT)))
      symloc = addsym(SIDENT);
  sym = symloc;
  if (sym->sclass == TYPDF)
    return(rptern(59));
  if (sym->sclass == MOE) {
    contyp = INT;
    convalu = (long) sym->sstore;
    return(xcon());
  }
  *tos++ = sym;
  if (tos > &astack[ASLEN])
    error(123);
/*if (sym->sstrct) {  */
  ttyp = sym->stype & 0x0f;
  if (ttyp==STRUCT || ttyp==UNION) {
    strnum = sym->sstrnum;
    if (!(strloc = sym->sstrct)) {
      fixstrct(sym);
      sym = symloc;
      strloc = sym->sstrct;
    }
  }
  if (!primexp())
    return(FALSE);
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
  register int *p;
  register int tp;
  int *cp;

  p = nxtcon;
  tp = (contyp << 8) | CONST;
#ifdef ALIGN
  tp = (tp<<16) | tp;
  *p++ = tp;
  *p++ = (int) convalu;
  if (contyp == DUBLE)
    *p++ = (int) fconvalu;
#else
  *p++ = tp;
  cp = &convalu;
  if (contyp <= UNSND)
    *p++ = *(cp+1);
  else {
    *p++ = *cp++;
    *p++ = *cp++;
    if (contyp == DUBLE) {
      *p++ = *cp++;
      *p++ = *cp++;
    }
  }
#endif
  if (p >= &contab[NUMCON])
    error(121);
  *tos++ = nxtcon;
  nxtcon = p;
  if (tos > &astack[ASLEN])
    error(123);
}

/* process string constant operand */

xstr() {
  short size;
  register struct symtab *sym;

  if (nxtsst >= &strings[SSLEN])
    error(120);
  symloc = sym = nxtsst++;
  sym->sclass = STAT;
  sym->stype = (ARAY<<4) | CHR;
  sym->sstore = ++label;
  sym->ssubs = nxtdim;
  *nxtdim++ = strsize;
  *nxtdim++ = (-1);
  outstrg();
  if (nxtdim >= &dimstk[DMLEN])
    error(127);
  return(xvar());
}

/* process sub expression */

xsub() {
  short typ;
  int *makone();
  register short mtyp;
  short tnum, tstr;
  char tflag;

  tnum = tstr = 0;
  curtok = 0;
  nokey = 0;
  if (tsttyp()) {
    typnam();
    if (getok() != RPR)
      rptern(45);
    else
      curtok = 0;
    typ = symloc->stype;
    nokey++;
    mtyp = typ & 0x0f;
    if (mtyp == ENUM)
      typ = ((typ & 0xfff0) | INT);
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
  nokey++;
  tflag = inexplst;
  inexplst = 0;
  exp15();
  inexplst = tflag;
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
  char tflag;

  if (getok() == RPR)
    return(TRUE);
  tflag = inexplst;
  inexplst = 1;
  while (TRUE) {
    entern(SPR);
    *tos++ = (struct symtab *) matlev;
    exp14();
    entera(PRM);
    tos--;
/*  outstrg();    fix string guy then do this */
    if (getok() != CMA) {
      inexplst = tflag;
      return(TRUE);
    }
    curtok = 0;
  }
}

/* process a structure member identifier */

strident() {
  register short ttyp;

  if (getok() != VAR)
    return(rpters(49));
  curtok = 0;
  if (!(symloc = looksym(SMEMBER))) {
    rptern(49);
  }
  else {
  /*if (symloc->sstrct) { */
    ttyp = symloc->stype & 0x0f;
    if (ttyp==STRUCT || ttyp==UNION) {
      strnum = symloc->sstrnum;
      if (!(strloc = symloc->sstrct)) {
        fixstrct(symloc);
        strloc = symloc->sstrct;
      }
    }
  }
  *tos++ = symloc;
  enterb(DOT);
  if (!primexp())
    return(FALSE);
  return(TRUE);
}

/* parse sizeof expression */

psizeof() {
  char parflag, done;
  char savmat, savstr;
  short savloc;
  struct symtab **savtos;
  struct express *savnxt;
  struct symtab *savtpd;

  parflag = done = curtok = 0;
  savmat = matlev;
  savstr = strnum;
  savloc = strloc;
  savtos = tos;
  savnxt = nxtmat;
  savtpd = typdfsym;
  contyp = UNSND;
  if (getok() == LPR) {
    parflag++;
    curtok = 0;
    if (tsttyp()) {
      symloc = 0;
      typnam();
      convalu = sizeit(symloc);
      done++;
    }
  }
  if (!done) {
    if (!exp2())
      rptern(63);
    if (matlev == savmat) {
      nxtmat->mo1loc = *(tos-1);
      nxtmat->moprtr = LOD;
      nxtmat++;
      if (!(convalu = patsize((*(tos-1))->stype)))
        rpters(75);
    }
    else
      convalu = patsize((nxtmat-1)->mttype);
  }
  if (parflag) {
    if (getok() != RPR)
      rptern(48);
    else
      curtok = 0;
  }
  matlev = savmat;
  strnum = savstr;
  strloc = savloc;
  tos = savtos;
  nxtmat = savnxt;
  typdfsym = savtpd;
  nxtmat->moprtr = 0;
  pshcon();
  return(primexp());
}

/* make and put the value one onto constant stack */

int *makone() {
  register int *p1, *p2;
  register int tp;

  p1 = p2 = nxtcon;
  tp = (INT<<8) | CONST;
  tp = (tp << 16) | tp;
  *p1++ = tp;
  *p1++ = 1;
  nxtcon = p1;
  return(p2);
}

