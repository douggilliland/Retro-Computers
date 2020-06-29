/*
     int getpw(uid, buf)
          int       uid;
          char     *buf;

          This function scans the system password file for
          the first correctly-formatted entry containing a
          userid field equal to <uid>.  It fills the buffer
          referenced by <buf> with that entry.  It returns
          0 if a correctly-formatted entry with the requested
          userid was found, otherwise it returns a non-zero
          value (EOF).

     Arguments:
          uid       int
                    Userid to search for
          buf       char *
                    References the char[] to be filled with
                    the first correctly formatted system
                    password file entry with the requested
                    userid

     Returns:  int
          0 if successful, non-zero otherwise

     Notes:
        - The function is obsolete and is included for compatability
          reasons only.  New code should use getpwuid().

     Routine History:
          07/26/84 kpm - New
*/


#include  "machine.h"
#include  <stdio.h>
#include  <ctype.h>
#include  <string.h>
#include  <pwd.h>


int getpw(uid, buf)
     REGISTER  int       uid;      /* Userid */
               char     *buf;      /* Target buffer */
{
     /*
          Local definitions
     */

     REGISTER  int       rtnval;             /* return value */
     register  char     *p;                  /* running ptr */
               char     *q;                  /* non-reg ptr */
               char      pwent[PWRECSZ+2];   /* local buf */
     REGISTER  FILE     *pwfile;             /* pw file stream */
     REGISTER  char      notfound;           /* flag, uid not found */
     REGISTER  int       colon = ':';        /* optz - constant */
               int       _strtoi();          /* convert routine */


     rtnval = EOF;
     if ((pwfile = fopen(PWFILNAM, "r")) != NULL)
     {
          /*
               Scan the password file until a properly-formatted
               record is read that has the requested userid or
               until the file is exhausted
          */
          notfound = TRUE;
          while (notfound &&
                 ((p = fgets(pwent, PWRECSZ+2, pwfile)) != NULL))
          {
               /*
                    Username field
                    May not be null
               */
               if (*p == colon) continue;
               if ((p = strchr(p, colon)) == NULL) continue;

               /*
                    Password field
               */
               if ((p = strchr(p+1, colon)) == NULL) continue;

               /*
                    Userid field
                    Must be a non-null string of digits
               */
               if (!isdigit(*(++p))) continue;
               if (_strtoi(p, &q, 10) != uid) continue;
               p = q;
               if (*p++ != colon) continue;

               /*
                    Initial directory field
                    May not be null
               */
               if (*p == colon) continue;
               if ((p = strchr(p, colon)) == NULL) continue;

               /*
                    Initial program field
               */
               if (strchr(p, '\n') == NULL) continue;

               /*
                    Found a properly formatted entry with
                    the requested userid
               */
               strcpy(buf, pwent);
               notfound = FALSE;
               rtnval = 0;
          }

          /*
               Close the system password file
          */
          fclose(pwfile);
     }

     /*
          Finished
     */
     return(rtnval);
}
