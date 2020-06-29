/*
     void      tzset();
     long      timezone;
     int       daylight;
     char     *tzname[];

          The function "tzset" sets the globally referencable
          values "timezone", "daylight", and "tzname".

          timezone  The number of seconds the timezone is west
                    of GMT
          daylight  Non-zero if standard U.S.A. daylight savings
                    time is being observed, zero otherwise
          tzname    An array of two (char *).  The first references
                    the name of the standard timezone, if known,
                    or NULL if not.  The second references the
                    name of the daylight-savings-time timezone,
                    if know, or NULL if not.
*/

#include  "machine.h"
#include  <sys/timeb.h>

     long      timezone = -1; /* seconds west of GMT */

     int       daylight = 0;  /* !0 if USA DST in effect, */
                              /* =0 otherwise */

     char     *tzname[2] =    /* Ptrs to time zone names */
               {NULL, NULL};


#define   MINTZNAM  4
#define   MAXTZNAM  10
static    char     *tznames[MAXTZNAM-MINTZNAM+1][2] =
          {         {"AST", "ADT"}, /* Nova Scotia    (Atlantic) */
                    {"EST", "EDT"}, /* North Carolina (Eastern)  */
                    {"CST", "CDT"}, /* Oklahoma       (Central)  */
                    {"MST", "MDT"}, /* Colorado       (Mountain) */
                    {"PST", "PDT"}, /* Nevada         (Pacific)  */
                    {"YST", "YDT"}, /* Yucon          (Yucon)    */
                    {"HST", "HDT"}, /* Hawaii         (Hawaii)   */
          } ;

void tzset()
{
               struct timeb   tbuf;          /* System time */
               int            ftime();       /* Get system time */
     REGISTER  int            i;             /* Local temp */


     /*
          Get the information from UniFLEX
     */
     ftime(&tbuf);

     /*
          Set "daylight" flag
     */
     daylight = tbuf.dstflag;

     /*
          Set "timezone" value (UniFLEX returns tbuf.timezone
          as MINUTES west of GMT
     */
     timezone = ((long) tbuf.timezone) * 60L;

     /*
          Set the timezone name pointers in "tzname",
          if known
     */
     if ((tbuf.timezone % 60 == 0) &&
         ((i = (tbuf.timezone / 60) - MINTZNAM) >= 0) &&
         (i <= MAXTZNAM))
     {
          tzname[0] = tznames[i][0];
          tzname[1] = tznames[i][1];
     }
     else
     {
          tzname[0] = NULL;
          tzname[1] = NULL;
     }
}
