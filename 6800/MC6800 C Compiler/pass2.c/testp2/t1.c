sub(p)
register int *p;
{
  int d[2];
  if ((d[0] = *p++) == (d[1] = 0));
}
