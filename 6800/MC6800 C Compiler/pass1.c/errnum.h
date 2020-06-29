/*******************************************************************/
/*                                                                 */
/*                         Error Numbers                           */
/*                                                                 */
/*******************************************************************/

/*        Fatal Errors        */

#define MEMERR 128  /* Memory overflow */
#define ARGERR 129  /* File names does not end in .c or .r */
#define FLNERR 130  /* Bad "include" file name */
#define FNFERR 131  /* "include" file not found */

/*        Non-fatal Errors    */

#define DEFERR  54  /* Definition error */
#define PARERR  55  /* Macro parameter substitution error */
#define IFNERR  56  /* Bad name in "if" command */
#define IFDERR  57  /* "endif" without preceding "if" */
#define IFLERR  58  /* "else" without preceding "if" */
#define LINERR  59  /* Line number error */
#define EXPERR  60  /* Identifier, continued comment or continued quote in
                       an "if" */
#define CMDERR  61  /* Unknown preprocessor command */
#define DUPERR  62  /* Duplicate DEFINE with warning requested */
