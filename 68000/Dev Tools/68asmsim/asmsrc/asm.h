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
 ************************************************************************/


/* include system header files for prototype checking */
#include <stdio.h>
#include <string.h>
#include <process.h>
#include <stdlib.h>
#include <malloc.h>


/* Status values */

/* These status values are 12 bits long with
   a severity code in the upper 4 bits */

#define OK 		0x00

/* Severe errors */
#define SEVERE		0x400
#define SYNTAX		0x401
#define INV_OPCODE	0x402
#define INV_ADDR_MODE	0x403
#define LABEL_REQUIRED	0x404
#define PHASE_ERROR	0x405

/* Errors */
#define ERROR		0x300
#define UNDEFINED	0x301
#define DIV_BY_ZERO	0x302
#define MULTIPLE_DEFS	0x303
#define REG_MULT_DEFS	0x304
#define REG_LIST_UNDEF	0x305
#define INV_FORWARD_REF	0x306
#define INV_LENGTH	0x307

/* Minor errors */
#define MINOR		0x200
#define INV_SIZE_CODE	0x201
#define INV_QUICK_CONST	0x202
#define INV_VECTOR_NUM	0x203
#define INV_BRANCH_DISP 0x204
#define INV_DISP	0x205
#define INV_ABS_ADDRESS	0x206
#define INV_8_BIT_DATA	0x207
#define INV_16_BIT_DATA	0x208
#define ODD_ADDRESS	0x209
#define NOT_REG_LIST	0x20A
#define REG_LIST_SPEC	0x20B
#define INV_SHIFT_COUNT	0x20C

/* Warnings */
#define WARNING		0x100
#define ASCII_TOO_BIG	0x101
#define NUMBER_TOO_BIG	0x102
#define INCOMPLETE	0x103

#define SEVERITY	0xF00

/* The NEWERROR macros updates the error variable var only if the
   new error code is more severe than all previous errors.  Throughout
   ASM this is the standard means of reporting errors. */

#define NEWERROR(var, code)	if ((code & SEVERITY) > var) var = code


/* Symbol table definitions */

/* Significant length of a symbol */
#define SIGCHARS 8


/* Structure for operand descriptors */
typedef struct {
	long int mode;	/* Mode number (see below) */
	long int data;	/* Immediate value, displacement, or absolute address */

	char reg;	/* Principal register number (0-7) */
	char index;	/* Index register number (0-7 = D0-D7, 8-15 = A0-A7) */
	char size;	/* Size of index register (WORD or LONG, see below) */
	char backRef;	/* True if data field is known on first pass */
	} opDescriptor;


/* Structure for a symbol table entry */
typedef struct symbolEntry {
	long int value;			/* 32-bit value of the symbol */
	struct symbolEntry *next;	/* Pointer to next symbol in linked list */
	char flags;			/* Flags (see below) */
	char name[SIGCHARS+1];		/* Name */
	} symbolDef;

/* Flag values for the "flags" field of a symbol */

#define BACKREF		0x01	/* Set when the symbol is defined on the 2nd pass */
#define REDEFINABLE	0x02	/* Set for symbols defined by the SET directive */
#define REG_LIST_SYM	0x04	/* Set for symbols defined by the REG directive */


/* Instruction table definitions */

/* Structure to describe one "flavor" of an instruction */

typedef struct {
	long int source,		/* Bit masks for the legal source...	*/
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
	char parseFlag;		/* Should assemble() parse the operands? */
	int (*exec)(int, char *, char *, int *);
			/* Routine to be called if parseFlag is FALSE */
	} instruction;


/* Addressing mode codes/bitmasks */

#define DnDirect			0x00001
#define AnDirect			0x00002
#define AnInd				0x00004
#define AnIndPost			0x00008
#define AnIndPre			0x00010
#define AnIndDisp			0x00020
#define AnIndIndex		0x00040
#define AbsShort			0x00080
#define AbsLong			0x00100
#define PCDisp				0x00200
#define PCIndex			0x00400
#define Immediate			0x00800
#define SRDirect			0x01000
#define CCRDirect			0x02000
#define USPDirect			0x04000
#define SFCDirect			0x08000
#define DFCDirect			0x10000
#define VBRDirect			0x20000


/* Register and operation size codes/bitmasks */

#define BYTE	((int) 1)
#define WORD	((int) 2)
#define LONG	((int) 4)
#define SHORT	((int) 8)


/* added for PC port -- 7/8/1988 */

#define	TRUE	-1
#define	FALSE	0


/* function return codes */

#define	NORMAL	0



/* function prototype definitions */
#include "proto.h"


