/*
     char *dirname(pathname)
          char     *pathname;

          This function extracts the path in the pathname
     <pathname> and returns the address of a buffer
     containing that path.  The path in "/" is "/", and
     the path in a pathname containing no '/' is ".".

     Arguments:
         pathname  char *
                   The address of a character-string containing
                   the pathname

     Returns: char *
          The address of a character-string containing the path
          in the pathname

     Errors:
          The function returns (char *) NULL if the pathname is
          longer than the internal buffers of this routine
        
     Routine History:
          11/06/84 kpm - New
*/

#include "machine.h"
#include <string.h>


char *dirname(path)
     char     *path;
{
     ADDRREG0  char     *p;
     ADDRREG1  char     *q;
     ADDRREG2  char     *r;
     DATAREG0  char      c;
     DATAREG1  int       i;

               char      rtnbuf[256];

     p = path;
     q = rtnbuf;
     r = (char *) NULL;
     i = sizeof(rtnbuf);
     while ((c = *q++ = *p++) != '\0')
          if (--i <= 0) return((char *) NULL);
          else if (c == '/') r = q - 1;
     if (r == (char *) NULL)
          strcpy(rtnbuf, ".");
     else if (r != &rtnbuf[0]) *r = '\0';
          else *(r+1) = '\0';
     return(rtnbuf);
}
