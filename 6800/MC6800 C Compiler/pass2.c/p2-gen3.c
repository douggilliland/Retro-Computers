/*
* This file contains the routines to generate code for conditionals.
* Also, all routines used to simplify branch groups are here.
*/

#include "pass2.h"
#include "il.h"

#define LSREF 6

extern int localv, *orp, *andp, *cndp;
extern int andstk[], orstk[], cndstk[];
extern struct express *dcont;
extern struct addreg *xcont;
extern struct express exptbl[];
extern struct addreg adregs[];
extern int explev, locop1, locop2;
extern int lstlev, curopr, condit;
extern char ccok, unscom, brntyp;
extern int flabnum;
extern char flabtyp, dvalid, sawcnd;
extern int retlab;
extern int stklev, stksiz;

/* Generate code for conditionals */

cnd() {
  struct express *p1;
  register struct addreg *p2;
  struct addreg *p3;
  int type, ref1, ref2;

  p1 = &exptbl[explev];
  p2 = &adregs[locop2 & (NUMADR-1)];
  p3 = &adregs[locop1 & (NUMADR-1)];
  switch(curopr) {
    case EQU:
      condit = EQ;
      break;
    case NEQ:
      condit = NE;
      break;
    case LEQ:
      condit = LE;
      break;
    case LES:
      condit = LT;
      break;
    case GEQ:
      condit = GE;
      break;
    case GRT:
      condit = GT;
      break;
  }
  type = typeop(&p1->op1);
  if (type & UNS)
    ++unscom;
  switch(type & 0xfffe) {
    case CHR:
      if ((locop2 & 0xf0) == DATREG) {
        ref1 = locop1;
        locop1 = locop2;
        locop2 = ref1;
        if (condit > NE) {
          if (condit==LT || condit==LE)
            condit++;
          else
            condit--;
        }
      }
      loadc(locop1);
      finarx(locop2);
      if (!(p2->ar_ref==CREF && *p2->ar_con==0 && ccok)) {
        ++ccok;
        outcode(" cmpb ");
        genadr(locop2 & (NUMADR-1));
      }
      dcont = NULL;
      break;
    case SHORT:
    case INT:
      if ((locop2 & 0xf0) == DATREG) {
        ref1 = locop1;
        locop1 = locop2;
        locop2 = ref1;
        if (condit > NE) {
          if (condit==LT || condit==LE)
            condit++;
          else
            condit--;
        }
      }
      loadi(locop1);
      finarx(locop2);
      if (!(p2->ar_ref==CREF && *p2->ar_con==0 && ccok)) {
        ++ccok;
        if (p2->ar_ref==CREF && *p2->ar_con==0)
          outcode(" addd #0\n");
        else {
          outcode(" cmpd ");
          genadr(locop2 & (NUMADR-1));
        }
      }
      dcont = NULL;
      break;
    case LONG:
      if (p2->ar_ref == LSREF && p3->ar_ref != LSREF) {
        ref1 = locop1;
        locop1 = locop2;
        locop2 = ref1;
        if (condit > NE) {
          if (condit==LT || condit==LE)
            condit++;
          else
            condit--;
        }
      }
      slong(locop1);
      slong(locop2);
      outcode(" jsr cmplong\n");
      stksiz -= 8;
      stklev -= 2;
      ccok++;
      break;
    default:
      ++unscom;
      if (p2->ar_inc) {
        p2->ar_ind++;
        finarx(locop2);
        p2->ar_ind--;
        loadx(locop2 & (NUMADR-1));
      }
      if (p3->ar_inc) {
        p3->ar_ind++;
        finarx(locop1);
        p3->ar_ind--;
      }
      if (p3->ar_ref == (ADRREG|UREG)) {
        if (p3->ar_ind<0 && (p3->ar_off || p3->ar_ofr)) {
          if (ref1 = dcont) {
            if (ref1 < (NUMADR | ARREF)) {
              if (p3 == &adregs[ref1 & (NUMADR-1)])
                dcont = 0;
            }
          }
          loadx(locop1 & (NUMADR-1));
          dcont = ref1;
        }
      }
      if (p2->ar_ref == (ADRREG|UREG)) {
        if (p2->ar_ind<0 && (p2->ar_off || p2->ar_ofr)) {
          if (ref1 = dcont) {
            if (ref1 < (NUMADR | ARREF)) {
              if (p2 == &adregs[ref1 & (NUMADR-1)])
                dcont = 0;
            }
          }
          loadx(locop2 & (NUMADR-1));
          dcont = ref1;
        }
      }
      if (p2->ar_ref == (ADRREG|XREG)) {
        ref1 = locop1;
        locop1 = locop2;
        locop2 = ref1;
        p2 = &adregs[locop2 & (NUMADR-1)];
        p3 = &adregs[locop1 & (NUMADR-1)];
        if (condit > NE) {
          if (condit==LT || condit==LE)
            condit++;
          else
            condit--;
        }
      }
      loadx(locop1 & (NUMADR-1));
      if (!(p2->ar_ref==CREF && *p2->ar_con==0 && ccok)) {
        ++ccok;
        ref1 = p3->ar_ref;
        ref2 = p2->ar_ref;
        if (ref1 == (ADRREG|XREG)) {
          if (ref2==(ADRREG|UREG) && p2->ar_ind<0)
            stacku(locop2);
          outcode(" cmpx ");
        }
        else {
          if (ref2 == (ADRREG|XREG))
            freex();
          outcode(" cmpu ");
        }
        genadr(locop2 & (NUMADR-1));
      }
      xcont = NULL;
      break;
  }
  if (((p1+1)->operator & 0xff) != LBL) {
    sawcnd++;
  }
}

/* Replace conditional and logical ops with branches and labels */

replcnd() {
  int i, x;
  register struct express *p;

  p = &exptbl[0];
  for (i=0; i<lstlev; i++) {
    switch(p->operator & 0xff) {
/*    case CXB:
        putbrf(p, *cndp++ = ++localv);
        break;   */
      case CBR:
/*      x = *(cndp-1);
        putbfl(p, x, *(cndp-1) = ++localv);   */
        putbra(p, *cndp++ = ++localv);
        break;
      case CEN:
        putllb(p, *--cndp);
        break;
      case ORB:
        putbrt(p, *orp++ = ++localv);
        break;
      case ORC:
        putbrt(p, *(orp-1));
        break;
      case ORE:
        putllb(p, *--orp);
        break;
      case ANB:
        putbrf(p, *andp++ = ++localv);
        break;
      case ANC:
        putbrf(p, *(andp-1));
        break;
      case ANE:
        putllb(p, *--andp);
        break;
      case OZT:
        p->op1.opkind.lbl.lnum = *--andp;
        i = finoz(i, p);
        p = &exptbl[i];
        break;
      case OZF:
        p->op1.opkind.lbl.lnum = *--orp;
        i = finoz(i, p);
        p = &exptbl[i];
        break;
    }
    p++;
  }
}

/* Enter conditional branch if true */

putbrt(ptr, label)
int label;
struct express *ptr;
{
  register struct express *p;

  p = ptr;
  clrop(&p->op1);
  p->operator = BRX;
  p->op1.opkind.brx.bxcon = BTRUE;
  p->op1.opkind.brx.bxtyp = LOCLAB;
  p->op1.opkind.brx.bxlnum = label;
}

/* Enter conditional branch if false */

putbrf(ptr, label)
int label;
struct express *ptr;
{
  register struct express *p;

  p = ptr;
  clrop(&p->op1);
  p->operator = BRX;
  p->op1.opkind.brx.bxcon = BFALSE;
  p->op1.opkind.brx.bxtyp = LOCLAB;
  p->op1.opkind.brx.bxlnum = label;
}

/* Enter label */

putllb(ptr, label)
int label;
struct express *ptr;
{
  register struct express *p;

  p = ptr;
  clrop(&p->op1);
  p->operator = LBL;
  p->op1.opkind.lbl.ltype = LOCLAB;
  p->op1.opkind.lbl.lnum = label;
}

/* Enter branch always with label */

putbfl(ptr, lab1, lab2)
int lab1, lab2;
struct express *ptr;
{
  register struct express *p;

  p = ptr;
  clrop(&p->op1);
  p->operator = BLX;
  p->op1.opkind.blx.btype = BALWAYS;
  p->op1.opkind.blx.bltyp1 = LOCLAB;
  p->op1.opkind.blx.blnum1 = lab2;
  p->op1.opkind.blx.bltyp2 = LOCLAB;
  p->op1.opkind.blx.blnum2 = lab1;
}

/* Enter branch always */

putbra(p, lab1)
int lab1;
register struct express *p;
{
  clrop(&p->op1);
  p->operator = BRX;
  p->op1.opkind.brx.bxcon = BALWAYS;
  p->op1.opkind.brx.bxtyp = LOCLAB;
  p->op1.opkind.brx.bxlnum = lab1;
}

/* Clear operand entry at ptr */

clrop(ptr)
char *ptr;
{
  register char *p;
  int i;

  p = ptr;
  for (i=0; i<sizeof(struct operand); i++)
    *p++ = '\0';
}

/* Check if end of conditional */

endofc() {
  int i, x, op;
  register struct express *p;

  for(x=0, p=&exptbl[i=explev+1]; x==0; i++, p++) {
    if (i==lstlev) {
      x++;
      break;
    }
    op = p->operator & 0xff;
    if ((op==BRX || op==BLX) && (p->op1.opkind.brx.bxlnum != retlab
        || p->op1.opkind.brx.bxtyp != REGLAB)) {
      x++;
      break;
    }
    if (op==CMA || op==NOT || op==LBL) {
      x++;
      break;
    }
    if (op!=NOP)
      break;
  }
  return(x);
}

/*
* Simplify branches and labels in expression matrix. Basically
* reductions such as "bne L2 ... L2 lbra L3" converts to
* "lbne L3" are performed.
*/

simpbra() {
  register struct express *p;
  int i;

  for (i=0, p=&exptbl[0]; i<lstlev; i++, p++)
    switch (p->operator & 0xff) {
      case LBL:
        if (((i+1)==lstlev) || (p->op1.opkind.lbl.ltype != LOCLAB))
          break;
        if (((p+1)->operator & 0xff)==LBL)
          p->operator = NOP;
        break;
      case BRX:
        if (redbra(i,p))
          break;
      case BLX:
/*      if (p->op1.opkind.brx.bxtyp == LOCLAB) { */
          p->op1.opkind.brx.bxlnum = fndlbl(p);
          p->op1.opkind.brx.bxtyp = flabtyp;
/*      } */
        if ((p->operator & 0xff) == BLX && ((p+1)->operator & 0xff) == LBL)
          p->operator = BRX;
        break;
    }
}

/* Try to find the label referenced by the current branch */

fndlbl(p)
struct express *p;
{
  register struct express *p2;
  struct express *srchlbl();

  p2 = srchlbl(p, p->op1.opkind.brx.bxlnum, p->op1.opkind.brx.bxtyp);
  if (p2 == NULL)
    return(flabnum);
/*if ((p2->operator & 0xff) != BLX) */
    ++p2;
  if (p2 < &exptbl[lstlev])
    switch (p2->operator & 0xff) {
      case BRX:
      case BLX:
        if (p2->op1.opkind.brx.bxlnum!=retlab
              || p2->op1.opkind.brx.bxtyp!=REGLAB) {
          if (p2->op1.opkind.brx.bxcon == p->op1.opkind.brx.bxcon ||
              p2->op1.opkind.brx.bxcon == BALWAYS) {
            flabnum = p2->op1.opkind.brx.bxlnum;
            flabtyp = p2->op1.opkind.brx.bxtyp;
  /*        if (flabtyp == LOCLAB) */
              fndlbl(p2);
          }
          else {
            if ((p->op1.opkind.brx.bxcon == BTRUE &&
                p2->op1.opkind.brx.bxcon == BFALSE) ||
                (p->op1.opkind.brx.bxcon == BFALSE &&
                p2->op1.opkind.brx.bxcon == BTRUE)) {
              if ((p2->operator & 0xff) != BLX && ((p2+1)->operator & 0xff) != LBL) {
                p2->operator = BLX;
                p2->op1.opkind.blx.bltyp2 = LOCLAB;
                p2->op1.opkind.blx.blnum2 = ++localv;
              }
              if ((p2->operator & 0xff) == BLX) {
                flabnum = p2->op1.opkind.blx.blnum2;
                flabtyp = p2->op1.opkind.blx.bltyp2;
              }
              else {
                flabnum = (p2+1)->op1.opkind.lbl.lnum;
                flabtyp = (p2+1)->op1.opkind.lbl.ltype;
              }
            }
          }
        }
    }
  return(flabnum);
}

/* Search for the label and type specified */

struct express *srchlbl(ptr, lnum, ltyp)
struct express *ptr;
int lnum;
char ltyp;
{
  register struct express *p;
  struct express *p2;
  int i;

  p = ptr;
  p2 = &exptbl[lstlev];
  i = 0;
  flabnum = lnum;
  flabtyp = ltyp;
  while (i == 0 && ++p < p2)
    switch (p->operator & 0xff) {
      case LBL:
        if (p->op1.opkind.lbl.lnum == lnum && p->op1.opkind.lbl.ltype == ltyp)
          i++;
        break;
      case BLX:
        if (p->op1.opkind.blx.blnum2 == lnum && p->op1.opkind.blx.bltyp2 == ltyp)
          i++;
        break;
    }
  if (i==0)
    return(NULL);
  while (((p+1)->operator & 0xff) == LBL)
    p++;
  if ((p->operator & 0xff) == BLX) {
    flabnum = p->op1.opkind.blx.blnum2;
    flabtyp = p->op1.opkind.blx.bltyp2;
  }
  else {
    flabnum = p->op1.opkind.lbl.lnum;
    flabtyp = p->op1.opkind.lbl.ltype;
  }
  return(p);
}

/*
* More branch reductions.  Here we get rid of all code following
* an unconditional branch which cannot be reached.  Also,
* constructs such as "bne L3 . lbra L4 . L3" are changed
* to "lbeq L4".
*/

redbra(i, ptr)
int i;
struct express *ptr;
{
  register struct express *p;
  int j, lnum, ltyp;

  p = ptr;
  if (p->op1.opkind.brx.bxcon == BALWAYS) {
    lnum = p->op1.opkind.brx.bxlnum;
    ltyp = p->op1.opkind.brx.bxtyp;
    i++;
    p++;
    for (j=0; i<lstlev; i++, p++) {
      if ((p->operator & 0xff) == LBL) {
        if (p->op1.opkind.lbl.lnum==lnum && p->op1.opkind.lbl.ltype==ltyp)
          j++;
        break;
      }
      else
        p->operator = NOP;
    }
    if (j) {
      ptr->operator = NOP;
      return(1);
    }
    return(0);
  }
  else {
    j=0;
    i++;
    p++;
    if (i<lstlev) {
      if ((p->operator & 0xff)==BRX && p->op1.opkind.brx.bxcon==BALWAYS) {
        if (p->op1.opkind.brx.bxlnum!=retlab || p->op1.opkind.brx.bxtyp != REGLAB) {
          i++;
          p++;
          if (i<lstlev && (p->operator & 0xff)==LBL) {
            j++;
            lnum = p->op1.opkind.lbl.lnum;
            ltyp = p->op1.opkind.lbl.ltype;
          }
        }
      }
    }
    if (j) {
      p = ptr;
      if (p->op1.opkind.brx.bxlnum==lnum && p->op1.opkind.brx.bxtyp==ltyp) {
        if (p->op1.opkind.brx.bxcon==BTRUE)
          p->op1.opkind.brx.bxcon = BFALSE;
        else
          p->op1.opkind.brx.bxcon = BTRUE;
        p->op1.opkind.brx.bxtyp = (p+1)->op1.opkind.brx.bxtyp;
        p->op1.opkind.brx.bxlnum = (p+1)->op1.opkind.brx.bxlnum;
        (p+1)->operator = NOP;
        return(1);
      }
    }
  }
  return(0);
}

/*
* Find all following ANE and ORE operators and set their
* label numbers from the appropriate stack
*/

finoz(i, p)
int i;
register struct express *p;
{
  for (i++, p++; i<lstlev; i++, p++) {
    if (p->operator == ANE) {
      p->op1.opkind.lbl.lnum = *--andp;
      continue;
    }
    if (p->operator == ORE) {
      p->op1.opkind.lbl.lnum = *--orp;
      continue;
    }
    break;
  }
  return(i-1);
}
