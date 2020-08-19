/*
 *  rand.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdlib.h>

/*-------------------------------- rand() -----------------------------------*/

/*
 * rand is a pseudo random number generator which returns an integer
 * in the range 0 to 32767
 */

static unsigned long next = 1;

int rand(void)
{
    next = next * 1103515245 + 12345;
    return((unsigned int)(next / 262144) % 32768);
}

/*-------------------------------- srand() ----------------------------------*/

void srand(unsigned int seed)
{
    next = seed;
}
