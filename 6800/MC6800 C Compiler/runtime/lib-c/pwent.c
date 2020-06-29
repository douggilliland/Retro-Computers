/*
     pwent.c - Password-file manipulation routines

     This file contains the base-level password-file
     manipulation routines.  Included are:

     struct passwd *getpwent()     Get next entry
              void  setpwent()     Rewind file
              void  endpwent()     Close file

     Other routines available:

     struct passwd *getpwnam()     Get entry keyed on username
     struct passwd *getpwuid()     Get entry keyed on userid
               int  putpwent()     Format data and write to stream

     For common password-entry definitions, see "pwd.h"
*/

/*
     Common definitions
*/
#include  "machine.h"
#include  <stdio.h>
#include  <string.h>
#include  <pwd.h>
#include  <ctype.h>


/*
     Data used by all routines in this module:

     _pwdfile  FILE *
               References the stream attached to the password
               file

     _pwdinfo  struct passwd
               Structure to be filled with information
               describing the current record
*/

static    FILE          *_pwdfile = NULL;
static    char           _pwdbuf[PWRECSZ+2];
static    struct passwd  _pwdinfo;



/*-------------------------------------------------------------------

     struct passwd *getpwent()

          This function reads and decodes the next valid
          entry in the password file.  If the password file
          is not currently open, the function opens it.
          It returns a pointer to a structure in static
          memory which describes the next entry in the
          password file, or NULL if none was read.

     Arguments: None

     Returns:  struct passwd *
          A pointer to a structure in static memory which
          contains the information obtained from the
          valid password-file entry read, or NULL if none
          was read.

     Notes:
        - Any entries in the password file which do not
          conform to the correct format are ignored.

     Format for an entry in the password file:

       1. A string of characters terminated by a ':' that
          represents the username.  This field may not
          be null
       2. A string of characters terminated by a ':' that
          represents the encrypted password.  A null field
          indicates that there is no password.
       3. A string of decimal digits terminated by a ':'
          that represents the user's id number.  This field
          may not be null.
       4. A string of characters terminated by a ':' that
          represents the user's initial directory.  This
          field may not be null.
       5. A string of characters terminated by a '\n' that
          represents the user's initial program.  A null
          field indicates that the initial program is the
          "shell"

     Routine History:
          07/25/84 kpm - New
*/

struct passwd *getpwent()
{
     /*
          Local declarations
     */

     REGISTER  struct passwd *pwent;
     register  char          *p;
               char          *q;


     /*
          If the password-file is not open, open it
     */
     if (_pwdfile == NULL)
          _pwdfile = fopen(PWFILNAM, "r");


     pwent = NULL;
     if (_pwdfile != NULL)
          while ((pwent == NULL) &&
                 ((p = fgets(_pwdbuf, PWRECSZ+2, _pwdfile)) != NULL))
          {
               /*
                    Username field
                    String of characters terminated by a ':'
                    Field may not be a null
               */
               _pwdinfo.pw_name = p;
               if (*p == ':')
                    continue;
               if ((p = strchr(p, ':')) == NULL)
                    continue;
               *p++ = '\0';

               /*
                    Encrypted password field
                    String of characters terminated by a ':'
                    Field may be null (no password)
               */
               _pwdinfo.pw_passwd = p;
               if ((p = strchr(p, ':')) == NULL)
                    continue;
               *p++ = '\0';
               if (strlen(_pwdinfo.pw_passwd) == 0)
                    _pwdinfo.pw_passwd = NULL;

               /*
                    User-id field
                    String of numeric (decimal) characters
                    terminated by a ':'
                    Field not be a null
               */
               if (!isdigit(*p))
                    continue;
               _pwdinfo.pw_uid = _strtoi(p, &q, 10);
               p = q;
               if (*p++ != ':')
                    continue;

               /*
                    Initial-directory field
                    String of characters terminated by a ':'
                    Field may not be null
               */
               _pwdinfo.pw_dir = p;
               if (*p == ':')
                    continue;
               if ((p = strchr(p, ':')) == NULL)
                    continue;
               *p++ = '\0';

               /*
                    Initial-program field
                    String of characters terminated by a '\n'
                    Field may be null (indicates "shell")
               */
               _pwdinfo.pw_shell = p;
               if ((p = strchr(p, '\n')) != NULL)
               {
                    *p = '\0';
                    if (strlen(_pwdinfo.pw_shell) == 0)
                         _pwdinfo.pw_shell = NULL;
                    pwent = &_pwdinfo;  /* Correctly formed record */
               }
          }
     return(pwent);
}


/*------------------------------------------------------------------

     void setpwent()

          This function rewinds the opened password
          file.  If not opened, this function does
          nothing

     Arguments:  None

     Returns:  Void

     Routine History:
          07/25/84 kpm - New
*/

void setpwent()
{
     /*
          Rewind the file if it's open
     */
     if (_pwdfile != NULL) rewind(_pwdfile);
}


/*------------------------------------------------------------------

     void endpwent()

          This function closes the password file if
          opened.

     Arguments:  None

     Returns:  Void

     Routine History:
          07/25/84 kpm - New
*/

void endpwent()
{
     /*
          Close the password file and set the pointer to NULL
          if it's open
     */
     if (_pwdfile != NULL)
     {
          fclose(_pwdfile);
          _pwdfile = NULL;
     }
}
