struct sss {
  int a,b,c;
  long l;
} s1;
struct sss *s2;

main() {
  int *y;

  xxx(s2 + 1);
  xxx( (struct sss *) y + 1 );
}
