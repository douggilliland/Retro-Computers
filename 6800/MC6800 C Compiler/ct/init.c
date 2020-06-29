struct key {
  char *keyword;
  int  keycount;
} keytab[] = {
  "break",0,
  "case",0,
  "char",0,
  "continue",0,
  "default",0,
  "while",0
};

static int day_tab[2][13] = {
  {0,31,28,31,30,31,30,31,31,30,31,30,31},
  {0,31,29,31,30,31,30,31,31,30,31,30,31}
};
static int test = 10;
static int test2 = {10};
static int test3[3] = {1,2,3};
int x[] = {1,3,5};
int y[4][3] = {
  {1,3,5},
  {2,4,6},
  {3,5,7},
};
int q[4][3] = {
  1,3,5,2,4,6,3,5,7
};
int r[4][3] = {
  {1}, {2}, {3}, {4}
};
char msg[] = "Syntax error on line %s\n";

f(day_tab)
int day_tab[][13];
{
  int a;

  day_tab[1][5] = 20;
  a=sizeof(keytab);
  a=sizeof(x);
  a=sizeof(msg);
}
g() { day_tab[2][1] = 10; }
