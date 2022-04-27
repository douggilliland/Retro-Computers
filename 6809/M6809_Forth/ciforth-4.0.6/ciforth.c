/* Copyright (2000): Albert van der Horst, HCC FIG Holland by GNU Public License */
#include <stdio.h>
#include <stdlib.h>
#include <sys/times.h>
#include <unistd.h>
#include <string.h>
#include <sys/time.h>
#include <sys/stat.h>
#include <termios.h>
#include <signal.h>
#include <setjmp.h>
#include <fcntl.h>
#include <errno.h>

/* Entry point of ciforth. */

/* To make linking possible. Anybody know where this is hanging out? */
void _fini(void) {return;}
void _init(void) {return;}

/* The offset into the boot parameters. */
typedef enum { COLD = 0, WARM = 4 } BOOT_OFFSET;
extern void ciforth( BOOT_OFFSET offset, int argc, char **argv );

/* The maximum size of a Forth command passed to the OS */
#define MAX_COMMAND 2000

/* The size of a Forth block aka screen */
#define KBBUF 1024

/* public declarations */
typedef struct tty
{
    int fd;               /* A file descriptor, presumably a tty */
    struct termios org;   /* Data of `fd', to be restored afterwards */
    struct termios now;   /* Used to mangle while changing `fd' */
    int is_a_tty;         /* `fd' is associated with a tty */
} TTY;


void tty_error(char *s)
{
  fprintf(stderr, "\n\nerror: %s, (%s)\n", s, sys_errlist[errno]);
  fflush(stderr);
}

void tty_warning(char *s)
{
  fprintf(stderr, "\n\nwarning: %s, (%s)\n", s, sys_errlist[errno]);
  fflush(stderr);
}

/* In behalf of debugging
DISPLAYSI(unsigned int x)
{
    static unsigned int y = ciforth;
    printf("%08x\n", x-y);
}
*/

void tty_set(TTY *ptty)
{
  if (!ptty->is_a_tty)
    return;
  if (tcsetattr (ptty->fd, TCSADRAIN, &ptty->now) < 0)
    tty_error ("unable to set tty state");
}

void tty_restore(TTY *ptty)
{                               /* write termio struct */
  if (!ptty->is_a_tty)
    return;
  if (tcsetattr(ptty->fd, TCSADRAIN, &ptty->org) < 0)
    tty_error("unable to restore tty state");
}

void tty_init(int fd, TTY *ptty)
{                               /* fill-in tty struct */
  ptty->fd = fd;
  ptty->is_a_tty = tcgetattr(ptty->fd, &ptty->org) >= 0 &&
                 tcgetattr(ptty->fd, &ptty->now) >= 0;
}

/* Disabling these special char's is only useful when                        */
/* making a full screen editor.                                              */
void tty_disable( TTY *ptty)
{
  if (!ptty->is_a_tty) return;

  /* disable some special characters */
/*ptty->now.c_cc[VINTR] = _POSIX_VDISABLE;   ^C                          */
/*ptty->now.c_cc[VQUIT] = _POSIX_VDISABLE;   ^\                          */
/*ptty->now.c_cc[VSUSP] = _POSIX_VDISABLE;   ^S/^Q                       */
  tty_set(ptty);
}

void tty_echo(TTY *ptty)
{
  if (!ptty->is_a_tty)
    return;
  ptty->now.c_lflag |= ECHO;
  tty_set(ptty);
}

void tty_noecho(TTY *ptty)
{
  if (!ptty->is_a_tty)
    return;
  ptty->now.c_lflag &= ~ECHO;
  tty_set(ptty);
}

void tty_keymode(TTY *ptty)
{
  if (!ptty->is_a_tty)
    return;
  ptty->now.c_lflag &= ~ICANON;
  ptty->now.c_cc[VMIN] = 1;
  ptty->now.c_cc[VTIME] = 0;
  tty_set(ptty);
}

void tty_linemode(TTY *ptty)
{
  if (!ptty->is_a_tty)
    return;
  ptty->now.c_lflag |= ICANON;

/* VMIN, VTIME are overloaded and should really be restored ... */
  ptty->now.c_cc[VMIN] = ptty->org.c_cc[VMIN];
  ptty->now.c_cc[VTIME] = ptty->org.c_cc[VTIME];
  tty_set(ptty);
}


/*****************************************************************************/
/*                      SIGNALS                                              */
/*****************************************************************************/


/* To be executed on SIGINT (Normally ^C) */
int break_pressed = 0;
void break_int( int ignore )
{
  signal(SIGINT, break_int);
  break_pressed = 1;
}

/* To be executed on SIGQUIT (Normally ^\) */
/* and on SIGSEGV (Normally invalid address) */
sigjmp_buf restart_forth;
void break_quit( int signum )
{
  signal(signum, break_quit);
  siglongjmp(restart_forth, WARM );
}

TTY std_in;

/* Actions performed in behalf of Forth.                                     */
/*  The Forth names fully specifiy the action, once you know that the stack  */
/*  translates in variables, but reversed. Forth names are got by removing   */
/*  "c_", upercasing and replacing '_' by  '-' from the c-function name      */

/* ?TERMINAL */
/* ^C is the break key. */
/* This idea turned out to be useless, because it is accepted synchronously  */
/* only.                                                                     */
/*
int c_qterm(void)
{
   return break_pressed-- >0;
}
*/

/* ?TERMINAL */
/* The "any key" is the break key. */
int c_qterm(void)
{
  fd_set rfds;
  struct timeval tv;

  tty_keymode(&std_in);
  /* Zero timeout, must be set each time! */
  /* A Linux peculiarity.                 */
  tv.tv_sec = 0;
  tv.tv_usec = 0;

  FD_ZERO(&rfds);
  FD_SET(0, &rfds);    /* From standard input */
  select(1, &rfds, NULL, NULL, &tv);

  return FD_ISSET(0, &rfds);
}

/* KEY */
int c_key( void )
{
  char key;
  int i;
  tty_keymode(&std_in);
  i=read(0, &key, 1);
  return key;
}

/* EMIT */
void c_emit(int ch)
{
  fputc(ch, stdout);
  fflush(stdout);
}

/* TYPE */
void c_type(int count, char buffer[])
{
  write(1, buffer, count);
  fflush(stdout);
}

/* EXPECT */
int c_expec(int count, char buffer[])
{
  int i;
  if ( count <= 0 ) return 0;

  if (std_in.is_a_tty)
  {
      tty_linemode(&std_in);
      i= read(0, buffer, count);
      buffer[--i]=0;  /* Eat the cr. */
  }
  else
  {
      /* We got to read by chars, to be able to stop */
      for(i=0; i<count-1; i++)  /* One char spare */
      {
          if ( 0==read(0,buffer+i,1) || '\n' == buffer[i] )
              break;
      }
      buffer[i] = 0;
  }
  return i;     /* Ignored by fig-Forth, use it and you have ANSI ACCEPT */
}

int block_fid = -1;

/* Open out block file with the Forth name `filename' */
/* `filename' is a stored Forth string.               */
int c_block_init( int access, int count, char filename[] )
{
  /* turn into c-string */
  char zname[MAX_COMMAND];
  strncpy(zname, filename, count);
  zname[count] = 0;

  close(block_fid);    /* Silently. */
  block_fid = open( zname, access );
  printf("block_fid is %d\n", block_fid);

  return block_fid > 0 ? 0 : errno;
}

/* Close block file earlier opened with c_block_init */
int c_block_exit( void )
{
  return close( block_fid );
}

/* RSLW */
int c_rslw(int control, int block, void *pmem )
{
    /* Did you now the real signature of `read' ? */
    ssize_t(*rslw)(int, void *, size_t ) = control? read: write ;
    off_t where = block * KBBUF;

    return
         block_fid <= 0 ? -1 :
         where != lseek( block_fid, where, SEEK_SET ) ? errno :
         KBBUF != (*rslw)( block_fid, pmem, KBBUF )   ? errno :
         0 ;
}

/* Perform ANSI Forth 'SYSTEM' */
/* Interpret the Forth string (`command',`count') as linux                   */
/* command and execute it.                                                   */
int c_system(int count, char command[])
{
  int i;
  char buffer[MAX_COMMAND];

  if( MAX_COMMAND-1 > count )
      return -1;

  strncpy( buffer, command, count);
  buffer[count]=0;
  buffer[count-1]=0;
  return system(buffer);
}

void c_debug(void ***pdea)
{
    void **dea = *pdea;
    long *nfa = *(int **)(dea+4);
    char *pc;
    int len;
    int i;

    printf("%p ",pdea);
    printf("%p ",dea);
    printf("%p ",nfa);
/*  if ( 0x08100000 < (int)nfa && (int)nfa <0x08200000 )                     */
    if ( nfa )
    {
        len = *nfa++;
        pc = (char *)nfa;
        if (len<32)
        {
            printf("%d ",len);
            for (i=0; i<len; i++)
                printf("%c", *pc++);
        }
    }
    printf("\n");
}

int main (int argc, char *argv[])
{
  BOOT_OFFSET bootmode = COLD;
/*printf("Hello world\n");exit(0);                                           */
/*signal(SIGINT, SIG_IGN);                                                   */
  /* Convenient interrupting of long loops */
  signal(SIGQUIT, break_quit);
  /* Restart when inspecting non existing memory */
  signal(SIGSEGV, break_quit);

  tty_init(0, &std_in);

  for(;;)
  if ( !sigsetjmp(restart_forth,1) )
  {
      ciforth( bootmode, argc, argv);
      break;
  }
  else
  {
        bootmode = WARM;
  }
  tty_restore(&std_in);
}
