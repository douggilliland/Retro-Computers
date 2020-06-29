main(argc,argv)
int argc;
char **argv;
{
  char *p1,*p2;
 char *p3;
 register int *p4;
  int *p5;
 register int i,j,k;

 *p1++ = ++(*p4--);
 *p1++ = ++(*p5--);
 *p1++ = (*--p4)++;
}
