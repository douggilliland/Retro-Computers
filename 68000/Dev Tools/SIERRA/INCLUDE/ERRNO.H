/*--------------------------------- errno.h ---------------------------------*/

/*
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#ifndef errno		/* define errno if user has not already defined it */
#define errno _errno
#endif

extern int errno;

/*
 * Sierra Systems errno error codes.
 *
 * Additions and/or changes to this list must be accompainied by similar
 * modifications to the file strerror.c in the libc source directory and
 * the mx_xcptn.s and h_xcptn.s files in the fp library source directory.
 */

#define NOERROR	    0		/*  no error			       */
#define ENOENT	    1		/*  no such file entry		       */
#define EIO	    2		/*  i/o error			       */
#define ENOTTY	    3		/*  not a serial device		       */
#define ENOMEM	    4		/*  out of memory		       */
#define EACCES	    5		/*  permission denied		       */
#define ENOTBLK	    6		/*  block device required	       */
#define ENODEV	    7		/*  no such device		       */
#define EINVAL	    8		/*  invalid argument		       */
#define EMFILE	    9		/*  file table is full		       */
#define EDRFUL	    10		/*  device directory is full	       */
#define ENOSPC	    11		/*  no space left on device	       */
#define ENOABLK	    12		/*  no more allocation blocks	       */
#define ENODBLK	    13		/*  no more data blocks on device      */
#define EFILEO	    14		/*  cannot create, file is open	       */
#define ENORAM	    15		/*  no ram space configured	       */
#define ENOHEAP	    16		/*  no heap space configured	       */
#define EISEEK	    17		/*  can't extend read only file	       */
#define EBADF	    18		/*  file not open, bad file descriptor */
#define EINSIG	    19		/*  invalid signal number	       */
#define EDOM	    20		/*  argument is out of range	       */
#define ERANGE	    21		/*  result is out of range	       */
