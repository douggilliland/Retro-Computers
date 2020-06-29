enum et {red, yellow, blue, white=10, black};
enum et e1 = white;
main() {
  int a,b;
  enum et e2 = black;
  a = black;
  e1 = 10;
  e1 = white;
  a = e1 + b + blue;
  a = sizeof(e1);
  a = sizeof(red);
  a = sizeof(enum et);
  a = &e2;
  a = &white;
}
