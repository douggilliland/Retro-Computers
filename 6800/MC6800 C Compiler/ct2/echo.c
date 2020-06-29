#include "putchar2.c"
#include "printf2.c"

main(argc, argv)
char *argv[];
{
  while (--argc > 0)
    printf("%s ",*++argv);
  putchar('\r');
  flush();
}
