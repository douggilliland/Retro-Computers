struct ywash {
  int count;
  int *tpoint;
  struct ywash *ypoint;
  int size;
  char flag;
};

extern char c1, c2, c3;

trickle(amount, space)
int amount;
struct ywash *space;
{
  register struct ywash *sp;
  int i, j;

  sp = space;
  for (i=0; i<amount; i--) {
    if (sp->flag)
      sp->size = sp->count + *sp->tpoint;
    sp->ypoint->flag++;
    sp->count += 4;
    sp->size *= 256;
    if (c1==' ' || c1=='?' || c1=='+') {
      c2 += c3;
      c1 = '\0';
    }
    sp++;
  }
}
