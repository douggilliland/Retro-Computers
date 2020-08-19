
/***************************** 68000 SIMULATOR ****************************

File Name: SIMOPS2.C
Version: 1.0

This file contains various routines for simulator operation

The routines are :  

	alter(), hex_to_dec(), dec_to_hex(), intmod(), portmod(), pcmod(),
	changemem(), mmod(), regmod(), mfill(), clear()


***************************************************************************/



#include <stdio.h>
#include "extern.h"


#define	MODIFY_DATA		0
#define	MODIFY_MEMORY	1


int alter()
{
	char	*choice;

	choice = gettext(2,"D<num>, A<num>, PC, MEMory, or IOport ? ");
	if (same("io",choice)) portmod();
	else if (same("pc",choice)) pcmod();
	else if (same("mem",choice)) mmod();
	else if (same("int",choice)) intmod();
	else if (same("d",choice)) regmod(choice + 1, MODIFY_DATA);
	else if (same("a",choice)) regmod(choice + 1, MODIFY_MEMORY);
	else cmderr();
	return SUCCESS;

}



int hex_to_dec()
{
	char	*num_string;
	long	number;

	num_string = gettext(2,"Hex number ? ");
	if (sscanf (num_string,"%08lx", &number) != 1)
		errflg = TRUE;

	printf ("Decimal value = %ld", number);
	windowLine();
	return SUCCESS;

}


int dec_to_hex()
{
	char	*num_string;
	long	number;

	num_string = gettext(2,"Decimal number ? ");

	if (sscanf (num_string,"%ld", &number) != 1)
		errflg = TRUE;

	printf ("Hex value = %08lx", number);
	windowLine();
	return SUCCESS;

}




int intmod()
{
	long	count, newvalue;
	char	*inp;

	inp = gettext(3,"New Interrupt Mask? ");
	eval2(inp, &newvalue);
	if (errflg)
		errmess();
	else
		SR = (SR & ~intmsk) | ((newvalue & 0x7) << 8);
	return SUCCESS;

}



int portmod()
{

	printf("control       = %04x  ? ",port1[0]);
	port1[0] = (pchange(port1[0]) & BYTE);
	if (!same(".",wordptr[0]))
		{
		printf("transmit data = %04x  ? ",port1[1]);
		port1[1] = (pchange(port1[1]) & BYTE);
		if (!same(".",wordptr[0]))
			{
			printf("status        = %04x  ? ",port1[2]);
			port1[2] = (pchange(port1[2]) & BYTE);
			if (!same(".",wordptr[0]))
				{
				printf("receive data  = %04x  ? ",port1[3]);
				port1[3] = (pchange(port1[3]) & BYTE);
				}
			}
		}
	p1dif = TRUE;
	return SUCCESS;

}



int pcmod()
{
	long	count, newvalue;
	char	*inp;

	inp = gettext(3,"Location? ");
	eval2(inp, &newvalue);
	if (errflg)
		errmess();
	else
		PC = newvalue;
	return SUCCESS;

}



int changemem(oldval, result)          /* gets new value for memory modify */
long oldval, *result;
{				
	long	i, count;

	errflg = 0;
	if (gets(lbuf,80) == NULL) exit(0);
	scrollWindow();
	count = scan(lbuf,wordptr,1);  		/* scan 1 string of input */
	i = oldval;
	if ((count > 0) && (!same(".",wordptr[0])))
		{
		eval2(wordptr[0], &i); 	/* get input */
		if (errflg)
			i = oldval;
		}
	*result = i;
	return -1;

}




int mmod()                               /* modify memory */
{
int	aloc;
long	value, newval;

aloc = getval(3,"Location? ");          /* get location to start modifying */
while (!same(".",wordptr[0]))      /* modify memory until a "." is entered */
	{
	value = memread(aloc, BYTE);            /* prompt location and contents */
	printf("<%04x> = %02x   ? ", WORD & aloc, value);
	changemem(value, &newval);
	memwrite(aloc, newval);
	if (errflg)
		errmess();
	else
		{
		++aloc;
		if ((newval & ~BYTE) != 0)
			{
			if ((newval & 0xffff0000) != 0)
				aloc += 3;
			else
				++aloc;
			}
		}
	}
windowLine();

}


int regmod (regpntr, data_or_mem)            /* modify processor registers */
char	*regpntr;
int	data_or_mem;
{
	long	regnum, i, value;

	errflg = FALSE;
	/* pick up register number */
	if (sscanf(regpntr,"%d",&regnum) != 1)	{
		cmderr();
		errflg = TRUE;
		return;
		}

	if (wcount >= 3) {
		if (!same(".",wordptr[2]))
			/* value is on line and modify only one register */
			{
			eval2(wordptr[2], &value);
			if (errflg) 
				errmess();	
			else
				if (data_or_mem == MODIFY_DATA)
					D[regnum] = value;
				else	
					A[regnum] = value;
			}
		}
	else
		/* prompt user for each value and */
		/* modify all following registers */
		for (i=regnum;i<=7;i++)
			{
			if (data_or_mem == MODIFY_DATA)    /* we're entering D regs */
				{
				printf("<D%01d> = %lx ? ", i, D[i]);
				D[i] = changemem(D[i]);
				}
			else
				{
				printf("<A%01d> = %lx ? ", i, A[i]);
				A[i] = changemem(A[i]);
				}

			/* if error allow retry */
			if (errflg)
				{
				errmess();
				i--;
				}
			else
				if (same(".",wordptr[0]))
					break;
			}
	return (0);
}



int mfill()                  /* load memory with contents of s_record file */
{
	FILE 	*fp;
	int 	checksum, line, loc, end__of__file;
	char 	byte, s_type, nambuf[40], *name;
	char 	*mkfname(), *gettext(), *bufptr, *bufend;

	name = gettext(2,"Filename? ");

	fp = fopen(name, "r");
	if (fp == NULL)
		{                         /* if file cannot be opened, print message */
		printf("error:  cannot open file %s", name);
		windowLine();
		return FAILURE;
		}

	line = 0;
	errflg = FALSE;
	end__of__file = FALSE;
	s_type = 0;

	fgets(lbuf, 80, fp);
	sscanf (lbuf,"S%c",&s_type);
	if (s_type != '0')                     /* if first record is not a 'S0' */
		errflg = TRUE;                  /* record then incorrect file format */
	line++;
	if (~errflg)
		while (fgets(lbuf, 80, fp) != NULL)           /* read file until end */
		{
		bufptr = lbuf;
		for (bufend = bufptr; *bufend != '\0'; bufend++);
		line++;
		sscanf (lbuf, "S%c%2x", &s_type, &checksum);
		bufptr += 4;
		switch (s_type)
			{
			case '1' : if (sscanf(bufptr,"%04x", &loc) != 1)
					errflg = TRUE;
				   else bufptr += 4;
				   break;
			case '2' : if (sscanf(bufptr,"%02x", &loc) != 1)
					errflg = TRUE;
				   else bufptr += 2;
				   break;
			case '3' : if (sscanf(bufptr,"%08x", &loc) != 1)
					errflg = TRUE;
				   else bufptr += 8;
				   break;
			case '9' : end__of__file = TRUE;
				   break;
			default :  errflg = TRUE;
			}
		if (end__of__file) break;
		if (errflg) break;
		while (sscanf(bufptr,"%02x",&byte))
			{
			bufptr += 2;
			for (bufend = bufptr; *bufend != '\0'; bufend++);
			if ((bufptr + 2) >= bufend) break;
			if ((loc < 0) || (loc > (MEMSIZE - 1)))
				{
				printf("\nInvalid Address on line %d...",line);
				windowLine();
				errflg = TRUE;
				break;
				}
			else
				memory[loc++] = byte;
			}
		if (errflg) break;
		}

	if (errflg)                     /* if error reading file, print message */
		{
		windowLine();
		printf("Invalid data on line %d of file...",line);
		windowLine();
		printf ("%d: %s", line, line, lbuf);
		windowLine();
	 	printf("Remainder of load aborted...");
		windowLine();
		}
	fclose(fp);			/* close file specified */
	return SUCCESS;

}



int clear()                   /* clear memory, registers, port, and cycles */
{
	char	*resp, *gettext();
	int	all, validr, flag, i;
	long	loop_counter;

	flag = 0;
	validr = FALSE;
	all = FALSE;
	resp = gettext(2,"clear MEM, REG, PORT, INT, CYcles, or ALL ? ");

	if (same("all",resp)) {
		validr = TRUE;
		all = TRUE;
		}

	if ((same("reg",resp)) || all)
		/* clear registers */
		{
		flag = 1;
		for(i=0; i<=7; i++) 
			{
			A[i] = 0;
			D[i] = 0;
			}
		validr = TRUE;
		}

	if ((same("mem",resp)) || all)
		/* if user wants to clear all clear mem */
		{
		for (loop_counter = 0; loop_counter < MEMSIZE; loop_counter++)
			memory[loop_counter] = 0;
	 	bpoints = 0;
		validr = TRUE;
		}

	if ((same("port",resp)) || all)
		{
		p1dif = TRUE;
		flag = 1;
		port1[0] = 0;
		port1[1] = 0;
		port1[2] = 0x82;
		port1[3] = 0;
		validr = TRUE;
		}

	if ((same("int",resp)) || all)
		{
		port1[0] &= 0x1f;
		port1[2] |= 0x80;
		validr = TRUE;
		}

	if ((same("cy",resp)) || all)
		{
		flag = 1;
		cycles = 00L;
		validr = TRUE;
		}

	if (!validr)
		errmess();

	return flag;

}


