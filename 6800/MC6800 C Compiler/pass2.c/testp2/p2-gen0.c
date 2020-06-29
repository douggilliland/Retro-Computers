/*
* This file contains code generation routines for nop, cvt,
* branches, and labels.
*/

#include "pass2.h"
#include "il.h"

extern int locop1, locop2, condit;
extern char ccok, brntyp, unscom, dvalid;
extern struct express exptbl[];
extern struct addreg adregs[];
extern int explev, revcon;
extern struct express *dcont;
extern struct addreg *xcont;
extern char *bar1[], *bar2[], *bar3[], *bar4[];
extern int curtyp, curopr;
extern char sawcnd;
extern int lstlev;
extern int stklev, stksiz;
extern char optb;

/* Process nop operator */

nop() {
  setrslt(exptbl[explev-1].rslt);
  if (dcont == &exptbl[explev-1])
    dcont = &exptbl[explev];
}

/* Generate code for conversions */

cvt() {
  int type;
  int i;

  type = typeop(&exptbl[explev].op1);
  dvalid = '\0';
  switch (curtyp & 0xfffe) {
    case CHR:
      switch (type & 0xfffe) {
        case CHR:
          loadc(locop1);
          rsltb();
          break;
        case SHORT:
        case INT:
          loadi(locop1);
          rsltb();
          break;
        case LONG:
          slong(locop1);
          outcode(" ldb 3,s\n leas 4,s\n");
          stksiz -= 4;
          stklev--;
          rsltb();
          ccok++;
          break;
        default:
          tfrxd();
          rsltb();
          break;
      }
      break;
    case SHORT:
    case INT:
      switch (type & 0xfffe) {
        case CHR:
          loadc(locop1);
          if (type & UNS)
            outcode(" clra\n");
          else
            outcode(" sex\n");
          rsltd();
          break;
        case SHORT:
        case INT:
          loadi(locop1);
          rsltd();
          break;
        case LONG:
          slong(locop1);
          outcode(" ldd 2,s\n leas 4,s\n");
          stksiz -= 4;
          stklev--;
          rsltd();
          ccok++;
          break;
        default:
          if (asnend()) {
            setrslt(locop1);
            exptbl[explev].rtype = type;
            exptbl[explev+1].rtype = type;
          }
          else
            tfrxd();
          break;
      }
      break;
    case LONG:
      switch(type & 0xfffe) {
        case CHR:
          loadc(locop1);
          if (type & UNS)
            outcode(" clra\n");
          else
            outcode(" sex\n");
          oitol(type);
          slrslt();
          break;
        case SHORT:
        case INT:
          loadi(locop1);
          oitol(type);
          slrslt();
          break;
        case LONG:
          setrslt(locop1);
          break;
        default:
          tfrxd();
          oitol(INT);
          slrslt();
          break;
      }
      break;
    default:
      switch (type & 0xfffe) {
        case CHR:
          tfrdx(type);
          break;
        case SHORT:
        case INT:
          if (asnend()) {
            setrslt(locop1);
            exptbl[explev].rtype = type;
            exptbl[explev+1].rtype = type;
          }
          else
            tfrdx(type);
          break;
        case LONG:
          if (xcont)
            freex();
          slong(locop1);
          outcode(" ldx 2,s\n leas 4,s\n");
          stksiz -= 4;
          stklev--;
          i = getar();
          adregs[i].ar_ref = ADRREG|XREG;
          adregs[i].ar_ind = -1;
          setrslt(i | ARREF);
          ccok++;
          break;
        default:
          setrslt(locop1);
          break;
      }
      break;
  }
}

/* Generate code for forced comparisons */

docmp(lev)
int lev;
{
  int tp;

  unscom = '\0';
  tp = exptbl[lev-1].rtype;
  if (tp & UNS)
    unscom++;
  ccok++;
  switch (tp & 0xfffe) {
    case CHR:
      outcode(" tstb\n");
      break;
    case SHORT:
    case INT:
      outcode(" addd #0\n");
      break;
    case LONG:
      slong(exptbl[lev-1].rslt);
      outcode(" jsr tstlong\n");
      stksiz -= 4;
      stklev--;
      ccok++;
      break;
    default:
      if (adregs[exptbl[lev-1].rslt & (NUMADR-1)].ar_ref == (ADRREG|UREG))
        outcode(" cmpu #0\n");
      else
        outcode(" cmpx #0\n");
      break;
  }
}

/* Generate code for BRX operator */

brx() {
  register struct operand *p;

  p = &exptbl[explev].op1;
  sawcnd = '\0';
  dcont = xcont = NULL;
  if ((ccok==0) && (p->opkind.brx.bxcon != BALWAYS)) {
    docmp(explev);
  }
  brntyp = p->opkind.brx.bxtyp;
  gbrnch(p->opkind.brx.bxcon, p->opkind.brx.bxlnum);
  if (p->opkind.brx.bxcon != BALWAYS)
    sawcnd++;
  if (curopr == BRX) {
    explev++;
    dolabs();
  }
  exptbl[explev].rtype = exptbl[explev-1].rtype;
  ccok = 0;
  nop();
}

/* Generate code for BLX operator */

blx() {
  register struct operand *p;

  p = &exptbl[explev].op1;
  brx();
  dvalid = '\0';
  if (p->opkind.blx.bltyp2 == LOCLAB)
    outcode("%u\n", p->opkind.blx.blnum2);
  else
    outcode("L%u\n", p->opkind.blx.blnum2);
  explev++;
  dolabs();
  exptbl[explev].rtype = exptbl[explev-1].rtype;
  ccok = 0;
  nop();
}

/* Generate code for labels */

lbl() {
  register struct express *p;

  p = &exptbl[explev];
  dvalid = '\0';
  while ((p->operator & 0xff) == LBL) {
    if (p->op1.opkind.lbl.ltype == LOCLAB)
      outcode("%u\n", p->op1.opkind.lbl.lnum);
    else
      outcode("L%u\n", p->op1.opkind.lbl.lnum);
    p++;
    exptbl[explev].rtype = exptbl[explev-1].rtype;
    nop();
    explev++;
  }
  explev--;
}

/* Generate all labels immediately following current op */

dolabs() {
  register struct express *p;

  p = &exptbl[explev];
  while ((p->operator & 0xff) == LBL) {
    if (p->op1.opkind.lbl.ltype == LOCLAB)
      outcode("%u\n", p->op1.opkind.lbl.lnum);
    else
      outcode("L%u\n", p->op1.opkind.lbl.lnum);
    p++;
    exptbl[explev].rtype = exptbl[explev-1].rtype;
    nop();
    explev++;
    dvalid = '\0';
  }
  explev--;
}

/* Routine to generate a conditional branch */

gbrnch(type, label)
char type;
int label;
{
  char ttyp;

  ttyp = brntyp;
  if (optb == 0)
    brntyp = REGLAB;
  if(((type==BTRUE)&&(!revcon))||((type==BFALSE)&&revcon))
    outcode("%s%s ",(brntyp==REGLAB)?" l":" ", unscom?bar3[condit]:bar1[condit]);
  else if (type != BALWAYS)
    outcode("%s%s ",(brntyp==REGLAB)?" l":" ", unscom?bar4[condit]:bar2[condit]);
  else
    outcode("%sbra ",(brntyp == REGLAB) ? " l" : " ");
  brntyp = ttyp;
  if (brntyp == LOCLAB)
    outcode("%uf\n", label);
  else
    outcode("L%u\n", label);
  condit = NE;
  revcon = 0;
}

/* Generate pointer to integral data type conversion */

tfrxd() {
  int loc;
  register struct addreg *p;

  p = &adregs[locop1 & (NUMADR-1)];
  p->ar_ind++;
  finarx(locop1);
  p->ar_ind--;
  loc = p->ar_ref;
  dvalid = '\0';
  if (loc==(ADRREG|XREG) || loc==(ADRREG|UREG) || p->ar_ind) {
    loadx(locop1 & (NUMADR-1));
    loc = p->ar_ref;
    if (dcont)
      freed();
    if (loc == (ADRREG|UREG)) {
      outcode(" tfr u,d\n");
      ccok = '\0';
    }
    else {
      outcode(" tfr x,d\n");
      ccok = '\0';
      xcont = NULL;
    }
  }
  else {
    loadi(locop1);
  }
  rsltd();
}

/* Generate integral to pointer data type conversion */

tfrdx(type) {
  int i;

  if (curopr!=CAL && (locop1 & ARREF) && (type >= SHORT)) {
    finarx(locop1);
    loadx(locop1 & (NUMADR-1));
    adregs[locop1 & (NUMADR-1)].ar_ind = -1;
/* used to be ind++    ????????????????   */
    setrslt(locop1);
  }
  else {
    if (xcont)
      freex();
    if (type < SHORT) {
      loadc(locop1);
      if (type & UNS)
        outcode(" clra\n");
      else
        outcode(" sex\n");
    }
    else
      loadi(locop1);
    outcode(" tfr d,x\n");
    dcont = NULL;
    i = getar();
    adregs[i].ar_ref = ADRREG|XREG;
    adregs[i].ar_ind = -1;
    xcont = &adregs[i];
    setrslt(i | ARREF);
    ccok = '\0';
  }
}

/* output code to convert int to long */

oitol(type) {
  outcode(" pshs d\n");
  if (type & UNS)
    outcode(" clra\n clrb\n pshs d\n");
  else {
    if (!ccok)
      outcode(" tsta\n");
    outcode(" bmi 1f\n clra\n clrb\n bra 2f\n1 ldd #$ffff\n2 pshs d\n");
  }
  stksiz += 4;
  stklev++;
  dvalid = 0;
  dcont = 0;
  ccok = 0;
}

/* check if rest of expression is just an assignment */

asnend() {
  register struct express *p;
  int op;

  p = &exptbl[explev+1];
  if (explev+1 == lstlev)
    return(0);
  if (p->operator != ASN)
    return(0);
  if ((p->op1.optype&0xff)==NNAME && p->op1.opkind.name.nclass==REG)
    return(0);
  if (explev+2 == lstlev)
    return(1);
  op = (++p)->operator & 0xff;
  if (op==BRX || op==BLX || op==LBL || op==CMA)
    return(1);
  return(0);
}
