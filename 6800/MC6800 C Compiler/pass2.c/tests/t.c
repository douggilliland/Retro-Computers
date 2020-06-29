char buf[10000];
main() {
  register char *p;
  register int i,j;
  char c;
  i = 1;
  p = buf;
  for (c=0, j=0; j<10000; c++, j++) {
    if ((c & 63) == 63) {
      *p++ = '\n';
      i = i * 16;
    }
    else if (j==12 || j==567 || j==1011 || j==4290 || j==7888
             || j==9001 || j==9623) {
      *p++ = c + 'a';
      i = 1;
    }
    else {
      *p++ = '\0';
      i = i * 256;
    }
  }
}
