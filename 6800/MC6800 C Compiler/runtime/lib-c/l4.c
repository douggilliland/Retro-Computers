/*
     l4.c - four-byte integer functions

          These routines are used to reference and assign
          4-byte integers whose boundary alignment is
          not guarenteed to be even

          void _l4tol(lp, cp, n)
               long int      *lp;
               char          *cp;
               int            n;

          void _ltol4(cp, lp, n)
               char          *cp;
               long int      *lp;
               int            n;
*/

#include  "machine.h"

/*
     void _l4tol(lp, cp, n)
          long int      *lp;
          char          *cp;
          int            n;

          This function converts the list of <n> four-byte
          integers referenced by <cp> to long integers,
          saving them in the list of (long int) referenced
          by <lp>.

          This routine is typically used to fetch four-byte
          integers whose boundary alignment may not be
          suitable to a direct reference

     Arguments:
          lp        long int *
                    References the list of long integers
                    to contain the converted values
          cp        char *
                    References the list of four-byte integers
                    to be converted
          n         int
                    The number of values to convert

     Returns:  void

     Routine History:
          08/07/84 kpm - New
*/

void _l4tol(lp, cp, n)
               long int      *lp;
     REGISTER  char          *cp;
     REGISTER  int            n;
{
     REGISTER  char          *clp = (char *) lp;

     while (n-- > 0)
     {
          *clp++ = *cp++;
          *clp++ = *cp++;
          *clp++ = *cp++;
          *clp++ = *cp++;
     }
}


/*
     void _ltol4(cp, lp, n)
          char          *cp;
          long int      *lp;
          int            n;

          This function converts the list of <n> long-integers
          referenced by <lp> to 4-byte integers, storing them
          in the (char) array referenced by <cp>.

          This function is typically used to save long-integers
          into a buffer whose boundary alignment may not be
          suitable for storing long-integers directly.

     Arguments:
          cp        char *
                    References the character array to contain
                    the long integers
          lp        long int *
                    References the list of long integers to
                    be converted
          n         int
                    The number of long integers to convert

     Returns:  void

     Routine History:
          08/06/84 kpm - New
*/

void _ltol4(cp, lp, n)
     REGISTER  char          *cp;
               long int      *lp;
     REGISTER  int            n;
{
     REGISTER  char          *clp = (char *) lp;

     while (n-- > 0)
     {
          *cp++ = *clp++;
          *cp++ = *clp++;
          *cp++ = *clp++;
          *cp++ = *clp++;
     }
}
