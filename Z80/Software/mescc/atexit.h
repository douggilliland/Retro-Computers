/**
 * @file   atexit.h
 * @brief  Library for the atexit() function.
 * @author Miguel I. Garcia Lopez / FloppySoftware
 *
 * Support library for the atexit() function, for MESCC (Mike's Enhanced
 * Small C Compiler for Z80 & CP/M).
 *
 * Revisions:
 *  - 30 Nov 2015 : First version.
 *  - 02 Dec 2016 : Prefix private names with '_' as supported in ZSM v3.1.
 *  - 07 Dec 2016 : GPL v3.
 *
 * Copyright (c) 2015-2016 Miguel I. Garcia Lopez / FloppySoftware.
 *
 * Licensed under the GNU General Public License v3.
 *
 * http://www.floppysoftware.es
 * floppysoftware@gmail.com
 */
#ifndef ATEXIT_H

#define ATEXIT_H

#define ATEXIT_MAX 3          // Max. # of allowed functions

int _atexit_now;              // Counter for # of stored functions
WORD _atexit_arr[ATEXIT_MAX]; // Array for stored functions

/**
 * @fn     int atexit(void (*func)(void))
 * @brief  Register function to be called when the program terminates normally.
 *
 * This function registers a function to be called when the program
 * terminates normally (either with exit(), or an implicit or
 * explicit return in the main() function.
 *
 * The registered functions will be called in reverse order (last
 * registered function first).
 *
 * @param  func - function to call
 * @return 0 on sucess, other values on failure
 */
int atexit(func)
WORD func;
{
	// Patch exit()

#asm
	LD A,0CDH
	LD (exit),A
	LD HL,_exit_patch
	LD (exit + 1),HL
#endasm

	if(_atexit_now < ATEXIT_MAX) {
		_atexit_arr[_atexit_now++] = func; return 0;
	}

	return -1;
}

// void _exit_patch(void) : call registered functions in reverse order.

_exit_patch()
{
	while(_atexit_now)
		_atexit_arr[--_atexit_now]();
}

// Cleaning

#undef ATEXIT_MAX

#endif

