/***********************************************************************
 *
 *		OPPARSE.C
 *		Operand Parser for 68000 Assembler
 *
 *    Function: opParse()
 *		Parses an operand of the 68000 assembly language
 *		instruction and attempts to recognize its addressing
 *		mode. The p argument points to the string to be
 *		evaluated, and the function returns a pointer to the
 *		first character beyond the end of the operand.
 *		The function returns a description of the operands that
 *		it parses in an opDescriptor structure. The fields of
 *		the operand descriptor are filled in as appropriate for
 *		the mode of the operand that was found:
 *
 *		 mode      returns the address mode (symbolic values
 *			   defined in ASM.H)
 *		 reg       returns the address or data register number 
 *		 data      returns the displacement or address or
 *			   immediate value
 *		 backRef   TRUE if data is the value of an expression
 *			   that contains only constants and backwards
 *			   references; FALSE otherwise.
 *		 index     returns the index register
 *			   (0-7 = D0-D7, 8-15 = A0-A7)
 *		 size      returns the size to be used for the index
 *			   register
 *
 *		The argument errorPtr is used to return an error code
 *		via the standard mechanism. 
 *
 *	 Usage:	char *opParse(p, d, errorPtr)
 *		char *p;
 *		opDescriptor *d;
 *		int *errorPtr;
 *
 *      Author: Paul McKee
 *		ECE492    North Carolina State University
 *
 *        Date: 10/10/86
 *
 *    Revision: 10/26/87
 *		Altered the immediate mode case to correctly flag
 *		constructs such as "#$1000(A5)" as syntax errors. 
 *
 ************************************************************************/


#include <stdio.h>
#include <ctype.h>
#include "asm.h"


extern char pass2;


#define isTerm(c)   (isspace(c) || (c == ',') || c == '\0')
#define isRegNum(c) ((c >= '0') && (c <= '7'))

char *opParse(p, d, errorPtr)
char *p;
opDescriptor *d;
int *errorPtr;
{

	/* Check for immediate mode */
	if (p[0] == '#') {
		p = eval(++p, &(d->data), &(d->backRef), errorPtr);
		/* If expression evaluates OK, then return */
		if (*errorPtr < SEVERE) {
			if (isTerm(*p)) {
				d->mode = Immediate;
				return p;
				}
			else {
				NEWERROR(*errorPtr, SYNTAX);
				return NULL;
				}
			}
		else
			return NULL;
		}
	/* Check for address or data register direct */
	if (isRegNum(p[1]) && isTerm(p[2])) {
		if (p[0] == 'D') {
			d->mode = DnDirect;
			d->reg = p[1] - '0';
			return (p + 2);
			}
		else if (p[0] == 'A') {
			d->mode = AnDirect;
			d->reg = p[1] - '0';
			return (p + 2);
			}
		}
	/* Check for Stack Pointer (i.e., A7) direct */
	if (p[0] == 'S' && p[1] == 'P' && isTerm(p[2])) {
		d->mode = AnDirect;
		d->reg = 7;
		return (p + 2);
		}
	/* Check for address register indirect */
	if (p[0] == '(' && 
	    ((p[1] == 'A' && isRegNum(p[2])) || (p[1] == 'S' && p[2] == 'P'))) {

		if (p[1] == 'S')
			d->reg = 7;
		else 
			d->reg = p[2] - '0';
		if (p[3] == ')') {
			/* Check for plain address register indirect */
			if (isTerm(p[4])) {
				d->mode = AnInd;
				return p+4;
				}
			/* Check for postincrement */
			else if (p[4] == '+') {
				d->mode = AnIndPost;
				return p+5;
				}
			}
		/* Check for address register indirect with index */
		else if (p[3] == ',' && (p[4] == 'A' || p[4] == 'D')
			 && isRegNum(p[5])) {
			d->mode = AnIndIndex;
			/* Displacement is zero */
			d->data = 0;
			d->backRef = TRUE;
			d->index = p[5] - '0';
			if (p[4] == 'A')
				d->index += 8;
			if (p[6] == '.')
				/* Determine size of index register */
				if (p[7] == 'W') {
					d->size = WORD;
					return p+9;
					}
				else if (p[7] == 'L') {
					d->size = LONG;
					return p+9;
					}
				else {
					NEWERROR(*errorPtr, SYNTAX);
					return NULL;
					}
			else if (p[6] == ')') {
				/* Default index register size is Word */
				d->size = WORD;
				return p+7;
				}
			else {
				NEWERROR(*errorPtr, SYNTAX);
				return NULL;
				}
			}
		}
	/* Check for address register indirect with predecrement */
	if (p[0] == '-' && p[1] == '(' && p[4] == ')' &&
	    ((p[2] == 'A' && isRegNum(p[3])) || (p[2] == 'S' && p[3] == 'P'))) {

		if (p[2] == 'S')
			d->reg = 7;
		else 
			d->reg = p[3] - '0';
		d->mode = AnIndPre;
		return p+5;
		}
	/* Check for PC relative */
	if (p[0] == '(' && p[1] == 'P' && p[2] == 'C') {
		/* Displacement is zero */
		d->data = 0;
		d->backRef = TRUE;
		/* Check for plain PC relative */
		if (p[3] == ')') {
			d->mode = PCDisp;
			return p+4;
			}
		/* Check for PC relative with index */
		else if (p[3] == ',' && (p[4] == 'A' || p[4] == 'D')
			 && isRegNum(p[5])) {
			d->mode = PCIndex;
			d->index = p[5] - '0';
			if (p[4] == 'A')
				d->index += 8;
			if (p[6] == '.')
				/* Determine size of index register */
				if (p[7] == 'W') {
					d->size = WORD;
					return p+9;
					}
				else if (p[7] == 'L') {
					d->size = LONG;
					return p+9;
					}
				else {
					NEWERROR(*errorPtr, SYNTAX);
					return NULL;
					}
			else if (p[6] == ')') {
				/* Default size of index register is Word */
				d->size = WORD;
				return p+7;
				}
			else {
				NEWERROR(*errorPtr, SYNTAX);
				return NULL;
				}
			}
		}

	/* Check for Status Register direct */
	if (p[0] == 'S' && p[1] == 'R' && isTerm(p[2])) {
		d->mode = SRDirect;
		return p+2;
		}	
	/* Check for Condition Code Register direct */
	if (p[0] == 'C' && p[1] == 'C' && p[2] == 'R' && isTerm(p[3])) {
		d->mode = CCRDirect;
		return p+3;
		}
	/* Check for User Stack Pointer direct */
	if (p[0] == 'U' && p[1] == 'S' && p[2] == 'P' && isTerm(p[3])) {
		d->mode = USPDirect;
		return p+3;
		}	
	/* Check for Source Function Code register direct (68010) */
	if (p[0] == 'S' && p[1] == 'F' && p[2] == 'C' && isTerm(p[3])) {
		d->mode = SFCDirect;
		return p+3;
		}	
	/* Check for Destination Function Code register direct (68010) */
	if (p[0] == 'D' && p[1] == 'F' && p[2] == 'C' && isTerm(p[3])) {
		d->mode = DFCDirect;
		return p+3;
		}	
	/* Check for Vector Base Register direct (68010) */
	if (p[0] == 'V' && p[1] == 'B' && p[2] == 'R' && isTerm(p[3])) {
		d->mode = VBRDirect;
		return p+3;
		}	

	/* All other addressing modes start with a constant expression */
	p = eval(p, &(d->data), &(d->backRef), errorPtr);
	if (*errorPtr < SEVERE) {
		/* Check for absolute */
		if (isTerm(p[0])) {
			/* Determine size of absolute address (must be long if
			   the symbol isn't defined or if the value is too big */
			if (!d->backRef || d->data > 32767 || d->data < -32768)
				d->mode = AbsLong;
			else
				d->mode = AbsShort;
			return p;
			}
		/* Check for address register indirect with displacement */
		if (p[0] == '(' && 
		    ((p[1] == 'A' && isRegNum(p[2])) || (p[1] == 'S' && p[2] == 'P'))) {
			if (p[1] == 'S')
				d->reg = 7;
			else 
				d->reg = p[2] - '0';
			/* Check for plain address register indirect with displacement */
			if (p[3] == ')') {
				d->mode = AnIndDisp;
				return p+4;
				}
			/* Check for address register indirect with index */
			else if (p[3] == ',' && (p[4] == 'A' || p[4] == 'D')
				 && isRegNum(p[5])) {
				d->mode = AnIndIndex;
				d->index = p[5] - '0';
				if (p[4] == 'A')
					d->index += 8;
				if (p[6] == '.')
					/* Determine size of index register */
					if (p[7] == 'W') {
						d->size = WORD;
						return p+9;
						}
					else if (p[7] == 'L') {
						d->size = LONG;
						return p+9;
						}
					else {
						NEWERROR(*errorPtr, SYNTAX);
						return NULL;
						}
				else if (p[6] == ')') {
					/* Default size of index register is Word */
					d->size = WORD;
					return p+7;
					}
				else {
					NEWERROR(*errorPtr, SYNTAX);
					return NULL;
					}
				}
			}
		
		/* Check for PC relative */
		if (p[0] == '(' && p[1] == 'P' && p[2] == 'C') {
			/* Check for plain PC relative */
			if (p[3] == ')') {
				d->mode = PCDisp;
				return p+4;
				}
			/* Check for PC relative with index */
			else if (p[3] == ',' && (p[4] == 'A' || p[4] == 'D')
				 && isRegNum(p[5])) {
				d->mode = PCIndex;
				d->index = p[5] - '0';
				if (p[4] == 'A')
					d->index += 8;
				if (p[6] == '.')
					/* Determine size of index register */
					if (p[7] == 'W') {
						d->size = WORD;
						return p+9;
						}
					else if (p[7] == 'L') {
						d->size = LONG;
						return p+9;
						}
					else {
						NEWERROR(*errorPtr, SYNTAX);
						return NULL;
						}
				else if (p[6] == ')') {
					/* Default size of index register is Word */
					d->size = WORD;
					return p+7;
					}
				else {
					NEWERROR(*errorPtr, SYNTAX);
					return NULL;
					}
				}
			}
		}

	/* If the operand doesn't match any pattern, return an error status */
	NEWERROR(*errorPtr, SYNTAX);
	return NULL;
}


