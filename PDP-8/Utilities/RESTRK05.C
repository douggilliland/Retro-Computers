/* This program sends an rk05 image out the serial port to the PDP8 restore
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
   unsigned short temp[2];
   int count,sect;
   unsigned int chksum = 0;
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

   count = 256;
   sect = 0;
   while(!terminate) {
      if ((rc = fread(temp,2,2,in)) < 2) {
            /* No more data */
         if (rc < 0) {
            perror("\nfile read failed\n");
            exit(1);
         }
           /* Must be at start of block when data done */
         if (count != 256 || rc != 0) {
            printf("\nEarly end of file %d, %d\n",count,rc);
            exit(1);
         }
            /* Send end of data flag and checksum */
         buf[0] = 0xfe;
         chksum = -chksum;
         buf[1] = chksum;
         buf[2] = (chksum & 0xfff) >> 8;
         ser_write(fd,(char *)buf,3);
         exit(0);
      }
         /* If start of new block send block flag */
      if (count == 256) {
         count = 0;
         buf[0] = 0xff;
         ser_write(fd,(char *)buf,1);
         sect++;
         if (sect % 32 == 0) {
            printf("Cyl %d\r",sect / 32);
            fflush(stdout);
         }
      }
      chksum += temp[0] + temp[1];
      buf[0] = temp[0];
      buf[1] = (temp[0] >> 8) | (temp[1] << 4);
      buf[2] = (temp[1] >> 4);
      ser_write(fd,(char *)buf,3);
      count += 2;
   }
   return 1;
}
