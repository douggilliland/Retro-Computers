#define COUNT 10000

main() {
  int i,j,k;

  for (i=0; i<COUNT; ++i) {
    j = 240;
    k = 15;
    j = (k*(j/k));
    j = (k*(j/k));
    j = (k+k+k+k+k+k+k+k+k+k+k+k+k+k+k+k);
    k = (j-k-k-k-k-k-k-k-k-k-k-k-k-k-k-k);

    j = (j<<4); k = (k<<4);
    j = (k*(j/k));
    j = (k*(j/k));
    j = (k+k+k+k+k+k+k+k+k+k+k+k+k+k+k+k);
    k = (j-k-k-k-k-k-k-k-k-k-k-k-k-k-k-k);

    j = (j<<4); k = (k<<4);
    j = (k*(j/k));
    j = (k*(j/k));
    j = (k+k+k+k+k+k+k+k+k+k+k+k+k+k+k+k);
    k = (j-k-k-k-k-k-k-k-k-k-k-k-k-k-k-k);
  }
}
