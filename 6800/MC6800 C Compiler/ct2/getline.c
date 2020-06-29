getline(str,lim)
char str[];
int lim;
{
  int c, i;
  register char *s;

  s = str;
  for (i=0; i<lim-1 && (c=getchar()) != EOF && c != '\n'; ++i)
    s[i] = c;
  if (c=='\n') {
    s[i] = c;
    ++i;
  }
  s[i] = '\0';
  return(i);
}
