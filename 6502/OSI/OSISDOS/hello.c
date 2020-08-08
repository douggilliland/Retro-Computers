/* hello.c example	*/
/* conio.h docs - Not sure how well it matches	*/
/* 	https://digitalmars.com/rtl/conio.html		*/
/* Commands are																					*/
/* mnt - mount the SD card, load/parse the boot record 											*/
/* dir - fetch the directory from the SD card and display to the screen, starts in root folder	*/
/* cd - change directory																		*/
/* ld - load a file from the SD card															*/

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
		cprintf("\n\rCommand (M/D/C/L/R/B/W/?/X) > ");
		myChar = cgetc ();
		if (myChar == 'X')
			loop = 0;
		else if (myChar == 'M')
			cprintf("Mount ");
		else if (myChar == 'D')
			cprintf("Dir ");
		else if (myChar == 'C')
			cprintf("Chdir ");
		else if (myChar == 'L')
			cprintf("Load ");
		else if (myChar == 'R')
			cprintf("Run ");
		else if (myChar == 'S')
			cprintf("Save ");
		else if (myChar == 'B')
			cprintf("Basic ");
		else if (myChar == 'W')
			cprintf("Warm Start ");
		else
			cprintf("\n\rCommands: Mount/Dir/Chdir/Load/Run/Save/Basic/Warm/eXit");
		if (rowCount++ == 14)
			rowCount = 0;
	}
    return EXIT_SUCCESS;
}
