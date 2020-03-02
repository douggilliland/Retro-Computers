/*
	HEADER:		CUG149;
	TITLE:		6801 Cross-Assembler (Portable);
	FILENAME:	A68UTIL.C;
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

3.5+ Feb 2019	Added S-record format HRJ.

This module contains the following utility packages:

	1)  symbol table building and searching

	2)  opcode and operator table searching

	3)  listing file output

	4)  hex file output

	5)  error flagging
*/

/*  Get global goodies:  */
#include "a68.h"
#include <string.h>
#include <ctype.h>
#include <malloc.h> /* for lcc-32 HRJ */
/* #include <alloc.h> for Turbo C HRJ */
#include <stdio.h>
#include <stdlib.h>


/*  Make sure that MSDOS compilers using the large memory model know	*/
/*  that calloc() returns pointer to char as an MSDOS far pointer is	*/
/*  NOT compatible with the int type as is usually the case.		*/

/* char *calloc(); */

/*HRJ local declarations */

static OPCODE *bccsearch(OPCODE *, OPCODE *, char *);
static void list_sym(SYMBOL *);
void fatal_error(char *);
static void check_page(void);
static void record(unsigned);
static void srecord(unsigned);
static void putb(unsigned);
static int ustrcmp(char *, char*);
void warning(char *);


/*  Get access to global mailboxes defined in A68.C:			*/

extern char errcode, line[], title[];
extern char hformat; /* (I)ntel or (M)otorola hex format*/
extern int eject, listhex;
extern unsigned address, bytes, errors, listleft, obj[], pagelen;

/*  The symbol table is a binary tree of variable-length blocks drawn	*/
/*  from the heap with the calloc() function.  The root pointer lives	*/
/*  here:								*/

static SYMBOL *sroot = NULL;

/*  Add new symbol to symbol table.  Returns pointer to symbol even if	*/
/*  the symbol already exists.  If there's not enough memory to store	*/
/*  the new symbol, a fatal error occurs.				*/

SYMBOL *new_symbol(nam)
char *nam;
{
    SCRATCH int i;
    SCRATCH SYMBOL **p, *q;
    /* void fatal_error(); */

    for (p = &sroot; (q = *p) && (i = strcmp(nam,q -> sname)); )
	p = i < 0 ? &(q -> left) : &(q -> right);
    if (!q) {
	if (!(*p = q = (SYMBOL *)calloc(1,sizeof(SYMBOL) + strlen(nam))))
	    fatal_error(SYMBOLS);
	strcpy(q -> sname,nam);
    }
    return q;
}

/*  Look up symbol in symbol table.  Returns pointer to symbol or NULL	*/
/*  if symbol not found.						*/

SYMBOL *find_symbol(nam)
char *nam;
{
    SCRATCH int i;
    SCRATCH SYMBOL *p;

    for (p = sroot; p && (i = strcmp(nam,p -> sname));
	p = i < 0 ? p -> left : p -> right);
    return p;
}

/*  Opcode table search routine.  This routine pats down the opcode	*/
/*  table for a given opcode and returns either a pointer to it or	*/
/*  NULL if the opcode doesn't exist.					*/

OPCODE *find_code(nam)
char *nam;
{
    /* OPCODE *bccsearch(); hrj */

    /* HRJ changed "NULL" to "NONE" in constructions below. */
    static OPCODE opctbl[] = {
	{ NONE,					0x1b,	"ABA"	},
	{ IS6801,				0x3a,	"ABX"	},
	{ DIROK + INDEX + IMM8 + REGREQ,	0x89,	"ADC"	},
	{ DIROK + INDEX + IMM8,			0x89,	"ADCA"	},
	{ DIROK + INDEX + IMM8,			0xc9,	"ADCB"	},
	{ DIROK + INDEX + IMM8 + REGREQ,	0x8b,	"ADD"	},
	{ DIROK + INDEX + IMM8,			0x8b,	"ADDA"	},
	{ DIROK + INDEX + IMM8,			0xcb,	"ADDB"	},
	{ IS6801 + DIROK + INDEX + IMM16,	0xc3,	"ADDD"	},
	{ DIROK + INDEX + IMM8 + REGREQ,	0x84,	"AND"	},
	{ DIROK + INDEX + IMM8,			0x84,	"ANDA"	},
	{ DIROK + INDEX + IMM8,			0xc4,	"ANDB"	},
	{ INDEX + REGOPT,			0x48,	"ASL"	},
	{ NONE,					0x48,	"ASLA"	},
	{ NONE,					0x58,	"ASLB"	},
	{ IS6801,				0x05,	"ASLD"	},
	{ INDEX + REGOPT,			0x47,	"ASR"	},
	{ NONE,					0x47,	"ASRA"	},
	{ NONE,					0x57,	"ASRB"	},
	{ REL,					0x24,	"BCC"	},
	{ REL,					0x25,	"BCS"	},
	{ REL,					0x27,	"BEQ"	},
	{ REL,					0x2c,	"BGE"	},
	{ REL,					0x2e,	"BGT"	},
	{ REL,					0x22,	"BHI"	},
	{ REL,					0x24,	"BHS"	},
	{ DIROK + INDEX + IMM8 + REGREQ,	0x85,	"BIT"	},
	{ DIROK + INDEX + IMM8,			0x85,	"BITA"	},
	{ DIROK + INDEX + IMM8,			0xc5,	"BITB"	},
	{ REL,					0x2f,	"BLE"	},
	{ REL,					0x25,	"BLO"	},
	{ REL,					0x23,	"BLS"	},
	{ REL,					0x2d,	"BLT"	},
	{ REL,					0x2b,	"BMI"	},
	{ REL,					0x26,	"BNE"	},
	{ REL,					0x2A,	"BPL"	},
	{ REL,					0x20,	"BRA"	},
	{ IS6801 + REL,				0x21,	"BRN"	},
	{ REL,					0x8d,	"BSR"	},
	{ REL,					0x28,	"BVC"	},
	{ REL,					0x29,	"BVS"	},
	{ NONE,					0x11,	"CBA"	},
	{ NONE,					0x0c,	"CLC"	},
	{ NONE,					0x0e,	"CLI"	},
	{ INDEX + REGOPT,			0x4f,	"CLR"	},
	{ NONE,					0x4f,	"CLRA"	},
	{ NONE,					0x5f,	"CLRB"	},
	{ NONE,					0x0a,	"CLV"	},
	{ DIROK + INDEX + IMM8 + REGREQ,	0x81,	"CMP"	},
	{ DIROK + INDEX + IMM8,			0x81,	"CMPA"	},
	{ DIROK + INDEX + IMM8,			0xc1,	"CMPB"	},
	{ INDEX + REGOPT,			0x43,	"COM"	},
	{ NONE,					0x43,	"COMA"	},
	{ NONE,					0x53,	"COMB"	},
	{ PSEUDO,				CPU,	"CPU"	},
	{ DIROK + INDEX + IMM16,		0x8c,	"CPX"	},
	{ NONE,					0x19,	"DAA"	},
	{ INDEX + REGOPT,			0x4a,	"DEC"	},
	{ NONE,					0x4a,	"DECA"	},
	{ NONE,					0x5a,	"DECB"	},
	{ NONE,					0x34,	"DES"	},
	{ NONE,					0x09,	"DEX"	},
	{ PSEUDO + ISIF,			ELSE,	"ELSE"	},
	{ PSEUDO,				END,	"END"	},
	{ PSEUDO + ISIF,			ENDI,	"ENDI"	},
	{ DIROK + INDEX + IMM8 + REGREQ,	0x88,	"EOR"	},
	{ DIROK + INDEX + IMM8,			0x88,	"EORA"	},
	{ DIROK + INDEX + IMM8,			0xc8,	"EORB"	},
	{ PSEUDO,				EQU,	"EQU"	},
	{ PSEUDO,				FCB,	"FCB"	},
	{ PSEUDO,				FCC,	"FCC"	},
	{ PSEUDO,				FDB,	"FDB"	},
	{ PSEUDO + ISIF,			IF,	"IF"	},
	{ INDEX + REGOPT,			0x4c,	"INC"	},
	{ NONE,					0x4c,	"INCA"	},
	{ NONE,					0x5c,	"INCB"	},
	{ PSEUDO,				INCL,	"INCL"	},
	{ NONE,					0x31,	"INS"	},
	{ NONE,					0x08,	"INX"	},
	{ INDEX,				0x4e,	"JMP"	},
	{ INDEX,				0x8d,	"JSR"	},
	{ DIROK + INDEX + IMM8 + REGREQ,	0x86,	"LDA"	},
	{ DIROK + INDEX + IMM8,			0x86,	"LDAA"	},
	{ DIROK + INDEX + IMM8,			0xc6,	"LDAB"	},
	{ IS6801 + DIROK + INDEX + IMM16,	0xcc,	"LDD"	},
	{ DIROK + INDEX + IMM16,		0x8e,	"LDS"	},
	{ DIROK + INDEX + IMM16,		0xce,	"LDX"	},
	{ INDEX + REGOPT,			0x48,	"LSL"	},
	{ NONE,					0x48,	"LSLA"	},
	{ NONE,					0x58,	"LSLB"	},
	{ IS6801,				0x05,	"LSLD"	},
	{ INDEX + REGOPT,			0x44,	"LSR"	},
	{ NONE,					0x44,	"LSRA"	},
	{ NONE,					0x54,	"LSRB"	},
	{ IS6801,				0x04,	"LSRD"	},
	{ IS6801,				0x3d,	"MUL"	},
	{ INDEX + REGOPT,			0x40,	"NEG"	},
	{ NONE,					0x40,	"NEGA"	},
	{ NONE,					0x50,	"NEGB"	},
	{ NONE,					0x01,	"NOP"	},
	{ DIROK + INDEX + IMM8 + REGREQ,	0x8a,	"ORA"	},
	{ DIROK + INDEX + IMM8,			0x8a,	"ORAA"	},
	{ DIROK + INDEX + IMM8,			0xca,	"ORAB"	},
	{ PSEUDO,				ORG,	"ORG"	},
	{ PSEUDO,				PAGE,	"PAGE"	},
	{ REGREQ,				0x36,	"PSH"	},
	{ NONE,					0x36,	"PSHA"	},
	{ NONE,					0x37,	"PSHB"	},
	{ IS6801,				0x3c,	"PSHX"	},
	{ REGREQ,				0x32,	"PUL"	},
	{ NONE,					0x32,	"PULA"	},
	{ NONE,					0x33,	"PULB"	},
	{ IS6801,				0x38,	"PULX"	},
	{ PSEUDO,				RMB,	"RMB"	},
	{ INDEX + REGOPT,			0x49,	"ROL"	},
	{ NONE,					0x49,	"ROLA"	},
	{ NONE,					0x59,	"ROLB"	},
	{ INDEX + REGOPT,			0x46,	"ROR"	},
	{ NONE,					0x46,	"RORA"	},
	{ NONE,					0x56,	"RORB"	},
	{ NONE,					0x3b,	"RTI"	},
	{ NONE,					0x39,	"RTS"	},
	{ NONE,					0x10,	"SBA"	},
	{ DIROK + INDEX + IMM8 + REGREQ,	0x82,	"SBC"	},
	{ DIROK + INDEX + IMM8,			0x82,	"SBCA"	},
	{ DIROK + INDEX + IMM8,			0xc2,	"SBCB"	},
	{ NONE,					0x0d,	"SEC"	},
	{ NONE,					0x0f,	"SEI"	},
	{ PSEUDO,				SET,	"SET"	},
	{ NONE,					0x0b,	"SEV"	},
	{ DIROK + INDEX + REGREQ,		0x87,	"STA"	},
	{ DIROK + INDEX,			0x87,	"STAA"	},
	{ DIROK + INDEX,			0xc7,	"STAB"	},
	{ IS6801 + DIROK + INDEX,		0xcd,	"STD"	},
	{ DIROK + INDEX,			0x8f,	"STS"	},
	{ DIROK + INDEX,			0xcf,	"STX"	},
	{ DIROK + INDEX + IMM8 + REGREQ,	0x80,	"SUB"	},
	{ DIROK + INDEX + IMM8,			0x80,	"SUBA"	},
	{ DIROK + INDEX + IMM8,			0xc0,	"SUBB"	},
	{ IS6801 + DIROK + INDEX + IMM16,	0x83,	"SUBD"	},
	{ NONE,					0x3f,	"SWI"	},
	{ NONE,					0x16,	"TAB"	},
	{ NONE,					0x06,	"TAP"	},
	{ NONE,					0x17,	"TBA"	},
	{ PSEUDO,				TITL,	"TITL"	},
	{ NONE,					0x07,	"TPA"	},
	{ INDEX + REGOPT,			0x4d,	"TST"	},
	{ NONE,					0x4d,	"TSTA"	},
	{ NONE,					0x5d,	"TSTB"	},
	{ NONE,					0x30,	"TSX"	},
	{ NONE,					0x35,	"TXS"	},
	{ NONE,					0x3e,	"WAI"	}
    };

    return bccsearch(opctbl,opctbl + (sizeof(opctbl) / sizeof(OPCODE)),nam);
}

/*  Operator table search routine.  This routine pats down the		*/
/*  operator table for a given operator and returns either a pointer	*/
/*  to it or NULL if the opcode doesn't exist.				*/

OPCODE *find_operator(nam)
char *nam;
{
    /* OPCODE *bccsearch(); */

    static OPCODE oprtbl[] = {
	{ REG,				'A',		"A"	},
	{ BINARY + LOG1  + OPR,		AND,		"AND"	},
	{ REG,				'B',		"B"	},
	{ BINARY + RELAT + OPR,		'=',		"EQ"	},
	{ BINARY + RELAT + OPR,		GE,		"GE"	},
	{ BINARY + RELAT + OPR,		'>',		"GT"	},
	{ UNARY  + UOP3  + OPR,		HIGH,		"HIGH"	},
	{ BINARY + RELAT + OPR,		LE,		"LE"	},
	{ UNARY  + UOP3  + OPR,		LOW,		"LOW"	},
	{ BINARY + RELAT + OPR,		'<',		"LT"	},
	{ BINARY + MULT  + OPR,		MOD,		"MOD"	},
	{ BINARY + RELAT + OPR,		NE,		"NE"	},
	{ UNARY  + UOP2  + OPR,		NOT,		"NOT"	},
	{ BINARY + LOG2  + OPR,		OR,		"OR"	},
	{ BINARY + MULT  + OPR,		SHL,		"SHL"	},
	{ BINARY + MULT  + OPR,		SHR,		"SHR"	},
	{ REG,				'X',		"X"	},
	{ BINARY + LOG2  + OPR,		XOR,		"XOR"	}
    };

    return bccsearch(oprtbl,oprtbl + (sizeof(oprtbl) / sizeof(OPCODE)),nam);
}

static int ustrcmp(s,t)
char *s, *t;
{
    SCRATCH int i;

    while (!(i = toupper(*s++) - toupper(*t)) && *t++);
    return i;
}

static OPCODE *bccsearch(OPCODE *lo, OPCODE *hi, char *nam)
{
    SCRATCH int i;
    SCRATCH OPCODE *chk;

    for (;;) {
	chk = lo + (hi - lo) / 2;
	if (!(i = ustrcmp(chk -> oname,nam))) return chk;
	if (chk == lo) return NULL;
	if (i < 0) lo = chk;
	else hi = chk;
    }
}



/*  Buffer storage for line listing routine.  This allows the listing	*/
/*  output routines to do all operations without the main routine	*/
/*  having to fool with it.						*/

static FILE *list = NULL;

/*  Listing file open routine.  If a listing file is already open, a	*/
/*  warning occurs.  If the listing file doesn't open correctly, a	*/
/*  fatal error occurs.  If no listing file is open, all calls to	*/
/*  lputs() and lclose() have no effect.				*/

void lopen(nam)
char *nam;
{
    /* FILE *fopen();
    void fatal_error(), warning(); */

    if (list) warning(TWOLST);
    else if (!(list = fopen(nam,"w"))) fatal_error(LSTOPEN);
    return;
}

/*  Listing file line output routine.  This routine processes the	*/
/*  source line saved by popc() and the output of the line assembler in	*/
/*  buffer obj into a line of the listing.  If the disk fills up, a	*/
/*  fatal error occurs.							*/

void lputs()
{
    SCRATCH int i, j;
    SCRATCH unsigned *o;
    /* void check_page(), fatal_error(); */

    if (list) {
	i = bytes;  o = obj;
	do {
	    fprintf(list,"%c  ",errcode);
	    if (listhex) {
		fprintf(list,"%04x  ",address);
		for (j = 4; j; --j) {
		    if (i) { --i;  ++address;  fprintf(list," %02x",*o++); }
		    else fprintf(list,"   ");
		}
	    }
	    else fprintf(list,"%18s","");
	    fprintf(list,"   %s",line);  strcpy(line,"\n");
	    check_page();
	    if (ferror(list)) fatal_error(DSKFULL);
	} while (listhex && i);
    }
    return;
}

/*  Listing file close routine.  The symbol table is appended to the	*/
/*  listing in alphabetic order by symbol name, and the listing file is	*/
/*  closed.  If the disk fills up, a fatal error occurs.		*/

static int col = 0;

void lclose()
{
    /* void fatal_error(), list_sym(); */

    if (list) {
	if (sroot) {
	    list_sym(sroot);
	    if (col) fprintf(list,"\n");
	}
	fprintf(list,"\f");
	if (ferror(list) || fclose(list) == EOF) fatal_error(DSKFULL);
    }
    return;
}

static void list_sym(sp)
SYMBOL *sp;
{
    /* void check_page(); */

    if (sp) {
	list_sym(sp -> left);
	fprintf(list,"%04x  %-10s",sp -> valu,sp -> sname);
	if (col = ++col % SYMCOLS) fprintf(list,"    ");
	else {
	    fprintf(list,"\n");
	    if (sp -> right) check_page();
	}
	list_sym(sp -> right);
    }
    return;
}

static void check_page()
{
    if (pagelen && !--listleft) eject = TRUE;
    if (eject) {
	eject = FALSE;  listleft = pagelen;  fprintf(list,"\f");
	if (title[0]) { listleft -= 2;  fprintf(list,"%s\n\n",title); }
    }
    return;
}

/*  Buffer storage for hex output file.  This allows the hex file	*/
/*  output routines to do all of the required buffering and record	*/
/*  forming without the	main routine having to fool with it.		*/

static FILE *hex = NULL;
static unsigned cnt = 0;
static unsigned addr = 0;
static unsigned sum = 0;
static unsigned buf[HEXSIZE];

/*  Hex file open routine.  If a hex file is already open, a warning	*/
/*  occurs.  If the hex file doesn't open correctly, a fatal error	*/
/*  occurs.  If no hex file is open, all calls to hputc(), hseek(), and	*/
/*  hclose() have no effect.						*/

void hopen(nam)
char *nam;
{
    /* FILE *fopen();
    void fatal_error(), warning(); */

    if (hex) warning(TWOHEX);
    else if (!(hex = fopen(nam,"w"))) fatal_error(HEXOPEN);
    return;
}

/*  Hex file write routine.  The data byte is appended to the current	*/
/*  record.  If the record fills up, it gets written to disk.  If the	*/
/*  disk fills up, a fatal error occurs.				*/

void hputc(c)
unsigned c;
{
    /* void record(); */

    if (hex) {
	buf[cnt++] = c;
	if (cnt == HEXSIZE) record(0);
    }
    return;
}

/*  Hex file address set routine.  The specified address becomes the	*/
/*  load address of the next record.  If a record is currently open,	*/
/*  it gets written to disk.  If the disk fills up, a fatal error	*/
/*  occurs.								*/

void hseek(a)
unsigned a;
{
    /* void record(); */

    if (hex) {
	if (cnt) record(0);
	addr = a;
    }
    return;
}

/*  Hex file close routine.  Any open record is written to disk, the	*/
/*  EOF record is added, and file is closed.  If the disk fills up, a	*/
/*  fatal error occurs.							*/

void hclose()
{
    /* void fatal_error(), record(); */

    if (hex) {
	if (cnt) record(0);
	record(1);
	if (fclose(hex) == EOF) fatal_error(DSKFULL);
    }
    return;
}

static void srecord(typ)
unsigned typ;
/* produces Motorola S-record S1 data format data for type 0,
   S9 address record for type 1*/
{
    SCRATCH unsigned i;
    /* void fatal_error(), putb(); */

    if (typ==0) { /* data record */
       putc('S',hex); putc ('1',hex);  putb(cnt+3);
       putb(high(addr)); putb(low(addr));
       for (i = 0; i < cnt; ++i) putb(buf[i]);
       putb(low(-1-sum));  putc('\n',hex); /* hrj was (-sum) */

       addr += cnt;  cnt = 0;
       sum = 0; /* HRJ */
    }
    if (typ==1) { /* addr record */
       putc('S',hex); putc ('9',hex);  putb(3);
       putb(high(addr)); putb(low(addr));
       putb(low(-1-sum));  putc('\n',hex); /* hrj was (-sum) */

       addr += cnt;  cnt = 0;
       sum = 0; /* HRJ */
    }

    if (ferror(hex)) fatal_error(DSKFULL);
    return;
}

static void record(typ)
unsigned typ;
{
    SCRATCH unsigned i;
    /* void fatal_error(), putb(); */

    if (hformat=='M') {
		srecord(typ);
		return;
	}

    if (hformat!='I') warning("hexrecord not Intel or Motorola\0");

    putc(':',hex);  putb(cnt);  putb(high(addr));
    putb(low(addr));  putb(typ);
    for (i = 0; i < cnt; ++i) putb(buf[i]);
    putb(low(-0-sum));  putc('\n',hex); /* hrj was (-sum */

    addr += cnt;  cnt = 0;
    sum = 0; /* HRJ */

    if (ferror(hex)) fatal_error(DSKFULL);
    return;
}

static void putb(b)
unsigned b;
{
    static char digit[] = "0123456789ABCDEF";

    putc(digit[b >> 4],hex);
    putc(digit[b & 0x0f],hex);
    sum += b;  return;
}

/*  Error handler routine.  If the current error code is non-blank,	*/
/*  the error code is filled in and the	number of lines with errors	*/
/*  is adjusted.							*/

void error(code)
char code;
{
    if (errcode == ' ') { errcode = code;  ++errors; }
    return;
}

/*  Fatal error handler routine.  A message gets printed on the stderr	*/
/*  device, and the program bombs.					*/

void fatal_error(msg)
char *msg;
{
    printf("Fatal Error -- %s\n",msg);
    exit(-1);
}

/*  Non-fatal error handler routine.  A message gets printed on the	*/
/*  stderr device, and the routine returns.				*/

void warning(msg)
char *msg;
{
    printf("Warning -- %s\n",msg);
    return;
}
