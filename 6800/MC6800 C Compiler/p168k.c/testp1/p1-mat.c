/*
* Routines to handle expression matrix manipulations
*/

#include "il.h"
#include "pass1.h"

extern short curtok;
extern struct express *nxtmat;
extern struct express emat[];
extern int contab[], *nxtcon;
extern char matlev;
extern struct symtab **tos, *astack[], strings[], *nxtsst, *topsst;
extern int dimstk[], *nxtdim;
extern int *cursubs;
extern char strngbf[];
extern char cmexfl;
extern char nokey;
extern char inexplst;
extern int line;
extern struct infost *ptinfo, stinfo[];

/* build an expression matrix */

bildmat() {
  int *savedim;
  short ret;
  struct symtab *savsst;

  tos = astack;
  nxtcon = contab;
  nxtmat = emat;
  savsst = nxtsst;
  inexplst = matlev = 0;
  savedim = nxtdim;
  cursubs = 0;
  nokey++;
  if (cmexfl)
    ret = exp14();
  else
    ret = exp15();
  cmexfl = 0;
  nokey = 0;
  nxtdim = savedim;
  topsst = nxtsst;
  nxtsst = savsst;
  return(ret);
}

/* make top entry a load instruction if not node */

makeload() {
  if (tos != astack)
    if (((unsigned) *(tos-1)) > 255)
        enteru(LOD);
}

/* enter a binary operator in matrix */

enterb(op) {
  register struct express *pexp;
  register struct symtab **symp;
  char tm;

  symp = --tos;
  pexp = nxtmat;
  pexp->moprtr = op;
  pexp->mttype = 0;
  pexp->mo2loc = *symp--;
  pexp->mo1loc = *symp;
  (pexp+1)->moprtr = 0;
  *symp = (struct symtab *) ++matlev;
  if ((nxtmat=pexp+1) >= &emat[MATLEN])
    error(124);
  tm = matlev;
  foldcon();
  if (tm==matlev)
    typechk();
}

/* enter unary operator in matrix */

enteru(op) {
  register struct express *pexp;
  struct symtab *ps;
  char top;
  unsigned i;

  top = 0;
  if (op == IND)
    top = ADR;
  if (op == ADR)
    top = IND;
  if (top) {
    i = (unsigned) *(tos-1);
    if (i<256) {
      pexp = &emat[i-1];
      if (pexp->moprtr == top) {
        pexp->moprtr = 0;
/*      i = (unsigned) pexp->mo1loc;
        if (i<256)
          pexp->mttype = emat[i-1].mttype;
        else {
          ps = pexp->mo1loc;
          pexp->mttype = ps->stype;
        }   */
        *(tos-1) = pexp->mo1loc;
        nxtmat--;
        matlev--;
        return;
      }
    }
  }
  pexp = nxtmat;
  pexp->moprtr = op;
  pexp->mttype = pexp->mo2loc = 0;
  pexp->mo1loc = *(tos-1);
  (pexp+1)->moprtr = 0;
  *(tos-1) = (struct symtab *) ++matlev;
  if ((nxtmat=pexp+1) >= &emat[MATLEN])
    error(123);
  top = matlev;
  foldcon();
  if (top == matlev)
    typechk();
}

/* enter no operand operator in matrix */

entern(op) {
  register struct express *pexp;

  pexp = nxtmat;
  pexp->moprtr = op;
  pexp->mttype = pexp->mo2loc = pexp->mo1loc = 0;
  (pexp+1)->moprtr = 0;
  ++matlev;
  if ((nxtmat=pexp+1) >= &emat[MATLEN])
    error(123);
  typechk();
}

/* enter special operator in matrix */

entera(op) {
  register struct express *pexp;

  pexp = nxtmat;
  pexp->moprtr = op;
  pexp->mttype = pexp->mo2loc = 0;
  pexp->mo1loc = *--tos;
  (pexp+1)->moprtr = 0;
  ++matlev;
  if ((nxtmat=pexp+1) >= &emat[MATLEN])
    error(123);
  typechk();
}

/* put ORB entry in matrix */

putorb() {
  makeload();
  doorb(ORB);
  *tos++ = (struct symtab *) matlev;
}

/* do OR processing */

doorb(op) {
  register struct express *p;

  p = nxtmat-1;
  while (p->moprtr==ORE && op!=ORC) {
    nxtmat = p--;
    --matlev;
    op = ORC;
  }
  if (p->moprtr == ANE) {
    nxtmat = p;
    --matlev;
    doorb(op);
    return(entern(ANE));
  }
  entera(op);
}

/* put ORE in matrix */

putore() {
  makeload();
/*if ((nxtmat-1)->moprtr != ORE) */
    entern(ORE);
  tos--;
  *(tos-1) = *tos;
}

/* put ANB entry in matrix */

putanb() {
  makeload();
  doanb(ANB);
  *tos++ = (struct symtab *) matlev;
}

/* do AND processing */

doanb(op) {
  register struct express *p;

  p = nxtmat-1;
  while (p->moprtr==ANE && op!=ANC) {
    nxtmat = p--;
    --matlev;
    op = ANC;
  }
  if (p->moprtr == ORE) {
    nxtmat = p;
    --matlev;
    doanb(op);
    return(entern(ORE));
  }
  entera(op);
}

/* put ANE in matrix */

putane() {
  makeload();
/*if ((nxtmat-1)->moprtr != ANE) */
    entern(ANE);
  tos--;
  *(tos-1) = *tos;
}

/* output expression matrix */

outexp() {
  register struct express *p;

  outtext();
  outil("%c%r", BEGEXP, line);
  matlev = 0;
  for (p=emat; p->moprtr; p++, matlev++) {
    outil("%c%r", p->moprtr, p->mttype);
    if (p->mo1loc) {
      outop(p->mo1loc);
      if (p->mo2loc)
        outop(p->mo2loc);
    }
  }
}

/* output matrix operand */

outop(optr)
struct symtab *optr;
{
  register struct symtab *p;
  register short *np;
  int tp;

  p = optr;
  if (((unsigned)p) < 256) {
    outil("%c%r", NNODE, p);
    return;
  }
  if ((p->stype & 0x0f) == CONST) {
    np = p;
    outil("%c%c", NCON, *np >> 8);
    tp = (*np++ >> 8);
#ifdef ALIGN
    np++;
    if (tp == DUBLE) {
      outil("%r", *np++);
      outil("%r", *np++);
    }
    outil("%r", *np++);
    outil("%r", *np++);
#else
    if (tp == DUBLE) {
      outil("%r", *np++);
      outil("%r", *np++);
    }
    if (tp > UNSND)
      outil("%r", *np++);
    outil("%r", *np++);
#endif
    return;
  }
  if (p->sclass == EXTN)
    outil("%c%c%r_%n", NNAME, p->sclass, p->stype, p->sname);
  else
    outil("%c%c%r%r", NNAME, p->sclass, p->stype, p->sstore);
}

