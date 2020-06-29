/*
* File do evaluate conatant expressions
*/

#include "il.h"
#include "pass1.h"

extern char matlev;
extern char cmexfl;
extern char absflag;
extern int value;
extern short contyp;
extern short curchar, curtok;
extern int pp_if_result;
extern long convalu;
extern struct express *nxtmat, emat[];
extern struct symtab **tos;

/* evaluate a constant expression */

cexp() {
  int *p;
  char savmat;

  cmexfl = 1;
  if (absflag) {
    savmat = matlev;
    if (!exp14())
      return(rptern(50));
    if (savmat != matlev)
      return(rptern(50));
    if (!isconst((*(tos-1))->stype))
      return(rptern(50));
    p = *--tos;
  }
  else {
    if (!bildmat())
      return(FALSE);
    if (!matlev)
      enteru(LOD);
    if (matlev != 1)
      return(rptern(50));
    if (emat[0].moprtr != LOD)
      return(rptern(50));
    if (!isconst(emat[0].mo1loc->stype))
      return(rptern(50));
    p = (int *) emat[0].mo1loc;
  }
  convalu = *(p+1);
  return(TRUE);
}

/* constant expression processor for preprocessor */

ppcexp() {
  short tch, ttok;
  short stat;
  int *p;
  char temp;

  tch = curchar;
  ttok = curtok;
  curchar = curtok = 0;
  temp = absflag;
  absflag = 1;
  if (stat = cexp())
    pp_if_result = convalu;
  else
    pp_if_result = 0;
  curchar = tch;
  curtok = ttok;
  absflag = temp;
  return(stat);
}

/* fold constants in current expression entery */

foldcon() {
  register struct express *p, *nodep;
  register int *conp, *conp2;
  unsigned nodenum;

  p = nxtmat-1;
  if ((unsigned) p->mo1loc >255) {
    if (isconst(p->mo1loc->stype)) {
      if ((unsigned) p->mo2loc > 255) {
        if (isconst(p->mo2loc->stype))
          return(evalcon());
        else
          return(FALSE);
      }
      else {
        if (!p->mo2loc)
          return(evalcon());
        conp = (int *) p->mo1loc;
        nodenum = (unsigned) p->mo2loc;
      }
    }
    else
      return(FALSE);
  }
  else {
    if (!p->mo1loc)
      return(FALSE);
    nodenum = (unsigned) p->mo1loc;
    if ((unsigned) p->mo2loc > 255) {
      if (isconst(p->mo2loc->stype))
        conp = (int *) p->mo2loc;
      else
        return(FALSE);
    }
    else {
      if (!p->mo2loc)
        return(FALSE);
      conp = NULL;
    }
  }
  if ((p->moprtr == ADD) && conp) {
    nodep = &emat[nodenum - 1];
    if (nodep->moprtr==ADD && (!(nodep->mttype&0x30))) {
      if ((unsigned) nodep->mo2loc > 255) {
        if (isconst(nodep->mo2loc->stype)) {
          conp2 = (int *) nodep->mo2loc;
          proccon(*(conp+1), *(conp2+1));
          *(conp2+1) = value;
          *(tos-1) = nodenum;
          nxtmat--;
          nxtmat->moprtr = 0;
          matlev--;
        }
      }
    }
  }
}

/* evaluate constant operation */

proccon(c1, c2)
int c1;
int c2;
{
  switch((nxtmat-1)->moprtr) {
    case UNM:
      value = -c1;
      break;
    case COM:
      value = ~c1;
      break;
    case NOT:
      value = !c1;
      break;
    case ADD:
      value = c1 + c2;
      break;
    case SUB:
      value = c1 - c2;
      break;
    case MUL:
      value = c1 * c2;
      break;
    case DIV:
      if (!c2)
        return(rptern(117));
      value = c1 / c2;
      break;
    case MOD:
      if (!c2)
        return(rptern(117));
      value = c1 % c2;
      break;
    case AND:
      value = c1 & c2;
      break;
    case BOR:
      value = c1 | c2;
      break;
    case XOR:
      value = c1 ^ c2;
      break;
    case SHL:
      value = c1 << c2;
      break;
    case SHR:
      value = c1 >> c2;
      break;
    case EQU:
      value = (c1 == c2);
      break;
    case NEQ:
      value = (c1 != c2);
      break;
    case LES:
      value = (c1 < c2);
      break;
    case GRT:
      value = (c1 > c2);
      break;
    case LEQ:
      value = (c1 <= c2);
      break;
    case GEQ:
      value = (c1 >= c2);
      break;
    default:
      return(FALSE);
  }
  return(TRUE);
}

/* evaluate constants in matrix entry */

evalcon() {
  register struct express *p;
  register int *c1, *c2;
  int stat;

  p = nxtmat-1;
  c1 = (int *) p->mo1loc;
  if (c2 = (int *) p->mo2loc)
    stat = proccon(*(c1+1), *(c2+1));
  else
    stat = proccon(*(c1+1), 0);
  if (!stat)
    return;
  contyp = INT;
  convalu = (long) value;
  tos--;
  nxtmat--;
  nxtmat->moprtr = 0;
  matlev--;
  pshcon();
}

/* test if type is constant valid for folding */

isconst(ct) {
  if ((ct & 0x0f) != CONST)
    return(FALSE);
#ifdef ALIGN
  if ((ct >> 8) >= FLOAT)
#else
  if ((ct >> 8) >= LONG)
#endif
    return(FALSE);
  return(TRUE);
}
