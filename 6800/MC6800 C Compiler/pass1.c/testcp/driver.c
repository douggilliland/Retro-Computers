#include  <ctype.h>
#include  "boolean.h"
#include  "miscdefs.h"
#include  "nxtchr.h"
#include  "tables.h"

char lstflg = 0;
int  pp_if_result;
#ifdef PROFILE
char      prof_buffer[4096];
int       pfd;
#endif
char uopt;
char qopt;
char nobopt;
char ilopt;
char optf;
extern    char ident[NS];
extern    short token;
extern    short class;
extern    char *keytab[];

main(argc,argv)
int  argc;
char *argv[];
{
     short i;
     char *nxtfil();
     short     nxtchr();
     char*     get_info();
     char*     cp;
     char**    cpp;
     char**    get_rel();
#ifdef PROFILE
     profil(prof_buffer,2048,0,8);
#endif

     if (prs(argc,argv) != 0) {
          printf("Cannot preset\n");
          flush();
          exit(255);
     }
     while ((cp=nxtfil()) != NULL) {
#ifndef NOTHING
          pfile();
          printf("\n");
          flush();
#endif
          while ( (i=nxtchr()) != FILE_END ){
#ifndef NOTHING
               switch (i) {
               case KEYWORD:  printf("Keyword: %s  Token: %d\n",
                                   keytab[token-1],token);
                              break;
               case IDENT:    printf("Identifier: %s\n",ident);
                              break;
               case END_IF:   printf("End of -if- expression\n");
                              break;
               default:       if (isprint(i))
                                   printf("Character: %c",i);
                              else printf("Control character: 0x%x",i);
                              printf(" Class: %d\n",class);
                              if (i == '\n')plinex();
                              break;
               }
#endif
          }
#ifndef NOTHING
          if( (cp=get_info()) != NULL) pstrng(cp);
#endif
     }
     flush();
#ifdef PROFILE
     if((pfd=creat("profile_data",0x1b)) != -1) {
          write(pfd,prof_buffer,4096);
          close(pfd);
     }
#endif
}
rptern(n)
int n;
{
     if(lstflg == 0) {
          pfile();
          pline();
     }
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
