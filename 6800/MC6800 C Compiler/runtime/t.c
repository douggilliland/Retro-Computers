#include <stdio.h>
#include <sys/timeb.h>
extern long timezone;
extern int daylight;
extern char *tzname[];
struct timeb buf;
long t, time();
char *ctime();
main() {
  ftime(&buf);
  printf("T=%ld, TK=%d, DSD=%d, Z=%d\n",
    buf.time, buf.tm_tik, buf.dstflag, buf.timezone);
  printf("TZ=%ld, DL=%d, N1=%s, N2=%s\n",timezone,daylight,tzname[0],tzname[1]);
  tzset();
  printf("TZ=%ld, DL=%d, N1=%s, N2=%s\n",timezone,daylight,tzname[0],tzname[1]);
  t = time(0L);
  printf("Time is %s\n", ctime(&t));
  fflush(stderr);
}
