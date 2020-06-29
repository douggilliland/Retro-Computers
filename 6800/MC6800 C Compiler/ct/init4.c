struct key {
  char *keyword;
  int  keycount;
  char message[3];
} keytab[] = {
  "break",0,"xx",
  "case",0,"xx",
  "char",0,
  "continue",0,"xx",
  "default",0,"xx",
  "while",0,"xx"
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
  day_tab[1][5] = 20;
}
g() { day_tab[2][1] = 10; }
