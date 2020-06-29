/*
     int _fmtout(pfmt)
          struct ofmtdesc    *pfmt;

          This function decodes a format description
          for an internal-to-external form conversion
          (i.e. fprintf(), sprintf()].  It expects
          pfmt->fmt_ptr to reference the first character
          of the format (the character after the '%'
          that introduces the format description).
          It returns after filling the structure
          referenced by "pfmt" and returns the type of
          the format, or NULL if unknown.

     Arguments:
          pfmt      struct ofmtdesc *
                    References the structure to contain
                    information about the format.

     Returns:  int
          The format type or NULL if indecipherable

     Routine History:
          07/06/84 kpm - New
*/

/*
     Common definitions
*/
#include  "machine.h"
#include  <stdio.h>
#include  "fmtout.h"
#include  <ctype.h>

int _fmtout(pfmt)
     register  struct ofmtdesc    *pfmt;
{
     REGISTER  char               *p;
     REGISTER  char               *r;
     REGISTER  char                c;
               char               *q;
               int                 _strtoi();


     /*
          Set up defaults
     */
     p = pfmt->fmtptr;
     pfmt->width = -1;
     pfmt->precn = -1;
     pfmt->justify = FALSE;
     pfmt->signed = FALSE;
     pfmt->blsign = FALSE;
     pfmt->alt = FALSE;
     pfmt->type = NULL;

     /*
          Handle flags
          May be in any order
     */
     while (c = *p++)
          if (c == '-') pfmt->justify = TRUE;
          else if (c == '+') pfmt->signed = TRUE;
          else if (c == ' ') pfmt->blsign = TRUE;
          else if (c == '#') pfmt->alt = TRUE;
          else break;

     /*
          Width field (default to -1)
     */
     if (isdigit(c))
     {
          pfmt->width = _strtoi(p-1, &q, 10);
          p = q;
          c = *p++;
          pfmt->varwidth = FALSE;
     }
     else if (pfmt->varwidth = (c == '*')) c = *p++;

     /*
          Precision field (default to -1)
          A null precision field (".") defaults
          to 0
     */
     if (c == '.')
     {
          if (isdigit(c = *p))
          {
               pfmt->precn = _strtoi(p, &q, 10);
               p = q;
               c = *p++;
               pfmt->varprecn = FALSE;
          }
          else
          {
               p++;
               if (pfmt->varprecn = (c == '*')) c = *p++;
               else pfmt->precn = 0;
          }
     }
     else pfmt->varprecn = FALSE;

     /*
          Long flag
     */
     if (pfmt->longflg = (c == 'l')) c = *p++;

     /*
          Field type
     */
     pfmt->type = c;


     /*
          Finished
     */
     pfmt->ptr = (c == '\0') ? p-1 : p;
     return(pfmt->type);
}
