main() {
  int a,b,c,d;

  c = 8;
  for (d=0; d<10000; d++) {
    a = b<<2;
    a = b<<4;
    a = b<<6;
    a = b<<8;
    a = b<<10;
    a = b<<12;
    a = b<<14;
    a = b<<c;
  }
}
