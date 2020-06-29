/*******************************************************************/
/*                                                                 */
/*             Miscellaneous Preprocessor Commands                 */
/*                                                                 */
/*******************************************************************/

#include  "boolean.h"
#include  "class.h"
#include  "errnum.h"
#include  "miscdefs.h"
#include  "tables.h"

static    char inctype;  /* "include" name terminator ( " or >) */
static    BOOLEAN pathi; /* TRUE if path information specified */
static    int name_length;/* length of specified name */
static    int r_name_length;   /* rounded name length */
static    int fd;        /* file descriptor of "include" file */
extern    int lib_nest;  /* library nesting level */
extern    int line;      /* Line number for compiler */
extern    BOOLEAN comment;    /* TRUE if in a comment */

/*******************************************************************/
/*                                                                 */
/*   include - include processor                                   */
/*                                                                 */
/*******************************************************************/

include()

{    char chr;           /* scratch character */
     BOOLEAN not_found;  /* TRUE if file not yet found */
     BOOLEAN try_open(); /* attempt open of file routine */
     BOOLEAN add_data(); /* add data to manaed tables */
     int  i;             /* scratch integer */
     char *get_space();  /* space allocator */
     char *cp;           /* scratch character pointer */
     int  *ip;           /* scratch integer pointer */
     int  f_tab_size;    /* size of "files" table information */

     eline->lwad = eline->ptr1 = eline->fwad;
     plinex();      /* print line so line number is correct */
     editline();    /* edit the line */
     while(comment) {
          getlin();      /* get another line */
          plinex();      /* print the new line */
          editline();    /* edit the line */
     }
     while((chr = *eline->ptr1) == ' ' || chr == '\t')eline->ptr1++;
     if (chr == '\"') inctype = chr;    /* if local file possible */
     else if (chr == '<') inctype = '>';/* if system files only */
     else error(FLNERR);                /* if improper format */
     pathi = FALSE;      /* preset "no path information" */
     eline->ptr2 = ++eline->ptr1;      /* skip starting name bracket */
     if(*eline->ptr1 == '/') pathi = TRUE; /* if started by path character */
     while( (chr = *eline->ptr1++) != inctype) {    /* if not end of name */
          if(chr == '\n') error(FLNERR);     /* if no terminator */
     }
     if ((name_length = eline->ptr1 - eline->ptr2 - 1) == 0)
          error(FLNERR); /* if no name */
     r_name_length = name_length + (name_length & 1);
     not_found = TRUE;   /* preset "file not yet found" */

     /*   First search the path of the source file if the name
          was bracketed by quotation marks and the specified path was
          not from the root.  */

     if(inctype == '\"' &&         /* if local search allowed, and */
        *eline->ptr2 != '/' &&     /* if path not from root, and */
        (i = path->lwad-path->fwad) != 0) {    /* if a source path exists */

          incfil->lwad = incfil->fwad;  /* set table empty */
          if( (cp=get_space(incfil,i)) == NULL) error(MEMERR);
          move(path->fwad,cp,i);        /* copy path */
          not_found = !try_open();      /* attempt open */
     }

     /*   If the file has not yet been found, search the path as
          exactly specified in the "include" statement. */

     if (not_found){          /* if not yet found */
          incfil->lwad = incfil->fwad;  /* set table empty */
          not_found = !try_open();      /* attempt open */
     }

     /*   If no path information was specified in the "include" statement,
          search the default directories. */

     if (!pathi) {
          ifiles->ptr1 = ifiles->fwad;
          while(not_found && ifiles->ptr1 < ifiles->lwad) {
               incfil->lwad = incfil->fwad;  /* set table empty */
               i = strlen(ifiles->ptr1);     /* get length */
               if(get_space(incfil,i) == NULL) error(MEMERR);
               move(ifiles->ptr1,incfil->fwad,i); /* copy path */
               not_found = !try_open();      /* attempt open */
               ifiles->ptr1 += (i+1);
          }
     }
     if(not_found) error(FNFERR);  /* file not found anywhere */
     name_length = incfil->lwad - incfil->fwad; /* compute length of name */
     r_name_length = name_length + (name_length & 1);
     f_tab_size = files->lwad - files->fwad; /* compute length of file info */

     /*   Reserve space in the "files" table.  We cannot use
          "add_data" because the data is in a table higher in memory
          than the table into which it is being copied.  It is not
          necessary to memorize the insertion addresses since the new data
          will be added at the "fwad" in the table. */

     if(get_space(files,r_name_length+3*sizeof(int)) == NULL) error(MEMERR);
     move(files->fwad,files->fwad+r_name_length+3*sizeof(int),f_tab_size);
                                        /* move data in "files" upward */
     ip = (int *)files->fwad; /* point to start of new entry */
     *ip = line = 0;          /* clear line number */
     *(ip+1) = fd;            /* remember descriptor */
     *(ip+2) = 0;             /* clear "name printed" flag */
     move(incfil->fwad,files->fwad+3*sizeof(int),name_length); /* copy name */
     set_new_file(fd);        /* reset file buffer and descriptor */
     ++lib_nest;              /* increment nesting level */
}

/*******************************************************************/
/*                                                                 */
/*   try_open - attempt open of an "include" file                  */
/*                                                                 */
/*******************************************************************/

static BOOLEAN try_open()

/*   Returns TRUE if file was successfully opened.  In this case,
     "fd" is set to the file descriptor. */

/*   On entry, "name_length" contains the length of the name,
     "eline->ptr2" points to the name, and the "incfil" table may
     be preset with leading path information. */

{    BOOLEAN   add_data();    /* add data to managed table */
     char      chr;           /* scratch character */

     chr = '\0';

     /*   The following works only because the "incfil" table is above the
          "eline" table. */

     if(!add_data(incfil,eline->ptr2,name_length) ||
        !add_data(incfil,&chr,sizeof(char)) ) error(MEMERR);
     if( (fd=open(incfil->fwad,0)) == -1) return FALSE; /* if cannot open */
     return TRUE;        /* file successfully opened, descriptor in "fd" */
}

/*******************************************************************/
/*                                                                 */
/*   info - collect assembler "info" statements.                   */
/*                                                                 */
/*******************************************************************/

info()

{    char *get_space();  /* get space in table routine */
     char *cp;           /* scratch character pointer */

     if( (cp=get_space(infotab,rline->lwad-rline->fwad-1)) == NULL)
          error(MEMERR); /* get room in table */
     *cp = ' ';   /* store leading space */
     move(rline->fwad+1,cp+1,rline->lwad-rline->fwad-2); /* copy line */
}

/*******************************************************************/
/*                                                                 */
/*   line_com - set line number and file name                      */
/*                                                                 */
/*******************************************************************/

line_com()

{    char *get_space();       /* get space in table routine */
     char *cp;                /* scratch character pointer */
     char chr;                /* scratch character */
     int  i = 0;              /* scratch integer */
     int  new_size;           /* size of new name */
     int  r_new_size;         /* rounded new size */
     int  old_size;           /* size of old name */
     char *name_ptr;          /* name pointer */

     plinex();      /* print the line before line number changes */
     while( (chr = *rline->ptr1++)==' ' || chr == '\t');
     if(CLSCH(chr) != NUMBER) non_fatal(LINERR);
     else {
          do {
               i = i*10 + (chr - '0');
               chr = *rline->ptr1++;
          } while (CLSCH(chr) == NUMBER);
          if (i != 0) {
               line = *( (int *)files->fwad ) = i-1; /* store new number */
               rline->ptr1--;
               while( (chr = *rline->ptr1)==' ' || chr == '\t')rline->ptr1++;
               if(CLSCH(chr) == ALPHA) {
                    rline->ptr2 = rline->ptr1;    /* remember start */
                    do {
                         chr = *rline->ptr1++;
                    } while(CLSCH(chr) != SEPAR); /* find end of name */
                    new_size = rline->ptr1 - rline->ptr2 - 1;
                    r_new_size = new_size + ((new_size & 1)? 1:2);
                    name_ptr = files->fwad + 3*sizeof(int);
                    old_size = strlen(name_ptr)+1;
                    old_size += (old_size & 1);
                    tbrdi(files,name_ptr,old_size);
                    if((cp = get_space(files,r_new_size)) == NULL)
                         error(MEMERR);
                    move(name_ptr,name_ptr+r_new_size,cp-name_ptr);
                    move(rline->ptr2,name_ptr,new_size);
                    *(name_ptr+new_size) = '\0';
                    *(int *)(files->fwad+2*sizeof(int)) = 0; /*clear flag*/
               }
          }
          else non_fatal(LINERR);
     }
}
