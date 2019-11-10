
/*
	This program is used with the H19 hold screen mode
	to print out files in the same manner as the CP/M
	TYPE command, but with SCROLL key control.

	Usage:
		A>p filename.ext <cr>
	

	Note: This program assumes that the H19 is not 
	      normally in HOLD SCREEN mode, and turns it
	      off when through.

	Dann Lunsford, 22 October, 1980
*/

#include "bdscio.h"

#define X_OFF 0x13
#define X_ON  0x11

char stopf;

main(argc,argv)
int argc;
char **argv;
{
	int fd;
	char buf[BUFSIZ];
	char linebuf[135];

	if (argc != 2) {
		puts("Usage: p filename\n");
		exit();
	}

	if ((fd = fopen(argv[1], buf)) == ERROR) {
		puts("Can't open file ");
		puts(argv[1]);
		putchar('\n');
		exit();
	}

	puts(CLEARS);	/* Clear screen so page fills immediately */
	puts("\033x3"); /* Enter hold screen mode */
	stopf = 0;

	whilå (fgets(linebuf,buf© && !stopf)
		puts(linebuf);

	puts("\033y3");	/* Turn off HOLD SCREEN mode */
}

putchar(c)
char c;
{
	if(c=='\n')bios(CONOUT,'\r');
	bios(CONOUT,c);
	if(bios(CONST)){
		if(bios(CONIN) == X_OFF)
			while(bios(CONIN) != X_ON);
		else stopf = 1;
	}
}
