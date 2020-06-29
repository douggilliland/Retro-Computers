/*
     char *basename(pathname, suffix)
          char     *pathname;
          char     *suffix;

          This function extracts the base filename from the
      pathname referenced by <pathname>.  If suffix != NULL,
      the function extracts that string from the base filename
      if it ends in that suffix.  It returns the address of
      a character-string containing the base filename (with
      the suffix possibly removed) as its result.

     Examples:
          basename("/a/b/xyz.c", ".c") -> "xyz"
          basename("abc.defg", "fg") -> "abc.de"
          basename("a/b/c/d", NULL) -> "d"

     Arguments:
          pathname  char *
                    The address of a character-string containing
                    the pathname
          suffix    char *
                    The address of a character-string containing
                    the suffix

     Returns:  char *
          The address of a character-string containing the resulting
          filename with possibly the suffix removed

     Errors:
        - The function returns (char *) NULL if the base filename
          is larger than permitted by internal buffers
*/

#include <string.h>
#include "machine.h"

char *basename(path, suffix)
               char     *path;
     ADDRREG2  char     *suffix;
{
     ADDRREG0  char     *p;
     ADDRREG1  char     *rtnval;

     DATAREG0  int       i;
     DATAREG1  int       j;

               char      rtnbuf[256];

     /*
       Find the beginning of the base filename
     */
     p = path + (i=strlen(path));
     while (--i >= 0)
          if (*--p == '/')
          {
               p++;
               break;
          }

     /*
       If there is no suffix (suffix == NULL) or it is longer
       than the base filename, or the base filename does not
       end with the suffix, return the base filename.  Otherwise,
       return the base filename with the suffix removed.
     */
     i = strlen(p);
     if ((suffix == (char *) NULL) ||
         ((j=strlen(suffix)) > i))
          if (i >= sizeof(rtnbuf)) rtnval = (char *) NULL;
          else rtnval = strcpy(rtnbuf, p);
     else
     {
          if (strcmp(p+(i-j), suffix) == 0) i -= j;
          rtnval = strncpy(rtnbuf, p, i);
          *(rtnval+i) = '\0';
     }
     return(rtnval);
}
