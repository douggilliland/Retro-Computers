/*
  perror.c - Standard error message handling routines
             and data

  Includes:

       char     *sys_errlist[];      Ptrs to messages
       int       sys_nerr;           Max error number
       void      perror();           Write error message
       void      _ierrmsg();         Non-standard init tables
*/


/*
  Standard definitions
*/

#include  "machine.h"
#include  <stdio.h>


/*
  Local definitions
     MAXERR     Max number of errors in system error file
                (Used to allocate space for sys_errmsg[])
     ERRFILE    Name of system error message file
     NOMSG      Default error message (if none)
     LOCALMIN   Minimum error number for local error message
     GENERMIN   Minimum error number for general error message
     LCLEFILE   Name of local error message file
     MXMSGSIZ   Maximum message size
     GENEFILE   Generic filename for general error files
                (for XXXX use 4 digit, (errno-GENERMIN)/256))
*/

#define   MAXERR         100
#define   ERRFILE        "/gen/errors/system"
#define   NOMSG          "No message for errno = "
#define   LOCALMIN       512
#define   GENERMIN       1024
#define   LCLEFILE       "/gen/errors/local"
#define   MXMSGSIZ       128
#define   GENEFILE       "/gen/errors/errorfileXXXX"


/*
  Global data (accessable by the world)
*/

  char     *sys_errlist[MAXERR];
  int       sys_nerr = -1;


/*
  void _ierrmsg()

       This function initializes the data used to print
       error messages by "perror()".  This includes
       "sys_errlist", a list of pointers to character-
       strings (the error messages) and "sys_nerr",
       the maximum error number.

       This function must be called before any reference
       to the global data containing error-message info.

  Arguments:  NONE

  Returns:  void

  Notes:
     - "sys_nerr" will be unchanged if this routine had
       a problem initializing the error-message data.
       Initially, "sys_nerr" is -1.

  Routine History:
       08/15/84 kpm - New
*/

void _ierrmsg()
{
  ADDRREG1  FILE     *errfp1;        /* ptr to 1st open of ERRFILE */
  ADDRREG2  FILE     *errfp2;        /* ptr to 2nd open of ERRFILE */
  ADDRREG0  char     *bufptr;        /* alloc'd buffer pointer */
  ADDRREG3  char    **arrayptr;      /* Ptr into sys_errlist[] */
  DATAREG0  int       posstr1;       /* offset to 1st string */
  DATAREG1  int       ptrof;         /* offset into file */
  DATAREG2  int       nbytes;        /* # bytes needed for strings */
  DATAREG3  int       noerror;       /* FLAG indicating error */
  DATAREG4  int       nslots;        /* Slot counter */
            short     shortint;      /* multiuse non-reg short */

  /*
    Open the error message file and read the first
    entry's offset (indicates where the offsets end
    and the messages begin  --  the message for
    error #0 is required!)
  */
  if (((errfp1 = fopen(ERRFILE, "r")) != NULL) &&
      (fread(&shortint, sizeof(short), 1, errfp1) == 1) &&
      (shortint > 0))
  {
    /*
      Open the error message file again (this instance
      will be used to access the messages, the first
      to access the offsets to the messages)
    */
    if ((errfp2 = fopen(ERRFILE, "r")) != NULL)
    {
      /*
        First pass through the file -- determine the size
        of the buffer needed to contain all of the error
        messages.  For each non-zero offset, sum the lengths
        of the strings the offsets reference
      */
      posstr1 = shortint;
      ptrof = 0;
      nbytes = 0;
      nslots = 0;
      noerror = TRUE;
      while((ptrof < posstr1) && noerror)
      {
        if (shortint != 0)
          if ((fseek(errfp2, (long) shortint, 0) == 0) &&
              (fread(&shortint, sizeof(short), 1, errfp2) == 1))
            nbytes += shortint;
          else noerror = FALSE;
        if (noerror)
          if (fread(&shortint, sizeof(short), 1, errfp1) == 1)
          {
            ptrof += sizeof(short);
            nslots++;
          }
          else noerror = FALSE;
      }
      if (noerror &&
          ((bufptr = malloc(nbytes)) != NULL))
      {
        /*
          Second pass through the file.  For each non-zero
          offset, read the string into the allocated buffer,
          setting the string address in the appropriate bin
          in "sys_errmsg" location
        */
        rewind(errfp1);
        arrayptr = sys_errlist;
        while (noerror && (--nslots >= 0) &&
               (fread(&shortint, sizeof(short), 1, errfp1) == 1))
          if (shortint != 0)
            if ((fseek(errfp2, (long) shortint, 0) == 0) &&
                (fread(&shortint, sizeof(short), 1, errfp2) == 1) &&
                (fread(bufptr, shortint, 1, errfp2) == 1))
            {
              *arrayptr++ = bufptr;
              bufptr += shortint;
            }
            else
              noerror = FALSE;       /* Some error */
          else
            *arrayptr++ = NULL;      /* No message for code */

        /*
          Calculate maximum error code for which we have
          messages
        */
        sys_nerr = (arrayptr - sys_errlist) - 1;
      }
      fclose(errfp2);      /* Close 2nd instance of errmsg file */
    }
    fclose(errfp1);   /* Close 1st instance of errmsg file */
  }
}


/*
  void perror(s)
       char     *s;

       This function writes the character-string
       referenced by <s> to stderr, followed by
       a colon then a space, followed by a message
       dependent upon the value of "errno", followed
       by an EOL character.  <s> is not written and
       the colon and space are suppressed if <s> is
       ((char *) NULL).

  Arguments:
       s         char *
                 References the char-string to be written
                 or NULL if none

  Returns:  void

  Notes:
     - Calls "_ierrmsg()" to initialize the error message
       buffers.

  Routine History:
       08/15/84 kpm - New
*/

void perror(s)
  ADDRREG1  char     *s;
{
  ADDRREG0  char     *p;
            int       signflag;
            short     shortint;
  ADDRREG2  FILE     *lclfd;
            char      msgbuf[MXMSGSIZ];
            char      flnambuf[sizeof(GENEFILE)];
  DATAREG0  int       errnum;
  DATAREG1  int       errvalue;
  DATAREG2  int       errclass;
  ADDRREG3  char     *q;


  /*
     Remember the error number in case perror() generates
     an error
  */
  errnum = errno;

  /*
       Initialize the message strings if necessary
  */
  if (sys_nerr < 0) _ierrmsg();

  /*
       Write the user's error message (if any)
  */
  if (s != NULL)
  {
       fputs(s, stderr);
       fputs(": ", stderr);
  }

  if (errnum < LOCALMIN)
  {
       /*
            If there's an error message for the current "errno",
            put the message, else put the default message
       */
       if ((errnum >= 0) &&
           (errnum <= sys_nerr) &&
           ((p = sys_errlist[errnum]) != NULL)) fputs(p, stderr);
       else
       {
            fputs(NOMSG, stderr);
            p = _itostr(errnum, 10, "0123456789", &signflag);
            if (signflag) fputc('-', stderr);
            fputs(p, stderr);
       }
  }
  else
  {
       p = NULL;
       if (errnum < GENERMIN)
       {
          errvalue = errnum - LOCALMIN;
          lclfd = fopen(LCLEFILE, "r");
       }
       else
       {
          errvalue = errnum % 256;
          errclass = (errnum-GENERMIN) / 256;
          strcpy(flnambuf, GENEFILE);
          q = &flnambuf[sizeof(flnambuf)-2];
          *q = '0' + (errclass % 10);
          *--q = '0' + ((errclass /= 10) % 10);
          *--q = '0' + ((errclass /= 10) % 10);
          *--q = '0' + ((errclass /= 10) % 10);
          lclfd = fopen(flnambuf, "r");
       }
       if (lclfd != (FILE *) NULL)
       {
         if ((fread(&shortint, sizeof(short), 1, lclfd) == 1) &&
             (shortint != 0) &&
             ((errvalue *= 2) < shortint) &&
             (fseek(lclfd, (long) errvalue, 0) == 0) &&
             (fread(&shortint, sizeof(short), 1, lclfd) == 1) &&
             (fseek(lclfd, (long) shortint, 0) == 0) &&
             (fread(&shortint, sizeof(short), 1, lclfd) == 1) &&
             (shortint <= MXMSGSIZ) &&
             (fread(msgbuf, 1, shortint, lclfd) > 0))
         {
           p = msgbuf;
           msgbuf[shortint] = '\0';
         }
         fclose(lclfd);
       }
       if (p != NULL) fputs(p, stderr);
       else
       {
            fputs(NOMSG, stderr);
            p = _itostr(errnum, 10, "0123456789", &signflag);
            if (signflag) fputc('-', stderr);
            fputs(p, stderr);
       }
  }

  /*
       Terminate the message with a EOL character
  */
  fputc(EOL, stderr);
}

/*
  char *strerror(n)
       int n;

       This function returns the character string
       error message associated with the integer n.

  Arguments:
      n          int
                 The error number to be used.

  Returns:  char *

  Notes:
     - Calls "_ierrmsg()" to initialize the error message
       buffers.

  Routine History:
       08/15/84 ljn - New
*/

char *
strerror(n)
DATAREG0 int n;
{
  ADDRREG0  char     *p;
            int       signflag;
            short     shortint;
  ADDRREG1  FILE     *lclfd;
            char      msgbuf[MXMSGSIZ];
            char      flnambuf[sizeof(GENEFILE)];
  DATAREG1  int       errvalue;
  DATAREG2  int       errclass;
  ADDRREG2  char     *q;


  /*
       Initialize the message strings if necessary
  */
  if (sys_nerr < 0) _ierrmsg();

  if (n < LOCALMIN)
  {
       /*
            If there's an error message for "n" return that msg.
       */
       if ((n >= 0) && (n <= sys_nerr) && (p = sys_errlist[n]))
          return(p);

       strcpy(msgbuf,NOMSG);
       p = _itostr(n, 10, "0123456789", &signflag);
       if (signflag)
          strcat(msgbuf,"-");
       strcat(msgbuf,p);
       return(msgbuf);
  }
  else
  {
       p = NULL;
       if (n < GENERMIN)
       {
          errvalue = n - LOCALMIN;
          lclfd = fopen(LCLEFILE, "r");
       }
       else
       {
          errvalue = n % 256;
          errclass = (n-GENERMIN) / 256;
          strcpy(flnambuf, GENEFILE);
          q = &flnambuf[sizeof(flnambuf)-2];
          *q = '0' + (errclass % 10);
          *--q = '0' + ((errclass /= 10) % 10);
          *--q = '0' + ((errclass /= 10) % 10);
          *--q = '0' + ((errclass /= 10) % 10);
          lclfd = fopen(flnambuf, "r");
       }
       if (lclfd != (FILE *) NULL)
       {
         if ((fread(&shortint, sizeof(short), 1, lclfd) == 1) &&
             (shortint != 0) &&
             ((errvalue *= 2) < shortint) &&
             (fseek(lclfd, (long) errvalue, 0) == 0) &&
             (fread(&shortint, sizeof(short), 1, lclfd) == 1) &&
             (fseek(lclfd, (long) shortint, 0) == 0) &&
             (fread(&shortint, sizeof(short), 1, lclfd) == 1) &&
             (shortint <= MXMSGSIZ) &&
             (fread(msgbuf, 1, shortint, lclfd) > 0))
         {
           p = msgbuf;
           msgbuf[shortint] = '\0';
         }
         fclose(lclfd);
       }
       if (p)
          return(p);
       else
       {
          strcpy(msgbuf,NOMSG);
          p = _itostr(n, 10, "0123456789", &signflag);
          if (signflag)
             strcat(msgbuf,"-");
          strcat(msgbuf,p);
          return(msgbuf);
       }
  }
}
