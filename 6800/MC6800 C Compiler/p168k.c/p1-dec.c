#include "pass1.h"
#include "il.h"
#include "nxtchr.h"


/* external definitions */

extern short curtok;
extern char matlev;
extern char ident[];
extern long convalu;
extern short contyp;
extern char lstflg;
extern short label;
extern short fpvars;
extern short strhdr;
extern short lastmem;
extern short strofs;
extern char strnum;
extern char strnum2;
extern short strhdr2;
extern int enumval;
extern char absflag;
extern int *subsptr;
extern short dtype, token, nxtaut;
extern int *nxtdim, dimstk[];
extern char dclass, blklev, pmlsf, fndcf;
extern char deftyp, sukey;
extern short nxtarg, argoff, datareg, addrreg;
extern struct express *nxtmat;
extern struct symtab *symloc;
extern struct symtab **tos;
extern struct symtab *typdfsym;
extern struct symtab *funnam;
extern struct symtab *argptr;
extern struct symtab *endprms;
extern TABLE sym_table;
extern struct symtab absdec;
extern char clstbl[], typtab[];
extern char strngbf[];
extern struct infost *ptinfo, stinfo[];

/* declaration list */

dcllst() {
  while (spctst())
    declar();
  return(TRUE);
}

/* parse the declarator */

declar() {
  ptinfo = stinfo;
  if (!spcfr())
    return(FALSE);
  if (tstdcl())
    if (!dctlst())
      fndsc();
  if (getok() != SMC)
    rptfnd(13);
  curtok = 0;
  return(TRUE);
}

/* test for specifier */

spctst() {
  dclass = dtype = deftyp = 0;
  typdfsym = NULL;
  symloc = NULL;
  switch (getok()) {
    case KEY:
      return((token >= 20) ? FALSE : TRUE);
    case VAR:
      if (symloc = looksym(SIDENT))
        return(symloc->sclass == TYPDF);
    default:
      return(FALSE);
  }
}

/* process specifier */

spcfr() {
  if (tstcls()) {
    if (tsttyp())
      return(type());
    else
      return(TRUE);
  }
  if (!tsttyp())
    return(rptern(15));
  if (type()) {
    tstcls();
    return(TRUE);
  }
  return(FALSE);
}

/* test for class specifier */

tstcls() {
  if (getok() != KEY)
    return(FALSE);
  if (token<=12 || token >=20)
    return(FALSE);
  curtok = 0;
  dclass = clstbl[token-14];
  return(TRUE);
}

/* test for type specifier */

tsttyp() {
  if (getok() == KEY)
    return(token<14);
  if (curtok == VAR) {
    symloc = looksym(SIDENT);
    return( symloc ? (symloc->sclass==TYPDF) : FALSE);
  }
  return(FALSE);
}

/* process type specifier */

type() {
  typdfsym = NULL;
  if (tststr()) {
    if (suspc()) {
      deftyp++;
      return(TRUE);
    }
    return(FALSE);
  }
  typdfsym = NULL;
  if (!tsttyp())
    return(rptern(15));
  settyp();
  while (tsttyp())
    settyp();
  if (dtype == UNS)
    dtype = UNSND;
  if (dtype==FLOAT || dtype==DUBLE)
    fpvars=1;
  return(TRUE);
}

/* check for structure type */

tststr() {
  short ttype;

  if (getok() == KEY)
    return(token>=8 && token<=10);
  if (curtok == VAR) {
    symloc = looksym(SIDENT);
    if (symloc->sclass != TYPDF)
      return(FALSE);
    ttype = symloc->stype & 0x0f;
    typdfsym = symloc;
    return(ttype>=STRUCT && ttype<=ENUM);
  }
  return(FALSE);
}

/* set the type for identifier */

settyp() {
  short stype;

  if (getok() != VAR) {
    curtok = 0;
    stype = typtab[token-1];
    if (deftyp && (dtype==0 || stype==0))
      rptern(74);
    if (dtype) {
      if (stype == INT) {
        if ((dtype&0xfe)==SHORT || (dtype&0xfe)==LONG) {
          deftyp++;
          return(TRUE);
        }
        if (dtype == UNS) {
          dtype |= stype;
          deftyp++;
          return(TRUE);
        }
        return(rptern(62));
      }
      if (dtype == UNS) {
        if (stype > UNS && stype < FLOAT) {
          dtype |= stype;
          deftyp++;
          return(TRUE);
        }
        else
          return(rptern(62));
      }
      if (stype==FLOAT && dtype==LONG)
        stype = DUBLE;
      else
        return(rptern(62));
    }
    dtype = stype;
    deftyp++;
    return(TRUE);
  }
  typdfsym = symloc;
  curtok = 0;
  if (dtype) {
    rpters(59);
    if (dclass == TYPDF)
      rpters(22);
  }
  else
    dtype = symloc->stype & 0x0f;
  symloc = NULL;
  deftyp++;
  return(TRUE);
}

/* test for declarator */

tstdcl() {
  switch(getok()) {
    case VAR:
    case MUL:
    case LPR:
      return(TRUE);
    case KEY:
      return(rptern(110));
    default:
      return(FALSE);
  }
}

/* process declarator list */

dctlst() {
  while (TRUE) {
    if (dodec() && pmlsf)
      return(rptern(11));
    if (getok() == ASN) {
      if (dclass == EXTN)
        return(rptern(68));
      if (!doinit())
        return(FALSE);
    }
    if (getok() != CMA)
      break;
    curtok = 0;
  }
  return(TRUE);
}

/* process a declarator */

dodec() {
  short ttype;
  char tclass;
  short size;
  short memoff;
  struct symtab *sptr;
  register struct symtab *sym;
  short *phdr;
  char *pnum;
  short typ;
  char tflags;

  tclass = dclass;
  ttype = dtype;
  pnum = &strnum;
  phdr = &strhdr;
  pmlsf = fndcf = 0;
  symloc = NULL;
  if (!dfdec())
    return(FALSE);
  if (typdfsym && (typdfsym->stype & 0x30))
    entdec(typdfsym->stype >> 4);
  sym = symloc;
  if (!deftyp)
    dtype |= INT;
  if (!sym) {
    if (curtok == KEY)
      return(rptern(110));
    return(rptern(4));
  }
  if (blklev==1 && !symloc->sclass) {
    if (!(dclass>=MOS && dclass<=MOE))
      return(rpters(25));
  }
  if ((dtype&0x0f) == 0) {
    typ = (dtype>>4);
    while (typ & 0x0c)
      typ >>= 2;
    if (typ != FNCT)
      rpters(74);
  }
  if ((dtype&0x0f)>=STRUCT && (dtype&0x0f)<=ENUM) {
    sym->sstrct = strhdr;
    sym->sstrnum = strnum;
    if (getok() != CMA) {
      strhdr2 = strhdr;
      strnum2 = strnum;
      ptinfo--;
      strhdr = ptinfo->header;
      strnum = ptinfo->number;
    }
    else {
      phdr = &(ptinfo-1)->header;
      pnum = &(ptinfo-1)->number;
    }
  }
  if ((dtype & 0x0f) == ENUM)
    dtype = (dtype & 0xfff0) | INT;
  if ((dtype&0x30)==(FNCT<<4)) {
    if (dclass>=MOS && dclass<=MOE)
      rptern(69);
    if (dtype & 0xc0)
      if ((dtype&0xc0) != (PTR<<6))
        rptern(69);
    if (blklev) {
      size = blklev;
      blklev = 0;
      dclass = EXTN;
      sptr = lookblk(SIDENT);
      if (sptr != sym) {
        blklev = size;
        symloc = sptr;
        tflags = sptr->sflags;
        sptr->sflags |= FEXT;
        if (!checkext())
          return(FALSE);
        sptr->sflags = tflags;
        symloc = sym;
      }
      blklev = size;
    }
  }
  if ((dtype&0x30) == (ARAY<<4)) {
    if ((dtype&0xc0) == (FNCT<<6))
      rptern(81);
/*  if (*(sym->ssubs)==0 && dclass!=EXTN && blklev!=1)
      rptern(53);   */
  }
  if (sym->sclass) {
    if (sym->sblklv > 1)
      return(rpters(22)); /* duplicate definition */
    if (!sym->sblklv) {
      if (!checkext())
        return(FALSE);
    }
    else {
      size = checkprm();
      dclass = tclass;
      dtype = ttype;
      return(size);
    }
  }
  sym->stype = dtype;
  if (!blklev) {
    if (!dclass) {
      sym->sclass = EXTN;
      sym->sflags |= FEXT;
      if ((dtype&0x30) != (FNCT<<4)) {
        if (getok() != ASN)
          outextdf();
        else
          outiextdf();
      }
      else {
        if (getok()==SMC || getok()==CMA)
          sym->sflags &= (~FEXT);
      }
    }
    if (!dclass || dclass==EXTN) {
      sym->sclass = EXTN;
      dclass = tclass;
      dtype = ttype;
      return(TRUE);
    }
  }
  if (!dclass) {
    if ((dtype&0x30) != (FNCT<<4))
      dclass = AUTO;
    else
      dclass = EXTN;
  }
  sym->sclass = dclass;
  if (sym->sclass != EXTN)
    sym->sblklv = blklev;
  else
    sym->sblklv = 0;
  switch (dclass) {
    case REG:
      if (asnreg(sym,0))
        break;
    case AUTO:
      sym->sstore = (nxtaut -= sizeit(symloc));
#ifdef ALIGN
      if (dtype>=SHORT && !isarch(dtype))
        if (nxtaut & 1)
          sym->sstore = --nxtaut;
#endif
      if (nxtaut > 0)
        rptern(99);
      outautdf();
      break;
    case STAT:
      if ((dtype&0x30) != (FNCT<<4)) {
        symloc->sstore = ++label;
        if (getok() != ASN)
          outstdf();
        else
          outistdf();
      }
      else {
        symloc->sclass = EXTN;
        symloc->sflags |= FSTATIC;
      }
      break;
    case MOS:
    case MOU:
    case MOE:
      memoff = ((char *) symloc - sym_table->fwad) + 1;
      if (!(*phdr))
        *phdr = memoff;
      if (lastmem) {
        sptr = sym_table->fwad + (lastmem-1);
        sptr->spoint = memoff;
      }
      lastmem = memoff;
#ifdef ALIGN
      if (dclass == MOS)
        if ((strofs & 1) && (dtype >= SHORT) && (!isarch(dtype))){
          strofs++;
          symloc->sflags |= FALND;
        }
#endif
      symloc->smemnum = *pnum;
      if (dtype==STRUCT || dtype==UNION)
        if (symloc->smemnum == symloc->sstrnum) {
          dclass = tclass;
          dtype = ttype;
          return(rpters(91));
        }
      if (!(size = sizeit(symloc)))
        rpters(16);
      if (dclass == MOE)
        symloc->sstore = enumval;
      else
        symloc->sstore = strofs;
      if (dclass == MOS)
        strofs += size;
      break;
  }
  dclass = tclass;
  dtype = ttype;
  return(TRUE);
}

/* do declaration definition */

dfdec() {
  char tempblk;
  int dimsize;
  struct symtab *tsym;
  short ttype;
  register int *p;
  char tnum;

  tempblk = blklev;
  switch (getok()) {
    case VAR:
      if (absflag)
        return(TRUE);
      curtok = 0;
      subsptr = NULL;
      if (symloc) {
        rpters(2);
      }
      if (dclass == EXTN)
        blklev = 0;
      if (dclass==MOS || dclass==MOU) {
        tnum = strnum;
        ttype = dtype & 0x0f;
        if (ttype>=STRUCT && ttype<=ENUM)
          strnum = (ptinfo-1)->number;
        if (looksym(SMEMBER)) {
          blklev = tempblk;
          strnum = tnum;
          return(rpters(18));
        }
        symloc = addsym(SMEMBER);
        strnum = tnum;
      }
      else {
        if (!(symloc = lookblk(SIDENT)))
          symloc = addsym(SIDENT);
      }
      blklev = tempblk;
      if (symloc->sclass == TYPDF) {
        return(rptern(59));
      }
      if (!(subsptr = symloc->ssubs)) {
        if (typdfsym && typdfsym->ssubs) {
          symloc->ssubs = nxtdim;
          p = typdfsym->ssubs;
          while ((*nxtdim++ = *p++) != -1);
        }
      }
      return(dfdec());
    case LPR:
      curtok = 0;
      if (absflag)
        if (getok() == RPR)
          symloc = &absdec;
      if (!symloc) { /* not a function */
        if (!dfdec())
          return(FALSE);
        if (getok() != RPR)
          return(rptern(3));
        curtok = 0;
        return(dfdec());
      }
      /* it is a function */
      fndcf++;
      if (!absflag && !blklev) {
        funnam = symloc;
        if (fndcf == 1)
          prmlst();
        symloc = funnam;
        blklev = 0;
      }
      if (getok() != RPR)
        return(rptern(6));
      curtok = 0;
      entdec(FNCT);
      if (getok()==VAR && (tsym=looksym(SIDENT)) && tsym->sclass==TYPDF)
        return(TRUE);
      return(dfdec());
    case MUL:
      curtok = 0;
      if (symloc)
        rpters(2);
      dfdec();
      if (absflag)
        symloc = &absdec;
      if (!symloc)
        return(rptern(4));
      entdec(PTR);
      return(TRUE);
    case LSB:
      curtok = 0;
      ttype = dtype;
      convalu = 0L;
      contyp = INT;
      if (absflag)
        symloc = &absdec;
      if (!(tsym=symloc))
        return(rptern(4));
      if (getok() == RSB) {
        if (subsptr != symloc->ssubs)
          rpters(53);
      }
      else {
        cexp();
        if ((int)convalu <= 0)
          rptern(114);
      }
      dimsize = (int) convalu;
      symloc = tsym;
      if (!symloc->ssubs) {
        symloc->ssubs = nxtdim;
        *nxtdim++ = dimsize;
        *nxtdim++ = (-1);
      }
      else {
        if (subsptr) {
          if (subsptr == symloc->ssubs) {
            if (dimsize) {
              if (*subsptr) {
                if (dimsize != *subsptr)
                  rpters(54);
              }
              else
                *subsptr = dimsize;
            }
          }
          else {
            if (!dimsize)
              rpters(53);
            else
              if (dimsize != *subsptr)
                rpters(54);
          }
        }
        else {
          if (!dimsize)
            rpters(53);
          else {
            *(nxtdim-1) = dimsize;
            *nxtdim++ = (-1);
          }
        }
      }
      if (nxtdim > (&dimstk[DMLEN]))
        error(127);
      if (subsptr)
        subsptr++;
      dtype = ttype;
      if (getok() != RSB)
        return(rpters(5));
      curtok = 0;
      entdec(ARAY);
      return(dfdec());
    default:
      return(TRUE);
  }
}

/* enter the declaration type */

entdec(typ)
int typ;
{
  register short i, mask;

  i = 4;
  mask = 0x30;
  while (dtype & mask) {
    mask <<= 2;
    i += 2;
  }
  if (!mask)
    rptern(64);
  else
    dtype |= (typ<<i);
}

/* check for valid external definition */

checkext() {
  register struct symtab *sym;

  sym = symloc;
  if (sym->sflags & FEXT) {
    if (dclass!=EXTN || dtype!=sym->stype)
      return(rpters(22));
  }
  else {
    if (sym->stype != dtype)
      return(rpters(22));
    if (!dclass)
      sym->sclass = 0;
  }
  return(TRUE);
}

/* process argument declarations */

argdec() {
  while (getok() != LCB) {
    dclass = dtype = deftyp = 0;
    if (tstcls()) {
      if (dclass != REG)
        return(rpters(12));
      if (tsttyp())
        type();
    }
    else {
      type();
    }
    dctlst();
    if (getok() != SMC) {
      rptsfnd(55);
      return(FALSE);
    }
    curtok = 0;
  }
  return(TRUE);
}

/* process parameter list */

prmlst() {
  register struct symtab *sym;

  blklev = 1;
  endprms = argptr = sym_table->lwad;
  argoff = entblock();
  nxtarg = FSTARG;
  datareg = addrreg = 0;
  if (getok() == RPR)
    return(TRUE);
  while (TRUE) {
    if (getok() != VAR)
      return(rptern(7));
    curtok = 0;
    pmlsf = 1;
    if (lookblk(SIDENT))
      rpters(22);
    else {
      sym = symloc;
      sym = addsym(SIDENT);
      sym->sclass = AUTO;
      sym->stype = INT;
      sym->sblklv = 1;
      sym->sflags |= FPRM;
      sym->sstore = nxtarg;
      nxtarg += SIZINT;
    }
    endprms = sym_table->lwad;
    if (getok() != CMA)
      return(TRUE);
    curtok = 0;
  }
}

/* check for valid parameter redefinition */

checkprm() {
  short size;
  register struct symtab *ptr;

  if (!(symloc->sflags & FPRM))
    return(rpters(22));
  symloc->sflags &= ~FPRM;
  if (dtype == UNSND)
    symloc->stype = dtype;
  if (dtype == FLOAT)
    dtype = DUBLE;
  if (dtype > UNSND) {
    if ((dtype & 0x30) == (ARAY<<4))
      dtype = (dtype & 0xffcf) | (PTR<<4);
    symloc->stype = dtype;
    size = sizeit(symloc) - SIZINT;
    if (size)
      for (ptr=symloc+1; ptr!=endprms; ptr++)
        ptr->sstore += size;
  }
  else {
    if (dtype < INT) {
      size = (dtype&0xe)==CHR ? 1 : 2;
      symloc->sstore += (SIZINT-size);
      symloc->stype = dtype;
    }
  }
  if (dclass == REG) {
    size = symloc->sstore;
    asnreg(symloc,1);
  }
  return(TRUE);
}

/* get the size of an item */

sizeit(sym)
register struct symtab *sym;
{
  register int size, usize;
  register struct symtab *memptr;
  register int *aptr;

  size = 0;
  if (usize = (sym->stype & 0x30)) {
    if (usize != (ARAY<<4))
      return(SIZINT);
    usize = sym->stype;
    while (((usize=remvlev(usize))&0x30)==(ARAY<<4));
    if (usize & 0x30)
      size = SIZINT;
  }
  usize = sym->stype & 0x0f;
  if (usize < DUBLE)
    usize &= 0x0e;
  if (!size) {
    switch(usize) {
      case CHR:
        size = 1;
        break;
      case SHORT:
        size = 2;
        break;
      case INT:
      case ENUM:
        size = SIZINT;
        break;
      case LONG:
      case FLOAT:
        size = 4;
        break;
      case DUBLE:
        size = 8;
        break;
      case STRUCT:
        if (!(sym->sstrct))
          if (!fixstrct(sym))
            return(rptern(83));
        memptr = sym_table->fwad + (sym->sstrct-1);
        while (memptr->spoint)
          memptr = sym_table->fwad + (memptr->spoint-1);
        size = memptr->sstore + sizeit(memptr);
#ifdef ALIGN
        if (size & 1)
          size++;
#endif
        break;
      case UNION:
        if (!(sym->sstrct))
          if (!fixstrct(sym))
            return(rptern(83));
        memptr = sym_table->fwad + (sym->sstrct-1);
        size = 0;
        while (TRUE) {
          usize = sizeit(memptr);
          if (usize > size)
            size = usize;
          if (!memptr->spoint)
            break;
          memptr = sym_table->fwad + (memptr->spoint-1);
        }
#ifdef ALIGN
        if (size & 1)
          size++;
#endif
        break;
    }
  }
  if (!(sym->stype & 0x30))
    return(size);
  usize = (sym->stype >> 4);
  for (aptr=sym->ssubs; *aptr != (-1); aptr++);
  for (;(usize&0x03)==ARAY; usize >>= 2)
    size *= *(--aptr);
  return(size);
}

/* parse type-name */

typnam() {
  int *savedim;
  register struct symtab *p;
  short i;
  register char *pc1, *pc2;
  struct symtab *temp;
  short savstrh;
  short ttype;
  char tdeftyp;

  ttype = dtype;
  tdeftyp = deftyp;
  dtype = deftyp = 0;
  typdfsym = NULL;
  savedim = nxtdim;
  savstrh = strhdr;
  p = &absdec;
  p->stype = p->sclass = p->ssubs = p->sstrct = 0;
  p->sstrnum = p->smemnum = p->spoint = 0;
  symloc = NULL;
  type();
/*if (symloc)
    if (symloc->sclass == TYPDF)
      symloc = NULL; */
  absflag++;
  strhdr = savstrh;
  temp = symloc;
  symloc = NULL;
  if (!dfdec()) {
    nxtdim = savedim;
    return(absflag = 0);
  }
  if (typdfsym && (typdfsym->stype & 0x30))
    entdec(typdfsym->stype >> 4);
  absflag = 0;
  nxtdim = savedim;
  symloc = temp;
  if (!symloc) {
    if (typdfsym)
      symloc = typdfsym;
    else {
      symloc = &absdec;
    }
  }
  if (symloc != &absdec) {
    pc1 = symloc;
    pc2 = &absdec;
    for (i=0; i<sizeof(struct symtab); i++)
      *pc2++ = *pc1++;
    symloc = &absdec;
  }
  symloc->stype = dtype;
  if ((dtype&0x0f)>=STRUCT && (dtype&0x0f)<=ENUM)
    ptinfo--;
  dtype = ttype;
  deftyp = tdeftyp;
  return(TRUE);
}

/* assign a register to variable if can */

asnreg(sym, flag)
register struct symtab *sym;
{
  short tp;

  tp = sym->stype;
  if ((tp & 0x30) == (PTR << 4)) {
    if (addrreg < NUMAREG) {
      sym->sclass = REG;
      if (flag) {
        sym->sblklv = 128 + addrreg++;
      }
      else {
        sym->sstore = 128 + addrreg++;
        outregdf(sym);
      }
      return(TRUE);
    }
  }
  else {
    if (tp < FLOAT) {
      if (datareg < NUMDREG) {
        sym->sclass = REG;
        if (flag) {
          sym->sblklv = datareg++;
        }
        else {
          sym->sstore = datareg++;
          outregdf(sym);
        }
        return(TRUE);
      }
    }
  }
  sym->sclass = AUTO;
  return(FALSE);
}

/* generate load register code for register parameter */

gnldreg(sym)
register struct symtab *sym;
{
  int offs;

  offs = sym->sstore;
  sym->sstore = ((int) sym->sblklv & 0xff);
  sym->sblklv = 1;
  outil("%c%r%c%r", BEGEXP, 0, ASN, sym->stype);
  outop(sym);
  outil("%c%c%r%r", NNAME, AUTO, sym->stype, offs);
}

/* check if type is an array of characters */

isarch(t)
register int t;
{
  while(TRUE) {
    if ((t & 0x30) != (ARAY << 4))
      return(FALSE);
    t = remvlev(t);
    if ((t&0x30) == 0)
      break;
  }
  if ((t&0x0e) == CHR)
    return(TRUE);
  return(FALSE);
}

/* try to fix structure pointer */

fixstrct(sym)
struct symtab *sym;
{
  register struct symtab *ps, *pe;
  char num;

  num = sym->sstrnum;
  ps = sym_table->fwad;
  pe = sym_table->lwad;
  while (ps < pe) {
    if (ps->sstrct && ps->sstrnum==num) {
      sym->sstrct = ps->sstrct;
      return(TRUE);
    }
    ps++;
  }
  return(FALSE);
}

