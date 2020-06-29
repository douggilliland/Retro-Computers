/*
     Included in this module:

     char *_itostr(val, base, digits, sign)

          Converts an integer (signed or unsigned) to
          its character representation in the specified
          base

     char *_ltostr(val, base, digits, sign)

          Converts a long integer (signed or unsigned)
          to its character representation in the specified
          base
*/

/*
     Common definitions:
*/
#include  "machine.h"
#include  <stdio.h>
#include  <string.h>

#define   CVTSTRSZ       33


/*----------------------------------------------------------*/

/*
     char *_ltostr(val, base, digits, sign)
          long      val;
          int       base;
          char     *digits;
          int      *sign;

          This function generates a string of ASCII
          characters from the value <val>, according
          to the base <base> and the digit-string
          referenced by <digits>.

          If <sign> != NULL, the int <sign> references
          will be set to 0 if <val> >= 0, -1 otherwise,
          and the string of characters generated will
          reflect the absolute value of <val>.  Otherwise,
          <val> is assumed to be unsigned.

          The string of digits (characters) referenced
          by <digits> is the list of characters in the
          base, beginning with zero up to but not including
          the base.  Extra characters are ignored; the string
          must have atleast <base> characters.

          The function returns a pointer to a static buffer
          containing the generated characters or NULL if an
          error was detected.

     Arguments:
          val       long
                    The long value to convert
          base      int
                    The base to convert through (i.e. 10 for
                    decimal numbers
          digits    char *
                    References the string containing the
                    digits of the base
          sign      int *
                    References an int to contain a sign
                    indicator if not NULL, otherwise indicates
                    that the value <val> is unsigned

     Returns:  char *
          A pointer to the static buffer containing the
          generated string

     Errors:
        - <base> < 2
        - strlen(<digits>) < <base>

     Routine History:
          06/28/84 kpm - New
*/

char *_ltostr(val, base, digits, sign)
     REGISTER  long      val;
     REGISTER  int       base;
     REGISTER  char     *digits;
     REGISTER  int      *sign;
{
     register  char          *p;
     REGISTER  unsigned int   b;
     REGISTER  unsigned long  i;
     REGISTER  unsigned long  j;
     static    char           staticbuf[CVTSTRSZ];

     if ((base < 2) || (strlen(digits) < base))
          return(NULL);

     if (sign != NULL)
          if (val < 0)
          {
               val = -val;
               *sign = -1;
          }
          else *sign = 0;

     *(p = &staticbuf[CVTSTRSZ-1]) = '\0';
     b = (unsigned) base;
     i = (unsigned long) val;
     if (i == 0) *--p = *digits;
     else while (i != 0)
          {
               j = i;
               *--p = *(digits + (j - ((i /= b) * b)));
          }

     return(p);
}

/*----------------------------------------------------------*/

/*
     char *_itostr(val, base, digits, sign)
          int       val;
          int       base;
          char     *digits;
          int      *sign;

          This function generates a string of ASCII
          characters from the value <val>, according
          to the base <base> and the digit-string
          referenced by <digits>.

          If <sign> != NULL, the int <sign> references
          will be set to 0 if <val> >= 0, -1 otherwise,
          and the string of characters generated will
          reflect the absolute value of <val>.  Otherwise,
          <val> is assumed to be unsigned.

          The string of digits (characters) referenced
          by <digits> is the list of characters in the
          base, beginning with zero up to but not including
          the base.  Extra characters are ignored; the string
          must have atleast <base> characters.

          The function returns a pointer to a static buffer
          containing the generated characters or NULL if an
          error was detected.

     Arguments:
          val       int
                    The value to convert
          base      int
                    The base to convert through (i.e. 10 for
                    decimal numbers
          digits    char *
                    References the string containing the
                    digits of the base
          sign      int *
                    References an int to contain a sign
                    indicator if not NULL, otherwise indicates
                    that the value <val> is unsigned

     Returns:  char *
          A pointer to the static buffer containing the
          generated string

     Errors:
        - <base> < 2
        - strlen(<digits>) < <base>

     Routine History:
          06/28/84 kpm - New
*/

char *_itostr(val, base, digits, sign)
     int       val;
     int       base;
     char     *digits;
     int      *sign;
{
     char     *_ltostr();

     return(_ltostr((long) val, base, digits, sign));
}
