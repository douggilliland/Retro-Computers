
/*
	This command prints out a given file with line
	numbers. Usage:

		A>pnum filename <cr>

	written by Leor Zolman
		   Jan, 1980

	The last statement of this program is a hint
	as to the kind of power C can provide...
*/

#include "bdscio.h"

main(argc,argv)
char **argv;
{
	int fd, lnum;
	char buf[BUFSIZ];
	char linebuf[135];

	if (argc != 2) {
		printf("Usage: pnum filename\n");
		exit();
	}

	if ((fd = fopen(argv[1], buf)) == ERROR) {
		printf("cannot open: %s\n",argv[1]);
		exit();
	}

	lnum = 1;

	while (fgets(linebuf,buf))
		printf("%4d: %s", lnum++, linebuf);
}

