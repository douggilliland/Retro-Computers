/*
     char *mktemp(template)
          char     *template;

          This function attempts to generate a pathname
          for a file that does not exist in the filesystem.
          It expects as its argument a reference to a
          character string which is a template pathname.
          It returns this argument as its result if
          successfully generated a pathname for a file
          that does not exist, or NULL otherwise.

          If the template pathname ends in six 'x' or 'X'
          characters, it replaces those characters with
          an 'A' character and a five-character representation
          of the current process-id.  It then checks the
          filesystem for a file of that name.  If a file by
          that name doesn't exist, it returns its argument
          <template>.  If a file by that name already exists,
          it changes the 'A' to a 'B' and retrys, continuing
          until a pathname is generated that does not reference
          an existing file or the upper- and lower-case
          alphabet is exhausted.

          If the template pathname does not end in 'x' or 'X'
          characters, the function checks the filesystem
          for an entry matching the template pathname and
          returns <template> if none exists, or NULL if one
          already exists.

     Arguments:
          template  char *
                    References the template character string from
                    which the filename is constructed

     Returns:  char *
          Its argument <template> if successful or NULL if not
          successful.

     Errors:
          Returns NULL with "errno" describing the error.
          Is "EEXIST" if all filenames are exhausted.

     Notes:
        - Modifies in place the template string

     Routine History:
          08/01/84 kpm - New
*/

/*
     Common definitions used
*/
#include  "machine.h"
#include  <string.h>
#include  <errno.h>


char *mktemp(template)
     REGISTER  char     *template;
{
     register  char     *p;
     REGISTER  char     *rtnval;
     REGISTER  int       length;
     REGISTER  int       pid;
     REGISTER  int       counter;

     rtnval = NULL;
     if (((length = strlen(template)) >= 6) &&
         (toupper(*(p=template+length-1)) == 'X') &&
         (toupper(*--p) == 'X') &&
         (toupper(*--p) == 'X') &&
         (toupper(*--p) == 'X') &&
         (toupper(*--p) == 'X') &&
         (toupper(*--p) == 'X'))
     {
          /*
               Build the filename from the template by
               replacing the last 6 chars in the template
               with a single char [A-Za-z] and the five-
               digit process id
          */
          pid = getpid();
          p = template + length;
          for (counter = 0 ; counter < 5 ; counter++)
          {
               *--p = (char) (((int) '0') + (pid % 10));
               pid /= 10;
          }
          *--p = 'A';

          /*
               Check for uniqueness.  If the file already exists,
               bump the single char and retry ('Z'->'a', 'z'->ERROR)
               Note that if any other error besides ENOENT is
               encountered, the process ends immediately
          */
          while (rtnval == NULL)
               if (access(template, 0) == 0)
                    if ((*p)++ == 'Z') *p = 'a';
                    else if (*p != '{') ;
                         else
                         {
                              errno = EEXIST;
                              break;
                         }
               else if (errno != ENOENT) break;
                    else rtnval = template;
     }

     /*
          Otherwise, just check to see if a file
          named <template> exists
     */
     else if ((access(template, 0) != 0) &&
              (errno == ENOENT)) rtnval = template;

     /*
          Return a pointer to the generated, unique filename
          or NULL if none was generated ("errno" contains
          reason)
     */
     return(rtnval);
}
