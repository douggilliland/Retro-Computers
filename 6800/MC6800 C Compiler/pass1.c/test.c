main() {
  int a,b;
  char c;

  b = (int) c;
  b = (char *) c;
  b = sizeof a;
  b = sizeof(a);
  b = sizeof (int [10]);
  b = sizeof(int);
  b = sizeof (int *);
  b = sizeof (int *[3]);
  b = sizeof (int (*)[3]);
  b = sizeof (int *());
  b = sizeof (int (*)());
}
