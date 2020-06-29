#include "getchar2.c"
#include "putchar2.c"
#include "printf.c"
#include "getline.c"
#include "index.c"

#define MAXLINE 100

main(argc, argv)
char *argv[];
{
  char line[MAXLINE], *s;
  int lineno;
  int except, number;
  int i;

  lineno=except=number=0;
  while (--argc > 0 && (*++argv)[0] == '+')
    for (s=argv[0]+1; *s!='\0'; s++)
      switch(*s) {
      case 'x':
        except = 1;
        break;
      case 'n':
        number = 1;
        break;
      default:
        printf("find: illegal option %c\n",*s);
        argc=0;
        break;
      }
  if (argc != 1)
    printf("Usage: find +x +n pattern\n");
  else
    while (getline(line, MAXLINE) > 0) {
      lineno++;
      i = index(line,"\f");
      if (i>=0) {
        for (i=0;i<3;i++)
          getline(line, MAXLINE);
      }
      else {
        i = index(line, "\n");
        if (i > 21) {
          i = index(line,">");
          if (i==1) {
            i = index(line, " lb");
            if (i==21)
              line[i+1] = ' ';
          }
          i = index(line, "lbra");
          if (i == 22) {
            line[22] = ' ';
            line[23] = 'j';
            line[24] = 'm';
            line[25] = 'p';
          }
          if (number)
            printf("%d: ", lineno);
          printf("%s",&line[21]);
        }
      }
    }
  flush();
}
