#include <stdio.h>

main()    /* copy input to output */
{
  int c;

  while((c = getchar()) != EOF)
    putchar(c);
}
