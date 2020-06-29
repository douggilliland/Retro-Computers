#include "getchar2.c"
#include "putchar2.c"
#include "printf.c"

main(argc, argv)

int argc;
char *argv[];

{
  int i,c;

  if (argc != 2) {
    printf(2,"Syntax error: viewil filename.\n");
    exit(255);
  }
  if ( (fin=open(argv[1], R)) == ERROR ) {
    printf(2,"Can't open '%s'.\n",argv[1]);
    exit(255);
  }
  while ((c=getchar()) != EOF) {
    i++;
    if (c < 128)
      doexp(c);
    else
      domop(c);
  }
  printf("Total characters processed = %d.\n",i);
  flush();
}

domop(c) {
  printf("domop\n");
}

doexp(c) {
  printf("doexp\n");
}
