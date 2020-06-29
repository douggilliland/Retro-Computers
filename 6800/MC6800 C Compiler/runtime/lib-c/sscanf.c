/*
     int sscanf(string, format [, arg1 [, ... [, argN]]])
          char     *string;
          char     *format;

          This function interprets the string represented by
          referenced by <string> as data described by the
          format referenced by <format> and assigns the
          interpreted data to the values referenced by
          the optional arguments <arg1> ... <argN>.
          The function returns the number of values assigned
          from the string or EOF if a conversion error is
          detected before any assignment is made.

     Arguments:
          string    char *
                    String to interpret
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

/*
     Definitions used in "scanf.h" to tailor that code
     for sscanf()
*/

#define   NXTCHR() (c=(*q++))
#define   SSCANF   1

#include  "machine.h"
#include  <ctype.h>
#include  <stdio.h>
#include  "fmtin.h"
#include  <string.h>
#include  "scanf.h"

int sscanf(string, format)
     char     *string;
     char     *format;
{
     return(_sscnf(string, &format));
}
