#include "pass1.h"
#include "il.h"
#include "nxtchr.h"

/* external definitions */

extern short curtok;
extern char ident[];
extern long convalu;
extern short contyp;
extern char lstflg;
extern short hdrlab;
extern char dclass;
extern char deftyp;
extern char nokey;
extern char strnum, funnum;
extern char swexp, rtexp;
extern short dtype;
extern short fpvars;
extern short funtype;
extern short strhdr;
extern short addrreg, datareg, flptreg;
extern short argoff, retlab;
extern short nxtaut, label;
extern char blklev, fndcf, pmlsf;
extern char strngbf[];
extern struct infost *ptinfo, stinfo[];
extern TABLE sym_table, lab_table;
extern struct symtab *symloc, *funnam, *argptr;
extern struct symtab *endprms, *typdfsym;
extern int *nxtfrc, frctab[];
extern struct express *nxtfor, fortab[];

domodule(name)
char *name;
{
  nokey = fpvars = 0;
  outil("%c%0s%c", BEGMOD, name, TEXT);
  program();
  if (fpvars)
    outil("%c", FPV);
  outinfo();
  flstr();
  outil("%c", ENDMOD);
}

/* parse a program */

program()
{
  swexp = rtexp = 0;
  while (getok() != FILE_END) {
    if (!extdef())
      curtok = 0;
  }
/*abort(sym_table->fwad);*/
}

/* parse an external definition */

extdef() {
  blklev = 0;
  ptinfo = stinfo;
  dclass = dtype = deftyp = 0;
  typdfsym = NULL;
  if (tstcls())
    if (!(dclass==EXTN || dclass==STAT || dclass==TYPDF))
      rpters(1);
  if (tsttyp())
    if (!type())
      return(FALSE);
  if (getok() != SMC) {
    if (!dodec())
      return(FALSE);
    if (getok() == ASN) {
      if (dclass == EXTN)
        return(rptern(68));
      if (!doinit())
        return(FALSE);
    }
    if (getok() != SMC) {
      if (curtok != CMA)
        if (!fndcf)
          return(rptern(8));
        else
         return(funbod());
      else {
        curtok = 0;
        if (pmlsf)
          return(rptern(9));
        if (!dctlst())
          return(FALSE);
        if (getok() != SMC)
          return(rptern(10));
        curtok = 0;
        return(TRUE);
      }
    }
  }
  else {
    if (dclass == TYPDF)
      rptern(4);
  }
  curtok = 0;
  if (pmlsf)
    return(rptern(9));
  else
    return(TRUE);
}

/* process function body */

funbod() {
  short fsize;

  retlab = ++label;
  hdrlab = ++label;
  nxtaut = FSTAUT;
  blklev = 1;
  nxtfrc = frctab;
  nxtfor = fortab;
  outtext();
  if (dclass == TYPDF)
    rptern(59);
  if (!(funnam->sflags & FSTATIC))
    outglob(funnam->sname);
  else
    funnam->sclass = EXTN;
  funtype = remvlev(funnam->stype);
  if (funtype==STRUCT || funtype==UNION) {
    strhdr = funnam->sstrct;
    strnum = funnam->sstrnum;
  }
  funnum = strnum;
  if (funtype==DUBLE || funtype==STRUCT || funtype==UNION)
    fsize = patsize(funtype);
  else
    fsize = 0;
  outil("%c_%n%r", BEGFNT, funnam->sname, fsize);
  outil("%c%r", BEGBLK, hdrlab);
  if (!argdec())
    eatsc();
  outprms();
  if (!cmpstm()) {
    lab_table->lwad = lab_table->fwad;
    exitblck(argoff);
    return(FALSE);
  }
  if (getok() == SMC)
    curtok = 0;
  outtext();
#ifdef MC68020
  outil("%c%r%r", ENDFNT, funtype, (flptreg<<8)|(addrreg<<4)|datareg);
#else
  outil("%c%r%r", ENDFNT, funtype, (addrreg<<8)|datareg);
#endif
  chklbls();
  exitblck(argoff);
  return(TRUE);
}

/* output parameter definitions */

outprms() {
  while (argptr != endprms) {
    symloc = argptr++;
    if (symloc->sclass == AUTO)
      outautdf();
    else
      if (symloc->sclass == REG) {
        gnldreg(symloc);
        outregdf(symloc);
      }
  }
}

/* check for undefined line labels */

chklbls() {
  register struct symtab *p;

  for (p=lab_table->fwad; p<lab_table->lwad; p++) {
    if (!(p->sflags & FLAB)) {
      symloc = p;
      rpters(106);
    }
  }
  lab_table->lwad = lab_table->fwad;
}

/* output info data collected by preprocessor */

outinfo() {
  char *get_info();
  char *p;

  if (p = get_info())
    outil("%c%0s", CMNT, p);
}

