main() {
  int a,b;
  if (a==2) {
    int a,b;
    a=2;
loop: b=1;
    goto loop2;
  }
  a=5;
loop2: b=6;
  goto loop;
}
