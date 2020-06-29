/*******************************************************************/
/*                                                                 */
/*                  Line Management Routines                       */
/*                                                                 */
/*******************************************************************/

#include  "tables.h"
#include  "boolean.h"
#include  "errnum.h"
#define   BUFSIZ  512

int            curr_fd;            /* Current file descriptor */
static    char buffer[BUFSIZ];     /* File buffer */
static    int  bufptr;             /* Buffer pointer */
static    int  chrcnt;             /* Character count in buffer */
int            lib_nest;           /* Library nesting level */
BOOLEAN        comment;            /* "In a comment" flag */
int            quote;              /* Quote flag/character */
extern    BOOLEAN  skip;           /* If skipping lines */
extern    int  if_nest;            /* "if" nesting level */
extern    BOOLEAN  printd;         /* Line printed flag */
extern    int errno;               /* system error number */
int            line;               /* Line number for use by compiler */
extern    short exp_count;         /* macro expansion count */

/*******************************************************************/
/*                                                                 */
/*   dinch - Get one character.                                    */
/*                                                                 */
/*******************************************************************/

int  dinch()

/*   Returns the character as an integer.
     Returns -1 if end of source file encountered. */

{    int  i;   /* scratch integer */
     short entry_length;   /* scratch integer */

     while ( (i=gnc()) == -1) {  /* if an end of file on current file */
          if(curr_fd != -1) {
               close(curr_fd);     /* close the current file */
               curr_fd = -1;
          }
          if (lib_nest == 0) return -1;  /* if not in a library */
          lib_nest--;         /* decrement nesting level */
          entry_length = strlen(files->fwad+3*sizeof(int))+3*sizeof(int)+1;
          entry_length += (entry_length & 1);
          tbrdi(files,files->fwad,entry_length); /* remove entry */
          curr_fd = *(((int *)(files->fwad))+1);     /* get descriptor */
          line = ++(*(int *)(files->fwad));    /* increment line number */
          chrcnt = 0;    /* set the buffer empty */
     }
     return i;   /* return the character */
}

/*******************************************************************/
/*                                                                 */
/*   editline - edit the current line                              */
/*                                                                 */
/*******************************************************************/

BOOLEAN editline()

/*   Returns FALSE if end of file encountered     */

{    BOOLEAN   sigchr;   /* "significant character found" indicator */
     BOOLEAN   spc_flag; /* TRUE if a space just seen */
     register char      chr;      /* scratch character */
     char passchr;
     register  char *lp = rline->ptr1;  /* character pointer in line */

     sigchr = FALSE;  /* indicate "no meaningful character found" */
     spc_flag = FALSE; /* indicate "no space seen" */

     for (;;) {
          chr = *lp++;      /* get next character */
          if (comment) {   /* if in a comment */
               if (chr == '*' && *lp == '/') {
                    comment = FALSE;    /* indicate "not in comment " */
                    lp++;       /* skip slash */
                    continue;
               }
               if (chr == '\n' && sigchr) break; /* if something found */
          }
          else {    /* not in a comment */
               if (quote != 0) {        /* if in a quote */
                    if (chr == '\\')  {
                        passchr = chr;
                         add_data(eline,&passchr,sizeof(char));/* output char */
                         chr = *lp++;      /* get next character */
                    }
                    else      /* not a slash */
                         if (chr == quote || chr == '\n')
                              quote = 0;       /* clear "in quote " */
               }
               else {   /* not in a quote */
                    if (chr == '\'' || chr == '\"') {
                         quote = chr; /* remember quote character */
                         spc_flag = FALSE;
                    }
                    else {  /* not a quote character */
                         if (chr == '/' && *lp == '*') {
                              /*  if start of a comment */
                              lp++;
                              comment = TRUE;
                              continue;
                         }
                         if (chr == ' ' || chr == '\t') {
                              if (spc_flag) {
                                   chr = '\0'; /* set character to a null */
                                   continue;
                              }
                              else {   /* have not seen previous space */
                                   spc_flag = TRUE;
                                   chr = ' ';
                              }
                         }
                         else spc_flag = FALSE; /* not a space or tab */
                    }
               }
          }
          if (chr != '\0' && !comment) {
               if(sigchr = sigchr || chr != '\n') {
                    passchr = chr;
                    add_data(eline,&passchr,sizeof(char));  /* output character */
                    chr = passchr;
               }
          }
          if (chr == '\n') {   /* if end of line */
               rline->ptr1 = lp;   /* update pointer */
               return TRUE;
          }
     }
     rline->ptr1 = lp;   /* update pointer */
     return TRUE;
}

/*******************************************************************/
/*                                                                 */
/*   getlin - get another line from source file.                   */
/*                                                                 */
/*******************************************************************/

BOOLEAN   getlin()

/*   Returns FALSE if end of file  */

{    int  i;   /* scratch integer */
     char chr; /* scratch character */
     char intermediate[80];   /* intermediate buffer */
     register char *iptr = intermediate;
     short ictr = 0;   /* character counter */

     line = ++(*(int *)files->fwad);         /* advance line number */
     rline->ptr1 = rline->lwad = rline->fwad; /* set raw line table empty */
     i = 0;                             /* initialize character */
     while ( i != '\n' && (i=dinch()) != -1 ) {
          *iptr++ = i;   /* store character */
          if((++ictr) == 80) {
               add_data(rline,intermediate,ictr);
               iptr = intermediate;
               ictr = 0;
          }
     }
     if(ictr != 0) add_data(rline,intermediate,ictr);
     if (i == -1) return FALSE;       /* indicate "end of file */
     chr = '\0'; /* null-terminate the line */
     add_data(rline,&chr,sizeof(char));
     printd = FALSE;
     return TRUE;   /* indicate "line ready" */
}


/*******************************************************************/
/*                                                                 */
/*   gnc - Get next character from the current file.               */
/*                                                                 */
/*******************************************************************/

int  gnc()

/*   Returns the character as an integer.
     Returns -1 if end of file encountered.  */

{
     if (chrcnt == 0) {
          if(curr_fd == -1) return -1;  /* if file is closed */
          if ( (chrcnt=read(curr_fd,buffer,BUFSIZ)) == -1) error(errno);
          if (chrcnt == 0) return -1;
          bufptr = 0;
     }
     chrcnt--;
     return (int)buffer[bufptr++];
}

/*******************************************************************/
/*                                                                 */
/*   nxtlin - get next line for the compiler.                      */
/*                                                                 */
/*******************************************************************/

BOOLEAN   nxtlin()

/* Return FALSE if end of file reached */

{    BOOLEAN   getlin();      /* load raw line buffer routine */
     int       prev_quote;    /* quote status temporary */
     BOOLEAN   bad_line;      /* used for loop control */

     bad_line = TRUE;
     while (bad_line) {
          plinex();      /* print any previous line */
          eline->ptr2 = eline->ptr1 = eline->lwad = eline->fwad;
          if (!getlin()) {
               if(if_nest != 0) {
                    if_nest = 0;    /* reset nesting level */
                    rptern(NOENDIF);    /* missing "endif" */
               }
               else if(comment) rptern(UNEXEOF);  /* EOF in comment */
               comment = FALSE;    /* indicate "not in comment" */
               quote = 0;          /* clear quote indicator */
               return FALSE;  /* indicate end of file */
          }
          if ((!comment) && (*rline->fwad == '#')) {
               /* if not inside of a comment and we have a preprocessor
                  command */
               prev_quote = quote;     /* preserve quote status */
               command();              /* process the command */
               quote = prev_quote;     /* restore the quote status */
               continue;               /* get another line */
          }
          exp_count = 0;      /* reset macro expansion counter */
          editline();              /* edit the line */
          if (!skip) bad_line = FALSE;  /* if not skipping, terminate loop */
     }
     return TRUE;
}

/*******************************************************************/
/*                                                                 */
/*   set_new_file - set new source file.                           */
/*                                                                 */
/*******************************************************************/

set_new_file(fd)
int  fd;  /* file descriptor for new file */

{
     if (chrcnt != 0) {  /* if data in the buffer */
          lseek(curr_fd,-(long)chrcnt,1);  /* backspace over data */
          chrcnt = 0;    /* clear the character count */
     }
     curr_fd = fd;       /* store new descriptor */
}
