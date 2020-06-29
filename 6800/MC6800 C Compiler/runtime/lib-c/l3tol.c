/*
     void l3tol(lp, cp, n)
          long     *lp;
          char     *cp;
          int       n;

          This function converts <n> 3-byte integers,
          represented as a list of bytes in the character
          array referenced by <cp>, to a list of long
          integers referenced by <lp>.

     Arguments:
          lp        long *
                    References a list of long integers,
                    the buffer to contain the results
          cp        char *
                    References the list of 3-byte ints
                    to be converted
          n         int
                    The number of 3-byte integers to convert

     Notes:
        - The conversions are SIGNED conversions
        - It is the caller's responsibility to ensure that
          there is enough space in the array of long ints
          to contain all of the results

     Errors:  None

     Routine History:
          07/23/84 kpm - New
*/

#include "machine.h"

void l3tol(lp, cp, n)
     REGISTER  char     *cp;
               long     *lp;
     REGISTER  int       n;
{
     /*
          Local declarations
     */
     register  char     *clp;


     /*
          Convert data only if <n> > 0
     */

     if (n > 0)
     {
          clp = (char *) lp;
          do
          {
               /*
                    Convert one item at a time
                    SIGNED conversion!!
               */
               *((short *) clp) = (short) *cp++;
               clp += 2;
               *clp++ = *cp++;
               *clp++ = *cp++;
          } while (--n);
     }
}
