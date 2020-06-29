main() {
  int a,b,c;

  a=(b>c)? b+c: b-c;
  a=b?a:c;
  a=max(a,b,c);
}

max(a,b,c) {
  int m;

  m=(a>b) ? a : b;
  return((m>c) ? m : c);
}
