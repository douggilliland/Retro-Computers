/*
     unsigned int sleep(sleeptim)
          unsigned int   sleeptim;

          This function causes the current process to
          pause for a maximum of <sleeptim> seconds.
          It returns the number of seconds yet unslept.

     Arguments:
          sleeptim  unsigned int
                    The maximum number of seconds to sleep

     Returns:  unsigned int
          The number of seconds in the sleep time yet unslept

     Notes:
        - Any interrupt that is not ignored and does not
          cause program termination will cause a premature
          ending of the sleep period.  The returned value
          will reflect the number of seconds yet unslept.
        - The sleep interval is implemented using the
          alarm interrupt (SIGALRM).  This function is
          cognizant of alarms armed before calling
          "sleep()" and of alarm-interrupt handler info
          set before calling "sleep()".  The armed alarms
          will behave as though the "sleep()" call had not
          been made, and the alarm-interrupt handler info
          is preserved (saved and restored) across the
          "sleep()" call.
        - "sleep(0)" is a request to sleep forever.

     Routine History:
          08/02/84 kpm - New.
*/

/*
     Common definitions
*/

#include  "machine.h"
#include  <sys/signal.h>

unsigned int sleep(sleeptim)
     REGISTER  unsigned int   sleeptim;
{
               unsigned int   alarm();
               void           pause();
               int          (*signal())();
               int            dummy();
     REGISTER  unsigned int   alarmtim;
     REGISTER  unsigned int   timeleft;
     register  int          (*handler)();


     /*
          Case 1:  No currently-active alarm
     */
     handler = signal(SIGALRM, dummy);
     if ((alarmtim = alarm(0)) == 0)
     {
          alarm(sleeptim);
          pause();
          timeleft = alarm(0);
          signal(SIGALRM, handler);
     }

     /*
          Case 2:  Currently active alarm to occur after
                   sleep interval
     */
     else if (((sleeptim != 0) && (alarmtim > sleeptim)) ||
              (handler == SIG_IGN))
     {
          alarm(sleeptim);
          pause();
          timeleft = alarm(0);
          signal(SIGALRM, handler);
          alarm(timeleft + (alarmtim - sleeptim));
     }

     /*
          Case 3:  Currently active alarm scheduled before
                   requested sleep interval
     */
     else
     {
          signal(SIGALRM, handler);
          alarm(alarmtim);
          pause();
          if ((timeleft = alarm(0)) != 0) alarm(timeleft);
          timeleft += sleeptim - alarmtim;
     }

     /*
          Return the amount of sleep-time yet unslept
     */
     return((sleeptim == 0) ? 0 : timeleft);
}

/*
     int dummy()

          This routine is called whenever an "ALARM"
          interrupt is seen.  It sure don't do much!
          "ALARM" interrupts cause program termination
          if not caught or ignored!
*/

static int dummy()
{
}
