/*
	HEADER:		CUG149;
	TITLE:		6801 Cross-Assembler (Portable);
	FILENAME:	A68EVAL.C;
	VERSION:	3.5;
	DATE:		08/27/1988;

	DESCRIPTION:	"This program lets you use your computer to assemble
			code for the Motorola 6800, 6801, 6802, 6803, 6808,
			and 68701 microprocessors.  The program is written in
			portable C rather than BDS C.  All assembler features
			are supported except relocation, linkage, and macros.";

	KEYWORDS:	Software Development, Assemblers, Cross-Assemblers,
			Motorola, MC6800, MC6801;

	SEE-ALSO:	CUG113, 6800 Cross-Assembler;

	SYSTEM:		CP/M-80, CP/M-86, HP-UX, MSDOS, PCDOS, QNIX;
	COMPILERS:	Aztec C86, Aztec CII, CI-C86, Eco-C, Eco-C88, HP-UX,
			Lattice C, Microsoft C,	QNIX C;

	WARNINGS:	"This program has compiled successfully on 2 UNIX
			compilers, 5 MSDOS compilers, and 2 CP/M compilers.
			A port to BDS C would be extremely difficult, but see
			volume CUG113.  A port to Toolworks C is untried."

	AUTHORS:	William C. Colley III;
*/

/*
		      6801 Cross-Assembler in Portable C

		   Copyright (c) 1985 William C. Colley, III

Revision History:

Ver	Date		Description

3.0	APR 1985	Recoded from BDS C version 2.5.  WCC3.

3.1	AUG 1985	Greatly shortened the routines find_symbol() and
			new_symbol().  Fixed bugs in expression evaluator.
			Added compilation instructions for Aztec C86,
			Microsoft C, and QNIX C.  Added optional optimizations
			for 16-bit machines.  Adjusted structure members for
			fussy compilers.  WCC3.

3.2	SEP 1985	Added the INCL pseudo-op and associated stuff.  WCC3.

3.3	JUL 1986	Added compilation instructions and tweaks for CI-C86,
			Eco-C88, and Lattice C.  WCC3.

3.4	JAN 1987	Fixed bug that made "FCB 0," legal syntax.  WCC3.

3.5	AUG 1988	Fixed a bug in the command line parser that puts it
			into a VERY long loop if the user types a command line
			like "A68 FILE.ASM -L".  WCC3 per Alex Cameron.

???	Aug 2019	HRJ col 1=* as comment line

This file contains the assembler's expression evaluator and lexical analyzer.
The lexical analyzer chops the input character stream up into discrete tokens
that are processed by the expression analyzer and the line assembler.  The
expression analyzer processes the token stream into unsigned results of
arithmetic expressions.
*/

/*  Get global goodies:  */

#include "a68.h"
#include <ctype.h>
#include <string.h>


/* from A18eval.c HRJ */
/* local  prototypes HRJ*/
static unsigned eval(unsigned);
static void exp_error(char);
void unlex(void);
TOKEN *lex(void);
static void make_number(unsigned);
int popc(void);
void pushc(char);
int isalph(char); /* was isalph(int) HRJ */
static int isnum(char), ischar(char), ishex(char);
static int isalpnum(char c);

/* external prototypes HRJ*/
void error(char);
void pops(char *), trash(void);
OPCODE *find_operator(char *);
SYMBOL *find_symbol(char *);

void asm_line(void);
void lclose(void), lopen(char *), lputs(void);
void hclose(void), hopen(char *), hputc(unsigned);
void error(char), fatal_error(char *), warning(char *);
void hseek(unsigned);
void unlex(void);
/* above from A68eval.c HRJ */

/*  Get access to global mailboxes defined in A68.C:			*/

extern char line[];
extern int filesp, forwd, pass;
extern unsigned pc;
extern FILE *filestk[], *source;
extern TOKEN token;

/*  Expression analysis routine.  The token stream from the lexical	*/
/*  analyzer is processed as an arithmetic expression and reduced to an	*/
/*  unsigned value.  If an error occurs during the evaluation, the	*/
/*  global flag	forwd is set to indicate to the line assembler that it	*/
/*  should not base certain decisions on the result of the evaluation.	*/

static int bad;

unsigned expr()
{
    SCRATCH unsigned u;
    /* unsigned eval(); */

    bad = FALSE;
    u = eval(START);
    return bad ? 0 : u;
}

static unsigned eval(pre)
unsigned pre;
{
    register unsigned op, u, v;
    /* TOKEN *lex();
    void exp_error(), unlex();*/

    for (;;) {
	u = op = lex() -> valu;
	switch (token.attr & TYPE) {
	    case REG:
	    case IMM:	exp_error('S');  break;

	    case SEP:	if (pre != START) unlex();
	    case EOL:	exp_error('E');  return (u); /* return had no value HRJ*/
	    case OPR:	if (!(token.attr & UNARY)) { exp_error('E');  break; }
			u = (op == '*' ? pc :
			    eval((op == '+' || op == '-') ?
				(unsigned) UOP1 : token.attr & PREC));
			switch (op) {
			    case '-':	u = word(0-u);  break; /* had (-u) HRJ */

			    case NOT:	u ^= 0xffff;  break;

			    case HIGH:	u = high(u);  break;

			    case LOW:	u = low(u);  break;
			}

	    case VAL:
	    case STR:	for (;;) {
			    op = lex() -> valu;
			    switch (token.attr & TYPE) {
				case REG:
				case IMM:   exp_error('S');  break;

				case SEP:   if (pre != START) unlex();
				case EOL:   if (pre == LPREN) exp_error('(');
					    return u;

				case STR:
				case VAL:   exp_error('E');  break;

				case OPR:   if (!(token.attr & BINARY)) {
						exp_error('E');  break;
					    }
					    if ((token.attr & PREC) >= pre) {
						unlex();  return u;
					    }
					    if (op != ')')
						v = eval(token.attr & PREC);
					    switch (op) {
						case '+':   u += v;  break;

						case '-':   u -= v;  break;

						case '*':   u *= v;  break;

						case '/':   if (v!=0) u /= v; else exp_error('E');  break;

						case MOD:   if (v!=0) u %= v; else exp_error('E'); break;

						case AND:   u &= v;  break;

						case OR:    u |= v;  break;

						case XOR:   u ^= v;  break;

						case '<':   u = u < v;  break;

						case LE:    u = u <= v;  break;

						case '=':   u = u == v;  break;

						case GE:    u = u >= v;  break;

						case '>':   u = u > v;  break;

						case NE:    u = u != v;  break;

						case SHL:   if (v > 15)
								exp_error('E');
							    else u <<= v;
							    break;

						case SHR:   if (v > 15)
								exp_error('E');
							    else u >>= v;
							    break;

						case ')':   if (pre == LPREN)
								return u;
							    exp_error('(');
							    break;
					    }
					    clamp(u);
					    break;
			    }
			}
			break;
		}
    }
}

static void exp_error(char c)
{
    forwd = bad = TRUE;  error(c);
}

/*  Lexical analyzer.  The source input character stream is chopped up	*/
/*  into its component parts and the pieces are evaluated.  Symbols are	*/
/*  looked up, operators are looked up, etc.  Everything gets reduced	*/
/*  to an attribute word, a numeric value, and (possibly) a string	*/
/*  value.								*/

static int oldt = FALSE;
static int quote = FALSE;

TOKEN *lex(void)
{
    SCRATCH char c, *p;
    SCRATCH unsigned b;
    SCRATCH OPCODE *o;
    SCRATCH SYMBOL *s;

    /* OPCODE *find_operator();
    SYMBOL *find_symbol();
    void exp_error(), make_number(), pops(), pushc(), trash(); */

    if (oldt) { oldt = FALSE;  return &token; }
    trash();
    if (isalph(c = popc())) {
	pushc(c);  pops(token.sval);
	if (o = find_operator(token.sval)) {
	    token.attr = o -> attr;
	    token.valu = o -> valu;
	}
	else {
	    token.attr = VAL;  token.valu = 0;

	    if (s = find_symbol(token.sval)) {
		token.valu = s -> valu;
		if (pass == 2 && s -> attr & FORWD) forwd = TRUE;
	    }
	    else exp_error('U');
	}
    }
    else if (isnum(c)) {
	pushc(c);  pops(token.sval);
	for (p = token.sval; *p; ++p);
	switch (toupper(*--p)) {
	    case 'B':	b = 2;  break;

	    case 'O':
	    case 'Q':	b = 8;  break;

	    default:	++p;
	    case 'D':	b = 10;  break;

	    case 'H':	b = 16;  break;
	}
	*p = '\0';  make_number(b);
    }
    else switch (c) {
	case '%':   b = 2;  goto num;

	case '@':   b = 8;  goto num;

	case '$':   b = 16;
num:		    pops(token.sval);
		    make_number(b);
		    break;

	case '#':   token.attr = IMM;
		    break;

	case '(':   token.attr = UNARY + LPREN + OPR;
		    goto opr1;

	case ')':   token.attr = BINARY + RPREN + OPR;
		    goto opr1;

	case '+':   token.attr = BINARY + UNARY + ADDIT + OPR;
		    goto opr1;

	case '-':   token.attr = BINARY + UNARY + ADDIT + OPR;
		    goto opr1;

	case '*':   token.attr = BINARY + UNARY + MULT + OPR;
		    goto opr1;

	case '/':   token.attr = BINARY + MULT + OPR;
opr1:		    token.valu = c;
		    break;

	case '<':   token.valu = c;
		    if ((c = popc()) == '=') token.valu = LE;
		    else if (c == '>') token.valu = NE;
		    else pushc(c);
		    goto opr2;

	case '=':   token.valu = c;
		    if ((c = popc()) == '<') token.valu = LE;
		    else if (c == '>') token.valu = GE;
		    else pushc(c);
		    goto opr2;

	case '>':   token.valu = c;
		    if ((c = popc()) == '<') token.valu = NE;
		    else if (c == '=') token.valu = GE;
		    else pushc(c);
opr2:		    token.attr = BINARY + RELAT + OPR;
		    break;

	case '\'': /* single quote and double quote */
	case '"':   quote = TRUE;  token.attr = STR;
		    for (p = token.sval; (*p = popc()) != c; ++p)
			if (*p == '\n') { exp_error('"');  break; }
		    *p = '\0';  quote = FALSE;
		    if ((token.valu = token.sval[0]) && token.sval[1])
			token.valu = (token.valu << 8) + token.sval[1];
		    break;

	case ',':   token.attr = SEP;
		    break;

        case '\n':  token.attr = EOL;
		    break;
    }
    return &token;
}

static void make_number(base)
unsigned base;
{
    SCRATCH char *p;
    SCRATCH unsigned d;
    /* void exp_error(); */

    token.attr = VAL;
    token.valu = 0;
    for (p = token.sval; *p; ++p) {
	d = toupper(*p) - (isnum(*p) ? '0' : 'A' - 10);
	token.valu = token.valu * base + d;
	if (!ishex(*p) || d >= base) { exp_error('D');  break; }
    }
    clamp(token.valu);
    return;
}

int isalph(char c)
{
    return (c >= 'A' && c <= '~') || c == '!' ||
	c == '&' || c == '.' || c == ':' || c == '?';
}

static int isnum(char c)
{
    return c >= '0' && c <= '9';
}

static int ishex(char c)
{
    return isnum(c) || ((c = toupper(c)) >= 'A' && c <= 'F');
}

static int isalpnum(char c) /* was isalnum(), already in ctype.h HRJ */
{
    return isalph(c) || isnum(c);
}

/*  Push back the current token into the input stream.  One level of	*/
/*  pushback is supported.						*/

void unlex()
{
    oldt = TRUE;
    return;
}

/*  Get an alphanumeric string into the string value part of the	*/
/*  current token.  Leading blank space is trashed.			*/

void pops(s)
char *s;
{
    /* void pushc(), trash(); */

    trash();
    for (; isalpnum(*s = popc()); ++s);
    pushc(*s);  *s = '\0';
    return;
}

/*  Trash blank space and push back the character following it.		*/

void trash()
{
    SCRATCH char c;
    /* void pushc(); */

    while ((c = popc()) == ' ');
    pushc(c);
    return;
}

/*  Get character from input stream.  This routine does a number of	*/
/*  other things while it's passing back characters.  All control	*/
/*  characters except \t and \n are ignored.  \t is mapped into ' '.	*/
/*  Semicolon is mapped to \n.  In addition, a copy of all input is set	*/
/*  up in a line buffer for the benefit of the listing.			*/

static int oldc, eol;
static char *lptr;

int popc(void)
{
    SCRATCH int c;

    if (oldc) { c = oldc;  oldc = '\0';  return c; }
    if (eol) return '\n';
    for (;;) {
	if ((c = getc(source)) != EOF) {
         if ((c &= 0377) == ';' && !quote) { /* comment to EOL */
	       do *lptr++ = c;
	       while ((c = getc(source)) != EOF && (c &= 0377) != '\n');
             }
         if ((c == '*') && (lptr==line)) {/* col 1 is star, comment to EOL  */
	       do *lptr++ = c;
	       while ((c = getc(source)) != EOF && (c &= 0377) != '\n');
             }
	}
	if (c == EOF) c = '\n';
	if ((*lptr++ = c) >= ' ' && c <= '~') return c;
	if (c == '\n') { eol = TRUE;  *lptr = '\0';  return '\n'; }
	if (c == '\t') return quote ? '\t' : ' ';
    }
}

/*  Push character back onto input stream.  Only one level of push-back	*/
/*  supported.  \0 cannot be pushed back, but nobody would want to.	*/

void pushc(char c)
{
    oldc = c;
    return;
}

/*  Begin new line of source input.  This routine returns non-zero if	*/
/*  EOF	has been reached on the main source file, zero otherwise.	*/

int newline()
{
    /* void fatal_error(); */

    oldc = '\0';  lptr = line;
    oldt = eol = FALSE;
    while (feof(source)) {
	if (ferror(source)) fatal_error(ASMREAD);
	if (filesp) {
	    fclose(source);
	    source = filestk[--filesp];
	}
	else return TRUE;
    }
    return FALSE;
}

