#ifdef FSCANF
int _fscnfp(stream, pval, fmt, pendflg, pchar)
     ADDRREG2  FILE              *stream;
#endif
#ifdef SSCANF
int _sscnfp(pstring, pval, fmt, pendflg, pchar)
               char             **pstring;
#endif
               double            *pval;
     ADDRREG1  struct ifmtdesc   *fmt;
               int               *pendflg;
               int               *pchar;
{
               char               strbuf[256];
     ADDRREG0  char              *p = strbuf;
#ifdef SSCANF
     ADDRREG2  char              *q = *pstring;
#endif
     DATAREG0  int                c;
     DATAREG1  int                not_end;
     DATAREG2  int                no_err;
     DATAREG3  int                i;
               int                bucount;

     double    atof();

     not_end = *pendflg;
     c = *pchar;
     /*
        Skip leading white-space (not included in the
        explicit field-width, if any)
     */
     while (not_end && isspace(c))
       not_end = NXTCHR();

     /*
        Two cases:
         - No explicit field width in the field description
         - The field description contains an explicit field width
     */
     if ((i = fmt->width) < 0)
     {
       /* Field has no explicit width */

       if (not_end)
       {
         /* Extract the sign, if any */
         if ((c == '-') || (c == '+'))
         {
           *p++ = c;
           no_err = not_end = NXTCHR();
         }

         /*
            Extract the mantissa, two cases:
               ddddd[.[ddddd]], or
               .ddddd
         */
         if (not_end && isdigit(c))
         {
           /*
              First case:  ddddd[.[ddddd]]
              Extract digits left of dec.pt.
           */
           do
             *p++ = c;
           while ((not_end = NXTCHR()) && isdigit(c));

           /*
              Extract dec.pt. (if any) 
              and following digits (if any)
           */
           if (not_end && (c == DECPT))
             do
               *p++ = c;
             while ((not_end = NXTCHR()) && isdigit(c));
         }
         else

           /*
              Second case:  .ddddd
              Extract the decimal point (required)
              and the digits following the dec.pt (1 req'd)
           */
           if (no_err = (not_end && (c == DECPT)))
           {
             *p++ = c;
             if ((no_err = not_end = NXTCHR()) && 
                 (no_err = isdigit(c)))
               do
                 *p++ = c;
               while ((not_end = NXTCHR()) && isdigit(c));
           }

         /* 
            Extract the exponent field, if any.
            Since we don't look ahead more than one char,
            we accept an 'e' or 'E' char even if it isn't
            followed by an optionally signed string of digits
         */
         if (not_end && no_err && (toupper(c) == 'E'))
         {
           *p++ = c;
           bucount = 1;    /* Count 'E' */
           if ((not_end = NXTCHR()) && ((c == '-') || (c == '+')))
           {
             *p++ = c;
             bucount = 2;  /* Count 'E' and sign */
             not_end = NXTCHR();
           }
           if (not_end && isdigit(c))
             do
               *p++ = c;
             while ((not_end = NXTCHR()) && isdigit(c));
           else p -= bucount;   /* Forget 'E' and sign if any */
         }
       }
       else
         no_err = FALSE;
     }
     else
     {
       /* Field has an explicit width */

       if (not_end && (i > 0))
       {
         /* Extract the sign, if any */
         if ((c == '-') || (c == '+'))
         {
           *p++ = c;
           no_err = ((not_end = NXTCHR()) && (--i > 0));
         }

         /*
            Extract the mantissa, two cases:
               ddddd[.[ddddd]], or
               .ddddd
         */
         if (not_end && (i > 0) && isdigit(c))
         {
           /*
              First case:  ddddd[.[ddddd]]
              Extract digits left of dec.pt.
           */
           do
             *p++ = c;
           while ((not_end = NXTCHR()) && (--i > 0) && isdigit(c));

           /*
              Extract dec.pt. (if any) 
              and following digits (if any)
           */
           if (not_end && (i > 0) && (c == DECPT))
             do
               *p++ = c;
             while ((not_end = NXTCHR()) && (--i > 0) && isdigit(c));
         }
         else

           /*
              Second case:  .ddddd
              Extract the decimal point (required)
              and the digits following the dec.pt (1 req'd)
           */
           if (no_err = (not_end && (i > 0) && (c == DECPT)))
           {
             *p++ = c;
             if ((no_err = not_end = NXTCHR()) && 
                 (no_err = ((--i > 0) && isdigit(c))))
               do
                 *p++ = c;
               while ((not_end = NXTCHR()) && 
                      (--i > 0) && isdigit(c));
           }

         /* 
            Extract the exponent field, if any.
            Since we don't look ahead more than one char,
            we accept an 'e' or 'E' char even if it isn't
            followed by an optionally signed string of digits
         */
         if (not_end && no_err && (i > 0) && (toupper(c) == 'E'))
         {
           *p++ = c;
           bucount = 1;    /* Count 'E' */
           if ((not_end = NXTCHR()) &&
               (--i > 0) && ((c == '-') || (c == '+')))
           {
             *p++ = c;
             bucount = 2;  /* Count 'E' and sign */
             not_end = NXTCHR();
             --i;
           }
           if (not_end && (i > 0) && isdigit(c))
             do
               *p++ = c;
             while ((not_end = NXTCHR()) && (--i > 0) && isdigit(c));
           else p -= bucount;   /* Forget 'E' and sign if any */
         }
       }
       else
         no_err = FALSE;
     }


     /* Assign the scanned value to the target (if any) */
     if (no_err && !fmt->noasgflg)
     {
       *p = '\0';
       if (fmt->longflg)
         *pval = atof(strbuf);
       else 
         *((float *) pval) = (float) atof(strbuf);
     }

#ifdef SSCANF
     *pstring = q;
#endif
     *pchar = c;
     *pendflg = not_end;
     return(no_err);
}
