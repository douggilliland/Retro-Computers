/* Program from page 74 */

#define EOF  (-1)

#define MAXOP  20
#define NUMBER '0'
#define TOOBIG '9'

main()    /* reverse polish desk calculator */
{
   int type;
   char s[MAXOP];
   double op2, atof(), pop(), push();

   while ((type = getop(s,MAXOP)) != 0)
       switch (type) {

       case NUMBER:
           push(atof(s));
           break;
       case '+':
           push(pop() + pop());
           break;
       case '*':
           push(pop() * pop());
           break;
       case '-':
           op2 = pop();
           push(pop()-op2);
           break;
       case '/':
           op2 = pop();
           if (op2 != 0)
               push(pop() / op2);
           else
               printf("zero divisor popped\n");
           break;
       case '=':
           printf("\t%f\n", push(pop()));
           break;
       case 'c':
           clear();
           break;
       case TOOBIG:
           printf("%.20s ... is too long\n", s);
           break;
       default:
           printf("unknown command %c\n", type);
           break;
       }
}

#define MAXVAL 100

int sp = 0; /* stack pointer */
double val[MAXVAL];  /* value stack */

double push(f)  /* push f onto value stack */
double f;
{
   if (sp<MAXVAL)
       return(val[sp++] = f);
   else {
       printf("error: stack full\n");
       clear();
       return(0);
   }
}

double pop()  /* pop top value from stack */
{
   if (sp > 0)
       return(val[--sp]);
   else {
       printf("error: stack empty\n");
       clear();
       return(0);
   }
}

clear()  /* clear stack */
{
   sp = 0;
}

getop(s,lim)  /* get next operator or operand */
char s[];
int lim;
{
  int i, c;

  while ((c = getch()) == ' ' || c == '\t' || c == '\n')
    ;
  if (c != '.' && (c<'0' || c>'9'))
    return(c);
  s[0] = c;
  for (i=1; (c=getchar()) >= '0' && c<='9'; i++)
    if (i<lim)
      s[i] = c;
  if (c=='.') {
    if (i<lim)
      s[i]=c;
    for (i++; (c=getchar())>='0' && c<='9'; i++)
      if (i<lim)
        s[i]=c;
  }
  if (i<lim) {
    ungetch(c);
    s[i] = '\0';
    return(NUMBER);
  } else {
      while (c!='\n' && c!=EOF)
        c=getchar();
      s[lim-1] = '0';
      return(TOOBIG);
  }
}

#define BUFSIZE 100

char buf[BUFSIZE];
int bufp = 0;

getch()
{
  return((bufp>0) ? buf[--bufp] : getchar());
}

ungetch(c)
int c;
{
  if (bufp > BUFSIZE)
    printf("ungetch: too many characters\n");
  else
    buf[bufp++] = c;
}
