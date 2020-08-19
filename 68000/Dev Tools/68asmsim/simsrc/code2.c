
/***************************** 68000 SIMULATOR ****************************

File Name: CODE2.C
Version: 1.0

The instructions implemented in this file are the data movement instructions
   other than the MOVE instructions:

		EXG, LEA, PEA, LINK, UNLK


***************************************************************************/


#include <stdio.h>
#include "extern.h"         /* contains global "extern" declarations */




int	EXG()
{
long	temp_reg;
int	Rx, Ry;

Rx = (inst >> 9) & 0x07;
Ry = inst & 0x07;
switch ((inst >> 3) & 0x1f)
	{
	case 0x08: temp_reg = D[Rx];
		D[Rx] = D[Ry];
		D[Ry] = temp_reg;
		break;
	case 0x09:	temp_reg = A[a_reg(Rx)];
		A[a_reg(Rx)] = A[a_reg(Ry)];
		A[a_reg(Ry)] = temp_reg;
		break;
	case 0x11: temp_reg = D[Rx];
		D[Rx] = A[a_reg(Ry)];
		A[a_reg(Ry)] = temp_reg;
		break;
	default  : return (BAD_INST);	/* bad op_mode field */
              break;
	}

inc_cyc (6);

return SUCCESS;

}




int	LEA()
{
int	reg;

reg = (inst >> 9) & 0x07;

if (eff_addr (LONG, CONTROL_ADDR, FALSE))
	return (BAD_INST);		/* bad instruction format */

/* perform the LEA operation */
A[a_reg(reg)] = (long) ((long)EA1 - (long)&memory[0]);

switch (eff_addr_code (inst, 0)) {
	case 0x02 : inc_cyc (4);
	            break;
	case 0x05 : inc_cyc (8);
	            break;
	case 0x06 : inc_cyc (12);
	            break;
	case 0x07 : inc_cyc (8);
	            break;
	case 0x08 : inc_cyc (12);
	            break;
	case 0x09 : inc_cyc (8);
	            break;
	case 0x0a : inc_cyc (12);
	            break;
	default   : break;
	}

return SUCCESS;

}




int	PEA()
{

if (eff_addr (LONG, CONTROL_ADDR, FALSE))
	return (BAD_INST);		/* bad instruction format */

/* push the longword address computed by the */
/* effective address routine onto the stack */

A[a_reg(7)] -= 4;
put (&memory[A[a_reg(7)]], (long) ((long)EA1 - (long)&memory[0]), LONG);

switch (eff_addr_code (inst, 0)) {
	case 0x02 : inc_cyc (12);
	            break;
	case 0x05 : inc_cyc (16);
	            break;
	case 0x06 : inc_cyc (20);
	            break;
	case 0x07 : inc_cyc (16);
	            break;
	case 0x08 : inc_cyc (20);
	            break;
	case 0x09 : inc_cyc (16);
	            break;
	case 0x0a : inc_cyc (20);
	            break;
	default   : break;
	}

return SUCCESS;

}




int	LINK()
{
int	reg;
long	temp, displacement;

reg = inst & 0x07;

mem_request (&PC, (long) WORD, &temp);
from_2s_comp(temp, (long) WORD, &displacement);

/* perform the LINK operation */
A[a_reg(7)] -= 4;
put (&memory[A[a_reg(7)]], A[reg], LONG);
A[reg] = A[a_reg(7)];
A[a_reg(7)] = A[a_reg(7)] + displacement;

inc_cyc (16);

return SUCCESS;

}



int	UNLK()
{
int	reg;

reg = inst & 0x07;

A[a_reg(7)] = A[reg];
mem_req ( (int) A[a_reg(7)], LONG, &A[reg]);
A[a_reg(7)] += 4;

inc_cyc (12);

return SUCCESS;

}

