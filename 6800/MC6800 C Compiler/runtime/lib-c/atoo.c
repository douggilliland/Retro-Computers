/*
     long _atoo(str)
          char     *str;

          Converts the string <str> to a LONG treating
          the digits in <str> as octal digits.
          Ignores leading white-space, accepts an
          optional leading sign, ends the conversion
          at the first unrecognizable character.

     Arguments:
          str       char *
                    Null-terminated character-string to
                    convert

     Returns:  long
          Converted value

     Routine History:
          06/21/84 kpm - New
*/

#include  <stdio.h>

long _atoo(str)
     char     *str;                /* String to convert */
{
     long      strtol();

     return(strtol(str, (char **) NULL, 8));
}
