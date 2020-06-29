struct st1 {
  int a;
  char *p;
};
main() {
  register struct st1 *sp;
  char c;
  sp++;
  sp->p++;
  sp->a++;
}
