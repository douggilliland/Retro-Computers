/*
 *  exit.c  (libc)
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdlib.h>
#include <stddef.h>

#define ATX_MAX 32

static void (*exit_func[ATX_MAX])(void);
static int index;

/*-------------------------------- exit() -----------------------------------*/

/*
 * exit causes normal program termination.  When exit() is called, all
 * functions registered by atexit() are called in the reverse order of
 * registration.  After all registered functions are called, _exit() is
 * passed the status word.  _exit() then closes all open files.	 Note,
 * exit() does not return to the caller.
 */

void exit(int status)
{
    while( index > 0 )
	exit_func[--index]();
    _exit(status);		    /* _exit() does not return */
}

/*--------------------------------- atexit() --------------------------------*/

/*
 * atexit registers functions to be called when the program terminates]
 * normally.  The function to be called at program termination is the
 * argument to atexit().  atexit() returns zero unless the registration
 * failed because there was no more room in which case a non-zero value is
 * returned.  If more than one function is registered, the functions are
 * executed in the reverse order that they were registered.  
 */

int atexit(void (*func)(void))
{
    if( index >= ATX_MAX )
	return(1);
    exit_func[index++] = func;
    return(0);
}
