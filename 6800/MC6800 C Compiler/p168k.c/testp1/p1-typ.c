/*
* routines to do type checking, setting, and conversions
*/

#include "il.h"
#include "pass1.h"

extern char qopt;
extern char matlev, nocomf;
extern short ptrcnt, opcount;
extern struct symtab **tos;
extern struct express *nxtmat;
extern struct classo *op1;
extern struct classo *op2;
extern struct classo classes[];
extern char thisop;
extern char strnum;
extern char funnum;
extern char doqmf;
extern short namsize;
extern struct express emat[];
extern int *cursubs;
extern short strloc;
extern short funtype;
extern unsigned lwr, upr, aft;
extern struct symtab pszsym;
extern struct symtab *funnam;
extern struct symtab *symloc;
extern struct symtab *astack[];

/* classify both operands of current entry */

classops() {
  register struct express *p;
  register struct classo *p1, *p2;
  register struct symtab *s;
  register unsigned n1, n2;
  int *cp;
  char top;

  p = nxtmat-1;
  ptrcnt = 0;
  thisop = p->moprtr;
  op1 = p1 = &classes[0];
  op2 = p2 = &classes[1];
  p1->otype = p2->otype = 0;
  p1->onode = p2->onode = 0;
  p1->ocflag = p2->ocflag = 0;
  if (s = p->mo1loc) {
    if ((unsigned) s > 255) {
      p1->onode = 0;
      p1->oloc.sym = s;
      if (!(p1->otype = s->stype))
        rptero(75, p1);
    }
    else {
      p1->onode = (unsigned) s;
      p1->oloc.exp = &emat[(unsigned) s - 1];
      if (!(p1->otype=p1->oloc.exp->mttype) && (p1->oloc.exp->moprtr==CAL))
        if (thisop != CMA)
          rptero(78, p1);
    }
    if (s = p->mo2loc) {
      if ((unsigned) s > 255) {
        p2->onode = 0;
        p2->oloc.sym = s;
        if (!(p2->otype = s->stype))
          rptero(75, p2);
      }
      else {
        p2->onode = (unsigned) s;
        p2->oloc.exp = &emat[(unsigned) s - 1];
        if (!(p2->otype=p2->oloc.exp->mttype) && (p2->oloc.exp->moprtr==CAL))
          rptero(78, p2);
      }
    }
  }
  if ((p1->otype & 0x0f) == CONST) {
    p1->otype >>= 8;
    if (p1->otype < FLOAT)
      p1->ocflag++;
  }
  if ((p2->otype & 0x0f) == CONST) {
    p2->otype >>= 8;
    if (p2->otype < FLOAT)
      p2->ocflag++;
  }
  if (p1->otype & 0x30)
    ptrcnt |= 1;
  if (p2->otype & 0x30)
    ptrcnt |= 2;
  if (thisop!=DOT && thisop!=ADR && (thisop<ADA || thisop>ASN)) {
    if (thisop!=RET && thisop!=LOD && (thisop<FPP || thisop>BMM)) {
      if (p1->otype == FLOAT) {
        cvop1(DUBLE);
      }
      if (p2->otype == FLOAT) {
        cvop2(DUBLE);
      }
    }
  }
  if (p1->onode && p2->onode) {
    if (p1->onode < p2->onode) {
      if ((p1->otype & 0x30)==0 && p1->otype!=STRUCT && p1->otype!=UNION) {
        p = &emat[p1->onode - 1];
        top = (p+1)->moprtr;
        if ((top!=ANE) && (top!=ORE)) {
          n1 = (unsigned) p->mo1loc;
          n2 = (unsigned) p->mo2loc;
          if (n1==0 || n2==0 || n1>255 || n2>255) {
            aft = nxtmat-emat-1;
            fndstsub(p1->oloc.exp);
            reorg();
            classops();
          }
        }
      }
    }
  }
}

/* check if operand is an lvalue */

chlvalu(op)
register struct classo *op;
{
  register short t;
  struct express *tptr;
  char rv = 0;

  if (t = (op->otype & 0x30))
    if (t != (PTR<<4))
      return(rptern(73));
  if (op->ocflag)
    return(rptern(73));
  if (op->onode) {
    if (thisop!=ADR && op->oloc.exp->moprtr == CVC) {
      if ((op->oloc.exp->mttype & 0x30) == (PTR<<4)) {
        tptr = nxtmat;
        nxtmat = op->oloc.exp + 1;
        classops();
        rv = chlvalu(op1);
        nxtmat = tptr;
        classops();
        return(rv);
      }
    }
    if (op->oloc.exp->moprtr==IND || op->oloc.exp->moprtr==DOT
         || op->oloc.exp->moprtr==BEX)
      return(TRUE);
    else
      return(rptern(73));
  }
  return(TRUE);
}

/* remove highest type level */

remvlev(typ)
unsigned typ;
{
  return(((typ>>2) & 0xfff0) | (typ & 0x0f));
}

/* change type X to pointer to X */

makeptr(typ)
unsigned typ;
{
  return(((typ&0xfff0)<<2) | (typ&0x0f) | (PTR<<4));
}

/* do type checking on entry */

typechk() {
  register struct express *p;
  int t;
  char saveop;
  int *cp;
  register struct symtab *sp;
  struct symtab *findnam();
  int kludge;

  if (nxtmat == emat)
    return;
  classops();
  if (op1->onode)
    if (onzcheck(op1->oloc.exp)) {
      op1->oloc.exp++;
      op1->otype = INT;
      op1->onode++;
      p = nxtmat-1;
      t = p->mo1loc;
      p->mo1loc = ++t;
    }
  if (op2->onode)
    if (onzcheck(op2->oloc.exp)) {
      op2->oloc.exp++;
      op2->otype = INT;
      op2->onode++;
      p = nxtmat-1;
      t = p->mo2loc;
      p->mo2loc = ++t;
    }
  p = nxtmat-1;
  if (thisop < FPP) {
    return;
  }
  if (thisop < ADD) {
    switch (thisop) {
      case FPP:
      case FMM:
      case BPP:
      case BMM:
        if (!chlvalu(op1))
          return(FALSE);
        if (op1->oloc.exp->moprtr == BEX)
          op1->oloc.exp->moprtr = BXC;
        if (t = (op1->otype & 0x30))
          if (t==(PTR<<4))
            return(ptradd(p));
          else
            rptern(76);
        break;
      case NOT:
        p->mttype = op1->otype;
        if (op1->otype > DUBLE)
          if ((op1->otype&0x30) != (PTR<<4))
            return(rptero(79, op1));
        return;
      case ADR:
        if ((op1->otype&0x30) != (FNCT<<4))
          chlvalu(op1);
        p->mttype = makeptr(op1->otype);
        if (!(op1->onode)) {
          if (op1->oloc.sym->sclass == REG)
            return(rptern(87));
        }
        else {
          if (op1->oloc.exp->moprtr == BEX)
            return(rptero(105, op1));
        }
        return;
      case IND:
        if (t = (op1->otype & 0x30)) {
          if (t == (FNCT<<4)) {
            p->moprtr = NOP;
            p->mttype = op1->otype;
            if (!op1->onode) {
              return;
            }
            else {
              if (op1->oloc.exp->moprtr==CEN)
                if ((unsigned)((op1->oloc.exp-1)->mo1loc) > 255)
                  return;
            }
            rptern(67);
          }
          p->mttype = remvlev(op1->otype);
          if (p->mttype==STRUCT || p->mttype==UNION) {
            if (op1->onode==0 || op1->oloc.exp->moprtr!=CVC) {
              sp = findnam(op1);
              strnum = sp->sstrnum;
              strloc = sp->sstrct;
            }
          }
          if ((t==(ARAY<<4)) && ((p->mttype&0x30)==(ARAY<<4)))
            p->moprtr = NOP;
          return;
        }
        rptero(70, op1);
        break;
      case UNM:
        if (op1->otype > DUBLE)
          rptero(71, op1);
        break;
      case COM:
        if ((op1->otype & 0x0e) > LONG)
          rptero(72, op1);
        break;
    }
    if (!(p->mttype = op1->otype))
      p->mttype = INT;
    return;
  }
  else if (thisop < EQU) {
    switch (thisop) {
      case ADD:
        if (ptrcnt) {
          if (ptrcnt == 3)
            return(rptern(80));
          ptradd(p);
        }
        else {
          docomut(p);
          if (chktyps(0))
            cvtrslt(0,0);
        }
        break;
      case SUB:
        if (op2->ocflag) {
          cp = p->mo2loc;
          cp++;
          *cp = -(*cp);
          p->moprtr = thisop = ADD;
        }
        if (ptrcnt) {
          if (ptrcnt == 2)
            return(rptern(82));
          if (ptrcnt == 1)
            ptradd(p);
          else {
            if (op1->otype != op2->otype) {
              if ((op1->otype&0x30)==FNCT || (op2->otype&0x30)==FNCT)
                return(rptern(84));
              if ((op1->otype&0xffcf) != (op2->otype&0xffcf))
                return(rptern(84));
            }
            t = patsize(remvlev(op1->otype));
            p->mttype = INT;
            p++;
            p->moprtr = DIV;
            kludge = p-emat;
            p->mo1loc = kludge;
            cp = makone();
            *(cp+1) = t;
            p->mo2loc = cp;
            p++;
            p->moprtr = 0;
            nxtmat = p;
            matlev++;
            t = *(tos-1);
            *(tos-1) = ++t;
            typechk();
          }
        }
        else {
          if (chktyps(0))
            cvtrslt(0,0);
        }
        break;
      case MUL:
        docomut(p);
      case DIV:
        if (op2->ocflag)
          if (opmd(p))
            return(TRUE);
        if (chktyps(0))
          cvtrslt(5,0);
        break;
      case MOD:
        if (chktyps(1))
          cvtrslt(5,0);
        break;
      case SHR:
      case SHL:
        if (chktyps(1))
          cvtrslt(3,1);
        break;
      case AND:
      case BOR:
      case XOR:
        docomut(p);
        if (chktyps(1))
          cvtrslt(0,0);
        break;
    }
  }
  else if (thisop < ADA) {
    if (ptrcnt == 1) {
      if (op2->otype >= FLOAT)
        return(rptero(88, op2));
    }
    else {
      if (ptrcnt == 2)
        if (op1->otype >= FLOAT)
          return(rptero(88, op1));
    }
    if (docomut(p))
      if (thisop > NEQ) {
        thisop += 2;
        if (thisop > GRT)
          thisop -= 4;
        p->moprtr = thisop;
      }
    if (chktyps(3))
      cvtrslt(6, 1);
  }
  else if (thisop <= ASN) {
    if (!chlvalu(op1))
      return(FALSE);
    if (thisop != ASN) {
      if (ptrcnt) {
        if (ptrcnt != 1)
          return(rptern(85));
        if (thisop!=ADA && thisop!=SUA)
          return(rptern(85));
        ptradd(p);
      }
      else {
        if (thisop <= DIA) {
          if (!chktyps(0))
            return(FALSE);
        }
        else {
          if (!chktyps(1))
            return(FALSE);
        }
        if (thisop==SRA || thisop==SLA) {
          if (op2->otype != CHR)
            cvop2(CHR);
            cvtrslt(9,1);
        }
        else
          cvtrslt(4,1);
      }
    }
    else {
      namsize = 0;
      if (chktyps(4)) {
        cvtrslt(7,1);
/*      if (op1->onode && op2->onode) {
          if (op1->otype!=STRUCT && op1->otype!=UNION) {
            aft = nxtmat-emat-1;
            fndstsub(op1->oloc.exp);
            reorg();
            classops();
          }
        }  */
        if (namsize) {
          entern(SIZ);
          putsize(namsize, &((p+1)->mo1loc));
        }
      }
    }
    if (op1->onode)
      if (op1->oloc.exp->moprtr == BEX)
        if (thisop == ASN)
          op1->oloc.exp->moprtr = BCL;
        else
          op1->oloc.exp->moprtr = BXC;
  }
  else {
    switch (thisop) {
      case CXB:
      case CBR:
      case CEN:
        cvtrslt(15,1);
        break;
      case DOT:
        t = op1->otype;
        if (t!=STRUCT && t!=UNION)
          return(rptero(113, op1));
        p->mttype = op2->otype;
        if (op2->oloc.sym->sflags & FFIELD) {
          enteru(BEX);
          cp = makone();
          *cp = (((SHORT<<8)|CONST)<<16) | ((SHORT<<8)|CONST);
          *(cp+1) = op2->oloc.sym->sstrct;
          (p+1)->mo2loc = cp;
        }
        break;
      case CAL:
        if ((op1->otype & 0x30) != (FNCT<<4))
          return(rptero(86, op1));
        p->mttype = remvlev(op1->otype);
        if (op1->onode) {
          aft = nxtmat-emat-1;
          fndstsub(op1->oloc.exp);
          reorg();
        }
        break;
      case PRM:
        if (op1->otype < INT)
          cvop1(INT);
        cvtrslt(15,1);
        if (p->mttype==STRUCT || p->mttype==UNION) {
          findnam(op1);
          putsize(namsize, &p->mo2loc);
        }
        break;
      case LOD:
        if (!(op1->otype & 0x30))
          if (op1->otype > DUBLE)
            return(rptero(89, op1));
        cvtrslt(15,1);
        break;
      case ENC:
        cvtrslt(15,1);
        if (p->mttype==STRUCT || p->mttype==UNION) {
          findnam(op1);
          putsize(namsize, &p->mo2loc);
        }
        break;
      case SPL:
        p->mttype = remvlev(symloc->stype);
        if (p->mttype==STRUCT || p->mttype==UNION)
          putsize(patsize(p->mttype), &p->mo1loc);
        break;
      case RET:
        if (funtype==STRUCT || funtype==UNION
                  || op1->otype==STRUCT || op1->otype==UNION) {
          if (op1->otype != funtype)
            rptern(116);
          else if (strnum != funnum)
            rptern(116);
        }
        if (op1->otype != funtype)
          cvop1(funtype);
        cvtrslt(15,1);
        if (funtype==STRUCT || funtype==UNION)
          putsize(patsize(funtype), &p->mo2loc);
        if (funtype == VOID)
          rptern(115);
        break;
      case SWT:
        if (op1->otype >= FLOAT)
          return(rptern(90));
        if (op1->otype != INT)
          cvop1(INT);
        cvtrslt(15,1);
        break;
      case SIZ:
        p->mttype = (p-1)->mttype;
        break;
      case BEX:
        p->mttype = UNSND;
        break;
    }
  }
}

ptradd(p)
register struct express *p;
{
  int size, *cp;
  struct classo *temp;
  int top1, top2, ttyp;
  char topr;
  register struct express *p2;
  short ttyp2;

  if (!(op1->otype & 0x30)) {
    temp = p->mo1loc;
    p->mo1loc = p->mo2loc;
    p->mo2loc = temp;
    temp = op1;
    op1 = op2;
    op2 = temp;
  }
  ttyp2 = remvlev(op1->otype);
  if (!op1->onode) {
    if (ttyp2==STRUCT || ttyp2==UNION)
      strloc = op1->oloc.sym->sstrct;
  }
  size = patsize(ttyp2);
  p->mttype = op1->otype;
  if ((op1->otype&0x30) == (FNCT<<4))
    return(rptero(77, op1));
  if (op2->otype >= FLOAT)
    return(rptero(96, op2));
  if (size == 1)
    return(TRUE);
  if (op2->ocflag && (op2->otype<=UNSND)) {
    cp = (int *)op2->oloc.sym;
    cp++;
    *cp *= size;
    if (*cp>127 && op2->otype==CHR) {
      op2->otype = INT;
      ttyp = (INT<<8) | CONST;
      ttyp = (ttyp<<16) | ttyp;
      *(cp-1) = ttyp;
    }
  }
  else {
    topr = p->moprtr;
    ttyp = op1->otype;
    top1 = p->mo1loc;
    p->mo1loc = p->mo2loc;
    p->moprtr = MUL;
    cp = makone();
    *(cp+1) = size;
    p->mo2loc = cp;
    typechk();
    p2 = nxtmat++;
    p2->moprtr = topr;
    p2->mttype = ttyp;
    p2->mo1loc = top1;
    p2->mo2loc = (nxtmat-emat)-1;
    (p2+1)->moprtr = 0;
    *(tos-1) = (struct symtab *) ++matlev;
  }
}

/* find pointed at object size */

patsize(t) {
  int *getsubs();

  if ((t&0x0f) == CONST)
    t >>= 4;
  pszsym.stype = t;
  if ((t&0x0f)==STRUCT || (t&0x0f)==UNION) {
    pszsym.sstrct = strloc;
    pszsym.sstrnum = strnum;
  }
  if ((t & 0x30) == (ARAY << 4))
    pszsym.ssubs = getsubs();
  else
    pszsym.ssubs = 0;
  return(sizeit(&pszsym));
}

/* check for valid types - three rules as follows:
*
* 0 -> any type (char to double) - no pointers
* 1 -> integral types only - no pointers
* 2 -> any type - including pointers
* 3 -> any type - except cant mix pointers and floats
*/

chktyps(rule) {
  struct symtab *findnam();

  switch (rule) {
    case 0:
      if (op1->otype > DUBLE)
        return(rptero(89, op1));
      if (op2->otype > DUBLE)
        return(rptero(89, op2));
      break;
    case 1:
      if (op1->otype >= FLOAT)
        return(rptero(92, op1));
      if (op2->otype >= FLOAT)
        return(rptero(92, op2));
      break;
    case 2:
      if (!(op1->otype&0x30))
        if (op1->otype > DUBLE)
          return(rptero(89, op1));
      if (!(op2->otype&0x30))
        if (op2->otype > DUBLE)
          return(rptero(89, op2));
      break;
    case 4:
      if (op1->otype==STRUCT || op1->otype==UNION) {
        if (op1->otype == op2->otype)
          if (findnam(op1)->sstrct == findnam(op2)->sstrct)
            return(TRUE);
        namsize = 0;
        return(rptern(95));
      }
    case 3:
      if (!ptrcnt) {
        if (op1->otype > DUBLE)
          return(rptero(89, op1));
        if (op2->otype > DUBLE)
         return(rptero(89, op2));
        break;
      }
      else {
        if (ptrcnt == 1) {
          if (op2->otype >= FLOAT)
            return(rptero(96, op2));
        }
        else {
          if (ptrcnt==2 && op1->otype>=FLOAT)
            return(rptero(96, op1));
        }
      }
      break;
  }
  return(TRUE);
}

/* do type conversions and set result type
*    There are 5 conversion rules as follows:
*     0 -> usual with +q option
*     1 -> usual without +q option
*     2 -> usual but allow small types
*     3 -> right operand to CHAR, left to INT unless +q
*     4 -> convert right operand to type of left
*     5 -> usual with +q but smallest type is short
*     6 -> special cases for relationals and pur assignment
*
*   Result rules:
*     0 -> usual
*     1 -> type of left operand
*     2 -> integer
*/

cvtrslt(crule, rrule) {
  short op1less, min;
  register struct express *p;

  if (op1->otype == op2->otype) {
    switch(crule) {
      case 0:
        if (qopt)
          break;
      case 1:
        if (op1->otype < INT) {
          cvop1(INT);
          cvop2(INT);
        }
      case 2:
      case 6:
      case 7:
        break;
      case 3:
        if (op2->otype != CHR)
          cvop2(CHR);
        if (!qopt)
          if (op1->otype < INT)
            cvop1(INT);
      case 4:
        break;
      case 5:
        if (qopt) {
          if (op1->otype < SHORT) {
            cvop1(SHORT);
            cvop2(SHORT);
          }
          break;
        }
        if (op1->otype < INT) {
          cvop1(INT);
          cvop2(INT);
        }
        break;
    }
  }
  else {
    op1less = 0;
    if (op1->otype < op2->otype)
      op1less++;
    min = INT;
    if (qopt)
      if (crule == 0)
        min = CHR;
      else
        if (crule == 5)
          min = SHORT;
    if (crule==2 || crule==6 || crule==7)
      min = CHR;
    switch (crule) {
      case 6:
      case 7:
        if (ptrcnt==3)
          break;
        if (op1->ocflag && op1->otype!=op2->otype)
          if (op1->otype<LONG && op2->otype<LONG) {
            cvcon(op1->otype, op2->otype, op1->oloc.sym);
            op1->otype = op2->otype;
            break;
          }
        if (op2->ocflag && op2->otype!=op1->otype)
          if (op1->otype<LONG && op2->otype<LONG) {
            cvcon(op2->otype, op1->otype, op2->oloc.sym);
            op2->otype = op1->otype;
            break;
          }
      case 0:
      case 1:
      case 2:
      case 5:
        if (crule != 7) {
          if (op1less) {
            if (op2->otype < min) {
              cvop1(min);
              cvop2(min);
              break;
            }
            if (op1->otype>=min && op2->ocflag && op2->otype==INT
                      && willfit(op1->otype, op2->oloc.sym)) {
              cvop2(op1->otype);
              break;
            }
            cvop1(op2->otype);
            break;
          }
          if (op1->otype < min) {
            cvop1(min);
            cvop2(min);
            break;
          }
        }
        if (crule==6 || crule==7) {
          if (op2->ocflag && ptrcnt==1) {
            if (op2->otype != INT)
              cvop2(INT);
            break;
          }
        }
        cvop2(op1->otype);
        break;
      case 3:
        if (!qopt)
          if (op1->otype < INT)
            cvop1(INT);
        if (op2->otype != CHR)
          cvop2(CHR);
        break;
      case 4:
        cvop2(op1->otype);
        break;
    }
  }
  p = nxtmat-1;
  switch (rrule) {
    case 0:
    case 1:
      p->mttype = op1->otype;
      break;
    case 2:
      p->mttype = INT;
      break;
  }
}

/* convert operand one to type specified */

cvop1(ctype) {
  register struct express *p;
  unsigned noden;
  int *cp;
  register struct classo *p1;

  p1 = op1;
  p = nxtmat-1;
  p->mttype = ctype;
  if (p1->onode)
    nodecvt(ctype, p1->oloc.exp);
  else {
    if (p1->ocflag && p1->otype<MAXCON && ctype<MAXCON) {
      cvcon(p1->otype, ctype, p->mo1loc);
      p1->otype = ctype;
      return;
    }
    else {
      (p+1)->mo2loc = p->mo2loc;
      p->mo2loc = 0;
      (p+1)->moprtr = p->moprtr;
      p->moprtr = CVC;
      (p+1)->mo1loc = (p-emat) + 1;
    }
  }
  p1->otype = ctype;
  (++nxtmat)->moprtr = 0;
  matlev++;
  noden = (unsigned) (*(tos-1));
  if (thisop != PRM)
    *(tos-1) = (struct symtab *) ++noden;
}

/* convert operand two to type specified */

cvop2(ctype) {
  register struct express *p;
  unsigned noden;
  int *cp;
  register struct classo *p2;

  p2 = op2;
  p = nxtmat-1;
  p->mttype = ctype;
  if (p2->onode)
    nodecvt(ctype, p2->oloc.exp);
  else {
    if (p2->ocflag && p2->otype<MAXCON && ctype<MAXCON) {
      cvcon(p2->otype, ctype, p->mo2loc);
      p2->otype = ctype;
      return;
    }
    else {
      (p+1)->mo1loc = p->mo1loc;
      p->mo1loc = p->mo2loc;
      p->mo2loc = 0;
      (p+1)->moprtr = p->moprtr;
      p->moprtr = CVC;
      (p+1)->mo2loc = (p-emat) + 1;
    }
  }
  p2->otype = ctype;
  (++nxtmat)->moprtr = 0;
  matlev++;
  noden = (unsigned) (*(tos-1));
  *(tos-1) = (struct symtab *) ++noden;
}

/* convert the node referenced to the type specified */

nodecvt(ctype, ep)
int ctype;
struct express *ep;
{
  register struct express *p;
  unsigned nodnum;
  unsigned mynode;

  for (p=nxtmat-1; p>ep; p--) {
    (p+1)->moprtr = p->moprtr;
    (p+1)->mttype = p->mttype;
    (p+1)->mo1loc = p->mo1loc;
    (p+1)->mo2loc = p->mo2loc;
  }
  p = ep+1;
  p->moprtr = CVC;
  p->mttype = ctype;
  p->mo1loc = (ep-&emat[0]) + 1;
  p->mo2loc = 1; /* so classop() won't reorg() - KLUDGE */
  mynode = (unsigned) (p->mo1loc);
  for (p=ep+2; p<=nxtmat; p++) {
    nodnum = (unsigned) (p->mo1loc);
    if (nodnum && (nodnum < 255) && (nodnum >= mynode))
      p->mo1loc = ++nodnum;
    nodnum = (unsigned) (p->mo2loc);
    if (nodnum && (nodnum < 255) && (nodnum >= mynode))
      p->mo2loc = ++nodnum;
  }
  if (doqmf == 0) {
    nxtmat++;
    classops();
    nxtmat--;
  }
  (ep+1)->mo2loc = 0; /* undo the above KLUDGE */
}

/* test for commute conditions and do it */

docomut(p)
register struct express *p;
{
  struct express *temp;

  if (nocomf) {
    nocomf=0;
    return(FALSE);
  }
  if (op1->onode)
    return(FALSE);
  if (!op2->onode && !op1->ocflag)
    return(FALSE);
  temp = p->mo1loc;
  p->mo1loc = p->mo2loc;
  p->mo2loc = temp;
  classops();
  return(TRUE);
}

/* optimize MUL & DIV if constants */

opmd(p)
register struct express *p;
{
  char flag;
  int con;
  register int *cp;

#ifdef ALIGN
  if (op1->otype >= FLOAT)
#else
  if (op1->otype > UNSND)
#endif
    return(FALSE);
  flag = 0;
  cp = p->mo2loc;
#ifdef ALIGN
  if (((*cp>>8) & 0x0f) >= FLOAT)
#else
  if (((*cp>>8) & 0x0f) >= LONG)
#endif
    return(FALSE);
  cp++;
  con = *cp;
  switch (con) {
    case 2:
      flag++;
      *cp = 1;
      break;
    case 4:
      flag++;
      *cp = 2;
      break;
    case 1:
      if (op1->onode)
        p->moprtr = NOP;
      else
        p->moprtr = LOD;
      p->mo2loc = 0;
      p->mttype = op1->otype;
      typechk();
      return(TRUE);
    case 256:
      flag++;
      *cp = 8;
      break;
    case 512:
      flag++;
      *cp = 9;
      break;
    case 8:
      flag++;
      *cp = 3;
      break;
    case 16:
      flag++;
      *cp = 4;
      break;
    case -1:
      p->moprtr = UNM;
      p->mo2loc = 0;
      p->mttype = op1->otype;
      typechk();
      return(TRUE);
    case 0:
      p->moprtr = LOD;
      *cp = 0;
      p->mo1loc = p->mo2loc;
      p->mo2loc = 0;
      p->mttype = op2->otype;
      return(TRUE);
#ifdef ALIGN
    case 32:
      flag++;
      *cp = 5;
      break;
    case 64:
      flag++;
      *cp = 6;
      break;
    case 128:
      flag++;
      *cp = 7;
      break;
#endif
  }
  if (flag)
    if (thisop == MUL)
      p->moprtr = SHL;
    else
      p->moprtr = SHR;
  if (p->moprtr == SHL || p->moprtr == SHR) {
    typechk();
    return(TRUE);
  }
  return(FALSE);
}

/* convert constant in place */

cvcon(oldt, newt, cp)
register int *cp;
{
  int value;

#ifdef ALIGN
  if (oldt==CHR && newt>=SHORT) {
    if (*(cp+1) > 127) {
      *(cp+1) |= 0xffffff00;
    }
  }
  else if (oldt==SHORT && newt>=INT) {
    if ((*(cp+1) & 0xfff) < 0)
      *(cp+1) |= 0xffff0000;
  }
  else if (oldt>=SHORT && newt<SHORT) {
    *(cp+1) &= 0xff;
  }
  else if (oldt>=INT && newt<INT)
    *(cp+1) &= 0xffff;
  value = (newt<<8) | CONST;
  value = (value << 16) | value;
  *cp = value;
#else
  value = *(cp+1);
  if (oldt==CHR && newt>=SHORT) {
    if (value > 127)
      value |= 0xff00;
  }
  else if (oldt>=SHORT && newt<SHORT)
    value &= 0xff;
  *cp = (newt<<8) | CONST;
  *(cp+1) = value;
#endif
}

/* do type conversions for question mark operator */

cvtqum(p2, p1)
register struct express *p1, *p2;
{
  register int t1, t2;
  char pc;

  t1 = p1->mttype;
  t2 = p2->mttype;
  pc = 0;
  if (t1 & 0x30)
    pc |= 1;
  if (t2 & 0x30)
    pc |= 2;
  if (pc) {
    if (pc==3) {
      if ((t1&0xffcf) != (t2&0xffcf))
        return(rptern(93));
    }
    else if (pc == 1) {
      chkzero(p2, t1);
    }
    else
      chkzero(p1, t2);
  }
  else {
/*  if (t1>DUBLE || t2>DUBLE)
      return(rptern(94));  TAKEN OUT 4-26-85 DGS */
    if (t1 == t2)
      return(TRUE);
    if (t1 > t2)
      nodecvt(t1, p2);
    else {
      nodecvt(t2, p1);
      (p1+2)->mttype = t2;
    }
    nxtmat++;
    matlev++;
    t1 = *(tos-1);
    *(tos-1) = ++t1;
  }
  return(TRUE);
}

/* check if node is a LOD zero */

chkzero(p, t)
register struct express *p;
{
  int *ip;

  if (p->moprtr != ENC)
    return(rptern(98));
  if ((unsigned)(p->mo1loc) < 256)
    return(rptern(98));
  if (!isconst(p->mo1loc->stype))
    return(rptern(98));
  ip = p->mo1loc;
  if (*(ip + 1))
    return(rptern(98));
  p->mttype = t;
  return(TRUE);
}

/* check for generation of 'one-zero' result */

onzcheck(ep)
register struct express *ep;
{
  register char op;
  unsigned noden;
  register char lthisop;

  lthisop = thisop;
  if (lthisop==ORC || lthisop==ANC || lthisop==ORB || lthisop==ANB)
    return(FALSE);
/*if (lthisop==CXB)
    return(FALSE);  */
  op = (ep+1)->moprtr;
  if (op == ANE || op == ORE) {
    ep++;
    ep->moprtr -= (ORE-OZF);
    ep->mttype = INT;
    return(TRUE);
  }
  else if (lthisop != CXB) {
    op = ep->moprtr;
    if (op==NOT || (op>=EQU && op<=GRT)) {
      nodecvt(INT, ep);
      ep++;
      ep->moprtr = OZR;
      ep = nxtmat + 1;
      ep->moprtr = 0;
      nxtmat = ep;
      matlev++;
      if (lthisop!=PRM && lthisop!=CBR) {
        noden = (unsigned) (*(tos-1));
        *(tos-1) = ++noden;
      }
      classops();
    }
  }
  return(FALSE);
}

/* find symbol name referenced by op */

struct symtab *findnam(op)
register struct classo *op;
{
  register struct express *ep;
  register struct symtab *sp;
  char flag = 0;

  if (op->onode) {
    ep = &emat[op->onode-1];
    while (1) {
      if (ep->moprtr == DOT)
        break;
      if (ep->moprtr == CVC) {
        sp = &pszsym;
        sp->sstrnum = strnum;
        sp->sstrct = strloc;
        flag++;
/*      return(sp);    */
        break;
      }
      else {
        if ((unsigned)(ep->mo1loc) < 256)
          ep = &emat[(unsigned)(ep->mo1loc)-1];
        else
          break;
      }
    }
    if (flag == 0) {
      if (ep->moprtr == DOT)
        sp = ep->mo2loc;
      else
        sp = ep->mo1loc;
    }
  }
  else
    sp = op->oloc.sym;
  pszsym.stype = op->otype;
  pszsym.sstrct = sp->sstrct;
  pszsym.ssubs = 0;
  namsize = sizeit(&pszsym);
  return(sp);
}

/* put size of structure in expression */

putsize(siz, loc)
int siz, *loc;
{
  register int *cp;

  cp = makone();
  *(cp+1) = siz;
  *loc = cp;
}

/* reorganize expression matrix -
 *    move node lwr through node upr after node aft */

reorg() {
  struct express tmpmat[128];
  register struct express *p;
  register struct express *ep;

  ep = emat;
  movemat(ep+(lwr-1), ep+(upr), tmpmat);
  movemat(ep+(upr), ep+(aft), ep+(lwr-1));
  movemat(tmpmat, &tmpmat[upr-lwr+1], ep+(lwr+aft-upr-1));
  for (p = ep+(lwr-1); p<nxtmat; p++) {
    adjust(&p->mo1loc);
    adjust(&p->mo2loc);
  }
}

/* adjust node numbers after reorganization */

adjust(node)
register unsigned *node;
{
  if (*node>=lwr && *node<=aft) {
    if (*node <= upr)
      *node += (aft-upr);
    else
      *node -= (upr-lwr+1);
  }
}

/* move matrix entries */

movemat(st, end, to)
register char *st, *to;
char *end;
{
  while (st < end)
    *to++ = *st++;
}

/* find start of sub expression */

fndstsub(p)
register struct express *p;
{
/*unsigned m1, m2;  */
  register unsigned *pt;

  upr = (p-emat) + 1;
  for (pt=(tos-2);;pt--) {
    if (pt < astack) {
      lwr = 1;
      break;
    }
    if (*pt < 256) {
      lwr = (*pt+1);
      break;
    }
  }
/*for (;;p--) {
    m1 = p->mo1loc;
    m2 = p->mo2loc;
    if (m1 && m1<256) {
      if (m2 && m2<256 && m2<m1)
        p = &emat[m2];
      else
        p = &emat[m1];
      continue;
    }
    if (m2 && m2<256) {
      p = &emat[m2];
      continue;
    }
    break;
  }
  if (p->moprtr == CAL)
    p = fndspl(p);
  lwr = (p-emat) + 1; */
}

/* get symbol entry with subscript pointer */

int *getsubs() {
  register struct express *p = nxtmat-1;
  register unsigned n;

  while ((n = (unsigned)p->mo1loc) < 256) {
    if (p->moprtr == DOT)
      break;
    p = &emat[n-1];
  }
  if (p->moprtr == DOT)
    return(p->mo2loc->ssubs);
  return(p->mo1loc->ssubs);
}

/* check if constant can be reduced in type */

willfit(typ, cp)
register int *cp;
{
  cp++;
  if (typ==CHR && *cp<128)
    return(1);
  if (typ==SHORT && *cp<0x7fff)
    return(1);
  return(0);
}

