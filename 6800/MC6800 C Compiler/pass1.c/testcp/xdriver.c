#include  <ctype.h>
#include  "boolean.h"
#include  "miscdefs.h"
#include  "nxtchr.h"
#include  "tables.h"

char lstflg = 0;
char uopt;
char qopt;
char nobopt;
char ilopt;
char optf;
int  pp_if_result;
extern    char ident[NS];
extern    short token;
extern    short class;
extern    char *keytab[];

main(argc,argv)
int  argc;
char *argv[];
{
     short i;
     BOOLEAN   nxtfil();
     short     nxtchr();
     char*     get_info();
     char*     cp;
     char**    cpp;
     char**    get_rel();

     if (prs(argc,argv) != 0) {
          printf("Cannot preset\n");
          flush();
          exit(255);
     }
     while (nxtfil()) {
          while ( (i=nxtchr()) != FILE_END ){
               switch (i) {
               case KEYWORD:  printf("%s", keytab[token-1],token);
                              break;
               case IDENT:    printf("%s",ident);
                              break;
               case END_IF:   printf("End of -if- expression\n");
                              break;
               default:       printf("%c",i);
                              break;
               }
               flush();
          }
     }
     flush();
}
rptern(n)
int n;
{
     printf("Error number %d\n",n);
     flush();
}
error(n)
int n;
{
     printf("Error number %d\n",n);
     flush();
     exit(255);
}
pstrng(s)
char *s;
{
     printf("%s",s);
}
rpterr(s)
char *s;
{
     printf("%s\n",s);
}
ppcexp()  /* preprocessor "if" expression handler */
{    int count;
     short nxtchr();
     while(nxtchr()!=END_IF) count++;
     pp_if_result = count & 1;
     return 1;
}
