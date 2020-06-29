#include "putchar2.c"

#define ERROR -1
#define R 0
#define BUFSIZ 512

int fd;
int address;
char buffer[BUFSIZ];

main(argc, argv)

int argc;
char *argv[];

{
  int count, i;

  if (argc != 2) {
    ostring(2,"Syntax error: dump filename\n");
    exit(255);
  }
  if ( (fd=open(argv[1], R)) == ERROR ) {
    ostring(2,"Can't open '");
    ostring(2,argv[1]);
    ostring(2,"'.\n");
    exit(255);
  }
  address = 0;
  while (count = read(fd, buffer, BUFSIZ)) {
    if (count == ERROR) {
      ostring(2,"I/O error while reading file.\n");
      exit(255);
    }
    display(count);
  }
  flush();
}

display(count) {
  char *p;
  int i;
  int a;

  p = buffer;
  while (count) {
    i = ( (count >= 16) ? 16 : count );
    count = ( (count >= 16) ? count-16 : 0);
    hexword(address);
    outch(' ');
    for (a=0; a != i; ++a) {
      outch(' ');
      hexbyte(*p++);
      if (a == 7) outch(' ');
    }
    while (a < 16) {
      ostring("   ");
      if (a == 7) outch(' ');
      ++a;
    }
    p -= i;
    ostring("  ");
    for (a=0; a != i; ++a) {
      wc(*p++);
    }
    address += i;
    outch('\n');
  }
}

wc(c)
char c;
{
  c &= 0x7f;
  if ( c < ' ' || c == 0x7f)
    outch('.');
  else
    outch(c);
}

hexbyte(byte)
char byte;
{
  static char hex[] = "0123456789abcdef";

  outch(hex[byte/16]);
  outch(hex[byte & 0xf]);
}

hexword(word)
unsigned word;
{
  hexbyte(word/256);
  hexbyte(word & 0xff);
}

ostring(arg) {
  int *p, f;
  char *ap, c;

  p = &arg;
  f = *p;
  if ((unsigned) f < 16) {
    ++p;
    if (f != fout) {
      flush();
      fout = f;
    }
  }
  ap = (char *) *p++;
  while ( c = *ap++ ) outch(c);
  if (fout != 1) flush();
  fout = 1;
}

outch(c)
char c;
{
  putchar(c);
}
