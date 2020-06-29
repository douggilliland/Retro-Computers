/* all statement parsing done in this file */

#include "pass1.h"
#include "il.h"
#include "nxtchr.h"

extern short nxtaut, hdrlab, label, curtok;
extern char blklev;
extern int *nxtdim;
extern short curchar;
extern short token, brklab, conlab;
extern short retlab, deflab;
extern int *nxtsw;
extern int *cswmrk;
extern char swflag, matlev;
extern long convalu;
extern int swttab[];
extern int *nxtfrc;
extern struct express *nxtfor;
extern struct symtab *symloc;
extern char swexp, rtexp;
extern short datareg, addrreg, flptreg;
extern int line;
extern struct infost *ptinfo, stinfo[];
extern struct symtab *topsst, *nxtsst;

/* parse a compound statement */

cmpstm() {
  short savaut;
  int *savdimp;
  int symmark;
  short varsize;

  symmark = entblock();
  savaut = nxtaut;
  savdimp = nxtdim;
  if (getok() != LCB)
    rptern(26);
  else
    curtok = 0;
  blklev++;
  dcllst();
  stmlst();
  if (getok() != RCB)
    rptern(27);
  else
    curtok = 0;
  nxtdim = savdimp;
  exitblck(symmark);
  if (blklev != 2) {
    savaut = nxtaut;
    varsize = 0;
  }
  else
    varsize = (savaut - nxtaut);
  blklev--;
  if (!(blklev-1)) {
    outtext();
    outil("%c%r", LABEL, retlab);
    outil("%c%r%r%c", ENDBLK, hdrlab, varsize, (flptreg<<4) | (datareg|addrreg));
  }
  nxtaut = savaut;
  if (curtok)
    return(FALSE);
  return(TRUE);
}

/* parse a statement list */

stmlst() {
  while (getok()!=RCB && curtok!=FILE_END)
    stmnt();
  return(TRUE);
}

/* parse a statement */

stmnt() {
  ptinfo = stinfo;
  switch(getok()) {
    case KEY:
      switch(token) {
        case 25: /* IF */
          return(stif());
        case 29: /* WHILE */
          return(stwhile());
        case 27: /* FOR */
          return(stfor());
        case 30: /* SWITCH */
          return(stswitch());
        case 21: /* RETURN */
          return(streturn());
        case 31: /* CASE */
          return(stcase());
        case 32: /* DEFAULT */
          return(stdefault());
        case 28: /* DO */
          return(stdo());
        case 23: /* BREAK */
          return(stbreak());
        case 24: /* CONTINUE */
          return(stcontin());
        case 20: /* GOTO */
          return(stgoto());
        default:
          return(rpteat(28));
      }
    case SMC:
      curtok = 0;
      return(TRUE);
    case LCB:
      return(cmpstm());
    case VAR:
      if (getnch() == ':') {
        curchar = 0;
        return(dolab());
      }
    default:
      if (!exp())
        return(eatsc());
      if (getok() != SMC)
        return(rpteat(29));
      curtok = 0;
      return(TRUE);
  }
}

/* parse if [else] statement */

stif() {
  short exitlab;
  short elselab;

  curtok = 0;
  exitlab = ++label;
  elselab = 0;
  pexp();
  outcbra(FALSE, exitlab);
  stmnt();
  if (getok()==KEY && token==26) { /* process ELSE */
    curtok = 0;
    outbra(elselab = ++label);
    outlabel(exitlab);
    stmnt();
  }
  outlabel(elselab ? elselab : exitlab);
  return(TRUE);
}

/* parse while statement */

stwhile() {
  short oldbrk;
  short oldcon;
  short newbrk;
  short newcon;

  curtok = 0;
  oldbrk = brklab;
  oldcon = conlab;
  outlabel(conlab = newcon = ++label);
/*outmark(1);  */
  brklab = newbrk = ++label;
  pexp();
  outcbra(FALSE, newbrk);
/*outmark(2);  */
  stmnt();
/*outmark(3);  */
  outbra(newcon);
  outlabel(newbrk);
  conlab = oldcon;
  brklab = oldbrk;
  return(TRUE);
}

/* parse do statement */

stdo() {
  short oldbrk;
  short oldcon;
  short looplab;
  short newcon;
  short newbrk;

  curtok = 0;
  oldbrk = brklab;
  oldcon = conlab;
  outlabel(looplab = ++label);
  conlab = newcon = ++label;
  brklab = newbrk = ++label;
  stmnt();
  if (getok()!=KEY || token!=29) /* look for WHILE */
    return(rpteat(30));
  curtok = 0;
  outlabel(newcon);
  pexp();
  outcbra(TRUE, looplab);
  if (getok() != SMC)
    rptfnd(31);
  curtok = 0;
  outlabel(newbrk);
  conlab = oldcon;
  brklab = oldbrk;
  return(TRUE);
}

/* parse return statement */

streturn() {
  curtok = 0;
  if (getok() != SMC) {
    rtexp++;
    exp();
  }
  if (getok() != SMC)
    rptfnd(31);
  curtok = 0;
  outbra(retlab);
  return(TRUE);
}

/* parse switch statement */

stswitch() {
  short olddef;
  int *marker;
  short oldbrk;
  short termlab;
  short testlab;
  int *oldmrk;

  curtok = 0;
  olddef = deflab;
  deflab = 0;
  marker = nxtsw;
  oldmrk = cswmrk;
  cswmrk = nxtsw;
  oldbrk = brklab;
  brklab = termlab = ++label;
  testlab = ++label;
  swflag++;
  swexp++;
  pexp();
  outbra(testlab);
  stmnt();
  outbra(termlab);
  outlabel(testlab);
  outswit(line, marker);
  outlabel(termlab);
  brklab = oldbrk;
  nxtsw = marker;
  cswmrk = oldmrk;
  deflab = olddef;
  swflag--;
  return(TRUE);
}

/* parse for statement */

stfor() {
  short oldbrk;
  short oldcon;
  short looplab;
  int *formark;
  int *conmark;
  struct symtab *sstmark;

  curtok = 0;
  oldbrk = brklab;
  oldcon = conlab;
  looplab = ++label;
  brklab = ++label;
  conlab = ++label;
  if (getok() != LPR)
    rptern(32);
  else
    curtok = 0;
  if (getok() != SMC)
    exp();
  if (getok() != SMC)
    rptfnd(31);
  curtok = 0;
  outlabel(looplab);
/*outmark(1);  */
  if (getok() != SMC) {
    exp();
    outcbra(FALSE, brklab);
  }
/*outmark(2);  */
  if (getok() != SMC)
    rptfnd(31);
  curtok = 0;
  formark = nxtfor;
  conmark = nxtfrc;
  sstmark = nxtsst;
  if (getok() != RPR) {
    forexp();
    nxtsst = topsst;
  }
  if (getok() == RPR) {
    curtok = 0;
    stmnt();
    outlabel(conlab);
    genforex(formark, conmark);
/*  outmark(3);  */
    outbra(looplab);
    outlabel(brklab);
  }
  nxtsst = sstmark;
  conlab = oldcon;
  brklab = oldbrk;
  return(TRUE);
}

/* parse break statement */

stbreak() {
  curtok = 0;
  if (!brklab)
    rptern(34);
  outbra(brklab);
  if (getok() != SMC)
    rptfnd(31);
  curtok = 0;
  return(TRUE);
}

/* parse continue statement */

stcontin() {
  curtok = 0;
  if (!conlab)
    rptern(35);
  outbra(conlab);
  if (getok() != SMC)
    rptfnd(31);
  curtok = 0;
  return(TRUE);
}

/* parse case statement */

stcase() {
  int swval, *p;

  curtok = 0;
  if (!swflag)
    rptern(36);
  if (!cexp())
    return(FALSE);
  if (swflag) {
    swval = (int) convalu;
    for (p=cswmrk; p<nxtsw; p+=2) {
      if (*p == swval)
        rptwrn(111);
    }
    *nxtsw++ = swval;
    *nxtsw++ = ++label;
    if (nxtsw > &swttab[SWLEN])
      error(124);
    outlabel(label);
  }
  if (getok() != COL)
    rptern(37);
  else
    curtok = 0;
  return(stmnt());
}

/* parse default statement */

stdefault() {
  curtok = 0;
  if (getok() != COL)
    rptern(37);
  else
    curtok = 0;
  if (deflab)
    rptern(38);
  if (!swflag)
    rptern(36);
  outlabel(deflab = ++label);
  return(stmnt());
}

/* parse goto statement */

stgoto() {
  curtok = 0;
  if (getok() != VAR)
    return(rptfnd(40));
  curtok = 0;
  if (!(symloc = looksym(SLABEL))) {
    symloc = addsym(SLABEL);
    symloc->sstore = ++label;
  }
  outbra(symloc->sstore);
  if (getok() != SMC)
    rptfnd(31);
  curtok = 0;
  return(TRUE);
}

/* process a statement label */

dolab() {
  curtok = 0;
  if ((symloc = looksym(SLABEL)) && (symloc->sflags & FLAB))
    rptern(41);
  else {
    if (!symloc) {
      symloc = addsym(SLABEL);
      symloc->sstore = ++label;
    }
    outlabel(symloc->sstore);
    symloc->sflags |= FLAB;
  }
  return(stmnt());
}
