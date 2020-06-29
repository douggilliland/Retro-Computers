/*
     int fprintf(stream, format [, arg1 [, ... [, argN]]])
          FILE     *stream;
          char     *format;

          This function edits the data represented by
          <arg1>, ..., <argN> according to the format
          referenced by <format> and writes the edited
          data to the stream referenced by <stream>.
          The function returns the number of characters
          written to the stream or a negative number
          if an error was detected.

     Arguments:
          stream    FILE *
                    References the standard I/O stream to
                    which data is to be written
          format    char *
                    A(format string) [See PRINTF(3C)]

     Returns:  int
          The number of characters written to the stream
          or a negative number if an error was detected

     Routine History:
          07/03/84 kpm - New
*/

/*
     Definitions used in "printf.h" to tailor that code
     for fprintf()
*/


#define   WRCHR(c)  {putc(c, stream); chrcnt++;}
#define   FPRINTF   1

#include  "machine.h"
#include  <stdio.h>
#include  <string.h>
#include  "fmtout.h"
#include  "printf.h"

int fprintf(stream, format)
     FILE     *stream;
     char     *format;
{
     return(_fprtf(stream, &format));
}
