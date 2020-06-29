/*
     int printf(format [,arg1 [,... [, argN]]])
          char     *format;

          This function formats the data represented by the
          arguments (<arg1>, ..., <argN>) according to the
          format description referenced by <format> and writes
          that data to the standard output device.  The function
          returns the number of characters written to the device
          or a negative number if there was an error.

     Arguments:
          format    char *
                    References the string describing the format
                    of the output

     Returns:  int
          The number of characters written to the standard output
          stream or a negative number if there was an error.

     Routine History:
          07/03/84 kpm - New
*/

#include  <stdio.h>

int printf(format)
     char     *format;
{
     return(_fprtf(stdout, &format));
}
