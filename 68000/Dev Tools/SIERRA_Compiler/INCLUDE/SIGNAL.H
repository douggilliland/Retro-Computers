/*------------------------------ signal.h -----------------------------------*/

/*
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

typedef long sig_atomic_t;

void (*signal(int sig, void (*func)(int)))(int);
int raise(int sig);

#define SIG_DFL	    (void (*)(int))0	/* set default handling of signal */
#define SIG_IGN	    (void (*)(int))1	/* set request to ignore signal	  */
#define SIG_ERR	    (void (*)(int))-1	/* rcvd when signal req refused	  */

/*
 * The signal numbers defined below are used in the files signal.c,
 * xcptn.c, ldtraps.s, h_ldtrap.s, traps.s, and ftraps.s all of which
 * are located in the SIERRA/lib/src directory.	 Any modifications
 * to the macros ** MUST ** be accompanied by identical modifications to
 * the above listed files.  Remember to change the value of MAXSIG if
 * new signal numbers such as SIGUSER are added.
 */

#define MAXSIG	    12	    /* signal number of highest defined signal	 */

#define SIGABRT	    1	    /* abnormal program termination e.g. abort() */
#define SIGBUS	    2	    /* bus error				 */
#define SIGCHK	    3	    /* chk instruction exception		 */
#define SIGFPE	    4	    /* floating point exception			 */
#define SIGILL	    5	    /* illegal instruction			 */
#define SIGINT	    6	    /* interrupt				 */
#define SIGTRAP	    7	    /* trapv, trapcc instruction executed	 */
#define SIGPRIV	    8	    /* privilege violation			 */
#define SIGADDR	    9	    /* address error				 */
#define SIGTERM	    10	    /* termination request			 */
#define SIGSPUR	    11	    /* spurious interrupt			 */
#define SIGZDIV	    12	    /* divide by zero				 */

/*
#define SIGUSER	    13	    /* user supported exception			 ./
*/
