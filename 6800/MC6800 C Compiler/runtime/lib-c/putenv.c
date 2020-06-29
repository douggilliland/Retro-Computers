/* putenv.c

    int putenv(string)
         char  *string;

         This function modifies the current environment list.
    If the variable defined by <string> is already defined
    in the environment list, this function redefines that
    variable.  If it is not already defined in the list,
    the function adds that definition to the list.

         The string is expected to be of the form 
    "<name>=<value>".
  
    Arguments:
         string    char *
                   Address of a character-string defining an
                   environment variable

    Returns:  int
         Zero if it couldn't allocate more memory (using 
         "malloc()") to expand the environment list, otherwise -1

    Routine History:
         03/05/85 kpm - New

*/


#include "machine.h"
#include <string.h>
#include <stdio.h>

#define  BUMPC        16

    static    char    alloced   = FALSE;
    static    int     nbinsleft = 0;

    extern    char  **environ;

int putenv(string)
    ADDRREG2  char   *string;
{
    ADDRREG0  char  **penv;
    ADDRREG1  char  **pp;
    ADDRREG3  char   *new;
              char   *peq;

    DATAREG0  int     n;
    DATAREG1  int     namelen;

    /*
      Validate (sort of) the environment variable definition
    */
    if ((string != (char *) NULL) &&
        ((peq = strchr(string, '=')) != NULL) &&
        ((namelen = peq - string) > 0))
    {
      /*
        Scan the environment list to see if the variable
        being defined already exists
      */
      for (n = 0 , penv = environ ;
           *penv != (char *) NULL ;
           ++n, ++penv)
        if ((strncmp(*penv, string, namelen) == 0) &&
            (*((*penv)+namelen) == '=')) break;

      /*
        If the environment variable already exists in the
        environment-list, just replace its definition
      */
      if (*penv != (char *) NULL)
        *penv = string;
      else
      {
        /*
          Otherwise, add this definition to the list
          If we've left room in the list for more entries
          (via a previous "putenv()" call), just add this
          entry to the list
        */
        if (--nbinsleft >= 0)
        {
          *penv++ = string;
          *penv = (char *) NULL;
        }
        else
        {
          /*
            No room in the existing list.  Allocate space
            for a new list (with extra space if possible)
            and copy the existing list into the new space
            (pointers only!)
          */
          new = malloc((n+BUMPC+1)*sizeof(char *));
          if (new == (char *) NULL)
          {
            new = malloc((n+2)*sizeof(char *));
            if (new == (char *) NULL)
              return(0); /* ERROR */
            nbinsleft = 0;
          }
          else
            nbinsleft = 15;
          pp = (char **) new;
          penv = environ;
          while (*pp++ = *penv++) ;
          *pp-- = (char *) NULL;
          *pp = string;
          if (alloced == TRUE) free(environ);
          alloced = TRUE;
          environ = (char **) new;
        }
      }
    }
    return(-1);  /* No error */
}
