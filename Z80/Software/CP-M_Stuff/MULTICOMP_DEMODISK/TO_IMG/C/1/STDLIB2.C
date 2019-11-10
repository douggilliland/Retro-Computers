/*
	STDLIB2.C -- for BDS C v1.41 -- 10/14/80

	This file contains the source for the following
	library functions:

	printf 		fprintf		sprintf		_spr
	scanf		fscanf		sscanf		_scn
	fgets
	puts		fputs
	swapin

	Note that all the upper-level formatted I/O functions
	("printf", "fprintf", "scanf", and "fscanf") now use
	"_spr" and "_scn" for doing conversions. While
	this leads to very modularized source code, it also
	means that calls to "scanf" and "fscanf" must process
	ALL the information on a line of text; if the format
	string runs out and there is still text left in the
	line being processed, the text will be lost (i.e., the
	NEXT scanf or fscanf call will NOT find it.)

	An alternate version of "_spr" is given in the file
	FLOAT.C for use with floating point numbers; see FLOAT.C
	for details. Since "_spr" is used by "printf", this
	really amounts to an alternate version of "printf."

	Also note that temporary work space is declared within
	each of the high-level functions as a one-dimensional
	character array. The length limit on this array is
	presently set to 132 by the #define MAXLINE statement;
	if you intend to create longer lines through printf,
	fprintf, scanf, or fscanf calls, be SURE to raise this
	limit by changing the #define statement.

	Some misc. comments on hacking text files with CP/M:
	The conventional CP/M text format calls for each
	line to be terminated by a CR-LF combination. In the
	world of C programming, though, we like to just use
	a single LF (also called a newline) to terminate
	lines. AND SO, the functions which deal with reading
	and writing text lines from disk files to memory and
	vice-versa ("fgets", "fputs") take special pains to
	convert	CR-LF combinations into single '\n' characters
	when reading from disk ("fgets"), and convert '\n'
	characters to CR-LF combinations when writing TO disk
	("fputs"). This allows the C programmer to do things
	in style, dealing only with a single line terminator
	while the text is in memory, while maintaining compat-
	ibility with the CP/M text format for disk files (so
	that, for example, a text file can be "type"d under
	the CCP.)
	To confuse matters further, the "gets" function
	(which simply buffers up a line of console input)
	terminates a line with '\0' (a zero byte) instead
	of CR or LF. Thus, if you want to read in lines of
	input from the console and write them to a file,
	you'll have to manually put out the CR and LF at the
	end of every line ("gets" was designed this was to
	be compatible with the UNIX version). 

	Remember to put out a 0x1a (control-Z, CPMEOF) at
	the end of text files being written out to disk.

	Also, watch out when reading in text files using
	"getc". While a text file is USUALLY terminated
	with a control-Z, it MAY NOT BE if the file ends
	on an even sector boundary (although respectable
	editors will now usually make sure the control-Z
	is always there.) This means that there are two
	possible return values from "getc" which can signal
	an End-of file: CPMEOF ( 0x1a, or control-Z),
	ERROR (-1, or 255 if you assign it to a char variable)
	should the CPMEOF (0x1a) be missing.
*/

#include "bdscio.h"

char toupper(), isdigit();

/*
	printf

	usage:
		printf(format, arg1, arg2, ...);
	
	Note that since the "_spr" function is used to
	form the output string, and then "puts" is used to
	actually print it out, care must be taken to 
	avoid generating null (zero) bytes in the output,
	since such a byte will terminate printing of the
	string by puts. Thus, a statment such as:

		printf("%c foo",'\0');

	would print nothing at all.

	This is my latest version of the "printf" standard library
	routine. This time, folks, it REALLY IS standard. I've
	tried to make it EXACTLY the same as the version presented
	in Kernighan & Ritchie: right-justification of fields is
	now the default instead of left-justification (you can have
	left-justification by using a dash in the conversion, as
	specified in the book); the "%s" conversion can take a precision
	now as well as a field width; the "e" and "f" conversions, for
	floating point numbers, are supported in a special version of
	"_spr" given in source form in the FLOAT.C file. If you do
	a lot of number crunching and wish to have that version be the
	default (it eats up a K or two more than this version), just
	replace the version of "_spr" in DEFF.CRL with the one in FLOAT.C,
	using the CLIB program, or else be stuck with always typing in
	"float" on the clink command line...
*/

printf(format)
char *format;
{
	char line[MAXLINE];
	_spr(line,&format);	/* use "_spr" to form the output */
	puts(line);		/* and print out the line	 */
}


/*
	scanf:
	This one accepts a line of input text from the
	console, and converts the text to the required
	binary or alphanumeric form (see Kernighan &
	Ritchie for a more thorough description):
	Usage:
		scanf(format, ptr1, ptr2, ...);

	Returns number of items matched.

	Since a new line of text must be entered from the
	console each time scanf is called, any unprocessed
	text left over from the last call is lost forever.
	This is a difference between BDS scanf and UNIX
	scanf. Another is that the field width specification
	is not supported here.
*/

int scanf(format)
char *format;
{
	char line[MAXLINE];
	gets(line);			/* get a line of input from user */
	return _scn(line,&format);	/* and scan it with "_scn"	 */
}


/*
	fprintf:
	Like printf, except that the first argument is
	a pointer to a buffered I/O buffer, and the text
	is written to the file described by the buffer:
	ERROR (-1) returned on error.

	usage:
		fprintf(iobuf, format, arg1, arg2, ...);
*/

int fprintf(iobuf,format)
char *format;
struct _buf *iobuf;
{
	char text[MAXLINE];
	_spr(text,&format);
	return fputs(text,iobuf);
}


/*
	fscanf:
	Like scanf, except that the first argument is
	a pointer to a buffered input file buffer, and
	the text is taken from the file instead of from
	the console.
	Usage:
		fscanf(iobuf, format, ptr1, ptr2, ...);
	Returns number of items matched (zero on EOF.)
	Note that any unprocessed text is lost forever. Each
	time scanf is called, a new line of input is gotten
	from the file, and any information left over from
	the last call is wiped out. Thus, the text in the
	file must be arranged such that a single call to
	fscanf will always get all the required data on a
	line. This is not compatible with the way UNIX does
	things, but it eliminates the need for separate
	scanning functions for files, strings, and console
	input; it is more economical to let both "fscanf" and
	"scanf" use "sscanf". If you want to be able to scan
	a partial line with fscanf and have the rest still be
	there on the next fscanf call, you'll have to rewrite
	fscanf to be self contained (not use sscanf) and use
	"ungetc" to push back characters.

	Returns number of items succesfully matched.
*/

int fscanf(iobuf,format)
char *format;
struct _buf *iobuf;
{
	char text[MAXLINE];
	if (!fgets(text,iobuf)) return 0;
	return _scn(text,&format);
}


/*
	sprintf:
	Like fprintf, except a string pointer is specified
	instead of a buffer pointer. The text is written
	directly into memory where the string pointer points.

	Usage:
		sprintf(string,format,arg1, arg2, ...);
*/

sprintf(buffer,format)
char *buffer, *format;
{
	_spr(buffer,&format);	/* call _spr to do all the work */
}


/*
	sscanf:

	Reads a line of text in from the console and scans it
	for variable values specified in the format string. Uses
	"_scn" for actual conversions; see the comments below in
	the _scn function for more details.

	Usage:
		scanf(format,&arg1,&arg2,...);
*/

int sscanf(line,format)
char *line, *format;
{
	return _scn(line,&format);	/* let _scn do all the work */
}



/*
	General formatted output conversion routine, used by
	fprintf and sprintf..."line" is where the output is
	written, and "fmt" is a pointer to an argument list 
	which must consist of a format string pointer and
	subsequent list of (optional) values. Having arguments
	passed on the stack works out a heck of a lot neater
	than it did before when the args were passed via an
	absolute vector in low memory!
*/


_spr(line,fmt)
char *line, **fmt;
{
	char _uspr(), c, base, *sptr, *format;
	char wbuf[MAXLINE], *wptr, pf, ljflag;
	int width, precision,  *args;

	format = *fmt++;    /* fmt first points to the format string	*/
	args = fmt;	    /* now fmt points to the first arg value	*/

	while (c = *format++)
	  if (c == '%') {
	    wptr = wbuf;
	    precision = 6;
	    ljflag = pf = 0;

	    if (*format == '-') {
		    format++;
		    ljflag++;
	     }

	    width = (isdigit(*format)) ? _gv2(&format) : 1;

	    if ((c = *format++) == '.') {
		    precision = _gv2(&format);
		    pf++;
		    c = *format++;
	     }

	    switch(toupper(c)) {

		case 'D':  if (*args < 0) {
				*wptr++ = '-';
				*args = -*args;
				width--;
			    }

		case 'U':  base = 10; goto val;

		case 'X':  base = 16; goto val;

		case 'O':  base = 8;  /* note that arbitrary bases can be
				         added easily before this line */

		     val:  width -= _uspr(&wptr,*args++,base);
			   goto pad;

		case 'C':  *wptr++ = *args++;
			   width--;
			   goto pad;

		case 'S':  if (!pf) precision = 200;
			   sptr = *args++;
			   while (*sptr && precision) {
				*wptr++ = *sptr++;
				precision--;
				width--;
			    }

		     pad:  *wptr = '\0';
		     pad2: wptr = wbuf;
			   if (!ljflag)
				while (width-- > 0)
					*line++ = ' ';

			   while (*line = *wptr++)
				line++;

			   if (ljflag)
				while (width-- > 0)
					*line++ = ' ';
			   break;

		 default:  *line++ = c;

	     }
	  }
	  else *line++ = c;

	*line = '\0';
}

/*
	Internal routine used by "_spr" to perform ascii-
	to-decimal conversion and update an associated pointer:
*/

int _gv2(sptr)
char **sptr;
{
	int n;
	n = 0;
	while (isdigit(**sptr)) n = 10 * n + *(*sptr)++ - '0';
	return n;
}


/*
	Internal function which converts n into an ASCII
	base `base' representation and places the text
	at the location pointed to by the pointer pointed
	to by `string'. Yes, you read that correctly.
*/

char _uspr(string, n, base)
char **string;
unsigned n;
{
	char length;
	if (n<base) {
		*(*string)++ = (n < 10) ? n + '0' : n + 55;
		return 1;
	}
	length = _uspr(string, n/base, base);
	_uspr(string, n%base, base);
	return length + 1;
}


/*
	General formatted input conversion routine. "line" points
	to a string containing ascii text to be converted, and "fmt"
	points to an argument list consisting of first a format
	string and then a list of pointers to the destination objects.

	Appropriate data is picked up from the text string and stored
	where the pointer arguments point according to the format string.
	See K&R for more info. The field width specification is not
	supported by this version.

	NOTE: the "%s" termination character has been changed
	from "any white space" to the character following the "%s"
	specification in the format string. That is, the call

		sscanf(string, "%s:", &str);

	would ignore leading white space (as is the case with all
	format conversions), and then read in ALL subsequent text
	(including newlines) into the buffer "str" until a COLON
	or null byte is encountered.

*/

int _scn(line,fmt)
char *line, **fmt;
{
	char sf, c, base, n, *sptr, *format;
	int sign, val, **args;

	format = *fmt++;	/* fmt first points to the format string */
	args = fmt;		/* now it points to the arg list */

	n = 0;
	while (c = *format++) {
	   if (!*line) return n;	/* if end of input string, return */
	   if (isspace(c)) continue;	/* skip white space in format string */
	   if (c != '%') {		/* if not %, must match text */
		if (c != _igs(&line)) return n;
		else line++;
	    }
	   else {			/* process conversion */
		sign = 1;
		base = 10;
		sf = 0;
		if ((c = *format++) == '*') {
			sf++;		/* if "*" given, supress assignment */
			c = *format++;
		 }
		switch (toupper(c)) {
		   case 'X': base = 16;
			     goto doval;

		   case 'O': base = 8;
			     goto doval;

		   case 'D': if (_igs(&line) == '-') {
				sign = -1;
				line++;
			      }

	   doval:  case 'U': val = 0;
			     if (_bc(_igs(&line),base) == ERROR)
				return n;
			     while ((c = _bc(*line++,base)) != 255)
				val = val * base + c;
			     line--;
			     break;

		   case 'S': _igs(&line);
			     sptr = *args;
			     while (c = *line++)   {
				if (c == *format) {
					format++;
					break;
				 }
				if (!sf) *sptr++ = c;
			      }				
			     if (!sf) {
				n++;
				*sptr = '\0';
				args++;
			      }
			     continue;

		   case 'C': if (!sf) {
				poke(*args++, *line);
				n++;
			     }
			     line++;
			     continue;

		   default:  return n;
		 }
		if (!sf) {
			**args++ = val * sign;
			n++;
		 }
	}}
	return n;
}

/*
	Internal function to position the character
	pointer argument to the next non white-space
	character in the string:
*/

char _igs(sptr)
char **sptr;
{
	char c;
	while (isspace(c = **sptr)) ++*sptr;
	return (c);
}


/*
	Internal function to convert character c to value
	in base b , or return ERROR if illegal character for that
	base:
*/

int _bc(c,b)
char c,b;
{
	if (isalpha(c = toupper(c))) c -= 55;
         else  if (isdigit(c))  c -= 0x30;
	 else return ERROR;
	if (c > b-1) return ERROR;
		else return c;
}


/*
	puts:
	Write out the given string to the console.
	A newline is NOT automatically appended:
*/

puts(s)
char *s;
{
	while (*s) putchar(*s++);
}


/*
	fgets:
	This next function is like "gets", except that
	a) the line is taken from a buffered input file instead
	of from the console, and b) the newline is INCLUDED in
	the string and followed by a null byte. 
	
	This one is a little tricky due to the CP/M convention
	of having a carriage-return AND a linefeed character
	at the end of every text line. In order to make text
	easier to deal with from C programs, this function (fgets)
	automatically strips off the CR from any CR-LF combinations
	that come in from the file. Any CR characters not im-
	mediately followed by LF are left intact. The LF
	is included as part of the string, and is followed
	by a null byte. (Note that LF equals "newline".)
	There is no limit to how long a line
	can be here; care should be taken to make sure the
	string pointer passed to fgets points to an area
	large enough to accept any possible line length
	(a line must be terminated by a newline (LF, or '\n')
	character before it is considered complete.)

	The value NULL (defined to be 0 here) is returned
	on EOF, whether it be a physical EOF (attempting to
	read past last sector of the file) OR a logical EOF
	(encountered a control-Z.) The 1.3 version didn't
	recognize logical EOFs, because I did't realize how
	SIMPLE it was to implement a buffered I/O "ungetc"
	function.
*/

char *fgets(s,iobuf)
char *s;
struct _buf *iobuf;
{
	int count, c;
	char *cptr;
	count = MAXLINE;
	cptr = s;
	if ( (c = getc(iobuf)) == CPMEOF || c == EOF) return NULL;

	do {
		if ((*cptr++ = c) == '\n') {
		  if (cptr>s+1 && *(cptr-2) == '\r')
			*(--cptr - 1) = '\n';
		  break;
		}
	 } while (count-- && (c=getc(iobuf)) != EOF && c != CPMEOF);

	if (c == CPMEOF) ungetc(c,iobuf);	/* push back control-Z */
	*cptr = '\0';
	return s;
}



/*
	fputs:
	This function writes a string out to a buffered
	output file. The '\n' character is expanded into
	a CR-LF combination, in keeping with the CP/M
	convention.
	If a null ('\0') byte is encountered before a
	newline is encountered, then there will be NO
	automatic termination character appended to the
	line.
	ERROR (-1) returned on error.
*/

fputs(s,iobuf)
char *s;
struct _buf *iobuf;
{
	char c;
	while (c = *s++) {
		if (c == '\n') putc('\r',iobuf);
		if (putc(c,iobuf) == ERROR) return ERROR;
	}
	return OK;
}


/*
	swapin:
	This is the swapping routine, to be used by the root
	segment to swap in a code segment in the area of memory
	between the end of the root segment and the start of the
	external data area. See the document "SWAPPING.DOC" for
	detailed info on the swapping scheme.

	Returns ERROR (-1) on error, OK (0) if segment loaded in OK.

	This version does not check to make sure that the code
	yanked in doesn't overlap into the extenal data area (in
	the interests of keeping the function short.) But, if you'd
	like swapin to check for such problems, note that memory 
	locations ram+115h and ram+116h contain the 16-bit address
	of the base of the external data area (low order byte first,
	as usual.) By rewriting swapin to read in one sector at a time
	and check the addresses, accidental overlap into the data area
	can be avoided.
*/

swapin(name,addr)
char *name;		/* the file to swap in */
{
	int fd;
	if (( fd = open(name,0)) == ERROR) {
		printf("Swapin: cannot open %s\n",name);
		return ERROR;
	}
	if ((read(fd,addr,9999)) < 0) {
		printf("Swapin: read error on %s\n",name);
		close(fd);
		return ERROR;
	}
	close(fd);
	return OK;
}

