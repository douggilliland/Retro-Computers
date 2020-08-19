/*
 *  printf.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdio.h>
#include <ctype.h>
#include <stdarg.h>

#define FT_EXTENDED 2	    /* defined in fp68881.h as _ft_extended */
#define FT_DOUBLE   5	    /* defined in fp68881.h as _ft_double   */
#define CVBUFSIZE   256	    /* size of _f_fltstr() buffer (>= 43)   */
#define S2L_BUFSIZE 22

#define PLUS	    0x01    /* indicates a '+' flag was encountered */
#define L_JSTFY	    0x02    /* indicates a '-' flag was encountered */
#define SPACE	    0x04    /* indicates a ' ' flag was encountered */
#define ALT	    0x08    /* indicates a '#' flag was encountered */
#define Z_PAD	    0x10    /* indicates '0' preceded field width   */
#define h_MDFR	    0x20    /* indicates a 'h' modifier encountered */
#define l_MDFR	    0x40    /* indicates a 'l' modifier encountered */
#define FL_CNV	    0x80    /* Floating point conversion character  */
#define x_CNV	    0x100   /* 'x' conversion character		    */
#define X_CNV	    0x200   /* 'X' conversion character		    */
#define p_CNV	    0x400   /* 'p' conversion character		    */
#define o_CNV	    0x800   /* 'o' conversion character		    */
#define u_CNV	    0x1000  /* 'u' conversion character		    */
#define di_CNV	    0x2000  /* 'd' or 'i' conversion character	    */
#define STR_CNV	    0x4000  /* 's' conversion character		    */

#define INT_CNV	    (x_CNV | X_CNV | p_CNV | o_CNV | u_CNV | di_CNV)
#define NUMBER_CNV  (INT_CNV | FL_CNV) 

#ifdef LIBMSMX
#ifdef FP_FLOAT

#define PRINTF	    printff
#define SPRINTF	    sprintff
#define FPRINTF	    fprintff
#define VPRINTF	    vprintff
#define VSPRINTF    vsprintff
#define VFPRINTF    vfprintff

#else
#ifdef FF_FLOAT

#define PRINTF	    printfff
#define SPRINTF	    sprintfff
#define FPRINTF	    fprintfff
#define VPRINTF	    vprintfff
#define VSPRINTF    vsprintfff
#define VFPRINTF    vfprintfff

#else

#define PRINTF	    printf
#define SPRINTF	    sprintf
#define FPRINTF	    fprintf
#define VPRINTF	    vprintf
#define VSPRINTF    vsprintf
#define VFPRINTF    vfprintf

#endif
#endif
#else

#define PRINTF	    printf
#define SPRINTF	    sprintf
#define FPRINTF	    fprintf
#define VPRINTF	    vprintf
#define VSPRINTF    vsprintf
#define VFPRINTF    vfprintf

#endif

#ifdef FLOAT
#ifdef DP_FLOAT
void _dp_fltstr(double *, char *, long, long, long);
#else
#ifdef FP_FLOAT
void _fp_fltstr(double *, char *, long, long, long);
#else
#ifdef FF_FLOAT
void _ff_fltstr(double *, char *, long, long, long);
#else
int _f_fltstr(long, void *, char *, long, long, long);
#endif
#endif
#endif
#endif

static int _do_prnt(register FILE *, const char *, va_list);
static int str2long(unsigned long, char **, char *, unsigned int);

/*------------------------------ printf() -----------------------------------*/

/*
 * printf accepts as its first argument a format string which contains
 * characters to be printed and conversion specifications.  Each
 * conversion specification is associated with an additional argument to
 * printf.  printf scans through the argument string, printing those
 * characters which are not associated with a conversion specification,
 * and printing the value of additional arguments as a string in a format
 * determined by the conversion specification associated with the argument.
 * printf returns the number of characters printed, or -1 if an error occurs.
 */

int PRINTF(const char *fmt, ...)
{
    va_list ap;

    va_start(ap, fmt);
    return(_do_prnt(stdout, fmt, ap));
}

/*------------------------------- sprintf() ---------------------------------*/

/*
 * sprintf operates just like printf(), except that the result of the
 * conversions is written to a string supplied by the calling function.
 * In order to accomodate _do_prnt(), which does output using the macro
 * putc(), a _iobuf structure is set up to fill the string.  putc() will
 * never confuse things by calling _flushbuf() because structure member cnt
 * is initialized to a large signed integer, and cannot be decremented to
 * zero with a reasonable length string created by _do_prnt().
 */

int SPRINTF(char *dest, const char *fmt, ...)
{
    va_list ap;
    register int rtrn_value;
    FILE my_iobuf;

    my_iobuf.flags = _IOWRITE | _IOSTRING;
#if __INT__ == 16
    my_iobuf.cnt = 0x7fff;		    /* any big number */
#else
    my_iobuf.cnt = 0x7fffffff;		    /* any big number */
#endif
    my_iobuf.ptr = dest;

    va_start(ap, fmt);
    rtrn_value = _do_prnt(&my_iobuf, fmt, ap);
    if( rtrn_value >= 0 )
	putc('\0', &my_iobuf);
    return(rtrn_value);
}

/*------------------------------- fprintf() ---------------------------------*/

/*
 * fprintf is identical to printf() except that a FILE pointer is as its
 * first argument, and used in the call to _do_prnt() instead of stdout.
 */

int FPRINTF(FILE *fp, const char *fmt, ...)
{
    va_list ap;

    va_start(ap, fmt);
    return(_do_prnt(fp, fmt, ap));
}

/*------------------------------- v*printf() --------------------------------*/

/*
 * v*printf is the same as *printf except that va_start is run by the
 * calling routine.
 */

int VPRINTF(const char *fmt, va_list ap)
{
    return(_do_prnt(stdout, fmt, ap));
}

int VSPRINTF(char *buf, const char *fmt, va_list ap)
{
    register int rtrn_value;
    FILE my_iobuf;

#if __INT__ == 16
    my_iobuf.cnt = 0x7fff;		    /* any big number */
#else
    my_iobuf.cnt = 0x7fffffff;		    /* any big number */
#endif
    my_iobuf.ptr = buf;

    rtrn_value = _do_prnt(&my_iobuf, fmt, ap);
    if( rtrn_value >= 0 )
	putc('\0', &my_iobuf);
    return(rtrn_value);
}

int VFPRINTF(FILE *file_ptr, const char *fmt, va_list ap)
{
    return (_do_prnt(file_ptr, fmt, ap));
}

/*----------------------------- _do_prnt() ----------------------------------*/

static int _do_prnt(register FILE *fp, const char *fmt, va_list ap)
{
    register unsigned int flags;    /* flag for holding for conv chars	*/
    register int length;	    /* length of converted string	*/
    register char *buffptr;	    /* pointer to output string		*/
    register char *ptr;		    /* pointer into prefix buffer	*/
    register int count;		    /* number of characters output	*/
    register int width;		    /* field width			*/
    register int precision;	    /* precision specification number	*/
    register int zeros;		    /* number of zeros for precision	*/
    register int pads;		    /* number of padding characters	*/
    register int prefix_len;	    /* length of prefix			*/
    register int cv_char;	    /* conversion (or pad) character	*/
    unsigned long val;		    /* integer value of an argument	*/
    char *ptr_buf;		    /* ptr to buffer filled by str2long */
    char prefix[3];		    /* buffer for the prefix		*/
    char s2l_buf[S2L_BUFSIZE];
#ifdef FLOAT
    int type_code;		    /* code for fltstr routine		*/
    double dval;		    /* _f_fltstr return value		*/
    long double ldval;		    /* _f_fltstr return value		*/
    void *fpval;		    /* pointer to floating point value	*/
    char fp_output_buf[CVBUFSIZE];  /* fp output character buffer	*/
#endif

    count = 0;

    /* loop until the end of the format string */

    while( *fmt ) {
	if( *fmt != '%' ) {
	    if( putc(*fmt++, fp) == EOF )
		return(-1);		    /* return error code */
	    count++;
	}
	else {				    /* current character is a '%' */
	    flags = 0;
	    width = -1;
	    precision = -1;
	    zeros = 0;
	    prefix_len = 0;
#ifdef FLOAT
#ifndef DP_FLOAT
#ifndef FP_FLOAT
#ifndef FF_FLOAT
	    type_code = FT_DOUBLE;
#endif
#endif
#endif
#endif

	    /* process flag characters */

	    for( ; ; ) {
		switch( *++fmt ) {
		case '+': flags |= PLUS; continue;
		case '-': flags |= L_JSTFY; continue;
		case ' ': flags |= SPACE; continue;
		case '#': flags |= ALT; continue;
		default: break;
		}
		break;
	    }

	    /* Process the field width specification.  If the field width */
	    /* character is a '*', the field width is specified as an	  */
	    /* integer argument.  ANSI specifies that if the argument is  */
	    /* negative, it is treated as a '-' flag followed by a	  */
	    /* positive field width.  A leading zero in the field width	  */
	    /* means the field will be padded with zero's and not spaces. */

	    if( *fmt == '0' ) {
		flags |= Z_PAD;
		fmt++;
	    }
	    if( *fmt == '*' ) {
		if( (width = va_arg(ap, int)) < 0 ) {
		    flags |= L_JSTFY;
		    width = -width;
		}
		fmt++;
	    }
	    else {
		if( isdigit(*fmt) )

		    /* compute field width */

		    width = 0;
		    while( isdigit(*fmt) )
			width = (width * 10) + *fmt++ - '0';
	    }

	    /* Process precision specification.	 If the precision    */
	    /* specification is the character '*', the precision is  */
	    /* specified by an integer argument.  If the argument is */
	    /* negative, it will be treated as absent below.	     */

	    if( *fmt == '.' ) {
		if( *++fmt == '*' ) {
		    precision = va_arg(ap, int);
		    fmt++;
		}
		else {
		    precision = 0;
		    while( isdigit(*fmt) )
			precision = (precision * 10) + *fmt++ - '0';
		}
	    }

	    /* Process modifier.  If the next character is 'h', 'l', or */
	    /* 'L' set the associated flag.				*/

	    switch( *fmt ) {
	    case 'h':
		flags |= h_MDFR;
		fmt++;
		break;
	    case 'l':
		flags |= l_MDFR;
		fmt++;
		break;
	    case 'L':
#ifdef FLOAT
#ifndef DP_FLOAT
#ifndef FP_FLOAT
#ifndef FF_FLOAT
		type_code = FT_EXTENDED;
#endif
#endif
#endif
#endif
		fmt++;
		break;
	    default:
		break;
	    }

	    /* set flags associated with the conversion character */

	    switch( cv_char = *fmt++ ) {
	    case 'G':
	    case 'g':
		if( precision == 0 )
		    precision = 1;
	    case 'E':
	    case 'e':
	    case 'f':
		flags |= FL_CNV;
		break;

	    case 'X':
		flags |= X_CNV;
		break;
	    case 'x':
		flags |= x_CNV;
		break;
	    case 'p':
		flags |= p_CNV;
		break;
	    case 'o':
		flags |= o_CNV;
		break;
	    case 'u':
		flags |= u_CNV;
		break;
	    case 'd':
	    case 'i':
		flags |= di_CNV;
		break;
	    case 's':
		flags |= STR_CNV;
		break;
	    case 'n':
		if( flags & h_MDFR )
		    *((short *)va_arg( ap, long )) = count;
		else
		    *((int *)va_arg( ap, long )) = count;
		goto next_iter;
	    case 'c':
		prefix[0] = va_arg(ap, int);
		goto x;
	    default:
		prefix[0] = cv_char;	/* %% */
	    x:
		prefix[1] = '\0';
		buffptr = prefix;
		length = 1;
		break;
	    }

	    /* evaluate floating point numbers */

	    if( flags & FL_CNV ) {
#ifdef FLOAT
		if( precision < 0 )	    /* default precision is 6 */
		    precision = 6;

#ifdef DP_FLOAT
		dval = va_arg(ap, double);
		_dp_fltstr(&dval, fp_output_buf, cv_char, precision,
		((flags & ALT) != 0));
		length = strlen(fp_output_buf);
#else
#ifdef FP_FLOAT
		dval = va_arg(ap, double);
		_fp_fltstr(&dval, fp_output_buf, cv_char, precision,
		((flags & ALT) != 0));
		length = strlen(fp_output_buf);
#else
#ifdef FF_FLOAT
		dval = va_arg(ap, double);
		_ff_fltstr(&dval, fp_output_buf, cv_char, precision,
		((flags & ALT) != 0));
		length = strlen(fp_output_buf);
#else
		if( type_code == FT_DOUBLE ) {
		    dval = va_arg(ap, double);
		    fpval = &dval;
		}
		else {
		    ldval = va_arg(ap, long double);
		    fpval = &ldval;
		}

		length = _f_fltstr(type_code, fpval, fp_output_buf, cv_char,
		precision, ((flags & ALT) != 0));
#endif
#endif
#endif
		buffptr = fp_output_buf;
#else
		fputs("\nMath library must precede standard C library on "
		"linker command line\n to access printf() that supports "
		"floating point.\n", stderr);
		exit(1);
#endif
	    }

	    /* evaluate pointers, decimal, unsigned, octal and hex */

	    else if( flags & INT_CNV ) {
		if( flags & p_CNV ) {
		    val = va_arg(ap, long);
		    flags |= ALT;
		    precision = 8;
		    cv_char = 'x';
		}
		else if( flags & di_CNV ) {	/* integers (%d and %i) */
		    if( flags & l_MDFR )
			val = va_arg(ap, long);
		    else if( flags & h_MDFR )
			val = (short)va_arg(ap, int);
		    else
			val = (int)va_arg(ap, int);
		}
		else {				/* unsigned (%u, %o, %x) */
		    if( flags & l_MDFR )
			val = va_arg(ap, long);
		    else if( flags & h_MDFR )
			val = (unsigned short)va_arg(ap, int);
		    else
			val = (unsigned int)va_arg(ap, int);
		}
		if( precision < 0 )		/* default precision is 1 */
		    precision = 1;
		length = str2long(val, &ptr_buf, s2l_buf, flags);
		buffptr = ptr_buf;
	    }

	    /* Set up strings.	Shorten length if precision requires. */

	    else if( flags & STR_CNV ) {
		buffptr = (char *)va_arg(ap, long);
		length = strlen(buffptr);
		if( (precision >= 0) && (precision < length) )
		    length = precision;
	    }

	    /* compute prefix for all numbers except '%u' unsigned int's */

	    if( flags & (NUMBER_CNV & ~u_CNV) ) {
		ptr = prefix;
		if( flags & (di_CNV | FL_CNV) ) {	/* signed */
		    if( *buffptr == '-' ) {
			*ptr++ = *buffptr++;
			length--;
		    }
		    else if( flags & PLUS )
			*ptr++ = '+';
		    else if( flags & SPACE )
			*ptr++ = ' ';
		}
		else if( (flags & ALT) && val ) {   /* %x, %p, %o && # && ^0 */
		    if( flags & (x_CNV | X_CNV | p_CNV) ) {
			*ptr++ = '0';
			*ptr++ = cv_char;
		    }
		    else if ( (flags & o_CNV) && (precision <= length) )
			*ptr++ = '0';
		}
		*ptr = '\0';
		prefix_len = ptr - prefix;
	    }

	    /* calculate leading zeros for precision specification */

	    if( flags & INT_CNV )
		if( precision > length )
		    zeros = precision - length;

	    /* Get number of padding characters, if any, that are needed   */
	    /* to fill the field width.	 If padding is necessary and the   */
	    /* argument is right justified within the field, either adjust */
	    /* the number of zeros to be printed after the prefix, or	   */
	    /* output the space padding before the prefix (depending on	   */
	    /* the padding specified).					   */

	    /* If right justified, zero padding on the left changes the	   */
	    /* number of zeros after the prefix.			   */

	    if( (pads = (width - prefix_len - zeros - length)) > 0 ) {
		if( !(flags &  L_JSTFY) ) {
		    if( flags & Z_PAD ) {
			zeros += pads;
			pads = 0;
		    }
		    else {			/* output space padding */
			count += pads;
			while( pads-- )
			    if( putc(' ', fp) == EOF )
				return(-1);	/* error */
		    }
		}
	    }

	    if( prefix_len ) {			/* output prefix */
		count += prefix_len;
		for( ptr = prefix; *ptr; )	/* '\0' terminates prefix */
		    if( putc(*ptr++, fp) == EOF )
			return(-1);		/* error */
	    }
	    if( zeros ) {			/* output precision zeros */
		count += zeros;
		while( zeros-- )
		    if(putc('0', fp) == EOF)
			return(-1);		/* error */
	    }
	    if( length ) {			/* output converted arg	  */
		count += length;
		while( length-- )
		    if( putc(*buffptr++, fp) == EOF )
			return(-1);		/* error */
	    }

	    /* output padding for left justification */

	    if( pads > 0 ) {
		count += pads;
		cv_char = (flags & Z_PAD) ? '0' : ' ';
		while( pads-- )
		    if( putc(cv_char, fp) == EOF )
			return(-1);		/* error */
	    }
	}
    next_iter:;
    }
    return(count);
}

/*------------------------------ str2long() ---------------------------------*/

/*
 * str2long converts a 32 bit value into a string.  Depending on the bits set
 * in the flags argument, the string will contain the octal, decimal,
 * unsigned decimal, or hexadecimal representation of the number.  If the
 * flag corresponding to the 'X' printf conversion is set (X_CNV), the]
 * hexadecimal representation will contain upper case letters, while if the
 * (x_CNV) is set, it will contain lower case letters.	str2long returns
 * the number of bytes placed in the destination string, including a leading
 * minus in the case of a signed negative value.  If the value passed to
 * str2long is 0, the string will contain only a null byte, and length zero
 * will be returned.  Minimum precision determinations are left to the
 * calling routine.
 */

static int str2long(
register unsigned long value,		    /* value to be converted	 */
char **ptr2ptr,				    /* pointer to buffer pointer */
char *s2l_buf,				    /* pointer to conversion buf */
register unsigned int flags)		    /* printf flags		 */
{
    static const char lc_digits[] = {"0123456789abcdef"};
    static const char uc_digits[] = {"0123456789ABCDEF"};
    register char *ptr;
    register const char *digit_ptr;
    int negative;

    if( value == 0 ) {			/* return immediately if value == 0 */
	s2l_buf[0] = '\0';
	*ptr2ptr = s2l_buf;
	return( 0 );
    }

    ptr = s2l_buf + S2L_BUFSIZE - 1;	/* put null byte at end of s2l_buf  */
    *ptr = '\0';
    negative = 0;

    if( (flags & di_CNV) && ((long)value < 0) ) {
	negative = 1;
	value = -value;			/* make it positive   */
    }
    if( flags & (u_CNV | di_CNV) ) {	/* base 10 conversion */
	do {
	    *--ptr = (value % 10) + '0';
	} while( value /= 10 ); 
    }
    else if( flags & o_CNV ) {		/* base 8 conversion  */
	do {
	    *--ptr = (value & 0x7) + '0';
	} while( value >>= 3 );
    }
    else {				/* base 16 conversion */
	digit_ptr = (flags & X_CNV) ? uc_digits: lc_digits;
	do {
	    *--ptr = *(digit_ptr + (value & 0xf));
	} while( value >>= 4);
    }
    if( negative )
	*--ptr = '-';
    *ptr2ptr = ptr;

    /* return the number bytes in the string */

    return(s2l_buf + S2L_BUFSIZE - 1 - ptr);
}

