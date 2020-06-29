#include "putchar2.c"
#include "printf.c"

extern int (*routines[])();

main() {
  int a;

  for(a=0; a<3; a++)
    (*routines[a])();
  flush();
}

fun1() {printf("1\n");}

fun2() {printf("2\n");}

fun3() {printf("3\n");}
