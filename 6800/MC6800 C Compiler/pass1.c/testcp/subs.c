/*******************************************************************/
/*                                                                 */
/*                  Miscellaneous Subroutines.                     */
/*                                                                 */
/*******************************************************************/

#include  "boolean.h"
#include  "class.h"
#include  "errnum.h"
#include  "miscdefs.h"
#include  "tables.h"

#define REGISTER register

extern    short class;    /* class of character */
extern    BOOLEAN   skip; /* TRUE if skipping */

BOOLEAN   d_error_printed = FALSE; /* 'D' option error printed */
int       define();      /* "define" processor */
int       else_com();    /* "else" processor */
int       endif();       /* "endif" processor */
int       ifdef();       /* "ifdef" processor */
int       ifexpr();      /* "if expression" processor */
int       ifndef();      /* "ifndef" processor */
int       include();     /* "include" processor */
int       line_com();    /* "line" processor */
int       info();        /* "info" processor */
int       undef();       /* "undef" processor */

struct    jmptab    {
          char *mat_str;      /* match string */
          int  (*proc)();     /* processor function */
          };

struct    jmptab    comtab[] = {
     {    "define",define },
     {    "include",include },
     {    "info",info },
     {    "tstmp",info },
     {    "line",line_com },
     {    "undef",undef },
     {    0,0  }  /*  end of table */
     };

struct    jmptab    iftab[] = {
     {    "if",ifexpr },
     {    "ifdef",ifdef },
     {    "ifndef",ifndef },
     {    "else",else_com },
     {    "endif",endif },
     {    0,0  }    /* end of table */
     };

/*******************************************************************/
/*                                                                 */
/*   aname() -- assemble name                                      */
/*                                                                 */
/*******************************************************************/

aname(tp,p)       /* assemble name */
REGISTER struct table *tp; /* pointer to table to use */
REGISTER char *p;          /* pointer to array for name (NS chars long) */

                  /* tp->ptr2 points to start of the name in the source.
                     On exit, tp->ptr1 points to character following the
                     name. */

{    int  chrcnt;   /* character counter */
     REGISTER char chr;      /* scratch character */
     register char *cp;  /* scratch character pointer */

     cp = tp->ptr1 = tp->ptr2;          /* point to start of name */
     chrcnt = 0;                   /* initialize counter */
     do {
          chr = *cp++;       /* get next character */
          chrcnt++;                /* count character */
          if ((class=CLSCH(chr)) != SEPAR)
               if(chrcnt < NS) *p++ = chr;     /* store character in name */
     } while (class != SEPAR && cp < tp->lwad);
     *p = '\0';                    /* terminate name */
     tp->ptr1 = class == SEPAR? cp-1: cp;    /* update pointer */
}

/*******************************************************************/
/*                                                                 */
/*   command - preprocessor command                                 */
/*                                                                 */
/*******************************************************************/

command()       /* preprocessor command */

{    char cname[NS];     /* command name */
     struct jmptab *fp;  /* command table entry */
     struct jmptab *find_com();  /* command decoder */

     rline->ptr2 = rline->fwad+1;  /* initialize pointer */
     while(*rline->ptr2 == ' ' || *rline->ptr2 == '\t')rline->ptr2++;
     if(*rline->ptr2 != '\n') {    /* if not a null command */
          aname(rline,cname);                 /* assemble the name */
          if ( (fp=find_com(comtab,cname)) != NULL ) {
               if(!skip) (*fp->proc)();
               else plinex();
          }
          else {
               if((fp=find_com(iftab,cname)) != NULL ) (*fp->proc)();
               else {
                    if(skip) plinex();
                    else non_fatal(CMDERR);  /* command error */
               }
          }
     }
}

/*******************************************************************/
/*                                                                 */
/*   find_com - look up preprocessor command                       */
/*                                                                 */
/*******************************************************************/

struct jmptab *find_com(t,n)
struct jmptab *t;  /* table pointer (array of "jmptab" structures. Table
                      is terminated by a null string pointer */
char *n;           /* pointer to the null terminated name */

/*   Return the processor address if found; NULL otherwise. */

{
     while (t->mat_str != NULL) {
          if(strcmp(t->mat_str,n) == 0) return t;
          t++;
     }
     return NULL;
}

/*******************************************************************/
/*                                                                 */
/*   lookup -- search for name in list.                            */
/*                                                                 */
/*******************************************************************/

short lookup(t,n)
char **t;      /* table pointer (array of pointers to strings). Table
                  is terminated by a null pointer */
char *n;       /* pointer to the null terminated name */

/*   Return the index of the entry plus 1.  Returns zero if not found */

{    register char *tp;       /* table string pointer */
     register char *np;       /* name pointer */
     char **ts;     /* table starting address */
     char chr;      /* scratch character */

     ts = t;             /* remember start of table */
     while (tp = *t++) {   /* if not at end of table */
          np = n;
          while((chr = *np++) == *tp++) {
               if(chr == '\0') return t-ts;
          }
     }
     return 0;           /* indicate "not found" */
}

/*******************************************************************/
/*                                                                 */
/*   non_fatal - issue message for non-fatal errors                */
/*                                                                 */
/*******************************************************************/

non_fatal(errno)
int  errno;    /* Error number */

{    switch (errno) {
     case CLDUPERR:
     case CLDEFARG:
     case CLDEFNAM: if(!d_error_printed) {
                         if((rline->lwad - rline->fwad) != 0) {
                              pstrng("#define ");
                              pstrng(rline->fwad);     /* print line */
                         }
                    }
                    else break;
     default: rptern(errno);
     }
}
