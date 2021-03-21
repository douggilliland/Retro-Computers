/**
 * @file   fprintf.h
 * @brief  Library for fprintf() function.
 * @author Miguel I. Garcia Lopez / FloppySoftware
 *
 * Implementation of fprintf() function, for MESCC (Mike's Enhanced
 * Small C Compiler for Z80 & CP/M).
 *
 * Revisions:
 *  - 23 Jan 2001 : Last revision.
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
#ifndef FPRINTF_H

#define FPRINTF_H

// Dependencies
// ------------

#ifndef XPRINTF_H
	#include <xprintf.h>
#endif

#ifndef FILEIO_H
	#include <fileio.h>
#endif

/**
 * @fn     int fprintf(FILE *fp, char *fmt, arg1, arg2, ...)
 * @brief  Formatted output to a file.
 *
 * See the documentation for xprintf.h to learn about the string format.
 *
 * @param  fp - file pointer
 * @param  fmt - string format
 * @param  arg1 - argument #1
 * @param  arg? - argument #?
 * @return number or characters written, or -1 on failure.
 */
#asm

fprintf:
	ADD	HL,HL
	ADD	HL,SP	;HL=Adr. fmt

	LD	DE,xfpfout
	PUSH	DE
	LD	DE,xfpfend
	PUSH	DE
	PUSH	HL

	INC	HL
	INC	HL	;HL=Adr. *fp
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	LD	(xfpfout+2),HL

	CALL	xprintf

	POP	BC
	POP	BC
	POP	BC

	RET
#endasm

// int xfpfout(char ch) : output ch to a file; return 0 on success, !=0 on failure.

#asm

xfpfout:
	PUSH	HL	;Char.
	LD	HL,0	;*FP
	PUSH	HL

	CALL	fputc

	POP	BC
	POP	BC

	EX	DE,HL
	LD	HL,0

	LD	A,255
	CP	D
	RET	NZ
	CP	E
	RET	NZ

	INC	L
	RET
#endasm

// void xfpfend(void) : end formatted output; currently does nothing.

#asm

xfpfend:
	RET

#endasm

#endif

