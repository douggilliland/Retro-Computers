#include "machine.h"
#include <string.h>
/*******************************************************************/
/*                                                                 */
/*   getenv - search environment for name                          */
/*                                                                 */
/*******************************************************************/

char *getenv(s)
ADDRREG1 char *s;

/*
      Search the environment for an entry prefixed by the argument 's'.
      If found, return the address of the character following the
      equal sign after the prefix.
      Return the null pointer if not found.
*/

{
   extern char **environ;     /* environment pointers */
   ADDRREG0 char **ep = environ; /* environment pointer */
   ADDRREG2 char *sp;         /* string pointer */
   DATAREG0 short sl;         /* string length */

   sl = strlen(s);            /* get length of argument */
   while((sp = *ep++) != NULL) {
      if(strncmp(s,sp,sl) == 0 && *(sp+sl) == '=') return sp+sl+1;
   }
   return NULL;
}
