/**
 * @file   xprintf.h
 * @brief  Support library for formatted output.
 * @author Miguel I. Garcia Lopez / FloppySoftware
 *
 * Support library for formatted output,
 * for MESCC (Mike's Enhanced Small C Compiler for Z80 & CP/M).
 *
 * All functions with formatted output like printf(), fprintf()
 * and sprintf() call some private functions in this order:
 *  - pf_sf()
 *  - pf_s()
 *  - pf_out()
 *
 * Revisions:
 *  - 19 Mar 2001 : Last revision.
 *  - 16 Apr 2007 : GPL'd.
 *  - 09 Dec 2016 : Documented. Optimized. GPL v3.
 *  - 02 Aug 2017 : Output '%%' as '%'.
 *
 * Copyright (c) 1999-2016 Miguel I. Garcia Lopez / FloppySoftware.
 *
 * Licensed under the GNU General Public License v3.
 *
 * http://www.floppysoftware.es
 * floppysoftware@gmail.com
 */
#ifndef XPRINTF_H

#define XPRINTF_H

// Dependencies
// ------------

#ifndef STRING_H
	#include <string.h>
#endif

// Private globals
// ---------------

BYTE xpf_err;         // True on error

extern WORD xpf_out;  // Output function
extern WORD xpf_end;  // End function

int xpf_fw;           // Field width
BYTE xpf_fa;          // Field alignment: 0=left, 1=right
BYTE xpf_fz;          // True on zero filling

int xpf_cnt;          // # of characters sent

/**
 * @fn     int xprintf(WORD funout, WORD funend, WORD adrpars)
 * @brief  Formatted output.
 *
 * This function performs formatted output. It is used
 * by printf(), fprintf() and sprintf() functions.
 *
 * The format is indicated in the string as follows:
 *
 * %[-][0][w]t
 *
 * | - : Left align (default: right align).
 * | 0 : Zero filling on right align.
 * | w : Width for alignment. If the specified width
 * |     is lower than the argument length, output is
 * |     done without aligment. Care with sprinf()!
 * | t : d = Signed decimal integer.
 * |     u = Unsigned decimal integer.
 * |     x = Hexadecimal integer.
 * |     s = String.
 * |     c = Character.
 *
 * The pair %% outputs a single %.
 *
 * @param  funout - function to output a character
 * @param  funend - function to end output
 * @param  adrpars - arguments addresses
 * @return # of characters sent on sucess, -1 on failure
 */
xprintf(funout, funend, adrpars)
WORD funout, funend;
WORD *adrpars;
{
	WORD *parg;	// Pointer to arguments
	char *pfor;	// Pointer to formatted string
	int ivalue;
	char ch;

	// Setup
	xpf_out = funout;
	xpf_end = funend;

	pfor = *adrpars;
	parg = --adrpars;

	xpf_err = xpf_cnt = 0;

	// Loop
	while((ch = *pfor++))
	{
		if(ch == '%')
		{
			// Character %
			if(*pfor == '%')
			{
				pf_out(ch);
				++pfor;

				continue;
			}

			// Align
			if(*pfor == '-')
			{
				xpf_fa = 0;  // Left align
				++pfor;
			}
			else
				xpf_fa = 1;  // Right align

			// Zero filling
			if(*pfor == '0')
			{
				xpf_fz = 1;  // Zero filling
				++pfor;
			}
			else
				xpf_fz = 0;

			// Width
			xpf_fw = 0;

			while(*pfor >= '0' && *pfor <= '9')
				xpf_fw = xpf_fw * 10 + (*pfor++) - '0';

			// Type
			switch(ch = *pfor++)
			{
				case 'd'  :
					ivalue = *parg--;
					pf_dec(ivalue);
					break;
				case 'u'  :
					ivalue = *parg--;
					pf_udec(ivalue);
					break;
				case 'x'  :
					ivalue = *parg--;
					pf_hex(ivalue);
					break;
				case 'c'  :
					pf_cf(*parg--);
					break;
				case 's'  :
					pf_sf(*parg--);
					break;
				case '\0' :
					--pfor;
					// P'abajo
				default   :
					pf_out('!');
					break;
			}
		}
		else
			pf_out(ch);

		if(xpf_err)
			break;
	}

	pf_end();

	return xpf_err ? -1 : xpf_cnt;
}

// void pf_sf(char *s) : output formatted string.

pf_sf(s)
char *s;
{
	int len;
	char fill;

	if(xpf_fw)
	{
		if((len = strlen(s)) < xpf_fw)
		{
			xpf_fw = xpf_fw-len;

			if(xpf_fa)
			{
				// Left align
				fill = (xpf_fz ? '0' : ' ');

				while(xpf_fw--)
					pf_out(fill);
				pf_s(s);
			}
			else
			{
				// Right align
				pf_s(s);

				while(xpf_fw--)
					pf_out(' ');
			}

			return;
		}
	}

	pf_s(s);
}

// void pf_cf(char c) : output formatted character.

pf_cf(c)
char c;
{
	char tmp[2];

	tmp[0] = c; tmp[1] = '\0';

	pf_sf(tmp);
}

unsigned char xpf_dst[7];  // Buffer for numbers
unsigned char *xpf_dpt;    // Buffer pointer

// void pf_dec(int i) : output signed decimal integer.

pf_dec(i)
int i;
{
	xpf_dpt = xpf_dst;

	if(i < 0)
	{
		*xpf_dpt++ = '-'; i = -i;
	}

	pf_dec2(i);

	*xpf_dpt = '\0';

	pf_sf(xpf_dst);
}

// void pf_dec2(int i) : helper for pf_dec().

pf_dec2(i)
int i;
{
	int n;

	if(n = i / 10)
		pf_dec2(n);

	*xpf_dpt++ = i % 10 + '0';
}

// void pf_udec(unsigned int i) : output unsigned decimal integer.

pf_udec(i)
unsigned i;
{
	xpf_dpt = xpf_dst;

	pf_udec2(i);

	*xpf_dpt = '\0';

	pf_sf(xpf_dst);
}

// void pf_udec2(unsigned int i) : helper for pf_udec().

pf_udec2(i)
unsigned i;
{
	unsigned n;

	if(n = i / 10)
		pf_udec2(n);

	*xpf_dpt++ = i % 10 + '0';
}

// void pf_hex(unsigned int i) : output hexadecimal integer.

pf_hex(i)
unsigned i;
{
	xpf_dpt = xpf_dst;

	pf_hex2(i);

	*xpf_dpt = '\0';

	pf_sf(xpf_dst);
}

// void pf_hex2(unsigned int i) : helper for pf_hex().

pf_hex2(i)
unsigned i;
{
	unsigned n;

	if(n = i / 16)
		pf_hex2(n);

	i %= 16;

	*xpf_dpt++ = i < 10 ? '0' + i : 'A' + i - 10;
}

// void pf_s(char *s) : output string.

pf_s(s)
char *s;
{
	while(*s)
		pf_out(*s++);
}

// void pf_out(char c) : output character.

#asm
pf_out:
	PUSH	HL
	DEFB	0CDH
xpf_out:
	DEFW	0
	POP	BC

	EX	DE,HL

	LD	HL,(xpf_cnt)
	INC	HL
	LD	(xpf_cnt),HL

	LD	A,D
	OR	E
	RET	Z
;;	LD	A,255
	LD	(xpf_err),A
	RET
#endasm

// void pf_end(void) : end output.

#asm
pf_end:
	DEFB	0C3H
xpf_end:
	DEFW	0
#endasm

#endif

