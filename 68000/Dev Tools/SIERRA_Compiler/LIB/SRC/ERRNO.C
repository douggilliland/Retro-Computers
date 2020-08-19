/*
 *  errno.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 *
 *  errno is #defined in errno.h as _errno, the object defined below.  errno
 *  is set by various library and system functions on error.  The value of
 *  errno set accordingly to correspond to the reason for failure.
 */

int _errno;
