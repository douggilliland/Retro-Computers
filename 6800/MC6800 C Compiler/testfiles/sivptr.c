#define TRUE 1
#define FALSE 0
#define SIZE 8190
#define SIZEPL 8191

char flags[SIZEPL];

main() {
  register int i;
  int prime,k,count,iter;
  register char *p;

  for (iter=1; iter <=10; iter++) {
    count=0;
    for (i=0, p=flags; i<=SIZE; i++)
      *p++ = TRUE;
    p = flags;
    for (i=0; i<=SIZE; i++) {
      if (p[i]) {
        prime = i+i+3;
        k=prime+i;
        while (k<=SIZE) {
          p[k]=FALSE;
          k += prime;
        }
        count++;
      }
    }
  }
}
