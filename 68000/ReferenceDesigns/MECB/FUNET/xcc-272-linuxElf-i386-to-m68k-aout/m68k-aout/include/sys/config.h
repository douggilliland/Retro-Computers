/* exceptions first */
#if defined(__H8300__) || defined(__H8500__) || defined (__H8300H__)
#define _FLOAT_ARG float
#define __SMALL_BITFIELDS
#define H8300 1
#define __IEEE_BIG_ENDIAN
#endif

/* 16 bit integer machines */
#if defined(__Z8001__) || defined(__Z8002__) || defined(__H8300__) || defined(__H8500__) || defined(__H8300H__)
#undef INT_MAX
#undef UINT_MAX
#define INT_MAX 32767
#define UINT_MAX 65535
#endif

#ifdef ___AM29K__
#define _FLOAT_RET double
#endif

#ifdef __i386__
#ifndef __unix__
/* in other words, go32 */
#define _FLOAT_RET double
#endif
#endif

#ifdef __m68000__
/* This is defined in machine/ieeefp.h; need to check is it redundant here? */
#define __IEEE_BIG_ENDIAN
#endif

/* ... and if there were no exceptions, the normal case. */
/* FIXME: How does this jive with _ansi.h? */
#ifndef _FLOAT_ARG
#define _FLOAT_ARG double
#endif
#ifndef _FLOAT_RET
#define _FLOAT_RET float
#endif

#if INT_MAX == 32767
typedef long int __int32_t;
typedef unsigned long int __uint32_t;
#else
typedef int __int32_t;
typedef unsigned int __uint32_t;
#endif

