/*
     int abs(i)
          int  i;

          This function returns the absolute value
          of its argument <i>.  If <i> is the maximum
          negative number, the function returns <i>
          and reports no error.

     Arguments:
          i         int
                    Argument to take the absolute value of

     Returns:  int
          abs(i) == i if i >= 0,
                   -i otherwise.


     Errors:
        - Integer overflow occurs if <i> == max neg number.
          This condition is ignored -- result is <i>.

     Routine History:
          07/23/84 kpm - New
*/


int abs(i)
     int       i;
{
     return((i >= 0) ? i : -i);
}
