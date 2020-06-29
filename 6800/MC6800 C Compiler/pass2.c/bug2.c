main(argc,argv)
int argc;
char **argv;
{
 register char *p1,*p2;
 char *p3;
 register int *p4;
 char ****chp4;
 char ***chp3;
 register int i,j,k;

 *p1++ = (*--p4)++;
 *--p2 = *(*++argv)++;
 *--p3 = *(*++argv)++;
 *p1++ = ++(*p4--);
 *(*(*++(*chp4--))++) = 'a';
 *(*(*++(*chp4--))++) = *(*(*--chp3)--)++;
 *(*(*++(*chp4--))++) += *(*(*--chp3)--)++;
 *(*(*++(*chp4--))++) = (*(*(*--chp3)--)++)++;
 *(*(*++(*chp4--))++) += (*(*(*--chp3)--)++)++;
}
