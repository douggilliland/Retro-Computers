/*
     int sprintf(string, format [, arg1 [, ... [, argN]]])
          char     *string;
          char     *format;

          This function edits the data represented by
          <arg1>, ..., <argN> according to the format
          referenced by <format> and saves the edited
          data in the buffer referenced by <string>.
          The edited data is null-terminated.  The
          function returns the length of the null-
          terminated character string generated.

     Arguments:
          string    char *
                    Target buffer
          format    char *
                    A(format string) [See PRINTF(3C)]

     Returns:  int
          The length of the generated character string

     Notes:
        - The caller is responsible for providing a buffer
          large enough for the edited data.
        - The count-of-characters returned does not include
          the null terminating the character string

     Routine History:
          07/03/84 kpm - New
*/

/*
     Definitions used in "printf.h" to tailor that code
     for sprintf()
*/

#define   WRCHR(c)  {*q++ = c;}
#define   SPRINTF   1

#include  "machine.h"
#include  <stdio.h>
#include  "fmtout.h"
#include  <string.h>
#include  "printf.h"

int sprintf(string, format)
     char     *string;
     char     *format;
{
     return(_sprtf(string, &format));
}
