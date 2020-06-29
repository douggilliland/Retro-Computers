#define TRUE 1
#define FALSE 0
#define SIZE 8190
#define SIZEPL 8191

char flags[SIZEPL];

main() {
  int i,prime,k,count,iter;

  for (iter=1; iter <=10; iter++) {
    count=0;
    for (i=0; i<=SIZE; i++)
      flags[i] = TRUE;
    for (i=0; i<=SIZE; i++) {
      if (flags[i]) {
        prime = i+i+3;
        k=i+prime;
        while (k<=SIZE) {
          flags[k]=FALSE;
          k += prime;
        }
        count = count+1;
      }
    }
  }
}
