char *s1 = "abcdefghi";
char *s2 = "efg";
main() {
  abort(strcspn(s1,s2));
}
