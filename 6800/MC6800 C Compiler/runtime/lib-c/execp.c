/*
  execp.c

     int execlp(path, [arg0, [arg1, [..., argn]]], (char *) NULL)
     int execvp(path, arglist)
*/

#include "machine.h"
#include <string.h>
#include <ctype.h>
#include <errno.h>
#include <sys/stat.h>

#ifndef TRUE
#define TRUE 't'
#define FALSE 0
#endif


int execvp(path, arglist)
               char     *path;
               char     *arglist[];
{
     ADDRREG0  char     *p;
     ADDRREG1  char     *q;
     ADDRREG2  char     *r;
     ADDRREG3  char     *s;
               char     *fullname;

     DATAREG0  int       not_done;
     DATAREG1  int       pathlen;
     DATAREG2  int       statval;

     struct    stat      statbuf;

               int       execv();
               char     *getenv();

     /*
       If there is no current "PATH" environment or there is
       a '/' in the pathname of the file to execute, try to
       execute the file without using any search rules
     */
     if (((q = getenv("PATH")) == (char *) NULL) ||
         (strchr(path, '/') != (char *) NULL))
       (void) execv(path, arglist);
     else
     {
       /*
         Must follow search rules.  For each directory in
         the search list, attempt to "exec" a file in that
         directory with the name <path>
       */
       not_done = TRUE;
       pathlen = strlen(path);
       while (not_done)
       {
         /*
           Extract the next entry from the search list,
           ignoring leading and trailing spaces
         */
         p = q;
         while(isspace(*p)) p++;
         if ((q = strchr(p, ':')) == (char *) NULL)
         {
           r = p + strlen(p);
           not_done = FALSE;
         }
         else
           r = q++;
         while ((--r >= p) && isspace(*r)) ;

         /*
           If the current entry in the search list is empty
           (a null or blank string), try to "exec" in the
           current directory
         */
         if (p > r)
         {
           (void) execv(path, arglist);
           if (errno == EACCES)
             statval = stat(path, &statbuf);
         }
         else
         {
           /*
             Generate a filename from the current search-list
             entry and the argument <path>, separating the two
             with a '/'
           */
           if ((fullname = malloc(r - p + pathlen + 3)) 
                         == (char *) NULL) break;
           for (s = fullname ; p <= r ; *s++ = *p++) ;
           *s++ = '/';
           (void) strcpy(s, path);

           /* Attempt to "exec" */
           (void) execv(fullname, arglist);

           if (errno == EACCES)
             statval = stat(fullname, &statbuf);
           free(fullname);
         }

         /*
           "exec" failed.  If failed because
             1.  EBBIG (binary file too large)
             2.  E2BIG (argument list too large)
             3.  EACCES (no access permissions) and
                 the file is both reachable and
                 executable, quit trying
         */
         if ((errno == EBBIG) ||
             (errno == E2BIG) ||
             ((errno == EACCES) &&
              (statval == 0) &&
              (statbuf.st_perm & S_IOEXEC))) not_done = FALSE;
       }

       /*
          If the final error-code is EMSDR (missing directory),
          change it to ENOENT (no file-system entry)
       */
       if (errno == EMSDR) errno = ENOENT;
     }
     return(-1);
}
int execlp(path, arg0)
     char     *path;
     char     *arg0;
{
     return(execvp(path, &arg0));
}
