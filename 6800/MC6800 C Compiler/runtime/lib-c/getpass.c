/*
     char *getpass(prompt)
          char     *prompt;

          This function writes the character string
          referenced by <prompt> to "stderr", then
          accepts characters from "stdin" up to and
          including EOF or EOL with ECHO turned off,
          writes an EOL to "stderr", turns ECHO on,
          then returns a pointer to the first eight
          characters read (not including EOL or EOF).

          It returns NULL with "errno" containing the
          error code if an error was encountered.

          This function catches hangup, kybd, quit
          signal, resets the terminal, then resignals
          the signal.

     Arguments:
          prompt    char *
                    References a char-string to be
                    written to "stderr"

     Returns:  char *
          References the character-string containing
          the (max of 8) characters read or NULL if
          error

     Notes:
        - The chars referenced by the value returned are
          in static memory and will be overwritten on
          subsequent calls to "getpass()".
        - Any other signal than kybd, quit, alarm, and hangup
          may cause the terminal to be left with no-echo
          set.
        - Signals received while changing signal handling
          information can cause weirdness.  It would be nice
          if the system could be made "quiet" around the
          blocks of "signal()" calls.

     Errors:
        - ENOTTY if either "stderr" or "stdin" are not
          terminals (char special files)

     Routine History:
          08/08/84 kpm - New
*/

#include  "machine.h"
#include  <stdio.h>
#include  <errno.h>
#include  <sys/sgtty.h>
#include  <sys/signal.h>

     static    struct sgttyb  ttyinfo;
     static    struct sgttyb  newinfo;
     static    char           passwd[9];

     static    int          (*intint)();
     static    int          (*hupint)();
     static    int          (*quitint)();
     static    int          (*alarmint)();

char *getpass(prompt)
     char     *prompt;
{
               int            resetint();

     REGISTER  char          *rtnval;
     register  char          *p;
     REGISTER  int            i;
     REGISTER  int            c;


     rtnval = (char *) NULL;
     if (isatty(fileno(stdin)) && isatty(fileno(stderr)))
     {
          if (fprintf(stderr, prompt) >= 0)
          {
               if (gtty(fileno(stdin), &ttyinfo) == 0)
               {
                    /*
                         Catch interrupts so we can restore
                         the tty status
                    */
                    quitint = signal(SIGQUIT, resetint);
                    hupint = signal(SIGHUP, resetint);
                    intint = signal(SIGINT, resetint);
                    alarmint = signal(SIGALRM, resetint);

                    /*
                         Change the tty so that ECHO is off
                    */
                    newinfo = ttyinfo;
                    newinfo.sg_flag &= ~ECHO;
                    if (stty(fileno(stdin), &newinfo) == 0)
                    {
                         /*
                              Fetch characters, saving a max of 8,
                              reading through to an EOL or EOF
                         */
                         p = passwd;
                         i = 8;
                         while ((i-- > 0) &&
                                ((c = getc(stdin)) != EOF) &&
                                (c != EOL))  *p++ = c;
                         if (i < 0)
                              while (((c = getc(stdin)) != EOF) &&
                                     (c != EOL)) ;
                         /*
                              Null-terminate password
                         */
                         *p = '\0';

                         /*
                              Set the return value and return the
                              terminal to its original state
                         */
                         rtnval = passwd;
                         stty(fileno(stdin), &ttyinfo);

                         /*
                              Return interrupt handlers to their
                              original state
                         */
                         signal(SIGQUIT, quitint);
                         signal(SIGHUP, hupint);
                         signal(SIGALRM, alarmint);
                         signal(SIGINT, intint);
                    }
               }
          }
     }
     else errno = ENOTTY;
     return(rtnval);
}

/*
     static int resetint(sig)
          int       sig;

          This function resets the standard input terminal to
          its original state (at call to "getpass()") and
          resets the interrupt handlers for "int", "hup",
          "quit", and "alarm" interrupts to their original
          state, then reissues the interrupt.

     Arguments:
          sig       int
                    The number of the signal to reissue

     Returns:  int
          Nothing in particular

*/

static int resetint(sig)
     int       sig;
{
     int       getpid();

     stty(fileno(stdin), &ttyinfo);
     clearerr(stdin);
     signal(SIGINT, intint);
     signal(SIGHUP, hupint);
     signal(SIGQUIT, quitint);
     signal(SIGALRM, alarmint);
     kill(getpid(), sig);
}
