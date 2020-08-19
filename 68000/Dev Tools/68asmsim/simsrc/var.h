
/***************************** 68000 SIMULATOR ****************************

File Name: VAR.H
Version: 1.0

This file contains all global variable definitions for the simulator 
program.  It is included in the module "sim.c" which contains main().



        BE CAREFUL TO KEEP THESE DECLARATIONS IDENTICAL TO THE GLOBAL
        VARIABLE DECLARATIONS IN "EXTERN.H"


***************************************************************************/


#include "def.h"                   /* include file for constants & types */
#include "proto.h"		/* function prototypes */


long 	D[D_REGS], OLD_D[D_REGS], A[A_REGS], OLD_A[A_REGS];
long 	PC, OLD_PC;
short	SR, OLD_SR;
int	cycles, old_cycles;
int 	trace, sstep, old_trace, old_sstep, exceptions;

char	memory[MEMSIZE];								/* array for memory */
char	buffer[40], lbuf[82], *wordptr[20]; 	/* command buffers */
char	bpoints = 0;
int 	brkpt[100], wcount;
int 	errflg;
int 	inst;

long	*EA1, *EA2;
long	EV1, EV2;

long	source, dest, result;

long	global_temp;		/* to hold an immediate data operand */

/* port structure is :{control,trans data,status,recieve data} */
unsigned int port1[4] = {0x00,0,0x82,0};	/* simulated 6850 port */
char 	p1dif = 0;

