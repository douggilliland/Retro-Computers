
/***************************** 68000 SIMULATOR ****************************

File Name: SIMOPS1.C
Version: 1.0

This file contains various routines for simulator operation

The routines are :  

	mdis(), selbp(), sbpoint(), cbpoint(), dbpoint(), memread(), 
	memwrite()

***************************************************************************/



#include <stdio.h>
#include "extern.h"



int mdis()                              /* display memory */
{
int	i, start, stop;
int	value;
char	mem_val;
char	*inp;

inp = gettext(2,"Location? ");
value = eval(inp);
if (errflg)
	{
	windowLine();
	printf("invalid location...");
	return FAILURE;
	}
start = value;

if (wcount < 3)			/* check no. of operands entered */
	{
	stop = 0;				/* only one operand was entered, */
								/* so only one loc. displayed */
	}
else
	{
	value = eval(wordptr[2]);	/* get second location */
	if(errflg)
		{
		windowLine();
		printf("invalid location...");
		return;
		}
	stop = value - 1;
	}

	for (;;)
		{
		windowLine();
		printf("%04x : ",WORD & start);
		for (i=0; i<8; i++)		/* display memory until */
			{			/* stop location is reached */
			mem_val = memread(start++, BYTE);
			printf(" %02x", mem_val & 0xff);
			if (start > stop)
				{
				windowLine();
				return SUCCESS;
				}
			if (!(start & 0x7)) break; 				/* stay on even boundaries */

			if (chk_buf() == 8)								/* "Halt" from keyboard */
				return SUCCESS;
			}
		}
}



int selbp()          /* break point set, clear or display routine */
{
	char *choice;

	choice = gettext(2,"Set Point, Clear Point, or Display Point ? ");
	if (same("sp",choice))
		sbpoint();
	else if (same("dp",choice))
		dbpoint();
	else if (same("cp",choice))
		cbpoint();
	else {
		cmderr();
		errflg = TRUE;
		return FAILURE;
		}

}



int sbpoint()                      /* set break point */
{
	int i, loc;
	char *inp;

	inp = gettext(3,"Location? ");		/* get input */
	loc = eval(inp);
	if (errflg) {
		windowLine();
		printf("invalid location...");
		return FAILURE;
		}

	/* set breakpoint in table and increment counter */

	for (i = 0; i<bpoints; i++)
		if(brkpt[i] == loc)
			return;
	brkpt[bpoints++] = loc;
	if (bpoints > 100)
		bpoints = 100;

}



int cbpoint()                   /* clear break point */
{
	int i, j, loc;
	char *inp;

	inp = gettext(3,"Location? ");		/* get input */
	loc = eval(inp);
	if (errflg)	{
		windowLine();
		printf("invalid location...");
		return FAILURE;
		}

	if (same("all",wordptr[2])) {
		bpoints = 0;
		return SUCCESS;
		}

	/* find break point specified */

	for (i = 0; i < bpoints; i++) if (brkpt[i] == loc) break;

	if (i == bpoints)	/* if not found, print message */
		{
		windowLine();
		printf("no break point at %04x",loc);
		return;
		}
	--bpoints;
	for (j = i; j < bpoints; j++) /* adjust breakpoint table and */
		brkpt[j] = brkpt[j + 1];	/* decrement counter */

}



int dbpoint()                         /* display break points */
{
	int i;

	windowLine();
	printf("breakpoints are set at the following locations:");
	windowLine();
	for (i = 0; i < bpoints; i++)
		printf("%2d)   %04x", i+1, WORD & brkpt[i]);
	return SUCCESS;

}



int memread(loc, MASK)                    /* read memory at given location */
int loc;            /* mask is used to prevent reading out of memory array */
{
	int value;

	/* handler for MC6850 PIA */
	if ((loc & 0xfffe) == 0x1000) 
		{
 		/* in folding of port1 */
		if ((loc & 0x0001) == 0)	/* status register */
			value = (port1[2] & 0x00ff);
		else
			{
			value = (port1[3] & 0x00ff);	/* recieve data */
			port1[2] &= 0xfe;
			port1[2] |= 0x80;
			}
		return(value);
		}
	value = memory[loc & ADDRMASK] & MASK;
	return value;

}



int memwrite(loc, value)          /* write given value into given location */
int loc;                 /* mask is used to prevent writing outside memory */
long value;														
{

	/* handler for MC6850 PIA                   THIS HANDLER IS COMMENTED OUT
	if ((loc & 0xfffe) == 0x1000)
		/* within port1 folding * /
		{
		p1dif = TRUE;
		if ((loc & 0x0001) == 0)	/* control register * /
			port1[0] = value;
		else
			/* transmit data * /
			{
			port1[1] = value;	/* load port * /
			port1[2] &= 0xfd;	/* adjust status register * /
			port1[2] |= 0x80;
			}
		return;
		}

	*/

		if ((value & 0xffff0000) != 0)
			{
			memory[loc & ADDRMASK] = (char) ((value >> 24) & BYTE);
			memory[(loc + 1) & ADDRMASK] = (char) ((value >> 16) & BYTE);
			memory[(loc + 2) & ADDRMASK] = (char) ((value >> 8) & BYTE);
			memory[(loc + 3) & ADDRMASK] = (char) (value & BYTE);
			}
		else
		if ((value & ~BYTE) != 0)
			{
			memory[loc & ADDRMASK] = (char) ((value & ~BYTE) >> 8);
			memory[(loc + 1) & ADDRMASK] = (char) (value & BYTE);
			}
		else
			memory[loc & ADDRMASK] = (char) value;
}


