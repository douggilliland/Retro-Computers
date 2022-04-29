
#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <assert.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>


unsigned char blk[512];

void usage()
{
   fprintf(stderr, "at least -i and -o\n");
}


int main(int argc, char *argv[])
{
   int i;
   int j;

   int op;
   int rc;
   int rc2;
   int myflagi=0;
   int myflago=0;
   int myflagv=0;
   int fill=10485760;
   int imsize;

   char *fn[128];
   char fno[128];

   int ih, oh;

   memset(blk, 0, sizeof(blk));
   memset(fn, 0, sizeof(fn));

// decode command line

   while ((op=getopt(argc, argv, "b:f:i:o:s:v"))!=EOF) switch (op) {
      case 'f':
         fill=atoi(optarg);
         break;
      case 'i':
//         printf("%s\n", optarg);
         strncpy(fn[myflagi++]=malloc(129), optarg, 127);
         if (myflagi>126) exit(1990);
         break;
      case 'o':
         ++myflago;
         strncpy(fno, optarg, sizeof(fno)-1);
         break;
      case 'v':
         ++myflagv;
         break;
      default:
         usage();
         exit(24);
   }

   if (!myflagi) { 
      usage();
      exit(24);
   }
   if (!myflago) { 
      usage();
      exit(24);
   }

   oh=open(fno, O_WRONLY | O_CREAT | O_TRUNC, S_IRUSR | S_IWUSR);
   if (oh<0) {
      fprintf(stderr, "error opening output file %s\n", fno);
      return -4;
   }


   for (i=0; i<126; i++) if (fn[i]) {
      if (*fn[i]) {
//         printf("%s\n", fn[i]);
         imsize=0;
         ih=open(fn[i], O_RDONLY);
         if (ih<0) {
            fprintf(stderr, "error opening input file %s\n", fn[i]);
            return -4;
         }
         while (1) {
            memset(blk, 0, sizeof(blk));
            rc=read(ih, blk, 256);
            imsize+=rc;
            if (rc < 0) {
               fprintf(stderr, "error reading input file %s\n", fn);
               return -4;
            }
            if (rc == 0) {
               break;
            } else if (rc != 256) {
               fprintf(stderr, "short input block\n");
               rc2=write(oh, blk, rc);
               if (rc2 != rc) {
                  fprintf(stderr, "write rc = %d\n", rc2);
               }
            } else {
               rc2=write(oh, blk, 512);
               if (rc2 != 512) {
                  fprintf(stderr, "write rc = %d\n", rc2);
               }
            }
         }
         close(ih);
         while (fill && imsize<fill) {
            imsize+=256;
            memset(blk, 0, sizeof(blk));
            rc2=write(oh, blk, 512);
            if (rc2 != 512) {
               fprintf(stderr, "write rc = %d\n", rc2);
            }
         }
      }
   }
   
   close(oh);

   return 0;
}

