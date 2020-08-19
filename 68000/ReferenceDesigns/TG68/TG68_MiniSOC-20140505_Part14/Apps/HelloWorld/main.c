#include "uart.h"
#include "small_printf.h"

int main(int argc, char **argv)
{
	printf("Hello World\n");
	printf("Hello number %d\n",42);
	printf("Printf with a string: %s\n","Yes, a string!");
	return(0);
}

