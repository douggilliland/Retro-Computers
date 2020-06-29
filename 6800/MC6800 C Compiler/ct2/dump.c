#include "putchar2.c"
#include "printf2.c"

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
    printf(2,"Syntax error: dump filename\n");
    exit(255);
  }
  if ( (fd=open(argv[1], R)) == ERROR ) {
    printf(2,"Can't open '%s'.\n",argv[1]);
    exit(255);
  }
  address = 0;
  while (count = read(fd, buffer, BUFSIZ)) {
    if (count == ERROR) {
      printf(2,"I/O error while reading '%s'.\n",argv[1]);
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
    printf("%04x ",address);
    for (a=0; a != i; ++a) {
      printf(" %02x",*p++);
      if (a == 7) printf(" ");
    }
    while (a < 16) {
      printf("   ");
      if (a == 7) printf(" ");
      ++a;
    }
    p -= i;
    putchar(' ');
    for (a=0; a != i; ++a) {
      wc(*p++);
    }
    address += i;
    putchar('\n');
  }
}

wc(c)
char c;
{
  c &= '\177';
  if ( c < ' ' || c == '\0177')
    printf(".");
  else
    printf("%c",c);
}
