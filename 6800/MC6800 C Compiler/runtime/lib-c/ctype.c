#include  "machine.h"
#include  <ctype.h>

int toupper(c)
     REGISTER  int       c;
{
     if ((c >= 'a') && (c <= 'z')) c ^= 0x0020;
     return(c);
}


int tolower(c)
     REGISTER  int       c;
{
     if ((c >= 'A') && (c <= 'Z')) c |= 0x0020;
     return(c);
}


int _isgraph(c)
     REGISTER  int       c;
{
     if (isascii(c))
          return(isprint(c) && (c != ' '));
     else return(0);
}
