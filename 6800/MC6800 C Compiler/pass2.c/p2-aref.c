#include "il.h"
#include "pass2.h"

extern int curopr, locop1, locop2, incloc;
extern struct addreg adregs[];
extern struct express *dcont;
extern struct addreg *xcont;
extern char ccok, dvalid;
extern int stklev;
extern int curtyp;

loadx(ar)
int ar;
{
  register struct addreg *p;
  int ref;
  int temp;

  p = &adregs[ar];
  ref = p->ar_ref;
  if ((ref==(ADRREG|XREG) || ref==(ADRREG|UREG)) && p->ar_ind<=0 && p->ar_off==0 && p->ar_ofr==0 && p->ar_chg == 0)
    return;
  ccok++;
  if (xcont != NULL && xcont != &adregs[ar]) {
    temp = 0;
    if (dcont && adregs[ar].ar_ofr) {
      temp = dcont;
      dcont = 0;
    }
    freex();
    if (temp)
      dcont = temp;
  }
  if (p->ar_ind < 0 && (ref & ADRREG)) {
    outcode(" leax ");
/*  p->ar_ind = 0; */
    ccok = '\0';
  }
  else {
    outcode(" ldx ");
    p->ar_chg = 0;
  }
  genadr(ar);
  if (p->ar_ind >= 0)
    p->ar_ind--;
  p->ar_ref = ADRREG|XREG;
  xcont = p;
}

loadu(ar)
int ar;
{
  register struct addreg *p;

  p = &adregs[ar];
  ccok++;
  if ((p->ar_ind < 0) && (p->ar_ref & ADRREG)) {
    p->ar_ind = 0;
    outcode(" leau ");
    ccok = '\0';
  }
  else
    outcode(" ldu ");
  genadr(ar);
}

setoff(offset, ar)
int offset;
int ar;
{
  register struct addreg *p;

  p = &adregs[ar];
  if (p->ar_ofr) {
    if (curopr == DOT) {
      --p->ar_ind;
      loadx(ar);
      ++p->ar_ind;
    }
    else
      loadx(ar);
    p->ar_off = offset;
  }
  else {
    if (curopr == DOT) {
      if (p->ar_ind > 0) {
        --p->ar_ind;
        loadx(ar);
        ++p->ar_ind;
      }
    }
    else if ((p->ar_ind>0) /*|| (p->ar_chg)*/ || ((p->ar_ind==0) && ((p->ar_ref!=(ADRREG|XREG)) || (p->ar_ref!=(ADRREG|UREG)))))
/*      else if ((p->ar_ind>0) || (p->ar_chg) ||
               ((p->ar_ind==0) && (!(p->ar_ref & ADRREG)))) */
      loadx(ar);
    p->ar_off += offset;
  }
}

setofr(oftyp, ar)
int oftyp;
int ar;
{
  register struct addreg *p;

  p = &adregs[ar];
  if (p->ar_off) {
    loadx(ar);
    p->ar_ofr = oftyp;
  }
  else {
    if ((p->ar_ref==(ADRREG|YREG)) || (p->ar_ind>0) || (p->ar_chg)
       || ((p->ar_ind<=0) && ( !(p->ar_ref&ADRREG)))) {
      dcont = 0;
      loadx(ar);
    }
    p->ar_ofr = oftyp;
    dcont = ARREF | ar;
  }
}

ptrloc1() {
  int temp, ref;

  ref = adregs[locop1 & (NUMADR-1)].ar_ref;
  if ((locop1 & DATREG) || (ref == CREF)) {
    temp = locop1;
    locop1 = locop2;
    locop2 = temp;
  }
}

dupop(loc)
int loc;
{
  int i,j;
  register char *p1;
  char *p2;

  if(!(loc & ARREF))
    badfile();
  else {
    i = getar();
    p1 = &adregs[loc & (NUMADR-1)];
    p2 = &adregs[i];
    for (j=0; j < sizeof(struct addreg); j++)
      *p2++ = *p1++;
    adregs[i].ar_inc = 0;
    adregs[i].ar_pre = 0;
    adregs[i].ar_ofr = 0;
    return(0x80 | i);
  }
}

finar(loc)
int loc;
{
  register struct addreg *p;
  int inc;
  int i;

  p = &adregs[loc & (NUMADR-1)];
  if (inc = p->ar_inc)
    if ((p->ar_pre && inc<0 && inc >-3) || (!p->ar_pre && inc>0 && inc<3)) {
      p->ar_pre = 0;
      if (p->ar_ref != (ADRREG | UREG)) {
        p->ar_inc = 0;
        p->ar_ind--;
        if (xcont)
          freex();
        incloc = dupop(loc);
        loadx(loc & (NUMADR-1));
        p->ar_ind++;
        p->ar_inc = inc;
      }
    }
    else
      finarx(loc);
}

finarx(loc)
int loc;
{
  register struct addreg *p;
  int inc, dup, i;

  p = &adregs[loc & (NUMADR-1)];
  if ((inc=p->ar_inc) && ((p->ar_ind > 0) || (p->ar_ref==(ADRREG|UREG)
       && (p->ar_ind >= 0)))) {
    p->ar_ind--;
    if ((curopr>=FPP && curopr<=BMM && (curtyp&0x30)==(PTR<<4) && p->ar_ind>=0)
          || p->ar_ref != (ADRREG|UREG)) {
      if (xcont)
        freex();
      dup = dupop(loc) & (NUMADR-1);
      p->ar_inc = 0;
      if (p->ar_ref==TREF && p->ar_ind>0)
        p->ar_ref = BREF;
      if (p->ar_ref == BREF)
        stklev++;
      loadx(loc & (NUMADR-1));
      outcode(" leax %d,x\n", inc);
      outcode(" stx ");
      dvalid = '\0';
      genadr(dup);
      adregs[dup].ar_ref = 0;
    }
    else {
      outcode(" leau %d,u\n", inc);
      p->ar_inc = 0;
    }
    if (p->ar_pre == 0)
      setoff(-inc, loc & (NUMADR-1));
    p->ar_pre = 0;
    p->ar_ind++;
  }
}
