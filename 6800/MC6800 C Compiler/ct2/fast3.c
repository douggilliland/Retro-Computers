char count;

main() {
  int a,b,c;
  int d;

  for (d=10000; d; --d) {
    count = 10;
    while (--count)
      if (count&1) a+=a;
  }
}
