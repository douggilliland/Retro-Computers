/* Print the Fibonacci series. For OS/8 native compiler or cc8 */
/* Invoke with .EXE CCR and enter this filename */
/* Note use of recursion */

int fib(n)
{
    if (n < 2)
	return n;
    else
	return fib(n-1)+fib(n-2);
}


int main()
{
	int i,rsl;
	i=1;
	while (1) {
		rsl=fib(i);
		if (rsl<0) {
			printf("Overflow at #%d = %u\r\n",i,rsl);
			break;
		}
		printf("Fib #%2d = %d\r\n",i,rsl);
		i++;
	}
}
