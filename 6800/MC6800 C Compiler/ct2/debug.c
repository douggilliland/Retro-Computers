#include "putchar2.c"
#include "printf2.c"
#include "debug.h"

struct map {
  int offset;
  int address;
  int size;
};
struct map fmap[40];
int fd;
char header[24];

main(argc, argv)

int argc;
char *argv[];

{
  int i;

  if (argc != 2) {
    printf(2,"Syntax error: debug filename\n");
    exit(255);
  }
  if ( (fd=open(argv[1], RW)) == ERROR ) {
    printf(2,"Can't open '%s'.\n",argv[1]);
    exit(255);
  }
  if (read(fd, header, 24) != 24) {
    printf(2,"Error reading binary header.\n");
    exit(255);
  }
  if (header[0] != 2) {
    printf(2,"File '%s' is not a binary file.\n",argv[1]);
    exit(255);
  }
  if (header[1] & 0x03 ==  0x02)
    mapabs();
  else
    mapseg();
  for (i=0; i<40; i++) {
    printf("Offset: %04x, address: %04x, size: %04x.\n", fmap[i].offset,
                  fmap[i].address, fmap[i].size);
  }
  flush();
}

mapseg() {
  int data;
  int text;

  printf("In mapseg\n");
  if (text = ( (int)header[2]<<8) + header[3] ) {
    fmap[0].offset = 24;
    fmap[0].address = 0;
    fmap[0].size = text;
  }
}

mapabs() {}
