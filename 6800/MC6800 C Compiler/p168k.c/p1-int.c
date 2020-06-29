#include "pass1.h"
#include "il.h"
#include "nxtchr.h"


/* external definitions */

extern short curtok;
extern char blklev;
extern char matlev;
extern char deftyp, strnum;
extern short strhdr, dtype;
extern struct infost *ptinfo, stinfo[];
extern struct symtab *typdfsym;
extern long convalu;
extern short contyp;
extern short strsize;
extern struct express *nxtmat;
extern struct symtab *symloc;
extern struct symtab **tos;
extern int ioff;
extern char optf;
extern short inztyp;
extern struct symtab *inzsym;
extern struct symtab *iname;
extern struct express emat[];
extern char ibindx, iwindx, ilindx, ilbindx;
extern char ibstk[];
extern short iwstk[];
extern long ilstk[];
extern struct ilab ilbstk[];
extern TABLE sym_table;
extern char cmexfl;
extern char initfld;
extern int crntfld;
extern unsigned fieldval;
extern char strngbf[];
extern struct symtab *nxtsst, strings[];
extern char strnum2;
extern short strhdr2;

/* local global variables */

static short ityp;

/* do initialization parsing */

doinit() {
  char pflag = 0;
  register struct symtab *var = symloc;
  register struct express *p;
  short tp;
  struct infost *tpoint;
  short tdtype;
  char tdeftyp;
  struct symtab *ttpdf;
  short ihdr;
  char inum;

  tdtype = dtype;
  tdeftyp = deftyp;
  ttpdf = typdfsym;
  curtok = 0;
  ibindx = iwindx = ilindx = ilbindx = 0;
  if (blklev && var->sclass!=STAT) {
    tpoint = ptinfo;
    ptinfo = stinfo;
    if (blklev==1)
      return(rpters(20));
    if (var->stype & 0x30) {
      if ((var->stype&0x30) != (PTR<<4))
        return(rpters(21));
    }
    else {
      if (var->stype > DUBLE)
        return(rptern(23));
    }
    if (getok() == LCB) {
      curtok = 0;
      pflag++;
    }
    inum = strnum;
    ihdr = strhdr;
    cmexfl++;
    if (!bildmat())
      return(FALSE);
    strhdr = ihdr;
    strnum = inum;
    tp = var->stype & 0x0f;
    if ((tp>=STRUCT && tp<=ENUM) && getok()==CMA) {
      ptinfo = ++tpoint;
      strhdr = strhdr2;
      strnum = strnum2;
    }
    p=nxtmat++;
    p->moprtr = ASN;
    p->mo1loc = var;
/*  if (!matlev)  */
      p->mo2loc = *(--tos);
/*  else
      p->mo2loc = (struct symtab *) (matlev++);   */
    (p+1)->moprtr = 0;
    typechk();
    outexp();
    if (pflag)
      if (getok() != RCB)
        return(rptern(17));
      else
        curtok = 0;
  }
  else {
    tpoint = ptinfo;
    ptinfo = stinfo;
    if (optf)
      rptern(112);
    inztyp = var->stype;
    inzsym = var;
    if (!inthing(var))
      return(FALSE);
    iflush();
    tp = var->stype & 0x0f;
    if ((tp>=STRUCT && tp<=ENUM) && getok()==CMA) {
      ptinfo = ++tpoint;
      strhdr = strhdr2;
      strnum = strnum2;
    }
  }
  dtype = tdtype;
  deftyp = tdeftyp;
  typdfsym = ttpdf;
  return(TRUE);
}

/* initialize an object */

inthing(var)
register struct symtab *var;
{
  short tp;

  tp = var->stype;
  if (tp > DUBLE)
    if (initfld) {
      ioff = fieldval;
      fieldval = 0;
      initfld = 0;
#ifdef ALIGN
      ilongs();
#else
      iwords();
#endif
    }
  if ((tp&0x30) == 0) {
    if (tp == STRUCT) {
      return(instruct(var));
    }
    else {
      if (tp <= DUBLE)
        return(intype(var));
      else if (tp == UNION)
        return(intype(var));
      else
        return(rpters(65));
    }
  }
  if ((tp&0x30) == (PTR<<4)) {
    return(intype(var));
  }
  if ((tp&0x30) == (ARAY<<4))
    return(inarray(var));
  return(rpters(24));
}

/* process data for scalar init types */

intype(p)
register struct symtab *p;
{
  short temtype;
  short valtype;
  char pflag = 0;

  if (p->sflags & FFIELD)
    return(infield(p));
  if (initfld) {
    ioff = fieldval;
    initfld = 0;
    fieldval = 0;
#ifdef ALIGN
    ilongs();
#else
    iwords();
#endif
  }
  if (getok() == LCB) {
    pflag++;
    curtok = 0;
  }
  valtype = p->stype;
  temtype = inzsym->stype;
  inzsym->stype = inztyp;
  if (getok() != RCB) {
    cmexfl++;
    if (!bildmat())
      return(FALSE);
  }
  else {
    emat[0].moprtr = NOP;
    emat[0].mttype = 0;
    emat[1].moprtr = 0;
    matlev = 1;
  }
  if (valtype == UNION)
    oiuval(p);
  else {
    if (!oival(valtype))
      return(FALSE);
  }
  inzsym->stype = temtype;
  if (pflag)
    if (getok() != RCB)
      return(rptern(17));
    else
      curtok = 0;
  return(TRUE);
}

/* output initialized data value */

oival(typ) {
  register struct express *p;
  char pflag;

  if (!matlev)
    enteru(LOD);
  iname = ioff = 0;
  pflag = 0;
  for (p=emat; p->moprtr; p++) {
    switch (p->moprtr) {
      case ADR:
        pflag++;
      case LOD:
        if (!iset(p->mo1loc))
          return(FALSE);
        break;
      case ADD:
        if (!iset(p->mo1loc))
          return(FALSE);
        if (!iset(p->mo2loc))
          return(FALSE);
      case NOP:
        break;
      case CVC:
        if (!iset(p->mo1loc))
          return(FALSE);
        if ((p->mttype&0x30)==(PTR<<4))
          pflag++;
        break;
      case DOT:
        if (!iname)
          if (!iset(p->mo1loc))
            return(FALSE);
        ioff += p->mo2loc->sstore;
        ityp = p->mttype;
        break;
      case IND:
        if (p->mttype==STRUCT || p->mttype==UNION) {
          if ((unsigned)p->mo1loc > 255)
            return(rptern(60));
          if ((emat[(unsigned)p->mo1loc - 1].mttype & 0x30) != (ARAY<<4))
            return(rptern(60));
          if ((p+1)->moprtr != DOT)
            return(rptern(60));
          break;
        }
        return(rptern(60));
      default:
        return(rptern(60));
    }
  }
  p--;
  if (p->mttype & 0x30)
    if ((p->mttype&0x30) == (PTR<<4))
      if (!pflag)
        return(rptern(60));
  if (!iname) {
#ifdef ALIGN
    if (typ < SHORT)
      ibytes();
    else if (typ < INT)
      iwords();
    else if ((typ & 0x30) || typ<FLOAT)
      ilongs();
    else
      ifloats(typ);
#else
    if (typ < SHORT)
      ibytes();
    else if ((typ & 0x30) || typ < LONG)
      iwords();
    else if (typ<FLOAT)
      ilongs();
    else
      ifloats(typ);
#endif
  }
  else {
    if ((!pflag) && (!(ityp & 0x30)))
      return(rptern(60));
    if (typ < INT)
      return(rptern(60));
    ilabels();
  }
  return(TRUE);
}

/* evaluate and set offset and or name field for initialization */

iset(p)
register struct symtab *p;
{
  int *ip;

  if ((unsigned)p < 256)
    return(TRUE);
  if (isconst(p->stype)) {
    ip = p;
    ioff += *(ip + 1);
  }
  else {
    if (iname)
      return(rptern(61));
    else {
      iname = p;
      ityp = iname->stype;
    }
  }
  return(TRUE);
}

/* set byte value */

ibytes() {
  if (iwindx)
    owords();
  else if (ilindx)
    olongs();
  else if (ilbindx)
    olabels();
  if (ibindx == 16)
    obytes();
  ibstk[ibindx++] = ioff;
}

/* set word value */

iwords() {
  if (ibindx)
    obytes();
  else if (ilindx)
    olongs();
  else if (ilbindx)
    olabels();
  if (iwindx == 16)
    owords();
  iwstk[iwindx++] = ioff;
}

/* set long value */

ilongs() {
  if (ibindx)
    obytes();
  else if (iwindx)
    owords();
  else if (ilbindx)
    olabels();
  if (ilindx == 16)
    olongs();
  ilstk[ilindx++] = ioff;
}

/* set label value */

ilabels() {
  if (ibindx)
    obytes();
  else if (iwindx)
    owords();
  else if (ilindx)
    olongs();
  if (ilbindx == 16)
    olabels();
  ilbstk[ilbindx].iofset = ioff;
  if (!iname) {
    ilbstk[ilbindx].ityp = 1;
    ilbstk[ilbindx++].ilabn = 0;
  }
  else {
    if (iname->sclass == STAT) {
      ilbstk[ilbindx].ityp = 0;
      ilbstk[ilbindx++].ilabn = iname->sstore;
    }
    else {
      ilbstk[ilbindx].ityp = 2;
      ilbstk[ilbindx++].ilabn = (int) (iname->sname);
    }
  }
}

/* flush all initialized data */

iflush() {
  if (initfld) {
    ioff = fieldval;
    initfld = 0;
    fieldval = 0;
#ifdef ALIGN
    ilongs();
#else
    iwords();
#endif
  }
  if (ibindx)
    obytes();
  else if (iwindx)
    owords();
  else if (ilindx)
    olongs();
  else if (ilbindx)
    olabels();
}

/* initialize array */

inarray(p)
register struct symtab *p;
{
  return(insubs(p, p->ssubs));
}

/* initialize a structure */

instruct(var)
register struct symtab *var;
{
  register struct symtab *p;
  char pflag = 0;
  char err = 0;

  if (var->sstrct == 0)
    return(rptfnd(83));
  if (getok() == LCB) {
    pflag++;
    curtok = 0;
  }
  p = sym_table->fwad + (var->sstrct-1);
  outil("%c", EVEN);
  while (p) {
    if (p->sflags & FALND) {
      ioff = 0;
      ibytes();
    }
    if (!inthing(p)) {
      err++;
      break;
    }
    if (getok() == CMA)
      curtok = 0;
    if (p->spoint)
      p = sym_table->fwad + (p->spoint-1);
    else
      break;
  }
  iflush();
  outil("%c", EVEN);
  if (getok() == CMA)
    curtok = 0;
  if (pflag)
    if (getok() == RCB)
      curtok = 0;
    else
      return(rptern(17));
  return(!err);
}

/* initialize a set of subscriptd */

insubs(vp, ip)
register struct symtab *vp;
register int *ip;
{
  int savtyp, count, i;
  register char *sp;
  int size;
  int dimc = 0;
  char err = 0;
  char pflag = 0;

  if (getok() == LCB) {
    curtok = 0;
    pflag++;
  }
  count = *ip++;
  savtyp = vp->stype;
  vp->stype = remvlev(vp->stype);
  if (*ip != -1) {
    if (count) {
      for (i=0; i<count; i++) {
        insubs(vp, ip);
        if (getok() == CMA)
          curtok = 0;
      }
    }
    else {
      while (getok() != RCB) {
        if (!insubs(vp, ip)) {
          err++;
          break;
        }
        dimc++;
        if (getok() == CMA)
          curtok = 0;
      }
      *(ip-1) = dimc;
    }
  }
  else {
    if (vp->stype==CHR && getok()==STC) {
      curtok = 0;
      nxtsst = strings;
      size = strsize;
      sp = strngbf;
      while (size) {
        ioff = *sp++;
        size--;
        ibytes();
      }
      size = strsize;
      if (count) {
        if (size > count)
          return(rptern(52));
        else
          for (i=size; i<count; i++)
            ibytes();
      }
      else
        *(ip-1) = size;
    }
    else if (count) {
      for (i=0; i<count; i++) {
        if (!inthing(vp)) {
          err++;
          break;
        }
        if (getok() == CMA)
          curtok = 0;
      }
    }
    else {
      while (getok() != RCB) {
        if (!inthing(vp)) {
          err++;
          break;
        }
        dimc++;
        if (getok() == CMA)
          curtok = 0;
      }
      *(ip-1) = dimc;
    }
  }
  vp->stype = savtyp;
  if (pflag)
    if (getok() != RCB)
      return(rptern(17));
    else
      curtok = 0;
  return(!err);
}

/* initialize a fielded variable */

infield(p)
register struct symtab *p;
{
  unsigned fval;
  short i;
  unsigned mask;
  char pflag = 0;

  if (getok() == LCB) {
    pflag++;
    curtok = 0;
  }
  if (getok() != RCB)
    cexp();
  else
    convalu = 0L;
  if (initfld && crntfld != p->sstore) {
    ioff = fieldval;
    fieldval = 0;
#ifdef ALIGN
    ilongs();
#else
    iwords();
#endif
  }
  initfld = 1;
  crntfld = p->sstore;
  fval = (unsigned) convalu;
  mask = 0;
  for (i = p->sstrct & 0xff; i; i--)
    mask = (mask << 1) | 1;
  if (fval > mask) {
    symloc = p;
    rpters(103);
  }
  fieldval |= (fval & mask) << ((p->sstrct >> 8) & 0xFF);
  if (pflag)
    if (getok() != RCB)
      return(rptern(17));
    else
      curtok = 0;
  return(TRUE);
}

/* output floating initializers */

ifloats(typ) {
  int db[2];

  if (typ==FLOAT) {
    intflt(ioff, &ioff);
    ilongs();
  }
  else {
    intdbl(ioff, db);
    ioff = db[0];
    ilongs();
    ioff = db[1];
    ilongs();
  }
}

/* output initialized union value */

oiuval(p)
register struct symtab *p;
{
  int i;

  ioff = 0;
#ifdef ALIGN
  for (i=sizeit(p)/2; i>0; i--)
    iwords();
#else
  for (i=sizeit(p); i>0; i--)
    ibytes();
#endif
}
