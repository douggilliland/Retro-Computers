/*
     FILE *fopen(filename, openmode)
          char *filename;
          char *openmode;

          This function opens the file named <filename>
          for the access specified by the string <openmode>.
          It returns a pointer to the file description
          block describing the open file.

     Arguments:
          filename  Pointer to the string naming the file
                    to be opened
          openmode  Pointer to the string describing the
                    type of access requested

          Valid open modes <openmode> are:

               "r"  Read-only (file must already exist)
               "w"  Truncate to zero-length if the file exists
                    or create the file, then write-only
               "a"  Create if necessary then write-only to
                    the end of the file
               "r+" Open for update (reading and writing, file
                    must exist)
               "w+" Truncate or create for update
               "a+" Create if necessary and open for update.
                    (writing takes place only at EOF though)

     Returns:  FILE *
          If successful, the address of the block describing
          the open file is returned.  Otherwise, NULL is
          returned.

     Notes:
        - Someday should return NULL with an error-code set in
          "errno" if the mode <openmode> is not recognized as
          one of the valid modes.

     Revision History:
          06/11/84 kpm - New
          05/09/85 ljn - Added "r+", "w+", and "a+" open modes.

*/


/*
     Common definitions
*/
#include "machine.h"
#include <stdio.h>
#include <errno.h>
#include <sys/fcntl.h>


FILE *fopen(filename, mode)
               char     *filename;
     REGISTER  char     *mode;
{
     REGISTER  int       fd;
     register  FILE     *fp;
     REGISTER  int       type;
     REGISTER  int       open_mode;

               FILE     *_allocfp();
               void      _setupfp();
               int       open();
               int       close();
               int       creat();
               int       lseek();
               void      exit();

     /*
          Open the file depending on the requested mode
     */

     if (*mode == 'r')
     {
          type = _READ;
          if (*++mode == '+')
             {
             /*
              * Open for update
              */
              open_mode = O_RDWR;
              type |= _UPDATE|_WRITE;
             }
          else if (*mode)
             {
             /*
              * Unknown mode
              */
              return(NULL);
             }
          else
             {
              open_mode = O_RDONLY;
             }
          /* Open for reading or read/write */
          if ((fd = open(filename, open_mode)) == -1)
               return(NULL);
     }
     else if (*mode == 'w')
     {
          type = _WRITE;
          if (*++mode == '+')
             {
             /*
              * Open for update
              */
              type |= _UPDATE|_READ;
             }
          else if (*mode)
             {
             /*
              * Unknown mode
              */
              return(NULL);
             }
          /* Create (truncate) for writing */
          if ((fd = creat(filename, PMODE)) == -1)
               return(NULL);
          if (type & _UPDATE)
             {
             /*
              * If we're opening for update we've got to reopen the
              * file for both reading and writing.
              */
              (void) close(fd);
              if ((fd = open(filename, O_RDWR)) == -1)
                 return(NULL);
             }
     }
     else if (*mode == 'a')
     {
          type = _WRITE|_APPEND;
          if (*++mode == '+')
             {
             /*
              * Open for update
              */
              type |= _UPDATE|_READ;
              open_mode = O_RDWR;
             }
          else if (*mode)
             {
             /*
              * Unknown mode
              */
              return(NULL);
             }
          else
             {
              open_mode = O_WRONLY;
             }
          /* Open for writing to the end of the file */
          if ((fd = open(filename, open_mode)) == -1)
          {
               if ((fd = creat(filename, PMODE)) == -1)
                    return(NULL);
               if (type & _UPDATE)
                  {
                  /*
                   * If we're opening for update we've got to
                   * reopen the file for reading and writing.
                   */
                   (void) close(fd);
                   if ((fd = open(filename,O_RDWR)) == -1)
                      return(NULL);
                  }
          }
          else (void) lseek(fd, 0L, 2);
     }
     else
     {
          /*
               Unknown mode
               Must set "errno" someday
          */
          return(NULL);
     }


     /*
          Assign the file we just opened to a standard I/O
          stream description buffer
     */
     if ((fp = _allocfp()) == NULL)
          (void) close(fd);
     else _setupfp(fp, fd, type);

     /*
          Finished
     */
     return(fp);
}
