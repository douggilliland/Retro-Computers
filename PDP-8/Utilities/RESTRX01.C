/* This program sends an rx01 image out the serial port to the PDP8 restore
   program.  It will prompt for the file to send or use first command
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
   unsigned char buf[3];
   unsigned char temp[128];
   int sect,scnt,track;
   unsigned int chksum = 0;
   int cntr;
   int interleave = 2;

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

   sect = 1;
   track = 0;
   scnt = 0;
   while(!terminate) {
      if (track > 76) {
         buf[0] = 0xfe;
         chksum += buf[0];
         chksum = -chksum;
         buf[1] = chksum;
         ser_write(fd,(char *)buf,2);
         printf("\nDone\n");
         exit(0);
      } else {
        buf[0] = 0xff;
        chksum += buf[0];
        ser_write(fd,(char *)buf,1);
      }
      fseek(in, (track*26 + sect - 1) * 128L, SEEK_SET);
      if (fread(temp,128,1,in) != 1) {
         perror("Fread failed");
         exit(1);
      }
      for (cntr = 0; cntr < 128; cntr++)
         chksum += temp[cntr];
      buf[0] = track;
      buf[1] = sect;
      chksum += buf[0];
      chksum += buf[1];
      ser_write(fd,(char *)buf,2);
      ser_write(fd,(char *)temp,128);

      sect += interleave;
      if (sect > 26)
         sect -= 26;
      if (sect == 1)
         sect++;

      scnt++;
      if (scnt >= 26) {
         printf("Track %d\r",track);
         fflush(stdout);
         track++;
         sect = 1;
         scnt = 0;
      }
   }
   return 1;
}
