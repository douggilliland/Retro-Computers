/*
     char *fullname(path)
          char     *path;

          This function generates the fully-qualified, unique
          pathname for that in the character-string referenced
          by <path>.  It returns the address of the character-
          string containing that pathname as its result.

          The function returns NULL if it could not determine the
          complete, unique pathname for its argument.  It returns
          NULL if it can not determine the name of the current
          directory, can not change directories to that in the
          pathname <path>, or if a filename would overflow one
          of the function's internal buffers.

     Arguments:
          path      char *
                    The address of a character-string containing
                    an existing pathname

     Returns:  char *
          The address of a character-string containing the complete,
          unique pathname for the argument <path>

     Routine History:
          11/05/84 kpm - New
*/
#include <string.h>
#include "machine.h"

char *fullname(path)
     char     *path;
{
     ADDRREG1  char     *p;
     ADDRREG0  char     *rtnval;
 
     DATAREG0  int       i;

     char      cwd[256];
     char      full[256];

     char     *dirname();
     char     *basename();
     char     *getcwd();

     rtnval = NULL;
     if (getcwd(cwd, sizeof(cwd)) != NULL)
     {
        cwd[strlen(cwd)-1] = '\0';
        if ((p = dirname(path)) != NULL)
           if (chdir(p) == 0)
           {
              if (getcwd(full, sizeof(full)) != NULL)
              {
                 if ((i = strlen(full)) == 2)
                    full[1] = '\0';  /* "/" */
                 else
                    full[i-1] = '/';
                 if ((p = basename(path, NULL)) != NULL)
                    if ((strlen(p)+strlen(full)) < sizeof(full))
                       rtnval = strcat(full, p);
                    else /*set errorcode someday*/ ;
              }
              chdir(cwd);
           }
     }
     return(rtnval);
}
