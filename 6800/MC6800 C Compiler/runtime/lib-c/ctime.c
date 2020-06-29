/*
     char *ctime(pclock)
          long     *pclock;

          This function generates a timestamp for the
          system time value referenced by <pclock>.
          It returns a pointer to that generated timestamp.
          The time-stamp displays the time in the local
          timezone with daylightsavings time (if applic)
          is in effect.

          The system time referenced by <pclock> is in
          seconds since the epoch.  The epoch is (on
          UniFLEX) 1 Jan 1980 00:00 GMT.  The timestamp
          is a 26 character string (including terminating
          end-of-line character and null) of the form:

          "%3s %3s %#2d %#2d:%#2d:%#2d %#4d\n"

     Arguments:
          pclock    long *
                    References the system time value to be
                    used to generate the timestamp.  It is
                    the number of seconds since the epoch,
                    which is 00:00 1 Jan 1980 GMT

     Returns:  char * (into static store)
          References the generated timestamp

     Routine History:
          07/26/84 kpm - New
*/

#include  <time.h>

char *ctime(pclock)
               long          *pclock;
{
     return(asctime(localtime(pclock)));
}
