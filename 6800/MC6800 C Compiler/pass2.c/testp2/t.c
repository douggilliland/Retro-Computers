sub(p)
register char *p;
{
  char d[2];
  if ((d[0] = *p++) == (d[1] = '\0'));
}
