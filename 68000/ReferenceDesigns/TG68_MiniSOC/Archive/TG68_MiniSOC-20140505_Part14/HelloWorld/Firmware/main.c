#include "uart.h"

int main(int argc, char **argv)
{
	char c;
	puts("Hello, world!\n");

	do
	{
		c=getserial();
		putchar(c);
	} while(1);
	
	return(0);
}

