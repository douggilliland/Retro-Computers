#ifdef SPRINTF
int _sprtf(string, pargs)
               char     *string;
#endif
#ifdef FPRINTF
int _fprtf(stream, pargs)
               FILE     *stream;
#endif
               char    **pargs;
{
#ifdef SPRINTF
     ADDRREG1  char     *q = string;
#endif
     ADDRREG0  char     *p;
     ADDRREG2  char     *f;
#ifdef FPRINTF
     DATAREG0  int       chrcnt = 0;
#endif
     ADDRREG3  char     *arg;
               char     *argptr;
     DATAREG1  int       i;
     DATAREG2  int       j;
     DATAREG3  int       c;
     DATAREG4  int       k;
     DATAREG5  int       l;

               char     *ff;
               int      *psignflg;
               int       signflg;
               int       base;
               char     *digits;

     struct    ofmtdesc  fmt;

               char     *_ltostr();
               char     *_itostr();
               int       _fmtout();

#ifdef SPRINTF
               char     *_sprtfp();
#endif
#ifdef FPRINTF
               int       _fprtfp();
#endif


     f = *pargs++;
     arg = (char *) pargs;

     while (c = *f++)
          if (c != '%') WRCHR(c)
          else
          {
               fmt.fmtptr = f;
               switch(_fmtout(&fmt))
               {
               case 'd':           /* 'd', signed decimal */
                    psignflg = &signflg;
                    base = 10;
                    i = 0;
                    goto dou;

               case 'u':           /* 'u', unsigned decimal */
                    psignflg = NULL;
                    base = 10;
                    i = 0;
                    goto dou;

               case 'o':           /* 'o', unsigned octal */
                    psignflg = NULL;
                    base = 8;
                    i = fmt.alt ? 1 : 0;
                    goto dou;

               case 'x':           /* 'x', unsigned hexadecimal */
                    digits = "0123456789abcdef";
                    goto xX;

               case 'X':           /* 'X', unsigned hexadecimal */
                    digits = "0123456789ABCDEF";
               xX:                 /* Common code, x X */
                    psignflg = NULL;
                    base = 16;
                    i = 0;
                    if (fmt.alt)
                         if (fmt.longflg)
                              if (*((long *) arg) != 0) i = 2;
                              else fmt.alt = FALSE;
                         else if (*((int *) arg) != 0) i = 2;
                              else fmt.alt = FALSE;
                    goto douxX;

               dou:               /* Common code, d o u */
                    digits = "0123456789";

               douxX:              /* Common code, d o u x X */

                    /*
                         Fetch variable width and precision
                    */
                    if (fmt.varwidth)
                    {
                         fmt.width = *((int *)arg);
                         arg += sizeof(int);
                    }
                    if (fmt.varprecn)
                    {
                         fmt.precn = *((int *)arg);
                         arg += sizeof(int);
                    }

                    /*
                         Generate an unsigned character string in
                         the requested base representing the
                         absolute value of the argument
                    */
                    if (fmt.longflg)
                    {
                         p = _ltostr(*((long *) arg), base, digits, psignflg);
                         arg += sizeof(long);
                    }
                    else
                    {
                         p = _itostr(*((int *) arg), base, digits, psignflg);
                         arg += sizeof(int);
                    }

                    /*
                         Special case:  if precision == 0 and the
                         argument is zero, the result must be a
                         null string
                    */
                    if ((*p == '0') && (fmt.precn == 0)) p++;

                    /*
                         Determine the number of padding spaces
                         needed (l) and the number of leading
                         zeroes needed (k)
                    */
                    j = strlen(p);
                    if ((k = fmt.precn - j) < 0) k = 0;
                    if ((fmt.type == 'd') &&
                        (signflg || fmt.signed || fmt.blsign))
                         i++;
                    if ((l = fmt.width - i - j - k) < 0) l = 0;

                    /*
                         Left justify unless otherwise requested
                    */
                    if (!fmt.justify)
                         while (l--)
                              WRCHR(' ')

                    /*
                         Write the sign if signed ('d' only)
                    */
                    if (psignflg != (int *) NULL)
                         if (signflg) WRCHR('-')
                         else if (fmt.signed) WRCHR('+')
                              else if (fmt.blsign) WRCHR(' ')

                    /*
                         Handle alternate format
                            - Leading '0' if 'o',
                            - Leading "0x" if 'x',
                            - Leading "0X" if 'X'
                    */
                    if (fmt.alt)
                         switch(fmt.type)
                         {
                         case 'o':
                              WRCHR('0')
                              break;
                         case 'x':
                              WRCHR('0')
                              WRCHR('x')
                              break;
                         case 'X':
                              WRCHR('0')
                              WRCHR('X')
                              break;
                         }

                    /*
                         Generate leading zeroes
                    */
                    if (k > 0)
                         while (k--) WRCHR('0')

                    /*
                         Write digits
                    */
                    if (j > 0)
                         while (c = *p++) WRCHR(c)

                    /*
                         Left-justify if requested
                    */
                    if (fmt.justify)
                         while (l--) WRCHR(' ')

                    break;  /* End of 'd' 'o' 'u' 'x' 'X' */


               case 'c':           /* 'c', character */

                    /*
                         Fetch variable width and precision
                    */
                    if (fmt.varwidth)
                    {
                         fmt.width = *((int *)arg);
                         arg += sizeof(int);
                    }
                    if (fmt.varprecn)
                    {
                         fmt.precn = *((int *)arg);
                         arg += sizeof(int);
                    }

                    /*
                         Get the character and advance the
                         argument pointer
                    */
                    c = *((int *) arg);
                    arg += sizeof(int);
                    i = (fmt.width > 1) ? fmt.width-1 : 0;

                    /*
                         Right justify within the field
                    */
                    if ((i > 0) && !fmt.justify)
                         while (i--)
                              WRCHR(' ')

                    /*
                         Write the character
                    */
                    WRCHR(c)

                    /*
                         Left justify if requested
                    */
                    if (fmt.justify)
                         while (i--)
                              WRCHR(' ')
                    break;

               case 's':           /* 's', string of characters */

                    /*
                         Fetch variable width and precision
                    */
                    if (fmt.varwidth)
                    {
                         fmt.width = *((int *)arg);
                         arg += sizeof(int);
                    }
                    if (fmt.varprecn)
                    {
                         fmt.precn = *((int *)arg);
                         arg += sizeof(int);
                    }

                    /*
                         Get the address of the string of chars
                         and advance the argument pointer
                    */
                    p = *((char **) arg);
                    arg += sizeof(char *);

                    /*
                         Calculate
                            - # chars to put from arg (i)
                            - # chars in the field (j)
                    */
                    k = strlen(p);
                    i = (fmt.precn < 0) ? k :
                        (fmt.precn < k) ? fmt.precn : k;
                    j = (fmt.width < i) ? i : fmt.width;

                    /*
                         Right justify
                    */
                    if (((k = j - i) > 0) && !fmt.justify)
                         while (k--)
                              WRCHR(' ')

                    /*
                         Write the string of characters
                    */
                    if (p != (char *) NULL)
                         while (i--)
                              WRCHR(*p++)

                    /*
                         Left justify if requested
                    */
                    if (k > 0)
                         while (k--)
                              WRCHR(' ')
                    break;  /* End of case 's' */

               case '%':           /* '%', write a '%' character */

                    /*
                         Fetch variable width and precision
                    */
                    if (fmt.varwidth)
                    {
                         fmt.width = *((int *)arg);
                         arg += sizeof(int);
                    }
                    if (fmt.varprecn)
                    {
                         fmt.precn = *((int *)arg);
                         arg += sizeof(int);
                    }

                    WRCHR('%')
                    break;

               case NULL:          /* '%' ending the format string */
                    break;

               case 'e':           /* 'e', exponent format */
               case 'E':           /* 'E', exponent format */
               case 'f':           /* 'f', decimal format */
               case 'g':           /* 'g', floating-point */
               case 'G':           /* 'G', floating-point */

                    /*
                         Fetch variable width and precision
                    */
                    if (fmt.varwidth)
                    {
                         fmt.width = *((int *)arg);
                         arg += sizeof(int);
                    }
                    if (fmt.varprecn)
                    {
                         fmt.precn = *((int *)arg);
                         arg += sizeof(int);
                    }

                    /*
                         Generate and write characters from
                         the floating-point value on the
                         stack and write to the appropriate
                         place
                    */
                    argptr = arg;
#ifdef FPRINTF
                    chrcnt += _fprtfp(stream, &fmt, &argptr);
#endif
#ifdef SPRINTF
                    q = _sprtfp(q, &fmt, &argptr);
#endif
                    arg = argptr;
                    break;

               /*
                    For unknown (and unimplemented format
                    types), just write the format description
                    as though it were a character string
               */
               default:            /* Unknown format */
                    i = fmt.ptr - (p = fmt.fmtptr);
                    while (i--)
                         WRCHR(*p++)
                    break;
               }
               f = fmt.ptr;
          }

          /*
               End code.  Null-terminate the generated string
               and return the length of the generated string
          */
#ifdef SPRINTF
          *q = '\0';
          return(q-string);
#endif
#ifdef FPRINTF
          return(ferror(stream) ? -1 : chrcnt);
#endif
}
