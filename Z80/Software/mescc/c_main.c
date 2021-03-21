/*	c_main.c

	Mike's Enhanced Small C Compiler for Z80 & CP/M

	Main module.

	Copyright (c) 1999-2016 Miguel I. Garcia Lopez

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

	16 Jan 2001 : Minor changes.
	20 Dec 2003 : Minor changes.
	20 Apr 2004 : Last revision.
	16 Apr 2007 : GPL'd.
	14 Dec 2013 : BUG solved in dofor(): 'continue' jumped to expresion test, instead of increment expr.
	10 Apr 2015 : Removed -A option (argc & argv support in mescc.h - now is managed by macro def. CC_NO_ARGS).
	16 Aug 2015 : Amended some comments and messages.
	26 Oct 2015 : Removed init_files() and cpp_end() calls.
	20 Nov 2015 : Updated, symbol has a new field SY_FLAGS.
	22 Nov 2015 : More on variable and array assignments. Cleaned a bit.
	              Solved bug when an empty function was declared (return was not written).
	26 Nov 2015 : More on array assignments.
	27 Nov 2015 : Modified some text messages.
	29 Nov 2015 : Modified dofor() to support forever loops: for(;;){...}.
	01 Nov 2015 : Emit function labels without ':' -- see newfunc().
	11 Oct 2016 : Changes in doswtch() output to help the optimizer. Extract parser functions to c_parser.c. Documented. Optimized.
	24 Oct 2016 : Option S to set default type for char to signed or unsigned.
	14 Feb 2018 : Use malloc() optionally.
*/

// Globals
// -------

#ifdef C_USEMALLOC

char *glbsymtab,            // Global symbol table
	 *glbend,               // End of global symbol table
     *glbptr;               // Pointer

char *locsymtab,            // Local symbol table
     *locend,               // End of local symbol table
	 *locptr;               // Pointer

char *litq;                 // String pool
int  litptr;                // Index

#else

char glbsymtab[GLB_TABSIZ],	// Global symbol table
     *glbptr;               // Pointer

char locsymtab[LOC_TABSIZ], // Local symbol table
	 *locptr;               // Pointer

char litq[STRBUF_SIZ];      // String pool and pointer
int  litptr;                // Index

#endif

int	wq[WQ_TABSIZ],          // While queue
	*wqptr;                 // Pointer

char line[LN_SIZ];          // Parsing line buffer
int	 lptr;                  // Index

int	letlab,        // Label letter
	errstop,       // Pause on error?
	eof,           // Non zero after final input
	ctext,         // Non-zero if C source to be included as comment
	typout,        // Output type: 0 = program, 1 = library, 2 = assembler
	lastst,        // Type of last executed statement
	nxtlab,        // Next label number
	litlab,        // String pool label
	sptr,          // Relative SP
	argstk,        // Function arg. SP
	argtop,        // Function arg. top SP
	errcnt,        // Error count
	errmax,        // Max. num. of errors,
	uchar,         // Default type for char is unsigned?
	locsiz,        // Size of local variables in a function
	stksize;       // Stack size for program

char ipfname[FILENAME_MAX],   // Input file name
	 opfname[FILENAME_MAX];   // Output file name

// C Preprocessor
// --------------

int	cppinasm,      // TRUE = #asm active
	cppincmt,      // TRUE = multi-line comment active
	cppinign,      // TRUE = #if FALSE active (ignored code)

	cppiflev,      // #if level
	cppifact;      // Active #if level

int  cppincs;              // Number of active #includes
WORD cppfps[CPPMAXINC];    // FPs for active includes - FILE *cppfps[x]
int  cpplines[CPPMAXINC];  // Number of current line for active #includes
char cppfnames[45];        // Buffer for filenames == CPPMAXINC * FILENAME_MAX

char cpptmp[LN_SIZ];       // Line buffer
int  cpptmpx;              // Index to line buffer

#ifdef C_USEMALLOC

char *cppmac;              // Macro buffer
int  cppmacx;              // Index to macro buffer

#else

char cppmac[CPPMACSIZ];    // Macro buffer
int  cppmacx;              // Index to macro buffer

#endif

int  cpphash[CPPHASHSIZ];  // Hash for macros

// File I/O
// --------

// Current input file
FILE *fi_fp;                 // File handle
char fi_name[FILENAME_MAX];  // File name
int  fi_line;                // Line number
int  fi_eof;                 // TRUE = EOF

// Output file
FILE *fo_fp;                 // File handle
char fo_name[FILENAME_MAX];  // File name

// Entry point to compiler
// ----------------------

main(argc,argv)
int argc, argv[]; // MESCC doesn't have char *argv[] yet...
{
	// Print title, version, etc.
	title();

	// Print help text if there are no arguments
	if(argc == 1)
	{
		help();	return;
	}

#ifdef C_USEMALLOC

	// Alloc memory for buffers
	if(!(glbsymtab = malloc(GLB_TABSIZ)) || !(locsymtab = malloc(LOC_TABSIZ)) || !(litq = malloc(STRBUF_SIZ)) || !(cppmac = malloc(CPPMACSIZ)))
	{
		errinit(ERNOMEM);
	}

	glbend = glbsymtab + GLB_TABSIZ;
	locend = locsymtab + LOC_TABSIZ;

#endif

	// Setup default values
	errstop  = 1;
	errmax   = 50;
	letlab   = 'a';
	typout   = OUT_PRG;
	*opfname = '\0';
	stksize  = 512;
	/* Already 0 *******************
	ctext = uchar = nxtlab = 0;
	********************************/

	// Parse options from command line
	getargs(argc - 1, &argv[1]);

	// Setup globals
	glbptr = GLB_START;
	locptr = LOC_START;
	wqptr  = wq;
	litlab = getlabl();
	/* Already 0 ******************************
	litptr = sptr = errcnt = eof = lastst = 0;
	*******************************************/

	// Setup files
	//init_files();

	// Setup preprocessor
	cpp_start();

	// Open files
	fi_open(ipfname);
	fo_open(opfname);

	// Send header to output file
	a_start();

	// Process all input
	parse();

	// Print \n
	co_nl();

	// Dump string literals
	dmplits();

	// Dump globals
	dmpglbs();

	// Send footer to output file
	a_end();

	// Close files
	fo_close();
	fi_close();

	// Say good bye to the C preprocessor
	//cpp_end();

	// Print \n
	co_nl();

	// Print summary
	co_line("Table    Used  Free");
	co_line("-------- ----- -----");
	co_str("Strings  "); co_dec_5(litptr) ;co_ch(' '); co_dec_5(STRBUF_SIZ - litptr); co_nl();
	co_str("Globals  "); co_dec_5(glbptr - GLB_START); co_ch(' '); co_dec_5(GLB_END - glbptr); co_nl();
	co_str("Macros   "); co_dec_5(cppmacx) ;co_ch(' '); co_dec_5(CPPMACSIZ - cppmacx); co_nl();

	co_nl();

	co_str("Errors:     "); co_dec(errcnt); co_nl();
	co_str("Next label: "); co_ch(letlab); co_dec(nxtlab); co_nl();
}

// Parse options from command line

getargs(argcnt, argstr)
int argcnt, argstr[];
{
	int i;
	char *ptr, *ptr3, *ptr4;

	// Input file name
	strcpy(ipfname, argstr[0]);

	// Parse options from command line
	for(i = 1; i < argcnt; ++i)
	{
		ptr  = strupr(argstr[i]);  // FIXME - This is for some emulators which not convert command line to upper case (!)

		// -O:AB
		ptr3 = ptr + 3; // Pointer to A
		ptr4 = ptr + 4; // Pointer to B

		if(*ptr++ != '-')
			errcmdl(ERCMDLN);

		// Output file name
		if((!memcmp("O:", ptr, 2)) && *ptr3)
			strcpy(opfname, ptr3);

		// Output file type
		else if(!strcmp("PRG", ptr))
			typout = OUT_PRG;
		else if(!strcmp("LIB", ptr))
			typout = OUT_LIB;
		else if(!strcmp("ASM", ptr))
			typout = OUT_ASM;

		// Write C source as comments?
		else if(!strcmp("C+", ptr))
			ctext = 1;
		else if(!strcmp("C-", ptr))
			ctext = 0;

		// Pause on errors?
		else if(!strcmp("E+", ptr))
			errstop = 1;
		else if(!strcmp("E-", ptr))
			errstop = 0;

		// Default type for char is unsigned?
		else if(!strcmp("S+", ptr))
			uchar = 0;
		else if(!strcmp("S-", ptr))
			uchar = 1;

		// Max. number of errors to abort compilation
		else if((!memcmp("E:", ptr, 2)) && *ptr3)
		{
			if((errmax = atoi(ptr3)) < 0)
				errcmdl(ERCMDER);
		}

		// Letter and start number for labels
		else if((!memcmp("L:", ptr, 2)) && *ptr3 && *ptr4)
		{
			if(!isalpha((letlab = *ptr3)) || (nxtlab = atoi(*ptr4)) < 0)
				errcmdl(ERCMDLB);
		}

		// Stack size
		else if((!memcmp("S:", ptr, 2)) && *ptr3)
		{
			if((stksize = atoi(ptr3)) < 512)
				errcmdl(ERCMDST);
		}

		// Unknown option
		else
			errcmdl(ERCMDLN);
	}

	// Add type to input file name if needed
	if(!strchr(ipfname, '.'))
		strcat(ipfname, ".c");

	// Add name without type to output file name if needed
	if(!(*opfname))
	{
		strcpy(opfname, ipfname);
		ptr = strchr(opfname, '.');
		*ptr = 0;
	}

	// Add type to output file name if needed
	if(!strchr(opfname, '.'))
		strcat(opfname, typout == OUT_LIB ? ".lib" : ".zsm");
}

// Print title, version, etc.

title()
{
	co_line(VERSION); co_nl();
	co_line(COPYRGT); co_nl();
}

// Print help text

help()
{
	co_line("Usage: cc name[.typ] [options]\n");
	co_line("-PRG          Out normal file ---- Type=ZSM");
	co_line("-LIB          Out library file --- Type=LIB");
	co_line("-ASM          Out assembler file - Type=ZSM");
	co_line("-O:name[.typ] File name for output");
	co_line("-Cflag        C source as comments?");
	co_line("-Eflag        Pause on errors?");
	co_line("-Sflag        Default type for char is signed?");
	co_line("-E:number     Max. number of errors to abort");
	co_line("-L:letnum     Letter and start number for labels");
	co_line("-S:size       Mininum stack size\n");
	co_line("Default options are: (flag is + for YES, - for NO)\n");
	co_line("\t-PRG -C- -E+ -S+ -E:50 -L:A0 -S:512");
	co_line("\tInput file type is .c");
	co_line("\tOutput file name is the same as input");
}
