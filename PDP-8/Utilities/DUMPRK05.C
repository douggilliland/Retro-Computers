/* This program receives an rk05 image from the serial port from the PDP8 dump
   program.  It will prompt for the file to receive or use first command
   line argument. It needs a config file dumprest.cfg or $HOME/.dumprest.cfg
   with the format defined in config.c

   This program should be running before the PDP8 end is started.

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
   int fd,c,i;
   FILE *out;
   char filename[256];
   char serial_dev[256];
   long baud;
   int two_stop;
   unsigned char buf[200];
   unsigned short temp;
   int count,sect,byte;
   int chksum = 0;

   setup_config(&baud,&two_stop,serial_dev);

   if (argc > 1) {
      strcpy(filename,argv[1]);
   } else {
      printf("Enter file name to receive\n");
      fflush(stdout);
      scanf("%s",filename);
   }

#ifdef PC
   out = fopen(filename,"wb");
#else
   out = fopen(filename,"w");
#endif
   if (out < 0) {
      fprintf(stderr,"On file %s ",filename);
      perror("open failed");
      exit(1);
   }

#if 0
      /* For testing read from file, only works in unix version */
   fd = open("dat",O_RDONLY,0666);
   if (fd < 0) {
      perror("Open failed on dat");
      exit(1);
   }
#else
   fd = init_comm(serial_dev,baud,two_stop);
#endif
   count = -1;
   sect = 0;
   byte = 0;
   while(!terminate) {
      c = ser_read(fd,(char *)buf,sizeof(buf));
      if (c < 0) {
         perror("Serial read failed");
         exit(1);
      }
      for (i = 0; i < c; i++) {
         if (count < 0 ) {
            if (count == -2) {
               if (byte == 0) {
                  temp = buf[i];
                  byte = 1;
               } else {
                  temp = temp | (buf[i] << 8);
                  if (((temp + chksum) & 0xfff) != 0)
                     printf("\nChecksum mismatch %x %x\n",temp,chksum);
                  printf("\nDone\n");
                  exit(1);
               }
            } else {
               if (buf[i] != 0xff && buf[i] != 0xfd) {
                  if (buf[i] == 0xfe) {
                     count = -2;
                     byte = 0;
                  } else {
                     printf("\nMissing start of block flag\n");
                     exit(1);
                  }
               } else {
                  count = 0;
                  if (buf[i] == 0xfd)
                     printf("\nsector %d, cyl %d side %d sect %d bad\n",
                       sect,sect / 32, (sect & 16) >> 4, sect % 16);
               }
            }
         } else {
           if (byte == 0) {
              temp = buf[i];
              byte++;
           } else
           if (byte == 1) {
              temp = (temp | (buf[i] << 8)) & 0xfff;
              fwrite(&temp,2,1,out);
              chksum = chksum + temp;
              temp = buf[i] >> 4;
              byte++;
           } else
           if (byte == 2) {
              temp = (temp | (buf[i] << 4)) & 0xfff;
              fwrite(&temp,2,1,out);
              chksum = chksum + temp;
              byte = 0;
              count = count + 2;
              if (count == 256) {
                 count = -1;
                 sect++;
                 if (sect % 32 == 0) {
                    printf("Cyl %d\r",sect / 32);
                    fflush(stdout);
                 }
              }
           }
        }
      }
   }
   return 1;
}
