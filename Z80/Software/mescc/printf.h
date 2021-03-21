/**
 * @file   printf.h
 * @brief  Library for printf() function.
 * @author Miguel I. Garcia Lopez / FloppySoftware
 *
 * Implementation of printf() function, for MESCC (Mike's Enhanced
 * Small C Compiler for Z80 & CP/M).
 *
 * Revisions:
 *  - 20 Oct 2000 : Last revision.
 *  - 16 Apr 2007 : GPL'd.
 *  - 25 Aug 2016 : Documented. GPL v3.
 *
 * Copyright (c) 1999-2016 Miguel I. Garcia Lopez / FloppySoftware.
 *
 * Licensed under the GNU General Public License v3.
 *
 * http://www.floppysoftware.es
 * floppysoftware@gmail.com
 */
#ifndef PRINTF_H

#define PRINTF_H

// Dependencies
// ------------

#ifndef XPRINTF_H
	#include <xprintf.h>
#endif

#ifndef CONIO_H
	#include <conio.h>
#endif

/**
 * @fn     int printf(char *fmt, arg1, arg2, ...)
 * @brief  Formatted output to stdout (or console).
 *
 * See the documentation for xprintf.h to learn about the string format.
 *
 * @param  fmt - string format
 * @param  arg1 - argument #1
 * @param  arg? - argument #?
 * @return number or characters written, or -1 on failure (currently always #).
 */
#asm

printf:
	ADD	HL,HL
	ADD	HL,SP
	INC	HL
	INC	HL	;HL=Adr. fmt

	LD	DE,xpfout
	PUSH	DE
	LD	DE,xpfend
	PUSH	DE
	PUSH	HL

	CALL	xprintf

	POP	BC
	POP	BC
	POP	BC

	RET
#endasm

// int xpfout(char ch) : output ch to stdout; return 0 on success, !=0 on failure (currently always returns 0).

#asm

xpfout:
	PUSH	HL
	CALL	putchar
	POP	BC
	LD	HL,0
	RET

#endasm

// void xpfend(void) : end formatted output; currently does nothing.

#asm

xpfend:
	RET

#endasm

#endif

