/*
     char *asctime(ptm)
          struct tm     *ptm;

          This function generates a timestamp from the
          information in the (struct tm) struct referenced
          by <ptm>.  It returns a reference to the generated
          character string.

          A timestamp is a 26-character string (incl. EOL
          and '\0') that contains the day of the week, the
          month of the year, the day of the month, the hour,
          minute, second, and year, respectively, formatted
          through:
               "%3s %3s %2.2d %2.2d:%2.2d:%2.2d %4.4d\n"
          using "sprintf()".

     Arguments:
          ptm       struct tm *
                    References the structure containing the
                    time information to be converted into a
                    timestamp

     Returns:  char *
          A reference to the generated timestamp.

     Notes:
        - The behavior of "asctime()" is undefined if the
          information in the (struct tm) referenced by <ptm>
          is not valid.
        - The string of characters referenced by the result
          is in static memory and will be overwritten on
          subsequent "asctime()" calls

     Routine History:
          07/30/84 kpm - New
*/

/*
     Definitions
*/
#include  "machine.h"
#include  <string.h>
#include  <time.h>

/*
     Static data
*/
static    char      timestmp[60];
static    char     *daynames[7] = {"Sun",
                                   "Mon",
                                   "Tue",
                                   "Wed",
                                   "Thu",
                                   "Fri",
                                   "Sat"
                                  };

static    char     *monnames[12]= {"Jan",
                                   "Feb",
                                   "Mar",
                                   "Apr",
                                   "May",
                                   "Jun",
                                   "Jul",
                                   "Aug",
                                   "Sep",
                                   "Oct",
                                   "Nov",
                                   "Dec"
                                  };


static char *gennum(i, n)
     int  i;
     int  n;
{
     ADDRREG0  char     *p;
     ADDRREG1  char     *dptr;
     DATAREG0  int       nz;
               char      staticbuf[10];

               char     *_itostr();

     dptr = _itostr(i, 10, "0123456789", (int *) NULL);
     if ((nz = n - strlen(dptr)) > 0)
     {
          for (p = staticbuf ; --nz >= 0 ; *p++ = '0') ;
          strcpy(p, dptr);
          return(staticbuf);
     }
     else return(dptr);
}


char *asctime(tm)
     ADDRREG1  struct tm     *tm;
{
     ADDRREG0  char          *p;

     p = timestmp;
     strcpy(p, daynames[tm->tm_wday]);
     p += 3;
     *p++ = ' ';
     strcpy(p, monnames[tm->tm_mon]);
     p += 3;
     *p++ = ' ';
     strcpy(p, gennum(tm->tm_mday, 2));
     p += 2;
     *p++ = ' ';
     strcpy(p, gennum(tm->tm_hour, 2));
     p += 2;
     *p++ = ':';
     strcpy(p, gennum(tm->tm_min, 2));
     p += 2;
     *p++ = ':';
     strcpy(p, gennum(tm->tm_sec, 2));
     p += 2;
     *p++ = ' ';
     strcpy(p, gennum(tm->tm_year+1900, 4));
     p += 4;
     *p++ = '\n';
     *p = '\0';
/*   sprintf(timestmp, "%3s %3s %2.2d %2.2d:%2.2d:%2.2d %4.4d\n",
                       daynames[tm->tm_wday],
                       monnames[tm->tm_mon],
                       tm->tm_mday,
                       tm->tm_hour,
                       tm->tm_min,
                       tm->tm_sec,
                       tm->tm_year+1900);
*/
     return(timestmp);
}
