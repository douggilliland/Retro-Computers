/*******************************************************************/
/*                                                                 */
/*             Classify Character Macro and Definitions            */
/*                                                                 */
/*******************************************************************/

#ifndef   isalpha
#include  <ctype.h>
#endif
#define   SEPAR   0      /* separator character type*/
#define   ALPHA   1      /* alphabetic charcter type (includes underscore)*/
#define   NUMBER  2      /* numeric character type */

#define CLSCH(CH) (CH=='_'||isalpha(CH)?ALPHA:(isdigit(CH)?NUMBER:SEPAR))
