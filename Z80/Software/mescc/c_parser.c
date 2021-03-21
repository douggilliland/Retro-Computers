/*	c_main.c

	Mike's Enhanced Small C Compiler for Z80 & CP/M

	Parser module.

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

	11 Oct 2016 : Extracted from c_main.c.
	23 Oct 2016 : Modified declvar() in order to set char to signed or unsigned by default (-U option).
*/

// Variable types
// --------------

#define VAR_GLB 0  // Global
#define VAR_LOC 1  // Local
#define VAR_ARG 2  // Function argument

// Parse whole source file

parse()
{
	while(!eof)
	{
		/*************************
		while(declvar(VAR_GLB));
		newfunc();
		InBlanks();
		**************************/

		if(!declvar(VAR_GLB) && !eof)
			newfunc(NULL, TY_INT);
	}
}

// Dump string literals

dmplits()
{
	int j, k;

	if(!litptr)
		return;

	co_line("Writing strings...");

	a_lnlabel(litlab);

	k = 0;

	while(k < litptr)
	{
		defbyte();

		j = 10;  // Number of bytes per line

		while(j--)
		{
			fo_dec(litq[k++]);

			if(!j || k >= litptr)
			{
				fo_nl(); break;
			}

			fo_ch(',');
		}
	}
}

// Dump global variables

dmpglbs()
{
	char *ptr;
	int *pw, size;

	co_line("Writing globals...");

	for(ptr = GLB_START; ptr != glbptr; ptr += SYMSIZE)
	{
		if(ptr[SY_IDENT] != ID_FUN && ptr[SY_STORAGE] != ST_EXTERN)
		{
			fo_str(ptr); fo_colon();

			size = *(pw = ptr + SY_OFFSET);

			//size=((ptr[SY_OFFSET] & 255) + (ptr[SY_OFFSET+1] << 8));

			if(ptr[SY_FLAGS] & FL_VALUE)
			{
				if(ptr[SY_IDENT] == ID_ARR)
					wrtequ();
				else if((ptr[SY_TYPE] & TY_CHAR) && ptr[SY_IDENT] != ID_PTR)
					defbyte();
				else
					defword();

				if(ptr[SY_FLAGS] & FL_STRBF)
				{
					a_label(litlab); fo_ch('+');
				}
			}
			else
			{
				defstrg();

				if((ptr[SY_TYPE] & TY_INT) || ptr[SY_IDENT] == ID_PTR)
					size += size;
			}

			fo_dec(size);
			fo_nl();
		}
	}
}

// Declare variables (and functions)
//
// Examples:
//
// char ch;
// unsigned char byte;
// int i;
// unsigned int word;
// unsigned word;
// char space = ' ', letter = 'a';
// char *title = "Title";
// char title[] = "Title";
// char abc[3] = {'a', 'b', 'c'};
// int numbers[] = {1, 2, 3};
//
// extern int total;
// extern char title[];
//
// - Arrays of pointers are not allowed: ie - char *months[] = {"Jan", "Feb", "Mar"};
// - Functions can't be extern or prototyped.

declvar(level)
int level;
{
	int stor, sign, type;
	int id, dim, flags, arridx, arrmax, arrptr;
	char s[NAME_SIZ];

	stor = sign = type = 0;

	if(level == VAR_GLB)
	{
		if(InSymEq("extern"))
			stor=ST_EXTERN;
	}

	if(InSymEq("unsigned"))
		sign = 1;
	else if(InSymEq("signed"))
		sign = 2;

	if(InSymEq("char"))
		type = TY_CHAR;
	else if(InSymEq("int"))
		type = TY_INT;

	if(!(stor + sign + type))
		return 0;

	if(!type)
		type = TY_INT;

	if(!stor)
		stor = (level == VAR_GLB) ? ST_STATIK : ST_STKLOC;

	if(sign == 1)
		type = (type == TY_CHAR) ? TY_UCHAR : TY_UINT;
	else if(!sign && type == TY_CHAR && uchar)
		type = TY_UCHAR;

	while(1)
	{
		id = InChEq('*') ? ID_PTR : ID_VAR;

		if(!symname(s))
			illname();

		dim = flags = 0;

		if(InChEq('['))
		{
			if(number(&dim))
			{
				if(dim <= 0)
				{
					errcont(ERARRSZ); dim = 1;
				}
			}

			ndch(']');

			if(id == ID_PTR)
				errcont(ERARRPT);

			if(level == VAR_ARG)
				id = ID_PTR;
			else if(level == VAR_GLB || stor == ST_EXTERN || dim)
				id = ID_ARR;
		}

		// FIXME -- Look for function declarations

		// Look for new functions and assigments
		if(/* level == VAR_GLB &&*/ stor == ST_STATIK)
		{
			// Check if it's a function
			if(InChEq('('))
			{
				newfunc(s, type); return 1;
			}

			// Assign value if any
			if(InChEq('='))
			{
				flags |= FL_VALUE;

				// Check for array or single variable
				if(id == ID_ARR)
				{

					/* Allowed:
						Array #1 : int values[]  = {1, 2, 3};  -- char or int
						Array #2 : int values[3] = {1, 2, 3};  -- char or int
						Array #3 : char name[]   = "Elvis";    -- char
					*/

					flags |= FL_STRBF;

					if(InChEq('{'))
					{
						arrmax = dim ? dim : 9999;
						arrptr = litptr;

						for(arridx = 0; arridx < arrmax; ++arridx)
						{
							if(constex(&dim))
							{
								wrtlit(dim);

								if(type & TY_INT)
									wrtlit(dim >> 8);
							}
							else
								errcont(ERCONST);

							if(!InChEq(','))
								break;
						}

						if(arridx < arrmax)
						{
							if(arrmax == 9999)
								arrmax = arridx + 1;

							while(++arridx < arrmax)
							{
								wrtlit(0);

								if(type & TY_INT)
									wrtlit(0);
							}
						}
						else
							errcont(ERARRSZ);

						dim = arrptr;

						ndch('}');
					}
					else if(!((type & TY_CHAR) && !dim && qstr(&dim)))  // char name[] = "Elvis";
						errcont(ERCNTAS);
				}
				else if(!constex(&dim))
				{
					// FIXME -- Some bizarre assigns here - ie char c = "String"

					if(qstr(&dim))
						flags |= FL_STRBF;
					else
						errcont(ERCNTAS);
				}
			}
		}

		// Adjust size

		if(!dim)
		{
			if(!(flags & FL_VALUE))
			{
				if(id == ID_ARR && stor != ST_EXTERN)
					errcont(ERARRSZ);

				dim = 1;
			}
		}

		// Declare

		if(level == VAR_GLB)
			declvglb(s, id, type, stor, dim, flags);
		else if(level == VAR_LOC)
			declvloc(s, id, type, stor, dim);
		else
			declvarg(s, id, type, stor, dim);

		if(!InChEq(','))
			break;
	}

	ndch(';');

	return 1;
}

// Write character to string buffer -- FIXME -- Change qstr(val) in c_expr.c to use this function ??

wrtlit(ch)
int ch;
{
	if(litptr < STRBUF_SIZ)
		litq[litptr++] = ch;
	else
		errexit(EROFSTR);
}

// Declare global

declvglb(sym, id, typ, sto, dim, flags)
char *sym;
int id, typ, sto, dim, flags;
{
	char *ptr;

	if(ptr = findglb(sym))
	{
		if(id != ptr[SY_IDENT] || typ != ptr[SY_TYPE] || (sto != ST_EXTERN && ptr[SY_STORAGE] != ST_EXTERN))
			multidef();

		if(sto != ST_EXTERN)
			ptr[SY_STORAGE] = sto;
	}
	else
		addglb(sym,id,typ,sto,dim,flags);
}

// Declare local

declvloc(sym, id, typ, sto, dim)
char *sym;
int id, typ, sto, dim;
{
	if(findloc(sym))
		multidef();
	else
	{
		if(id == ID_PTR || (typ & TY_INT))
			dim += dim;

		locsiz += dim;

		addloc(sym, id, typ, sptr - locsiz);
	}
}

// Declare function argument

declvarg(sym, id, typ, sto, dim)
char *sym;
int id, typ, sto, dim;
{
	char *ptr;
	int *pw, locadr;

	if(argstk)
	{
		if(ptr = findloc(sym))
		{
			if(ptr[SY_IDENT])
				multidef();
			else
			{
				ptr[SY_IDENT] = id;
				ptr[SY_TYPE]  = typ;
				ptr[SY_FLAGS] = 0;

				pw = ptr + SY_OFFSET;
			      	locadr = argtop - *pw;
				*pw = locadr;

				/****************************************************
				locadr=argtop-(ptr[SY_OFFSET+1]<<8)-ptr[SY_OFFSET];
				ptr[SY_OFFSET]=locadr;
				ptr[SY_OFFSET+1]=locadr>>8;
				*****************************************************/

				argstk -= 2;
			}
		}
		else
			errcont(ERARGNM);
	}
	else
		errcont(ERARGNB);
}

// New function
//
// name==NULL -> fun(){...}
// name!=NULL -> ){...}
//
// typ is currently ignored, funcion is always TY_INT

newfunc(name, typ)
char *name;
int typ;
{
	char n[NAME_SIZ], *ptr, argtyp;

	if(name)
	{
		strcpy(n, name);
	}
	else if(!symname(n))
	{
		errcont(ERFUNDE);
		BfKill();
		return;
	}
	else
		ndch('('); 

	msgindent(); co_str("Function: "); co_line(n);

	if(ptr = findglb(n))
	{
		if(ptr[SY_IDENT] != ID_FUN || ptr[SY_OFFSET] == ID_FUN)
			multidef();
		else
			ptr[SY_OFFSET] = ID_FUN;

		/***************************************
		if(ptr[SY_IDENT]!=ID_FUN)
		{
			multidef();
		}
		else
		{
			if(ptr[SY_OFFSET]==ID_FUN)
				multidef();
			else
				ptr[SY_OFFSET]=ID_FUN;
		}
		****************************************/
	}
	else
		addglb(n, ID_FUN, TY_INT, ST_STATIK, ID_FUN, 0);

	fo_line(n);  // FIXME -- Use a function from c_asm.c ??

	locptr = LOC_START;
	argstk = 0;

	while(!InChEq(')'))
	{
		if(symname(n))
		{
			if(findloc(n))
				multidef();
			else
			{
				addloc(n, 0, 0, argstk);
				argstk += 2;
			}
		}
		else
		{
			errcont(ERARGNM);
			junk();
		}

		InBlanks();

		if(BfNeq(')'))
			ndch(',');

		if(endst())
			break;
	}

	if(argstk)
	{
		argtop = argstk;

		while(declvar(VAR_ARG))
			;

		if(argstk)
			errcont(ERARGNB);
	}

	sptr = lastst = 0;

	if(stment() != S_RETURN)
	{
		modstk(0, 0);
		retfn();
	}

	sptr   = 0;
	locptr = LOC_START;
}

// Statement
// ---------

stment()
{
	if(eof)
		return -1;

	if(InSymEq("if"))
	{
		doif(); lastst = S_IF;
	}
	else if(InSymEq("for"))
	{
		dofor(); lastst = S_FOR;
	}
	else if(InSymEq("while"))
	{
		dowhile(); lastst = S_WHILE;
	}
	else if(InSymEq("break"))
	{
		dobreak(); ns(); lastst = S_BREAK;
	}
	else if(InSymEq("do"))
	{
		dodo(); lastst = S_WHILE;
	}
	else if(InSymEq("return"))
	{
		doretrn(); ns(); lastst = S_RETURN;
	}
	else if(InSymEq("continue"))
	{
		docont(); ns(); lastst = S_CONT;
	}
	else if(InSymEq("switch"))
	{
		doswtch(); lastst = S_SWITCH;
	}
	else if(InChEq('{'))
	{
		while(!InChEq('}'))
		{
			if(stment() == -1)
			{
				errndch('}'); break;
			}
		}
	}
	else if(InChEq(';'))
	{
		// Nothing
	}
	else
	{
		locsiz = 0;

		while(declvar(VAR_LOC));

		if(locsiz)
			sptr = modstk(sptr - locsiz, 0);
		else
		{
			expresn(); ns(); lastst = S_EXP;
		}
	}

	return lastst;
}

// Need end of statement

ns()
{
	ndch(';');
}

// if statement

doif()
{
	int flev, fsp, flab1, flab2;

	flev  = locptr;
	fsp   = sptr;
	flab1 = getlabl();
	test(flab1);
	stment();
	sptr   = modstk(fsp, 0);
	locptr = flev;

	if(!InSymEq("else"))
	{
		a_lnlabel(flab1); return;
	}

	if(lastst != S_RETURN && lastst != S_BREAK && lastst != S_CONT)
		jump(flab2 = getlabl());
	else
		flab2 = 0;

	a_lnlabel(flab1);

	stment();

	sptr   = modstk(fsp, 0);
	locptr = flev;

	if(flab2)
		a_lnlabel(flab2);
}

// do statement

dodo()
{
	int wq[WQ_SIZ];

	wq[WQ_SYM]  = locptr;
	wq[WQ_SP]   = sptr;
	wq[WQ_LOOP] = getlabl();
	wq[WQ_LAB]  = getlabl();
	wq[WQ_LAB2] = getlabl();

	addwhle(wq);

	a_lnlabel(wq[WQ_LAB2]);

	stment();

	if(!InSymEq("while"))
		errcont(EREXWHI);

	a_lnlabel(wq[WQ_LOOP]);

	test(wq[WQ_LAB]);
	jump(wq[WQ_LAB2]);

	a_lnlabel(wq[WQ_LAB]);
	ns();
	locptr = wq[WQ_SYM];
	sptr   = modstk(wq[WQ_SP], 0);

	delwhle();
}

// while statement

dowhile()
{
	int wq[WQ_SIZ];

	wq[WQ_SYM]  = locptr;
	wq[WQ_SP]   = sptr;
	wq[WQ_LOOP] = getlabl();
	wq[WQ_LAB]  = getlabl();

	addwhle(wq);

	a_lnlabel(wq[WQ_LOOP]);

	test(wq[WQ_LAB]);
	stment();
	jump(wq[WQ_LOOP]);

	a_lnlabel(wq[WQ_LAB]);

	locptr = wq[WQ_SYM];
	sptr   = modstk(wq[WQ_SP], 0);

	delwhle();
}

// return statement

doretrn()
{
	if(endst())
		modstk(0, 0);
	else
	{
		expresn();
		modstk(0, 1);
	}

	retfn();
}

// break statement

dobreak()
{
	int *ptr;

	if((ptr = rdwhile()))
	{
		modstk(ptr[WQ_SP], 0);
		jump(ptr[WQ_LAB]);
	}
}

// continue statement

docont()
{
	int *ptr;

	if((ptr = rdwhile()))
	{
		modstk(ptr[WQ_SP], 0);
		jump(ptr[WQ_LOOP]);
	}
}

// Call function

callfnc(ptr)
char *ptr;
{
	int nargs;

	nargs = 0;

	InBlanks();

	if(!ptr)
		fpush();

	while(BfNeq(')'))
	{
		if(endst())
			break;
		expresn();
		if(!ptr)
			swapstk();
		fpush();
		nargs += 2;
		if(!InChEq(','))
			break;
	}

	ndch(')');

	// Add # of arguments if it's a special function (printf, scanf, etc.)
	if(ptr)
	{
		if(special(ptr))
		{
		 	immed_dec(nargs / 2);
		 	nargs += 2;
			fpush();
		}

		callfn(ptr);
	}
	else
		callstk();

	sptr = modstk(sptr + nargs, 1);
}

// Check for special function names

special(ptr)
char *ptr;
{
	if(!strcmp(ptr,"printf"))
		return 1;

	if(!strcmp(ptr,"scanf"))
		return 1;

	if(!strcmp(ptr,"sprintf"))
		return 1;

	if(!strcmp(ptr,"sscanf"))
		return 1;

	if(!strcmp(ptr,"fprintf"))
		return 1;

	if(!strcmp(ptr,"fscanf"))
		return 1;

	return 0;
}

// Junk

junk()
{
	if(issym(inbyte()))
	{
		while(issym(Bf()))
			BfGet();
	}
	else
	{
		while((!issym(Bf())) && Bf())
			BfGet();
	}

	InBlanks();
}

// Check for end of statement

endst()
{
	InBlanks();

	return(BfEq(';') || BfEq(0));
}

// Illegal symbol name

illname()
{
	errcont(ERSYMNM);
	junk();
}

// Symbol already defined

multidef()
{
	errcont(ERALDEF);
}

// Find global symbol

findglb(s)
char *s;
{
	char *ptr;

	for(ptr = GLB_START; ptr != glbptr; ptr += SYMSIZE)
	{
		if(!strcmp(s, ptr))
			return ptr;
	}

	return 0;
}

// Find local symbol

findloc(s)
char *s;
{
	char *ptr;

	for(ptr = LOC_START; ptr != locptr; ptr += SYMSIZE)
	{
		if(!strcmp(s, ptr))
			return ptr;
	}

	return 0;
}

// Add global symbol

addglb(s, id, typ, sto, val, flags)
char *s, id, typ, sto;
int val, flags;
{
	char *ptr;
	int *pw;

	if(ptr = findglb(s))
		return ptr;

	if(glbptr == GLB_END)
		errexit(EROFGLB);

	ptr = glbptr;
	strcpy(ptr, s);
	ptr[SY_IDENT]   = id;
	ptr[SY_TYPE]    = typ;
	ptr[SY_STORAGE] = sto;
	ptr[SY_FLAGS]   = flags;

	*(pw = ptr + SY_OFFSET) = val;

	//ptr[SY_OFFSET]=val;
	//ptr[SY_OFFSET+1]=val>>8;

	glbptr += SYMSIZE;

	return ptr;
}

// Add local symbol

addloc(s, id, typ, val)
char *s, id, typ;
int val;
{
	char *ptr;
	int *pw;

	if(ptr = findloc(s))
		return ptr;

	if(locptr == LOC_END)
		errexit(EROFLOC);

	ptr = locptr;
	strcpy(ptr, s);
	ptr[SY_IDENT]   = id;
	ptr[SY_TYPE]    = typ;
	ptr[SY_STORAGE] = ST_STKLOC;
	ptr[SY_FLAGS]   = 0;

	*(pw = ptr + SY_OFFSET) = val;

	//ptr[SY_OFFSET]=val;
	//ptr[SY_OFFSET+1]=val>>8;

	locptr += SYMSIZE;

	return ptr;
}

// Check if string starts with a valid symbol name

symname(s)
char *s;
{
	int i;

	InBlanks();

	if(issym1st(Bf()))
	{
		i = 0;
		do
		{
			if(i != NAME_MAX)
			{
				*s++ = BfGet();
				++i;
			}
			else
				BfGet();
		}
		while(issym(Bf()));

		*s = 0;

		return 1;
	}

	return 0;
}

// Get next label number

getlabl()
{
	return nxtlab++;
}

// Add while entry

addwhle(ptr)
int ptr[];
{
	int k;

	if(wqptr != WQ_MAX)
	{
		k = 0;
		while(k != WQ_SIZ)
			*wqptr++ = ptr[k++];
	}
	else
		errcont(ERTMWHI); 
}

// Delete while entry

delwhle()
{
	if(rdwhile())
		wqptr -= WQ_SIZ;
}

// Read last while entry

rdwhile()
{
	if(wqptr != wq)
		return wqptr - WQ_SIZ;

	errcont(ERNOWHI);

	return 0;
}

// Need special character

ndch(c)
char *c;
{
	if(InChEq(c))
		return 0;

	errndch(c);
	// junk();

	return 1;
}

// for statement

dofor()
{
	int queue[WQ_SIZ];              // Local queue area

	queue[WQ_SYM]  = locptr;        // Save local level
	queue[WQ_SP]   = sptr;          // And stack pointer
	queue[WQ_LOOP] = getlabl();	// Looping label
	queue[WQ_LAB]  = getlabl();     // Loop exit variable
	queue[WQ_END]  = getlabl();     // Loop end label
	queue[WQ_BODY] = getlabl();	
	addwhle(queue);                 // Add while to loop queue
	ndch('(');                      // Check for open parenthesis
	if(ChNeq(';'))
		expresn();              // Initialize expression
	ndch(';');                      // Check for semicolon
	a_lnlabel(queue[WQ_END]);       // Control loop label -- bug solved: was WQ_LOOP
	if(ChNeq(';')) {
		expresn();              // Loop control expression
		testjmp(queue[WQ_LAB]); // See if it's exit time
	}
	jump(queue[WQ_BODY]);           // Not time to exit; do body
	ndch(';');                      // Check for semicolon
	a_lnlabel(queue[WQ_LOOP]);      // Print end of loop -- bug solved: was WQ_END
	if(ChNeq(')'))
		expresn();              // End loop expression
	jump(queue[WQ_END]);            // Do loop control expression -- bug solved: was WQ_LOOP
	ndch(')');

	a_lnlabel(queue[WQ_BODY]);
	stment();
	jump(queue[WQ_LOOP]);           // Bug solved: it was WQ_END
	a_lnlabel(queue[WQ_LAB]);
	locptr=queue[WQ_SYM];
	sptr=modstk(queue[WQ_SP], 0);
	delwhle();
}

// switch statement

doswtch()
{
	int value[SWITCH_MAX];      // Value for case statement
	int label[SWITCH_MAX];      // Value for each label
	int count, temp;            // Number of switches
	int endlab;                 // Label for default
	int labsw;                  // Used for switch label
	int val;
	int queue[WQ_SIZ];          // Local queue area

	count = 0;                  // Number of case statements
	queue[WQ_SYM]  = locptr;    // Local variable pointer
	queue[WQ_SP]   = sptr;      // Save current stack pointer
	endlab         =            // Default exit label
	queue[WQ_LOOP] =            // Looping label
	queue[WQ_LAB]  =            // Loop exit variable
	queue[WQ_END]  = getlabl(); // Continue label
	addwhle(queue);             // Add to while stack


	ndch('(');                  // Check for "("
	expresn();                  // Expression for switch
	fpush();
	ndch(')');                  // Check for ")"
	ndch('{');
	jump(labsw = getlabl());
	sptr += 2;

	while(1)
	{
 		if(InSymEq("case"))
		{
			if(!constex(&val))
				errcont(ERCONST);

			if(count < SWITCH_MAX - 2)
			{
				value[count] = val;
				a_lnlabel(label[count++] = getlabl());
			}
			else
				errcont(ERTMCAS);

			ndch(':');
		}
		else if(InSymEq("default"))
		{
			endlab = getlabl();
			a_lnlabel(endlab);

			ndch(':');
		}
		else if(InChEq('}'))
		{
			jump(queue[WQ_LAB]);  // Jump past switch data
			a_lnlabel(labsw);
			execsw(count, labsw = getlabl(), endlab);
			a_lnlabel(labsw);
			for(temp = 0; temp < count; ++temp)
			{
				defword(); fo_dec(value[temp]); fo_nl();
				defword(); a_lnlabel(label[temp]);
			}
			delwhle();
			a_lnlabel(queue[WQ_LAB]);
			locptr = queue[WQ_SYM];
			sptr = modstk(queue[WQ_SP], 0);
			break;
		}
		else
			stment();
	}
}

// Check for constant expression (number or string)

constex(val)
int *val;
{
	InBlanks();

	if(number(val))
		return 1;

	if(pstr(val))
		return 1;

	return 0;
}

// Undefine local #defines

#undef VAR_GLB
#undef VAR_LOC
#undef VAR_ARG
