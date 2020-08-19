/*
 *  system.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdlib.h>
#include <stddef.h>

/*-------------------------------- system() ---------------------------------*/

/*
 * system passes a string to a command processor in a hosted environment.
 * There is currently no command processor provided with the Sierra Systems
 * library.  The ANSI proposed standard specifies that in this case, when
 * passed a NULL argument, system() return 0.
 */

int system(const char *string)
{
    if( string == NULL )
	return(0);
    else
	return(-1);
}
