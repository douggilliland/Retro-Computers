/*
     int _fmtin(pfmt)
          struct ifmtdesc    *pfmt;

          This function deciphers a format description
          given to sscanf() (fscanf()), fills the
          structure referenced by "pfmt" with information
          describing that format description, and returns
          the type of the format.

     Arguments:
          pfmt      struct ifmtdesc *
                    References the structure to contain the
                    description of the format

     Returns:  int
          The type of the format

     Notes:
        - Both 'l' and 'h' in a format description cause the
          description to be indecipherable
        - The function expects pfmt->fmtptr to be filled
          by the caller -- it must contain the address of
          the first character of the format (the character
          immediately following the '%' that introduces the
          format)
        - This routine only understands the format of the
          specification, not the types of the conversions

     Routine History:
          07/09/84 kpm - New
*/

#include  "machine.h"
#include  <stdio.h>
#include  "fmtin.h"
#include  <ctype.h>

int _fmtin(pfmt)
     register  struct ifmtdesc    *pfmt;
{
     /*
          Local declarations
     */

     REGISTER  char               *p;
               char               *q;
     REGISTER  char               *r;
     REGISTER  char               *s;
     REGISTER  char                c;
     REGISTER  char                i;
     REGISTER  char                boolval;


     /*
          Initializations
     */
     p = pfmt->fmtptr;

     /*
          No-assignment flag
     */
     if (pfmt->noasgflg = ((c = *p++) == '*')) c = *p++;

     /*
          Width field
     */
     if (isdigit(c))
     {
          pfmt->width = _strtoi(p-1, &q, 10);
          p = q;
          c = *p++;
     }
     else pfmt->width = -1;

     /*
          Size of operand
     */
     if (pfmt->longflg = (c == 'l'))
     {
          c = *p++;
          pfmt->shortflg = FALSE;
     }
     else if (pfmt->shortflg = (c == 'h')) c = *p++;

     /*
          Conversion code
     */
     if ((pfmt->type = c) != NULL)
     {
          if (c == '[')
          {
               if (boolval = ((c = *p++) == '^')) c = *p++;
               for (r = pfmt->charbuf , i = 128 ; i-- ; *r++ = boolval);
               boolval = !boolval;
               r = pfmt->charbuf;
               if ((c == ']') || (c == '-'))
               {
                    s = r + ((int) c);
                    if (*p == '-')
                         if (((i = *++p - c) > 0) && (*p != ']'))
                         {
                              do
                                   *s++ = boolval;
                              while (i--);
                              p++;
                         }
                         else
                         {
                              *s = boolval;
                              *(r + ((int) '-')) = boolval;
                         }
                    else
                         *s = boolval;
                    c = *p++;
               }

               while (c != NULL)
               {
                    if (c == ']') break;
                    s = r + ((int) c);
                    if (*p == '-')
                    {
                         if (((i = *++p - c) > 0) && (*p != ']'))
                         {
                              do
                                   *s++ = boolval;
                              while (i--);
                              p++;
                         }
                         else
                         {
                              *s = boolval;
                              *(r + ((int) '-')) = boolval;
                         }
                    }
                    else
                         *s = boolval;
                    c = *p++;
               }
               if (c == NULL) --p;  /* Ended w/out ']' char */
          }
     }
     else --p;

     /*
          Return the type of the format (or NULL if
          the format description was indecipherable
     */
     pfmt->ptr = p;
     return((int) pfmt->type);
}
