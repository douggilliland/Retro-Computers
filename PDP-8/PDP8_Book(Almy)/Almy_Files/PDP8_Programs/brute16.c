/* Find all primes using a brute force approach.
 * This technique uses multiply and divide instructions. */

#include <stdio.h>      /* for putchar function */

//#define MAXINT 4095     /* Maximum integer with our 12 bit numbers */
//#define MAXROOT 64      /* We don't need to check beyond this */
#define MAXINT 65535     /* Maximum integer with our 16 bit numbers */
#define MAXROOT 256      /* We don't need to check beyond this */

void main(void) {

    unsigned int checking;       /* The value we are currently checking */
    unsigned int trial;          /* The trial divisor */
    unsigned int i;

    checking = 2;       /* Start with 2 */
    do
    {
        trial = 2;
        while (trial < checking)
        {
            /* If there is no remainder, then checking is divisible by
             * trial */
            if (checking % trial == 0) goto notPrime;
            trial = trial + 1;
        }
        /* If we get here, we have a prime number */
        i = checking;
        if (i < 10) goto lt10;
        if (i < 100) goto lt100;
	if (i < 1000) goto lt1000;
	if (i < 10000) goto lt10000;
        /* Since division gives both the quotient and the remainder,
         * the division and remainder operations in the next two
         * statements can be done in a single operation on the PDP-8 */ 
	putchar((i / 10000) + '0');
	i = i % 10000;
lt10000:        putchar((i / 1000) + '0');
        i = i % 1000;
lt1000: putchar((i / 100) + '0');
        i = i % 100;
lt100:  putchar((i / 10) + '0');
        i = i % 10;
lt10:   putchar(i + '0');
        putchar(' ');   /* Space between values */
notPrime:
        checking = checking + 1; /* Go to next value to check */
    } while (checking <= MAXINT); /* This is actually a check for carry out in the previous addition in the PDP-8 */
}
