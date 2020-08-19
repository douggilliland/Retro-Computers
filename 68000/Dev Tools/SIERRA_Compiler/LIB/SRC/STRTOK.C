/*
 *  strtok.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stddef.h>

static char *next;

/*-------------------------------- strtok() ---------------------------------*/

/*
 * strtok is a string tokenizer function.  Successive calls to this function
 * return pointers to null terminated subsets of a string string, delimited
 * by characters from the string set.
 *
 * On the first call, string is a pointer to the string to be broken into
 * tokens.  This argument must be NULL on all subsequent calls while the
 * calling routine wants to continue drawing tokens from the string initially
 * passed.  Passing a non-NULL argument here will cause strtok() to start
 * culling tokens from the newly indicated string.  separator_list is a
 * string containing the delimiting characters for the tokens.	This string
 * may change between calls to strtok(), even while tokenizing the same
 * string.  On each successive call, strtok() returns a pointer to a null
 * terminated string representing the next token in the string initially
 * passed.  Note that strtok() actually writes the '\0' bytes into the string,
 * overwriting delimiting characters, so the calling function must not expect
 * the string to to remain intact.
 *
 * On the first call to strtok(), next, a static pointer, is assigned the
 * value of the first argument.	 At the end of each call, next will point to
 * the character following the last one scanned.  When strtok() is called, it
 * skips all characters in the string which are in the delimiter set.  If all
 * the characters in the string are in the delimiter set, the function
 * returns NULL.  Otherwise, strtok() returns a pointer to the first
 * non-delimiter character.  Before returning, strtok() writes a string
 * terminating null character on top of the next delimiter character in the
 * string, if any.  The effect of this is to return a string pointer to a
 * single token which was delimited by characters from the string set.
 */

char *strtok(char *string, const char *separator_list)
{
    register char *pstr;
    register const char *plist;
    char *start;

    if( string )	    /* first call to strtok() */
	next = string;
    else if( !next )	    /* invalid first call     */
	return(NULL);

    for( pstr = next; *pstr; pstr++ ) {
	for( plist = separator_list; (*pstr != *plist) && *plist; plist++ );

	if( *plist == '\0' ) {		    /* non-delimiter found */
	    start = pstr;
	    do {
		if( *++pstr == '\0' ) {	    /* end of token string */
		    next = pstr;
		    return(start);
		}
		for( plist = separator_list; *plist && (*pstr != *plist);
		plist++ );
	    } while( *plist == '\0' );	    /* while non-delimiter */
	    *pstr = '\0';
	    next = ++pstr;
	    return(start);
	}
    }
    return(NULL);
}
