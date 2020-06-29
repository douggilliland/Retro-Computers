/*
     scanf.h - Common code for sscanf() and fscanf()

     This code is common to both sscanf() and fscanf() except
     for what's modified by the macros and definitions defined
     in sscanf.c and fscanf.c

     The function NXTCHR() sets the integer variable "c" to
     the value of the next character on the stream or from
     the string and returns TRUE if a character was successfully
     obtained or FALSE if a character was not successfully
     obtained.  (TRUE is defined as any-bits-on, FALSE is
     defined as zero.)
*/

/*
     Defined:
          int _sscnf()
          int _fscnf()
*/


#ifdef SSCANF
int _sscnf(string, pformat)
  char     *string;
#endif
#ifdef FSCANF
int _fscnf(stream, pformat)
  FILE     *stream;
#endif
  char    **pformat;
{
  /*
    Local declarations
  */

  struct ifmtdesc     fmt;           /* Format description */

  union                              /* Used to convert data */
  {                                  /* For %d %o %u %x formats */
       unsigned long       ul;
                long       l;
       unsigned int        ud;
                int        d;
       unsigned short      us;
                short      s;
  } val;

  ADDRREG1  char     *p;             /* Ptr into format */
#ifdef SSCANF
  ADDRREG2  char     *q;             /* Ptr into string */
#endif
  ADDRREG0  char     *r;             /* Ptr to target chars */
  ADDRREG3  char    **arg = pformat; /* Ptr to current arg ptr */
  DATAREG0  int       c;             /* Current input char */
  DATAREG1  int       d;             /* Current format char */
  DATAREG2  int       not_end;       /* Flag, char read okay */
  DATAREG3  int       no_err;        /* Flag, no error yet */
  DATAREG4  int       i;             /* General purpose counter */
            unsigned  j;             /* Multipurpose */
            unsigned  shiftcnt;      /* Shift count for %o %h */
            int       arg_cnt;       /* Number of assignments */
            char     *fmtptr;        /* Non-register char ptr */
            char     *digitstr;      /* String of digits for base */
            char      neg_flag;      /* TRUE if result negative */
            char      cbuf[256];     /* Matching char buffer */
            int       flag;          /* Non-register flag */
            int       cc;            /* Non-register character */
            char     *cp;            /* Non-register char ptr */
     


  /*
    Initializations:
      - ptr to input string (q) [if _sscnf()]
      - number of assignments (arg_cnt) (none yet)
      - ptr to format string (p)
      - no error-flag (no_err)
      - not-yet-end-of-input flag (not_end)
      - 1st char of input (c) [by NXTCHR]
      - 1st char of format (d)
      - set matching char buffer addr
  */
#ifdef SSCANF
  q = string;
#endif
  arg_cnt = 0;
  p = *arg++;
  no_err = TRUE;
  d = *p++;
  not_end = NXTCHR();
  fmt.charbuf = cbuf;

  /*
    Continue getting characters from input
    until either the format is exhausted or
    the end of input is reached or a conversion
    error is detected
  */

  while (d && no_err)
  {
    /*
      Case 1:  Whitespace character
               Read up to the next non-whitespace
    */
    if (isspace(d))
    {
      /*
        Consume all consecutive whitespace chars
        in the format-string
      */
      while (isspace(d = *p++));

      /*
        Consume all consecutive whitespace chars
        (if any) in the input-string
      */
      while (not_end && isspace(c))
        not_end = NXTCHR();
    }

    /*
      Case 2:  Format description
               Interpret data according to the format
    */
    else if (d == '%')
    {
      fmt.fmtptr = p;
      switch(_fmtin(&fmt))
      {
        /*
          'd' and 'u' formats

          Convert strings of decimal digits, either signed
          or unsigned, to their integer equivalent and assign
          the converted value to an [unsigned] int, either
          which may also be long or short
        */
      case 'd':
      case 'u':
        /*
          Consume leading white space
        */
        while (not_end && isspace(c))
          not_end = NXTCHR();

        if ((i = fmt.width) < 0)
        {
          /*
            No width specified.  Continue until an inappropriate
            character is obtained or until the end of the stream
            (string) is exhausted
          */
          if (not_end)
          {
            /*
              Handle sign
                - None permitted for 'u' format
            */
            if (fmt.type == 'u')
              neg_flag = FALSE;
            else
              if (c == '+')
              {
                /*
                  '+' sign
                */
                neg_flag = FALSE;
                no_err = not_end = NXTCHR();
              }
              else
                if (c == '-')
                {
                  /*
                    '-' sign
                  */
                  neg_flag = TRUE;
                  no_err = not_end = NXTCHR();
                }
                else
                  neg_flag = FALSE;          /* Sign omitted */

            /*
              Keep extracting digits from the stream (string)
              until an error is detected or a non-digit char
              is found.  Note that there must be at least one
              digit read from the source
            */
            if (no_err && isdigit(c))
            {
              /*
                Just consume digits if noassign ('*' switch)
                requested
              */
              if (fmt.noasgflg)
                while((not_end = NXTCHR()) && isdigit(c));
              else
              {
                /*
                  Assigning a value
                */
                val.ul = 0L;
                if (fmt.longflg)
                {
                  /*
                    'l' switch requested in the format
                    Assigning to a long [unsigned] int
                  */
                  do
                    val.ul = (val.ul * ((unsigned long) 10L)) +
                             ((unsigned long)(c & 0x0F));
                  while((not_end = NXTCHR()) && isdigit(c));
                  *(*((long **)(arg++))) = neg_flag ? -val.l : val.ul;
                }
                else if (fmt.shortflg)
                {
                  /*
                    'h' switch requested in the format
                    Assigning to a short [unsigned] int
                  */
                  do
                    val.us = (val.us * ((unsigned short) 10)) +
                             ((unsigned short)(c & 0x0F));
                  while((not_end = NXTCHR()) && isdigit(c));
                  *(*((short **)(arg++))) = neg_flag ?
                                            -val.s : val.us;
                }
                else
                {
                  /*
                    No size switches requested
                    Assigning to an [unsigned] int
                  */
                  do
                    val.ud = (val.ud * 10) + ((unsigned)(c & 0x0F));
                  while((not_end = NXTCHR()) && isdigit(c));
                  *(*((int **)(arg++))) = neg_flag ?
                                          -val.d : val.ud;
                }
                arg_cnt++;         /* Inc count of args assigned */
              }
            }
            else
              no_err = FALSE;      /* Prev error or no digits */
          }
          else
            no_err = FALSE;        /* No characters from source */
        }
        else
        {
          /*
            Explicit width requested in 'd' or 'u' format
          */
          if (fmt.width == 0)      /* Special case width of zero */
            if (fmt.noasgflg) ;    /* %*0d, %*0u do nothing */
            else
            {
              /*
                %0d %0ld %0hd %0u %0lu %0hu - Assign zero
              */
              if (fmt.longflg)
                *(*((long **)(arg++))) = 0L;      /* %0ld %0lu */
              else if (fmt.shortflg)
                *(*((short **)(arg++))) = 0;      /* %0hd %0hu */
              else
                *(*((int **)(arg++))) = 0;        /* %0d %0u */

              arg_cnt++;           /* Inc args assigned count */
            }

            else
            {
              /*
                Non-zero width requested
              */
              if (not_end)
              {
                /*
                  Handle sign
                     - None permitted for 'u' format
                */
                if (fmt.type == 'u')
                  neg_flag = FALSE;
                else
                  if (c == '+')
                  {
                    /*
                      '+' sign
                    */
                    neg_flag = FALSE;
                    not_end = NXTCHR();
                    no_err = not_end && --i;
                  }
                  else
                    if (c == '-')
                    {
                      /*
                        '-' sign
                      */
                      neg_flag = TRUE;
                      not_end = NXTCHR();
                      no_err = not_end && --i;
                    }
                    else
                      neg_flag = FALSE;           /* Default sign */

                /*
                  If no error so far and there is atleast one
                  digit, continue
                */
                if (no_err && isdigit(c))
                {
                  /*
                    If the noassignment switch is requested ('*'),
                    just consume digits until the end of the source,
                    the width is exhausted, or an inappropriate char
                    is read
                  */
                  if (fmt.noasgflg)
                    while((not_end = NXTCHR()) && --i && isdigit(c));
                  else
                  {
                    /*
                      Assigning to a value (no '*' switch)
                    */
                    val.ul = 0L;
                    if (fmt.longflg)
                    {
                      /*
                        'l' switch specified on the format
                        Assign to a long [unsigned] int
                      */
                      do
                         val.ul = (val.ul * ((unsigned long) 10L)) +
                                  ((unsigned long)(c & 0x0F));
                      while((not_end = NXTCHR()) && --i && isdigit(c));
                      *(*((long **)(arg++))) = neg_flag ?
                                               -val.l : val.ul;
                    }
                    else if (fmt.shortflg)
                    {
                      /*
                        'h' switch specified on the format
                        Assign to a short [unsigned] int
                      */
                      do
                        val.us = (val.us * ((unsigned short) 10)) +
                                 ((unsigned short)(c & 0x0F));
                      while((not_end = NXTCHR()) && --i && isdigit(c));
                      *(*((short **)(arg++))) = neg_flag ?
                                                -val.s : val.us;
                    }
                    else
                    {
                      /*
                        No data-type size switch specified
                        Assign to an [unsigned] int
                      */
                      do
                        val.ud = (val.ud * 10) +
                                 ((unsigned int)(c & 0x0F));
                      while((not_end = NXTCHR()) && --i && isdigit(c));
                      *(*((int **)(arg++))) = neg_flag ?
                                              -val.d : val.ud;
                    }
                    arg_cnt++;     /* Bump the args assigned count */
                  }
                }
                else
                  no_err = FALSE;  /* No digits seen or prev error */
              }
              else
                no_err = FALSE;    /* No chars from source */
            }
        }

        break;                     /* End of 'd' and 'u' cases */


      /*
        'x' and 'o' formats

        Converting (possibly signed) strings of hexadecimal or
        octal digits to their equivalent in [unsigned] int,
        either short or long
      */
      case 'x':
      case 'o':

        /*
          Set up shift count and digits string for the
          formats
        */
        if (fmt.type == 'x')
        {
          digitstr = "0123456789ABCDEFabcdef";
          shiftcnt = 4;
        }
        else /* fmt.type == 'o' */
        {
          digitstr = "01234567";
          shiftcnt = 3;
        }

        /*
          Consume leading white space
        */
        while (not_end && isspace(c))
          not_end = NXTCHR();

        if ((i = fmt.width) < 0)
        {
          /*
            No width specified.  Continue until an inappropriate
            character is obtained or until the end of the stream
            (string) is exhausted
          */
          if (not_end)
          {
            /*
              Handle sign
            */
            if (c == '+')
            {
              /*
                '+' sign
              */
              neg_flag = FALSE;
              no_err = not_end = NXTCHR();
            }
            else
              if (c == '-')
              {
                /*
                  '-' sign
                */
                neg_flag = TRUE;
                no_err = not_end = NXTCHR();
              }
              else
                neg_flag = FALSE;          /* Sign omitted */

            /*
              Keep extracting digits from the stream (string)
              until an error is detected or a non-digit char
              is found.  Note that there must be at least one
              digit read from the source
            */
            if (no_err && ((r=strchr(digitstr, c)) != NULL))
            {
              /*
                Just consume digits if noassign ('*' switch)
                requested
              */
              if (fmt.noasgflg)
                while((not_end = NXTCHR()) &&
                      (strchr(digitstr, c) != NULL));
              else
              {
                /*
                  Assigning a value
                */
                val.ul = 0L;
                if (fmt.longflg)
                {
                  /*
                    'l' switch requested in the format
                    Assigning to a long [unsigned] int
                  */
                  do
                  {
                    val.ul <<= shiftcnt;
                    if ((j = r - digitstr) >= 16) j -= 6;
                    val.ul += (unsigned long) j;
                  }
                  while((not_end = NXTCHR()) &&
                        ((r=strchr(digitstr, c)) != NULL));
                  *(*((long **)(arg++))) = neg_flag ? -val.l : val.ul;
                }
                else if (fmt.shortflg)
                {
                  /*
                    'h' switch requested in the format
                    Assigning to a short [unsigned] int
                  */
                  do
                  {
                    val.us <<= shiftcnt;
                    if ((i = r - digitstr) >= 16) i -= 6;
                    val.us += (unsigned short) i;
                  }
                  while((not_end = NXTCHR()) &&
                        ((r=strchr(digitstr, c)) != NULL));
                  *(*((short **)(arg++))) = neg_flag ?
                                            -val.s : val.us;
                }
                else
                {
                  /*
                    No size switches requested
                    Assigning to an [unsigned] int
                  */
                  do
                  {
                    val.ud <<= shiftcnt;
                    if ((i = r - digitstr) >= 16) i -= 6;
                    val.ud += i;
                  }
                  while((not_end = NXTCHR()) &&
                        ((r=strchr(digitstr, c)) != NULL));
                  *(*((int **)(arg++))) = neg_flag ?
                                          -val.d : val.ud;
                }
                arg_cnt++;         /* Inc count of args assigned */
              }
            }
            else
              no_err = FALSE;      /* Prev error or no digits */
          }
          else
            no_err = FALSE;        /* No characters from source */
        }
        else
        {
          /*
            Explicit width requested in 'x' or 'o' format
          */
          if (fmt.width == 0)      /* Special case width of zero */
            if (fmt.noasgflg) ;    /* %*0x, %*0o do nothing */
            else
            {
              /*
                %0x %0lx %0hx %0o %0lo %0ho - Assign zero
              */
              if (fmt.longflg)
                *(*((long **)(arg++))) = 0L;      /* %0lx %0lo */
              else if (fmt.shortflg)
                *(*((short **)(arg++))) = 0;      /* %0hx %0ho */
              else
                *(*((int **)(arg++))) = 0;        /* %0x %0o */

              arg_cnt++;           /* Inc args assigned count */
            }

            else
            {
              /*
                Non-zero width requested
              */
              if (not_end)
              {
                if (c == '+')
                {
                  /*
                    '+' sign
                  */
                  neg_flag = FALSE;
                  not_end = NXTCHR();
                  no_err = not_end && --i;
                }
                else
                  if (c == '-')
                  {
                    /*
                      '-' sign
                    */
                    neg_flag = TRUE;
                    not_end = NXTCHR();
                    no_err = not_end && --i;
                  }
                  else
                    neg_flag = FALSE;           /* Default sign */

                /*
                  If no error so far and there is atleast one
                  digit, continue
                */
                if (no_err && ((r=strchr(digitstr, c)) != NULL))
                {
                  /*
                    If the noassignment switch is requested ('*'),
                    just consume digits until the end of the source,
                    the width is exhausted, or an inappropriate char
                    is read
                  */
                  if (fmt.noasgflg)
                    while((not_end = NXTCHR()) && --i &&
                          (strchr(digitstr, c) != NULL));
                  else
                  {
                    /*
                      Assigning to a value (no '*' switch)
                    */
                    val.ul = 0L;
                    if (fmt.longflg)
                    {
                      /*
                        'l' switch specified on the format
                        Assign to a long [unsigned] int
                      */
                      do
                      {
                        val.ul <<= shiftcnt;
                        if ((j = r - digitstr) >= 16) j -= 6;
                        val.ul += (unsigned long) j;
                      }
                      while((not_end = NXTCHR()) && --i &&
                            ((r = strchr(digitstr, c)) != NULL));
                      *(*((long **)(arg++))) = neg_flag ?
                                               -val.l : val.ul;
                    }
                    else if (fmt.shortflg)
                    {
                      /*
                        'h' switch specified on the format
                        Assign to a short [unsigned] int
                      */
                      do
                      {
                        val.us <<= shiftcnt;
                        if ((j = r - digitstr) >= 16) j -= 6;
                        val.us += (unsigned short) j;
                      }
                      while((not_end = NXTCHR()) && --i &&
                            ((r = strchr(digitstr, c)) != NULL));
                      *(*((short **)(arg++))) = neg_flag ?
                                                -val.s : val.us;
                    }
                    else
                    {
                      /*
                        No data-type size switch specified
                        Assign to an [unsigned] int
                      */
                      do
                      {
                        val.ud <<= shiftcnt;
                        if ((j = r - digitstr) >= 16) j -= 6;
                        val.ud += j;
                      }
                      while((not_end = NXTCHR()) && --i &&
                            ((r = strchr(digitstr, c)) != NULL));
                      *(*((int **)(arg++))) = neg_flag ?
                                              -val.d : val.ud;
                    }
                    arg_cnt++;     /* Bump the args assigned count */
                  }
                }
                else
                  no_err = FALSE;  /* No digits seen or prev error */
              }
              else
                no_err = FALSE;    /* No chars from source */
            }
        }

        break;                     /* End of 'x' and 'o' cases */


      /*
        's' format
            String assignment.
      */
      case 's':
        /*
          Set up argument
        */
        if (!fmt.noasgflg)
          r = *arg++;

        /*
          Eat leading whitespace
        */
        while (not_end && isspace(c))
          not_end = NXTCHR();

        if (not_end)
        {
          /*
            Assign string
          */
          if ((i = fmt.width) < 0)
            do
              if (!fmt.noasgflg) *r++ = c;
            while ((not_end = NXTCHR()) && !isspace(c));
          else
            if (i > 0)
              do
                if (!fmt.noasgflg) *r++ = c;
              while ((not_end = NXTCHR()) && !isspace(c) && --i);

          /*
            Null-terminate the string and count the argument
          */
          if (!fmt.noasgflg)
          {
            *r = '\0';
            arg_cnt++;
          }
        }
        else
          if (fmt.width == 0)
            if (fmt.noasgflg) ;
            else
            {
              *r = '\0';
              arg_cnt++;
            }
          else no_err = FALSE;
        break;

      /*
        'c' format
            Fetch a single character or <width> chars
            if specified
      */
      case 'c':
        if (!fmt.noasgflg)
          r = *arg++;
        if (not_end)
        {
          if ((i = fmt.width) < 0)
          {
            if (!fmt.noasgflg) *r = c;
            not_end = NXTCHR();
          }
          else
            while (i--)
            {
              if (!fmt.noasgflg) *r++ = c;
              if (!(not_end = NXTCHR())) break;
            }
          if (!fmt.noasgflg) arg_cnt++;
        }
        else
          if (no_err = (fmt.width == 0))
            if (!fmt.noasgflg) arg_cnt++;
        break;

      /*
        '%' format
            The next character must be a '%'
            Width field is ignored
      */
      case '%':
        if (not_end)
          if (c == '%')
          {
            d = *p++;
            not_end = NXTCHR();
          }
          else no_err = FALSE;
        else no_err = FALSE;
        break;

      /*
        "%[" format
        Match character list
          - Format does not consume leading spaces
      */
      case '[':

        /*
          Set up and consume argument (if any)
        */
        if (!fmt.noasgflg)
          r = *arg++;

        if ((i = fmt.width) < 0)
          if (not_end && fmt.charbuf[c])
            if (fmt.noasgflg)
              while ((not_end = NXTCHR()) && fmt.charbuf[c]);
            else
            {
              do
                *r++ = c;
              while ((not_end = NXTCHR()) && fmt.charbuf[c]);
              *r = '\0';
              arg_cnt++;
            }
          else
            no_err = FALSE;

        else
          if (fmt.width == 0)
          {
            if (!fmt.noasgflg)
            {
              *r = '\0';
              arg_cnt++;
            }
          }
          else
            if (not_end && fmt.charbuf[c])
              if (fmt.noasgflg)
                while ((not_end = NXTCHR()) && --i && fmt.charbuf[c]);
              else
              {
                do
                  *r++ = c;
                while ((not_end = NXTCHR()) && --i && fmt.charbuf[c]);
                *r = '\0';
                arg_cnt++;
              }
            else no_err = FALSE;

        break;      /* End of %[ case */


      case 'E':
      case 'F':
      case 'G':
        fmt.longflg = !fmt.shortflg;
        fmt.shortflg = FALSE;


      case 'e':
      case 'f':
      case 'g':
        flag = not_end;
        cc = c;
#ifdef FSCANF
        no_err = _fscnfp(stream, fmt.noasgflg?NULL:*arg++, &fmt,
                         &flag, &cc);
#endif
#ifdef SSCANF
        cp = q;
        no_err = _sscnfp(&cp, fmt.noasgflg?NULL:*arg++, &fmt,
                         &flag, &cc);
        q = cp;
#endif
        not_end = flag;
        c = cc;
        if (no_err && !fmt.noasgflg) arg_cnt++;
        break;


      /*
        Unknown (or unsupported) format type
        Just set the error flag
      */
      default:
        no_err = FALSE;
      }

      /*
        Update pointer to format string and get
        the next character
      */
      p = fmt.ptr;
      d = *p++;

    } /* End of '%' (format item) case */

    /*
      Case 3:  Match a character
               The next character in the input
               list must match the character in
               the format
    */
    else
      if (not_end)
        if (d == c)
        {
          /* Match */
          d = *p++;
          not_end = NXTCHR();
        }
        else no_err = FALSE;
     else no_err = FALSE;

  } /* END while() */

  /*
    Push the last character read from the input
    stream back onto the stream since it has not
    been consumed yet (only if this is _fscnf()).
    Note that ungetc() does nothing if the character
    being pushed back is EOF.
  */

#ifdef FSCANF
  ungetc(c, stream);
#endif


  /*
    Return the number of assignments or EOF if
    none and there was an error
  */

  if ((arg_cnt == 0) && (!no_err || (!not_end && d)))
    arg_cnt = EOF;

  return(arg_cnt);
}
