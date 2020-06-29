/*
     getut.c - "/act/utmp" file manipulations

          These routines are used to fetch information
          from the system accounting file "/act/utmp",
          which contains information about the current
          logged-in users

     Entry points:

          struct utmp *getutent()  Get next entry
          struct utmp *getutline() Get next entry with line
                 void  setutent()  Rewind file
                 void  endutent()  Close file
*/

#include  "machine.h"
#include  <stdio.h>
#include  <utmp.h>
#include  <string.h>

/*
     Definitions:
          UTNAME    Name of accounting file
*/
#define   UTNAME         "/act/utmp"

/*
     Static data:
          _utfd     FILE *
                    References the standard I/O stream on
                    which the accounting file is open
          _vline    int
                    The entry number of the current entry
                    if any, 0 otherwise
          _utmpinfo struct utmp
                    Contains the most-recently read record
                    info
*/
static    FILE          *_utfd = NULL;
static    int            _vline = 0;
static    struct utmp    _utmpinfo;



/*
     struct utmp *getutent()

          This function fetches the next valid entry in the
          UniFLEX accounting file "/act/utmp", if any.  If
          "getutent()" (or "getutline()") has not yet been
          called, or "endpwent()" has been called since the
          last call to "getutent()" (or "getutline()"), it
          opens the file positioning it to the first record.

          The result of the function references a (struct
          utmp) which contains information extracted from
          the record successfully read, or NULL if no record
          was successfully read.

     Arguments:  None

     Returns:  struct utmp *
          References information extracted from the record
          read or NULL if none

     Routine History:
          08/09/84 kpm - New
*/

struct utmp *getutent()
{
     register  struct utmp   *rtnval;
     REGISTER  int            not_done = TRUE;
               char           utmprecd[16];

     /*
          Open the file if it is not currently open
     */
     rtnval = NULL;
     if (_utfd == NULL) _utfd = fopen(UTNAME, "r");

     /*
          If there is a file opened, read records until
          a record with valid info is found (byte 0 of
          ut_line field is not zero) or the end of the
          file is found.
     */
     if (_utfd != NULL)
       while (not_done)
         if (fread(utmprecd, 16, 1, _utfd) == 1)
         {
           _vline++;
           if (utmprecd[0] != '\0')
           {
             strncpy(_utmpinfo.ut_user, &utmprecd[2], 8);
             strcpy(_utmpinfo.ut_line, "/dev/tty");
             _utmpinfo.ut_id[0] = _utmpinfo.ut_id[1] = '0';
             _utmpinfo.ut_id[2] = _utmpinfo.ut_line[8] = utmprecd[0];
             _utmpinfo.ut_id[3] = _utmpinfo.ut_line[9] = utmprecd[1];
             _utmpinfo.ut_time = *((unsigned long *) &utmprecd[12]);
             rtnval = &_utmpinfo;
             not_done = FALSE;
           }
         }
         else
         {
           not_done = FALSE;
           _vline = 0;
         }

     /*
          Return the address of the information read if successful,
          NULL otherwise
     */
     return(rtnval);
}


/*
     struct utmp *getutline(line)
          struct utmp *line;

          This function searches for the next valid
          record in the UniFLEX system accounting file
          "/act/utmp" that contains a (ut_line) field
          matching that field in the (struct utmp)
          referenced by <line>.  Its result is a reference
          to a (struct utmp) which contains information
          derived from that record.

          If the accounting file is active (meaning it
          has been accessed by "getutline()" or "getutent()"
          with no subsequent "endutent()" call), the search
          begins with the current record.  If it is not active,
          it is made active and the search begins with the
          first valid record of the file.

     Arguments:
          line      struct utmp *
                    References the structure containing the
                    (ut_line) field to search for

     Returns:
          Successful:  A reference to a (struct utmp) in static
               memory containing information derived from the
               record found.
          Unsuccessful:  ((struct utmp *) NULL)

     Routine History:
          09/10/84 kpm - New
*/
struct utmp *getutline(line)
     REGISTER  struct utmp   *line;
{
     /*
          If the current entry is valid, check it first
     */
     if (_vline != 0)
          if (strncmp(line->ut_line, _utmpinfo.ut_line, 12) == 0)
               return(&_utmpinfo);

     /*
          Check the remaining entries.
     */
     while(getutent() != NULL)
          if (strncmp(line->ut_line, _utmpinfo.ut_line, 12) == 0)
               return(&_utmpinfo);

     /*
          No match
     */
     return(NULL);
}


/*
     void setutent()

          This function rewinds the open "utmp" file
          If it is not open, the function does nothing.

     Arguments:  None

     Returns:  Void

     Routine History:
          08/09/84 kpm - New
*/

void setutent()
{
     if (_utfd != NULL)
     {
          rewind(_utfd);
          _vline = 0;
     }
}


/*
     void endutent()

          This function closes the open "utmp" file
          If it is not open, the function does nothing.

     Arguments:  None

     Returns:  Void

     Routine History:
          08/09/84 kpm - New
*/

void endutent()
{
     if (_utfd != NULL)
     {
          fclose(_utfd);
          _utfd = NULL;
          _vline = 0;
     }
}
