
/***************************** 68000 SIMULATOR ****************************

File Name: CODE7.C
Version: 1.0

The instructions implemented in this file are shift and rotate operations:

		SHIFT_ROT (ASL, ASR, LSL, LSR, ROL, ROR, ROXL, ROXR), SWAP,
		BIT_OP (BCHG, BCLR, BSET, BTST), TAS


***************************************************************************/


#include <stdio.h>
#include "extern.h"         /* contains global "extern" declarations */




int	SHIFT_ROT()
{
long	size;
int	reg, count_reg, shift_count, shift_size, type, counter, msb, mem_reg;
int	direction, temp_bit, temp_bit_2;

if (mem_reg = ((inst & 0xc0) == 0xc0))
	{
	if (eff_addr ((long) WORD, MEM_ALT_ADDR, TRUE))
		return (BAD_INST);		/* bad instruction format */
	size = WORD;
	shift_count = 1;
	source = dest = EV1 & size;
	type = (inst & 0x600) >> 9;
	inc_cyc (8);
	}
else
	{
	if (decode_size(&size)) 
		return (BAD_INST); /* bad instruction format */
	if (inst & 0x20)
		shift_count = D[(inst >> 9) & 0x7] % 64;
	else
		{
		shift_count = (inst >> 9) & 0x7;
		if (shift_count == 0)
			shift_count = 8;
		}
	reg = inst & 7;
	source = dest = D[reg] & size;
	type = (inst & 0x18) >> 3;
	EA1 = &D[reg];
	value_of (EA1, &EV1, size);
	if (size == LONG)
		inc_cyc (8 + 2 * shift_count);
	else
		inc_cyc (6 + 2 * shift_count);
	}
direction = inst & 0x100;
if (size == LONG)
	shift_size = 31;
else if (size == WORD)
	shift_size = 15;
else
	shift_size = 7;

if (shift_count == 0)
	{
	if (type == 2)
		cc_update (N_A, GEN, GEN, ZER, CASE_1, 
			source, dest, EV1, size, shift_count);
	else
		cc_update (N_A, GEN, GEN, ZER, ZER, 
			source, dest, EV1, size, shift_count);
	}
else
switch (type) {
	case 0 : 											/* do an arithmetic shift */
	if (direction) {			/* do a shift left */
		put (EA1, (EV1 & size) << shift_count, size);
		value_of (EA1, &EV1, size);
		cc_update (GEN, GEN, GEN, CASE_4, CASE_3, 
				source, dest, EV1, size, shift_count);
		}
	else {		/* do a shift right */
		/* do the shift replicating the most significant bit */
		if ((EV1 >> shift_size) & 1)
			temp_bit = 1;
		else
			temp_bit = 0;
		for (counter = 1; counter <= shift_count; counter++)
			{
			put (EA1, (EV1 & size) >> 1, size);
			value_of (EA1, &EV1, size);
			if (temp_bit)
				put (EA1, EV1 | (1 << shift_size), size);
			else
				put (EA1, EV1 & (~(1 << shift_size)), size);
			value_of (EA1, &EV1, size);
			}
		cc_update (GEN, GEN, GEN, ZER, CASE_2, 
				source, dest, EV1, size, shift_count);
		}
      break;
	case 1 : 											/* do a logical shift */
				if (direction) {			/* do a shift left */
					put (EA1, EV1 << shift_count, size);
					value_of (EA1, &EV1, size);
					cc_update (GEN, GEN, GEN, ZER, CASE_3, 
							source, dest, EV1, size, shift_count);
					}
				else {		/* do a shift right */
					put (EA1, (EV1 & size) >> shift_count, size);
					value_of (EA1, &EV1, size);
					cc_update (GEN, GEN, GEN, ZER, CASE_2, 
							source, dest, EV1, size, shift_count);
					}
            break;
	case 2 :                    					/* do a rotate with extend */
				if (direction) {			/* do a rotate left */
					for (counter = 1; counter <= shift_count; counter++)
						{
						temp_bit = (EV1 >> shift_size) & 1;
						temp_bit_2 = (SR & xbit) >> 4;
						put (EA1, (EV1 & size) << 1, size);
						value_of (EA1, &EV1, size);
						if (temp_bit_2)
							put (EA1, EV1 | 1, size);
						else
							put (EA1, EV1 & ~1, size);
						value_of (EA1, &EV1, size);
						if (temp_bit)
							SR = SR | xbit;
						else
							SR = SR & ~xbit;
						}
					cc_update (GEN, GEN, GEN, ZER, CASE_3, 
							source, dest, EV1, size, shift_count);
					}
				else {		/* do a rotate right */
					for (counter = 1; counter <= shift_count; counter++)
						{
						temp_bit = EV1 & 1;
						temp_bit_2 = (SR & xbit) >> 4;
						put (EA1, (EV1 & size) >> 1, size);
						value_of (EA1, &EV1, size);
						if (temp_bit_2)
							put (EA1, EV1 | (1 << shift_size), size);
						else
							put (EA1, EV1 & (~(1 << shift_size)), size);
						value_of (EA1, &EV1, size);
						if (temp_bit)
							SR = SR | xbit;
						else
							SR = SR & ~xbit;
						}
					put (EA1, EV1, size);		
					cc_update (GEN, GEN, GEN, ZER, CASE_2, 
							source, dest, EV1, size, shift_count);
					}
            break;
	case 3 : 											/* do a rotate */
				if (direction) {			/* do a rotate left */
					for (counter = 1; counter <= shift_count; counter++)
						{
						temp_bit = (EV1 >> shift_size) & 1;
						put (EA1, (EV1 & size) << 1, size);
						value_of (EA1, &EV1, size);
						if (temp_bit)
							put (EA1, EV1 | 1, size);
						else
							put (EA1, EV1 & ~1, size);
						value_of (EA1, &EV1, size);
						}
					cc_update (N_A, GEN, GEN, ZER, CASE_3, 
							source, dest, EV1, size, shift_count);
					}
				else {		/* do a rotate right */
					for (counter = 1; counter <= shift_count; counter++)
						{
						temp_bit = EV1 & 1;
						put (EA1, (EV1 & size) >> 1, size);
						value_of (EA1, &EV1, size);
						if (temp_bit)
							put (EA1, EV1 | (1 << shift_size), size);
						else
							put (EA1, EV1 & (~(1 << shift_size)), size);
						value_of (EA1, &EV1, size);
						}
					cc_update (N_A, GEN, GEN, ZER, CASE_2, 
							source, dest, EV1, size, shift_count);
					}
            break;
	}

return SUCCESS;

}



int	SWAP()
{
long	reg;

reg = inst & 0x07;

/* perform the SWAP operation */
D[reg] = ((D[reg] & WORD) * 0x10000) | ((D[reg] & 0xffff0000) / 0x10000);

cc_update (N_A, GEN, GEN, ZER, ZER, source, dest, D[reg], LONG, 0);

inc_cyc (4);

return SUCCESS;

}



int	BIT_OP()
{
int	reg, mem_reg;
long	size, bit_no;

if (inst & 0x100)
	bit_no = D[(inst >> 9) & 0x07];
else
	{
	mem_request (&PC, (long) WORD, &bit_no);
	bit_no = bit_no & 0xff;
	}

mem_reg = (inst & 0x38);

if (eff_addr ((long) BYTE, DATA_ADDR, TRUE))
	return (BAD_INST);		/* bad instruction format */

if (mem_reg)
	{
	bit_no = bit_no % 8;
	size = BYTE;
	}
else
	{
	bit_no = bit_no % 32;
	size = LONG;
	}

if ((EV1 >> bit_no) & 1)
	SR = SR & (~zbit);
else
	SR = SR | zbit;

switch ((inst >> 6) & 0x3) {
	case 0 : 			/* perform a bit test operation */
		  if (mem_reg)
			inc_cyc (4);
		  else
			inc_cyc (6);
		  break;
	case 1 : 			/* perform a bit change operation */
			if ((EV1 >> bit_no) & 1)
				put (EA1, *EA1 & (~(1 << bit_no)), size);
			else
				put (EA1, *EA1 | (1 << bit_no), size);
			inc_cyc (8);
		  break;
	case 2 : /* perform a bit clear operation */
			put (EA1, *EA1 & (~(1 << bit_no)), size);
		  if (mem_reg)
			inc_cyc (8);
		  else
			inc_cyc (10);
		  break;
	case 3 : /* perform a bit set operation */
			put (EA1, *EA1 | (1 << bit_no), size);
			inc_cyc (8);
		  break;
	}

if (mem_reg)
	inc_cyc (4);

return SUCCESS;

}




int	TAS()
{

if (eff_addr ((long) BYTE, DATA_ALT_ADDR, TRUE))
	return (BAD_INST);		/* bad effective address format */

/* perform the TAS operation */
/* first set the condition codes according to *EA1 */
cc_update (N_A, GEN, GEN, ZER, ZER, source, dest, *EA1, (long) BYTE, 0);

/* then set the high order bit of the *EA1 byte */
put (EA1, EV1 | 0x80, (long) BYTE);

inc_cyc ((inst & 0x30) ? 10 : 4);

return SUCCESS;

}

