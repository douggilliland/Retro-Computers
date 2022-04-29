

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

#define NOOFCHAR 128
FILE *txtf;
char bits[65536];

void usage()
{
   fprintf(stderr, "pdp2011fontconvert <txt format font file>\n");
}



int main(int argc, char *argv[])
{
   int i;
   int j;
   int noofchar, width, height;
   int currchar;
   char buf32[31];
   char ch;
   int x, y;

   if (argc!=2) {
      usage();
      exit(4);
   }

   memset(&bits, 0, sizeof(bits));
   txtf=fopen(argv[1],"r");

   i=fscanf(txtf, "++font-text-file\n");
   i=fscanf(txtf, "++chars\n%d\n", &noofchar);
   if (i!=1 || noofchar!=256) {
      fprintf(stderr, "error in ++chars directive\n");
      exit(4);
   }
   i=fscanf(txtf, "++width\n%d\n", &width);
   if (i!=1 || width!=8) {
      fprintf(stderr, "error in ++width directive\n");
      exit(4);
   }
   i=fscanf(txtf, "++height\n%d\n", &height);
   if (i!=1 || height!=20) {
      fprintf(stderr, "error in ++height directive\n");
      exit(4);
   }

   fprintf(stderr, "%d %d %d\n", noofchar, width, height);

   currchar=0;
   x=0;
   y=0;
   while (1) {
      ch=fgetc(txtf);
      if (ch==EOF) {
         break;
      } else if (ch=='+') {
         i=fscanf(txtf, "+---%03d-", &currchar);
         if (i!=1) {
            fprintf(stderr, "error in ++char directive following %d\n", currchar);
            exit(4);
         }
//         fprintf(stderr, "%d %d\n", i, currchar);
         while (1) {
            ch=fgetc(txtf);
            if (ch=='\n') break;
         }
         x=0;
         y=0;
      } else if (ch==' ') {
         x=x+1;
      } else if (ch=='X') {
         if (currchar==65) {
//            fprintf(stderr, "bit: %02x %02d %02d\n", currchar, x, y);
         }
         bits[y*width*NOOFCHAR + x*NOOFCHAR + currchar]=1;
         x=x+1;
      } else if (ch=='\n') {
         x=0;
         y=y+1;
      } else {
         fprintf(stderr, "error char found %02x\n", ch);
         exit(4);
      }
   }

   fprintf(stderr, "check : this should be a capital A:\n");
   for (y=0; y<height; y++) {
      for (x=0; x<width; x++) {
         if (bits[y*width*NOOFCHAR + x*NOOFCHAR + 65]) {
            fprintf(stderr, "X");
         } else {
            fprintf(stderr, " ");
         }
      }
      fprintf(stderr, "\n");
   }
   fprintf(stderr, "\n");

//   for (i=0; i<height*width*NOOFCHAR; i+=64) {
   for (i=0; i<32768; i+=64) {                 // way more than we should need, but the synthesizer refuses to generate blockram unless it's a power of 2
      printf("   \"");
      for (j=0; j<64; j++) {
         if (bits[i+j]) {
            printf("1");
         } else {
            printf("0");
         }
      }
//      if (i<height*width*NOOFCHAR-64) {
      if (i<32768-64) {
         printf("\"  &");
      } else {
         printf("\"   ");
      }
      printf("     -- %05d-%05d FONTDATA\n", i,i+63);
   }
}


