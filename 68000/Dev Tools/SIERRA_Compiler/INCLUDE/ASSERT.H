/*--------------------------------- assert.h --------------------------------*/

/*
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 *
 *  The assert macro is designed to be placed in code with an expression
 *  as an argument which is believed to be true.  If the expression is
 *  false (eg. there is a bug) a message is printed to stderr describing the
 *  assertion which was false and indicating the file and line number.
 *
 *  After development is complete, the message can be turned off by defining
 *  NDEBUG in the source and recompiling.
 */

#undef assert

#ifdef NDEBUG

#define assert(ignore)

#else

#include <stdio.h>

#define	assert(exp) if( !(exp) ) { \
fprintf(stderr, "Assertion failed: %s, file %s, line %d\n", \
#exp, __FILE__, __LINE__); \
abort(); }

#endif
