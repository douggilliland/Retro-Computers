/*
* This file contains the routines to generate code for the
* unary operators.
*/

#include "pass2.h"
#include "il.h"

extern struct addreg adregs[];
extern struct express exptbl[];
extern int locop1, locop2, explev;
extern int curopr, curtyp;
extern char ccok, unscom, brntyp, dvalid;
extern int lstlev, revcon;
extern char sawcnd;
extern struct addreg *xcont;
extern int stksiz, stklev;

/* Generate code for the FPP operator */

fpp() {
  register struct addreg *p;
  int i;

  if (curtyp & UNS)
    unscom++;
  switch(curtyp & 0xfffe) {
    case CHR:
      finar(locop1);
      if (endofc())
        i=0;
      else
        i=dupop(locop1);
      ccok++;
      dvalid = '\0';
      outcode(" inc ");
      genadr(locop1 & (NUMADR-1));
      if (i) {
        ccok++;
        outcode(" ldb ");
        genadr(i & (NUMADR-1));
      }
      rsltb();
      break;
    case SHORT:
    case INT:
      if (endofx()) {
        finar(locop1);
        spclinc();
      }
      else {
        curopr = ADA;
        opasn();
      }
      break;
    case LONG:
      plong(locop1);
      outcode(" jsr inclong\n");
      if (!endofsub()) {
        slong(locop1);
        slrslt();
      }
      else {
        xcont->ar_ref = 0;
        xcont = 0;
      }
      ccok = 0;
      break;
    default:
      p = &adregs[locop1 & (NUMADR-1)];
      if (p->ar_ref == (ADRREG | XREG))
        freex();
      p->ar_inc = *adregs[locop2 & (NUMADR-1)].ar_con;
      p->ar_pre++;
      if ( needval() || ((p->ar_ind > 0) && (p->ar_ref != (ADRREG | XREG)))) {
        p->ar_ind++;
        finarx(locop1);
        p->ar_ind--;
      }
      setrslt(locop1);
  }
}

/* Generate code for the FMM operator */

fmm() {
  register struct addreg *p;
  int i;

  if (curtyp & UNS)
    unscom++;
  switch(curtyp & 0xfffe) {
    case CHR:
      finar(locop1);
      if (endofc())
        i=0;
      else
        i=dupop(locop1);
      ccok++;
      dvalid = '\0';
      outcode(" dec ");
      genadr(locop1 & (NUMADR-1));
      if (i) {
        ccok++;
        outcode(" ldb ");
        genadr(i & (NUMADR-1));
      }
      rsltb();
      break;
    case SHORT:
    case INT:
      curopr = SUA;
      opasn();
      break;
    case LONG:
      plong(locop1);
      outcode(" jsr declong\n");
      if (!endofsub()) {
        slong(locop1);
        slrslt();
      }
      else {
        xcont->ar_ref = 0;
        xcont = 0;
      }
      ccok = 0;
      break;
    default:
      p = &adregs[locop1 & (NUMADR-1)];
      if (p->ar_ref == (ADRREG | XREG))
        freex();
      p->ar_inc = -(*adregs[locop2 & (NUMADR-1)].ar_con);
      p->ar_pre++;
      if ( needval() || ((p->ar_ind > 0) && (p->ar_ref != (ADRREG | XREG)))) {
        p->ar_ind++;
        finarx(locop1);
        p->ar_ind--;
      }
      setrslt(locop1);
      break;
  }
}

/* Generate code for the BPP operator */

bpp() {
  register struct addreg *p;
  struct express *p2;
  int i;

  if (curtyp & UNS)
    unscom++;
  switch(curtyp & 0xfffe) {
    case CHR:
      if (!endofx()) {
        i = dupop(locop1);
        loadc(locop1);
        locop1 = i;
      }
      else
        finar(locop1);
      outcode(" inc ");
      genadr(locop1 & (NUMADR-1));
      ccok = '\0';
      dvalid = '\0';
      rsltb();
      break;
    case SHORT:
    case INT:
      if (!endofx()) {
        i = dupop(locop1);
        loadi(locop1);
        locop1 = i;
      }
      else
        finar(locop1);
      spclinc();
      break;
    case LONG:
      if (!endofsub()) {
        slong(locop1);
        slrslt();
      }
      else {
        plong(locop1);
        xcont->ar_ref = 0;
        xcont = 0;
      }
      outcode(" jsr inclong\n");
      ccok = 0;
      break;
    default:
      p = &adregs[locop1 & (NUMADR-1)];
      if (p->ar_ref == (ADRREG|XREG))
        freex();
      p->ar_inc = *adregs[locop2 & (NUMADR-1)].ar_con;
      if ( needval() || ((p->ar_ind > 0) && (p->ar_ref != (ADRREG|XREG)))) {
        p->ar_ind++;
        finarx(locop1);
        p->ar_ind--;
        ccok = '\0';
        p2 = &exptbl[explev+1];
        if ((explev+1 != lstlev) && (((p2->operator & 0xff) == BLX)
            || ((p2->operator & 0xff) == BRX)) && (p2->op1.opkind.brx.bxcon != BALWAYS))
          loadx(locop1 & (NUMADR-1));
      }
      setrslt(locop1);
      break;
  }
}

/* Generate code for the BMM operator */

bmm() {
  register struct addreg *p;
  struct express *p2;
  int i;

  if (curtyp & UNS)
    unscom++;
  switch(curtyp & 0xfffe) {
    case CHR:
      if (!endofx()) {
        i = dupop(locop1);
        loadc(locop1);
        locop1 = i;
      }
      else
        finar(locop1);
      outcode(" dec ");
      genadr(locop1 & (NUMADR-1));
      ccok = '\0';
      dvalid = '\0';
      rsltb();
      break;
    case SHORT:
    case INT:
      if (!endofx()) {
        i = dupop(locop1);
        loadi(locop1);
        locop1 = i;
      }
      else
        finar(locop1);
      spcladr(locop1, " tst ");
      outcode(" bne 1f\n dec ");
      i = dupop(locop1);
      genadr(locop1 & (NUMADR-1));
      spcladr(i, "1 dec ");
      ccok = '\0';
      dvalid = '\0';
      rsltd();
      break;
    case LONG:
      if (!endofsub()) {
        slong(locop1);
        slrslt();
      }
      else {
        plong(locop1);
        xcont->ar_ref = 0;
        xcont = 0;
      }
      outcode(" jsr declong\n");
      ccok = 0;
      break;
    default:
      p = &adregs[locop1 & (NUMADR-1)];
      if (p->ar_ref == (ADRREG|XREG))
        freex();
      p->ar_inc = -(*adregs[locop2 & (NUMADR-1)].ar_con);
      if ( needval() || ((p->ar_ind > 0) && (p->ar_ref != (ADRREG|XREG)))) {
        p->ar_ind++;
        finarx(locop1);
        p->ar_ind--;
        ccok = '\0';
        p2 = &exptbl[explev+1];
        if ((explev+1 != lstlev) && (((p2->operator & 0xff) == BLX)
            || ((p2->operator & 0xff) == BRX)) && (p2->op1.opkind.brx.bxcon != BALWAYS))
          loadx(locop1 & (NUMADR-1));
      }
      setrslt(locop1);
      break;
  }
}

/* Generate code for the NOT operator */

not() {
  if ((curtyp & 0xfffe) == LONG) {
    slong(locop1);
    outcode(" jsr tstlong\n");
    stksiz -= 4;
    stklev--;
    ccok++;
  }
  else
    lod();
  revcon = !revcon;
  sawcnd++;
}

/* Generate code for the ADR operator */

adr() {
  --adregs[locop1 & (NUMADR-1)].ar_ind;
  setrslt(locop1);
}

/* Generate code for the indirection operator */

ino() {
  int ar;
  register struct addreg *p;

  ar = locop1 & (NUMADR-1);
  p = &adregs[ar];
  finarx(locop1);
  if ((curtyp & 0x30) != (ARAY<<4)) {
    if (p->ar_ind > 0)
      loadx(ar);
    ++p->ar_ind;
    if ((curtyp & 0x30) == (PTR<<4))
      finarx(locop1);
    ++p->ar_chg;
  }
  if (!endofi())
    setrslt(locop1);
  else
    lod();
}

/* Generate code for the unary minus operator */

unm() {
  dvalid = '\0';
  switch (curtyp & 0xfffe) {
    case CHR:
      loadc(locop1);
      outcode(" negb\n");
      ccok++;
      rsltb();
      break;
    case SHORT:
    case INT:
      loadi(locop1);
      outcode(" nega\n negb\n sbca #0\n");
      ccok = '\0';
      rsltd();
      break;
    case LONG:
      slong(locop1);
      outcode(" jsr neglong\n");
      slrslt();
      clnlong();
      ccok = 0;
      break;
  }
}

/* Generate code for the compliment operator */

com() {
  dvalid = '\0';
  switch (curtyp & 0xfffe) {
    case CHR:
      loadc(locop1);
      outcode(" comb\n");
      ccok++;
      rsltb();
      break;
    case SHORT:
    case INT:
      loadi(locop1);
      outcode(" comb\n coma\n");
      ccok = '\0';
      rsltd();
      break;
    case LONG:
      slong(locop1);
      outcode(" jsr comlong\n");
      slrslt();
      clnlong();
      ccok = 0;
      break;
  }
}

/* Generate code for special inc and dec operations */

spclinc() {
  int i;
  register struct express *p;

  i = 0;
  spcladr(locop1, " inc ");
  dvalid = '\0';
  p = &exptbl[explev+1];
  if ((explev+1 != lstlev) && ((p->operator & 0xff) == BRX)
      && (p->op1.opkind.brx.bxcon == BALWAYS)) {
    unscom = 0;
    revcon = 0;
    brntyp = p->op1.opkind.brx.bxtyp;
    gbrnch(BTRUE, p->op1.opkind.brx.bxlnum);
    i++;
  }
  else {
    outcode(" bne 1f\n");
  }
  outcode(" inc ");
  genadr(locop1 & (NUMADR-1));
  if (!i)
    outcode("1\n");
  ccok = '\0';
  rsltd();
}

/* check for end of indirection expression */

endofi() {
  int i, x, op;
  register struct express *p;

  for(x=0, p=&exptbl[i=explev+1]; x==0; i++, p++) {
    if (i==lstlev) {
      x++;
      break;
    }
    op = p->operator & 0xff;
    if (op==BRX || op==BLX) {
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

/* check if need value from ++ or -- op */

needval() {
  register struct express *p;
  struct addreg *ap;
  int op;

  if (endofc())
    return(1);
  ap = &adregs[locop1 & (NUMADR-1)];
  if ((curtyp & 0x30)==(PTR << 4) && ap->ar_ref==(ADRREG|UREG) && ap->ar_chg)
    return(1);
  p = &exptbl[explev+1];
  while (p != &exptbl[lstlev]) {
    if ((p->op1.optype&0xff)==NNODE) {
      if (p->op1.opkind.node.nnum == (explev+1)) {
        op = p->operator & 0xff;
        if (op==ADD || op==SUB)
          return(1);
        else
          return(0);
      }
    }
    if ((p->op2.optype&0xff)==NNODE) {
      if (p->op2.opkind.node.nnum == (explev+1)) {
        op = p->operator & 0xff;
        if (op==ADD || op==SUB)
          return(1);
        else
          return(0);
      }
    }
    p++;
  }
  return(0);
}
