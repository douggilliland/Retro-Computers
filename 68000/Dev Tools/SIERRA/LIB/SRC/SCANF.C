/*
 *  scanf.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdio.h>
#include <stddef.h>
#include <string.h>
#include <ctype.h>
#include <stdarg.h>

#ifdef DP_FLOAT
#define FT_SINGLE   0
#define FT_DOUBLE   1
#define FT_EXTENDED 1
#else
#define FT_SINGLE   1	    /* defined in fp68881.h as _ft_single   */
#define FT_DOUBLE   5	    /* defined in fp68881.h as _ft_double   */
#define FT_EXTENDED 2	    /* defined in fp68881.h as _ft_extended */
#endif

#define CVBUFSIZE   256	    /* size of float character buffer	    */

/* The following are flag which are set on each conversion according to	 */
/* the conversion character and conversion modifiers.  Three are used in */
/* parsing the string passed to the floating point conversion routine	 */
/* (flaging the current parse position).				 */
/*									 */
/* DO NOT change the defines for the conversion characters without	 */
/* making corresponding modifications in the digit_tab[] array.		 */

#define d_CNV		0x1	    /* conversion characters		 */
#define i_CNV		0x2
#define u_CNV		0x4
#define o_CNV		0x8
#define p_CNV		0x10
#define x_CNV		0x20
#define s_CNV		0x40
#define c_CNV		0x80
#define n_CNV		0x100
#define FLOAT_CNV	0x200	    /* f, e, E, g or G conversion char	 */
#define BRACKET_CNV	0x400	    /* '[' conversion			 */
#define PCT_CNV		0x800	    /* '%' conversion (i.e. "%%" in fmt) */

#define SUPPRESS	0x1000	    /* assignment suppression flag bit	 */
#define h_MDFR		0x2000	    /* h (half) modifier ==> short int	 */
#define l_MDFR		0x4000	    /* ==> long int			 */

#define HAT_N_BRACK	0x8000	    /* ==> '[' was followed by a '^'	 */
#define NEGFLAG		0x10000	    /* '-' encountered in parsing an int */
#define L_ZERO		0x20000	    /* lading zero in parsing an int	 */
#define L_ZEROX		0x40000	    /* leading '0x' in parsing an int	 */
#define CONVERSION	0x80000	    /* a conversion occured in '['	 */

#define MANTISSA	0x100000    /* in or past mantissa of fp parse	 */
#define EXPONENT	0x200000    /* in the exponent of fp parse	 */
#define CHARACTERISTIC	0x400000    /* in the characteristic of fp parse */

#define INT_CNV		(d_CNV | i_CNV | u_CNV | o_CNV | p_CNV | x_CNV)

#define VALUE(c)	(digit_tab[c] & 0xf)
#define BIT(c)		(unsigned int)(digit_tab[c] >> 4)

#ifdef LIBMSMX
#ifdef FP_FLOAT

#define SCANF	    scanff
#define SSCANF	    sscanff
#define FSCANF	    fscanff

#else
#ifdef FF_FLOAT

#define SCANF	    scanfff
#define SSCANF	    sscanfff
#define FSCANF	    fscanfff

#else

#define SCANF	    scanf
#define SSCANF	    sscanf
#define FSCANF	    fscanf

#endif
#endif
#else

#define SCANF	    scanf
#define SSCANF	    sscanf
#define FSCANF	    fscanf

#endif

#ifdef FLOAT
#ifdef FP_FLOAT
void _fp_strflt(char *, void *, char*);
#else
#ifdef FF_FLOAT
void _ff_strflt(char *, void *, char*);
#else
#ifdef DP_FLOAT
void _dp_strflt(char *, void *, long, char*);
#else
void _f_strflt(char *, void *, long, char*);
#endif
#endif
#endif
#endif

static long _do_scan(FILE *, const char *, va_list);

/*
 * The lower 4 bits represent the numeric value of hex, decimal and octal
 * digits.  The upper four bits of the character table represent the position
 * of the flag bit corresponding to the conversion character indexed.  Thus,
 * for example, during a format string parse, when a conversion character is
 * expected, the digit_tab value for the character is examined.	 If the
 * character is 'x', the upper four bits are 0110 (or 0x6).  This indicates
 * that the flag bit for this conversion character is in the sixth position.
 * The flag variable is the most efficient way to store the conversion
 * information, and using the table is the smallest and quickest way to set
 * these flags.
 */

static const unsigned char digit_tab[128] =
{
   0,	0,   0,	  0,   0,   0,	 0,   0,   0,	0,   0,	  0,   0,   0,	 0,   0,
   0,	0,   0,	  0,   0,   0,	 0,   0,   0,	0,   0,	  0,   0,   0,	 0,   0,
   0,	0,   0,	  0,   0,0xc0,	 0,   0,   0,	0,   0,	  0,   0,   0,	 0,   0,
0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,   0,	  0,   0,   0,	 0,   0,
   0,0x0a,0x0b,0x0c,0x0d,0xae,0x0f,0xa0,   0,	0,   0,	  0,   0,   0,	 0,   0,
   0,	0,   0,	  0,   0,   0,	 0,   0,0x60,	0,   0,0xb0,   0,   0,	 0,   0,
   0,0x0a,0x0b,0x8c,0x1d,0xae,0xaf,0xa0,   0,0x20,   0,	  0,   0,   0,0x90,0x40,
0x50,	0,   0,0x70,   0,0x30,	 0,   0,0x60,	0,   0,	  0,   0,   0,	 0,   0,
};
 
/*------------------------------- scanf() -----------------------------------*/

int SCANF(const char *fmt, ...)
{
    va_list ap;

    va_start(ap, fmt);
    return( _do_scan(stdin, fmt, ap) );
}

/*------------------------------- fscanf() ----------------------------------*/

int FSCANF(FILE *fp, const char *fmt, ...)
{
    va_list ap;

    va_start(ap, fmt);
    return( _do_scan(fp, fmt, ap) );
}

/*------------------------------- sscanf() ----------------------------------*/

int SSCANF(register char *string, const char *fmt, ...)
{
    register int i;
    va_list ap;
    FILE my_iobuf;

    i = 0;
    my_iobuf.ptr  = string;
    my_iobuf.base = string;		/* needed for ungetc  */
    while( *string++ != '\0' )		/* get size of string */
	i++;
    my_iobuf.cnt  = i;
    my_iobuf.flags = _IOREAD | _IOSTRING;

    va_start( ap, fmt );
    return( _do_scan( &my_iobuf, fmt, ap ) );
}

/*------------------------------- _do_scan() --------------------------------*

/*
 *_do_scan is the workhorse function for the scanf() series of functions.
 * It reads data from the _iob structure pointed to by its first argument,
 * and converts the characters seen into values according to the format
 * string pointed to by its second argument, fmt.  These values are passed
 * to the calling function by assignment to the variable pointed to by a
 * pointer in the variable argument list of the calling function.  If the
 * input character is inappropriate for the conversion indicated by the
 * format string, a matching failure occurs and the function returns.  If
 * the input terminates (by an EOF, or in the case of sscanf() an end of
 * string) before a conversion takes place, EOF is returned.  Otherwise,
 * _do_scan returns the number of successful conversions.  Note, _do_scan is
 * designed to work only with an isspace() macro which has no side effects.
 */

static long _do_scan(FILE *fp, const char *fmt, va_list ap)
{
    register int inchar;	    /* current input character	      */
    register unsigned long flags;   /* flags set for each conversion  */
    register long ccount;	    /* number of characters input     */
    register unsigned long number;  /* int conversion result	      */
    register long acount;	    /* number of assignments	      */
    register char *cp;		    /* character pointer for strings  */
    register const char *cpc;	    /* charaacter ptr for const str's */	    
    register long field;	    /* field width		      */
    register long width;	    /* for ccount calc. & %[] width   */
    register char *end;		    /* end of a %[ ... ] conversion   */
#ifdef FLOAT							      
#ifndef FP_FLOAT
#ifndef FF_FLOAT
    register int fp_type;	    /* type of float argument	      */
#endif
#endif
    char fltbuff[CVBUFSIZE];	    /* buffer for string to float cnv */
#endif

    ccount = 0;
    acount = 0;
    while( *fmt != '\0' ) {
	if( isspace(*fmt) ) {
	    while( isspace(*++fmt) );		/* skip spaces in fmt  */

	    /* del to cause sp in fmt to eat up 0 or more sp's 3-10-92 */
#if 0
	    if( isspace(inchar = getc(fp)) )
		ccount++;
	    else				/* directive fails if  */
		goto pushback_brk;		/* no space in input   */
#endif
	    while( isspace(inchar = getc(fp)) )	/* skip space in input */
		ccount++;

	    if( inchar == EOF )
		goto out;
	    ungetc(inchar, fp);			/* push back non-space */
	}
	else if( *fmt != '%' ) {		/* match other chars exactly */
	    if( *fmt++ == (inchar = getc(fp)) )
		ccount++;
	    else
		goto pushback_brk;
	}
	else {					/* '%' in fmt string   */
	    field = -1;
	    flags = 0;
#ifdef FLOAT
#ifndef FP_FLOAT
#ifndef FF_FLOAT
	    fp_type = FT_SINGLE;		/* default float type  */
#endif
#endif
#endif
	    if( *++fmt == '*' ) {
		flags |= SUPPRESS;		/* set suppression flag */
		++fmt;
	    }
	    if( isdigit(*fmt) )			/* get the fieldwidth	*/
		for( field = 0; isdigit(*fmt); )
		    field = (10 * field) + *fmt++ - '0';
	    if( field == 0 )			/* zero fieldwidth is a */
		break;				/* matching failure	*/
	    width = field;

	    if( *fmt == 'h' ) {			/* set modifier flags	*/
		flags |= h_MDFR;		/* short int modifier	*/
		++fmt;
	    }
	    else if( *fmt == 'l' ) {
#ifdef FLOAT
#ifndef FP_FLOAT
#ifndef FF_FLOAT
		fp_type = FT_DOUBLE;		/* fp double modifier	*/
#endif
#endif
#endif
#if (__INT__ == 16)
		flags |= l_MDFR;		/* long int modifier	*/
#endif
		++fmt;
	    }
	    else if( *fmt == 'L' ) {
#ifdef FLOAT
#ifndef FP_FLOAT
#ifndef FF_FLOAT
		fp_type = FT_EXTENDED;		/* fp long double mod  */
#endif
#endif
#endif
		++fmt;
	    }

	    /* Now the format string is parsed except for the conversion   */
	    /* character.  If we see anything other than a conversion char */
	    /* here, we have a failure, so break.  The BIT macro indexes   */
	    /* into a static table (digit_tab) on the character, returning */
	    /* a number representing the position in the flags integer of  */
	    /* the flag indicating the conversion character.  So use this  */
	    /* number to set the appropriate flag bit.			   */

	    if( (number = BIT(*fmt++)) == 0 )
		break;
	    flags |= (1 << --number);

	    /* process the input based on conversion char and modifiers */				

	    if( flags & INT_CNV ) {			/* integer types    */
		number = 0;
		while( isspace(inchar = getc(fp)) )	/* skip input space */
		    ccount++;
		field--;

		if( !(flags & (u_CNV | p_CNV)) ) {
		    if( (inchar == '-') || (inchar == '+') ) {
			if( field  == 0 )
			    goto pushback_brk;
			if( inchar == '-' )
			    flags |= NEGFLAG;
			inchar = getc(fp);
			field--;
		    }
		}

		if( (inchar == '0') && field ) {	/* eat 0 and 0x	 */
		    flags |= L_ZERO;
		    inchar = getc( fp );
		    field--;
		    if( (tolower(inchar) == 'x') &&
		    (flags & (x_CNV | p_CNV | i_CNV)) ) {
			flags |= L_ZEROX;
			if( field ) {
			    inchar = getc(fp);
			    field--;
			}
			else {
			    ccount += 2;	/* 0x with fieldwidth of 2 */
			    break;		/* is a matching error	   */
			}
		    }
		    else {
			if( flags & i_CNV )	/* If i_CNV started with 0 */
			    flags |= o_CNV;	/* make it an octal number */
		    }
		}
		else if( flags & i_CNV )	/* non-zero 1st digit  */
		    flags |= d_CNV;		/* i_CNV used as d_CNV */

		if( flags & o_CNV ) {		/* base 8	       */
		    if( isodigit(inchar) ) {
			number = inchar - '0';
			while( field-- && (isodigit(inchar = getc(fp))) ) {
			    number <<= 3;
			    number += (inchar - '0');
			}
		    }
		    else if( !flags & L_ZERO )
			goto pushback_brk;
		}
		else if( flags & ( x_CNV | p_CNV | L_ZEROX) ) {	/* base 16 */
		    if( isxdigit(inchar) ) {
			number = VALUE(inchar);
			while( field-- && isxdigit(inchar = getc(fp)) ) {
			    number <<= 4;
			    number += VALUE(inchar);
			}
		    }
		    else if( !(flags & L_ZERO) || (flags & L_ZEROX) ) {
			if( flags & L_ZEROX )
			    ccount += 2;
			goto pushback_brk;
		    }
		}
		else {				    /* base 10 */
		    if( isdigit(inchar) ) {
			number = inchar - '0';
			while( field-- && isdigit(inchar = getc(fp)) ) {
			    number = (number << 3) + (number << 1); /* x10 */
			    number += (inchar - '0');
			}
		    }
		    else if( !(flags & L_ZERO) )
			goto pushback_brk;
		}

		/* push back mismatched character */

		if( (++field != 0) && (inchar != EOF) )
		    ungetc(inchar, fp);

		ccount += width - field;		/* adjust count */
		if( flags & SUPPRESS )
		    continue;
		else
		    acount++;

		if( flags & NEGFLAG )
		    number = -number;

		if( flags & p_CNV )		    /* pointer assignment */
		    *(va_arg(ap, void **)) = (void *)number;
		else {				    /* unsigneds and ints */
		    if( flags & h_MDFR )
			*(va_arg(ap, short *)) = (short)number;
#if (__INT__ == 16)
		    else if( flags & l_MDFR )
			*(va_arg(ap, long *)) = number;
#endif
		    else
			*(va_arg(ap, int *)) = (int)number;
		}
	    }
	    else if( flags & s_CNV ) {		    /* string conversion */
		while( isspace(inchar = getc(fp)) )
		    ccount++;
		if( inchar == EOF )
		    break;
		ungetc(inchar, fp);

		if( flags & SUPPRESS ) {
		    while( field-- && ((inchar = getc(fp)) != EOF) &&
		    !isspace(inchar) );
		}
		else {
		    cp = va_arg(ap, char *);
		    while( field-- && ((inchar = getc(fp)) != EOF) &&
		    !isspace(inchar) )
			*cp++ = inchar;
		    *cp = '\0';
		    acount++;
		}
		if( (++field != 0) && (inchar != EOF) )
		    ungetc(inchar, fp);
		ccount += width - field;
	    }
	    else if( flags & c_CNV ) {		    /* character conversion */
		if( field < 0 )
		    width = field = 1;		    /* default width is 1   */
		if( flags & SUPPRESS ) {
		    while( field && ((inchar = getc(fp)) != EOF) )
			field--;
		}
		else {
		    cp = va_arg(ap, char *);
		    while( field && ( (inchar = getc(fp)) != EOF ) ) {
			*cp++ = inchar;
			field--;
		    }
		    if( inchar != EOF )
			acount++;
		}
		ccount += width - field;	/* never unget after a %c   */
	    }
	    else if( flags & BRACKET_CNV ) {	/* bracket [...] conversion */
		if( *fmt == '^' ) {
		    flags |= HAT_N_BRACK;
		    fmt++;
		}

		/* include leading ] in scan set */

		cpc = (*fmt == ']') ? (fmt + 1): fmt;

		/* find ] in format string */

		if( (end = strchr(cpc, ']')) == NULL )
		    end = strchr(cpc, '\0');
		width = end - (char *)fmt;	/* number chars from [ to ] */
		if( !(flags & SUPPRESS) )
		    cp = va_arg(ap, char *);
		while( field-- ) {
		    if( (inchar = getc(fp)) == EOF )
			break;
		    ccount++;

		    /* character is in brackets */

		    if( memchr(fmt, inchar, width) != NULL ) {
			if( flags & HAT_N_BRACK )
			    break;
		    }

		    /* character is not in brackets */

		    else if( !(flags & HAT_N_BRACK) )
			break;

		    /* copy the character */

		    if( !(flags & SUPPRESS) ) {
			flags |= CONVERSION;
			*cp++ = inchar;
		    }
		}
		if( (++field != 0) && (inchar != EOF) ) {
		    ungetc(inchar, fp);
		    ccount--;
		}
		if( *end != '\0' )		/* advance fmt past ]	 */
		    ++end;			/* unless it was missing */
		fmt = end;
		if( (flags & (SUPPRESS | CONVERSION)) == CONVERSION ) {
		    acount++;			/* increment count and	  */
		    *cp = '\0';			/* null terminate string  */
		}
	    }
	    else if( flags & FLOAT_CNV ) {	/* floating point conversion */
#ifdef FLOAT
		if( (field == -1) || (field >= CVBUFSIZE) ) 
		    field = CVBUFSIZE - 1;
		while( isspace(inchar = getc(fp)) )	/*skip whitespace */
		    ccount++;
		field--;
		cp = fltbuff;
		if( (inchar == '-') || (inchar == '+') ) {
		    *cp++ = inchar;
		    if( field-- == 0 )	    /* sign alone is not a fp number */
			goto pushback_brk;
		    inchar = getc(fp);
		}
		if( inchar == '.' ) {
		    *cp++ = inchar;
		    if( field-- == 0 )
			goto call_fl_conv;
		    inchar = getc(fp);
		    flags |= MANTISSA;
		}
		if( !isdigit(inchar) ) {
		    flags &= ~MANTISSA;
		    goto call_fl_conv;
		}

		flags |= CHARACTERISTIC;

		/* Scan digits until a non-digit is seen. Then look for a */
		/* dot or an 'e' or 'E'.  Set a flag depending on what	  */
		/* character was seen showing where it is in the parsing  */
		/* of the float.  If it is something not wanted, like a	  */
		/* dot after the mantissa or exponent, quit.		  */

		 for( ; ; ) {
		    while( isdigit(inchar) ) {
			*cp++ = inchar;
			if( field-- == 0 )
			    goto call_fl_conv;
			inchar = getc(fp);
		    }
		    if( inchar == '.' ) {
			if( flags & (MANTISSA | EXPONENT) )
			    break;
			*cp++ = inchar;
			if( field-- == 0 )
			    goto call_fl_conv;
			inchar = getc(fp);
			flags |= MANTISSA;
		    }
		    else if( tolower(inchar) == 'e' ) {
			if( flags & EXPONENT )
			    break;
			*cp++ = inchar;
			if( field-- == 0 )
			    goto call_fl_conv;
			inchar = getc(fp);
			if( (inchar == '-') || (inchar == '+') ) {
			    *cp++ = inchar;
			    if( field-- == 0 )
				goto pushback_brk;  /* 100e+ is not a float */
			    inchar = getc(fp);
			}
			if( !isdigit(inchar) )
			    goto pushback_brk;
			flags |= EXPONENT;
		    }
		    else
			break;
		}
	    call_fl_conv:

		/* do not pushback if field is 0 */

		if( (++field != 0) && (inchar != EOF) )
		    ungetc(inchar, fp);

		ccount += cp - fltbuff;

		if( flags & (MANTISSA | CHARACTERISTIC) ) {
		    if( flags & SUPPRESS )
			continue;
		    *cp = '\0';

		    /* Note that char * is used instead of the more natural */
		    /* void * in the va_arg macro.  This avoids the error   */
		    /* of incrementing a void pointer in the macro.	    */

#ifdef FP_FLOAT
		    _fp_strflt(fltbuff, NULL, va_arg(ap, char*));
#else
#ifdef FF_FLOAT
		    _ff_strflt(fltbuff, NULL, va_arg(ap, char*));
#else
#ifdef DP_FLOAT
		    _dp_strflt(fltbuff, NULL, fp_type, va_arg(ap, char*));
#else
		    _f_strflt(fltbuff, NULL, fp_type, va_arg(ap, char*));
#endif
#endif
#endif
		    acount++;
		}
		else
		    goto out;
#else
		fputs("\nMath library must precede standard C library on "
		"linker command line\n to access scanf() that supports "
		"floating point.\n", stderr);
		exit(1);
#endif
	    }

	    else if( flags & PCT_CNV ) {	    /* % conversion */
		if( (inchar = getc(fp)) == '%' )
		    ccount++;
		else
		    goto pushback_brk;
	    }
	    else if( flags & n_CNV ) {		    /* n conversion */
		if( flags & h_MDFR )
		    *(va_arg(ap, short *)) = (short)ccount;
#if (__INT__ == 16)
		else if( flags & l_MDFR )
		    *(va_arg(ap, long *))  = ccount;
#endif
		else
		    *(va_arg(ap, int *))  = (int)ccount;
	    }

	    /* illegal conversion char was found -- treat as unmatched char */

	    else
		goto pushback_brk;
	}
    }
    goto out;

pushback_brk:
    if( inchar != EOF )
	ungetc(inchar, fp);
out:
    if( (inchar == EOF) && (acount == 0) )
	return(EOF);
    return(acount);
}
