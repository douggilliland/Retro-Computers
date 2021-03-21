/*	c_error.c

	Mike's Enhanced Small C Compiler for Z80 & CP/M

	Errors module.

	Copyright (c) 1999-2016 Miguel I. Garcia Lopez, FloppySoftware.

	This program is free software; you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the
	Free Software Foundation; either version 2, or (at your option) any
	later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

	Revisions:

	16 Jan 2001 : Last revision.
	16 Apr 2007 : GPL'd.
	26 Oct 2015 : Cleaned.
	27 Nov 2015 : Modified some text messages.
	11 Oct 2016 : Documented and slightly optimized. Errors by id or message.
	14 Feb 2018 : Added errors ERESCSQ (bad escape sequence) and ERNOMEM (not enough memory for buffers). Added errinit macro. Added errinit().
*/

// Need a character (it's missing)

errndch(c)
char c;
{
	char s[8];  // "Need: ?" + '\0'

	strcpy(s, "Need: ?");
	s[6] = c;

	errcont_str(s);
}

// Command line error

errcmdl(id)
int id;
{
	co_str("\nError! "); co_line(errmsg(id));
	exit(1);
}

// Initialization error
errinit(id)
int id;
{
	errcmdl(id);
}

// File error

errfile(id, fname)
int id; char *fname;
{
	co_str("\nError! File: "); co_str(fname); co_str(" - "); co_line(errmsg(id));
	exit(1);
}

// Print error and continue

errcont(id)
int id;
{
	errcont_str(errmsg(id));
}

// Print error and continue

errcont_str(msg)
char *msg;
{
	errshow_str(msg);

	if(errcnt == errmax)
	{
		co_line("\nToo many errors, compilation aborted!");
		exit(1);
	}

	if(errstop)
	{
		if(getch() == '.')
			errstop = 0;
	}
}

// Print error and exit

errexit(id)
int id;
{
	errshow(id);
	exit(1);
}

// Print error

errshow(id)
int id;
{
	errshow_str(errmsg(id));
}

// Print error

errshow_str(msg)
char *msg;
{
	int i;

	fo_nl(); co_nl();

	comment();
	fo_str(co_str("Error!")); fo_dec(co_dec_5(++errcnt)); fo_ch(co_ch(' '));
	fo_str(co_str("Line: ")); fo_dec(co_dec_5(fi_line));  fo_ch(co_ch(' '));
	fo_str(co_str("File: ")); fo_line(co_line(fi_name));

	comment();
	fo_line(co_line(msg));

	comment();
	for(i = 0; line[i]; ++i)
	{
		fo_ch(co_ch(line[i] == '\t' ? ' ' : line[i]));
	}

	fo_nl(); co_nl();

	comment();
	for(i = 0; i < lptr; ++i)
	{
		fo_ch(co_ch(' '));
	}

	fo_ch(co_ch('^'));
	fo_nl(); co_nl();
}

// Return error message

errmsg(id)
int id;
{
	switch(id)
	{
		// Compiler
		case ERCONST : return "Must be constant";
		case ERARRPT : return "Illegal *[]";
		case ERARRSZ : return "Illegal array size";
		case ERCNTAS : return "Can't assign";
		case ERARGNB : return "Illegal number of arguments";
		case ERARGNM : return "Need name of argument";
		case ERFUNDE : return "Illegal function declaration";
		case ERSYMNM : return "Illegal symbol name";
		case ERALDEF : return "Already defined";
		case EROFGLB : return "Global symbol table is full";
		case EROFLOC : return "Local symbol table is full";
		case ERTMWHI : return "Too many whiles";
		case ERNOWHI : return "No active whiles";
		case EREXWHI : return "Need a while";
		case ERLTLNG : return "Line too long";
		case ERTMCAS : return "Too many cases";

		// Expression parser
		case ERSIZOF : return "Illegal use of sizeof";
		case EROFSTR : return "String table is full";
		case ERILADR : return "Illegal address";
		case ERCTSUB : return "Can't index";
		case ERINVEX : return "Illegal expression";
		case ERMBLVL : return "Must be lvalue";
		case ERESCSQ : return "Bad escape sequence";

		// Preprocessor
		case ERASMWE : return "#asm without #endasm";
		case EREASWA : return "#endasm without #asm";
		case ERMACAD : return "Macro already defined";
		case ERTMIFS : return "Too many active #ifs";
		case ERELSEW : return "#else without #if";
		case ERENDIF : return "#endif without #if";
		case ERBADCM : return "Illegal # command";
		case EROFMAC : return "Macro table if full";
		case ERTMINC : return "Too many active includes";

		// File I/O
		case EROPEN  : return "Can't open";
		case ERWRITE : return "Can't write";
		case ERCLOSE : return "Can't close";

		// Command line
		case ERCMDLN : return "Illegal option";
		case ERCMDER : return "Illegal max. number of errors";
		case ERCMDLB : return "Illegal label";
		case ERCMDST : return "Illegal size of stack";

		// Initialization
#ifdef C_USEMALLOC
		case ERNOMEM : return "Not enough memory for buffers";
#endif
	}

	// Unknown error id
	return "Unknown error";
}
