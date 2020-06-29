main() {
  register int *p, *p2;
  int i;
  while ((i==0) && (++p < p2))
    i++;
  while (++p2 < p)
    i++;
  p2 < ++p;
  p2 = ++p;
  p2 < p++;
  p2 = p++;
  p < p2++;
  p = p2++;
  i = p++;
  i = ++p;
  i = ++p2;
  fun(++p);
  i = *(++p + 1);
}
