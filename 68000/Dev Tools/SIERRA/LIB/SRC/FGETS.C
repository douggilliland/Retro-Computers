/*
 *  fgets.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdio.h>

/*--------------------------------- fgets() ---------------------------------*/

/*
 * fgets reads at most one less than the number of characters specified by
 * count from the stream pointed to by fp into the array pointed to by
 * string.  No additional characters are read after a new-line character
 * (which is retained) or after end-of-file.  A null character is written
 * immediately after the last character read into the array.
 *
 * Usage:
 *	fgets(char *string, int count, FILE *fp)
 *
 *	string -- pointer to array into which characters are to be read
 *	count --- maximum number of characters to read into array
 *	fp ------ pointer to the FILE structure associated with input stream
 *	return -- returns string if successful.	 If end-of-file is
 *		  encountered and and no characters have been read into the
 *		  array, the contents of the array remain unchanged and a
 *		  null pointer is returned.  If a read error occurs, the
 *		  array contents are indeterminite and a null pointer is
 *		  returned.
 */

char *fgets(char *string, int count, register FILE *fp)
{
    register char *ptr;
    register int c;

    c = 0;
    ptr = string;
    while( (--count > 0) && ((c = getc(fp)) != EOF) ) {
	*ptr++ = c;
	if( c == '\n' )
	    break;
    }

    if( ((c == EOF) && (ptr == string)) || ferror(fp) )
	return(NULL);

    *ptr = '\0';
    return(string);
}
