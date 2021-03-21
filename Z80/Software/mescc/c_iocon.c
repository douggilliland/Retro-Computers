/*	c_iocon.c

	Mike's Enhanced Small C Compiler for Z80 & CP/M

	I/O console module.

	Copyright (c) 1999-2016 Miguel I. Garcia Lopez, FloppySoftware.

	This program is free software; you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the
	Free Software Foundation; either version 2, or (at your option) any
	later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

	Revisions:

	16 Jan 2001 : Last revision.
	16 Apr 2007 : GPL'd.
	26 Oct 2015 : Cleaned.
	11 Oct 2016 : Documented and slightly optimized.
	21 Oct 2016 : Modified co_dec() an co_dec_5().
*/

// Print a character
// out: character value

co_ch(c)
char c;
{
	putchar(c); return c;
}

// Print a string
// out: string address

co_str(s)
char *s;
{

#if C_USEPRINTF
	printf("%s", s);
#else
	/********************
	char *p;

	p = s;

	while(*p)
		co_ch(*p++);
	*********************/
	putstr(s);
#endif

	return s;
}

// Print a string + '\n'
// out: string address

co_line(s)
char *s;
{
#if C_USEPRINTF
	printf("%s\n", s);
#else
	/***********************
	co_str(s); co_ch('\n');
	***********************/
	puts(s);
#endif

	return s;
}

// Print '\n'

co_nl()
{
	co_ch('\n');
}

// Print signed decimal number
// out: value

co_dec(n)
int n;
{
#ifdef C_USEPRINTF
	printf("%d", n);
#else
	/********************************************************************
	int i;

	if(n < 0)
	{
		// Possible $8000 can't be negatived
		// if((number^0xFFFF)==0x7FFF){outstr("0-32768");return;}

		co_ch('-');

		if(n == -32768)
		{
			co_str("32768"); return;
		}

		n = -n;
	}

	if(i = n / 10)
		co_dec(i);

	co_ch(n % 10 + '0');
	*********************************************************************/

	co_str(int2str(n));
#endif

	return n;
}

// Print signed decimal number

co_dec_5(n)
int n;
{
#ifdef C_USEPRINTF
	printf("%05d", n);
#else
	/********************************************************************
	if(n < 10000)
	{
		co_ch('0');
		
		if(n < 1000)
		{
			co_ch('0');
			
			if(n < 100)
			{
				co_ch('0');
				
				if(n < 10)
					co_ch('0');
			}
		}
	}

	co_dec(n);
	*********************************************************************/

	co_str(int2str_5(n));
#endif
}
