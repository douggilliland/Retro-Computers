int i1, i2, i3, i4;
char c1, c2, c3, c4;
int *p1, *p2;
char array[1000];

main() {
  int a,b,c;
  char x,y,z;
  char *pc1, *pc2;

  for (a=0; a<1000; a++)
    array[a] = 0;
  for (pc1=array; pc1<&array[1000];) {
    if (*pc1++ != 0)
      abort();
  }
  c1 = c2 = 0;
  for (b=0; b<1000; b++)
    array[b] = c1++;
  for(pc2=array; pc2<&array[1000];)
    if (*pc2++ != c2++)
      abort();
  i3 = 100;
}

abort() {}
