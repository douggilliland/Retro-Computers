/*	c_string.c

	Mike's Enhanced Small C Compiler for Z80 & CP/M

	String handling module.

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

	20 Oct 2016 : Documented and slightly optimized. Added int2str_5().
*/

// Private globals for this module

char cc_str[7]; // -12345 + ZERO

// Output int as signed decimal number

int2str(n)
int n;
{
#ifdef C_USEPRINTF
	sprintf(cc_str, "%d", n);

	return cc_str;
#else
	char *p;
	int sign;

	if(n >= 0)
	{
		sign = 0;
	}
	else if(n != -32768)
	{
		sign = 1;
		n = -n;
	}
	else
	{
		return strcpy(cc_str, "-32768");
	}

	*(p = cc_str + 6) = '\0';

	do
	{
		*(--p) = '0' + n % 10;
	} while((n /= 10));

	if(sign)
	{
		*(--p) = '-';
	}

	return p;
#endif
}

// Output int as signed decimal number, 5 digits, padded with spaces.

int2str_5(n)
int n;
{
#ifdef C_USEPRINTF
	sprintf(cc_str, "%5d", n);

	return cc_str;
#else
	char *p;
	int i, k;

	k = 5 - strlen((p = int2str(n)));

	for(i = 0; i < k; ++i)
	{
		cc_str[i] = ' ';
	}

	strcpy(cc_str + i, p);

	return cc_str;
#endif
}

