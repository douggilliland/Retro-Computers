/*
     time.h - time definitions
*/

#define time_h

/*
     Definition of time vector "struct tm"

     int  tm_sec         00 - 59   # seconds into the minute
     int  tm_min         00 - 59   # minutes into the hour
     int  tm_hour        00 - 23   # hours into the day
     int  tm_mday        01 - 31   day of the month
     int  tm_mon         00 - 11   # months into the year
     int  tm_year                  years since 1900
     int  tm_wday        00 - 06   # days into week (0 == Sunday
     int  tm_yday        00 - 365  # days into year
     int  tm_isdst       != 0 -> dst is in effect, == 0 otherwise

     NOTE:  Previous versions of UniFLEX named the "tm_sec" field
            "tm_secs".  Was changed to the UNIX name "tm_sec" for
            compatibility reasons ... kpm 07/26/84
*/

struct tm
{
     int       tm_sec;
     int       tm_min;
     int       tm_hour;
     int       tm_mday;
     int       tm_mon;
     int       tm_year;
     int       tm_wday;
     int       tm_yday;
     int       tm_isdst;
};

#ifndef   NULL
#define   NULL      0
#endif


/*
     External definitions
*/

/*
     The following external variables are set up by
     calling tzset()
*/
extern    char     *tzname[];      /* Timezone names */
extern    int       daylight;      /* 0 if no DST, <>0 if DST */
extern    long      timezone;      /* Seconds West of GMT */


/*
     Functions available
*/

     char          *asctime();     /* Gen timestamp from "tm" struct */
     char          *ctime();       /* Gen timestamp from value */
     struct tm     *gmtime();      /* Gen GMT "tm" struct */
     struct tm     *localtime();   /* Gen local "tm" struct */
     void           tzset();       /* Set global information */
