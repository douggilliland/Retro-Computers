
/***************************** 68000 SIMULATOR ****************************

File Name: CODE1.C
Version: 1.0

The instructions implemented in this file are the MOVE instructions:

   MOVE, MOVEP, MOVEA, MOVE_FR_SR, MOVE_TO_CCR, MOVE_TO_SR, MOVEM,
   MOVE_USP, MOVEQ


***************************************************************************/



#include <stdio.h>
#include "extern.h"         /* contains global "extern" declarations */


/* the following two arrays specify the execution times of the MOVE
	instruction, for byte/word operands and for long operands */

int	move_bw_times [12][9] = {
            4,    4,    8,    8,    8,   12,   14,   12,   16 ,
            4,    4,    8,    8,    8,   12,   14,   12,   16 ,
            8,    8,   12,   12,   12,   16,   18,   16,   20 ,
            8,    8,   12,   12,   12,   16,   18,   16,   20 ,
           10,   10,   14,   14,   14,   18,   20,   18,   22 ,
           12,   12,   16,   16,   16,   20,   22,   20,   24 ,
           14,   14,   18,   18,   18,   22,   24,   22,   26 ,
           12,   12,   16,   16,   16,   20,   22,   20,   24 ,
           16,   16,   20,   20,   20,   24,   26,   24,   28 ,
           12,   12,   16,   16,   16,   20,   22,   20,   24 ,
           14,   14,   18,   18,   18,   22,   24,   22,   26 ,
            8,    8,   12,   12,   12,   16,   18,   16,   20   };


int	move_l_times [12][9] = {
            4,    4,   12,   12,   12,   16,   18,   16,   20 ,
            4,    4,   12,   12,   12,   16,   18,   16,   20 ,
           12,   12,   20,   20,   20,   24,   26,   24,   28 ,
           12,   12,   20,   20,   20,   24,   26,   24,   28 ,
           14,   14,   22,   22,   22,   26,   28,   26,   30 ,
           16,   16,   24,   24,   24,   28,   30,   28,   32 ,
           18,   18,   26,   26,   26,   30,   32,   30,   34 ,
           16,   16,   24,   24,   24,   28,   30,   28,   32 ,
           20,   20,   28,   28,   28,   32,   34,   32,   36 ,
           16,   16,   24,   24,   24,   28,   30,   28,   32 ,
           18,   18,   26,   26,   26,   30,   32,   30,   34 ,
           12,   12,   20,   20,   20,   24,   26,   24,   28   };


/* the following two arrays specify the instruction execution times
	for the MOVEM instruction for memory-to-reg and reg-to-memory cases */

int     movem_t_r_times[11] = {
        0,    0,    12,   12,    0,   16,   18,   16,   20,   16,   18  };

int     mover_t_m_times[11] = {
        0,    0,     8,    0,    8,   12,   14,   12,   16,    0,    0  };
		


int	MOVE()
{
long	size;				/* 'size' holds the instruction size */
int	src, dst;		/* 'src' and 'dst' hold the addressing mode codes */
							/* for instruction execution time computation */

/* MOVE has a different format for size field than all other instructions */
/* so we can't use the 'decode_size' function */
switch ( (inst >> 12) & 0x03)	
	{
	case 0x01 : size = BYTE;				/* bit pattern '01' */
		         break;
	case 0x03 : size = WORD;				/* bit pattern '10' */
		         break;
	case 0x02 : size = LONG;				/* bit pattern '11' */
		         break;
	default   : return (BAD_INST);		/* bad size field */
               break;
	}

/* the following gets the effective addresses for the source and destination
	operands */
if ( (eff_addr (size, ALL_ADDR, FALSE)) ||
     (eff_addr (size, DATA_ALT_ADDR, FALSE)) )
	return (BAD_INST);   /* if bad address format then return */
								/* the code for 'bad instruction' */

dest = EV2;								/* set 'dest' for use in 'cc_update' */

put (EA2, EV1, size);				/* perform the move to '*EA2' */
value_of (EA2, &EV2, size);		/* set 'EV2' for use in 'cc_update' */

src = eff_addr_code(inst,0);		/* get the addressing mode codes */
dst = eff_addr_code(inst,6);

if (size == LONG)			/* use the codes in instruction time computation */
	inc_cyc (move_l_times [src] [dst]);
else
	inc_cyc (move_bw_times [src] [dst]);

/* now update the condition codes */
cc_update (N_A, GEN, GEN, ZER, ZER, EV1, dest, EV2, size, 0);

/* return the value for 'success' */
return SUCCESS;

}



int	MOVEP()
{
int	address, Dx, disp, count, direction, reg;
long	temp, size;

mem_request (&PC, (long) WORD, &temp);
from_2s_comp (temp, (long) WORD, &temp);

address = A[a_reg(inst&0x07)] + (temp & WORD);

direction = inst & 0x80;

if (inst & 0x40)
	{
	size = LONG;
	count = 4;
	}
else
	{
	size = WORD;
	count = 2;
	}

reg = (inst >> 9) & 0x07;
Dx = D[reg] & size;

for (;count > 0; count--)
	{
	disp = 8 * (count - 1);
	if (direction)
		mem_put ( (long)((Dx >> disp) & BYTE) , address, (long) BYTE);
	else
		{
		mem_req (address, (long) BYTE, &temp);
		switch  (count) {
			case 4 :	D[reg] = (D[reg] & 0x00ffffff) | (temp * 0x1000000);
						break;
			case 3 :	D[reg] = (D[reg] & 0xff00ffff) | (temp * 0x10000);
						break;
			case 2 :	D[reg] = (D[reg] & 0xffff00ff) | (temp * 0x100);
						break;
			case 1 : D[reg] = (D[reg] & 0xffffff00) | (temp);
						break;
			}
		}
	address += 2;
	}

inc_cyc ( (size == LONG) ? 24 : 16);

return SUCCESS;

}



int	MOVEA()
{
long	size;
int	src;

if (inst & 0x1000)
	size = WORD;
else
	size = LONG;

src = eff_addr_code(inst,0);
if (size == WORD)
	inc_cyc (move_bw_times[src][2]);
else
	inc_cyc (move_l_times[src][2]);

if (eff_addr(size, ALL_ADDR, FALSE))
	return (BAD_INST);

if (size == WORD) 
	sign_extend ((int)EV1, (long) WORD, &EV1);

A[a_reg((inst >> 9) & 0x07)] = EV1;

return SUCCESS;

}



int	MOVE_FR_SR()
{

if (eff_addr ((long) WORD, DATA_ALT_ADDR, TRUE))
	return (BAD_INST);

put (EA1, (long) SR, (long) WORD);

inc_cyc ((inst & 0x0030) ? 8 : 6);

return SUCCESS;

}



int	MOVE_TO_CCR()
{

if (eff_addr ((long) WORD, DATA_ADDR, TRUE))
	return (BAD_INST);

put (&SR, EV1, (long) BYTE);

inc_cyc (12);

return SUCCESS;

}



int	MOVE_TO_SR()
{

if (! (SR & sbit))
	return (NO_PRIVILEGE);

if (eff_addr ((long) WORD, DATA_ADDR, TRUE))
	return (BAD_INST);

put (&SR, EV1, (long) WORD);

inc_cyc (12);

return SUCCESS;

}



int	MOVEM()
{
int	direction, addr_modes_mask, counter, addr_mode;
int	displacement, address, total_displacement;
long	size, mask_list, temp;

mem_request (&PC, (long) WORD, &mask_list);

if (inst & 0x0040)
	size = LONG;
else
	size = WORD;

if (direction = (inst & 0x0400))
	addr_modes_mask = CONTROL_ADDR | bit_4;
else
	addr_modes_mask = CONT_ALT_ADDR | bit_5;

if (eff_addr (size, addr_modes_mask, FALSE))
	return (BAD_INST);			/* bad effective address */

address = (long) ( (long)EA1 - (long)&memory[0]);
total_displacement = address;

if ((inst & 0x0038) != 0x20)
	{
	if (size == WORD)
		displacement = 2;
	else
		displacement = 4;
	}
else
	{
	if (size == WORD)
		displacement = -2;
	else
		displacement = -4;
	}

addr_mode = eff_addr_code (inst,0);

if (direction)
	inc_cyc (movem_t_r_times[addr_mode]);		/* memory to registers */
else
	inc_cyc (mover_t_m_times[addr_mode]);		/* registers to memory */

for (counter = 0; counter < 16; counter++)
	if (mask_list & (1 << counter))
		{
		if (size == LONG)
			inc_cyc (8);
		else
			inc_cyc (4);
		if (direction)
			{
			if (size == WORD)		/* if size is WORD then sign-extend */
				{
				mem_req (address, (long) WORD, &temp);
				sign_extend ((int) temp, LONG, &temp);
				}
			if (counter < 8)
				D[counter] = temp;
			else
				A[a_reg(counter - 8)] = temp;
			}
		else
			{
			if ((inst & 0x38) == 0x20)
				{
				if (counter < 8)
					mem_put (A[a_reg(7 - counter)], address, size);
				else
					mem_put (D[15 - counter], address, size);
				}
			else
				{
				if (counter < 8)
					mem_put (D[counter], address, size);
				else
					mem_put (A[a_reg(counter - 8)], address, size);
				}
			}
		address += displacement;
		}
address -= displacement;
total_displacement = address - total_displacement;

/* if pre-decrement or post-increment modes then change the value */
/* of the address register appropriately */
if ( ((inst & 0x38) == 0x20) || ( (inst & 0x38) == 0x18) )
	A[a_reg(inst & 0x7)] += total_displacement;

return SUCCESS;

}



int	MOVE_USP()
{
int	reg;

if (!(SR & sbit))
	return (NO_PRIVILEGE);		/* supervisor state not on */

reg = inst & 0x7;
if (reg == 7)
	reg = 8;

if (inst & 0x8)
	A[reg] = A[7];
else
	A[7] = A[reg];

inc_cyc (4);

return SUCCESS;

}



int	MOVEQ()
{
int	reg;

reg = (inst >> 9) & 0x7;
source = inst & 0xff;
dest = D[reg];

/* the data register is sign extended to a longword */
sign_extend ((int)source, (long) BYTE, &D[reg]);
sign_extend ((int)D[reg], (long) WORD, &D[reg]);

cc_update (N_A, GEN, GEN, ZER, ZER, source, dest, D[reg], LONG, 0);
inc_cyc (4);
return SUCCESS;

}

