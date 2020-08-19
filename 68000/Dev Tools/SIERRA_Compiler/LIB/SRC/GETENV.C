/*
 *  getenv.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdlib.h>

/*-------------------------------- getenv() ---------------------------------*/

/*
 * getenv searches an environment list, provided by the host environment,
 * for a string that matches the string pointed to by name.  The set of
 * environment names and the method for altering the environment list are
 * implementation defined.  getenv() returns a pointer to a string
 * associated with the matched list member.  The string pointed to must
 * not be modified by the program.  If the specified name cannot be found,
 * a null pointer is returned.
 *
 * The getenv() routine defined below assumes that the environment variables
 * are defined in _env an array of pointers to character strings.  The
 * library file env.c compiled and included in the libc library file
 * contains an empty _env array that can be modified to be non-empty.  The
 * _env array can also be defined and linked into the user's program.
 *
 * The format of the strings in _env[] is
 *
 * <variable>=<value>
 * 
 * where spaces are not allowed before or after the equal sign '='.
 */

static char *envcmp(const char *, char *);

extern char * const _env[];

/*------------------------------- getenv() ----------------------------------*/

char *getenv(const char *name)
{
    char * const *env_str;
    char *rtrn_val;

    for( env_str = _env; *env_str; env_str++ ) {
	if( rtrn_val = envcmp(name, (char *)*env_str) )
	    return(rtrn_val);
    }
    return(NULL);
}

/*------------------------------- envcmp() ----------------------------------*/

static char *envcmp(const char *name, char *env_str)
{
    while( (*name == *env_str) && *name ) {
	name++;
	env_str++;
    }

    if( (*name == '\0') && (*env_str == '=') )
	return(++env_str);
    else
	return(NULL);
}
