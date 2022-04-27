/* $Id: stealconstant.c,v 4.1.2.3 2004/11/01 20:45:21 albert Exp $                   */
/* Copyright(2000): Albert van der Horst, HCC FIG Holland by GNU Public License */
#include <stdio.h>
#include <stdlib.h>
#include <sys/times.h>
#include <unistd.h>
#include <linux/unistd.h>
#include <string.h>
#include <sys/time.h>
#include <sys/stat.h>
#include <termios.h>
#include <signal.h>
#include <setjmp.h>
#include <fcntl.h>
#include <errno.h>
#include <asm/ioctls.h>

/*****************************************************************************/
/*                                                                           */
/*  This c-source is only intended to be print a number of EUQATES           */
/*  in form that is palatable for the assemblers used in generating          */
/*  ciforth.                                                                 */
/*                                                                           */
/*****************************************************************************/

/* Steal the information what value B has, leave it in A */
#define STEAL(A,B)   printf("%s\tEQU\t0x%x\n", A, B );

/* Have a A that has the same value than in C. */
#define STEALNAME(A)   STEAL( #A, A)

/* Have a A that has the number of system call B */
#define STEALSYS(A)   STEAL( #A, __NR_##A)

int main()
{
printf("_C{ ------------------------------------------------------------      }\n");
printf("_C{   Start of constants stolen from C.                                 }\n");
printf("_C{ ------------------------------------------------------------      }\n");
printf("\n");
        STEALNAME(SEEK_SET)
        STEALNAME(TCGETS)
        STEALNAME(TCSETS)
        STEALNAME(ECHO)
        STEALNAME(EAGAIN)
        STEALNAME(EINTR)
        STEALNAME(EPIPE)
        STEALNAME(VMIN)
        STEALNAME(VTIME)
        STEALNAME(ICANON)
        STEALNAME(O_RDWR)
        STEALNAME(O_RDONLY)
        STEALNAME(O_WRONLY)
        STEALNAME(O_CREAT)
        STEALNAME(O_NONBLOCK)

        STEAL("SIZE_TERMIO",sizeof(struct termios))

printf("\n");
printf("_C{ Numbers of system calls. See \"Linux kernel Internals\" Appendix A. }\n");
printf("_C{ By M.Beck, H. Boehme e.a. Addison Wesley.                         }\n");
printf("_C{ The system calls themselves are extensively documented in chapter }\n");
printf("_C{ 2 of the man pages, e.g. \"man 2 exit\"}\n");
        STEALSYS(exit)
        STEALSYS(open)
        STEALSYS(close)
        STEALSYS(creat)
        STEALSYS(unlink)
        STEALSYS(chdir)
        STEALSYS(read)
        STEALSYS(select)
        STEALSYS(_newselect)
        STEALSYS(write)
        STEALSYS(ioctl)
        STEALSYS(ioperm)
        STEALSYS(iopl)
        STEALSYS(lseek)
        STEALSYS(execve)
        STEALSYS(fork)
        STEALSYS(waitpid)
printf("_C{ ------------------------------------------------------------      }\n");
printf("_C{   End of constants stolen from C.                                 }\n");
printf("_C{ ------------------------------------------------------------      }\n");
        exit(0);
}
