


/*
	This program accepts a list of filenames, which 
	should represent ascii files on the disk, and
	prints them out on the CP/M list device.
	There is nothing particularly fascinating about
	this program; it is included mainly as an example
	of file I/O handling in C.

	Note the use of ARGC and ARGV in main; the names
	themselves mean "arg count" and "arg vector", and
	point out that upon entry to the "main" program,
	your command line arguments are available for
	processing. ARGC is equal to the number of arguments
	given on the command line PLUS ONE, and ARGV tells you
	the address of the beginning of each argument. Thus,
	the expression
			argv[1]
	represents the address of the first character of the
	first argument string;
			argv[2]
	would be the address of the second argument string,
	etc. By convention, argv[0] is not used, since 0
	arguments is a special case. On UNIX C, the original
	C, argv[0] would point to the command itself
	(i.e., the string 'foo' in
		A> foo arg1 arg2 arg3 )
	But, unfortunately, CP/M doesn't bother to save that
	part of the command line, so the C COM file can never
	see what its name really is.
	Note that ARGV can NEVER equal zero; the case of zero
	arguments causes ARGV to be equal to 1. Again, this
	is to maintain compatibility with UNIX C.

	Alternatively (and, in fact, how it is done here), it
	is possible to use the variable argv as a pointer, so
	that the value of
			*++argv
	upon entry to main would point to the first
	argument string; after incrementing argv again
	it would point to the second argument string, etc.
	Note how the increment operation specified by
			argv++
			 or
			++argv
	knows to add 2 to argv, since argv was declared as
	a pointer to pointers, and pointers take 2 bytes!
	Thus, should argv have been (incorrectly) declared
			char *argv;
	then the
			argv++
	operation would add only 1 to argv, instead of 2.

	Oh well, enough tutorial. Here's the program...

*/


#define BUFSIZ 8192

int lpos;
int lines;

main(argc,argv)
int argc;
char **argv;
{
	outp(0,8); /* set 3P+S to 1200 baud */
	while (--argc) {
		printf("\nPrinting %s...\n",*++argv);
		putlist(*argv);
	 }
}

putlist(file)
char *file;
{
	char buffer[BUFSIZ];
	int fd,i,j;
	int nsects;
	lpos=1; /* keep track of print head position */
	nsects = BUFSIZ/128;
	bdos(5,0x0d);
	for(i=0; i<8; i++) bdos(5,0x0a);
	lines=1;
	fd=open(file,0);
	if ( fd == -1) return;
	while ((j= read(fd,buffer,nsects))==nsects)
		putchunk(buffer);
	if (j) putchunk(buffer);
	close(fd);
}


/*
	This routine puts BUFSIZ characters (or until EOF)
	out on the list device.
*/

putchunk(buffer)
char *buffer;
{
	char c;
	int i,j,k;
	for (k=0; k<BUFSIZ; k++)
	switch (c= *buffer++) {
		case '\r':
			bdos(5,'\r');
			putchar('\r');
			lpos = 0;
			break;

		case '\t':
			while(lpos%8) { lpos++;
					bdos(5,' ');
					putchar(' ');
					}
			bdos(5,' '); putchar(' ');
			lpos++;
			break;

		case 0x1a:
			return;

		case 0x0a:
			lines++;
			if(lines==6) {
			printf("\nTear off page...\n");
			wait(300); /* give him 30 seconds */
			 }
			if(lines==60) {
				for(i=0; i<10; i++)
					bdos(5,0x0a);
				lines=1;
				for(i=0; i<5000; i++);
			 }
		default:
			bdos(5,c);
			putchar(c);
			lpos++;
	}
}


/* routine to wait for a specified number of
  tenths of a second and return the number of tenths
  of a second it took the user to type something */

wait(n)
int n;
{
	int i;
	int j;
	for (i=1; i<n+1; i++)
		for (j=0; j<165; j++)
		if (bdos(11)&1) return i;
	return n;
}
