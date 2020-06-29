int seed = 7;
int buffer[1000];

main() {
  int i,j,temp;

  setstack(16000);
  for (i=0; i<10; i++) {
    for (j=0; j<1000; j++) {
      temp = random();
      if (temp<0)
        temp = -temp;
      buffer[j] = temp;
    }
    quick(0, 1000, buffer);
  }
}

quick(lo, hi, base)
int lo, hi, base[];
{
  int i,j,pivot,temp;

  if (lo < hi) {
    for (i=lo, j=hi, pivot = base[hi]; i<j;) {
      while (i<j && base[i]<pivot)
        i++;
      while (j>i && base[j]>pivot)
        j--;
      if (i<j) {
        temp = base[i];
        base[i] = base[j];
        base[j] = temp;
      }
    }
    temp = base[i];
    base[i] = base[hi];
    base[hi] = temp;
    quick(lo, i-1, base);
    quick(i+1, hi, base);
  }
}

random() {
  seed = seed * 2517 + 13849;
  return(seed);
}
