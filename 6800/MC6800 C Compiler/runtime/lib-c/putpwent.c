/*
     int putpwent(pwent, stream)
          struct passwd *pwent;
          FILE           stream;

          This function edits the information in the
          password structure referenced by <pwent>
          to the form required by the system password
          file "/etc/log/password" and writes the
          edited information to the standard I/O stream
          referenced by <stream>, terminated by a '\n'.

     Arguments:
          pwent     struct passwd *
                    References the structure containing the
                    password-file entry information
          stream    FILE *
                    References the standard I/O stream to
                    which the edited data is to be written

     Returns:  int
          0 if the data was written successfully, EOF otherwise
          (System V manual says "non-zero otherwise")

     Notes:
        - The UNIX System V manual [PUTPWENT(3C)] indicates
          that the "pw_passwd" and "pw_shell" entries in
          the password-entry description structure may be
          "null".  Does this mean they may be null-strings
          or the null pointer NULL?  I don't know.  This
          routine takes care of both circumstances.

     Routine History:
          07/25/84 kpm - New
*/

#include  <stdio.h>
#include  <pwd.h>

int putpwent(pwent, stream)
     register  struct passwd *pwent;
               FILE          *stream;
{
     return ((fprintf(stream, "%s:%s:%d:%s:%s\n",
                              pwent->pw_name,
                              pwent->pw_passwd == NULL ?
                                    "" : pwent->pw_passwd,
                              pwent->pw_uid,
                              pwent->pw_dir,
                              pwent->pw_shell == NULL ?
                                    "" : pwent->pw_shell
                      ) >= 0) ? 0 : EOF);
}
