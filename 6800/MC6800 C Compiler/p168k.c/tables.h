/*******************************************************************/
/*                                                                 */
/*             Managed Table Definitions.                          */
/*                                                                 */
/*******************************************************************/

#include "tbdef.h"

extern TABLE relfil;  /* List of relocatable files */
extern TABLE infotab; /* "info" statements */
extern TABLE path;    /* Current path for "include" searching */
extern TABLE files;   /* Source and "include" file stack */
extern TABLE rline;   /* Raw input line */
extern TABLE eline;   /* Edited input line */
extern TABLE defnam;  /* Definition names */
extern TABLE deftab;  /* Definitions and macroes */
extern TABLE incfil;  /* "include" file and path */
extern TABLE defarg;  /* Actual arguments in macro call */
extern TABLE defexp;  /* Expanded macro */
extern TABLE sym_table;  /* Symbol table */
extern TABLE lab_table;  /* Line label table */
