/*******************************************************************/
/*                                                                 */
/*                            R A N D O M                          */
/*                                                                 */
/*******************************************************************/

/*   Random number functions.

     srand(seed)
     int seed;

     rrand()

     rand()

     Utilizes a Tausworthe 31/7 random number generator .

*/

#define SEED 12345678L        /* default seed */

static short initialized = 0; /* nonzero when intialized */
static long random;           /* the random number */


/*******************************************************************/
/*                                                                 */
/*   rand - return the next random number                          */
/*                                                                 */
/*******************************************************************/

int rand()

{    long s;                  /* scratch */

     if(!initialized) {
          random = SEED;
          initialized = 1;
     }
     s = random;
     s >>= 7;  /* right shift 7 */
     random = (s ^= random);  /* exclusive or and make both the same */
     s <<= 24; /* left shift by 31-7 */
     random = (random ^ s) & 0x7FFFFFFFL; /* exclusive or and clear sign */
     return (int)(random & 0x7FFF);
}

/*******************************************************************/
/*                                                                 */
/*   rrand - seed ranndom number generator from clock              */
/*                                                                 */
/*******************************************************************/

rrand()

{    long time();        /* get time */

     random = time(0);
     initialized = 1;
}

/*******************************************************************/
/*                                                                 */
/*   srand - initialize random number generator from a seed        */
/*                                                                 */
/*******************************************************************/

srand(s)
int s;         /* the seed */

{
     if(s == 0 || s == 1) random = SEED;
     else random = s & 0x7FFF;
     initialized = 1;
}
