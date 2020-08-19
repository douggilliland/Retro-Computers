/*---------------------------------- float.h --------------------------------*/

/*
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 *
 *  Constants that provide information on floating point processing.
 */

#define FLT_RADIX	    2	    /* radix of exponent representation */
#define FLT_ROUNDS	    1	    /* addition rounds to nearest	*/

#if __FLOAT__ == 80	    /* 80 Bit Floating Point (coprocessor) */

#define LDBL_MANT_DIG	    64
#define LDBL_DIG	    19
#define LDBL_MIN_EXP	    (-16382)
#define LDBL_MIN_10_EXP	    (-4930)
#define LDBL_MAX_EXP	    16384
#define LDBL_MAX_10_EXP	    4932
#define LDBL_MAX	    1.18973149535723176490e+4932L
#define LDBL_EPSILON	    1.08420217248550443401e-19L
#define LDBL_MIN	    3.36210314311209350650e-4932L

#define DBL_MANT_DIG	    53
#define DBL_DIG		    15
#define DBL_MIN_EXP	    (-1021)
#define DBL_MIN_10_EXP	    (-307)
#define DBL_MAX_EXP	    1024
#define DBL_MAX_10_EXP	    308
#define DBL_MAX		    1.7976931348623157e+308
#define DBL_EPSILON	    2.2204460492503131e-16
#define DBL_MIN		    2.2250738585072014e-308

#define FLT_MANT_DIG	    24
#define FLT_DIG		    7
#define FLT_MIN_EXP	    (-125)
#define FLT_MIN_10_EXP	    (-37)
#define FLT_MAX_EXP	    128
#define FLT_MAX_10_EXP	    38
#define FLT_MAX		    3.40282347e+38
#define FLT_EPSILON	    1.19209290e-07
#define FLT_MIN		    1.17549435e-38

#elif __FLOAT__ == 64	    /* 64 Bit Floating Point */

#define LDBL_MANT_DIG	    53	
#define LDBL_DIG	    15	
#define LDBL_MIN_EXP	    (-1021) 
#define LDBL_MIN_10_EXP	    (-307)  
#define LDBL_MAX_EXP	    1024    
#define LDBL_MAX_10_EXP	    308	
#define LDBL_MAX	    1.7976931348623157e+308 
#define LDBL_EPSILON	    2.2204460492503131e-16  
#define LDBL_MIN	    2.2250738585072014e-308 

#define DBL_MANT_DIG	    53
#define DBL_DIG		    15
#define DBL_MIN_EXP	    (-1021)
#define DBL_MIN_10_EXP	    (-307)
#define DBL_MAX_EXP	    1024
#define DBL_MAX_10_EXP	    308
#define DBL_MAX		    1.7976931348623157e+308
#define DBL_EPSILON	    2.2204460492503131e-16
#define DBL_MIN		    2.2250738585072014e-308

#define FLT_MANT_DIG	    24
#define FLT_DIG		    7
#define FLT_MIN_EXP	    (-125)
#define FLT_MIN_10_EXP	    (-37)
#define FLT_MAX_EXP	    128
#define FLT_MAX_10_EXP	    38
#define FLT_MAX		    3.40282347e+38
#define FLT_EPSILON	    1.19209290e-07
#define FLT_MIN		    1.17549435e-38

#elif __FLOAT__ == 32	    /* 32 Bit Floating Point Only */

#define LDBL_MANT_DIG	    24
#define LDBL_DIG	    7
#define LDBL_MIN_EXP	    (-125)
#define LDBL_MIN_10_EXP	    (-37)
#define LDBL_MAX_EXP	    128
#define LDBL_MAX_10_EXP	    38
#define LDBL_MAX	    3.40282347e+38
#define LDBL_EPSILON	    1.19209290e-07
#define LDBL_MIN	    1.17549435e-38

#define DBL_MANT_DIG	    24
#define DBL_DIG		    7
#define DBL_MIN_EXP	    (-125)
#define DBL_MIN_10_EXP	    (-37)
#define DBL_MAX_EXP	    128
#define DBL_MAX_10_EXP	    38
#define DBL_MAX		    3.40282347e+38
#define DBL_EPSILON	    1.19209290e-07
#define DBL_MIN		    1.17549435e-38

#define FLT_MANT_DIG	    24
#define FLT_DIG		    7
#define FLT_MIN_EXP	    (-125)
#define FLT_MIN_10_EXP	    (-37)
#define FLT_MAX_EXP	    128
#define FLT_MAX_10_EXP	    38
#define FLT_MAX		    3.40282347e+38
#define FLT_EPSILON	    1.19209290e-07
#define FLT_MIN		    1.17549435e-38

#else			    /* Motorola Fast Floating Point Only */

#define LDBL_MANT_DIG	    24
#define LDBL_DIG	    7
#define LDBL_MIN_EXP	    (-63)
#define LDBL_MIN_10_EXP	    (-19)
#define LDBL_MAX_EXP	    63
#define LDBL_MAX_10_EXP	    18
#define LDBL_MAX	    9.22337055e18
#define LDBL_EPSILON	    1.19209290e-07
#define LDBL_MIN	    5.42101097e-20

#define DBL_MANT_DIG	    24
#define DBL_DIG		    7
#define DBL_MIN_EXP	    (-63)
#define DBL_MIN_10_EXP	    (-19)
#define DBL_MAX_EXP	    63
#define DBL_MAX_10_EXP	    18
#define DBL_MAX		    9.22337055e18
#define DBL_EPSILON	    1.19209290e-07
#define DBL_MIN		    5.42101097e-20

#define FLT_MANT_DIG	    24
#define FLT_DIG		    7
#define FLT_MIN_EXP	    (-63)
#define FLT_MIN_10_EXP	    (-19)
#define FLT_MAX_EXP	    63
#define FLT_MAX_10_EXP	    18
#define FLT_MAX		    9.22337055e18
#define FLT_EPSILON	    1.19209290e-07
#define FLT_MIN		    5.42101097e-20

#endif

#define FFLT_MANT_DIG	    24
#define FFLT_DIG	    7
#define FFLT_MIN_EXP	    (-63)
#define FFLT_MIN_10_EXP	    (-19)
#define FFLT_MAX_EXP	    63
#define FFLT_MAX_10_EXP	    18
#define FFLT_MAX	    9.22337055e18
#define FFLT_EPSILON	    1.19209290e-07
#define FFLT_MIN	    5.42101097e-20

/*
 * _MANT_DIG	    number of bits in mantissa
 * _DIG		    number of decimal digits of precision
 * _MIN_EXP	    minimum negative integer such that 2 rasied to that
 *		    power minus 1 is a normalized floating point number
 * _MIN_10_EXP	    minimum negative integer such that 10 raised to that
 *		    power is a normalized floating point number
 * _MAX_EXP	    maximum integer such that 2 raised to that power
 *		    minus 1 is a representable floating point number
 * _MAX_10_EXP	    maximum integer such that 10 raised to that power is in
 *		    the range of representable floating point numbers
 * _MAX		    maximum representable finite floating point number
 * _EPSILON	    minimum positive fp number such that (1.0 + x ) != 1.0
 * _MIN		    minimum normalized floating point number
 */
