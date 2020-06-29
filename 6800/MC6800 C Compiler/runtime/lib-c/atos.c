/*
     short _atos(str)
          char     *str;

          Converts the string <str> to a SHORT, treating
          the digits in <str> as decimal digits.
          Ignores leading white-space, accepts an
          optional leading sign, ends the conversion
          at the first unrecognizable character.

     Arguments:
          str       char *
                    Null-terminated character-string to
                    convert

     Returns:  short
          Converted value

     Routine History:
          06/21/84 kpm - New
*/

#include  <stdio.h>

short _atos(str)
     char     *str;                /* String to convert */
{
     long      strtol();

     return((short) strtol(str, (char **) NULL, 10));
}
