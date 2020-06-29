/*******************************************************************/
/*                                                                 */
/*                         Error Numbers                           */
/*                                                                 */
/*******************************************************************/

/*        Fatal Errors        */

#define MEMERR 128  /* Memory overflow */
#define FLNERR 129  /* Bad "include" file name */
#define FNFERR 130  /* "include" file not found */

/*        Non-fatal Errors    */

#define DEFNAM  131 /* Definition name error */
#define IFNERR  132 /* Bad name in "if" command */
#define IFDERR  133 /* "endif" without preceding "if" */
#define IFLERR  134 /* "else" without preceding "if" */
#define LINERR  135 /* Line number error */
#define EXPERR  136 /* Identifier, continued comment or continued quote in
                       an "if" */
#define CMDERR  137 /* Unknown preprocessor command */
#define DUPERR  138 /* Duplicate DEFINE with warning requested */
#define CLDEFNAM 139 /* 'D' option name error */
#define DEFARG 140  /* missing ')' after argument list */
#define CLDEFARG 141 /* missing ')' after argument list in 'D' option */
#define CLDUPERR 142 /* duplicated definition in 'D' option */
#define NOENDIF 143 /* missing "endif' */
#define UNEXEOF 144 /* unexpected EOF (in a comment ) */
#define TOODEEP 145 /* possible recursive macro */
#define PARERR 146 /* macro parameter substitution error */
