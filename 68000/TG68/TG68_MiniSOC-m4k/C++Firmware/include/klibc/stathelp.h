/*
 * stathelp.h
 *
 * Helper macros for <klibc/archstat.h>
 */

#ifndef _KLIBC_STATHELP_H
#define _KLIBC_STATHELP_H

#include <klibc/endian.h>

/*
 * Most architectures have a 64-bit field for st_dev and st_rdev,
 * but dev_t is 32 bits (uint32_t == unsigned int), so make a
 * macro we can use across all architectures.
 */

#if __BYTE_ORDER == __BIG_ENDIAN
# define __stdev64(x)	unsigned int __##x, x;
#else
# define __stdev64(x)	unsigned int x, __##x;
#endif

#endif				/* _KLIBC_STATHELP_H */
