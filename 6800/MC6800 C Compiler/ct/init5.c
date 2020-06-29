struct key {
  char *keyword;
  int  keycount;
} keytab[7] = {
  {"break",0},
  {"case",0},
  {"char",0},
  {"continue",0},
  {"default",0},
  {"while",0}
};

static int day_tab[2][13] = {
  {0,31,28,31,30,31,30,31,31,30,31,30,31},
  {0,31,29,31,30,31,30,31,31,30,31,30,31}
};

int rrr = {10,10};
