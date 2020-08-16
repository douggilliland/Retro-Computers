/*------------------------------- stdarg.h ----------------------------------*/

/*
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

/*
 * va_start() macro initializes the argument pointer ap to point to the
 * first function parameter after parmN.  That is, to the first of the
 * variable number of parameters.
 *
 * va_arg() macro returns a pointer to the current argument parameter,
 * and advances the argument pointer ap to point to the next argument in
 * the parameter list.	The argument pointer ap is advanced by the size
 * of the object on the stack as determined by sizeof(type).
 */

#ifndef _VA_LIST
#define _VA_LIST
typedef char *va_list;
#endif

#define va_start(ap,parmN) ap = (char*)&parmN + sizeof(parmN)

#define va_arg(ap,type) *((type*)((ap += sizeof((type)1 + 1)) - sizeof(type)))

#define va_end(ap) 

