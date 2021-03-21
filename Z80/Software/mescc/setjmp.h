/**
 * @file   setjmp.h
 * @brief  Non-local jumps.
 * @author Miguel I. Garcia Lopez / FloppySoftware
 *
 * Non-local jumps functions, for MESCC (Mike's Enhanced
 * Small C Compiler for Z80 & CP/M).
 *
 * Only one jmp_buf is allowed.
 *
 * Call to setjmp is performed as - ie: setjmp(env):
 *   LD HL,(env)
 *   PUSH HL
 *   CALL setjmp
 *   POP BC
 *
 * Call to longjmp is performed as - ie: longjmp(env, 1):
 *
 *   LD HL,(env)
 *   PUSH HL
 *   LD HL,1
 *   PUSH HL
 *   CALL longjmp
 *   POP BC
 *   POP BC
 *
 * Defined macros:
 *  - jmp_buf
 *
 * Revisions:
 *  - 21 Ago 2015 : Initial version.
 *  - 22 Ago 2015 : Changed jmp_buf from char to int.
 *  - 15 Ago 2016 : Documented. GPL v3.
 *
 * Copyright (c) 2015-2016 Miguel I. Garcia Lopez / FloppySoftware.
 *
 * Licensed under the GNU General Public License v3.
 *
 * http://www.floppysoftware.es
 * floppysoftware@gmail.com
 */
#ifndef SETJMP_H

#define SETJMP_H

#define jmp_buf int   // Just something

WORD setjmp_rt;       // Return address
WORD setjmp_sp;       // SP

/**
 * @fn     int setjmp (jmp_buf env)
 * @brief  Save state information for later use of longjmp().
 * @param  env - buffer for state data
 * @return 0 from direct call, other values from a longjmp call
 */
#asm
setjmp
	POP  HL
	LD   (setjmp_rt), HL
	LD   (setjmp_sp), SP
	PUSH HL
	LD   HL, 0
	RET
#endasm

/**
 * @fn     void longjmp (jmp_buf env, int rv)
 * @brief  Resume execution after setjmp().
 *
 * This function resumes the execution after setjmp(), restoring
 * the previously stored state in env.
 *
 * @param  env - buffer with state data
 * @param  rv  - value to return; must be != 0
 * @return rv value
 */
#asm
longjmp
	POP  BC
	POP  HL
	LD   SP,(setjmp_sp)
	LD   DE,(setjmp_rt)
	PUSH DE
	RET
#endasm

#endif

