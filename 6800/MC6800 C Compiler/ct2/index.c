index(s,t1)
char s[], t1[];
{
  int i,j,k;
  register char *t;

  t = t1;
  for (i=0; s[i]!='\0'; i++) {
    for (j=i, k=0; t[k]!='\0' && s[j]==t[k]; j++, k++);
    if (t[k] == '\0')
      return(i);
  }
  return(-1);
}
