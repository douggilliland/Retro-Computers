/* Find primes using the Sieve of Erathosthenes.
 * This technique doesn't use multiply or divide instructions. */

#include <stdio.h>      /* for putchar function */


#define MAXINT 65535     /* Maximum integer with our 12 bit numbers */
#define MAXROOT 256      /* We don't need to check beyond this */

#define WORDS (65536L/8)  /* We will use single bits in the sieve array to represent each value, but to */
/* make the math easier, we will use only eight bits per word so we can
 * find the word index and bit position by shifts and masks only. WORDS
 * represents the size of the sieve array */

int sieve[WORDS];


void main(void) {
    unsigned int checking;       /* The value we are currently checking */
    unsigned int multiple;       /* The location we are marking */
    unsigned int i,j;            /* Temporary variables */

    /* First clear the array */
    i = 0;
    do
    {
        sieve[i] = 0;
        i = i + 1;
    } while (i < WORDS);

    /* Do the marking */
    checking = 2;
    do
    {   /* Is the value we are checking a prime? */
        i = checking >> 3; /* word index is checking right shifted 3 bits*/
        j = 1 << (checking & 0x7); /* bit index -- shift 1 left 0 to 7 times depending on 3 lsbs of checking */
        if ((sieve[i] & j) == 0) /* we have a prime, so... */
        {
            /* Mark multiples of the number as not being prime */
            multiple = checking;
            do
            {
                multiple = multiple + checking;
                /* This needs some explanation. multiple can never
                 * actually be bigger than the maximum integer, so this
                 * is really a test of if the preceding addition
                 * overflowed (carry set). If this C program is run on a PC, an
                 * integer is actually bigger than MAXINT so this will
                 * work as written. The "break" gets us out of the
                 * loop. */
                if (multiple > MAXINT) break;
                /* mark the location as not being prime */
                i = multiple >> 3;      /* again, find the word index */
                j = 1 << (multiple & 0x07); /* and the bit mask */
                sieve[i] = sieve[i] | j; /* Set the bit */
            } while (1);        /* Do forever, until break is executed */
        }

        checking  = checking + 1;       /* Go to next value to check */
    } while (checking < MAXROOT);

    /* Now print all primes */
    checking = 2;
    do
    {
        /* is value of checking not marked (is a prime?) */
        i = checking >> 3;
        j = 1 << (checking & 0x07);
        if ((sieve[i] & j) == 0)
        {
            /* Print value to display, but we can't divide to convert
             * to ASCII. */
            i = checking;
            j = '0';

            /* Optional code to make output look nicer (no leading
             * zeroes) */
            if (i < 10) goto lt10;
            if (i < 100) goto lt100;
            if (i < 1000) goto lt1000;
	    if (i < 10000) goto lt10000;
            /* End of optional code */

	    while (i > 10000)
	    {
		    j = j + 1;
		    i = i - 10000;
	    }
	    putchar(j);
	    j = '0';
	    
lt10000:    while (i > 1000)
            {
                j = j + 1;
                i = i - 1000;
            }
            putchar(j);
            j = '0';
lt1000:     while (i > 100)
            {
                j = j + 1;
                i = i - 100;
            }
            putchar(j);
            j = '0';
lt100:      while (i > 10)
            {
                j = j + 1;
                i = i - 10;
            }
            putchar(j);
lt10:       i = i + '0';
            putchar(i);
            putchar(' ');       /* Space between numbers */
        }
        checking = checking + 1;
    } while (checking < MAXINT);        /* Again, this is an carry out check in the PDP-8 */
            
}             
