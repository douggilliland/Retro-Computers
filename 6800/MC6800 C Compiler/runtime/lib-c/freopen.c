/*
     FILE *freopen(filename, mode, stream)
          char     *filename;
          char     *mode;
          FILE     *stream;

          This function closes the file associated with
          the standard I/O stream <stream>, then attempts
          to open the file <filename> with access type
          <mode> and associates that file with the given
          stream

     Arguments:
          filename  A(filename string)
          mode      A(access-type description string)
          stream    A(block describing stream)

          Valid access-types <mode> are:

               "r"  Read-only (file must already exist)
               "w"  Truncate to zero-length if the file exists
                    or create the file, then write-only
               "a"  Create if necessary then write-only to
                    the end of the file
               "r+" Open for update (read/write - file must exist)
               "w+" Truncate to zero-length if the file exists
                    or create the file, then read/write
               "a+" Create if necessary then read/write to EOF

     Returns:  FILE *
          <stream> if successful, NULL if not successful

     Notes:
        - The original file on the stream is closed even
          if the freopen() is ultimately unsuccessful

     Revision History:
          06/11/84 kpm - New
          05/10/85 ljn - Added support for "r+", "w+" and "a+" modes.

*/


/*
     Common definitions
*/
#include "machine.h"
#include <stdio.h>
#include <errno.h>
#include <sys/fcntl.h>


FILE *freopen(filename, mode, stream)
               char     *filename;
     register  char     *mode;
     REGISTER  FILE     *stream;
{
     REGISTER  int       fd;
     REGISTER  int       type;
     REGISTER  int       open_mode;

               void      _setupfp();
               int       fclose();
               int       pclose();
               int       open();
               int       close();
               int       creat();
               int       lseek();
               void      exit();

     /*
          Close the file currently on the stream
     */
     if (stream->_flag & (_READ | _WRITE)) {
          if(stream->_flag & _PIPE) (void) pclose(stream);
          else (void) fclose(stream);
     }


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
          Assign the file we just opened to the given
          standard I/O stream description buffer
     */
     _setupfp(stream, fd, type);

     /*
          Finished
     */
     return(stream);
}
