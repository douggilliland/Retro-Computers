#include <math.h>
char *_ftoa(fp)
     double    fp;
{
     register  char     *p;
     register  char     *q;
               int       i, sign, expnt;

     static    char      buffer[22];

     p = ecvt(fp, 14, &expnt, &sign);
     q = buffer;
     if (*p != '0') expnt--;
     *q++ = sign ? '-' : '+';
     *q++ = *p++;
     *q++ = '.';
     while (*q++ = *p++) ;
     --q;
     *q++ = 'E';
     p = _itostr(expnt, 10, "0123456789", &sign);
     *q++ = sign ? '-' : '+';
     for (i = 3 - strlen(p) ; i-- ; ) *q++ = '0';
     while (*q++ = *p++) ;
     return(buffer);
}
