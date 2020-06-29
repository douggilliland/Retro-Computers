int extv;

main() {
  int a,b,c;
  char d,e,f;
  static statv;

  a=b&0xff;
  a=b&0xff00;
  a=b&c;
  f=a;
  a=f;
  a=12&b;
  a=(b+c)&(extv-statv);
  a=(b+c)*(extv&(b-100));
  a=(b+c)&(d*(b+f));
  a=b&extv;
  a=b&statv;
  d=e&'\77';
  d=e&f;
  d=e&0xff;
  d=e&0xffff;
  a=b&0xffff;
}
