/*
     char *gcvt(val, precn, buf)
          double    val;
          int       precn;
          char     *buf;

          This function converts the double-precision floating-
          point value <val> to its character equivalent, placing
          the result in the buffer referenced by <buf>.  It
          produces at most <precn> digits.  The format depends
          on the value of <val>.  If the exponent of <val> is
          less than -4 or > <precn> (dec.pt. in front of the
          first digit) and <val> != 0.0, generate 'e'-like
          string with trailing zeros in the significand removed.
          Otherwise, generate 'f'-like string with the all
          insignificant digits removed.  If there are no digits
          to the right of the decimal point, the decimal point
          is also removed.

     Arguments:
          val       double
                    The value to convert
          precn     int
                    The maximum number of significant digits
                    requested
          buf       The address of the target buffer

     Returns:
          The address of the target buffer if successful,
          NULL otherwise

     Errors:
        - <precn> <= 0
        - <precn> > internal maximum of "gcvt()"

     Routine History:
          12/04/84 kpm - New
*/


#include "machine.h"
#include <string.h>

char *gcvt(val, precn, buf)
     double    val;
     int       precn;
     char     *buf;
{
     ADDRREG0  char     *p;
     ADDRREG1  char     *q;

               int       decpt;
               int       sign;
     DATAREG0  int       i;
     DATAREG1  int       j;

               char     *ecvt();


     if ((p = ecvt(val, precn, &decpt, &sign)) != NULL)
     {
        q = buf;
        if (sign != 0)
           *q++ = '-';
        if (((i=decpt) >= -3) && (i <= precn))
        {
           /* f-type conversion */
           if (i <= 0)
           {
              *q++ = '0';
              *q++ = '.';
              while (++i <= 0) *q++ = '0';
              while (*q++ = *p++);
           }
           else
              if (i < precn)
              {
                 while (--i >= 0) *q++ = *p++;
                 *q++ = '.';
                 while (*q++ = *p++) ;
              }
              else while (*q++ = *p++);
           /*
              Strip insignificant trailing '0's
           */
           if (decpt < precn)
           {
              --q;
              while (*--q == '0') ;
              if (*q != '.') q++;
              *q = '\0';
           }
        }
        else
        {
           /* e-type conversion */
           *q++ = *p++;
           *q++ = '.';
           while (*q++ = *p++) ;
           --q;
           while (*--q == '0') ;
           if (*q != '.') q++;
           *q++ = 'e';
           if ((i = decpt-1) >= 0)
              *q++ = '+';
           else
           {
              i = -i;
              *q++ = '-';
           }
           *q++ = '0' + (i/10);
           *q++ = '0' + (i%10);
           *q = '\0';
        }
        p = buf;
     }
     return(p);
}
