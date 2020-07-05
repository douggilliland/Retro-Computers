#if defined(__sparc__)
/*
 * XXX: Need to put a list of the field contents here.
 *
 * NOTE: Based on BSD source.
 */
#define	_JBLEN	10
#endif

/* necv70 was 9 as well. */

#if defined(__mc68000__)
/*
 * onsstack,sigmask,sp,pc,psl,d2-d7,a2-a6,
 * fp2-fp7	for 68881.
 * All else recovered by under/over(flow) handling.
 */
#define	_JBLEN	34
#endif

#if defined(__H8300__)
/*
 * 8 regs + pc + reg
 * 
 */
#define	_JBLEN	11
#endif

#if defined(__Z8001__) || defined(__Z8002__)
/* 16 regs + pc */
#define _JBLEN 20
#endif

#if defined(___AM29K__)
/*
 * onsstack,sigmask,sp,pc,npc,psr,g1,o0,wbcnt (sigcontext).
 * All else recovered by under/over(flow) handling.
 */
#define	_JBLEN	9
#endif

#if defined(__i386__)
#if defined(__unix__)
# define _JBLEN	36
#else
#include "setjmp-dj.h"
#endif
#endif

#if defined(__i960__)
#define _JBLEN 35
#endif

#if defined(__mips__)
#define _JBLEN 11
#endif

#if defined(__m88000__)
#define _JBLEN 21
#endif

#if defined(__powerpc__)
#define _JBLEN 59
#endif

#if defined(__hppa__)
#define _JBLEN 48
#endif

#if defined(__sh__)
#define _JBLEN 20
#endif

#if defined(__v800)
#define _JBLEN 28
#endif

#ifdef _JBLEN
typedef	int jmp_buf[_JBLEN];
/*
 * One extra word for the "signal mask saved here" flag.
 */
typedef	int sigjmp_buf[_JBLEN+1];
#endif
