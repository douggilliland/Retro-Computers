/*	c_cpp.c

	Mike's Enhanced Small C Compiler for Z80 & CP/M

	Integrated preprocessor module.

	Copyright (c) 1999-2021 Miguel I. Garcia Lopez, FloppySoftware.

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
	14 Aug 2015 : Added support for simple comments: // comment.
	26 Oct 2015 : Added included files control (removed from c_iofile.c).
	              Removed cpp_end(). Cleaned.
	20 Jul 2016 : Removed error message in p_macdel() if macro doesn't exists.
	12 Aug 2016 : Support for indented #commands.
	11 Oct 2016 : Documented and slightly optimized.
	12 Oct 2016 : Change input '\t' to ' ' in cpp_read().
	13 Oct 2016 : Now cpp_read() skip empty lines (both C and assembler) and comments (assembler).
	04 Jan 2021 : Remove space on the right in p_prep().
*/

// Types of symbol preprocess

#define CPP_SYM_NO  0  // No preprocessing of symbols
#define CPP_SYM_YES 1  // Preprocessing of symbols

// Setup CPP

cpp_start()
{
	/* NOT NEEDED: ALL INITIAL VALUES ARE 0 ****************
	int i;

	// Setup initial values

	cppinasm =
	cppincmt =
	cppinign =
	cppiflev =
	cppifact =
	cppmacx  =
	cppincs  = 0;

	for(i = 0; i < CPPHASHSIZ; ++i)
		cpphash[i] = 0;
	********************************************************/
}

// Execute a #command

p_cmd()
{
	// Skip #
	BfGet();

	// Check if #asm is active
	if(cppinasm)
	{
		// Check if it's #endasm
		if(InSymEq("endasm"))
		{
			p_endasm();
			BfKill();
			return;
		}

		// Error: #endasm expected
		errcont(ERASMWE);

		cppinasm = 0;
	}

	// Following commands are executed always
	if(InSymEq("if"))
		p_if(0);
	else if(InSymEq("else"))
		p_else();
	else if(InSymEq("endif"))
		p_endif();
	else if(InSymEq("ifdef"))
		p_if(1);
	else if(InSymEq("ifndef"))
		p_if(2);

	// Don't execute following commands if we are in a 'false' if or else
	else if(cppinign)
	{
		BfKill(); return;
	}
	else if(InSymEq("define"))
		p_define();
	else if(InSymEq("undef"))
		p_undef();
	else if(InSymEq("include"))
		p_include();
	else if(InSymEq("asm"))
		p_asm();
	else if(InSymEq("endasm"))
		p_endasm();

	// Unknown #command
	else
		errcont(ERBADCM);

	// Discard remain contents
	BfKill();
}

// Define a macro: #define name value

p_define()
{
	char s[NAME_SIZ];

	// Skip blanks
	BfBlanks();

	// Get name
	if(!symname(s))
	{
		errcont(ERSYMNM); return;
	}

	// Skip blanks
	BfBlanks();

	// Preprocess the value
	p_prep(CPP_SYM_YES);

	// Add macro
	p_macput(s, line);
}

// Undefine a macro: #undef name

p_undef()
{
	char s[NAME_SIZ];

	// Skip blanks
	BfBlanks();

	// Get name
	if(!symname(s))
	{
		errcont(ERSYMNM); return;
	}

	// Delete macro
	p_macdel(s);
}

// Include file: #include <filename> | "filename"

p_include()
{
	char chend;

	// Skip blanks
	BfBlanks();

	// Preprocess the value
	p_prep(CPP_SYM_YES);

	// Print message
	msgindent(); co_str("#include "); co_line(line);

	// Get filename
	if(*line=='<')        // <filename>
		chend='>';
	else if(*line=='"')   // "filename"
		chend='"';
	else
		errcont(ERBADCM); // Bad syntax

	// Skip < or "
	BfGet();

	// Get filename
	while(BfNeq(chend))
	{
		if(!BfGet())
		{
			// Error: > or " missing
			errcont(ERBADCM); return;
		}
	}

	// Set end of filename
	*(line + lptr) = 0;

	// Open file
	if(cppincs == CPPMAXINC) 
		errfile(ERTMINC,line+1);

	cppfps[cppincs]   = fi_fp;
	cpplines[cppincs] = fi_line;
	strcpy(cppfnames + cppincs * FILENAME_MAX, fi_name);

	++cppincs;

	fi_open(line + 1);
}

// End included file

p_endinc()
{
	fi_close();

	fi_fp   = cppfps[--cppincs];
	fi_line = cpplines[cppincs];
	strcpy(fi_name, cppfnames + cppincs * FILENAME_MAX);

	fi_eof = 0;

	// Print message
	msgindent(); co_line("#end include");
}

// Assembler code: #asm

p_asm()
{
	// Print message on output file for the optimizer
	a_opt(0);

	// Set flag
	cppinasm = 1;
}

// End assembler code

p_endasm()
{
	// Check if #asm is active
	if(cppinasm)
	{
		// Print message on output file for the optimizer
		a_opt(1);

		// Unset flag
		cppinasm = 0;
	}
	else
		errcont(EREASWA);
}

// Test command:
// iftype = 0 -> #if     constantValue
// iftype = 1 -> #ifdef  macroName
// iftype = 2 -> #ifndef macroName

p_if(iftype)
int iftype;
{
	char s[NAME_SIZ];
	int val;

	// Check for too many active #ifs
	if(cppiflev == CPPMAXIFS)
	{
		errcont(ERTMIFS); return;
	}

	// Check if we have to execute this #if
	if(!(cppiflev == cppifact && cppinign == 0))
	{
		// Ignore it
		++cppiflev;	return;
	}

	// Skip blanks
	BfBlanks();

	// Add #if level
	++cppiflev;
	++cppifact;

	// Execute it
	if(iftype)
	{
		// Get macro name
		if(!symname(s))
		{
			// Error: bad macro name
			errcont(ERSYMNM);
			cppinign = 1;
			return;
		}

		// Check if the macro exists
		cppinign = p_macfind(s) != -1 ? 0 : 1; // FIXME -- cppinign = p_macfind(s) == -1 ???

		// Reverse result on #ifndef
		if(iftype == 2)
			cppinign = 1 - cppinign; // FIXME -- Would it be better 'cppinign = !cppinign'?
	}
	else
	{
		// Preprocess the value
		p_prep(CPP_SYM_YES);

		// Get value
		val = 0; number(&val);

		cppinign = val ? 0 : 1; // FIXME -- cppinign = !val ???
	}
}

// Test commando: #else
	
p_else()
{
	// Check if there are active #ifs
	if(!cppiflev)
		errcont(ERELSEW);
	else if(cppiflev == cppifact)
	{
		// Toggle flag
		cppinign = 1 - cppinign; // FIXME -- cppinign = !cppinign ???
	}
}

// End test command: #endif

p_endif()
{
	// Check if there are active #ifs
	if(!cppiflev)
	{
		errcont(ERENDIF); return;
	}

	// Check if we have to execute this #endif
	if(cppiflev == cppifact)
	{
		--cppifact;
		cppinign = 0;
	}

	// Decrement #if level
	--cppiflev;
}

// Compute hash for macro name

p_hash(c)
char c;
{
	if(isupper(c))
		return c - 'A';

	if(islower(c))
		return 26 + c - 'a';

	return 52;
}

// Add macro

p_macput(name, def)
char *name, *def;
{
	int ln, ld;

	// Check if there is a macro with that name
	if(p_macfind(name) == -1)
	{
		ln = strlen(name);
		ld = strlen(def);

		if((cppmacx + ln + ld + 2) <= CPPMACSIZ)
		{
			// Store macro name and value
			cppmac[cppmacx++] = ln;
			cppmac[cppmacx++] = ld;
			memcpy(cppmac + cppmacx, name, ln);
			cppmacx += ln;
			memcpy(cppmac + cppmacx, def, ld);
			cppmacx += ld;

			// Increment hash counter
			++cpphash[p_hash(*name)];
		}
		else
			errexit(EROFMAC);
	}
	else
		errcont(ERMACAD);
}

// Delete macro if exists

p_macdel(name)
char *name;
{
	int i, size;

	if((i = p_macfind(name)) != -1)
	{
		size = cppmac[i] + (cppmac[i + 1] & 0xFF) + 2;
		memcpy(cppmac + i, cppmac + i + size, cppmacx - (i + size));
		cppmacx -= size;

		--cpphash[p_hash(*name)];
	}
}

// Find macro
// out: index on success; else -1

p_macfind(name)
char *name;
{
	int i, ln, size;

	// Check for user defined macros
	if(cpphash[p_hash(*name)])
	{
		ln = strlen(name);

		for(i = 0; i < cppmacx; i += size)
		{
			if(ln == cppmac[i])
			{
				if(!memcmp(name, cppmac + i + 2, ln))  // FIXME -- Optimize this
					return i;
			}

			size = cppmac[i] + (cppmac[i + 1] & 0xFF) + 2;
		}
	}

	// Error: macro not found
	return -1;
}

// Get line and preprocess it
// out: 0 on success; 1 on EOF

cpp_read()
{
	int c, lastc;

	while(1)
	{
		lptr = lastc = 0;

		// Read a line
		while(1)
		{
			while(lptr != LN_SIZ)
			{
				/**************************************************
				c = fi_ch();

				if(c == '\n' || c == EOF) // FIXME -- Optimize this
					break;
				***************************************************/

				if((c = fi_ch()) == '\n')
					break;

				if(c == EOF)
					break;

				if(c == '\t')
					c = ' ';

				line[lptr++] = lastc = c;
			}

			// source \ <nl>        -> join with next line
			// source <nl>          -> eol
			// source <eof>         -> eol
			// too-long-source <nl> -> eol
			// <nl>                 -> eol
			
			if(lastc != '\\' || c != '\n' || cppinasm) // FIXME -- Optimize this
				break;

			--lptr;
			++fi_line;
		}

		// Increment line number
		++fi_line;

		// Check empty line
		if(!lptr)
		{
			// Check EOF
			if(c == EOF)
			{
				// Check if there are pending included files
				if(cppincs)
				{
					// Continue with previous included file
					p_endinc(); continue;
				}

				// EOF
				return 1;
			}

			// Skip empty lines
			continue;
		}

		// End of string
		if(lptr != LN_SIZ)
			line[lptr] = '\0';
		else
		{
			// Line too long
			line[LN_MAX] = '\0';
			errcont(ERLTLNG);
		}

		// Start from first character in the line
		lptr = 0;

		// Check for multi-line comments not closed yet
		if(cppincmt)
		{
			while(BfWordNeq('*/'))
			{
				if(!BfGet())
					break;
			}

			// EOL ?
			if(!BfGet())
				continue;

			BfGet();

			// Close multi-line comment
			cppincmt = 0;
		}

		// Skip blanks
		BfBlanks();

		// Skip empty lines
		if(!Bf())
			continue;

		// Check if it's a #command
		if(BfEq('#'))
		{
			// Preprocess #command line and execute it
			p_prep(CPP_SYM_NO);
			p_cmd();
		}

		// Check if we are not in ignoring code (false if, etc.)
		else if(!cppinign)
		{
			// Check if it's an assembler line
			if(cppinasm)
			{
				// Skip assembler comments
				if(Bf() != ';')
					fo_line(line /* + lptr */);
			}

			// It's C source code
			else {
				if(ctext)
				{
					// Output C source code as assembler comment -- FIXME - This outputs // coments too!
					comment(); fo_line(line /* + lptr */);
				}

				// Preprocess C source code
				p_prep(CPP_SYM_YES);

				// Success
				return 0;
			}
		}
	}
}

// Preprocess input line
// in: type of symbol preprocessing

p_prep(sym)
int sym;
{
	int i, x;
	char s[NAME_SIZ], *p;

	cpptmpx = 0;

	while(Bf())
	{
		if(BfEq(' ') /*|| BfEq('\t')*/)    // Compact blanks to 1 space -- FIXME -- Optimize this
		{
			// Skip blanks
			BfBlanks();

			// Put 1 space
			p_keepch(' ');
		}
		else if(BfEq('"'))             // Check for double quoted strings
		{
			p_preps('"');
		}
		else if(BfEq('\''))            // Check for single quoted strings
		{
			p_preps('\'');
		}
		else if(BfWordEq('/*'))        // Check for multi-line comments
		{
			BfGet();
			BfGet();

			// Check for end of multi-line comment
			while(BfWordNeq('*/'))
			{
				if(!BfGet())
				{
					// Unclosed multi-line comment
					cppincmt = 1;
					break;
				}
			}

			// Close multi-line comment
			BfGet();
			BfGet();
		}
		else if(BfWordEq('//'))        // Check for single-line comments
		{
			break;
		}
		else if(sym && issym1st(Bf()))
		{
			// Check for symbol name -- FIXME -- Optimize this (but note that 'i' is used later in p_keepstr!)
			i = 0;
			do
			{
				if(i < NAME_MAX)
					s[i++] = BfGet();
				else
					BfGet();
			}
			while(issym(Bf()));

			s[i] = '\0';

			// Search for a macro name
			if((x = p_macfind(s)) == -1)
			{
				// Not found: keep as it is
				p_keepstr(s, i);
			}
			else
			{
				// Found: substitute it by its value
				p_keepstr(cppmac + x + 2 + cppmac[x], cppmac[x + 1] & 0xFF);
			}
		}
		else
		{
			// Keep character as it is
			p_keepch(BfGet());
		}
	}
	
	// Remove space on the right
	if(cpptmpx) {
		if(cpptmp[cpptmpx - 1] == ' ') {
			--cpptmpx;
		}
	}

	// Check for line buffer overlow
	if(cpptmpx == LN_SIZ)
	{
		errcont(ERLTLNG);

		--cpptmpx;
	}

	// EOS
	p_keepch(0);

	// Copy temporary buffer to line buffer -- FIXME -- Try to optimize this
	memcpy(line, cpptmp, cpptmpx);

	lptr = 0;
}

// Preprocess quoted string

p_preps(c)
int c;
{
	// Get first quote
	p_keepch(BfGet());
	
	while(BfNeq(c))
	{
		// Get \?, including \" and \'
		if(BfEq('\\'))
			p_keepch(BfGet());

		// Get character
		if(Bf())
			p_keepch(BfGet());
		else
			break;
	}

	// Get last quote if any -- FIXME -- What if the line has not a trailing quote?
	if(BfGet())
		p_keepch(c);
}

// Keep string

p_keepstr(s, len)
char *s; int len;
{
	if(cpptmpx + len > LN_SIZ)
		len = LN_SIZ - cpptmpx;

	memcpy(cpptmp + cpptmpx, s, len);
	cpptmpx += len;
}

// Keep character

p_keepch(c)
int c;
{
	if(cpptmpx != LN_SIZ)
		cpptmp[cpptmpx++] = c;
}

// Indent message according to the number of active #includes

msgindent()
{
	int i;

	for(i = 0; i < cppincs; ++i)
		co_str("  ");
}

// Undefine internal macros

#undef CPP_SYM_NO
#undef CPP_SYM_YES

