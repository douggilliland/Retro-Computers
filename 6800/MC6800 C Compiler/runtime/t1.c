main() {
  int sflag;
  char *p;
  p = _itostr(1, 10, "0123456789", &sflag);
  abort(p,sflag);
}
