/* code to output intermediate data */

#include "pass1.h"
#include "il.h"
#include "machine.h"

extern char cspace;
extern struct symtab *symloc;
extern int *nxtsw;
extern short deflab;
extern struct sstack strstck[];
extern short strindx;
extern char *nxtstr, strngbf[];
extern struct symtab *nxtsst, strings[];
extern char ibindx, iwindx, ilindx, ilbindx;
extern char ibstk[];
extern short iwstk[];
extern long ilstk[];
extern struct ilab ilbstk[];
extern int fstr;
extern struct express *nxtmat;

/* output external definition */

outextdf() {
  outbss();
  outglob(symloc->sname);
  outdnam(symloc->sname);
  outsspac(sizeit(symloc));
}

/* output initialized external definition */

outiextdf() {
  outdata();
  outglob(symloc->sname);
  outdnam(symloc->sname);
}

/* output data name */

outdnam(name)
char name[];
{
  outil("%c_%n", DNAME, name);
}

/* output global definition */

outglob(name)
char name[];
{
  outil("%c_%n", GLOBAL, name);
}

/* output variable space */

outsspac(size)
unsigned size;
{
  if (SIZINT == 2)
    outil("%c%r", SSPACE, size);
  else
    outil("%c%r%r", SSPACE, 0, size);
}

/* output text */

outtext() {
  if (cspace) {
    cspace = STEXT;
    outil("%c", TEXT);
  }
}

/* output data */

outdata() {
  if (cspace != SDATA) {
    cspace = SDATA;
    outil("%c", DATA);
  }
}

/* output bss */

outbss() {
  if (cspace != SBSS) {
    cspace = SBSS;
    outil("%c", BSS);
  }
}

/* output auto definition */

outautdf() {
  outil("%c%r%n", AUTVAR, symloc->sstore, symloc->sname);
}

/* output static definition */

outstdf() {
  outbss();
  outil("%c%r%n", STVAR, symloc->sstore, symloc->sname);
  outsspac(sizeit(symloc));
}

/* output initialized static variable */

outistdf() {
  outdata();
  outil("%c%r%n", STVAR, symloc->sstore, symloc->sname);
}

/* output label */

outlabel(num)
unsigned num;
{
  outtext();
  outil("%c%r", LABEL, num);
}

/* output conditional branch */

outcbra(con, num)
int con;
unsigned num;
{
  short typ;

  typ = (nxtmat-1)->mttype;
  if (typ==STRUCT || typ==UNION)
    rptern(104);
  outtext();
  outil("%c%c%r", CBRNCH, con, num);
}

/* output branch */

outbra(num)
unsigned num;
{
  outtext();
  outil("%c%r", BRANCH, num);
}

/* output switch code */

outswit(lineno, marker)
unsigned lineno;
int *marker;
{
  outil("%c%r%r", SWIT, lineno, deflab);
  while (marker != nxtsw) {
    if (SIZINT == 2)
      outil("%r%r", *(marker+1), *marker);
    else
      outil("%r%r%r%r", 0, *(marker+1), 0, *marker);
    marker += 2;
  }
  cspace = 1;
  outil("%r", 0);
  if (SIZINT == 4)
    outil("%r", 0);
}

/* output register variable definition */

outregdf(sym)
register struct symtab *sym;
{
  outil("%c%r%n", REGVAR, sym->sstore, sym->sname);
}

/* output expression strings */

outstrg() {
  short i;
  struct sstack *p;

  if (strindx) {
    p = strstck;
    for (i=0; i<strindx; i++, p++)
      outil(fstr, "%c%r%0s", STRNG, p->stlbl, p->stptr);
    strindx = 0;
    nxtsst = strings;
    nxtstr = strngbf;
  }
}

/* output bytes */

obytes() {
  short i;

  outil("%c%c", BYTES, ibindx);
  for (i=0; i<ibindx; i++)
    outil("%c", ibstk[i]);
  ibindx = 0;
}

/* output words */

owords() {
  short i;

  outil("%c%c", WORDS, iwindx);
  for (i=0; i<iwindx; i++)
    outil("%r", iwstk[i]);
  iwindx = 0;
}

/* output longs */

olongs() {
  short i;

  outil("%c%c", LONGS, ilindx);
  for (i=0; i<ilindx; i++)
    outil("%r%r", 0, (int) ilstk[i]);
  ilindx = 0;
}

/* output labels */

olabels() {
  short i, t;

  outil("%c%c", LABELS, ilbindx);
  for (i=0; i<ilbindx; i++) {
    t = ilbstk[i].ityp;
#ifdef ALIGN
    outil("%c%r%r", t, 0, ilbstk[i].iofset);
#else
    outil("%c%r", t, ilbstk[i].iofset);
#endif
    if (!t)
      outil("%r", ilbstk[i].ilabn);
    else if (t==2)
      outil("_%n", ilbstk[i].ilabn);
  }
  ilbindx = 0;
}
