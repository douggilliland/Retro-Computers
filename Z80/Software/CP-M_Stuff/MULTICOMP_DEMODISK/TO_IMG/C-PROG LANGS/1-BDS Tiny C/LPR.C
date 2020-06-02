/*
	Line printer formatter 

	Written by Leor Zolman
		   May 28, 1980

	First prints all files named on the command line, and then
	asks for names of more files to print until a null line is typed.
	Control-Q aborts current printing and goes to next file.

	Paper should be positioned ready to print on the first page; each
	file is always printed in an even number of pages so that new files
	always start on the same phase of fan-fold paper.

	Tabs are expanded into spaces.
*/

#include "bdscio.h"

#define FF 0x0c		/* formfeed character, or zero if not supported */
#define PGLEN 64	/* lines per lineprinter page */

int colno, linesleft;

main(argc,argv)
char **argv;
{
	int i, pgno, fd;
	char date[30], linebuf[135];	/* date and line buffers */
	char fnbuf[30], *fname;		/* filename buffer & ptr */
	char ibuf[BUFSIZ];		/* buffered input buffer */
	char *gets();

	pgno = colno = 0;
	linesleft = PGLEN; 
	printf("What is today's date? ");
	  gets(date);

	while (1)
	{
		if (argc-1)
		 {
			fname = *++argv;
			argc--;
		 }
		else
		 {
			printf("\nEnter file to print, or CR if done: ");
			if (!*(fname = gets(fnbuf))) break;
		 }

		if ((fd = fopen(fname,ibuf)) == ERROR)
		 {
			printf("Can't open %s\n",fname);
			continue;
		 }
		else printf("\nPrinting %-13s",fname);

		for (pgno = 1; ; pgno++)
		 {
			putchar('*');
			sprintf(linebuf,"\n%28s%-13s%5s%-3d%20s\n\n",
				"file: ",fname,"page ",pgno,date);
			linepr(linebuf);

		loop:	if (!fgets(linebuf,ibuf)) break;
			if (kbhit() && getchar() == 0x11) break;
			if (linepr(linebuf)) continue;
			if (linesleft > 2) goto loop;
			formfeed();
		 }
		formfeed();
		if (pgno % 2) formfeed();
		fabort(fd);
	}
}

/*
	Print a line of text out on the list device, and
	return true if a formfeed was encountered in the
	text.
*/

linepr(string)
char *string;
{
	char c, ffflag;
	ffflag = 0;
	while (c = *string++)
	  switch (c) {
	    case FF:
		ffflag = 1;
		break;
	    case '\n':	
		putlpr('\r');
		putlpr('\n');
		colno = 0;
		linesleft--;
		break;

	    case '\t':
		do {
		  putlpr(' ');
		  colno++;
		} while (colno % 8);
		break;

	    default:					
		putlpr(c);
		colno++;
	}
	if (ffflag) formfeed();
	return ffflag;
}

putlpr(c)
char c;
{
	bios(LIST,c);
}

formfeed()
{
	if (FF) putlpr(FF);
	else while (linesleft--) putlpr('\n');
	linesleft = PGLEN;
}
