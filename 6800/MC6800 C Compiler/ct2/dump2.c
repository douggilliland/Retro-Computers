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
    pstrng(2,"Syntax error: dump filename\n",0);
    exit(255);
  }
  if ( (fd=open(argv[1], R)) == ERROR ) {
    pstrng(2,"Can't open '",argv[1],"'.\n",0);
    exit(255);
  }
  address = 0;
  while (count = read(fd, buffer, BUFSIZ)) {
    if (count == ERROR) {
      pstrng(2,"I/O error while reading file.\n",0);
      exit(255);
    }
    display(count);
  }
  flush();
}

display(count) {
  register char *p;
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
      pstrng("   ",0);
      if (a == 7) outch(' ');
      ++a;
    }
    p -= i;
    pstrng("  ",0);
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
  c &= '\177';
  if ( c < ' ' || c == '\0177')
    outch('.');
  else
    outch(c);
}

hexbyte(byte)
char byte;
{
  static char hex[] = "0123456789abcdef";

  outch(hex[(byte&0xff)/16]);
  outch(hex[(byte&0xff) % 16]);
}

hexword(word)
unsigned word;
{
  hexbyte(word/256);
  hexbyte(word % 256);
}

pstrng(arg) {
  int *p, f;
  register char *ap;

  p = &arg;
  f = *p;
  if ((unsigned) f < 16) {
    ++p;
    if (fout != f) {
      flush();
      fout = f;
    }
  }
  while (ap = *p++)
    while (*ap) outch(*ap++);
  if (fout != 1) flush();
  fout = 1;
}

outch(c)
char c;
{
  putchar(c);
}
