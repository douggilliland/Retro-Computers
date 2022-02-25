
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

inp = getText(2,"Location? ");
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
		return FAILURE;
		}
	stop = value - 1;
	}

	for (;;)
		{
		windowLine();
		printf("%04x : ",WORD_MASK & start);
		for (i=0; i<8; i++)		/* display memory until */
			{			/* stop location is reached */
			mem_val = memread(start++, BYTE_MASK);
			printf(" %02x", mem_val & 0xff);
			if (start > stop)
				{
				windowLine();
				return SUCCESS;
				}
			if (!(start & 0x7)) break; 				/* stay on even boundaries */

//			if (chk_buf() == 8)								/* "Halt" from keyboard */
				return SUCCESS;
			}
		}
}


/*
int selbp()          // break point set, clear or display routine
{
	char *choice;

	choice = getText(2,"Set Point, Clear Point, or Display Point ? ");
	if (same("sp",choice))
		sbpoint();
	else if (same("dp",choice))
		dbpoint();
	else if (same("cp",choice))
		cbpoint();
	else {
		cmderr();
		errflg = true;
		return FAILURE;
		}
  return SUCCESS;
}
*/


int memread(int loc, int MASK)                    /* read memory at given location */
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



int memwrite(int loc, long value)          /* write given value into given location */
{

	/* handler for MC6850 PIA                   THIS HANDLER IS COMMENTED OUT
	if ((loc & 0xfffe) == 0x1000)
		/* within port1 folding * /
		{
		p1dif = true;
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
			memory[loc & ADDRMASK] = (char) ((value >> 24) & BYTE_MASK);
			memory[(loc + 1) & ADDRMASK] = (char) ((value >> 16) & BYTE_MASK);
			memory[(loc + 2) & ADDRMASK] = (char) ((value >> 8) & BYTE_MASK);
			memory[(loc + 3) & ADDRMASK] = (char) (value & BYTE_MASK);
			}
		else
		if ((value & ~BYTE_MASK) != 0)
			{
			memory[loc & ADDRMASK] = (char) ((value & ~BYTE_MASK) >> 8);
			memory[(loc + 1) & ADDRMASK] = (char) (value & BYTE_MASK);
			}
		else
			memory[loc & ADDRMASK] = (char) value;
  return 0;
}


