/*
	HEADER:		CUG149;
	TITLE:		6801 Cross-Assembler (Portable);
	FILENAME:	A68.C;
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

3.5+ FEB 2019	Added option for Motorola S records. HRJ

3.5! Aug 2019   added col-1 '*' comment support HRJ

This file contains the main program and line assembly routines for the
assembler.  The main program parses the command line, feeds the source lines to
the line assembly routine, and sends the results to the listing and object file
output routines.  It also coordinates the activities of everything.  The line
assembly routines uses the expression analyzer and the lexical analyzer to
parse the source line and convert it into the object bytes that it represents.
*/

/*  Get global goodies:  */

#include "a68.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

/* eternal routines HRJ*/

    void asm_line(void);
    void lclose(void), lopen(char *), lputs(void);
    void hclose(void), hopen(char *), hputc(unsigned);
    void error(char), fatal_error(char *), warning(char *);
    void pops(char *), pushc(int), trash(void);
	int popc(void);
	void hseek(unsigned);
	void unlex(void);
	int isalph(char); /* was int isalph(int) HRJ */

	/* these are local but used before defined HRJ */
	static void do_label(void),normal_op(void), pseudo_op(void);
	static void flush(void);


/*  Define global mailboxes for all modules:				*/

char errcode, line[MAXLINE + 1], title[MAXLINE];
char hformat='I'; /* (I)ntel or (M)otorola hex format*/
int pass = 0;
int eject, filesp, forwd, listhex;
unsigned  address, bytes, errors, listleft, obj[MAXLINE], pagelen, pc;
FILE *filestk[FILES], *source;
TOKEN token;

/*  Mainline routine.  This routine parses the command line, sets up	*/
/*  the assembler at the beginning of each pass, feeds the source text	*/
/*  to the line assembler, feeds the result to the listing and hex file	*/
/*  drivers, and cleans everything up at the end of the run.		*/

static int done, extend, ifsp, off;

void main(argc,argv)
int argc;
char **argv;
{
    SCRATCH unsigned *o;
    int newline(void);

    printf("6800/6801 Cross-Assembler (Portable) Ver 3.5!\n");
    printf("Copyright (c) 1985 William C. Colley, III\n");
    printf("fixes for LCC/Windows and improvement by HRJ Aug 26 2019\n");
    printf("A68 source_file | -l list_file | | -o/-s object_file |\n\n");

    while (--argc > 0) {
	if (**++argv == '-') {
	    switch (toupper(*++*argv)) {
		case 'L':   if (!*++*argv) {
				if (!--argc) { warning(NOLST);  break; }
				else ++argv;
			    }
			    lopen(*argv);
			    break;

		case 'O':   if (!*++*argv) {
				if (!--argc) { warning(NOHEX);  break; }
				else ++argv;
			    }
			    hopen(*argv); hformat='I';
			    break;

		case 'S':   if (!*++*argv) {
				if (!--argc) { warning(NOHEX);  break; }
				else ++argv;
			    }
			    hopen(*argv); hformat='M';
			    break;
		default:    warning(BADOPT);
	    }
	}
	else if (filestk[0]) warning(TWOASM);
	else if (!(filestk[0] = fopen(*argv,"r"))) fatal_error(ASMOPEN);
    }
    if (!filestk[0]) fatal_error(NOASM);

    while (++pass < 3) {
	fseek(source = filestk[0],0L,0);  done = extend = off = FALSE;
	errors = filesp = ifsp = pagelen = pc = 0;  title[0] = '\0';
	while (!done) {
	    errcode = ' ';
	    if (newline()) {
		error('*');
		strcpy(line,"\tEND\n");
		done = eject = TRUE;  listhex = FALSE;
		bytes = 0;
	    }
	    else asm_line();
	    pc = word(pc + bytes);
	    if (pass == 2) {
		lputs();
		for (o = obj; bytes--; hputc(*o++));
	    }
	}
    }

    fclose(filestk[0]);  lclose();  hclose();

    if (errors) printf("%d Error(s)\n",errors);
    else printf("No Errors\n");

    exit(errors);
}

/*  Line assembly routine.  This routine gets expressions and tokens	*/
/*  from the source file using the expression evaluator and lexical	*/
/*  analyzer, respectively.  It fills a buffer with the machine code	*/
/*  bytes and returns nothing.						*/

static char label[MAXLINE];
static int ifstack[IFDEPTH] = { ON };

static OPCODE *opcod;

void asm_line(void)
{
    SCRATCH int i,j;
    /* int isalph(); */
	/* int popc(); */
    OPCODE *find_code(char *), *find_operator(char *);

    /* void do_label(), flush(), normal_op(), pseudo_op(); */
    /* void error(), pops(), pushc(), trash(); */

    address = pc;  bytes = 0;  eject = forwd = listhex = FALSE;
    for (i = 0; i < BIGINST; obj[i++] = NOP);

    label[0] = '\0';
    if ((i = popc()) != ' ' && i != '\n') {
	if (isalph((char) i)) { /* HRJ */
	    pushc(i);  pops(label);
		/* HRJ remove colon from label */
		j = strlen(label); if (label[j-1]==':') label[j-1] ='\0';
		/* printf("asm_Line>>%s<<\n",label);  /* HRJ diagnostic */
	    if (find_operator(label)) { label[0] = '\0';  error('L'); }
	}
	else {
	    error('L');
	    while ((i = popc()) != ' ' && i != '\n');
	}
    }

    trash(); opcod = NULL;
    if ((i = popc()) != '\n') {
	if (!isalph((char) i)) error('S'); /* HRJ */
	else {
	    pushc(i);  pops(token.sval);
	    if (!(opcod = find_code(token.sval))) error('O');
	}
	if (!opcod) { listhex = TRUE;  bytes = BIGINST; }
    }

    if (opcod && opcod -> attr & ISIF) { if (label[0]) error('L'); }
    else if (off) { listhex = FALSE;  flush();  return; }

    if (!opcod) { do_label();  flush(); }
    else {
	listhex = TRUE;
	if (opcod -> attr & PSEUDO) pseudo_op();
	else normal_op();
	while ((i = popc()) != '\n') if (i != ' ') error('T');
    }
    source = filestk[filesp];
    return;
}

static void flush(void)
{
    /* int popc(void); */
    while (popc() != '\n');
}

static void do_label(void)
{
    SCRATCH SYMBOL *l;
    SYMBOL *find_symbol(char *), *new_symbol(char *);
    /* void error() */

    if (label[0]) {
	listhex = TRUE;
	if (pass == 1) {
	    if (!((l = new_symbol(label)) -> attr)) {
		l -> attr = FORWD + VAL;
		l -> valu = pc;
	    }
	}
	else {
	    if (l = find_symbol(label)) {
		l -> attr = VAL;
		if (l -> valu != pc) error('M');
	    }
	    else error('P');
	}
    }
}

#define	NONUM		0
#define	NEEDBYTE	1
#define	HAVENUM		2

static void normal_op(void)
{
    SCRATCH int numctl;
    SCRATCH unsigned attrib, opcode, operand;
    unsigned expr(void);
    TOKEN *lex(void);
    void do_label(void), unlex(void);

    do_label();

    attrib = opcod -> attr;
    bytes = 1;  opcode = opcod -> valu;  operand = 0;
    if (extend && opcode == 0x8d) attrib |= DIROK;
    numctl = NONUM;

    if (attrib & IS6801) {
	attrib &= ~IS6801;
	if (!extend) error('O');
    }

    for (;;) {
	switch (lex() -> attr & TYPE) {
	    case REG:	switch (token.valu) {
			    case 'B':	if (opcode < 0x40) ++opcode;
					else opcode |= opcode < 0x80 ?
					    0x10 : 0x40;

			    case 'A':	if (attrib & REGOPT) {
					    attrib = NONE;  numctl = HAVENUM;
					    break;
			    		}
					if (attrib & REGREQ) {
					    attrib &= ~REGREQ;  break;
					}
					error('R');  bytes = 3;  return;

			    case 'X':	bytes = 3;
					if (!(attrib & INDEX)) {
					    error('A');  return;
					}
					if (numctl == HAVENUM &&
					    operand > 0xff) {
					    error('V');  return;
					}
					bytes = 2;  numctl = NEEDBYTE;
					opcode = (opcode | 0x20) & 0xef;
					attrib &= REGREQ;  break;
			}
			if ((lex() -> attr & TYPE) != SEP) unlex();
			break;

	    case IMM:	bytes = 3;
			if (!(attrib & (IMM16 + IMM8))) {
			    error('A');  return;
			}
			operand = expr();
			if (attrib & IMM8) {
			    --bytes;
			    if (operand > 0xff && operand < 0xff80) {
				error('V');  return;
			    }
			}
			attrib &= REGREQ;  break;

	    case OPR:
	    case STR:
	    case VAL:	unlex();
			operand = expr();
			if (attrib & REL) {
			    numctl = HAVENUM;  bytes = 2;
			    operand = word(operand - (pc + 2));
			    if (operand > 0x7f && operand < 0xff80) {
				error('B');  return;
			    }
			    attrib = NONE;  break;
			}

	    case SEP:	bytes = 3;
			if (numctl == NEEDBYTE) {
			    if (operand > 0xff && operand < 0xff80) {
				error('V');  return;
			    }
			    numctl = HAVENUM;  bytes = 2;  break;
			}
			if (numctl == HAVENUM || !(attrib & INDEX)) {
			    error('S');  return;
			}
			numctl = HAVENUM;  opcode |= 0x30;
			attrib &= (INDEX + REGREQ + DIROK);
			break;

	    case EOL:	if (attrib & ~(DIROK + INDEX)) {
			    error(attrib & REGREQ || (attrib & (REGOPT + INDEX)
				== (REGOPT + INDEX)) ? 'R' : 'S');
			    bytes = 3;  return;
			}
			if (attrib & DIROK && !forwd && operand <= 0xff) {
			    bytes = 2;  opcode ^= 0x20;
			}

			obj[0] = opcode;
			if (bytes == 2) obj[1] = low(operand);
			if (bytes == 3) {
			    obj[1] = high(operand);
			    obj[2] = low(operand);
			}
			return;
	}
    }
}

static void pseudo_op(void)
{
    SCRATCH char *s;
    SCRATCH unsigned *o, u;
    SCRATCH SYMBOL *l;

    unsigned expr(void);
    SYMBOL *find_symbol(char *), *new_symbol(char *);
    TOKEN *lex(void);
    /* void do_label(), error(), fatal_error(), hseek(), unlex(); */

    o = obj;
    switch (opcod -> valu) {
	case CPU:   listhex = FALSE;  do_label();
		    u = expr();
		    if (forwd) error('P');
		    else if (u != 6800 && u != 6801) error('V');
		    else extend = u == 6801;
		    break;

	case ELSE:  listhex = FALSE;
		    if (ifsp) off = (ifstack[ifsp] = -ifstack[ifsp]) != ON;
		    else error('I');
		    break;

	case END:   do_label();
		    if (filesp) { listhex = FALSE;  error('*'); }
		    else {
			done = eject = TRUE;
			if (pass == 2 && (lex() -> attr & TYPE) != EOL) {
			    unlex();  hseek(address = expr());
			}
			if (ifsp) error('I');
		    }
		    break;

	case ENDI:  listhex = FALSE;
		    if (ifsp) off = ifstack[--ifsp] != ON;
		    else error('I');
		    break;

	case EQU:   if (label[0]) {
			if (pass == 1) {
			    if (!((l = new_symbol(label)) -> attr)) {
				l -> attr = FORWD + VAL;
				address = expr();
				if (!forwd) l -> valu = address;
			    }
			}
			else {
			    if (l = find_symbol(label)) {
				l -> attr = VAL;
				address = expr();
				if (forwd) error('P');
				if (l -> valu != address) error('M');
			    }
			    else error('P');
			}
		    }
		    else error('L');
		    break;

	case FCB:   do_label();
		    do {
			if ((lex() -> attr & TYPE) == SEP) u = 0;
			else {
			    unlex();
			    if ((u = expr()) > 0xff && u < 0xff80) {
				u = 0;  error('V');
			    }
			}
			*o++ = low(u);  ++bytes;
		    } while ((token.attr & TYPE) == SEP);
		    break;

	case FCC:   do_label();
		    while ((lex() -> attr & TYPE) != EOL) {
			if ((token.attr & TYPE) == STR) {
			    for (s = token.sval; *s; *o++ = *s++)
				++bytes;
			    if ((lex() -> attr & TYPE) != SEP) unlex();
			}
			else error('S');
		    }
		    break;

	case FDB:   do_label();
		    do {
			if ((lex() -> attr & TYPE) == SEP) u = 0;
			else { unlex();  u = expr(); }
			*o++ = high(u);  *o++ = low(u);
			bytes += 2;
		    } while ((token.attr & TYPE) == SEP);
		    break;

	case IF:    if (++ifsp == IFDEPTH) fatal_error(IFOFLOW);
		    address = expr();
		    if (forwd) { error('P');  address = TRUE; }
		    if (off) { listhex = FALSE;  ifstack[ifsp] = ZERO; } /* was NULL but error */

		    else {
			ifstack[ifsp] = address ? ON : OFF;
			if (!address) off = TRUE;
		    }
		    break;

	case INCL:  listhex = FALSE;  do_label();
		    if ((lex() -> attr & TYPE) == STR) {
			if (++filesp == FILES) fatal_error(FLOFLOW);
			if (!(filestk[filesp] = fopen(token.sval,"r"))) {
			    --filesp;  error('V');
			}
		    }
		    else error('S');
		    break;

	case ORG:   u = expr();
		    if (forwd) error('P');
		    else {
			pc = address = u;
			if (pass == 2) hseek(pc);
		    }
		    do_label();
		    break;

	case PAGE:  listhex = FALSE;  do_label();
		    if ((lex() -> attr & TYPE) != EOL) {
			unlex();  pagelen = expr();
			if (pagelen > 0 && pagelen < 3) {
			    pagelen = 0;  error('V');
			}
		    }
		    eject = TRUE;
		    break;

	case RMB:   do_label();
		    u = word(pc + expr());
		    if (forwd) error('P');
		    else {
			pc = u;
			if (pass == 2) hseek(pc);
		    }
		    break;

	case SET:   if (label[0]) {
			if (pass == 1) {
			    if (!((l = new_symbol(label)) -> attr)
				|| (l -> attr & SOFT)) {
				l -> attr = FORWD + SOFT + VAL;
				address = expr();
				if (!forwd) l -> valu = address;
			    }
			}
			else {
			    if (l = find_symbol(label)) {
				address = expr();
				if (forwd) error('P');
				else if (l -> attr & SOFT) {
				    l -> attr = SOFT + VAL;
				    l -> valu = address;
				}
				else error('M');
			    }
			    else error('P');
			}
		    }
		    else error('L');
		    break;

	case TITL:  listhex = FALSE;  do_label();
		    if ((lex() -> attr & TYPE) == EOL) title[0] = '\0';
		    else if ((token.attr & TYPE) != STR) error('S');
		    else strcpy(title,token.sval);
		    break;
    }
    return;
}
