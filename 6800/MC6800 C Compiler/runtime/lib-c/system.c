/*
     int system(cmd)
          char     *cmd;

          This function submits the list of shell commands
          referenced by <cmd> to the shell for execution.
          It returns whatever the shell returns as its
          result.

     Arguments:
          cmd       char *
                    References a character-string containing
                    shell commands to be executed

     Returns:  int
          Whatever the shell returns if successful or whatever
          "execv()" returns if not successful

     Routine History:
          08/03/84 kpm - New
*/


#include  "machine.h"
#include  <stdio.h>
#include  <sys/signal.h>
#include  <errno.h>

int system(string)
               char     *string;
{
               int     (*signal())();
               int       fork();
               int       execv();
     DATAREG0  int       pid;
     DATAREG1  int       code;
     ADDRREG0  int     (*oldsig)();
               int       status;

     /*
          Fork a child [fork() returns 0 if child,
          the child's pid if parent]
     */
     oldsig = signal(SIGINT, (int (*)()) SIG_IGN);
     if ((pid = vfork()) == 0)
     {
          /*
               Child process
                  - Exec the shell (w/ or w/o +b)
                  - If execl() failed, return the errcd
                    [MUST _exit() so buffers don't get
                    flushed!]
          */
          if (oldsig == ((int (*)()) SIG_IGN))
               code = execl("/bin/shell", "shell",
                            "+bcx", string, NULL);
          else
               code = execl("/bin/shell", "shell",
                            "+cx", string, NULL);
          _exit(code);
     }

     /*
       Note:  On VM systems, the parent is not allowed to
              run until the child releases memory, either
              by terminating or via an "exec" system call.
              Therefore, we know we are not corrupting the
              child's signal table by restoring the parent's
              signal handling here
     */
     (void) signal(SIGINT, oldsig);

     if (pid != -1)
     {
          /*
               Wait for the child to die -- don't stop waiting
               just because we got an interrupt
          */
          while ((((code = wait(&status)) < 0) && (errno == EINTR)) ||
                 ((code >= 0) && (code != pid)));
     }
     else status = -1;        /* fork() error */

     /*
          Finished.  Return whatever was returned by the child
     */
     return(status);
}
