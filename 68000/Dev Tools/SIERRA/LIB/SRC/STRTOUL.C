/*
 *  strtoul.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdlib.h>
#include <ctype.h>
#include <errno.h>
#include <limits.h>

static const unsigned char shift_counts[37] = {
    0, 0, 1, 0, 2, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0
};

/*------------------------------- strtoul() ---------------------------------*

/*
 * strtoul() converts an ASCII character string into an unsigned long int
 * using a base between 2 and 36 (inclusively).	 strtoul accepts first an
 * optional sequence of whitespace characters (as defined by isspace()), an
 * optional '+' or '-' indicating the sign of the number followed by a
 * sequence of digits.	In the normal case, the function terminates at the
 * first unrecognized character.  If the conversion base is zero, the base is
 * determined by the form of the input string.	Base 16 if it begins with 0x
 * or 0X and base 8 if it begins with 0 not followed by an x or X.  If the
 * conversion base is non-zero, strtoul first checks that it lies between 2
 * and 36 (inclusively), and if not, returns 0.	 Otherwise, if the conversion
 * base is 16, a leading 0x or 0X in the digit string is ignored, and leading
 * zeroes are ignored for all bases.  If the conversion base is greater than
 * 10, alphabetic numerals are used in upper or lower case.  If the
 * conversion of the digit string would cause long integer overflow, strtoul()
 * returns ULONG_MAX and continues to scan the digit string, without further
 * conversion.	The end_ptr argument provides a means of recording the
 * position in the input string at which strtoul() stopped scanning characters.
 *
 * Usage:
 *
 *	unsigned long strtoul(const char *str, char **end_ptr, int base)
 *
 *	str ------ points to the string to be converted to a long
 *	end_ptr -- if non-null, points to a pointer at which the address of
 *		   the first character int str not recognized by strtoul() is
 *		   to be stored (if null, no action is taken)
 *	base ----- an integer between 2 and 36 (inclusively) to be used as
 *		   the conversion base, or 0 if the string is to be
 *		   interpreted automatically as hexadecimal, decimal or octal
 *	return --- the unsigned long integer resulting from the conversion.
 *		   If no conversion is possible, zero is returned.  ULONG_MAX
 *		   is returned and errno is set to ERANGE on overflow.
 */

unsigned long strtoul
(
register const char *str,
char **end_ptr,
register int base
)
{
    register unsigned long number;
    register long digit;
    register int c;
    register int shift;
    register int overflow;
    register unsigned long max_quot;
    long unsigned max_rem;
    int negative;

    negative = 0;
    overflow = 0;

    /* strip leading whitespace */

    while( isspace(*str) )
	str++;

    if( (*str == '-') || (*str == '+') )	
	negative = (*str++ == '-');

    if( (base < 2) || (base > 36) ) {
	if( base ) {
	    if( end_ptr )
		*end_ptr = (char *)str;
	    errno = EDOM;
	    return(0);
	}
    }

    /* accept and interpret leading 0x, 0X, or 0 */

    if( *str == '0' ) {
	if( (*++str == 'x') || (*str == 'X') ) {
	    if( base == 0 )
		base = 16;
	    if( base == 16 )
		++str;
	}
	else if( base == 0 )
	    base = 8;
    }
    if( base == 0 )
	base = 10;

    /* The character array shift_counts[], when indexed by a number    */
    /* between 0 and 36 (inclusively), gives the number of places to   */
    /* shift to achieve multiplication by that number if it is a power */
    /* of 2, else 0.  It is used to speed up conversions when the base */
    /* is a power of 2.						       */

    shift = shift_counts[base];

    /* max_quot is the largest number which when multiplied by base */
    /* will not cause overflow.	 max_rem is the least-significant   */
    /* digit of ULONG_MAX in the current base.			    */

    max_quot = ULONG_MAX / base;
    max_rem = ULONG_MAX % base;
    
    /* get a digit, break if not valid for this base, */
    /* add digit to number, check for overflow	      */

    for( number = 0, c = *str; ; c = *++str ) {
	if( isdigit(c) )
	    digit = c - '0';
	else if( islower(c) )
	    digit = (c - 'a') + 10;
	else if( isupper(c) )
	    digit = (c - 'A') + 10;
	else
	    break;

	if( digit >= base )
	    break;

	if( (number >= max_quot) && !overflow ) {
	    if( (number > max_quot) || (digit > max_rem) )
		overflow = 1;
	}

	if( shift )
	    number <<= shift;
	else if( base == 10 )
	    number = (number << 3) + number + number;
	else
	    number *= base;

	number += digit;
    }

    if( end_ptr )
	*end_ptr = (char *)str;

    if( overflow ) {
	errno = ERANGE;
	return(ULONG_MAX);
    }
    else
	return(negative ? -number : number);
}
