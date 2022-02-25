/***********************************************************************
 *
 *		ASM.H
 *		Global Definitions for 68000 Assembler
 *
 *      Author: Paul McKee
 *		ECE492    North Carolina State University
 *
 *        Date:	12/13/86
 *
 *    Modified: Charles Kelly
 *              Monroe County Community College
 *              http://www.monroeccc.edu/ckelly
 *
 ************************************************************************/
#ifndef asmH
#define asmH


/* include system header files for prototype checking */
#include <stdio.h>
#include <string.h>
#include <system.hpp>
#include <process.h>
#include <stdlib.h>
#include <malloc.h>
#include <vcl.h>

/* Define a couple of useful tests */

#define isTerm(c)   (c == ',' || c == '/' || c == '-' || isspace(c) || !c || c == '{')
#define isRegNum(c) ((c >= '0') && (c <= '7'))

const AnsiString VERSION =                     "5.16.01";  // don't forget to change version.txt on easy68k.com
const char TITLE[] = "EASy68K Editor/Assembler v5.16.01";

/* Status values */

/* These status values are 12 bits long with
   a severity code in the upper 4 bits */

const int OK                    = 0x00;

/* Severe errors */
const int SEVERE	            = 0x400;
const int SYNTAX	            = 0x401;
const int INV_OPCODE	        = 0x402;
const int INV_ADDR_MODE	        = 0x403;
const int LABEL_REQUIRED	    = 0x404;
const int NO_ENDM               = 0x405;
const int TOO_MANY_ARGS         = 0x406;
const int INVALID_ARG           = 0x407;
const int COMMA_EXPECTED        = 0x408;
const int PHASE_ERROR	        = 0x409;
const int FILE_ERROR            = 0x40A;
const int MACRO_NEST            = 0x40B;
const int NO_IF                 = 0x40C;
const int NO_WHILE              = 0x40D;
const int NO_REPEAT             = 0x40E;
const int NO_FOR                = 0x40F;
const int ENDI_EXPECTED         = 0x410;
const int ENDW_EXPECTED         = 0x411;
const int ENDF_EXPECTED         = 0x412;
const int REPEAT_EXPECTED       = 0x413;
const int LABEL_ERROR           = 0x414;
const int NO_DBLOOP             = 0x415;
const int DBLOOP_EXPECTED       = 0x416;
const int BAD_BITFIELD          = 0x417;
const int ILLEGAL_SYMBOL        = 0x418;

const int EXCEPTION             = 0x999;


/* Errors */
const int ERRORN	            = 0x300;
const int UNDEFINED	            = 0x301;
const int DIV_BY_ZERO	        = 0x302;
const int MULTIPLE_DEFS	        = 0x303;
const int REG_MULT_DEFS	        = 0x304;
const int REG_LIST_UNDEF	    = 0x305;
const int INV_FORWARD_REF	    = 0x306;
const int INV_LENGTH	        = 0x307;

/* Minor errors */
const int MINOR		            = 0x200;
const int INV_SIZE_CODE	        = 0x201;
const int INV_QUICK_CONST	    = 0x202;
const int INV_MOVE_QUICK_CONST  = 0x203;
const int INV_VECTOR_NUM	    = 0x204;
const int INV_BRANCH_DISP       = 0x205;
const int INV_DISP	            = 0x206;
const int INV_ABS_ADDRESS	    = 0x207;
const int INV_8_BIT_DATA	    = 0x208;
const int INV_16_BIT_DATA	    = 0x209;
const int NOT_REG_LIST	        = 0x20A;
const int REG_LIST_SPEC	        = 0x20B;
const int INV_SHIFT_COUNT	    = 0x20C;
const int INV_OPERATOR          = 0x20D;
const int FAIL_ERROR            = 0x20E;        // user defined

/* Warnings */
const int WARNING		        = 0x100;
const int ASCII_TOO_BIG	        = 0x101;
const int NUMBER_TOO_BIG	    = 0x102;
const int INCOMPLETE	        = 0x103;
const int FORCING_SHORT         = 0x104;
const int ODD_ADDRESS	        = 0x105;
const int END_MISSING           = 0x106;
const int ADDRESS_MISSING       = 0x107;
const int THEN_EXPECTED         = 0x108;
const int DO_EXPECTED           = 0x109;
const int FORWARD_REF           = 0x10A;
const int LABEL_TOO_LONG        = 0x10B;


const int SEVERITY	            = 0xF00;

/* The NEWERROR macros updates the error variable var only if the
   new error code is more severe than all previous errors.  Throughout
   ASM this is the standard means of reporting errors. */

//#define NEWERROR(var, code)	if ((code & SEVERITY) > var) var = code
// ck: the previous line was causing errors when placed inside if-else
#define NEWERROR(var, code)      var = ((code & SEVERITY) > var) ? code : var


/* Symbol table definitions */

const int SIGCHARS = 33;        // significant characters in symbol
const int MAX_ARGS = 36;        // maximum number of macro arguments
const int ARG_SIZE = 256;       // maximum size of each argument

/* Structure for operand descriptors */
struct opDescriptor
{
  int  mode;	// Mode number (see below)
  int  data;	// IMMEDIATE value, displacement, or absolute address
  int  field;   // for bitField instructions
  char reg;	// Principal register number (0-7)
  char index;	// Index register number (0-7 = D0-D7, 8-15 = A0-A7)
  char size;	// Size of index register (WORD or LONG, see below)
                // or forced size of IMMEDIATE instruction
                // BYTE_SIZE, WORD_SIZE, LONG_SIZE
                // Also used to prevent MOVEQ, ADDQ & SUBQ optimizations (see OPPARSE.CPP)
  bool backRef;	// True if data field is known on first pass
};


/* Structure for a symbol table entry */
typedef struct symbolEntry {
	int value;			/* 32-bit value of the symbol */
	struct symbolEntry *next;	/* Pointer to next symbol in linked list */
	char flags;			/* Flags (see below) */
	char name[SIGCHARS+1];		/* Name */
	} symbolDef;

/* Flag values for the "flags" field of a symbol */
const int BACKREF	    = 0x01;	/* Set when the symbol is defined on the 2nd pass */
const int REDEFINABLE	= 0x02;	/* Set for symbols defined by the SET directive */
const int REG_LIST_SYM	= 0x04;	/* Set for symbols defined by the REG directive */
const int MACRO_SYM     = 0x08;    // Set for macros
const int DS_SYM        = 0x10;    // Set for labels defined with DS directive

/* Instruction table definitions */

/* Structure to describe one "flavor" of an instruction */

typedef struct {
	int source,		/* Bit masks for the legal source...	*/
	    dest;		/*  and destination addressing modes	*/
	char sizes;		/* Bit mask for the legal sizes */
	int (*exec)(int, int, opDescriptor *, opDescriptor *, int *);
                                /* Pointer to routine to build the instruction */
	short int bytemask,	/* Skeleton instruction masks for byte size...  */
		  wordmask,	/*  word size, ...			        */
		  longmask;	/*  and long sizes of the instruction	        */
	} flavor;


/* Structure for the instruction table */
typedef struct {
	char *mnemonic;		/* Mnemonic */
	flavor *flavorPtr;	/* Pointer to flavor list */
	char flavorCount;	/* Number of flavors in flavor list */
	bool parseFlag;		/* Should assemble() parse the operands? */
	int (*exec)(int, char *, char *, int *);
			/* Routine to be called if parseFlag is FALSE */
	} instruction;


/* Addressing mode codes/bitmasks */

const int DnDirect		= 0x00001;
const int AnDirect		= 0x00002;
const int AnInd			= 0x00004;
const int AnIndPost		= 0x00008;
const int AnIndPre		= 0x00010;
const int AnIndDisp		= 0x00020;
const int AnIndIndex	= 0x00040;
const int AbsShort		= 0x00080;
const int AbsLong		= 0x00100;
const int PCDisp		= 0x00200;
const int PCIndex		= 0x00400;
const int IMMEDIATE		= 0x00800;
const int SRDirect		= 0x01000;
const int CCRDirect		= 0x02000;
const int USPDirect		= 0x04000;
const int SFCDirect		= 0x08000;
const int DFCDirect		= 0x10000;
const int VBRDirect		= 0x20000;


/* Register and operation size codes/bitmasks */

//const int BYTE	((int) 1)
//const int WORD	((int) 2)
//const int LONG	((int) 4)
//const int SHORT	((int) 8)

const int BYTE_SIZE  = 1;
const int WORD_SIZE  = 2;
const int LONG_SIZE  = 4;
const int SHORT_SIZE = 8;

// upper limit of 68000 memory
const int MEM_SIZE = 0x00FFFFFF;

// function return codes
const int NORMAL = 0;
const int MILD_ERROR = 1;
const int CRITICAL = 2;

// tab types
enum tabTypes{ Assembly, Fixed };

const int TAB1 = 12;          // tab positions for smart tabs (in characters)
const int TAB2 = 20;
const int TAB3 = 44;

const int MACRO_NEST_LIMIT = 256;  // nesting level limit

// syntax highlight
typedef struct
{
  TColor color;
  bool   bold;
  bool   italic;
  bool   underline;
} FontStyle;

const TColor DEFAULT_CODE_COLOR = clBlack;
const TColor DEFAULT_UNKNOWN_COLOR = clOlive;
const TColor DEFAULT_DIRECTIVE_COLOR = clGreen;
const TColor DEFAULT_COMMENT_COLOR = clBlue;
const TColor DEFAULT_LABEL_COLOR = clPurple;
const TColor DEFAULT_STRUCTURE_COLOR = clMaroon;
const TColor DEFAULT_ERROR_COLOR = clRed;
const TColor DEFAULT_TEXT_COLOR = clTeal;
const TColor DEFAULT_BACK_COLOR = clWhite;

const char NEW_PAGE_MARKER[] = "<------------------------------ PAGE ------------------------------>";

// function prototype definitions
#include "proto.h"

#endif
