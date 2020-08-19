/*
 *  abort.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdlib.h>
#include <signal.h>

/*---------------------------------- abort() ---------------------------------*/

/*
 * abort causes abnormal program termination to occur, unless the signal
 * SIGABRT is being caught and the signal handler does not return.
 * If the registered signal handler returns, _exit() is called with failure
 * status.
 */

void abort()
{
    raise(SIGABRT);
    _exit(EXIT_FAILURE);
}
