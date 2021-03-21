/*	c_buf.c

	Mike's Enhanced Small C Compiler for Z80 & CP/M

	I/O buffer module.

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
	27 May 2007 : issym() expanded to more speed.
	              Minor changes in inchar().
	16 Aug 2015 : Minor changes in BfWordEq() and BfWordNeq().
	26 Oct 2015 : Cleaned.
	29 Nov 2015 : Added ChEq() y ChNeq().
	11 Oct 2016 : Documented and slightly optimized.
	12 Oct 2016 : Blanks are ' ' only. See cpp_read().
*/

// Test if character is valid as first character of symbol

issym1st(c)
char c;
{
	return isalpha(c) || c == '_';  // FIXME - Optimize for MESCC ??
}

// Test if character is valid as character symbol

issym(c)
char c;
{
	return isalpha(c) || c == '_' || isdigit(c); // FIXME - Optimize for MESCC ??
}

// -------------------------------------
// Functions related to the input stream
// -------------------------------------

// Skip symbol name if matchs with input parameter
// in:  symbol name
// out: true on success; else false

InSymEq(s)
char *s;
{
	int i;

	InBlanks(); // FIXME -- Optimize this (see c_main.c)

	i = strlen(s);

	if(!memcmp(s, line + lptr, i))
	{
		if(!issym(line[lptr + i]))
		{
			lptr += i; return 1;
		}
	}

	return 0;
}

// Skip character if matches with input parameter
// in:  character
// out: true on success; else false

InChEq(c)
char c;
{
	InBlanks();  // FIXME -- Optimize this (see c_main.c)

	if(BfEq(c))  // FIXME -- Optimize this
	{
		BfGet(); // FIXME -- Optimize this
		return 1;
	}

	return 0;
}

// Skip two characters if match with input parameter
// in:  two characters
// out: true on succes; else false

InWordEq(w)
int w;
{
	InBlanks();  // FIXME -- Optimize this (see c_main.c)

	if(BfWordEq(w))
	{
		BfGet();
		BfGet();
		return 1;
	}

	return 0;
}

// Input byte
// out: byte on success; else 0

inbyte()
{
	while(!Bf())
	{
		if(eof)
			return 0;

		BfRead();
	}

	return BfGet();
}

// Input character
// out: character on success; else 0

inchar()
{
	if(!Bf())
		BfRead();

	return eof ? 0 : BfGet();
}

// Skip blanks

InBlanks()
{
	while(1)
	{
		/*****************************
		while(BfEq(' ') || BfEq('\t'))
			BfGet();
		******************************/

		BfBlanks();

		if(Bf())
			break;

		BfRead();

		if(eof)
			break;
	}
}

// Test if the next character matchs with input parameter

ChEq(c)
char c;
{
	InBlanks();  // FIXME -- Optimize this (see c_main.c)

	return BfEq(c);
}

// Test if the next character does not match with input parameter

ChNeq(c)
char c;
{
	InBlanks();  // FIXME -- Optimize this (see c_main.c)

	return BfNeq(c);
}

// -------------------------------------
// Functions related to the input buffer
// -------------------------------------

Bf()
{
	return line[lptr];
}

// Return following character to the current one

BfNext()
{
	/*****************************
	if(Bf())
		return line[lptr + 1];

	return 0;
	******************************/
	
	return Bf() ? line[lptr + 1] : 0;
}

// Input current character

BfGet()
{
	char c;

	if(c = Bf())
		++lptr;

	return c;
}

// Test if current character matchs with input parameter

BfEq(c)
char c;
{
	return Bf() == c;
}

// Test if current character does not match with input parameter

BfNeq(c)
char c;
{
	return Bf() != c;
}

// Test if following character to the current one matchs with input parameter

BfNextEq(c)
char c;
{
	return BfNext() == c;
}

/*
	int BfNextNeq(char c)
	Devuelve TRUE si BfNext() != c.
*/

// Test if following character to the current one does not match with input parameter

BfNextNeq(c)
char c;
{
	return BfNext() != c;
}

// Test if two characters are in the current position

BfWordEq(w)
int w;
{
	return w == ((Bf() << 8) + BfNext());  // FIXME -- This is not transportable at all!
}

// Test if two characters are not in the current position

BfWordNeq(w)
int w;
{
	return w != ((Bf() << 8) + BfNext()); // FIXME -- This is not transportable at all!
}

// Skip blanks

BfBlanks()
{
	/********************************************************
	while(BfEq(' ') || BfEq('\t'))  // FIXME -- Optimize this
		BfGet();
	*********************************************************/

	while(line[lptr] == ' ')
		++lptr;
}

// Read a line into the buffer

BfRead()
{
	eof = cpp_read();
}

// Discard the current contents

BfKill()
{
	line[0] = lptr = 0;
}
