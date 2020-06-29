/*
     int atoi(str)
          char     *str;

          Converts the string <str> to an INT treating
          the digits in <str> as decimal digits.
          Ignores leading white-space, accepts an
          optional leading sign, ends the conversion
          at the first unrecognizable character.

     Arguments:
          str       char *
                    Null-terminated character-string to
                    convert

     Returns:  int
          Converted value

     Routine History:
          06/21/84 kpm - New
*/

#include  <stdio.h>

int atoi(str)
     char     *str;                /* String to convert */
{
     long      strtol();

     return((int) strtol(str, (char **) NULL, 10));
}
