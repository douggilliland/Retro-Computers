/**
 * @file   sprintf.h
 * @brief  Library for sprintf() function.
 * @author Miguel I. Garcia Lopez / FloppySoftware
 *
 * Implementation of sprintf() function, for MESCC (Mike's Enhanced
 * Small C Compiler for Z80 & CP/M).
 *
 * Revisions:
 *  - 20 Oct 2000 : Last revision.
 *  - 16 Apr 2007 : GPL'd.
 *  - 14 Apr 2015 : Ammended a bad closed comment.
 *  - 25 Aug 2016 : Documented. GPL v3.
 *
 * Copyright (c) 1999-2016 Miguel I. Garcia Lopez / FloppySoftware.
 *
 * Licensed under the GNU General Public License v3.
 *
 * http://www.floppysoftware.es
 * floppysoftware@gmail.com
 */
#ifndef SPRINTF_H

#define SPRINTF_H

// Dependencies
// ------------

#ifndef XPRINTF_H
	#include <xprintf.h>
#endif

/**
 * @fn     int sprintf(char *dst, char *fmt, arg1, arg2, ...)
 * @brief  Formatted output to memory.
 *
 * See the documentation for xprintf.h to learn about the string format.
 *
 * @param  dst - destination
 * @param  fmt - string format
 * @param  arg1 - argument #1
 * @param  arg? - argument #?
 * @return number or characters written, or -1 on failure (currently always #).
 */
#asm

sprintf:
	ADD	HL,HL
	ADD	HL,SP	;HL=Adr. fmt

	LD	DE,xspfout
	PUSH	DE
	LD	DE,xspfend
	PUSH	DE
	PUSH	HL

	INC	HL
	INC	HL	;HL=Adr. dst
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	LD	(xspfout+2),HL

	CALL	xprintf

	POP	BC
	POP	BC
	POP	BC

	RET
#endasm

// int xspfout(char ch) : output ch to memory; return 0 on success, !=0 on failure (currently always returns 0).

#asm

xspfout:
	LD	A,L
	LD	HL,0	;Adr.
	LD	(HL),A

	INC	HL
	LD	(xspfout+2),HL

	LD	HL,0

	RET
#endasm

// void xspfend(void) : end formatted output; writes a trailing zero byte.

#asm

xspfend:
	LD	HL,(xspfout+2)
	LD	(HL),0
	RET

#endasm

#endif

