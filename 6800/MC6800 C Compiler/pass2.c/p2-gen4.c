/*
* This file has the routines to produce code for assignments.
*/

#include "pass2.h"
#include "il.h"

#define LSREF 6

extern int locop1, locop2, explev;
extern char ccok, dvalid;
extern char notdone;
extern char opalong;
extern int curopr, curtyp;
extern int stksiz, stklev;
extern struct addreg *xcont;
extern struct express exptbl[];
extern struct addreg adregs[];

/* Generate code for the assignment operator */

asn() {
  register struct addreg *p;
  register struct addreg *p2;

  switch (curtyp & 0xfffe) {
    case CHR:
      p = &adregs[locop2 & (NUMADR-1)];
      if (endofc() && (p->ar_ref==CREF) && (*p->ar_con==0)) {
        finar(locop1);
        ccok++;
        outcode(" clr ");
        dvalid = '\0';
      }
      else {
        loadc(locop2);
        finar(locop1);
        ccok++;
        outcode(" stb ");
        setdloc(locop1 & (NUMADR-1));
      }
      genadr(locop1 & (NUMADR-1));
      rsltb();
      break;
    case SHORT:
    case INT:
      finar(locop1);
      ccok++;
      loadi(locop2);
      setdloc(locop1 & (NUMADR-1));
      outcode(" std ");
      genadr(locop1 & (NUMADR-1));
      rsltd();
      break;
    case LONG:
      slong(locop2);
      p = &adregs[locop1 & (NUMADR-1)];
      if (p->ar_ref==BREF || p->ar_ref==TREF) {
        outcode(" jsr asnslong\n");
        clnlong();
        if (--stklev)
          stksiz -= 2;
        p->ar_ref = 0;
      }
      else {
        plong(locop1);
        outcode(" jsr asnlong\n");
        clnlong();
        if (xcont) {
          xcont->ar_ref = 0;
          xcont = 0;
        }
      }
      slrslt();
      ccok = 0;
      break;
    default: /* pointer */
      p = &adregs[locop1 & (NUMADR-1)];
      if ((p->ar_ref == (ADRREG | UREG)) && (p->ar_ind == -1)) {
        p2 = &adregs[locop2 & (NUMADR-1)];
        p2->ar_ind++;
        finarx(locop2);
        p2->ar_ind--;
        loadu(locop2 & (NUMADR-1));
        setrslt(locop1);
        break;
      }
      else {
        p2 = &adregs[locop2 & (NUMADR-1)];
        p2->ar_ind++;
        finarx(locop2);
        p2->ar_ind--;
        loadx(locop2 & (NUMADR-1));
        finar(locop1);
        if (adregs[locop2 & (NUMADR-1)].ar_ref == (ADRREG|UREG))
          outcode(" stu ");
        else
          outcode(" stx ");
        genadr(locop1 & (NUMADR-1));
        setrslt(locop2);
      }
      ccok++;
      break;
  }
}

/* Generate code for the op-assignment operators */

opasn() {
  int loc;
  char temp;

  finarx(locop1);
  if (exptbl[explev].rtype & 0x30)
    if (xcont)
      freex();
  if ((curtyp&0xfffe)==LONG && (xcont==adregs+(locop1&NUMADR-1))) {
    if (adregs[locop2&(NUMADR-1)].ar_ref != LSREF) {
      temp = exptbl[explev].operator;
      exptbl[explev].operator = ASN;
      freex();
      exptbl[explev].operator = temp;
    }
    else {
      savex();
    }
  }
  loc = dupop(locop1);
  if (adregs[locop1 & (NUMADR-1)].ar_ref == BREF)
    notdone++;
  if ((curtyp&0xfffe) == LONG) {
    opalong++;
    notdone++;
  }
  switch (curopr) {
    case ADA:
      add();
      break;
    case SUA:
      sub();
      break;
    case MUA:
      mul();
      break;
    case DIA:
      div();
      break;
    case MOA:
      mod();
      break;
    case SRA:
      shr();
      break;
    case SLA:
      shl();
      break;
    case ANA:
      and();
      break;
    case BOA:
      bor();
      break;
    case XOA:
      xor();
      break;
    default:
      badfile();
  }
  locop1 = loc;
  locop2 = exptbl[explev].rslt;
  opalong = 0;
  asn();
}
