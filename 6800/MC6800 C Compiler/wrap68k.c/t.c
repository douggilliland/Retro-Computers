main() {
  int i;
  i = 0;
  fun(0);
}

fun(i) {
  if (i<10000)
    fun(i+1);
}
