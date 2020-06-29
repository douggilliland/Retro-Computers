/*
* This file contains the general code production routines
* such as generation of addresses.
*/

#include "pass2.h"
#include "il.h"

#define LSREF 6

extern struct addreg adregs[];
extern struct express exptbl[];
extern struct express *dcont;
extern struct addreg *xcont;
extern int stklev, stksiz, explev, lstlev;
extern char ccok, dvalid;
extern int incloc, curopr, locop2, locop1;
extern char notdone;
extern char opalong;
extern struct dstruct dloc;

/* Generate an address for the op at loc */

genadr(loc)
int loc;
{
  int i, type;
  int indc, offset;
  char ns[9];
  register struct addreg *aptr;

  aptr = &adregs[loc];
  type = aptr->ar_ref;
  indc = aptr->ar_ind;
  if ((indc < 0) && (!(type & ADRREG)))
    putchar('#');
  else if (indc > 0)
    putchar('[');
  if ((type & 0xf0) == 0) {
    switch(type) {
      case NREF:
        for (i=0; i<8; i++) {
          ns[i] = aptr->ar_data.ad_nam[i];
          aptr->ar_data.ad_nam[i] = '\0';
        }
        ns[8] = '\0';
        outcode("%s", ns);
        break;
      case CREF:
        outcode("%d", *aptr->ar_con + aptr->ar_off);
        aptr->ar_off = 0;
        aptr->ar_con = NULL;
        break;
      case LREF:
        outcode("L%u", aptr->ar_data.ad_val);
        aptr->ar_data.ad_val = 0;
        break;
      case TREF:
        if (!notdone) {
          outcode("0,s++");
          stksiz -= 2;
          --stklev;
          break;
        }
      case BREF:
        outcode("0,s");
        if (!notdone)
          --stklev;
        else
          notdone = 0;
        break;
      default:
        badfile();
    }
    if (aptr->ar_off != 0) {
      outcode("+%d", aptr->ar_off);
      aptr->ar_off = 0;
    }
  }
  else
    switch(type & 0xf0) {
      case ADRREG:
        offset = 0;
        if (aptr->ar_ofr != 0) {
          if (aptr->ar_ofr == OFFB)
            putchar('b');
          else
            putchar('d');
          aptr->ar_ofr = 0;
          dcont = NULL;
        }
        else {
          if (aptr->ar_off != 0) {
            offset = aptr->ar_off;
            aptr->ar_off = 0;
          }
          outcode("%d", aptr->ar_data.ad_val + offset);
        }
        putchar(',');
        if ((i = aptr->ar_inc) < 0)
          do {
            putchar('-');
          } while (++i);
        switch(type & 0x7) {
          case XREG:
            putchar('x');
            xcont = 0;
            break;
          case YREG:
            putchar('y');
            aptr->ar_data.ad_val = 0;
            break;
          case UREG:
            putchar('u');
            break;
        }
        if ((i = aptr->ar_inc) > 0)
          do {
           putchar('+');
          } while (--i);
    }
  if (indc > 0) {
    putchar(']');
    --aptr->ar_ind;
  }
  putchar('\n');
  aptr->ar_ref = 0;
  if (aptr->ar_inc) {
    aptr->ar_inc = 0;
    if ((type & 0x07) == XREG) {
      outcode(" stx ");
      dvalid = '\0';
      if (adregs[incloc & (NUMADR-1)].ar_ref == BREF)
        ++stklev;
      genadr(incloc & (NUMADR-1));
      adregs[incloc & (NUMADR-1)].ar_ref = 0;
    }
    ccok = 0;
  }
}

/* Generate special address for the 'increment' ops.
*  The code to be generated is in opst. */

spcladr(loc, opst)
int loc;
char *opst;
{
  int i;
  struct addreg *temp;
  register struct addreg *p;

  p = &adregs[loc & (NUMADR-1)];
  if ((p->ar_ofr) || (p->ar_ind>0)) {
    --p->ar_ind;
    loadx(loc & (NUMADR-1));
    ++p->ar_ind;
  }
  i = dupop(loc) & (NUMADR-1);
  temp = xcont;
  if (xcont == p)
    xcont = &adregs[i];
  adregs[i].ar_ind--;
  setoff(1, i);
  adregs[i].ar_ind++;
  outcode(opst);
  genadr(i);
  xcont = temp;
}

/* Generate code and addresses for the bit wise operators */

bitadr(code)
char *code;
{
  struct addreg *p, *temp;
  int loc, ref, i;
  
  loc = locop2 & (NUMADR-1);
  p = &adregs[loc];
  if (p->ar_ofr || p->ar_ind>0) {
    --p->ar_ind;
    loadx(loc);
    ++p->ar_ind;
  }
  ref = p->ar_ref;
  if (ref==NREF || ref==LREF || ref==(ADRREG|YREG) ||
      ((ref==(ADRREG|XREG) || ref==(ADRREG|UREG)) && (!p->ar_inc))) {
    i = dupop(locop2) & (NUMADR-1);
    temp = xcont;
    adregs[i].ar_ind--;
    setoff(1, i);
    adregs[i].ar_ind++;
    outcode(" %sa ", code);
    genadr(loc);
    if (xcont==p)
      xcont = &adregs[i];
    outcode(" %sb ", code);
    genadr(i);
    xcont = temp;
  } else if (ref==BREF) {
    outcode(" %sa 0,s\n %sb 1,s\n", code, code);
    --stklev;
  } else if (ref==TREF) {
    outcode(" %sa 0,s+\n %sb 0,s+\n", code, code);
    --stklev;
    stksiz -= 2;
  } else if (ref==(ADRREG|XREG)) {
    xcont = NULL;
    outcode(" %sa 0,x+\n %sb 0,x+\n stx ", code, code);
    genadr(incloc & (NUMADR-1));
    adregs[incloc & (NUMADR-1)].ar_ref = 0;
  } else {
    outcode(" %sa 0,u+\n %sb 0,u+\n", code, code);
  }
  ccok = dvalid = '\0';
}

/* Generate code for an integer load of a data register */

loadi(loc)
int loc;
{
  if (loc & ARREF) {
    if (!(dvalid && dmatch(loc & (NUMADR-1)))) {
      if (dcont && ((dcont != loc) || (curopr >= ADA && curopr <= XOA)))
        freed();
      finar(loc);
      ccok++;
      setdloc(loc & (NUMADR-1));
      if (iszcon(loc & (NUMADR-1)))
        outcode(" clra\n clrb\n");
      else {
        outcode(" ldd ");
        genadr(loc & (NUMADR-1));
      }
    }
  }
}

/* Generate code for a character load of a data register */

loadc(loc)
int loc;
{
  if (loc & ARREF) {
    if (!(dvalid && dmatch(loc & (NUMADR-1)))) {
      if (dcont && ((dcont != loc) || (curopr >= ADA && curopr <= XOA)))
        freed();
      finar(loc);
      ccok++;
      setdloc(loc & (NUMADR-1));
      if (iszcon(loc & (NUMADR-1)))
        outcode(" clrb\n");
      else {
        outcode(" ldb ");
        genadr(loc & (NUMADR-1));
      }
    }
  }
}

/* Generate code for freeing a data register */

freed() {
  int i;
  unsigned temp;
  int oldrslt;
  register struct addreg *p;

  temp = dcont;
  if (temp < (NUMADR | ARREF)) {
    p = &adregs[temp & (NUMADR-1)];
    p->ar_ind--;
    dcont = 0;
    loadx(temp & (NUMADR-1));
    p->ar_ind++;
  }
  else {
    oldrslt = dcont->rslt;
    dcont->rslt = (i=getar()) | ARREF;
    adregs[i].ar_ref = (oldrslt == (DATREG|DREG)) ? ipush() : cpush();
  }
}

/* Generate code for pushing a data register onto the stack */

ipush() {
  dcont = NULL;
  if (stklev++) {
    stksiz += 2;
    outcode(" pshs d\n");
    return(TREF);
  }
  else {
    outcode(" std 0,s\n");
    return(BREF);
  }
}

cpush() {
  dcont = NULL;
  if (stklev++) {
    stksiz++;
    outcode(" pshs b\n");
    return(TREF);
  }
  else {
    outcode(" stb 0,s\n");
    return(BREF);
  }
}

/* Mark the result as being in a data register */

rsltd() {
  dcont = &exptbl[explev];
  exptbl[explev].rslt = DATREG|DREG;
}

rsltb() {
  dcont = &exptbl[explev];
  exptbl[explev].rslt = DATREG|BREG;
}

/* Set the result of an operation */

setrslt(loc)
int loc;
{
  exptbl[explev].rslt = loc;
}

/* Generate code to free an address register */

freex() {
  int inc;

  if (inc = xcont->ar_inc) {
    xcont->ar_inc = 0;
    outcode(" leax %d,x\n stx ", inc);
    dvalid = 0;
    genadr(incloc & (NUMADR-1));
    adregs[incloc & (NUMADR-1)].ar_ref = 0;
    if (xcont->ar_pre == 0)
      setoff(-inc, xcont - adregs);
    xcont->ar_pre = 0;
  }
  if (xcont->ar_ind>0 || xcont->ar_off!=0 || xcont->ar_ofr!=0) {
    --xcont->ar_ind;
    loadx(xcont - adregs);
    ++xcont->ar_ind;
  }
  if (curopr==PRM || xtype() != LONG) {
    if (dcont)
      freed();
    xcont->ar_ref = xpush();
    xcont->ar_ind++;
    xcont = NULL;
  }
  else {
    outcode(" jsr pshlong\n");
    xcont->ar_ref = LSREF;
    xcont = 0;
  }
}

/* Generate code to push an address register onto the stack */

xpush() {
  if (stklev++) {
    stksiz += 2;
    outcode(" pshs x\n");
    return(TREF);
  }
  else {
    outcode(" stx 0,s\n");
    return(BREF);
  }
}

/* Generate code to push the U register onto the stack */

stacku(loc) {
  register struct addreg *p;

  p = &adregs[loc & (NUMADR-1)];
  if (p->ar_ind>0 || p->ar_off!=0 || p->ar_ofr!=0) {
    p->ar_ind--;
    loadx(loc & (NUMADR-1));
    p->ar_ind++;
  }
  if (p->ar_ref == (ADRREG|XREG))
    freex();
  else {
    p->ar_ref = upush();
    p->ar_ind++;
  }
}

upush() {
  if (stklev++) {
    stksiz += 2;
    outcode(" pshs u\n");
    return(TREF);
  }
  else {
    outcode(" stu 0,s\n");
    return(BREF);
  }
}

/* Clean up stack code generation */

clnstk(size)
int size;
{
  outcode(" leas %d,s\n", size);
}

/* Generate code to clean 2 bytes off stack */

clntwo() {
  if (--stklev != 0) {
    stksiz -= 2;
    outcode(" leas 2,s\n");
  }
}

/* Test if current matrix level is the end of the expression */

endofx() {
  int i, x, op;
  register struct express *p;

  for(x=0, p=&exptbl[i=explev+1]; x==0; i++, p++) {
    if (i==lstlev) {
      x++;
      break;
    }
    op = p->operator & 0xff;
    if ((op==BRX || op==BLX) && (p->op1.opkind.brx.bxcon == BALWAYS)) {
      x++;
      break;
    }
    if (op == CMA) {
      x++;
      break;
    }
    if (op!=NOP && op != LBL)
      break;
  }
  return(x);
}

/* Find the type of operand at opptr */

typeop(opptr)
struct operand *opptr;
{
  switch(opptr->optype & 0xff) {
    case NNODE:
      return(exptbl[opptr->opkind.node.nnum-1].rtype);
    case NCON:
      return(opptr->opkind.cons.ctype & 0xff);
    case NNAME:
      return(opptr->opkind.name.ntype);
  }
}

/* Set the location of the contents of the data register */

setdloc(loc)
int loc;
{
  register struct addreg *p;
  char *pc1, *pc2;
  int ref, i;

  dvalid = '\0';
  p = &adregs[loc];
  ref = p->ar_ref;
  if (ref==(ADRREG|YREG) || ref==NREF || ref==CREF || ref==LREF)
    if (p->ar_off==0 && p->ar_ind==0 && p->ar_ofr==0 && p->ar_inc==0) {
      dvalid++;
      dloc.d_ref = ref;
      switch (ref) {
        case CREF:
          dloc.d_data.d_val = *p->ar_con;
          break;
        case NREF:
          pc1 = p->ar_data.ad_nam;
          pc2 = dloc.d_data.d_name;
          for (i=0; i<8; i++)
            *pc2++ = *pc1++;
          break;
        default:
          dloc.d_data.d_val = p->ar_data.ad_val;
          break;
      }
    }
}

/* Check if 'loc' is the same as that of the contents of the data register */

dmatch(loc)
int loc;
{
  register struct addreg *p;
  int i;
  char *pc1, *pc2;

  if (dcont)
    return(0);
  p = &adregs[loc];
  if (p->ar_ref == dloc.d_ref)
    if (p->ar_off==0 && p->ar_ind==0 && p->ar_ofr==0 && p->ar_inc==0)
      switch (dloc.d_ref) {
        case CREF:
          if (*p->ar_con == dloc.d_data.d_val)
            return(1);
          else
            return(0);
        case LREF:
        case (ADRREG|YREG):
          if (p->ar_data.ad_val == dloc.d_data.d_val)
            return(1);
          else
            return(0);
        case NREF:
          pc1 = dloc.d_data.d_name;
          pc2 = p->ar_data.ad_nam;
          for (i=0; i<8; i++)
            if (*pc1++ != *pc2++)
              break;
          return(i==8);
      }
  return(0);
}

/* set long result */

slrslt() {
  int i;
  register struct addreg *p;

  p = &adregs[i=getar()];
  p->ar_ref = LSREF;
  setrslt(0x80 | i);
}

/* set up long value on stack */

slong(loc) {
  register struct addreg *p;
  int temp;

  p = &adregs[loc & (NUMADR-1)];
  if (p->ar_ref != LSREF) {
    if (p->ar_ref == CREF) {
      temp = *(p->ar_con);
      *p->ar_con = *(p->ar_con+1);
      if (*p->ar_con == 0)
        outcode(" clra\n clrb\n");
      else
        loadi(loc);
      outcode(" pshs d\n");
      dcont = 0;
      *p->ar_con = temp;
      p->ar_ref = CREF;
      if (temp != *(p->ar_con+1))
        if (temp == 0)
          outcode(" clra\n clrb\n");
        else
          loadi(loc);
      outcode(" pshs d\n");
      dcont = 0;
    }
    else {
      finarx(loc);
      p->ar_ind--;
      loadx(loc & (NUMADR-1));
      xcont = 0;
      outcode(" jsr pshlong\n");
    }
    p->ar_ref = 0;
    ++stklev;
    stksiz += 4;
    return(0);
  }
  return(1);
}

/* point to long value with x code generation */

plong(loc) {
  register struct addreg *p;

  p = &adregs[loc & (NUMADR-1)];
  if (p->ar_ref != LSREF) {
    finarx(loc);
    p->ar_ind--;
    loadx(loc & (NUMADR-1));
  }
}

/* find type referenced by x register */

xtype() {
  register struct express *ep;
  int loc;

  loc = (xcont - adregs) | 0x80;
  for (ep = &exptbl[explev]; ep>= exptbl; ep--) {
    if (loc == ep->rslt)
      if (ep->rtype == LONG)
        return(chasn(ep));
      else
        return(0);
  }
  return(0);
}

/* check if long reference is left op of assign */

chasn(ep)
register struct express *ep;
{
  int node;
  int lev;

  node = lev = node = (ep - exptbl)+1;
  for (ep++; lev <= explev; lev++, ep++) {
    if ((ep->op1.optype & 0xff) == NNODE) {
      if (node == ep->op1.opkind.node.nnum) {
        if (ep->operator == ASN)
          return(0);
        else
          return(LONG);
      }
    }
  }
  return(LONG);
}

/* check for end of sub expression */

endofsub() {
  int x, i, op;
  register struct express *p;

  if (opalong)
    return(0);
  for (x=0, p=&exptbl[i=explev+1]; x==0; i++, p++) {
    if (i == lstlev) {
      x++;
      break;
    }
    op = p->operator & 0xff;
    if ((op==BRX || op==BLX) && (p->op1.opkind.brx.bxcon == BALWAYS)) {
      x++;
      break;
    }
    if (op==CMA) {
      x++;
      break;
    }
    if (op == LBL)
      continue;
    if (op != NOP)
      break;
  }
  return(x);
}

/* clean long off stack if end of subexpression */

clnlong() {
  if (curopr!=ENC && endofsub()) {
    stksiz -= 4;
    stklev--;
    clnstk(4);
  }
}

/* special clean long */

sclnlong() {
  stksiz -= 4;
  stklev--;
  clnlong();
}

/* save x in temp location - used for long opasn */

savex() {
  int i;

  xcont->ar_ind--;
  loadx(xcont - adregs);
  outcode(" stx ltemp\n");
  xcont->ar_ref = NREF;
  for (i=0; i<6; i++)
    xcont->ar_data.ad_nam[i] = "ltemp"[i];
  xcont->ar_ind = 1;
  xcont = 0;
}

/* test for zero constant at loc */

iszcon(loc) {
  register struct addreg *p;

  p = &adregs[loc];
  if (p->ar_ref==CREF && *p->ar_con==0)
    return(1);
  return(0);
}
