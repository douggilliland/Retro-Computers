/*
     int scanf(format [, arg1 [, ... [, argN]]])
          char     *format;

          This function interprets the data on the standard
          input stream (stdin) as data described by the
          format referenced by <format> and assigns the
          interpreted data to the values referenced by
          the optional arguments <arg1> ... <argN>.
          The function returns the number of values assigned
          from the stream or EOF if a conversion error is
          detected before any assignment is made.

     Arguments:
          format    char *
                    A(format string) [See SCANF(3C)]

     Returns:  int
          The number of assignments made or EOF if an error
          was encountered before any assignment could be
          made.

     Notes:
        - The success of fields converted but not assigned
          is not determinable.
        - All arguments are pointers to the values to be
          assigned.

     Routine History:
          07/11/84 kpm - New
*/

#include  <stdio.h>

int scanf(format)
     char     *format;
{
     return(_fscnf(stdin, &format));
}
