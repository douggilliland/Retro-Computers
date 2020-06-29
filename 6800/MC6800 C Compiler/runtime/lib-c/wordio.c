/*
     Functions defined in this module:

          int  getw(stream)

          int  putw(stream)
*/

/*
     Common definitions
*/
#include "machine.h"
#include <stdio.h>


/*-----------------------------------------------------------------*/

/*
     int putw(wd, stream)
          int       wd;
          FILE     *stream;

          This function writes the word <wd> to the
          standard I/O stream <stream>.  No alignment
          is assumed on the output file.

     Arguments:
          wd        Word to write.
          stream    A(standard I/O buffer) describing i/o
                    stream

     Returns:
          wd if successful, EOF if failure

     Notes:
        - EOF is a valid value to write.  Use ferror() to
          determine if there was an error.
        - A partial word may be written if there is an error.

     Revision History:
          06/13/84 kpm - New
*/


int putw(wd, stream)
               int       wd;
     REGISTER  FILE     *stream;
{
     register  char     *p;
     REGISTER  int       i;

     p = (char *) &wd;
     for (i = 0 ; i < sizeof(int) ; i++)
        if (putc(*p++, stream) == EOF) return(EOF);
     return(wd);
}

/*----------------------------------------------------------------*/

/*
     int getw(stream)
          FILE     *stream;

          This function reads the next word from the
          input stream <stream>.  The size of a word
          is "sizeof(int)".  No alignment is assumed
          in the file.

     Arguments:
          stream    A(Standard I/O stream) iob

     Returns:
          EOF if end-of-file or error, word read if successful

     Notes:
        - EOF is a valid value to read, use feof() and
          ferror() to determine if there was error or
          if end-of-file was detected.
        - If EOF or error occurs while reading a word
          EOF is returned.  Thus, partial words at the
          end of the file can not be read.

     Revision History:
          06/13/84 kpm - New
*/

int getw(stream)
     REGISTER  FILE     *stream;
{
     register  char     *p;
     REGISTER  int       i;
               int       wd;

     p = (char *) &wd;
     for (i = 0 ; i < sizeof(int) ; i++)
        if ((*p++ = getc(stream)) == EOF) return(EOF);
     return(wd);
}
