#include "putchar.c"
#include "printf.c"

#define N 6
#define NSQ 25
#define FALSE 0
#define TRUE 1

int h[N][N];
int a[9] = {0,2,1,-1,-2,-2,-1,1,2};
int b[9] = {0,1,2,2,1,-1,-2,-2,-1};

main() {
  int i,j,q;

  for (i=1; i<N; i++)
    for (j=1; j<N; j++)
      h[i][j] = 0;
  h[1][1] = 1;
  try(2,1,1,&q);
  if (q)
    for (i=1; i<N; i++) {
      for (j=1; j<N; j++)
        printf("   %d", h[i][j]);
      putchar('\n');
    }
  else
    printf("No solution.\n");
}

try(i,x,y,q)
int i,x,y;
int *q;
{
  int k,u,v,q1;

  k = 0;
  do {
    k++;
    q1 = FALSE;
    u = x + a[k];
    v = y + b[k];
    if (u>=1 && u<N && v>=1 && v<N)
      if (!h[u][v]) {
        h[u][v] = i;
        if (i<NSQ) {
          try(i+1, u, v, &q1);
          if (!q1)
            h[u][v] = 0;
        }
        else
          q1 = TRUE;
      }
  } while (!q1 && k!=8);
  *q = q1;
}
