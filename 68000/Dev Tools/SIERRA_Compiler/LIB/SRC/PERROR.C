/*
 *  perror.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdio.h>
#include <string.h>
#include <errno.h>

/*-------------------------------- perror() ---------------------------------*/

/*
 * perror maps the error number in the integer expression errno to an error
 * message.  It writes a sequence of characters to the standard error stream
 * with first (if string is neither a null pointer nor a poiter to a null
 * string) the string pointed to by string, a colon ':', a space; then an
 * appropriate erron message string followed by a new-line character.  The
 * contents of the error message string are the same as those returned by
 * the strerror function with the argument errno.
 */

void perror(const char *string)
{
    if( string && *string ) {
	fputs(string, stderr);
	fputs(": ", stderr);
    str:
	fputs(strerror(errno), stderr);
	fputc('\n', stderr);
    }
    else
	goto str;
}
