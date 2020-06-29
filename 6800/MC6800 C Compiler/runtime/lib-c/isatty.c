
/*
     Common definitions
*/
#include "machine.h"
#include <sys/stat.h>
#include <sys/modes.h>


/*-----------------------------------------------------------------*/

/*
     int isatty(fildes)
          int       fildes;

          This routine returns 1 if the open file number
          <fildes> refersto a terminal, 0 otherwise.

     Arguments:
          fildes    int
                    Open file number

     Returns:  int
          1 if <fildes> refers to a terminal, 0 otherwise

     Notes:
        - The terminal need not be in the device directory
          "/dev", it need only be defined as a "char special"
          file

     Routine History:
          06/21/84 kpm - New
*/

int isatty(fildes)
     int       fildes;
{
     DATAREG0  int            rtnvl;
               struct stat    status;

     if (fstat(fildes, &status) == 0)
          rtnvl = (status.st_mode & S_IFMT) == S_IFCHR;
     else rtnvl = 0;

     return(rtnvl);
}
