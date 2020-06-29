#include "index.c"

#define MAXLINE 1000

main(argc, argv)
char *argv[];
{
  char line[MAXLINE], *s;
  int lineno;
  int except, number;

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
      if ((index(line, *argv) >= 0) != except) {
        if (number)
          printf("%d: ", lineno);
        printf("%s",line);
      }
    }
  flush();
}
