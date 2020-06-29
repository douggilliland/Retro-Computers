#include "pass1.h"
#include "il.h"
#include "nxtchr.h"

/* external definitions */

extern short curtok;
extern char ident[];
extern long convalu;
extern short contyp;
extern char lstflg;
extern short strindx;
extern short hdrlab;
extern char dclass;
extern char deftyp;
extern char swexp, rtexp;
extern short dtype;
extern short addrreg, datareg;
extern short argoff, retlab;
extern short nxtaut, label;
extern char blklev, fndcf, pmlsf;
extern char *nxtstr, strngbf[];
extern struct infost *ptinfo, stinfo[];
extern struct sstack *strngloc;
extern TABLE sym_table;
extern struct symtab *symloc, *funnam, *argptr;
extern int *nxtfrc, frctab[];
extern struct express *nxtfor, fortab[];

domodule(name)
char *name;
{
  outil("%c%0s%c", BEGMOD, name, TEXT);
  program();
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
  strindx = 0;
  nxtstr = strngbf;
/*abort(sym_table->fwad);*/
}

/* parse an external definition */

extdef() {
  blklev = 0;
  ptinfo = stinfo;
  dclass = dtype = deftyp = 0;
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
  curtok = 0;
  if (pmlsf)
    return(rptern(9));
  else
    return(TRUE);
}

/* process function body */

funbod() {
  retlab = ++label;
  hdrlab = ++label;
  nxtaut = FSTAUT;
  blklev = 1;
  nxtfrc = frctab;
  nxtfor = fortab;
  outtext();
  if (funnam->sclass != STAT)
    outglob(funnam->sname);
  outil("%c_%n", BEGFNT, funnam->sname);
  outil("%c%r", BEGBLK, hdrlab);
  if (!argdec())
    eatsc();
  outprms();
  if (!cmpstm()) {
    exitblck(argoff);
    return(FALSE);
  }
  outtext();
  outil("%c%r%r", ENDFNT, remvlev(funnam->stype), (addrreg<<8)|datareg);
  exitblck(argoff);
  return(TRUE);
}

/* output parameter definitions */

outprms() {
  while (argptr != sym_table->lwad) {
    symloc = argptr++;
    if (symloc->sclass == AUTO)
      outautdf();
  }
}

