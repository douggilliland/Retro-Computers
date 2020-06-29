main() {
  int a;
  int *p;
  return (a+10);
  return a+10;
  a = ((int) (char *) p)++;
  a = a + ((int) (char *) p)++;
  a = ((char *) (a+2))++;
  a = (a+2)++;
}
