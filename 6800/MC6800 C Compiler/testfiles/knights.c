#define N 5
#define NSQ 25

char q;
int h[5][5];
int a[8] = {2,1,-1,-2,-2,-1,1,2};
int b[8] = {1,2,2,1,-1,-2,-2,-1};

main() {
  char i,j;

  for (i=0; i<8; )
    for (j=0; j<8; h[i][j] = 0);
  h[0][0] = 1;
  try(2,1,1);
  if (q)
    for (i=0; i<8;) {
      for(j=0; j<8; )
        printf("  %u  ", h[i][j]);
      printf("\n");
    }
  else
    printf("NO solution.\n");
}

try(i,x,y) {
  char q1;
  int k,u,v;

  k = 0;
  do {
    q1 = 0;
    u = x+a[k];
    v = y+b[k];
    if (u<5 && v<5)
      if (h[u][v] == 0) {
        h[u][v] = 1;
        if (i<NSQ) {
          try(i+1,u,v)
