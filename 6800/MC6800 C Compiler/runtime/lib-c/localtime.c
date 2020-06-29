/*
     localtime.c - Generate struct tm structures from
                   system time values

     Includes:
          struct tm *localtime()
          struct tm *gmtime()
*/


#include  "machine.h"
#include  <time.h>

/*
     Static data
*/

static    struct tm      tv;
static    int            mdaysin[12] = { 31,      /* January */
                                         -1,      /* February */
                                         31,      /* March */
                                         30,      /* April */
                                         31,      /* May */
                                         30,      /* June */
                                         31,      /* July */
                                         31,      /* August */
                                         30,      /* September */
                                         31,      /* October */
                                         30,      /* November */
                                         31       /* December */
                                       };

/*------------------------------------------------------------------

     struct tm *localtime(pclock)
          long     *pclock;

          This function takes the system time value referenced
          by <pclock> and breaks it down into hours, minutes,
          seconds, etc., returning a pointer to a structure
          containing that information.  (See <time.h> for a
          description of the structure.)  The time information
          is represented in local time and daylight savings
          time (USA Standard) is taken into account if
          necessary.

          The system time value referenced by <pclock> is an
          integer representing the number of seconds since
          the epoch, which is January 1, 1980 at 00:00 GMT.

     Arguments:
          pclock    long *
                    References the system time value (# seconds
                    since the epoch) to be broken-down into
                    units in the local timezone.

     Returns:  struct tm *
          A reference to a structure containing the broken-down
          time units.

     Notes:
        - The struct tm structure referenced by this function is
          in static memory and will be overwritten by subsequent
          calls to localtime() or gmtime().

     Routine History:
          07/27/84 kpm - New
*/

struct tm *localtime(pclock)
     long     *pclock;             /* Ptr to system time value */
{
     struct tm     *_gentm();      /* Routine that breaks down time */
     int            _isindst();    /* TRUE if DST is in effect,
                                      FALSE otherwise */
     REGISTER  long      clock;    /* System time value */


     clock = *pclock;               /* Get system time value */

     /*
          If timezone, daylight, and tzname are not yet set up,
          set them up using tzset()
     */
     if (timezone < 0L) tzset();

     /*
          Apply the timezone
     */
     if ((clock = clock - timezone) < 0) clock = 0;
     else
       /*
          Take into account daylight-savings time if it is
          being observed by the system and the current time is
          within the timeperiod in which daylightsavingstime
          is in effect
       */
       if (tv.tm_isdst = (daylight && _isindst(clock)))
          clock += 3600L;

     return(_gentm(clock));
}

/*------------------------------------------------------------------

     struct tm *gmtime(pclock)
          long     *pclock;

          This function takes the system time value referenced
          by <pclock> and breaks it down into hours, minutes,
          seconds, etc., returning a pointer to a structure
          containing that information.  (See <time.h> for a
          description of the structure.)

          The system time value referenced by <pclock> is an
          integer representing the number of seconds since
          the epoch, which is January 1, 1980 at 00:00 GMT.

     Arguments:
          pclock    long *
                    References the system time value (# seconds
                    since the epoch) to be broken-down into
                    units in the Greenwich timezone (GMT)

     Returns:  struct tm *
          A reference to a structure containing the broken-down
          time units.

     Notes:
        - The struct tm structure referenced by this function is
          in static memory and will be overwritten by subsequent
          calls to localtime() or gmtime().

     Routine History:
          07/27/84 kpm - New
*/

struct tm *gmtime(pclock)
     long     *pclock;
{
     struct tm     *_gentm();
     tv.tm_isdst = 0;
     return(_gentm(*pclock));
}

/*
     static struct tm *_gentm(clock)
          long      clock;

          Break down system time value into seconds, minutes,
          hours, day of the week, day of the month, day of the
          year, years since 1900.

     Arguments:
          clock     long
                    System time value

     Returns:  struct tm *
          Reference to the structure (static) that contains
          the information derived from the system time value.

     Routine History:
          07/27/84 kpm - New
*/

static struct tm *_gentm(clock)
     REGISTER  long      clock;
{
     REGISTER  int       dayofyr;
     REGISTER  int       year;
     REGISTER  int       month;

     /*
        Calculate seconds into the minute
     */
     tv.tm_sec  = clock % 60L;

     /*
        Calculate minutes into the hour
     */
     tv.tm_min  = (clock = clock / 60L) % 60L;

     /*
        Calculate hours (24hr clock) into the day
     */
     tv.tm_hour = (clock = clock / 60L) % 24L;

     /*
        Calculate days into the week
        (0-6, 0 is Sunday)
        [Jan 1, 1980 was a Wednesday!]
     */
     tv.tm_wday = ((dayofyr = clock / 24L) + 2) % 7;

     /*
        Calculate years since 1900
     */
     if (dayofyr < (5*366) + (15*365))  /* day < 1/1/2000 ?? */
     {
        dayofyr += (19*366) + (61*365);
        year = 0;
     }
     else  /* day >= 1/1/2000 */
     {
        dayofyr -= (5*366) + (15*365); /* Calc day since 1/1/2000 */
        year = 100 * ((dayofyr / ((19*366)+(81*365)))+1);
        dayofyr %= (19*366) + (81*365);  /* Calc day of century */
     }
     if (dayofyr >= 365)
     {
        for (year += 1 , dayofyr -= 365 ;   /* Count century year */
             dayofyr >= 365+365+365+366 ;
             dayofyr -= 365+365+365+366 , year += 4) ;
        if (dayofyr >= 365)
        {
           year += 1;
           if ((dayofyr -= 365) >= 365)
           {
              year += 1;
              if ((dayofyr -= 365) >= 365)
              {
                year += 1;
                dayofyr -= 365;
              }
           }
        }
     }
     tv.tm_year = year;

     /*
        Day of the year
     */
     tv.tm_yday = dayofyr;

     /*
        Day of the month & month of the year
         - Must fill in # days in February
     */
     mdaysin[1] = (((year%4) == 0) && ((year%100) != 0)) ? 29 : 28;
     for (month = 0 ; dayofyr >= mdaysin[month] ; month++)
        dayofyr -= mdaysin[month];
     tv.tm_mon  = month;
     tv.tm_mday = dayofyr + 1;

     /*
        Finished
     */
     return(&tv);
}
int _isindst(clock)
     REGISTER  long      clock;
{
     REGISTER  int       yday;          /* Day of the year */
     REGISTER  int       hour;          /* Hour of the day */
     REGISTER  int       year;          /* Years since 1900 */
     REGISTER  int       wday;          /* Day of the week (0=Sun) */
               int       lsunapr;       /* Last sunday in April */
               int       lsunoct;       /* Last sunday in October */

     /*
        Determine the hour (24 hr clock)
     */
     hour = (clock / (60L * 60L)) % 24;

     /*
        Determine the day of the year
     */
     yday =  clock / (60L*60L*24L);

     /*
        Determine day of the week (Jan 1 was a Wed)
     */
     wday = (yday + 2) % 7;

     /*
        Determine years since 1900
     */
     if (yday < (5*366) + (15*365))  /* day < 1/1/2000 ?? */
     {
        yday += (19*366) + (61*365); /* Calc day since 1/1/1900 */
        year = 0;
     }
     else  /* day >= 1/1/2000 */
     {
        yday -= (5*366) + (15*365); /* Calc day since 1/1/2000 */
        year = 100 * ((yday / ((19*366)+(81*365)))+1);
        yday %= (19*366) + (81*365);  /* Calc day of century */
     }
     if (yday >= 365)
     {
        for (year += 1 , yday -= 365 ;   /* Count century year */
             yday >= 365+365+365+366 ;
             yday -= 365+365+365+366 , year += 4) ;
        if (yday >= 365)
        {
           year += 1;
           if ((yday -= 365) >= 365)
           {
              year += 1;
              if ((yday -= 365) > 365)
              {
                year += 1;
                yday -= 365;
              }
           }
        }
     }

     /*
        Determine the day of the year that is the last Sunday
        in April and the last Sunday in October (note leapyear
        adjustment)
        119 is the year-day for Apr 31
        303 is the year-day for Oct 31
        420 is a number > 366 that has 7 as a factor
     */
     lsunapr = 119 - ((119 + 420 + wday - yday) % 7);
     lsunoct = 303 - ((303 + 420 + wday - yday) % 7);
     if ((year % 4 == 0) && (year % 100 != 0))
     {
        lsunapr++;
        lsunoct++;
     }

     /*
        Daylight savings time is in effect between
             0200 on the last Sunday of April
             0100 on the last Sunday of October
     */
     return(((yday > lsunapr) && (yday < lsunoct)) ||
            ((yday == lsunapr) && (hour >= 2)) ||
            ((yday == lsunoct) && (hour < 2)));
}
