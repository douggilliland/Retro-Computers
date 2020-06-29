/*
* This file has all routines which generate code for special
* IL operators.
*/

#include "pass2.h"
#include "il.h"

extern int locop1, locop2, curtyp;
extern struct addreg adregs[];
extern int stksiz, stklev, revcon;
extern struct addreg *xcont;
extern struct express *dcont;
extern struct express exptbl[];
extern int explev;
extern char ccok, dvalid, sawcnd;
extern char brntyp;
extern int lretlab;
extern int curopr;
extern char enclev;

/* Generate code for the DOT operator */

dot() {
  register struct addreg *p;
  struct addreg *p1;

  ptrloc1();
  p = &adregs[locop2 & (NUMADR-1)];
  p1 = &adregs[locop1 & (NUMADR-1)];
  finar(locop1);
/*p1->ar_ind--;  */
  setoff(*p->ar_con, locop1 & (NUMADR-1));
/*p1->ar_ind++;  */
  p->ar_ref = 0;
  if (curtyp & 0x30) {
    if ((curtyp & 0x30) == (ARAY<<4))
      adregs[locop1 & (NUMADR-1)].ar_ind = -1;
    else
      adregs[locop1 & (NUMADR-1)].ar_chg = 1;
  }
  if (!endofi())
    setrslt(locop1);
  else
    lod();
}

/* Generate code for a function call */

cal() {
  int i;
  register struct addreg *p;
  struct express *ep;

  ++adregs[locop1 & (NUMADR-1)].ar_ind;
  finar(locop1);
  outcode(" jsr ");
  genadr(locop1 & (NUMADR-1));
  ccok = '\0';
  dvalid = '\0';
  if (curtyp & 0x30) {
    ep = &exptbl[explev];
    if (asnend()) {
      ep->rtype = INT;
      (ep+1)->rtype = INT;
      rsltd();
      locop1 = dcont->rslt;
    }
    else if ((ep+1)->operator==CVC && (ep+1)->op1.optype==NNODE
            && (ep+1)->op1.opkind.node.nnum==(explev+1)
            && (ep+1)->rtype==INT) {
      ep->rtype = INT;
      rsltd();
      locop1 = dcont->rslt;
    }
    else {
      p = &adregs[i = getar()];
      xcont = p;
      dcont = 0;
      p->ar_ref = (ADRREG|XREG);
      p->ar_ind = -1;
      setrslt(i | ARREF);
      ccok = 0;
      outcode(" tfr d,x\n");
    }
  }
  else if ((curtyp & 0xfffe) == LONG) {
    p = &adregs[i = getar()];
    xcont = p;
    p->ar_ref = (ADRREG | XREG);
    locop1 = (i | 0x80);
    setrslt(locop1);
    ccok = 0;
  }
  else {
    rsltd();
    locop1 = dcont->rslt;
  }
}

/* Generate call for a function parameter push */

prm() {
  register struct addreg *p;

  switch(curtyp & 0xfffe) {
    case CHR:
      loadc(locop1);
      if (curtyp & UNS)
        outcode(" clra\n");
      else
        outcode(" sex\n");
      ipush();
      break;
    case SHORT:
    case INT:
      loadi(locop1);
      ipush();
      break;
    case LONG:
      slong(locop1);
      ccok = 0;
      break;
    default:
      p = &adregs[locop1 & (NUMADR-1)];
      p->ar_ind++;
      finarx(locop1);
      p->ar_ind--;
      loadx(locop1 & (NUMADR-1));
      stacku(locop1);
      xcont = NULL;
  }
}

/* Generate code for the LOD operator */

lod() {
  switch (curtyp & 0xfffe) {
    case CHR:
      loadc(locop1);
      rsltb();
      break;
    case SHORT:
    case INT:
      loadi(locop1);
      rsltd();
      break;
    case LONG:
      slong(locop1);
      slrslt();
      clnlong();
      ccok = 0;
      break;
    default:
      if (endofc() || curopr==RET)
        loadx(locop1 & (NUMADR-1));
      setrslt(locop1);
      break;
  }
}

/* generate code for ENC op */

enc() {
  register struct addreg *p;

  lod();
  if ((curtyp & 0xfffe) == LONG && (++enclev & 1)) {
    stklev--;
    stksiz -= 4;
  }
  if (curtyp & 0x30) {
    p = &adregs[locop1 & (NUMADR-1)];
    if (p->ar_ref == (ADRREG|UREG)) {
      outcode(" leax 0,u\n");
      p->ar_ref = (ADRREG|XREG);
      p->ar_ind = 0;
      p->ar_chg = 0;
      xcont = p;
    }
  }
}

/* Generate call for a function parameter list */

spl() {
  int slevel, ssize;

  if (xcont)
    freex();
  if (dcont)
    freed();
  slevel = stklev;
  ssize = stksiz;
  ++explev;
  explev = dospr();
  while (exptbl[explev].operator != CAL) {
    doentry();
    explev++;
  }
  doentry();
  if (stksiz - ssize)
    clnstk(stksiz - ssize);
  stksiz = ssize;
  stklev = slevel;
}

spr() {
  badfile();
}

/* Generate code for the comma operator */

cma() {
  xcont = NULL;
  dcont = NULL;
  revcon = 0;
  sawcnd = '\0';
}

/* Traverse a set of function parameters in reverse order */

dospr() {
  int mylev, rlev;
  register struct express *p;

  p = &exptbl[explev];
  if (p->operator==CAL || p->operator==SPL)
    return(explev);
  mylev = ++explev;
  ++p;
  if (p->operator == SPL) {
    skipfun();
    p = &exptbl[explev];
  }
  while (p->operator != PRM) {
    if (p->operator == CAL)
      return(--mylev);
    if (p->operator == SPL) {
      skipfun();
      p = &exptbl[explev];
    }
    else {
      explev++;
      p++;
    }
  }
  explev++;
  rlev = dospr();
  explev = mylev;
  while (exptbl[explev].operator != PRM) {
    doentry();
    explev++;
  }
  doentry();
  return(rlev);
}

/* Skip over a function call in the matrix */

skipfun() {
  register struct express *p;

  p = &exptbl[explev];
  while (p->operator != CAL) {
    explev++;
    if ((++p)->operator == SPL) {
      skipfun();
      p = &exptbl[explev];
    }
  }
  ++explev;
}

/* gen code for OZR operator */

ozr() {
  if (!ccok)
    docmp(explev);
  brntyp = LOCLAB;
  gbrnch(BTRUE, 1);
  outcode(" clra\n clrb\n bra 2f\n1 ldd #1\n2\n");
  ++ccok;
  dvalid = 0;
  rsltd();
}

/* gen code for OZF operator */

ozf() {
  if (!ccok)
    docmp(explev);
  brntyp = LOCLAB;
  gbrnch(BFALSE, 1);
  outcode("%u\n", exptbl[explev].op1.opkind.lbl.lnum);
  gozlabs(ORE, ANE);
  outcode(" ldd #1\n bra 2f\n");
  explev = gozlabs(ANE, ORE);
  outcode("1 clra\n clrb\n2\n");
  ccok++;
  dvalid = 0;
  rsltd();
}

/* gen code for OZT operator */

ozt() {
  if (!ccok)
    docmp(explev);
  brntyp = LOCLAB;
  gbrnch(BTRUE, 1);
  outcode("%u\n", exptbl[explev].op1.opkind.lbl.lnum);
  gozlabs(ANE, ORE);
  outcode(" clra\n clrb\n bra 2f\n");
  explev = gozlabs(ORE, ANE);
  outcode("1 ldd #1\n2\n");
  ccok++;
  dvalid = 0;
  rsltd();
}

/* generate ANE and ORE labels for ozf and ozt ops */

gozlabs(o1, o2) {
  register struct express *p;
  int i;

  i = explev;
  p = &exptbl[i];
  p++;
  while (p->operator==o1 || p->operator==o2) {
    if (p->operator == o1)
      outcode("%u\n", p->op1.opkind.lbl.lnum);
    p++;
    i++;
  }
  return(i);
}

/* generate code for SAV op */

sav() {
  if (xcont)
    freex();
  if (dcont)
    freed();
}

/* generate return code */

ret() {
  if ((curtyp&0xfffe) != LONG) {
    lod();
    if (curtyp & 0x30) {
      if (adregs[locop1 & (NUMADR-1)].ar_ref == (ADRREG|UREG))
        outcode(" tfr u,x\n");
    }
  }
  else {
    slong(locop1);
    if (!lretlab)
      lretlab = genlab();
    outcode(" ldx #L%u\n", lretlab);
    outcode(" jsr asnlong\n");
    ccok = 0;
    stksiz -= 4;
    stklev--;
  }
}
