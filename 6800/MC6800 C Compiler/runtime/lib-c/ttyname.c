/*
     Common definitions
*/
#include "machine.h"
#include <sys/stat.h>
#include <sys/modes.h>
#include <stdio.h>
#include <sys/dir.h>
#include <string.h>
#include <ctype.h>


/*
     char *ttyname(fildes)
          int       fildes;

          This routine returns a pointer to the completely
          qualified pathname of the terminal whose current
          open filenumber is <fildes>, or NULL if <fildes>
          is not a terminal in "/dev"

     Arguments:
          fildes    int
                    Open filenumber

     Returns: char *
          A pointer to the name of the terminal associated
          with the open file <fildes>, or NULL if none.

     Notes:
        - Returned pointer is to a static buffer that will be
          overwritten on subsequent calls

     Routine History:
          06/29/84 kpm - New
*/

char *ttyname(fildes)
     DATAREG0  int            fildes;
{
     ADDRREG2  DIR           *pdir;
     ADDRREG1  char          *rtnvl = NULL;
     DATAREG1  int            i_num;
     ADDRREG0  struct direct *dir_ent;
     struct    stat           status;
     static    char           buf[256];


     if (fstat(fildes, &status) == 0)
       if ((status.st_mode & S_IFMT) == S_IFCHR)
       {
         i_num = status.st_ino;
         if ((pdir = opendir("/dev")) != NULL)
         {
           while ((dir_ent = readdir(pdir)) != NULL)
             if ((i_num == dir_ent->d_ino) &&
                 (dir_ent->d_name[0] == 't') &&
                 (dir_ent->d_name[1] == 't') &&
                 (dir_ent->d_name[2] == 'y') &&
                 (isascii(dir_ent->d_name[3]) &&
                  isdigit(dir_ent->d_name[3])) &&
                 (isascii(dir_ent->d_name[4]) &&
                  isdigit(dir_ent->d_name[4])) &&
                 (dir_ent->d_name[5] == '\0'))
               rtnvl = strcat(strcpy(buf, "/dev/"), dir_ent->d_name);
           closedir(pdir);
         }
       }

     return(rtnvl);
}
