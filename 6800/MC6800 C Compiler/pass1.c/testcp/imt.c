/*******************************************************************/
/*                                                                 */
/*                  Insert Macro Text                              */
/*                                                                 */
/*******************************************************************/

#include  "boolean.h"
#include  "class.h"
#include  "errnum.h"
#include  "miscdefs.h"
#include  "tables.h"

#define NEST_LIMIT 1000       /* maximum expansions per line */

short     exp_count = 0;      /* definition expansion counter */
extern    BOOLEAN   inif;     /* if in "if" statement */

/*******************************************************************/
/*                                                                 */
/*   cap - copy actual parameters.                                 */
/*                                                                 */
/*******************************************************************/

static int  cap()

/*   Return a count of the number of parameters.
     Returns -1 if an error was detected.    */

/*   On entry "eline->ptr1" points to the leading "(".
     On exit, "eline->ptr1" points to the first character past the ")". */

{    int  parcnt = 0;    /* running parameter count */
     BOOLEAN prot = FALSE; /* "protected" flag; commas not meaningful */
     int  pdepth = 0;    /* nested parentheses level */
     char string = '\0'; /* contains closing quote for string */
     BOOLEAN more_args = TRUE; /* loop control */
     BOOLEAN not_arg_end;     /* loop control */
     int  zero = 0;      /* constant zero */
     BOOLEAN add_data(); /* add data to table */
     BOOLEAN nxtlin();   /* get next line routine */
     char chr;           /* scratch character */

     defarg->lwad = defarg->fwad;  /* set argument table empty */
     eline->ptr1++;                /* skip "(" */
     while (more_args) {
          defarg->ptr1 = defarg->lwad;  /* point to size field */
          if(!add_data(defarg,&zero,sizeof(int))) error(MEMERR);
          while((chr = *eline->ptr1)==' '||chr == '\t')eline->ptr1++;
          not_arg_end = TRUE;
          while(not_arg_end) {
               chr = *eline->ptr1++;    /* get next character */
               if(string == '\0') {     /* if not in a string */
                    switch(chr) {
                    case '\"':
                    case '\'':
                         string = chr;  /*  remember quote mark */
                         prot = TRUE;   /* commas not meaningful */
                         break;
                    case '(':
                         if(string == '\0') {
                              pdepth++;
                              prot = TRUE;
                         }
                         break;
                    case ')':
                         if (pdepth !=  0) { /* if nested */
                              if(--pdepth == 0 ) prot = FALSE;
                         }
                         else {
                              more_args = not_arg_end = FALSE;
                              parcnt++; /* count argument */
                         }
                         break;
                    case ',':
                         if(!prot) { /* if not protected */
                              not_arg_end = FALSE; /* indicate end of arg */
                              parcnt++; /* count argument */
                         }
                         break;
                    case '\n':
                         if(!nxtlin()) return -1; /* no more data, error */
                         chr = '\0';
                         break;
                    }
               }
               else {    /* in a string */
                    if (chr == string) {
                         string = '\0'; /* terminate string */
                         if(pdepth == 0) prot = FALSE; /* remove protection*/

                    }
                    else if (chr == '\\') {
                         if(*eline->ptr1=='\n') { /* if end of line */
                              if(inif) return -1;
                              chr = '\0';   /* ignore */
                              if(!nxtlin()) return -1; /* if no more data */
                         }
                         else {
                              if(!add_data(defarg,&chr,sizeof(char)))
                                                  error(MEMERR);
                              (*(int *)defarg->ptr1)++; /* count character */
                              chr = *eline->ptr1++;  /* get next char */
                         }
                    }
               }
               if(not_arg_end && chr != '\0') {
                    if(!add_data(defarg,&chr,sizeof(char)))error(MEMERR);
                    (*(int *)defarg->ptr1)++; /* count character */
               }
          }
          if(((*(int *)defarg->ptr1) & 1) != 0) {
               chr = '\0';
               if(!add_data(defarg,&chr,sizeof(char)))error(MEMERR);
               (*(int *)defarg->ptr1)++; /* count character */
          }
     }
     return parcnt; /* return the argument count */
}

/*******************************************************************/
/*                                                                 */
/*   imt - insert macro text.                                      */
/*                                                                 */
/*******************************************************************/

imt(p)
char*     p;   /* pointer to definition in "deftab" */

/*   "eline->ptr2" points to start of name in source line.
     "eline->ptr1" points to character after name in source line. */

{    char *cp;      /* scratch character pointer */
     int  *ip;      /* scratch integer pointer */
     char *get_space();  /* get space in table */
     int  body_size;/* size of macro body */
     int  old_size; /* size of text to be replaced */
     int  new_size; /* size of replacement text */
     int  size_dif; /* size difference */
     BOOLEAN substitute();  /* substitute parameters */

     if(++exp_count > NEST_LIMIT) error(TOODEEP); /* if too deep */
     ip = (int *)(p+2*sizeof(int)); /* point to parameter count */
     cp = ((char *)(ip+1))+(*ip)*NSR;     /* point to body size */
     body_size = *(int *)cp;  /* get size of body */
     if(body_size != 0) {
          deftab->ptr2 = cp+sizeof(int);  /* remember body pointer */
          if( get_space(defexp,body_size) == NULL) error(MEMERR);
          move(deftab->ptr2,defexp->fwad,body_size); /* copy body */
     }
     if (*(ip-1) != 0) { /* if there are parameters */
          if(!substitute(p)) non_fatal(PARERR);   /* substitute parameters */
     }
     new_size = defexp->lwad - defexp->fwad; /* compute replacement size */
     old_size = eline->ptr1 - eline->ptr2;   /* compute old text size */
     size_dif = new_size - old_size;         /* compute difference */
     if (size_dif != 0) {        /* if not exact fit */
          int tail_size = eline->lwad-eline->ptr1;
          if(new_size > old_size) {     /* if more space needed */
               if(get_space(eline,new_size-old_size)==NULL)error(MEMERR);
          }
          /*   Move rest of line up or down as needed */
          move(eline->ptr1,eline->ptr1+size_dif,tail_size);
          if(old_size > new_size)eline->lwad += size_dif;
     }
     move(defexp->fwad,eline->ptr2,new_size); /* insert replacement text */
     eline->ptr1 = eline->ptr2;    /* point to new text */
     defexp->lwad = defexp->fwad;  /* empty the expansion table */
}

/*******************************************************************/
/*                                                                 */
/*   substitute - substitute parameters.                           */
/*                                                                 */
/*******************************************************************/

static BOOLEAN substitute(p)
char *p;       /* pointer to definition */

/*   Returns TRUE if no error detected; FALSE otherwise. */

{    char      chr;      /* scratch character */
     BOOLEAN   nxtlin(); /* get next line routine */
     int       parcnt;   /* actual parameter count */
     int       fparcnt;  /* formal parameter count */
     int       i;        /* scratch integer */
     register  char *dp; /* definition pointer */
     BOOLEAN   ch_name();/* check for and assemble a name */
     char      cname[NSR];/* name scratch */
     char      *ap;      /* formal argument pointer */
     BOOLEAN   no_name;  /* loop control */
     int       new_size; /* size of actual parameter */
     int       old_size; /* size of formal parameter */
     int       size_dif; /* size difference */
     char      *ep;      /* scratch character pointer */
     char      *get_space(); /* get space in table routine */

     fparcnt = *(int *)(p+2*sizeof(int)); /* get formal param count */
     deftab->ptr1 = p+3*sizeof(int);  /* point to parameters */
     while(TRUE)  {
          while((chr = *eline->ptr1)==' '||chr == '\t')eline->ptr1++;
          if (chr == '\\' && *(eline->ptr1+1) == '\n') {
               if(!nxtlin()) return FALSE;  /* no more data */
          }
          else  {
               if(chr != '(') return FALSE;
               else break;
          }
     }
     if((parcnt=cap()) == -1) return FALSE; /* parameter error */
     if(fparcnt == 0) return TRUE; /* if no formal, any number are good */
     if(fparcnt != parcnt) return FALSE; /* if incorrect parameter count */
     dp = defexp->fwad;            /* point to start of definition */
     while(dp != defexp->lwad) {   /* search macro body */
          chr = *dp++;   /* get next character */
          switch (CLSCH(chr)) {
          case NUMBER:
               while(dp != defexp->lwad ) {
                    chr = *dp;   /* get a character */
                    if(CLSCH(chr) == SEPAR) {
                         if(chr != '.') break;
                    }
                    dp++;
               }
               break;
          case SEPAR:
               break;
          case ALPHA:
               defexp->ptr2 = --dp;     /* back up pointer and save */
               aname(defexp,cname);     /* assemble the name */
               for(i = 0, ap = deftab->ptr1, no_name = TRUE;
                   no_name && i < fparcnt ;
                   i++, ap += NSR) {
                    if(strcmp(ap,cname) == 0) no_name = FALSE;
               }
               if(no_name) {  /* no formal argument found */
                    dp = defexp->ptr1;  /* skip name */
                    break;
               }
               ap = defarg->fwad;  /* point to first actual parameter */
               while(--i) {
                    ap += *(int *)ap+sizeof(int); /* find parameter */
               }
               new_size = *(int *)ap;
               ap += sizeof(int);
               if(new_size != 0 && *(ap+new_size-1) == '\0')
                    --new_size;
               old_size = defexp->ptr1 - defexp->ptr2;
               size_dif = new_size - old_size;
               if (size_dif != 0) {        /* if not exact fit */
                    if(new_size > old_size) {     /* if more space needed */
                         if((ep = get_space(defexp,new_size-old_size))==NULL)
                            error(MEMERR);
                         defexp->lwad = ep;  /* restore data end */
                    }
                    move(defexp->ptr1,defexp->ptr1+size_dif,
                         defexp->lwad-defexp->ptr1);
                    defexp->lwad += size_dif;
               }
               move(ap,defexp->ptr2,new_size);
               dp = defexp->ptr2+new_size;
               break;
          }
     }
     return TRUE;
}
