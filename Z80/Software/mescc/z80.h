/**
 * @file   z80.h
 * @brief  Z80 specific functions.
 * @author Miguel I. Garcia Lopez / FloppySoftware
 *
 * Functions for the Z80 cpu, for MESCC (Mike's Enhanced
 * Small C Compiler for Z80 & CP/M).
 *
 * Revisions:
 *  - 13 Dec 2014 : 1st version.
 *  - 15 Aug 2016 : Documented. GPL v3.
 *
 * Copyright (c) 2014-2016 Miguel I. Garcia Lopez / FloppySoftware.
 *
 * Licensed under the GNU General Public License v3.
 *
 * http://www.floppysoftware.es
 * floppysoftware@gmail.com
 */
#ifndef Z80_H

#define Z80_H

/**
 * @fn     int Z80in(int port)
 * @brief  Input a byte from a port.
 * @return byte value
 */
#asm

Z80in
	LD	C,L
	IN	A,(C)
	LD	H,0
	LD	L,A
	RET
	
#endasm

/**
 * @fn     void Z80out(int port, int value))
 * @brief  Output a byte to a port.
 */
#asm

Z80out
	POP  DE
	POP  HL
	POP  BC
	PUSH BC
	PUSH HL
	PUSH DE
	OUT  (C),L
	RET
	
#endasm

/**
 * @fn     void Z80di(void)
 * @brief  Disable interrupts.
 */
#asm

Z80di
	DI
	RET
	
#endasm

/**
 * @fn     void Z80ei(void)
 * @brief  Enable interrupts.
 */
#asm

Z80ei
	EI
	RET
	
#endasm

#endif

