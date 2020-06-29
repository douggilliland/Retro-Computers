/*
     int _fprtfp(stream, fmt, value)
          FILE               *stream;
          struct ofmtdesc    *fmt;
          double              value;

     int _sprtfp(string, fmt, value)
          char               *string;
          struct ofmtdesc    *fmt;
          double              value;

          This function generates characters from the floating-
     point value <value> using the 'e', 'E', 'f', 'g', or 'G'
     format description described by the structure referenced
     by <fmt> and writes those characters to the standard
     I/O stream <stream> (character-string whose address is
     <string>).  It returns as its result the number of characters
     written to the standard I/O stream (character-string).

     Arguments:
          stream    FILE *
                    The standard I/O stream to write the 
                    generated characters to
          string    char *
                    The character-string to write the
                    generated characters to
          fmt       struct ofmtdesc *
                    Information describing the field description
          value     double
                    The value from which characters are generated
*/

#include  "machine.h"
#include  <stdio.h>
#include  <string.h>
#include  <ctype.h>
#include  "fmtout.h"
#include  "fmtin.h"

#define   DECPT     '.'

#define   WRCHR(c)  {putc((c), stream); chrcnt++;}
#define   FPRINTF   1

#include  "printfp.h"


#undef    FPRINTF

#define   WRCHR(c)  {*q++ = (c);}
#define   SPRINTF   1

#include  "printfp.h"


#define   FSCANF   1
#define   NXTCHR() ((c=getc(stream))!=EOF)

#include  "scanfp.h"


#undef    FSCANF
#define   SSCANF   1
#define   NXTCHR() (c=(*q++))

#include  "scanfp.h"


/*
     void pffinit()

          This function does nothing.  Referencing this function
     guarentees that the floating-point conversion code for
     "fprintf()" and "sprintf()" get brought in.  Normally,
     the floating-point conversion code for these routines
     are stubs.
*/

void pffinit() {}
