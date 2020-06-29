/*******************************************************************/
/*                                                                 */
/*                  Define Command Processing                      */
/*                                                                 */
/*******************************************************************/

#include  "boolean.h"
#include  "class.h"
#include  "errnum.h"
#include  "miscdefs.h"
#include  "tables.h"

#ifdef M68000
#define NESIZE 64   /* size of the following structure */
#define NESHIFT 6   /* log2 of NESIZE */
#else
#define NESIZE 16   /* size of the following structure */
#define NESHIFT 4   /* log2 of NESIZE */
#endif

struct    name_entry {
     char nam[NSR];
     int    nbr;
#if NESIZE-NSR-sizeof(int)
     char pad[NESIZE-NSR-sizeof(int)];
#endif
};


BOOLEAN   warn_dup = FALSE;   /* warn of duplicate definitions */
extern    BOOLEAN   comment;  /* comment flag */
extern    int       quote;    /* "in quote" flag */
extern    char *keytab[];     /* keyword table */
extern    BOOLEAN d_opt_proc; /* 'D' option processing flag */

int  deftag = 0;    /* definition number */

/*******************************************************************/
/*                                                                 */
/*   define - process "define" command                             */
/*                                                                 */
/*******************************************************************/

define()

{    char      chr;      /* scratch character */
     BOOLEAN   getlin(); /* get next line */
     BOOLEAN   editline(); /* edit current line */
     char      cname[NSR];/* name scratch */
     BOOLEAN   no_error = TRUE; /* loop control */
     short     errnum;   /* error number to report */
     char*     sdt();    /* search definition table */
     char*     defptr;   /* definition pointer */
     int*      ip;       /* scratch integer pointer */
     int       i;        /* scratch integer */
     int       j;        /* scratch integer */
     BOOLEAN   add_data(); /* add data to table */
     char      skip_sep(); /* skip parameter separator */
     BOOLEAN   more_line;  /* loop control variable */
     BOOLEAN   put_name(); /* add name to name table */
     short     lookup();   /* list lookup routine */
     BOOLEAN   ch_name();  /* check for name */
     BOOLEAN   name_put = FALSE;   /* error control */

     errnum = d_opt_proc? CLDEFNAM:DEFNAM;   /* preset error */
     deftab->ptr2 = deftab->lwad;  /* remember current table end */

     /*   Skip spaces and check for an alphabetic character (start of
          name).  Allow continuations between "define" and the name */

     do {
          if(ch_name(cname)) break;     /* if a name, exit loop */
          if (!d_opt_proc && *rline->ptr1 == '\\' && *(rline->ptr1+1) == '\n') {
               plinex();      /* print the line */
               no_error = getlin();     /* get another line */
          }
          else  no_error = FALSE;   /* not continuation */
     } while(no_error);

     /*   If we did find the start of a name, make sure that it is not
          an attempt to redefine a keyword.*/

     if(no_error){
          if(lookup(keytab,cname) != 0) no_error = FALSE;
     }

     /*   If we have a legitimate name, check for duplicates.  If
          a duplicate is found, remove it from the definition table.
          Issue a warning message about the duplicate if the user has
          so requested through a command line option. */

     if (no_error) {
          if( (defptr=sdt(cname)) != NULL) { /* if duplicate found */
               rem_def(defptr);              /* remove definition */
               deftab->ptr2 = deftab->lwad;  /* reset ending address */
               if(warn_dup) {                /* warn of duplicate */
                    pline();                 /* print the line */
                    non_fatal(d_opt_proc? CLDUPERR:DUPERR);
               }
          }
          errnum = d_opt_proc? CLDEFARG: DEFARG;  /* preset error */

          /*   Start construction of table entry for the definition.
               The name goes first, followed by a size field which
               reflects the number of bytes to skip to reach the next
               entry in the table.  This is followed by a flag which,
               if non-zero, indicates that parameters were specified.
               This, in turn, is followed by a parameter count and
               the parameters themselves.  If no parameters are present,
               a count of zero stored.  */

          deftag = deftab->lwad - deftab->fwad;   /* determine offset */
          if(!(name_put = put_name(cname,deftag)))error(MEMERR);
          i=0;  /* clear size and parameters flag */
          if(!add_data(deftab,&i,sizeof(int)))error(MEMERR);
          if(!add_data(deftab,&i,sizeof(int)))error(MEMERR);
          deftab->ptr1 = deftab->lwad; /* remember next location */
          if(!add_data(deftab,&i,sizeof(int)))error(MEMERR);
          if(*rline->ptr1 == '(') {          /* if parameters specified */
               *(int *)(deftab->ptr1-sizeof(int)) = 1; /* set flag */
               ++rline->ptr1;      /* skip "(" */
               do {
                    if(ch_name(cname)){ /* if a name, put in table */
                         if(!add_data(deftab,cname,NSR))error(MEMERR);
                         (*(int *)deftab->ptr1)++;  /* advance count */
                         no_error= !((chr=skip_sep()) == '\0');
                    }
                    else {
                         if((chr = *rline->ptr1)==')' &&
                            *(int *)deftab->ptr1 == 0){  /* if "()" */
                              rline->ptr1++; /* skip ")" */
                              break;
                         }
                         if(chr == '\\' && *(rline->ptr1+1) == '\n') {
                              if(d_opt_proc) {
                                   no_error = FALSE;
                                   break;
                              }
                              plinex();      /* print the line */
                              no_error=getlin(); /* get another line */
                              chr = ',';     /* set fake separator */
                              continue;      /* try for another name */
                         }
                    }
               } while (chr == ',' && no_error);
               if(no_error) no_error = chr == ')';
          }

          /*   After the parameters (if any) is the size of the body
               of the definition.  Following that is the definition
               body proper.   */

          eline->lwad = eline->fwad;    /* empty the edited line table */
          while((chr = *rline->ptr1)==' ' || chr == '\t')rline->ptr1++;
          more_line = editline();       /* edit rest of line */
          while (!d_opt_proc && more_line) {
               if(!comment) {
                    if ((eline->lwad-eline->fwad > 1) &&
                         (*(eline->lwad-2) == '\\')) {
                              *(eline->lwad-2) = ' ';
                              eline->lwad--;
                    }
                    else more_line = FALSE;
               }
               if(more_line) {
                    plinex();
                    more_line = getlin() && editline();
               }
          }

          /*   Compute the size.  Put the size and the macro body
               into the table.  This works only because "deftab" is
               higher than "eline" in memory. */

          i = eline->lwad-eline->fwad;  /* compute size of body */
          if(i != 0 && *(eline->lwad-1) == '\n') {/* remove any CR */
               i--;
               eline->lwad--;
          }
          if(!add_data(deftab,&i,sizeof(int)))error(MEMERR);
          if(i != 0 &&
             !add_data(deftab,eline->fwad,i)) error(MEMERR);

          i = deftab->lwad-deftab->ptr2;
          if(i & 1) {    /* if the size is an odd number */
               chr = '\0';    /* pad to even number */
               if(!add_data(deftab,&chr,sizeof(chr))) error(MEMERR);
               ++i;
          }
          *(int *)(deftab->ptr2) = i;
                                             /* store the size */
     }
     if (!no_error) {
          pline();                      /* print the line */
          non_fatal(errnum);  /* definition error */
          deftab->lwad = deftab->ptr2;  /* reset table end */
          if(name_put) tbrdi(defnam,defnam->ptr2,sizeof(struct name_entry));
     }
     comment = FALSE;         /* guarantee edit variables clear */
     quote = 0;
}

/*******************************************************************/
/*                                                                 */
/*   undef - process "undef" command.                              */
/*                                                                 */
/*******************************************************************/

undef()

{    BOOLEAN   ch_name();     /* check name routine */
     char      cname[NS];     /* name temporary */
     char      *cp;           /* scratch character pointer */

     while(ch_name(cname)) {  /* check for name */
          if ( (cp=sdt(cname)) != NULL) rem_def(cp);
     }
}

/*******************************************************************/
/*                                                                 */
/*   ch_name - check for, and assemble, a name                     */
/*                                                                 */
/*******************************************************************/

BOOLEAN ch_name(p)
char *p;       /* pointer to area in which to store name */

/*   Return TRUE if a name was found  */

{    char      chr;      /* scratch character */
     register  char *lp = rline->ptr1;  /* line pointer */

     while ((chr = *lp) == ' ' || chr == '\t')lp++;
     if (CLSCH(chr) != ALPHA) {
          rline->ptr1 = lp;   /* update pointer */
          return FALSE; /* if no name found */
     }
     rline->ptr2 = rline->ptr1 = lp;    /* point to start of name */
     aname(rline,p);               /* assemble the name */
     return TRUE;
}

/*******************************************************************/
/*                                                                 */
/*   put_name - store definition name in name table                */
/*                                                                 */
/*******************************************************************/

static BOOLEAN put_name(n,t)
char *n;       /* pointer to the name */
int t;         /* definition offset */

/*   On entry, defnam->ptr1 is the insertion address.
     Returns FALSE if an error is detected.
     defnam->ptr2 points to the location of the name */

{    char      *get_space();  /* get space in table */
     struct    name_entry definition;   /* table entry */
     int       tail_size;     /* size of data beyond insertion point */

     strcpy(definition.nam,n);
     definition.nbr = t;
     tail_size = defnam->lwad - defnam->ptr1;
     if(get_space(defnam,sizeof(definition)) == NULL)
          return FALSE;
     if(tail_size != 0)
          move(defnam->ptr1,defnam->ptr1+sizeof(definition),tail_size);
     move(&definition,defnam->ptr1,sizeof(definition));
     return TRUE;
}

/*******************************************************************/
/*                                                                 */
/*   rem_def - remove definition                                   */
/*                                                                 */
/*******************************************************************/

static rem_def(p)
char *p;  /* pointer to the definition body */

{    int       i;   /* scratch integer */
     int       tag; /* scratch integer */
     register struct name_entry *nep;   /* name pointer */
     register struct name_entry *ep;    /* ending name pointer */

     tag = ((struct name_entry *)(defnam->ptr1))->nbr;
     i = *(int *)p;  /* compute size of item */
     tbrdi(deftab,p,i);            /* remove the item */
     tbrdi(defnam,defnam->ptr1,sizeof(struct name_entry));
     for(nep=(struct name_entry *)defnam->fwad,
         ep=(struct name_entry *)defnam->lwad;
         nep < ep; nep++) {
          if(nep->nbr > tag) nep->nbr -= i;  /* adjust offset */
     }
}

/*******************************************************************/
/*                                                                 */
/*   sdt - search definition table                                 */
/*                                                                 */
/*******************************************************************/

char *sdt(n)
char *n;       /* pointer to name for which to search */

/*   Returns a pointer to the definition in the "deftab" table.
     Returns NULL if not found. */

{    int  snt();    /* search name table */
     int  tag;      /* definition tag */

     if((tag=snt(n)) == -1)return NULL;   /* if not in name table */
     return deftab->fwad + tag;    /* return pointer to body */
}

/*******************************************************************/
/*                                                                 */
/*   skip_sep - skip parameter separator                           */
/*                                                                 */
/*******************************************************************/

static char skip_sep()

/*   Returns the separator character skipped.  Returns the null
     character if end of file reached.  */

{    char      chr;      /* scratch character */
     register char *cp;  /* character pointer */

     cp = rline->ptr1;
     while(TRUE) {
          while((chr = *cp++) == ' ' || chr == '\t');
          if(chr == '\\' && *cp == '\n') { /* if continuation */
               rline->ptr1 = cp;   /* update pointer */
               plinex();           /* print the line */
               if(!getlin()) {     /* if no more lines */
                    return '\0';   /* return EOF indicator */
               }
               cp = rline->ptr1;
               continue;
          }
          else {
               rline->ptr1 = cp;   /* update pointer */
               return chr;
          }
     }
}

/*******************************************************************/
/*                                                                 */
/*   snt - search name table                                       */
/*                                                                 */
/*******************************************************************/

int snt(n)
char *n;            /* pointer to name */

/*   Returns the tag number of the definition and "ptr1" points to the
     entry.
     Returns -1 if not in the table and "ptr1" is the insertion point. */

{    register char *low = defnam->fwad;
     register char *high = defnam->lwad;
     register struct name_entry *current;   /* entry being examined */
     int  result = 1;    /* comparison result */

     while(low != high) {
          current = (struct name_entry *)(low + ((((unsigned)(high-low))>>(NESHIFT+1))<<NESHIFT));
          if((result=strcmp(n,current->nam)) == 0) {
               defnam->ptr1 = (char *)current;
               return current->nbr;
          }
          else {
               if(result < 0) high = (char *)current;
               else low = (char *)(current + 1);
          }
     }
     defnam->ptr1 = high;
     return -1;
}
