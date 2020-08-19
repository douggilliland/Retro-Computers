/*
 *  ioctl.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <io.h>

int _raw_mode;

/*-------------------------------- ioctl() ----------------------------------*/

/*
 * ioctl switches between COOKED and RAW mode I/O behavior in read().
 * (default is COOKED mode I/O)
 */

int ioctl(int fd, int request, void *arg)
{
    if( request & RAW )
	_raw_mode = 1;
    else
	_raw_mode = 0;
    return(0);
}
