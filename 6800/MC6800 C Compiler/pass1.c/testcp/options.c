/*******************************************************************/
/*                                                                 */
/*                      Option Processing                          */
/*                                                                 */
/*******************************************************************/

#include "boolean.h"
#include "errnum.h"
#include "tables.h"

extern BOOLEAN d_error_printed;    /* 'D' option error */
extern char ilopt;            /* intermediate language flag */
extern char lstflg;           /* listing flag */
extern char nobopt;           /* no binary flag */
extern BOOLEAN printd;        /* line printed flag */
extern char qopt;             /* "quick" code flag */
extern BOOLEAN warn_dup;      /* warn of duplicate definitions */
extern char optf;             /* "firmware" option */
extern char uopt;             /* "unix" mode */
extern BOOLEAN inclist;       /* "include" file listing disable */

BOOLEAN d_opt_proc = FALSE;   /* TRUE when processing 'D' option */
int argc_opt;                 /* argument count */
char **argv_opt;              /* argument array pointer */

/*******************************************************************/
/*                                                                 */
/*   d_option - process +D option                                  */
/*                                                                 */
/*******************************************************************/

d_option()

{  short   i;            /* scratch integer */
   register TABLE tp = rline;    /* table pointer */
   register char *cp;        /* scratch character pointer */
   register char **ap = argv_opt;   /* argument pointer */
   char    c;            /* scratch character */
   BOOLEAN add_data();       /* add data to table */

   d_opt_proc = TRUE;        /* indicate "processing 'D' option" */
   for (i = 1; i < argc_opt; i++){
      if((c = **(++ap)) != '\0') {
         if(c == '+') {
            cp = (*ap)+1;   /* point to first option letter */
            while((c = *cp++) != '\0') {
               if(c == 'D') {
                  if(*cp == '=') ++cp;
                  eline->lwad = eline->ptr1 = eline->ptr2 = eline->fwad;
                  tp->lwad = tp->ptr1 = tp->ptr2 = tp->fwad;
                  printd = TRUE; /* pretend line was printed */
                  while((c = *cp++) != '=' && c != '\0')
                     if(!add_data(tp,&c,sizeof(c))) error(MEMERR);
                  if(tp->lwad - tp->fwad == 0) {
                     non_fatal(CLDEFNAM);
                     break;
                  }
                  if(c == '\0') {
                     if(!add_data(tp," 1\n",4)) error(MEMERR);
                  }
                  else {
                     c = ' ';
                     if(!add_data(tp,&c,sizeof(c))) error(MEMERR);
                     while((c = *cp++) != '\0')
                        if(!add_data(tp,&c,sizeof(c))) error(MEMERR);
                     if(!add_data(tp,"\n",2)) error(MEMERR);
                  }
                  define();   /* add the definition */
                  --cp;    /* point to the null character */
               }
            }
         }
      }
   }
   d_opt_proc = FALSE;    /* clear flags */
   d_error_printed = TRUE;    /* prevent duplicated messages */
   tp->lwad = tp->ptr1 = tp->ptr2 = tp->fwad;   /* empty tables */
   eline->lwad = eline->ptr1 = eline->ptr2 = eline->fwad;
}

/*******************************************************************/
/*                                                                 */
/*   options - process options                                     */
/*                                                                 */
/*******************************************************************/

options()

{  short   i;         /* scratch integer */
   register char *cp; /* scratch character pointer */
   register char **ap = argv_opt;   /* argument pointer */
   char    c;         /* scratch character */
   char    *psep = "/";  /* path separator character */
   BOOLEAN add_data();   /* add data to table */

   for (i = 1; i < argc_opt; i++){
      if((c = **(++ap)) != '\0') {
         if(c == '+') {
            cp = (*ap)+1;   /* point to first option letter */
            while((c = *cp++) != '\0') {
               switch(c) {
               case 'D': while (*cp != '\0') cp++; /* skip */
                     break;
               case 'I': ilopt = '1';   /* enable "il" file */
                     break;
               case 'L': lstflg = '1';  /* enable listing */
                     break;
               case 'N': inclist = FALSE;    /* disable "include" listing */
                     lstflg = '1';      /* enable listing */
                     break;
               case 'U': uopt = '1';    /* indicate "unix" mode */
                     break;
               case 'f': optf = '1';    /* select "firmware"mode */
                     break;
               case 'i': if(*cp == '=') ++cp;
                     if(!add_data(ifiles,cp,strlen(cp)) ||
                        !add_data(ifiles,psep,strlen(psep)+1)) error(MEMERR);
                     while(*cp != '\0') ++cp;
                     break;
               case 'n': nobopt = '1';  /* disable binary */
                     break;
               case 'q': qopt = '1';    /* enable "quick" */
                     break;
               case 'w': warn_dup = TRUE;
                     break;
               default: break;
               }
            }
         }
      }
   }
}
