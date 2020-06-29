/*******************************************************************/
/*                                                                 */
/*   Conditional Processing (if,ifdef,ifndef,else,endif)           */
/*                                                                 */
/*******************************************************************/

#include  "boolean.h"
#include  "errnum.h"
#include  "miscdefs.h"
#include  "nxtchr.h"
#include  "tables.h"

int  if_nest = 0;        /* nesting level */
BOOLEAN   skip = FALSE;  /* skip lines flag */
static    int  skip_level = 0;     /* skipping level */
extern    int  pp_if_result;  /* "if expression" result */
extern    BOOLEAN comment;    /* comment flag */
extern    int  quote;         /* quote flag/character */
BOOLEAN   inif = FALSE;       /* if in "if" expression */

/*******************************************************************/
/*                                                                 */
/*   ifexpr - if expression processing                             */
/*                                                                 */
/*******************************************************************/

ifexpr()

{    BOOLEAN   editline();    /* line editor */
     BOOLEAN   no_go = FALSE; /* error flag */
     short     nxtchr();      /* get next character routine */
     short     i;             /* scratch integer */
     extern char ident[];

     if_nest++;     /* increment nesting level */
     if(!skip) {    /* if not skipping */
          if(!editline() || comment || quote != 0)no_go = TRUE;
          else {
               /* Force expansion of macroes by repeatedly calling
                  "nxtchr" until the entire line is processed.  Any
                  response of "keyword" or "identifier" is considered
                  an error. */

               inif = TRUE;
               while ( (i=nxtchr()) != END_IF);
               inif = TRUE;   /* reset "in if" flag */
               eline->ptr1 = eline->fwad; /* reset pointer */
               if(ppcexp() == 0) no_go = TRUE; /* if error */
               else {
                    if(pp_if_result == 0) {
                         skip_level = if_nest;
                         skip = TRUE;
                    }
               }
          }
     }
     if(no_go) {    /* if an error occurred somewhere */
          inif = FALSE;
          comment = FALSE; /* clear editing flags */
          quote = 0;
          eline->ptr1 = eline->lwad;    /* skip rest of line */
          non_fatal(EXPERR);  /* issue error message */
     }
}

/*******************************************************************/
/*                                                                 */
/*   ifdef - check for defined                                     */
/*                                                                 */
/*******************************************************************/

ifdef()

{    char *sdt();        /* search definition table routine */
     BOOLEAN ch_name();  /* check and assemble name routine */
     char cname[NS];     /* name scratch */

     if_nest++;          /* increment nesting level */
     if(!skip) {         /* if not skipping */
          if(ch_name(cname)) {     /* if a name exists */
               if(!sdt(cname)) {   /* if name not found */
                    skip = TRUE;
                    skip_level = if_nest; /* remember skipping level */
               }
          }
          else non_fatal(IFNERR);  /* bad name in conditional */
     }
}

/*******************************************************************/
/*                                                                 */
/*   ifndef - check for not defined                                */
/*                                                                 */
/*******************************************************************/

ifndef()

{    char *sdt();        /* search definition table routine */
     BOOLEAN ch_name();  /* check and assemble name routine */
     char cname[NS];     /* name scratch */

     if_nest++;          /* increment nesting level */
     if(!skip) {         /* if not skipping */
          if(ch_name(cname)) {     /* if a name exists */
               if(sdt(cname)) {    /* if name found */
                    skip = TRUE;
                    skip_level = if_nest; /* remember skipping level */
               }
          }
          else non_fatal(IFNERR);  /* bad name in conditional */
     }
}

/*******************************************************************/
/*                                                                 */
/*   endif - terminate conditional                                 */
/*                                                                 */
/*******************************************************************/

endif()

{
     if(if_nest == 0) non_fatal(IFDERR);     /* if no preceding "if" */
     else {
          if(skip) {     /* if skipping code */
               if (if_nest == skip_level) {  /* if at skip level */
                    skip = FALSE;            /* turn off skip */
                    skip_level = 0;
               }
          }
          if_nest--;     /* decrement nesting level */
     }
}

/*******************************************************************/
/*                                                                 */
/*   else - else command                                           */
/*                                                                 */
/*******************************************************************/

else_com()

{
     if(if_nest == 0) non_fatal(IFDERR);     /* if no preceding "if" */
     else {
          if(skip) { /* if skipping */
               if(if_nest == skip_level) { /* if at correct level */
                    skip = FALSE;  /* stop skipping */
                    skip_level = 0;
               }
          }
          else {
               skip_level = if_nest;    /* set skip level */
               skip = TRUE;             /* commend skipping */
          }
     }
}
