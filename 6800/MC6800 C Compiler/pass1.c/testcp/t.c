struct st1 {
  struct st1 *a;
  struct st1 *b;
  int c;
};
main() {
  register struct st1 *p;
  fun(p->a, p->b - p->a->b);
}
