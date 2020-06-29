#include <stdio.h>
#include <string.h>

#define NOERFMSG "Couldn't open error file - reporting error "
#define UNKNEMSG "? Unknown error "
#define DIGITS   "0123456789"

char *errmsg(errnum)
  int errnum;
{
  static char msgtext[255];
  short seek_adr, msg_len;
  long err_fd;

  if ((errnum >= 1) && (errnum <= 63))
  {
    if ((err_fd = open("/gen/errors/system", 0)) == -1)
      return(strcat(strcpy(msgtext, NOERFMSG),
                    _itostr(errnum, 10, DIGITS, (int *) NULL)));
    else
    {
      lseek(err_fd, ((long)errnum)*2L, 0);
      read(err_fd, &seek_adr, 2);
      lseek(err_fd, (long)seek_adr, 0);
      read(err_fd, &msg_len, 2);
      read(err_fd, msgtext, msg_len);
      close(err_fd);
      return(msgtext);
    }
  } 
  else 
    if (errnum != 0)
      return(strcat(strcpy(msgtext, UNKNEMSG),
                    _itostr(errnum, 10, DIGITS, (int *) NULL)));
    else
      return((char *) NULL);
}
