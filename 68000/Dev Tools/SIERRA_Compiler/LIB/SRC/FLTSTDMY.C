/*
 *  fltstdmy.c	(libc)
 *
 *  Copyright 1992 by Sierra Systems.  All rights reserved.
 */

/*------------------------------ _f_fltstr() --------------------------------*/

/*
 * _f_fltstr is a dummy float to string conversion function that gets pulled
 * in if the actual _f_fltstr function defined in LIBM is not pulled in
 */

int _f_fltstr(int type, char *ptr_2_fp, char *buf, int conv_flag, int prec,
int alt_fmt)
{
    *buf = '\0';
    return(0);
}
