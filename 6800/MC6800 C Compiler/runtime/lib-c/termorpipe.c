
/*
     Common definitions
*/
#include "machine.h"
#include <sys/stat.h>
#ifndef modes_h
#include <sys/modes.h>
#endif


/*-----------------------------------------------------------------*/

/*
     int _termorpipe(fildes)
          int       fildes;

          This routine returns 1 if the open file number
          <fildes> refers to a terminal or a pipe, 0 otherwise.

     Arguments:
          fildes    int
                    Open file number

     Returns:  int
          1 if <fildes> refers to a terminal or a pipe, 0 otherwise

     Notes:
        - The terminal need not be in the device directory
          "/dev", it need only be defined as a "char special"
          file

     Routine History:
          06/03/85 ljn - New
*/

int _termorpipe(fildes)
     int       fildes;
{
     DATAREG0  int            rtnvl = 0;
               struct stat    status;

     if (fstat(fildes, &status) == 0)
        {
         rtnvl = status.st_mode & S_IFMT;
         if ((rtnvl == S_IFCHR) || (rtnvl == S_IFPIPE))
            rtnvl = 1;
        }

     return(rtnvl);
}
