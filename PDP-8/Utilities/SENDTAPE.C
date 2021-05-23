/* This program sends a file out the serial port to the PDP8.  Use for
   sending paper tape images.
   It will prompt for the file to send or use first command
   line argument.  It needs a config file dumprest.cfg or $HOME/.dumprest.cfg
   with the format defined in config.c

   The PDP8 end should be running before this program is started

   On the PC ctrl-break will terminate the program
*/
#ifdef PC
#include "encom.h"
#else
#include <termios.h>
#include <unistd.h>
#include <memory.h>
#endif

#include <stdio.h>
#include <fcntl.h>
#include <time.h>
#include <signal.h>
#include <stdlib.h>
#include <string.h>

#define ARRAYSIZE(a) (sizeof(a) / sizeof(a[0]))

int terminate = 0;

#ifndef PC
#define ser_read read
#define ser_write write
#endif;

#include "config.c"
#include "comm.c"

main(argc,argv)
   int argc;
   char *argv[];
{
   int fd;
   FILE *in;
   char filename[256];
   char serial_dev[256];
   long baud;
   int two_stop;
   unsigned char buf[256];
   long count;
   int rc;

   setup_config(&baud,&two_stop,serial_dev);

   if (argc > 1) {
      strcpy(filename,argv[1]);
   } else {
      printf("Enter file name to send\n");
      fflush(stdout);
      scanf("%s",filename);
   }

#ifdef PC
   in = fopen(filename,"rb");
#else
   in = fopen(filename,"r");
#endif
   if (in == NULL) {
      fprintf(stderr,"On file %s ",filename);
      perror("open failed");
      exit(1);
   }

#if 0
      /* For testing write to file, only works in unix version */
   fd = open("dat",O_RDWR | O_CREAT | O_TRUNC,0666);
   if (fd < 0) {
      perror("Open failed on dat");
      exit(1);
   }
#else
   fd = init_comm(serial_dev,baud,two_stop);
#endif

   count = 0;
   while(!terminate && !feof(in)) {
      if ((rc = fread(buf,1,sizeof(buf),in)) < 0) {
         perror("\nfile read failed\n");
         exit(1);
      }
      count += rc;
      ser_write(fd,(char *)buf,rc);
   }
   if (terminate)
      printf("Send aborted, %d bytes sent\n",count);
   else
      printf("Done, sent %d bytes\n",count);
   exit(0);
}
