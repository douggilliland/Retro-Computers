/*	c_asm.c

	Mike's Enhanced Small C Compiler for Z80 & CP/M

	Assembler code output module.

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

	20 Dec 2006 : Last revision.
	16 Apr 2007 : GPL'd.
	26 May 2007 : Solved bug in a_incdec() - assumed wrongly that
	              lval[0] never is 0.
	17 Feb 2015 : Solved bug in getvloc() and putvloc() - some systems
                      can corrupt 1 byte in variable area (stack).
	10 Apr 2015 : Removed code for argc & argv support via the -A option.
	26 Oct 2015 : Cleaned.
	28 Oct 2015 : Now ;[ is for optimizer off and ;] for optimizer on.
	22 Nov 2015 : New function wrtequ().
	01 Dec 2015 : Print a SPACE on line starts, instead of a TAB.
	13 Oct 2016 : Documented.
	13 Jan 2021 : Bugfix in a_incdec() in extern char.
*/

// Start of assembler code

a_start()
{
	comment();
	fo_str(VERSION);
	fo_nl();

	if(typout==OUT_PRG)
	{
		/* Define stack size */

		fo_str("ccSTACKSIZE EQU ");fo_dec(stksize);fo_nl();
	}
	else if(typout==OUT_LIB)
		fo_line("#asm");
}

// End of assembler code

a_end()
{
	if(typout == OUT_PRG)
		fo_line("ccfreemem: DEFB 0");
	else if(typout == OUT_LIB)
		fo_line("#endasm");

	if(typout != OUT_LIB)
		a_code("END");
}

// Output flag for optimizer

a_opt(on)
int on;
{
	fo_line(on ? ";]" : ";[");
}

// Output space + something + \n

a_code(s)
char *s;
{
	fo_ch(' '); fo_line(s);
}

// Output space + something

a_tcode(s)
char *s;
{
	fo_ch(' '); fo_str(s);
}

// Output (something)

a_pcode(s)
char *s;
{
	fo_ch('('); fo_str(s); fo_ch(')');
}

// Output (something) + \n

a_pcodenl(s)
char *s;
{
	a_pcode(s); fo_nl();
}

// Start of assembler comment

comment()
{
	fo_ch(';');
}

// HL = (global variable)

getmem(sym)
char *sym;
{
	if((sym[SY_TYPE] & TY_CHAR) && sym[SY_IDENT] != ID_PTR)
	{
		a_tcode(sym[SY_TYPE] == TY_CHAR ? "LD A," : "LD HL,");
		a_pcodenl(sym + SY_NAME);

		sym[SY_TYPE] == TY_CHAR ? callrt("sxt") : a_code("LD H,0");
	}
	else
	{
		a_tcode("LD HL,"); a_pcodenl(sym + SY_NAME);
	}
}

// Get local value

getvloc(sym)
char *sym;
{
	int offset, sizflg;

	offset=(sym[SY_OFFSET] & 255) + (sym[SY_OFFSET + 1] << 8) - sptr; // FIXME - Optimize this

	sizflg = offset < 256;

	if((sym[SY_TYPE] & TY_CHAR) && sym[SY_IDENT] != ID_PTR)
	{
		if(sym[SY_TYPE] == TY_CHAR)
			callrt(sizflg ? "xgc" : "xgc2");
		else if(offset)
			callrt(sizflg ? "xgb" : "xgb2");
		else
		{
			a_code("POP HL");
			a_code("PUSH HL");
			a_code("LD H,0");
			return;
		}
	}
	else if(sizflg)
	{
		switch(offset)
		{
			case 0:	a_code("POP HL");
				a_code("PUSH HL");
				return;
			/*************************************************************
			NOTE: FOLLOWING CODE CAN CAUSE 1 BYTE OF LOCAL VARIABLES TO
			BE CORRUPTED, IF AN INTERRUPT OCCURS BETWEEN INC SP AND DEC SP
			AND THE SYSTEM PUTS SOMETHING IN THE PROGRAM STACK (AS DOES
			CP/M PLUS ON THE AMSTRAD PCW).

			case 1:	a_code("INC SP");
				a_code("POP HL");
				a_code("PUSH HL");
				a_code("DEC SP");
				return;
			**************************************************************/
			case 2:	a_code("POP BC");
				a_code("POP HL");
				a_code("PUSH HL");
				a_code("PUSH BC");
				return;
		}

		callrt("xgw");
	}
	else
		callrt("xgw2");

	sizflg ? defbyte() : defword();
	fo_dec(offset);
	fo_nl();
}

// HL = local variable address

getloc(sym)
char *sym;
{
	immed_dec((sym[SY_OFFSET] & 255) + (sym[SY_OFFSET + 1] << 8) - sptr); // FIXME - Optimize this
	a_code("ADD HL,SP");
}

// (global variable) = HL

putmem(sym)
char *sym;
{
	if((sym[SY_TYPE] & TY_CHAR) && sym[SY_IDENT] != ID_PTR)
	{
		a_code("LD A,L");
		a_tcode("LD "); a_pcode(sym + SY_NAME); fo_line(",A");
	}
	else
	{
		a_tcode("LD "); a_pcode(sym + SY_NAME); fo_line(",HL");
	}
}

// Put local value

putvloc(sym)
char *sym;
{
	int offset, sizflg;

	offset = (sym[SY_OFFSET] & 255) + (sym[SY_OFFSET + 1] << 8) - sptr; // FIXME - Optimize this

	sizflg = offset < 256;

	if((sym[SY_TYPE] & TY_CHAR) && sym[SY_IDENT] != ID_PTR)
	{
		if(offset < 2)
		{
			a_code("POP BC");
			a_code(offset ? "LD B,L" : "LD C,L");
			a_code("PUSH BC");
			return;
		}

		callrt(sizflg ? "xpb" : "xpb2");
	}
	else if(sizflg)
	{
		switch(offset)
		{
			case 0:	a_code("POP BC");
				a_code("PUSH HL");
				return;

			/*************************************************************
			NOTE: FOLLOWING CODE CAN CAUSE 1 BYTE OF LOCAL VARIABLES TO
			BE CORRUPTED, IF AN INTERRUPT OCCURS BETWEEN INC SP AND DEC SP
			AND THE SYSTEM PUTS SOMETHING IN THE PROGRAM STACK (AS DOES
			CP/M PLUS ON THE AMSTRAD PCW).

			case 1:	a_code("INC SP");
				a_code("POP BC");
				a_code("PUSH HL");
				a_code("DEC SP");
				return;
			**************************************************************/
			case 2:	a_code("POP BC");
				a_code("POP DE");
				a_code("PUSH HL");
				a_code("PUSH BC");
				return;
		}

		callrt("xpw");
	}
	else
		callrt("xpw2");

	sizflg ? defbyte() : defword();
	fo_dec(offset);
	fo_nl();
}

// Store specified object type in HL at address	on the top of the stack

putstk(obj)
char obj;
{
	fpop();

	if(obj & TY_CHAR)
	{
		a_code("LD A,L");
		a_code("LD (DE),A");
	}
	else
		callrt("pw");
}

// Fetch specified object type indirect through HL into HL

indrct(obj)
char obj;
{
	if(obj == TY_UCHAR)
	{
		a_code("LD L,(HL)");
		a_code("LD H,0");
	}
	else
		callrt(obj & TY_CHAR ? "gc" : "gw");
}

// Swap HL and DE

swap()
{
	a_code("EX DE,HL");
}

// Start assembler code to load HL with a value

immed()
{
	a_tcode("LD HL,");
}

// Load HL with address

immed_str(str)
char *str;
{
	immed(); fo_line(str);
}

// Load HL with decimal value

immed_dec(dec)
int dec;
{
	immed(); fo_dec(dec); fo_nl();
}

// PUSH HL into stack

fpush()
{
	a_code("PUSH HL");
	sptr -= 2;
}

// POP DE from stack

fpop()
{
	a_code("POP DE");
	sptr += 2;
}

// Swap HL and stack content

swapstk()
{
	a_code("EX (SP),HL");
}

// Output local label

a_label(num)
int num;
{
	fo_ch(letlab); fo_dec(num);
}

// Output local label + \n

a_lnlabel(num)
int num;
{
	a_label(num); fo_nl();
}

// Call runtime label

callrt(label)
char *label;
{
	a_tcode("CALL cc"); fo_line(label);
}

// Call function label

callfn(label)
char *label;
{
	a_tcode("CALL "); fo_line(label);
}

// Execute switch statement

execsw(count, label, endlab)
int count, label, endlab;
{
	a_tcode("LD DE,"); a_lnlabel(label);
	a_tcode("LD HL,"); a_lnlabel(endlab);
	a_tcode("LD B,");  fo_dec(count); fo_nl();
	a_code("JP ccswtch");
}

// Output RET

retfn()
{
	a_code("RET");
}

// Perform subroutine call to adress on top of stack

callstk()
{
	immed_str("5+$");    // ZSM error if $+5
	swapstk();
	a_code("JP (HL)");
	sptr += 2;
}

// Jump to local label

jump(label)
int label;
{
	a_tcode("JP "); a_lnlabel(label);
}

// Jump to local label if HL == 0

testjmp(label)
int label;
{
	a_code("LD A,H");
	a_code("OR L");
	a_tcode("JP Z,"); a_lnlabel(label);
}

// Output DEFB

defbyte()
{
	a_tcode("DEFB ");
}

// Output DEFW

defword()
{
	a_tcode("DEFW ");
}

// Output DEFS

defstrg()
{
	a_tcode("DEFS ");
}

// Output EQU

wrtequ()
{
	a_tcode("EQU ");
}

// Modify stack pointer value
// in:  flag != 0 to preserve hl
// out: new stack pointer value

modstk(newsp, flag)
int newsp, flag;
{
	int k, m;

	k = newsp - sptr;
	m = flag ? 14 : 10;

	if(k > 0 && k < m)
	{
		if(k & 1)
		{
			a_code("INC SP");
			--k;
		}
		while(k)
		{
			a_code("POP BC");
			k -=2;
		}
	}
	else if(k < 0 && k > -m)
	{
		if(k & 1)
		{
			a_code("DEC SP");
			++k;
		}
		while(k)
		{
			a_code("PUSH BC");
			k += 2;
		}
	}
	else if(k)
	{
		if(flag)
			swap();
		immed_dec(k);
		a_code("ADD HL,SP");
		a_code("LD SP,HL");
		if(flag)
			swap();
	}

	return newsp;
}

// Double value: HL = HL + HL

doubreg()
{
	a_code("ADD HL,HL");
}

// Increment or decrement

a_incdec(lval, inc, post)
int lval[], inc, post;
{
	char *ptr;
	int i, dbl;

	ptr = lval[0];

	if((ptr && (ptr[SY_TYPE] & TY_CHAR) && ptr[SY_IDENT] != ID_PTR)	|| (lval[1] & TY_CHAR))
	{
		if(!lval[1])
			ptr[SY_STORAGE] != ST_STKLOC ? immed_str(ptr + SY_NAME) : getloc(ptr);

		if(post)
			a_code("LD A,(HL)");

		a_code(inc ? "INC (HL)" : "DEC (HL)");

		if(lval[1] == TY_CHAR || (!lval[1] && ptr[SY_TYPE] == TY_CHAR))
			callrt(post ? "sxt" : "gc");
		else
		{
			a_code(post ? "LD L,A" : "LD L,(HL)");
			a_code("LD H,0");
		}
	}
	else
	{
		i = dbl = ((lval[2] & TY_INT) && (!lval[1] || (!lval[1] && ptr[SY_IDENT] == ID_PTR))) ? 2 : 1;
		if(lval[1])
			fpush();
		rvalue(lval);
		while(dbl--)
			inc ? finc() : fdec();
		store(lval);
		if(post)
		{
			while(i--)
				inc ? fdec() : finc();
		}
	}
}

// ---------------------
// Arithmetic operations
// ---------------------

// Addition: HL = DE + HL

addfn()
{
	a_code("ADD HL,DE");
}

// Subtraction: HL = DE - HL

subfn()
{
	callrt("sub");
}

// Multiplication: HL = DE * HL

a_mul(sign)
int sign;
{
	callrt(sign ? "mul" : "umul");
}

// Division: HL = DE / HL

a_div(sign)
int sign;
{
	callrt(sign ? "div" : "udiv");
}

// Modulus: HL = DE % HL

a_mod(sign)
int sign;
{
	callrt(sign ? "mod" : "umod");
}

// -----------------
// Binary operations
// -----------------

// Binary or: HL = DE | HL

orfn()
{
	callrt("or");
}

// Binary xor: HL = DE ^ HL

xorfn()
{
	callrt("xor");
}

// Binary and: HL = DE & HL

andfn()
{
	callrt("and");
}

// Right shift: HL = DE >> HL

a_sr(sign)
int sign;
{
	callrt(sign ? "asr" : "uasr");
}

// Left shift: HL = DE << HL

a_sl(sign)
int sign;
{
	callrt(sign ? "asl" : "uasl");
}

// Two complement: HL = -HL

negfn()
{
	callrt("neg");
}

// One complement: HL = ~HL

comfn()
{
	callrt("com");
}

// Increment: HL = HL + 1

finc()
{
	a_code("INC HL");
}

// Decrement: HL = HL - 1

fdec()
{
	a_code("DEC HL");
}

// ------------------------------------------------
// Logical and comparison operators
// out: non zero value if true; zero falue if false
// ------------------------------------------------

// Equal: HL = DE == HL

eq()
{
	callrt("eq");
}

// Not equal: HL = DE != HL

ne()
{
	callrt("ne");
}

// Less: HL = DE < HL

a_lt(sign)
int sign;
{
	callrt(sign ? "lt" : "ult");
}

// Less or equal: HL = DE <= HL

a_le(sign)
int sign;
{
	callrt(sign ? "le" : "ule");
}

// Greather: HL = DE > HL

a_gt(sign)
int sign;
{
	callrt(sign ? "gt" : "ugt");
}

// Greather or equal: HL = DE >= HL

a_ge(sign)
int sign;
{
	callrt(sign ? "ge" : "uge");
}

// Logical and: HL = DE && HL

lgandfn()
{
	callrt("lgand");
}

// Logical or: HL = DE || HL

lgorfn()
{
	callrt("lgor");
}

// Logical not: HL = !HL

lgnotfn()
{
	callrt("lgnot");
}
