main() {
  int i;
  unsigned value, fib();

  for (i=1; i<=10; i++)
    value = fib(24);
}

unsigned fib(x)
int x;
{
  if (x>2)
    return(fib(x-1) + fib(x-2));
  else
    return(1);
}
