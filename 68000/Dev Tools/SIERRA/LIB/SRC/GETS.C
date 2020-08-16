/*
 *  gets.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdio.h>

/*--------------------------------- gets() ----------------------------------*/

/*
 * gets reads characters from the input stream pointed to by stdin, into an
 * array pointed to by string, until an end-of-file is encountered or a
 * new-line is read.  Any new-line character is discarded, and a null
 * character is written immediately after the last chracter read into the
 * array.  gets() returns string if successful.	 If end-of-file is
 * encountered and no characters have been read into the array, the contents
 * of the array remain unchanged and a null pointer is returned.  If a read
 * error occurs during the operation, the array contents contentents are
 * indeterminate and a null pointer is returned.
 */

char *gets(char *string)
{
    register char *ptr;
    register int c;

    ptr = string;
    while( ((c = getchar()) != EOF) && (c != '\n') )
	*ptr++ = c;

    if( ((c == EOF) && (ptr == string)) || ferror(stdin) )
	return(NULL);

    *ptr = '\0';
    return(string);
}
