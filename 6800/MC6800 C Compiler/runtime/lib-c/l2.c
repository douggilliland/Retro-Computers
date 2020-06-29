/*
     l2.c - two-byte integer functions

          These routines are used to reference and assign
          2-byte integers whose boundary alignment is
          not guarenteed to be even

          void _l2tos(sp, cp, n)
               short int     *sp;
               char          *cp;
               int            n;

          void _stol2(cp, sp, n)
               char          *cp;
               short int     *sp;
               int            n;
*/

#include  "machine.h"

/*
     void _l2tos(sp, cp, n)
          short int     *sp;
          char          *cp;
          int            n;

          This function converts the list of <n> two-byte
          integers referenced by <cp> to short integers,
          saving them in the list of (short int) referenced
          by <sp>.

          This routine is typically used to fetch two-byte
          integers whose boundary alignment may not be
          suitable to a direct reference

     Arguments:
          sp        short int *
                    References the list of short integers
                    to contain the converted values
          cp        char *
                    References the list of two-byte integers
                    to be converted
          n         int
                    The number of values to convert

     Returns:  void

     Routine History:
          08/07/84 kpm - New
*/

void _l2tos(sp, cp, n)
               short int     *sp;
     REGISTER  char          *cp;
     REGISTER  int            n;
{
     REGISTER  char          *csp = (char *) sp;

     while (n-- > 0)
     {
          *csp++ = *cp++;
          *csp++ = *cp++;
     }
}


/*
     void _stol2(cp, sp, n)
          char          *cp;
          short int     *sp;
          int            n;

          This function converts the list of <n> short-integers
          referenced by <sp> to 2-byte integers, storing them
          in the (char) array referenced by <cp>.

          This function is typically used to save short-integers
          into a buffer whose boundary alignment may not be
          suitable for storing short-integers directly.

     Arguments:
          cp        char *
                    References the character array to contain
                    the short integers
          sp        short int *
                    References the list of short integers to
                    be converted
          n         int
                    The number of short integers to convert

     Returns:  void

     Routine History:
          08/06/84 kpm - New
*/

void _stol2(cp, sp, n)
     REGISTER  char          *cp;
               short int     *sp;
     REGISTER  int            n;
{
     REGISTER  char          *csp = (char *) sp;

     while (n-- > 0)
     {
          *cp++ = *csp++;
          *cp++ = *csp++;
     }
}
