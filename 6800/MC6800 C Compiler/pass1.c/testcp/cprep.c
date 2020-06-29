/*******************************************************************/
/*                                                                 */
/*                Stand-alone C Preprocessor Driver                */
/*                                                                 */
/*******************************************************************/

#ifdef M68000
#info 68000 UniFLEX (R) cprep - Stand-alone C preprocessor
#info Version 1.0:0, May 20, 1985
#info Copyright (C) 1985, by
#info Technical Systems Consultants, Inc.
#info All rights reserved.
#tstmp
#else
/*
#info 6809 UniFLEX (R) cprep - Stand-alone C preprocessor
#info Version 1.0:0, May 20, 1985
#info Copyright (C) 1985, by
#info Technical Systems Consultants, Inc.
#info All rights reserved.
*/
#endif

#include  <ctype.h>
#include  <sys/modes.h>
#include  "boolean.h"
#include  "errnum.h"
#include  "miscdefs.h"
#include  "nxtchr.h"
#include  "tables.h"

#ifndef NULL
#define NULL ((char *)0)
#endif

char ilopt;            /* intermediate language flag */
char lstflg;           /* listing flag */
char nobopt;           /* no binary flag */
char qopt;             /* "quick" code flag */
char optf;             /* "firmware" option */
char uopt;             /* "unix" mode */

BOOLEAN new_line;      /* start of new line */
int last_line_number;  /* last known line number */
int lst_lib_nest;     /* last know library nesting level */

extern int line;         /* current line number */
extern int lib_nest;
extern    char ident[NS];
extern    short token;
extern    short class;
extern    char *keytab[];
extern    BOOLEAN inclist;

/*******************************************************************/
/*                                                                 */
/*      Main Program                                               */
/*                                                                 */
/*******************************************************************/

main(argc,argv)
int  argc;
char *argv[];
{
     register  short i;     /* next character */
     BOOLEAN   nxtfil();    /* process next file */
     short     nxtchr();    /* get next character */

     if (prs(argc,argv) != 0) {
          printf("Cannot preset\n");
          flush();
          exit(255);
     }
     inclist = FALSE;       /* turn off listings */
     lstflg = 0;
     while (nxtfil()) {
          new_line = TRUE;       /* start of a new line */
          last_line_number = -2; /* fake the last known line number */
          lst_lib_nest = 0;
          while ( (i=nxtchr()) != FILE_END ){
               if(new_line) {
                    if(line != last_line_number ||
                       lst_lib_nest != lib_nest) {

                         lst_lib_nest = lib_nest;
                         last_line_number = line;
                         if(files->fwad != files->lwad) {
                              printf("#line %d ",line);
                              pstrng(files->fwad+3*sizeof(int));
                              pstrng("\n");
                         }
                    }
                    new_line = FALSE;
               }
               switch (i) {
               case KEYWORD:  printf("%s",keytab[token-1]);
                              break;
               case IDENT:    printf("%s",ident);
                              break;
               case END_IF:   printf("End of -if- expression\n");
                              break;
               default:       printf("%c",i);
                              if(i == '\n') {
                                   ++last_line_number;
                                   new_line = TRUE;
                              }
                              break;
               }
          }
     }
     flush();
}


/*******************************************************************/
/*                                                                 */
/*   perr_line - print error line                                  */
/*                                                                 */
/*******************************************************************/

perr_line()

{    int  lino;     /* Line number scratch */
     char number[7];/* ASCII form of the number */
     int  i;        /* Scratch integer */
     extern BOOLEAN printd;  /* line printed flag */

     if (printd || rline->fwad == rline->lwad) return; /* if no line */

     /* Convert and print the line number */

     lino = *((int *)(files->fwad)); /* Get current line number */
     lino = lino % 10000;          /* Guarantee only 4 digits */
     for (i = 4; i >= 1; i--) {
          number[i] = (char)( (lino%10) + '0');
          lino = lino / 10;
     }
     for (i = 1; i < 4; i++) {
          if(number[i] == '0') number[i] = ' ';
          else break;
     }
     number[0] = ' ';
     number[5] = ':';
     number[6] = '\0';
     to_std_error(number);
     to_std_error("   ");           /* Print spaces */
     to_std_error(rline->fwad);     /* Print the line */
     printd = TRUE; /* indicate "line printed" */
}
/*******************************************************************/
/*                                                                 */
/*  pstrng - print a string                                        */
/*                                                                 */
/*******************************************************************/

pstrng(s)
char *s;
{
     printf("%s",s);
}

/*******************************************************************/
/*                                                                 */
/*  to_std_error - print a string on standard error                */
/*                                                                 */
/*******************************************************************/

to_std_error(s)
char *s;
{   extern int fout;    /* file descriptor */

    flush();
    printf(2,"%s",s);
    flush();
    fout = 1;           /* restore descriptor */
}
