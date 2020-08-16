/*
 *  env.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 *
 *  The _env array is a dummy array referenced by the getenv() routine.
 *  Meaningful environment variables can be included in the following _env
 *  array of pointers to character strings, or an _env array can be linked
 *  into the user's application.
 */

#include <stddef.h>

char * const _env[] = {
/*
    "SIERRA=C:\\SIERRA",	    for example
    "TMP68=E:\\",					for example
*/
	NULL
};
