/*******************************************************************/
/*                                                                 */
/*                  Symbol Table Management                        */
/*                                                                 */
/*******************************************************************/

#include  "boolean.h"
#include  "errnum.h"
#include  "miscdefs.h"
#include  "symbol.h"
#include  "tables.h"

extern char blklev;      /* block level */
extern char strnum;      /* structure number */
extern char ident[];     /* current name */

static char *st_base = (char *)(0); /* last known base of symbol table */
static char *lt_base = (char *)(0); /* last known base of label table */

/*******************************************************************/
/*                                                                 */
/*   addsym - add symbol to table                                  */
/*                                                                 */
/*******************************************************************/

struct symtab *addsym(t)
char t;   /* symbol type */

{    TABLE     stp;           /* symbol table pointer */
     TABLE     ntp;           /* name table pointer */
     char      *base;         /* last known base value */
     struct    symtab    s;   /* scratch symbol table entry */
     struct    symtab    *r;  /* response */
     char      *get_space();  /* get space in table */
     char      *np;           /* name pointer */
     short     ns;            /* length of name including null byte */

     if(t != SLABEL) {
        stp = sym_table;    /* select symbol table */
        ntp = sym_name;     /* select symbol name table */
        base = st_base;     /* select last known base address */
     }
     else {
        stp = lab_table;    /* select label table */
        ntp = lab_name;     /* select label name table */
        base = lt_base;     /* select last known base address */
     }

     /*   Clear out the symbol table entry */

     s.stype = s.sstore = s.sstrct = s.spoint = 0;
     s.ssubs = (char *)0;
     s.sstrnum = s.smemnum = s.sclass = s.sflags = s.sblklv = '\0';
     s.sitype = t; /* store symbol type */
     if((np=get_space(ntp,(ns = strlen(ident) + 1))) == NULL) error(MEMERR);
     strcpy(np,ident);  /* copy the name */
     s.sname = base + (np-ntp->fwad);   /* store pointer */
     if( (r=(struct symtab *)get_space(stp,sizeof(s))) == NULL) error(MEMERR);
     move(&s,r,sizeof(s));
     plug_addresses();  /* adjust base addresses if necessary */
     return r;
}

/*******************************************************************/
/*                                                                 */
/*   entblock - entry into a block                                 */
/*                                                                 */
/*******************************************************************/

int entblock()

/*   Returns the offset of the end of the symbol table */

{
     return sym_table->lwad - sym_table->fwad;
}

/*******************************************************************/
/*                                                                 */
/*   exitblck - exit block, remove entries from table              */
/*                                                                 */
/*******************************************************************/

exitblck(o)
int  o;        /* offset for new end of symbol table */

{
     if(sym_table->lwad != sym_table->fwad + o) {
        sym_name->lwad = ((struct symtab *)(sym_table->fwad + o))->sname;
        sym_table->lwad = sym_table->fwad + o;
     }
}

/*******************************************************************/
/*                                                                 */
/*   lookblk - search symbol table at block level                  */
/*                                                                 */
/*******************************************************************/

struct symtab *lookblk(t)
char t;        /* symbol type */

{    TABLE tp;                       /* scratch table pointer */
     register struct symtab *ep;     /* structure pointer */
     register struct symtab *ts;     /* table start as a structure pointer */

     tp = t == SLABEL? lab_table: sym_table; /* select table */
     if(blklev != 0) {
          ep = (struct symtab *)tp->lwad;    /* end of table */
          ts = (struct symtab *)tp->fwad;    /* start of table */

          while ((--ep) >= ts) {
               if(blklev == ep->sblklv &&
                  ep->sitype == t &&
                  strcmp(ep->sname,ident) == 0 &&
                  (t == SMEMBER? strnum == ep->smemnum: TRUE)) return ep;
          }
     }
     else {
          ts = (struct symtab *)tp->lwad;    /* end of table */
          ep = (struct symtab *)tp->fwad;    /* start of table */

          while (ep != ts) {
               if(blklev == ep->sblklv &&
                  ep->sitype == t &&
                  strcmp(ep->sname,ident) == 0 &&
                  (t == SMEMBER? strnum == ep->smemnum: TRUE)) return ep;
               ep++;
          }
     }
     return NULL;
}

/*******************************************************************/
/*                                                                 */
/*   looksym - search symbol table                                 */
/*                                                                 */
/*******************************************************************/

struct symtab *looksym(t)
char t;        /* symbol type */

{    TABLE tp;                       /* scratch table pointer */
     register struct symtab *ep;     /* structure pointer */
     register struct symtab *ts;     /* table start as a structure pointer */

     tp = t == SLABEL? lab_table: sym_table; /* select table */
     ep = (struct symtab *)tp->lwad;    /* end of table */
     ts = (struct symtab *)tp->fwad;    /* start of table */

     while ((--ep) >= ts) {
          if(ep->sitype == t &&
             strcmp(ep->sname,ident) == 0 &&
             (t == SMEMBER? strnum == ep->smemnum: TRUE)) return ep;
     }
     return NULL;
}

/*******************************************************************/
/*                                                                 */
/*   strtfnct - start new function, clear label table              */
/*                                                                 */
/*******************************************************************/

strtfnct()

{
     lab_table->lwad = lab_table->fwad;
     lab_name->lwad = lab_name->fwad;
}

/*******************************************************************/
/*                                                                 */
/*   plug_addresses - adjust base addresses                        */
/*                                                                 */
/*******************************************************************/

static plug_addresses()

{   register struct symtab *p;  /* symbol table entry pointer */
    register struct symtab *l;  /* ending address for search */
    register int offset;        /* amount to adjust */

    if( (offset = sym_name->fwad - st_base) != 0 &&
        sym_name->fwad != sym_name->lwad) {

        l = (struct symtab *)sym_table->lwad;
        for(p = (struct symtab *)sym_table->fwad ; p < l; p++) {

            p->sname += offset;
        }
        st_base = sym_name->fwad;
    }
    if( (offset = lab_name->fwad - lt_base) != 0 &&
        lab_name->fwad != lab_name->lwad) {

        l = (struct symtab *)lab_table->lwad;
        for(p = (struct symtab *)lab_table->fwad ; p < l; p++) {

            p->sname += offset;
        }
        lt_base = lab_name->fwad;
    }
}
