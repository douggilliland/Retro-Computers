int extv;

main() {
  int a,b,c;
  char d,e,f;
  static statv;

  a=b|c;
  d=e|f;
  a=b|0xff;
  a=b|0xff00;
  a=b|0xffff;
  a=b|0x5555;
  a=b|d;
  a=d|b;
  d=a|e;
  d=e|a;
  a=(b+c)|(a+b);
  a=(b*c)|(a+((b+c)|0xff));
  d=e|0xff;
  d=e|0xffff;
  d=e|0xff00;
  d=e|0x5555;

  a=b^c;
  d=e^f;
  a=b^0xff;
  a=b^0xff00;
  a=b^0xffff;
  a=b^0x5555;
  a=b^d;
  a=d^b;
  d=a^e;
  d=e^a;
  a=(b+c)^(a+b);
  a=(b*c)^(a+((b+c)^0xff));
  d=e^0xff;
  d=e^0xffff;
  d=e^0xff00;
  d=e^0x5555;

  a=-b;
  d=-e;
  a=~b;
  a=~d;
  d=~e;
  d=~a;
}
