/*
     Routines in this module:  openutils.c
          _allocfp()     Allocate an fp from the fp pool
          _setupfp()     Initialize an fp
*/


/*
     Common definitions
*/
#include "machine.h"
#include <stdio.h>
#include <errno.h>


FILE *_allocfp()
{
     register  FILE     *fp;
     REGISTER  int       i;


     /*
          Look for a free slot in the standard I/O
          stream description table "_iob"
     */
     for (i = 0 , fp = _iob ; i < _NFILE ; i++ , fp++)
          if ((fp->_flag & (_READ|_WRITE)) == 0) break;
     if (i == _NFILE)
     {
          /* errno = ?????; */
          return(NULL);
     }
     return(fp);
}


void _setupfp(fp, fd, mode)
     register  FILE     *fp;
     REGISTER  int       fd;
     REGISTER  int       mode;
{
     /*
          Set up the file description block pointed to
          by <fp>.
     */
     fp->_fd = fd;                 /* Open file number */
     fp->_flag = mode;             /* I/O mode and flags */
     fp->_base = NULL;             /* No buffer associated */
     fp->_save = EOF;              /* No "ungotten" char */
     fp->_cnt  = 0;                /* Nothing in buffer */
     fp->_ptr  = NULL;             /* No current buffer */
}
