/* this file contains code for declarations of structures & unions */

#include "pass1.h"
#include "il.h"

extern short dtype, strtag;
extern char deftyp, dclass;
extern short curtok;
extern char blklev;
extern short token, strhdr, strofs, strptr;
extern struct symtab *symloc;
extern TABLE sym_table;
extern short curtyp;
extern char strnum, strcount;
extern short lastmem;
extern char typtab[];
extern int enumval;
extern long convalu;
extern struct infost *ptinfo, stinfo[];
extern char doingfld, fieldoff;
extern struct symtab absdec;
extern struct symtab *typdfsym;

/* test for structure or union specifier */

suspc() {
  short tempoff;
  struct symtab *sptr;
  short tlstmem;
  short tstrtag;
  char tflag = 0;

  tempoff = token;
  ptinfo->header = strhdr;
  ptinfo->number = strnum;
  ptinfo++;
  if (ptinfo >= &stinfo[STNEST])
    error(125);
  tlstmem = lastmem;
  tstrtag = strtag;
  enumval = strnum = strhdr = strtag = lastmem = 0;
  if (getok() == VAR) {
    symloc = looksym(SIDENT);
    if (symloc && symloc->sclass==TYPDF) {
      dtype = symloc->stype & 0x0f;
      typdfsym = symloc;
      strhdr = symloc->sstrct;
      strnum = symloc->sstrnum;
      lastmem = tlstmem;
      strtag = tstrtag;
      curtok = 0;
      symloc = NULL;
      return(TRUE);
    }
  }
  curtok = 0;
  dtype = typtab[tempoff-1];
  if (getok() == VAR) {
    curtok = 0;
    symloc = looksym(STAG);
    if (symloc) {
      if (getok() != LCB) {
        if (symloc->sclass != (dtype-3))
          return(rpters(39));
        if (symloc->sstrct)
          strhdr = symloc->sstrct;
        else {
/*        if (!(strhdr = (ptinfo-1)->header))
            strhdr = (sym_table->lwad - sym_table->fwad) + 1;  */
          strhdr = 0;
        }
        strnum = symloc->sstrnum;
        lastmem = tlstmem;
        strtag = tstrtag;
        return(TRUE);
      }
      if (symloc->sblklv == blklev) {
        if (symloc->sstrct)
          return(rpters(19));
      }
    }
    else {
      symloc = addsym(STAG);
      tflag++;
    }
    symloc->sblklv = blklev;
    symloc->stype = dtype;
    symloc->sclass = dtype-3;
    if (tflag)
      strnum = symloc->sstrnum = ++strcount;
    else
      strnum = symloc->sstrnum;
    symloc->smemnum = 0;
    strtag = ((char *) symloc - sym_table->fwad) + 1;
  }
  if (getok() != LCB) {
    lastmem = tlstmem;
    strtag = tstrtag;
    return(TRUE);
  }
  curtok = 0;
  if (!strnum)
    strnum = ++strcount;
  tempoff = strofs;
  strofs = 0;
  strptr = 0;
  stdlst();
  if (strtag) {
    sptr = sym_table->fwad + (strtag - 1);
    sptr->sstrct = strhdr;
  }
  lastmem = tlstmem;
  strtag = tstrtag;
  strofs = tempoff;
  if (getok() != RCB) {
    return(rptern(17));
  }
  doingfld = curtok = 0;
  return(TRUE);
}

/* process structure - union declaration list */

stdlst() {
  short ttype;
  char tclass;
  struct symtab *temp;

  ttype = dtype;
  tclass = dclass;
  temp = typdfsym;
  if (getok() == RCB)
    return(FALSE);
  while (getok() != RCB) {
    if (!stdec(ttype))
      return(FALSE);
  }
  dtype = ttype;
  dclass = tclass;
  typdfsym = temp;
  return(TRUE);
}

/* parse struct - union declaration */

stdec(class) {
  dtype = deftyp = 0;
  if (class != MOE) {
    if (!type())
      return(FALSE);
  }
  else
    dtype = INT;
  dclass = class;
  if (!stdcl())
    return(FALSE);
  if (dclass != MOE) {
    if (getok() != SMC)
      return(rptern(13));
    curtok = 0;
  }
  return(TRUE);
}

/* parse struct - union declarator */

stdcl() {
  while (TRUE) {
    if (!sdecl())
      return(FALSE);
    if (!symloc)
      return(rptern(56));
    if (getok() != CMA)
      return(TRUE);
    curtok = 0;
  }
}

/* process struct -union declarator */

sdecl() {
  short bfield;
  short ttype;
  struct symtab *saveit;

  symloc = NULL;
  if (getok() != COL)
    if (!dodec())
      return(FALSE);
  saveit = symloc;
  if (dclass==MOS && getok()==COL) {
    if (!doingfld)
      fieldoff = 0;
    if (symloc)
      ttype = symloc->stype;
    else
      ttype = dtype;
    if (ttype!=INT && ttype!=UNSND)
      rpters(100);
    curtok = 0;
    doingfld = 1;
    cexp();
    symloc = saveit;
    bfield = (short) convalu;
    if (bfield < 0)
      rptern(101);
    if (bfield > (SIZINT * 8))
      rpters(101);
    if (symloc) {
      strofs -= SIZINT;
      if (!bfield)
        rpters(102);
      symloc->sflags |= FFIELD;
      if ((fieldoff + bfield) > (SIZINT * 8)) {
        symloc->sstore = strofs = strofs + SIZINT;
        fieldoff = 0;
      }
      symloc->sstrct = (((short)fieldoff<<8) | bfield);
      fieldoff += bfield;
    }
    else {
      symloc = &absdec;
      if (!bfield) {
        if (fieldoff == 0) {
          doingfld = 0;
          if (strofs & 1)
            strofs++;
        }
        else {
          strofs += SIZINT;
          doingfld = fieldoff = 0;
        }
      }
      else
        fieldoff += bfield;
    }
  }
  else {
    if (doingfld) {
      doingfld = 0;
      strofs += SIZINT;
      symloc->sstore += SIZINT;
    }
  }
  if (dclass == MOE) {
    if (getok() == ASN) {
      curtok = 0;
      cexp();
      symloc = saveit;
/*    if (enumval > (int) convalu)
        rptern(57);   */
      enumval = (int) convalu;
      symloc->sstore = enumval;
    }
    enumval++;
  }
  return(TRUE);
}

