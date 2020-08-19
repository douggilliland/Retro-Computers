
/***************************** 68000 SIMULATOR ****************************

File Name: CODE4.C
Version: 1.0

The instructions implemented in this file are the integer arithmetic
	operations:

		DIVS, DIVU, MULS, MULU, NEG, NEGX, CMP, CMPA, CMPI, CMPM,
		TST, CLR, EXT


***************************************************************************/


#include <stdio.h>
#include "extern.h"         /* contains global "extern" declarations */





int	DIVS()
{
int	reg, overflow;
long	remainder;

if (eff_addr ((long) WORD, DATA_ADDR, TRUE))
	return (BAD_INST);			/* bad instruction format */

reg = (inst >> 9) & 0x0007;

from_2s_comp (EV1 & WORD, (long) WORD, &source);
from_2s_comp (D[reg], LONG, &dest);

if (source == 0)
	return (DIV_BY_ZERO);		/* initiate exception processing */

/* check for overflow */
if ( ( (source < 0) && (dest >= 0) ) || ( (source >= 0) && (dest < 0) ) )
	{
	if ((dest / -source) > WORD)
		overflow = TRUE;
	else
		overflow = FALSE;
	}
else
	{
	if ((dest / source) > WORD)
		overflow = TRUE;
	else
		overflow = FALSE;
	}

if (overflow)
	SR |= vbit;			/* if overflow then quit */
else
	{
	SR &= ~vbit;
	result = (dest / source) & 0xffff;
	remainder = (dest % source) & 0xffff;
	D[reg] = result = result | (remainder * 0x10000);
	cc_update (N_A, GEN, GEN, N_A, ZER, source, dest, result, (long) WORD, 0);
	if ( ( (source < 0) && (dest >= 0) ) || ( (source >= 0) && (dest < 0) ) )
		SR |= nbit;
	else
		SR &= ~nbit;
	}

inc_cyc (158);

return SUCCESS;

}



int	DIVU()
{
int	reg;

if (eff_addr ((long) WORD, DATA_ADDR, TRUE))
	return (BAD_INST);			/* bad instruction format */

reg = (inst >> 9) & 0x0007;

source = EV1 & WORD;
dest = D[reg];

if (source == 0)
	return (DIV_BY_ZERO);		/* initiate exception processing */

if ( (dest / source) > WORD)
	SR |= vbit; 		/* check for overflow */
else
	{
	SR &= ~vbit;
	D[reg] = result =((dest / source) & 0xffff) | ((dest % source) * 0x10000);

	cc_update (N_A, GEN, GEN, N_A, ZER, source, dest, result, (long) WORD, 0);
	}

inc_cyc (140);

return SUCCESS;

}



int	MULS()
{
int	reg;

if (eff_addr ((long) WORD, DATA_ADDR, TRUE))
	return (BAD_INST);			/* bad instruction format */

reg = (inst >> 9) & 0x0007;

from_2s_comp (EV1 & WORD, (long) WORD, &source);
from_2s_comp (D[reg] & WORD, (long) WORD, &dest);

D[reg] = result = source * dest;

cc_update (N_A, GEN, GEN, CASE_9, ZER, source, dest, result, (long) WORD, 0);

inc_cyc (70);

return SUCCESS;

}



int	MULU()
{
int	reg;

if (eff_addr ((long) WORD, DATA_ADDR, TRUE))
	return (BAD_INST);			/* bad instruction format */

reg = (inst >> 9) & 0x0007;

source = EV1 & WORD;
dest = D[reg] & WORD;

D[reg] = result = source * dest;

cc_update (N_A, GEN, GEN, ZER, ZER, source, dest, result, LONG, 0);

inc_cyc (70);

return SUCCESS;

}



int	NEG()
{
long	size;

if ((decode_size(&size)) ||
    (eff_addr (size, DATA_ALT_ADDR, TRUE)))
	return (BAD_INST);		/* bad instruction format */

source = dest = EV1 & size;

/* perform the NEG operation */
put (EA1, -dest, size);
value_of (EA1, &result, size);

cc_update (GEN, GEN, GEN, CASE_3, CASE_4, source, dest, result, size, 0);

if (inst & 0x0030) 
	inc_cyc ( (size == LONG) ? 12 : 8);
else 
	inc_cyc ( (size == LONG) ? 6 : 4);

return SUCCESS;

}



int	NEGX()
{
long	size;

if ((decode_size(&size)) ||
    (eff_addr (size, DATA_ALT_ADDR, TRUE)))
	return (BAD_INST);		/* bad instruction format */

dest = dest = EV1 & size;

/* perform the NEGX operation */
put (EA1, -dest - ((SR & xbit) >> 4), size);
value_of (EA1, &result, size);

cc_update (GEN, GEN, CASE_1, CASE_3, CASE_4, source, dest, result, size, 0);

if (inst & 0x0030) {
	inc_cyc ( (size == LONG) ? 12 : 8);
	}
else {
	inc_cyc ( (size == LONG) ? 6 : 4);
	}

return SUCCESS;

}



int	CMP()
{
long	size;
int	reg;

if ((decode_size(&size)) || 
    (eff_addr (size, ALL_ADDR, TRUE)))
	return (BAD_INST);			/* bad instruction format */

reg = (inst >> 9) & 0x0007;

source = EV1 & size;
dest = D[reg] & size;

put (&result, dest - source, size);

/* now set the condition codes */
cc_update (N_A, GEN, GEN, CASE_2, CASE_6, source, dest, result, size, 0);

inc_cyc ( (size == LONG) ? 6 : 4);

return SUCCESS;

}


int	CMPA()
{
long	size;
int	reg;

if (inst & 0x0100)
	size = LONG;
else
	size = WORD;

if (eff_addr (size, ALL_ADDR, TRUE))
	return (BAD_INST);			/* bad instruction format */

reg = a_reg((inst >> 9) & 0x0007);

if (size == WORD)
	sign_extend ((int)EV1, WORD, &EV1);

source = EV1 & size;
dest = A[reg] & size;

put (&result, dest - source, size);

/* now set the condition codes according to the result */
cc_update (N_A, GEN, GEN, GEN, GEN, source, dest, result, size, 0);

inc_cyc (6);

return SUCCESS;

}


int	CMPI()
{
long	size;

if (decode_size(&size))
	return (BAD_INST);			/* bad instruction format */

mem_request (&PC, size, &source);

if (eff_addr (size, DATA_ALT_ADDR, TRUE))
	return (BAD_INST);			/* bad instruction format */

dest = EV1 & size;

put (&result, dest - source, size);

cc_update (N_A, GEN, GEN, CASE_2, CASE_6, source, dest, result, size, 0);

if (inst & 0x0038) {
	inc_cyc ( (size == LONG) ? 12 : 8);
	}
else {
	inc_cyc ( (size == LONG) ? 14 : 8);
	}

return SUCCESS;

}



int	CMPM()
{
long	size;
int	Rx, Ry;

if (decode_size(&size)) 
	return (BAD_INST);

Rx = a_reg((inst >> 9) & 0x07);
Ry = a_reg(inst & 0x07);

mem_req ( (int) A[Ry], size, &source);
mem_req ( (int) A[Rx], size, &dest);

put (&result, dest - source, size);

if (size == BYTE)  {
	A[Rx]++;
	A[Ry]++;
	};
if (size == WORD)  {
	A[Rx] += 2;
	A[Ry] += 2;
	};
if (size == LONG)  {
	A[Rx] += 4;
	A[Ry] += 4;
	};

/* now set the condition codes according to the result */
cc_update (N_A, GEN, GEN, CASE_2, CASE_6, source, dest, result, size, 0);

inc_cyc ( (size == LONG) ? 20 : 12);

return SUCCESS;

}




int	TST()
{
long	size;

if ((decode_size(&size)) ||
    (eff_addr (size, DATA_ALT_ADDR, TRUE)))
	return (BAD_INST);		/* bad instruction format */

value_of (EA1, &dest, size);

/* test the dest operand and set the condition codes accordingly */
cc_update (N_A, GEN, GEN, ZER, ZER, source, dest, dest, size, 0);

if (inst & 0x0030) {
	inc_cyc ( (size == LONG) ? 4 : 4);
	}
else {
	inc_cyc ( (size == LONG) ? 4 : 4);
	}

return SUCCESS;

}



int	CLR()
{
long	size;

if ((decode_size(&size)) ||
    (eff_addr (size, DATA_ALT_ADDR, TRUE)))
	return (BAD_INST);		/* bad instruction format */

source = dest = EV1 & size;

/* perform the CLR operation */
put (EA1, (long) 0, size);
value_of (EA1, &result, size);

cc_update (N_A, ZER, GEN, ZER, ZER, source, dest, result, size, 0);

if (inst & 0x0030) {
	inc_cyc ( (size == LONG) ? 12 : 8);
	}
else {
	inc_cyc ( (size == LONG) ? 6 : 4);
	}

return SUCCESS;

}




int	EXT()
{
long	size;
int	reg;

reg = inst & 0x07;

if (inst & 0x0040)
	size = LONG;
else
	size = WORD;

source = dest = D[reg] & size;

if (size == WORD)
 D[reg] = (D[reg]&~WORD) | (D[reg] & BYTE) | (0xff00 * ((D[reg]>>7) & 0x01));
else
 D[reg] = (D[reg] & WORD) | (0xffff0000 * ((D[reg] >> 15) & 0x01));

cc_update (N_A, GEN, GEN, ZER, ZER, source, dest, D[reg], size, 0);

inc_cyc (4);

return SUCCESS;

}

