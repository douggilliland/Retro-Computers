/*
     struct passwd *getpwuid(uid)
          int  uid;

          This function scans the system password file
          "/etc/log/password" for the first entry containing
          a user id field <uid>.  If one is found, it returns
          a pointer to a structure (in static memory) which
          describes that entry.  If one is not found, it
          returns NULL.

     Arguments:
          uid       int
                    User id to search for

     Returns:  struct passwd *
          A pointer to a structure describing the found entry
          or NULL if none is found

     Routine History:
          07/25/84 kpm - New
*/


#include "machine.h"
#include <pwd.h>

struct passwd *getpwuid(uid)
     REGISTER  int       uid;
{
     /*
          Local declarations
     */
     register  struct passwd *pwent;


     /*
          Begin at the beginning of the password file
     */
     setpwent();


     /*
          Search the password file until an entry with a
          user id of <uid> is found.  If found, return a
          pointer to the structure containing information
          about that entry.  If not found, return NULL
     */
     while (((pwent = getpwent()) != NULL) &&
            (pwent->pw_uid != uid)) ;

     return(pwent);
}
