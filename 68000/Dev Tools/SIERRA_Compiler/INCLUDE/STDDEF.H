/*--------------------------------- stddef.h --------------------------------*/

/*
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 *
 *  Commonly used definitions and typedefs
 */

#ifndef _SIZE_T
#define _SIZE_T
typedef unsigned long size_t;	/* type returned by sizeof operator	   */
#endif

#ifndef _WCHAR_T
#define _WCHAR_T
typedef unsigned char wchar_t;	/* type that fits widest defined character */
#endif

typedef long ptrdiff_t;		/* type of difference between two pointers */

#define NULL (void *)0

#define offsetof(struct_type, mbr) ((size_t)&(((struct_type*)0)->mbr))

