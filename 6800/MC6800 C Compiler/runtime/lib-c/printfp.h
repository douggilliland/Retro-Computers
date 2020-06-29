/*
     printfp.h - Output code for floating-point values

          This file defines the functions which generate
     characters from a floating-point value and write those
     characters to a standard I/O stream or to a character-
     string.

     Those functions are:

     int _fprtfp(stream, fmt, ppval)
          FILE               *stream;
          struct ofmtdesc    *fmt;
          double            **ppval;

     char *_sprtfp(string, fmt, ppval)
          char               *string;
          struct ofmtdesc    *fmt;
          double            **ppal;

          These function generate characters from the floating-
     point value **<ppval> using the 'e', 'E', 'f', 'g', or 'G'
     format description described by the structure referenced
     by <fmt> and writes those characters to the standard
     I/O stream <stream> (character-string whose address is
     <string>).  It increments *<ppval> by sizeof(double).

          The function "_fprtfp()" returns the number of 
     characters written to the stream <stream>.  The function
     "_sprtfp()" returns <string> as its result.

     Arguments:
          stream    FILE *
                    The standard I/O stream to write the 
                    generated characters to
          string    char *
                    The character-string to write the
                    generated characters to
          fmt       struct ofmtdesc *
                    Information describing the field description
          ppval     double **
                    A pointer to the address of the value from
                    which characters are generated
*/

#ifdef FPRINTF
int _fprtfp(stream, fmt, ppval)
     FILE               *stream;
#endif
#ifdef SPRINTF
char *_sprtfp(string, fmt, ppval)
     char               *string;
#endif
     ADDRREG1  struct ofmtdesc    *fmt;
               double            **ppval;
{
     ADDRREG0  char              *p;
#ifdef SPRINTF
     ADDRREG2  char              *q = string;
#endif
     ADDRREG3  char     *r;

#ifdef FPRINTF
     DATAREG0  int       chrcnt;
#endif
     DATAREG1  int       n;
     DATAREG2  int       prc;
     DATAREG3  int       nldgt;
     DATAREG4  int       wid;
     DATAREG5  int       dpflg;
               int       expnt;
               int       signflg;
               double    val;
               char      gfmtbuf[40];


#ifdef FPRINTF
     chrcnt = 0;
#endif
     val = *(*ppval)++;
     switch(fmt->type)
     {

     /*
        Field types:  e, E
        Floating-point data, scientific notation
     */
     case 'e':
     case 'E':
          /* Default the precision */
          if ((prc = fmt->precn) < 0) prc = 6;

          /* Generate digits ... use default precision if
             there's any error */
          if ((p = ecvt(val, prc+1, &expnt, &signflg)) == NULL)
               p = ecvt(val, (prc=6)+1, &expnt, &signflg);

          /* Correct exponent (unless value is zero) */
          if (val != 0.0) expnt--;
         
          /* Determine the minimum field width
             Sum of:
              - precision
              - size of exponent (4 or 5)
              - +1 for single digit left of dec.pt.
              - +1 for sign (if any)
              - +1 for dec.pt. (if any)
          */
          wid = prc + 5;
          if (abs(expnt) > 99) wid++;
          if (signflg || fmt->signed || fmt->blsign) wid++;
          if (dpflg = ((prc != 0) || fmt->alt)) wid++;
 
          /* Write leading spaces (if any) */
          for (n = fmt->width - wid ; --n >= 0 ; ) WRCHR(' ')

          /* Write sign (if any) */
          if (signflg) WRCHR('-')
          else if (fmt->signed) WRCHR('+')
               else if (fmt->blsign) WRCHR(' ')
  
          /* Write single digit left of dec.pt. (always one) */
          WRCHR(*p++)

          /* Put the dec.pt.  (if any)
             and digits right of dec.pt. (if any) */
          if (dpflg)
          {
               WRCHR(DECPT)
               while (--prc >= 0) WRCHR(*p++)
          }

          /* Introduce the exponent (with the field type) */
          WRCHR(fmt->type)

          /* Generate and write the exponent */
          p = _itostr(expnt, 10, "0123456789", &signflg);
          WRCHR(signflg?'-':'+')
          if ((n = strlen(p)) < 2) WRCHR('0')
          while (--n >= 0) WRCHR(*p++)

          /* End 'e', 'E' format */
          break;

     /*
        Field types:  f
        Floating-point data, decimal notation
     */
     case 'f':

          /* Set default precision */
          if ((prc = fmt->precn) < 0) prc = 6;

          /*
             Generate digits
             Revert to default precision if explicit precision
             is too large
          */
          if ((p = fcvt(val, prc, &expnt, &signflg)) == NULL)
               p = fcvt(val, (prc = 6), &expnt, &signflg);
         
          /* Determine the number of digits to write */
          if ((nldgt = expnt) > 0) wid = nldgt + prc;
          else wid = prc + 1;
    
          /* Count the sign (if any) */
          if (signflg || fmt->signed || fmt->blsign) wid++;

          /* Count the decimal point (if any) */
          if (dpflg = ((prc != 0) || fmt->alt)) wid++;

          /* Write leading spaces (if any) */
          for (n = fmt->width - wid ; --n >= 0 ; ) WRCHR(' ')

          /* Write the sign (if any) */
          if (signflg) WRCHR('-')
          else if (fmt->signed) WRCHR('+')
               else if (fmt->blsign) WRCHR(' ')

          /*
             Write the digits generated.
             Two cases:
               - Atleast 1 signif digit left of dec.pt.
               - No signif digits left of dec.pt.
          */
          if (nldgt > 0)
          {
               /* Write signif digits left of dec.pt. */
               while(--nldgt >= 0) WRCHR(*p++)

               /* Write decimal point and digits right of dec.pt. */
               if (dpflg)
               {
                    WRCHR(DECPT)
                    while(--prc >= 0) WRCHR(*p++)
               }
          }
          else
          {
               /* No signif digits left of dec.pt. */
               /* Write a single zero left of dec.pt. */
               WRCHR('0')

               /* Write dec.pt. (if necessary) */
               if (dpflg) WRCHR(DECPT)

               /* Write leading zeros (right of dec.pt.) */
               while (++nldgt <= 0)
               {
                    prc--;
                    WRCHR('0')
               }
             
               /* Write signif digits left of dec.pt. */
               while (--prc >= 0) WRCHR(*p++)
          }
  
          /* End 'f'-type field */
          break;

     /*
        Format types:  'g', 'G'
        Floating-point data:  Convert through 'e', 'E', or
        'f' formats, dependent upon the value of the data
     */
     case 'g':
     case 'G':
          /* Default the precision */
          if ((prc = fmt->precn) <= 0) prc = 6;

          /* Generate digits ... use default precision if
             there's any error */
          if ((p = ecvt(val, prc, &expnt, &signflg)) == NULL)
               p = ecvt(val, prc=6, &expnt, &signflg);

          /*
             Generate the string to be written (before applying
             the (explicit width)
          */
          r = gfmtbuf;

          /* Set sign */
          if (signflg != 0) 
             *r++ = '-';
          else
             if (fmt->signed)
                *r++ = '+';
             else
                if (fmt->blsign)
                   *r++ = ' ';
          /* Determine type of format */
          if (((n=expnt) >= -3) && (n <= prc))
          {
             /* 'f'-like format */
             if (n <= 0)
             {
                /* Leading zero, dec.pt., digits */
                *r++ = '0';
                *r++ = DECPT;
                while (++n <= 0) *r++ = '0';
                while (*r++ = *p++) ;
             }
             else
                if (n < prc)
                {
                   /* Leading digits, dec.pt., digits */
                   while (--n >= 0) *r++ = *p++;
                   *r++ = DECPT;
                   while (*r++ = *p++) ;
                }
                else
                {
                   /* Leading digits, dec.pt. (maybe) */
                   while (*r++ = *p++) ;
                   if (fmt->alt)
                   {
                      *(r-1) = DECPT;
                      *r++ = '\0';
                   }
                }
             if ((expnt < prc) && !fmt->alt)
             {
                /* Remove trailing zeros (maybe dec.pt too) */
                --r;
                while (*--r == '0') ;
                if (*r != DECPT) r++;
                *r = '\0';
             }
          }
          else
          {
             /* 'e'-like format */

             /* One digit left of dec.pt., then dec.pt. */
             *r++ = *p++;
             *r++ = DECPT;

             /* Generate digits right of dec.pt. */
             while (*r++ = *p++) ;
             --r;
             /* Remove insignificant digits (unless '#') */
             if (!fmt->alt)
             {
                while (*--r == '0') ;
                if (*r != DECPT) r++;
             }

             /* Generate 'e' (or 'E') */
             *r++ = fmt->type - 2;

             /* Generate signed exponent */
             if ((n = expnt-1) >= 0)
                *r++ = '+';
             else
             {
                n = -n;
                *r++ = '-';
             }
             if (n >= 100)
             {
                *r++ = '0' + (n/100);
                n %= 100;
             }
             *r++ = '0' + (n/10);
             *r++ = '0' + (n%10);
             *r = '\0';
          }

          /* Right justify (unless '-' requested) */
          if (((n = fmt->width-strlen(gfmtbuf)) > 0) && !fmt->justify)
             while (--n >= 0) WRCHR(' ')

          /* Write the generated data */
          r = gfmtbuf;
          while (*r) WRCHR(*r++)

          /* Left-justify (if requested by '-') */
          while (--n >= 0) WRCHR(' ')

          /* End of 'g'-format case */
          break;
     }

#ifdef FPRINTF
     return(chrcnt);
#endif
#ifdef SPRINTF
     return(q);
#endif
}
