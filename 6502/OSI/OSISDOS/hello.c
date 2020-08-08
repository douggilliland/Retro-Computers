/* hello.c example	*/
/* conio.h docs - Not sure how well it matches	*/
/* 	https://digitalmars.com/rtl/conio.html		*/

#include <conio.h>	/* Console I/O	*/
#include <stdlib.h>

int main (void)
{
	unsigned char myChar;
	unsigned char loop = 1;
	unsigned char rowCount = 0;
	while(loop == 1)
	{
		if (rowCount == 0)
			clrscr();
		cprintf("Press x to exit <RETURN>.");
		myChar = cgetc ();
		if (myChar == 'X')
			loop = 0;
		cprintf("%c\n\r",myChar);
		if (rowCount++ == 14)
			rowCount = 0;
	}
    return EXIT_SUCCESS;
}
