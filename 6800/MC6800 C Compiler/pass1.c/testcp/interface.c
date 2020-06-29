/*******************************************************************/
/*                                                                 */
/*             Routines Called by the Compiler Proper              */
/*                                                                 */
/*******************************************************************/

#include  "boolean.h"
#include  "class.h"
#include  "errnum.h"
#include  "miscdefs.h"
#include  "nxtchr.h"

BOOLEAN   inclist = TRUE;/* list "include" files */
char      ident[NS];     /* Identifier name */
short     token;         /* Token from keyword table */
short     class;         /* Class of character */
extern    BOOLEAN inif;  /* TRUE if in an "if" expression */
extern    int errno;     /* system error number */
extern    int lib_nest;  /* library nesting level */
extern    int quote;     /* current quote character */
extern    BOOLEAN skip;  /* TRUE if skipping lines */
extern    BOOLEAN comment;    /* TRUE if in a comment */

char *keytab[]=  /* Keyword table. Index + 1 is token value */
   { "int","char","long","short","unsigned",
     "float","double","struct","union","enum",
     "void","","","auto","static",
     "register","extern","typedef","","goto",
     "return","sizeof","break","continue","if",
     "else","for","do","while","switch",
     "case","default","entry",
     0 };


/*   Variables referenced within the C compiler proper */

extern    char lstflg;   /* Listing flag */

/*   Managed Table Definitions */

#include "tbdef.h"

TABLE infotab; /* "info" statements */
TABLE ifiles;  /* "include" file search paths */
TABLE path;    /* Current path for "include" searching */
TABLE files;   /* Source and "include" file stack */
TABLE rline;   /* Raw input line */
TABLE eline;   /* Edited input line */
TABLE defnam;  /* Definition names */
TABLE deftab;  /* Definitions and macroes */
TABLE incfil;  /* "include" file and path */
TABLE defarg;  /* Actual arguments in macro call */
TABLE defexp;  /* Expanded macro */
TABLE sym_table;    /* Symbol table */
TABLE lab_table;    /* Line label table */
TABLE sym_name;     /* Symbol names */
TABLE lab_name;     /* Label names */

/*   Command line related variables  */

static int       argcnt;   /* Argument count */
static char      **aptr;   /* Pointer to argument array */
extern int       argc_opt; /* Argument count for option processor */
extern char      **argv_opt;  /* Argument array pointer for option processor */

/*   Miscellaneous Variables  */

extern    int       curr_fd;  /* Current file descriptor */
BOOLEAN   printd;   /* TRUE if current line already printed */

/*******************************************************************/
/*                                                                 */
/*   get_info - return any "info" information                      */
/*                                                                 */
/*******************************************************************/

char *get_info()

{    BOOLEAN   add_data();    /* add data to table */
     char      chr;           /* scratch character */

     if(infotab->lwad == infotab->fwad) return NULL; /* if no info */
     chr = '\0';    /* null-terminate the table */
     if(!add_data(infotab,&chr,sizeof(char))) error(MEMERR);
     infotab->lwad = infotab->fwad; /* empty the table */
     return infotab->fwad;
}

/*******************************************************************/
/*                                                                 */
/*   nxtchr -- return next character                               */
/*                                                                 */
/*******************************************************************/

short nxtchr()            /* Return next character */

{    char chr;                  /* scratch character */
     static char    prev_char;  /* previous character */
     static char    string;     /* contains quote character for string */
     static BOOLEAN innumb;     /* TRUE if processing a number */
     char*          defptr;     /* definition pointer */
     char*          sdt();      /* search definition table */
     short          lookup();   /* table lookup routine */
     BOOLEAN        nxtlin();   /* get next line */

 while(TRUE) {
     while(eline->ptr1 == eline->lwad) {/* if table is empty */
          if (inif) {    /* if in "if", terminate expression */
               inif = FALSE;
               return END_IF;
          }
          plinex();                     /* print current line */
          if (!nxtlin()) return FILE_END;  /* if no more data */
     }
     chr = *eline->ptr1++;              /* get character */
     class = CLSCH(chr);                /* classify the character */
     if (string != '\0') {              /* if in a string */
          if(prev_char != '\\') {       /* if previous not escape char */
               prev_char = chr;         /* update previous character */
               if(chr == string || chr == '\n' ) string = '\0';
          }
          else prev_char = (chr == '\\')? '\0':chr; /* update previous */
          return (short)chr;            /* return the character */
     }
     if (chr == '\'' || chr == '\"') {  /* if start of string */
          string = chr;                 /* remember quote mark */
          innumb = FALSE;               /* indicate "not a number" */
          return (int)chr;              /* return the character */
     }
     if (innumb) {                      /* if processing a number */
          if (class == SEPAR && chr != '.') innumb = FALSE; /* end of number */
          return (int)chr;              /* return the character */
     }
     if (class == NUMBER) innumb = TRUE;
                                        /* indicate "processing number" */
     if (class != ALPHA) return (int)chr; /* if not a name, return character*/
     eline->ptr2 = eline->ptr1 - 1;     /* remember start of name */
     aname(eline,ident);                /* assemble the name */
     if ((token=lookup(keytab,ident)) != 0) return KEYWORD; /* if keyword */
     if ((defptr=sdt(ident)) == NULL) return IDENT; /* if not definition */
     imt(defptr);                       /* insert the macro text */
 }
}

/*******************************************************************/
/*                                                                 */
/*   nxtfil - process next file from command line.                 */
/*                                                                 */
/*******************************************************************/

char *nxtfil()

/*   Returns a pointer to the file name.  Returns NULL if not more
     files to process.   */

{    char chr;  /* scratch character */
     char *cp;  /* scratch character pointer */
     int  i;    /* scratch integer */
     char *get_space();  /* Managed Table space allocator routine */
     char *rindex();     /* find last occurrence routine */
     BOOLEAN add_data(); /* Add data to a managed table */

     /* Empty some tables */

     eline->ptr1 = eline->lwad = eline->fwad;
     path->lwad = path->fwad;
     files->lwad = files->fwad;
     reset();  /* clear definitions and symbols */
     comment = skip = FALSE;  /* reset comment and skip flags */
     quote = 0;     /* clear quote flag */
     d_option();    /* process 'D' options */

     /* Get the next file name.  */

     while (--argcnt) {
          if (**(++aptr) == '+') continue;  /* if an option */

          /* Process .c file.  The entire argument in put in
             the "files" table.  Any leading path
             information is put in the "path" table. */

          /* Initialize the line number, file descriptor, and "name
             printed" flag to zero. */

          i = 0;
          if (!add_data(files,&i,sizeof(int))) error(MEMERR);
          files->ptr2 = files->lwad; /* remember address of descriptor */
          if (!add_data(files,&i,sizeof(int))) error(MEMERR);
          if (!add_data(files,&i,sizeof(int))) error(MEMERR);
          files->ptr1 = files->lwad;   /* remember address of file name */

          cp = *aptr;  /* Store in variables for speed */
          i = strlen(*aptr)+1;
          if (!add_data(files,cp,i)) error(MEMERR);
          if ((i & 1) && get_space(files,1) == NULL) error(MEMERR);
          if ( (cp=rindex(cp,'/')) != (char *)NULL ) { /* look for path sep */
               if(!add_data(path,*aptr,cp-*aptr+1)) error(MEMERR);
          }

          /* Open the file and remember the descriptor */

          if ( (curr_fd=open(files->fwad+3*sizeof(int),0)) == -1)
               error(errno);
          *(int *)(files->ptr2) = curr_fd;

          return files->fwad+3*sizeof(int)+(path->lwad - path->fwad);
     }
     return NULL;  /* no more files to process */
}

/*******************************************************************/
/*                                                                 */
/*   pfile - print current file name.                              */
/*                                                                 */
/*******************************************************************/

pfile()
{    char *p;   /* scratch pointer to a character */
     short i;   /* scratch integer */

     if ( (*((int *)(files->fwad)+2) != 0) ||
          (files->fwad == files->lwad) ) return; /* if already printed or
                                                      no file name present */

     /* Indicate in all higher files that name should be printed */

      for ( p = files->fwad; p != files->lwad; ) {
          *((int *)p+2) = 0;      /* clear "name printed" flag */
          p += 3*sizeof(int);     /* skip header information */
          i = strlen(p) + 1;
          p += i + (i & 1);
     }

     pstrng(files->fwad+3*sizeof(int));  /* print the file name */
     pstrng("\n");  /* terminate with new line */
     *( (int *)(files->fwad)+2) = 1; /* indicate "name printed" */
}

/*******************************************************************/
/*                                                                 */
/*   pline - print current line                                    */
/*                                                                 */
/*******************************************************************/

pline()

{    int  lino;     /* Line number scratch */
     char number[7];/* ASCII form of the number */
     int  i;        /* Scratch integer */

     if (printd || (rline->fwad == rline->lwad)) return; /* if already printed
                                                          or no line */
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
     pstrng(number);
     pstrng("   ");           /* Print spaces */
     pstrng(rline->fwad);     /* Print the line */
     printd = TRUE;           /* Indicate "line printed" */
}

/*******************************************************************/
/*                                                                 */
/*   plinex - print line only if list flag is on                   */
/*                                                                 */
/*******************************************************************/

plinex()

{
     if (lstflg != '\0' &&
         (lib_nest == 0 || inclist) ) pline();
}

/*******************************************************************/
/*                                                                 */
/*   prs - preset.  Initialize tables and arguments.               */
/*                                                                 */
/*******************************************************************/

prs(argc,argv)
int  argc;     /* Command line argument count */
char *argv[];  /* Command line argument array */

/*   Returns non-zero if cannot complete initialization; usually due to
     not being able to get memory via "alloc" for table information.  */

{    struct table *new_table();
     BOOLEAN add_data();                /* add data to table */
     char *stand1 = "include/";         /* first standard search path */
     char *stand2 = "/lib/include/";    /* second standard search path */

     argc_opt = argcnt = argc;   /* remember argument count */
     argv_opt = aptr = &argv[0]; /* set pointer to first argument */

     if ( ( (sym_table = new_table(250)) == NULL ) ||
          ( (lab_table = new_table(10)) == NULL ) ) return 1;
     if ( ( (sym_name = new_table(200)) == NULL ) ||
          ( (lab_name = new_table(40)) == NULL ) ) return 1;
     if ( ( (infotab = new_table(100)) == NULL ) ||
          ( (ifiles  = new_table(16)) == NULL ) ||
          ( (path   = new_table(16)) == NULL ) ) return 1;
     if ( ( (files  = new_table(16)) == NULL ) ||
          ( (rline  = new_table(256)) == NULL ) ||
          ( (eline  = new_table(512)) == NULL ) ) return 1;
     if ( ( (deftab = new_table(100)) == NULL ) ||
          ( (defnam = new_table(256)) == NULL ) ) return 1;
     if ( ( (incfil = new_table(16)) == NULL ) ||
          ( (defarg = new_table(100)) == NULL ) ||
          ( (defexp = new_table(100)) == NULL ) ) return 1;
     get_space(rline,1); /* force assignment of table addresses */
     rline->lwad = rline->fwad;    /* empty the table */
     options(); /* process options */
     if( !add_data(ifiles,stand1,strlen(stand1)+1) ||
         !add_data(ifiles,stand2,strlen(stand2)+1) ) return 1;
     return 0;
}

/*******************************************************************/
/*                                                                 */
/*  reset - clear all definitions, macroes, and symbols            */
/*                                                                 */
/*******************************************************************/

static reset()
{    extern int deftag;

     deftab->lwad = deftab->fwad;  /* clear definitions and macroes */
     defnam->lwad = defnam->fwad;
     deftag = 0;
     lab_table->lwad = lab_table->fwad; /* clear definitions and macroes */
     sym_table->lwad = sym_table->fwad;
}
