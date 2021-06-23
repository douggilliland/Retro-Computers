


#ifndef _GLOBALS_H_
#define _GLOBALS_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern char    *Optr;
extern int     Line_num;            /* current line number          */
extern int     Err_count;           /* total number of errors       */
extern char    Line[];     /* input line buffer            */
extern char    Label[];    /* label on current line        */
extern char    Op[];        /* opcode mnemonic on current line      */
extern char    Operand[];  /* remainder of line after op           */
extern char    *Optr;               /* pointer into current Operand field   */
extern int     Result;              /* result of expression evaluation      */
extern int     Force_word;          /* Result should be a word when set     */
extern int     Force_byte;          /* Result should be a byte when set     */
extern int     Pc;                  /* Program Counter              */
extern int     Old_pc;              /* Program Counter at beginning */

extern int     Last_sym;            /* result of last lookup        */

extern int     Pass;                /* Current pass #               */
extern int     N_files;             /* Number of files to assemble  */
extern FILE    *Fd;                 /* Current input file structure */
extern int     Cfn;                 /* Current file number 1...n    */
extern int     Ffn;                 /* forward ref file #           */
extern int     F_ref;               /* next line with forward ref   */
extern char    **Argv;              /* pointer to file names        */

extern int     E_total;             /* total # bytes for one line   */
extern int     E_bytes[];           /* Emitted held bytes           */
extern int     E_pc;                /* Pc at beginning of collection*/

extern int     Lflag;               /* listing flag 0=nolist, 1=list*/

extern int     P_force;            /* force listing line to include Old_pc */
extern int     P_total;              /* current number of bytes collected    */
extern int     P_bytes[];          /* Bytes collected for listing  */

extern int     Cflag;              /* cycle count flag */
extern int     Cycles;             /* # of cycles per instruction  */
extern long    Ctotal;             /* # of cycles seen so far */
extern int     Sflag;              /* symbol table flag, 0=no symbol */
extern int     N_page;             /* new page flag */
extern int     Page_num;           /* page number */
extern int     CREflag;            /* cross reference table flag */

extern struct  nlist *root;            /* root node of the tree */
  
extern FILE    *Objfil;             /* object file's file descriptor*/
extern char    Obj_name[];

#endif // _GLOBALS_H_

