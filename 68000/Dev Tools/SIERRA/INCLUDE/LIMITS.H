/*--------------------------------- limits.h --------------------------------*/

/*
 *  Copyright 1987, 1994 by Sierra Systems.  All rights reserved.
 *
 *  Definitions of the limits applicable to data types in the Sierra C
 *  compiler and cross development package.
 *
 *  As specified by ANSI C, constants whose values cannot be represented as
 *  a signed int are treated as unsigned.  Therefore, INT_MIN and LONG_MIN 
 *  cannot be represented as -2147483648 because this evaluates to a negative
 *  unsigned constant.	The expresssion -(2147483647+1)	is used because it
 *  evalutes to a negative signed constant.
 */

#define CHAR_BIT    8			/* number of bits in a char	   */
#define SCHAR_MIN   (-128)		/* minimum signed char value	   */
#define SCHAR_MAX   127			/* maximum signed char value	   */
#define UCHAR_MAX   255U		/* maximum unsigned char value	   */
#define CHAR_MIN    (-128)		/* minimum (signed) char value	   */ 
#define CHAR_MAX    127			/* maximum (signed) char value	   */
#define MB_LEN_MAX  1			/* maximum bytes in multibyte char */
#define SHRT_MIN    (-32768)		/* minimum (signed) short value	   */
#define SHRT_MAX    32767		/* maximum (signed) short value	   */
#define USHRT_MAX   65535U		/* maximum unsigned short value	   */
#define LONG_MIN    (-(2147483647+1))	/* minimum (signed) long value	   */
#define LONG_MAX    2147483647		/* maximum (signed) long value	   */
#define ULONG_MAX   4294967295U		/* maximum unsigned long value	   */
#if __INT__==32
#define INT_MIN	    (-(2147483647+1))	/* minimum (signed) int value	   */
#define INT_MAX	    2147483647		/* maximum (signed) int value	   */
#define UINT_MAX    4294967295U		/* maximum unsigned int value	   */
#else
#define INT_MIN	    (-32768)		/* minimum (signed) int value	   */
#define INT_MAX	    32767		/* maximum (signed) int value	   */
#define UINT_MAX    65535U		/* maximum unsigned int value	   */
#endif
