/*
     struct passwd *getpwnam(name)
          char     *name;

          This function scans the system password file
          "/etc/log/password" for the first entry containing
          a username field <name>.  If one is found, it
          returns a pointer to a structure (in static memory)
          which describes that entry.  If one is not found, it
          returns NULL.

     Arguments:
          name      char *
                    Username to search for

     Returns:  struct passwd *
          A pointer to a structure describing the found entry
          or NULL if none is found

     Routine History:
          07/25/84 kpm - New
*/


#include "machine.h"
#include <pwd.h>
#include <string.h>

struct passwd *getpwnam(name)
     REGISTER  char     *name;
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
          username of <name> is found.  If found, return a
          pointer to the structure containing information
          about that entry.  If not found, return NULL
     */
     while (((pwent = getpwent()) != NULL) &&
            (strcmp(pwent->pw_name, name) != 0)) ;

     return(pwent);
}
