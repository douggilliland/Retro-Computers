/*
     FILE *fdopen(fd, mode)
          int       fd;
          char     *mode;

          This function attaches the file whose open-file-ptr
          is <fd> to a stream with an access-mode of <mode>,
          typically obtained from a open(), dup(), creat(),
          or pipe() call.  The access-mode must match the
          open mode of the file referenced by <fd>.

     Arguments:
          fd:       Open file descriptor of the file to attach to
                    a stream.
          mode:     A pointer to the character string describing
                    the requested access method of the file

     Returns:  FILE *
          A(file description block) if successful, NULL otherwise

     Notes:
        - Cannot verify that the access mode matches the open
          mode since there is no way to coax the open mode
          from UniFLEX.

     Routine History:
          06/11/84 kpm - New
          05/10/85 ljn - Added support of "open for update" modes.

*/


/*
     Common definitions
*/

#include "machine.h"
#include <stdio.h>
#include <errno.h>


FILE *fdopen(fd, mode)
     REGISTER  int       fd;
     register  char     *mode;
{
     REGISTER  int       type;
     REGISTER  FILE     *fp;

               FILE     *_allocfp();
               void      _setupfp();
               int       lseek();
               void      exit();


     /*
          Determine the mode of the operation
     */
     if (*mode == 'r') type = _READ;
     else if (*mode == 'w') type = _WRITE;
     else if (*mode == 'a')
     {
          /*
               Appending.  Assuming <fd> is a pipe or a terminal
               if we get an error seeking to the end of the file
          */
          type = _WRITE|_APPEND;
          if (lseek(fd, 0L, 2) == -1)
               if (errno == EBADF) return(NULL);
     }
     else
     {
          /*
               Invalid mode.  Must set "errno" someday.
          */
          return(NULL);
     }
    /*
     * Check for update mode.
     */
     if (*++mode == '+')
        {
         type |= _UPDATE|_READ|_WRITE;
        }
     else if (*mode)
        {
        /*
         * Unknown mode
         */
         return(NULL);
        }


     /*
          Set up the file description in std i/o
     */

     if ((fp = _allocfp()) != NULL)
          _setupfp(fp, fd, type);

     return(fp);
}
