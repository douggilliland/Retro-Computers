
/***************************** 68000 SIMULATOR ****************************

File Name: CODE6.C
Version: 1.0

The instructions implemented in this file are the logical arithmetic
   operations:

		AND, ANDI, ANDI_TO_CCR, ANDI_TO_SR, OR, ORI, ORI_TO_CCR,
		ORI_TO_SR, EOR, EORI, EORI_TO_CCR, EORI_TO_SR, NOT


***************************************************************************/


#include <stdio.h>
#include "extern.h"         /* contains global "extern" declarations */



int	AND()
{
int	addr_modes_mask, reg;
long	size;

addr_modes_mask = (inst & 0x0100) ? MEM_ALT_ADDR : DATA_ADDR;

if ((decode_size(&size)) ||
    (eff_addr (size, addr_modes_mask, TRUE)))
	return (BAD_INST);			/* bad instruction format */

reg = (inst >> 9) & 0x0007;

if (inst & 0x0100)
	{
	source = D[reg] & size;
	dest = EV1 & size;
	put (EA1, dest & source, size);
	value_of (EA1, &result, size);
	}
else
	{
	source = EV1 & size;
	dest = D[reg] & size;
	put (&D[reg], dest & source, size);
	result = D[reg] & size;
	}

cc_update (N_A, GEN, GEN, ZER, ZER, source, dest, result, size, 0);

if (inst & 0x0100) 
	inc_cyc ( (size == LONG) ? 12 : 8);
else {
	if (size == LONG) {
		if ( (!(inst & 0x0030)) || ((inst & 0x003f) == 0x003c) )
			inc_cyc (8);
		else
			inc_cyc (6);
		}
	else {
		inc_cyc (4);
		}
	}

return SUCCESS;

}



int	ANDI()
{
long	size;

if (decode_size(&size))
	return (BAD_INST);			/* bad instruction format */

mem_request (&PC, size, &source);

if (eff_addr (size, DATA_ALT_ADDR, TRUE))
	return (BAD_INST);			/* bad instruction format */

dest = EV1 & size;

put (EA1, source & dest, size);
value_of (EA1, &result, size);

cc_update (N_A, GEN, GEN, ZER, ZER, source, dest, result, size, 0);

if (inst & 0x0038)
	inc_cyc ( (size == LONG) ? 20 : 12);
else
	inc_cyc ( (size == LONG) ? 16 : 8);

return SUCCESS;

}


int	ANDI_TO_CCR()
{
long	temp;

mem_request (&PC, (long) WORD, &temp);

SR &= temp | 0xff00;

inc_cyc (20);

return SUCCESS;

}


int	ANDI_TO_SR()
{
long	temp;

if (!(SR & sbit))
	return (NO_PRIVILEGE);

mem_request (&PC, (long) WORD, &temp);
SR &= temp;

inc_cyc (20);

return SUCCESS;

}




int	OR()
{
long	size;
int	mask, reg;

mask = (inst & 0x0100) ? MEM_ALT_ADDR : DATA_ADDR;

if ((decode_size(&size)) || 
    (eff_addr(size, mask, TRUE)))
	return (BAD_INST);		/* bad instruction format */

reg = (inst >> 9) & 0x0007;

if (inst & 0x0100)
	{
	source = D[reg] & size;
	dest = EV1 & size;
	put (EA1, source | dest, size);
	value_of (EA1, &result, size);
	}
else
	{
	source = EV1 & size;
	dest = D[reg] & size;
	put (&D[reg], source | dest, size);
	result = D[reg] & size;
	}

cc_update (N_A, GEN, GEN, ZER, ZER, source, dest, result, size, 0);

if (inst & 0x0100) 
	inc_cyc ( (size == LONG) ? 12 : 8);
else {
	if (size == LONG) {
		if ( (!(inst & 0x0030)) || ((inst & 0x003f) == 0x003c) )
			inc_cyc (8);
		else
			inc_cyc (6);
		}
	else 
		inc_cyc (4);
	}

return SUCCESS;

}




int	ORI()
{
long	size;

if (decode_size(&size))
	return (BAD_INST);			/* bad instruction format */

mem_request (&PC, size, &source);

if (eff_addr (size, DATA_ALT_ADDR, TRUE))
	return (BAD_INST);			/* bad instruction format */

dest = EV1 & size;

put (EA1, source | dest, size);
value_of (EA1, &result, size);

cc_update (N_A, GEN, GEN, ZER, ZER, source, dest, result, size, 0);

if (inst & 0x0038) {
	inc_cyc ( (size == LONG) ? 20 : 12);
	}
else {
	inc_cyc ( (size == LONG) ? 16 : 8);
	}

return SUCCESS;

}


int	ORI_TO_CCR()
{
long	temp;

mem_request (&PC, (long) WORD, &temp);

SR |= temp;

inc_cyc (20);

return SUCCESS;

}


int	ORI_TO_SR()
{
long	temp;

if (!(SR & sbit))
	return (NO_PRIVILEGE);

mem_request (&PC, (long) WORD, &temp);
SR |= temp;

inc_cyc (20);

return SUCCESS;

}



int	EOR()
{
long	size;
int	reg;

if ((decode_size(&size)) ||
    (eff_addr (size, DATA_ALT_ADDR, TRUE)))
	return (BAD_INST);			/* bad instruction format */

reg = (inst >> 9) & 0x0007;

source = D[reg] & size;
dest = EV1 & size;

put (EA1, EV1 ^ D[reg], size);
value_of (EA1, &result, size);

cc_update (N_A, GEN, GEN, ZER, ZER, source, dest, result, size, 0);

if (inst & 0x0038)
	inc_cyc ( (size == LONG) ? 12 : 8);
else
	inc_cyc ( (size == LONG) ? 8 : 4);

return SUCCESS;

}



int	EORI()
{
long	size;
int	data;

if (decode_size(&size))
	return (BAD_INST);			/* bad instruction format */

mem_request (&PC, size, &source);

if (eff_addr (size, DATA_ALT_ADDR, TRUE))
	return (BAD_INST);			/* bad instruction format */

dest = EV1 & size;

put (EA1, source ^ dest, size);
value_of (EA1, &result, size);

cc_update (N_A, GEN, GEN, ZER, ZER, source, dest, result, size, 0);

if (inst & 0x0038) {
	inc_cyc ( (size == LONG) ? 20 : 12);
	}
else {
	inc_cyc ( (size == LONG) ? 16 : 8);
	}

return SUCCESS;

}


int	EORI_TO_CCR()
{
long	temp;

mem_request (&PC, (long) WORD, &temp);

SR ^= temp;

inc_cyc (20);

return SUCCESS;

}


int	EORI_TO_SR()
{
long	temp;

if (!(SR & sbit))
	return (NO_PRIVILEGE);

mem_request (&PC, (long) WORD, &temp);
SR ^= temp;

inc_cyc (20);

return SUCCESS;

}


int	NOT()
{
long	size;

if ((decode_size(&size)) ||
    (eff_addr (size, DATA_ALT_ADDR, TRUE)))
	return (BAD_INST);		/* bad instruction format */

source = dest = EV1 & size;

/* perform the NOT operation */
put (EA1, ~dest, size);
value_of (EA1, &result, size);

cc_update (N_A, GEN, GEN, ZER, ZER, source, dest, result, size, 0);

if (inst & 0x0030) {
	inc_cyc ( (size == LONG) ? 12 : 8);
	}
else {
	inc_cyc ( (size == LONG) ? 6 : 4);
	}

return SUCCESS;

}

