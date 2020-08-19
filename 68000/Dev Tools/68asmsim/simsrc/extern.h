
/***************************** 68000 SIMULATOR ****************************

File Name: EXTERN.H
Version: 1.0

This file contains all extern global variable definitions for the 
simulator program.  It is included in all modules other than the module
"sim.c" which contains the main() function.


        BE CAREFUL TO KEEP THESE DECLARATIONS IDENTICAL TO THE GLOBAL
        VARIABLE DECLARATIONS IN "VAR.H"


***************************************************************************/


#include "def.h"			/* constant declarations */
#include "proto.h"		/* function prototypes */


extern long			D[D_REGS], OLD_D[D_REGS], A[A_REGS], OLD_A[A_REGS];
extern long			PC, OLD_PC;
extern short		SR, OLD_SR;

extern char			memory[MEMSIZE];
extern char			bpoints;
extern char			lbuf[82], *wordptr[20], buffer[40];
extern int			cycles, old_cycles;
extern int			brkpt[100];
extern char			p1dif;
extern char			*gettext();
extern int			wcount;
extern unsigned	int port1[4];
extern char			p1dif;
extern int			errflg;
extern int			trace, sstep, old_trace, old_sstep, exceptions;
extern int			inst;
extern long			*EA1, *EA2;
extern long			EV1, EV2;

extern long			source, dest, result;

extern long			global_temp;		/* to hold an immediate data operand */

