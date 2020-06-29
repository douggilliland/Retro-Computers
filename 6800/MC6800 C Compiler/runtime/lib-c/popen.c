/* popen.c

    #include <stdio.h>

    FILE *popen(command,type)
         char  *command, *type;

    int  plcose(stream)
         FILE *stream;


        The "popen" command creates a pipe between the calling program
    and the command.  If "type" is "w", the calling program may write
    to the standard input of the command by writing on the stream.
    If "type" is "r", the calling program may read from the standard
    output of the command by reading from the stream.

    Arguments:
         command   char *
                   Address of a character-string containing the command
                   name.  Standard "shell" search paths are used for
                   locating the command.

         type      char *
                   The I/O mode of the pipe from the calling programs
                   view.  "w" indicates writing to the pipe; "r",
                   reading from the pipe.

    Returns:  FILE *
         (FILE *)(0) if files or tasks cannot be created, or the
         I/O type is neither "w" nor "r".

        The "pclose" function closes a stream created by "popen".
    After closing the stream,it waits for the command to terminate and
    returns the termination status.

    Arguments:
         stream    FILE *
                   Address of a stream created by "popen".

    Returns:  int
         -1 if the stream was not created by "popen" or the child
         task does not exist.

    Routine History:
         04/23/85 RFK - New


*/

#define NOFILE ((FILE *)(0))
#define STDIN 0
#define STDOUT 1

#include <errno.h>
#include <stdio.h>

FILE *popen(command,type)
char *command;  /* command to connect to the stream */
char *type;     /* read/write mode */

{
     int fd[2];               /* pipe file descriptors */
     register int mode;       /* 1 if write mode; 0 if read mode */
     register int task_id;    /* task ID of child */
     register FILE *fp;       /* file pointer */
     register int i;          /* loop control */

     if(*type == 'w') mode = 1;         /* if write mode */
     else if (*type == 'r') mode = 0;   /* if read mode */
     else return NOFILE;                /* if error */

     if(pipe(fd) == -1) return NOFILE;  /* if cannot open pipe */
     if((fp = fdopen(fd[mode? 1:0], type)) == NULL) return NOFILE;

     if((task_id = vfork()) != 0) {     /* parent processing */
          close(fd[mode? 0:1]);         /* close other descriptor */
          if(task_id == -1) {           /* if no child created */
               fclose(fp);              /* close stream */
               return NOFILE;           /* return error indication */
          }
          fp->_flag |= _PIPE;           /* indicate "pipe" */
          fp->_task_id = task_id;       /* store task Id */
          return fp;                    /* return file pointer */
     }
     else {    /* child processing */
          if(mode) { /* if parent is writing to the child */
               close(fd[1]);  /* close unused descriptor */
               close(STDIN);
               if(dup2(fd[0],STDIN) == -1) _exit(errno);
               close(fd[0]);  /* close original descriptor */
          }
          else { /* if parent is reading from the child */
               close(fd[0]);  /* close unused descriptor */
               close(STDOUT);
               if(dup2(fd[1],STDOUT) == -1) _exit(errno);
               close(fd[1]);  /* close original descriptor */
          }
          for(i = 3; i < _NFILE; i++) close(i); /* close all other files */
          execl("/bin/shell","shell","+xc",command,(char *)0);
          _exit(errno);    /* failed to find the shell */
     }
}

int pclose(stream)
FILE *stream;

{    register int task_id;         /* pipe task ID */
     int task_status;              /* child's task status */
     register int tid;             /* task ID returned by "wait" */
     extern int errno;             /* system error 8 */

     if( stream == NOFILE ||
         !(stream->_flag & _PIPE) ) return -1;    /* if not pipe */
     task_id = stream->_task_id;   /* get task ID of child */
     fclose(stream);               /* close the stream */
     while( (tid = wait(&task_status)) != task_id) {
          if(tid == -1 && errno != EINTR) break;
     }
     return tid == -1? -1: task_status;
}
