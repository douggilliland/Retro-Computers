
/***************************** 68000 SIMULATOR ****************************

File Name: CODE9.C
Version: 1.0

The instructions implemented in this file are the exception processing
related operations:

        CHK, ILLEGAL, RESET, STOP, TRAP, TRAPV	


***************************************************************************/


#include <stdio.h>
#include "extern.h"         /* contains global "extern" declarations */




int	CHK()
{
int	reg;
long	temp;

reg = (inst >> 9) & 0x07;

if (eff_addr ((long) WORD, DATA_ADDR, TRUE))
	return (BAD_INST);		/* bad instruction format */

from_2s_comp (EV1, (long) WORD, &source);
dest = D[reg] & WORD;

cc_update (N_A, GEN, UND, UND, UND, source, D[reg], D[reg], WORD, 0);

/* perform the CHK operation */
if ((dest < 0) || (dest > source))
	return(CHK_EXCEPTION);

inc_cyc (10);

return SUCCESS;

}



int	ILLEGAL()
{

return (ILLEGAL_TRAP);

}



int	RESET()
{

if (!(SR & sbit))
	return (NO_PRIVILEGE);

/* assert the reset line to reset external devices */

inc_cyc (132);

return SUCCESS;

}



int	STOP()
{
long	temp;
int	tr_on;

inc_cyc (4);

mem_request (&PC, (long) WORD, &temp);

if (SR & tbit)
	tr_on = TRUE;
else
	tr_on = FALSE;

if (!(SR & sbit))
	return (NO_PRIVILEGE);

SR = temp & WORD;
if (tr_on)
	SR = SR | tbit;

if (!(SR & sbit))
	return (NO_PRIVILEGE);

if (!(SR & tbit))
	printf ("Processor has entered stop mode.  Processing halted.");
else
	{
	printf ("Processor has entered stop mode.\n");
	printf ("Processing halted, but resumed due to a trace exception.");
	}

return (STOP_TRAP);

}



int	TRAP()
{

return (TRAP_TRAP);

}




int	TRAPV()
{

if (SR & vbit)
	return (TRAPV_TRAP);

inc_cyc (4);

return SUCCESS;

}

