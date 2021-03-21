/**
 * @file   rand.h
 * @brief  Pseudo-random number generation.
 * @author Miguel I. Garcia Lopez / FloppySoftware
 *
 * Pseudo-random number generation, for MESCC (Mike's Enhanced
 * Small C Compiler for Z80 & CP/M).
 *
 * Revisions:
 *  - 18 Mar 2015 : 1st version.
 *  - 23 Mar 2015 : Trying to improve rand().
 *  - 15 Aug 2016 : Documented. GPL v3.
 *
 * Defined macros:
 *  - RAND_MAX
 *
 * Copyright (c) 2015-2016 Miguel I. Garcia Lopez / FloppySoftware.
 *
 * Licensed under the GNU General Public License v3.
 *
 * http://www.floppysoftware.es
 * floppysoftware@gmail.com
 */
#ifndef RAND_H

#define RAND_H

#define RAND_MAX 32767

int xs_seed = 1; // Initial value for seed

/**
 * @fn     int rand(void)
 * @brief  Generate a pseudo-random value between 0 and RAND_MAX (both included).
 * @return value
 */
rand()
{
	// return (xs_seed = ((xs_seed * 3) + 1) & 0x7FFF);

	return (xs_seed = (((xs_seed << 1) + xs_seed) + 1) & 0x7FFF);
}

/**
 * @fn     void srand(unsigned int seed)
 * @brief  Seeds the pseudo-random number generator used by rand().
 * @param  seed - value
 */
srand(seed)
unsigned int seed;
{
	xs_seed = seed;
}

#endif

