/*
     void ltol3(cp, lp, n)
          char     *cp;
          long     *lp;
          int       n;

          This function converts a list of long integers
          to a list of 3-byte integers, packed into a
          character array.

     Arguments:
          cp        char *
                    References the target character array.
          lp        long *
                    References the list of longs to be converted
          n         int
                    The number of longs to be converted

     Notes:
        - All long values are truncated to their low-order
          24-bits.
        - It is the user's responsibility to ensure that the
          character array is large enough to hold the converted
          data (<n> * 3 characters long)

     Routine History:
          07/23/84 kpm - New

*/

#include "machine.h"

void ltol3(cp, lp, n)
     REGISTER  char     *cp;
               long     *lp;
     REGISTER  int       n;
{
     /*
          Local declarations
     */
     register  char     *clp;


     /*
          Only convert if <n> > 0
     */
     if (n > 0)
     {
          clp = (char *) lp;  /* Treat longs as char buffer */
          do
          {
               clp++;              /* Skip 1st byte */
               *cp++ = *clp++;     /* Copy 2nd byte */
               *cp++ = *clp++;     /* Copy 3rd byte */
               *cp++ = *clp++;     /* Copy 4th byte */
          } while (--n);      /* While count not exhausted */
     }
}
