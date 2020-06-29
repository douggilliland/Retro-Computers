struct st1 {
  int a;
  char *p;
};
main() {
  register struct st1 *sp;
  struct st1 *sp2;
  char *pp;
  char c;
  *++sp->p = c;
  pp = sp->p;
  pp = ++sp;
}
