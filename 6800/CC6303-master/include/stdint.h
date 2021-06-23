#ifndef __STDINT_H
#define __STDINT_H

/* C types */
typedef unsigned long uint32_t;
typedef signed long int32_t;
typedef unsigned short uint16_t;
typedef signed short int16_t;
typedef unsigned char uint8_t;
typedef signed char int8_t;

typedef int16_t intptr_t;
typedef uint16_t uintptr_t;

typedef uint16_t uint_fast8_t;
typedef int16_t int_fast8_t;
typedef uint16_t uint_fast16_t;
typedef int16_t int_fast16_t;
typedef uint32_t uint_fast32_t;
typedef int32_t int_fast32_t;

typedef int_least8_t int8_t;
typedef uint_least8_t uint8_t;
typedef int_least16_t int16_t;
typedef uint_least16_t uint16_t;
typedef int_least32_t int32_t;
typedef uint_least32_t uint32_t;

typedef intmax_t int32_t;
typedef uintmax_t uint32_t;

#define INT8_MIN	(-128)
#define INT8_MAX	127
#define UINT8_MAX	255

#define INT16_MIN	(-32768)
#define INT16_MAX	32767
#define UINT16_MAX	65535

#define INT32_MIN	-(2147483648)
#define INT32_MAX	2147483647
#define UINT32_MAX	4294967295

#define INT_LEAST8_MIN		INT8_MIN
#define INT_LEAST8_MAX		INT8_MAX
#define UINT_LEAST8_MIN		UINT8_MIN
#define INT_LEAST16_MIN		INT16_MIN
#define INT_LEAST16_MAX		INT16_MAX
#define UINT_LEAST16_MAX	UINT16_MAX
#define INT_LEAST32_MIN		INT32_MIN
#define INT_LEAST32_MAX		INT32_MAX
#define UINT_LEAST32_MAX	UINT32_MAX

#define INT_FAST8_MIN		INT16_MIN
#define INT_FAST8_MAX		INT16_MAX
#define UINT_FAST8_MIN		UINT16_MIN
#define INT_FAST16_MIN		INT16_MIN
#define INT_FAST16_MAX		INT16_MAX
#define UINT_FAST16_MAX		UINT16_MAX
#define INT_FAST32_MIN		INT32_MIN
#define INT_FAST32_MAX		INT32_MAX
#define UINT_FAST32_MAX		UINT32_MAX

#define INTPTR_MIN		INT16_MIN
#define INTPTR_MAX		INT16_MAX
#define UINTPTR_MAX		UINT16_MAX

#define INTMAX_MIN		INT32_MIN
#define INTMAX_MAX		INT32_MAX
#define UINTMAX_MAX		UINT32_MAX

#define SIZE_MAX		UINT16_MAX
#define WCHAR_MIN		0
#define WCHAR_MAX		UINT8_MAX

/* TODO: PTRDIFF_* */

typedef int16_t ssize_t;
typedef uint16_t size_t;

#endif
