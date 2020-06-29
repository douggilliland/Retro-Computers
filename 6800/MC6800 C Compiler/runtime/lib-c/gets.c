/*
     char *gets(s)
          char     *s;

     This function reads characters from the standard
     input stream, stdin, saving them in the character
     array pointed to by "s".  It reads until it sees
     the end of the stream or an end-of-line character
     (EOL).  It discards the EOL (if read) and ends
     the string of characters with a NULL character.

     Arguments:
          s        *char
                    Pointer to target char array

     Returns:
          NULL if the end of the input stream is
          reached and no characters were read,
          otherwise, its argument "s".

     Routine History:
          05/31/84 kpm - New
*/


#include "machine.h"
#include <stdio.h>

char *gets(s)
     char     *s;
{
     register   char   *ptr;
     REGISTER   int     c;

     /*  Keep reading characters until the end of the
         file is reached or an EOL (end-of-line) char
         is read.  Discard the EOL character and NULL
         terminate the string.
     */
     ptr = s;
     while (((c = getc(stdin)) != EOF) && (c != EOL)) *ptr++ = c;
     *ptr = '\0';

     /*  Return NULL if the end of the file was reached
         and no characters were read, otherwise return
         a pointer to the character array containing
         the characters read.
     */
     return(((c == EOF) && (ptr == s)) ? NULL : s);
}
