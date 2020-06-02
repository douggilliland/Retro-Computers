
/*

	This is a simple example of recursion in C.
	Both the "fibo" and "fact" functions call 
	themselves (recurse).
	Note that the results of the computations become
	meaningless above certain values of n due to the
	16-bit value limit. Oh well.

*/


main()
{
	int n;
	printf("\n\n	\"To iterate is human;\n");
	printf("	to recurse is divine.\"\n\n");
	printf("At the question mark, enter an integer n.\n");
	printf("If n is positive, n! will be printed;\n");
	printf("If n is negative, the  |n|th fibonacci number\n");
	printf("will be printed. \n");
	printf("Enter a null line or 0 to quit.\n\n");
	while (n = getnum())
	if (n>0)
	printf("Factorial %d = %u\n",n,fact(n));
	else printf("Fibonacci number #%1d = %u\n",-n,fibo(-n));
}

fact(n)
int n;
{
	return n>2 ? n * fact(n-1) : n;
}

fibo(n)
{
	return n<3 ? 1 : fibo(n-1)+fibo(n-2);
}


getnum()
{
	char input[100];
	printf("? ");
	return atoi(gets(input));
}

