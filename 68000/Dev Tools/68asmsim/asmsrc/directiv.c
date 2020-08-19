/***********************************************************************
 *
 *		DIRECTIVE.C
 *		Directive Routines for 68000 Assembler
 *
 * Description: The functions in this file carry out the functions of
 *		assembler directives. All the functions share the same
 *		calling sequence: 
 *
 *		    general_name(size, label, op, errorPtr)
 *		    int size;
 *		    char *label, *op;
 *		    int *errorPtr;
 *
 *		The size argument contains the size code that was
 *		specified with the instruction (using the definitions
 *		in ASM.H) or 0 if no size code was specified. The label
 *		argument is a pointer to a string (which may be empty)
 *		containing the label from the line containing the
 *		directive. The op argument is a pointer to the first
 *		non-blank character after the name of the directive,
 *		i.e., the operand(s) of the directive. The errorPtr
 *		argument is used to return a status via the standard
 *		mechanism. 
 *
 *      Author: Paul McKee
 *		ECE492    North Carolina State University
 *
 *        Date:	12/13/86
 *
 ************************************************************************/


#include <stdio.h>
#include <ctype.h>
#include "asm.h"

extern long	loc;
extern char pass2, endFlag, listFlag;

extern char *listPtr;	/* Pointer to buffer where listing line is assembled
			   (Used to put =XXXXXXXX in the listing for EQU's and SET's */


/***********************************************************************
 *
 *	Function org implements the ORG directive.
 *
 ***********************************************************************/

int	org(size, label, op, errorPtr)
int size;
char *label, *op;
int *errorPtr;
{
long	newLoc;
char backRef;

	if (size)
		NEWERROR(*errorPtr, INV_SIZE_CODE);
	if (!*op) {
		NEWERROR(*errorPtr, SYNTAX);
		return NORMAL;
		}
	op = eval(op, &newLoc, &backRef, errorPtr);
	if (*errorPtr < SEVERE && !backRef) {
		NEWERROR(*errorPtr, INV_FORWARD_REF);
		}
	else if (*errorPtr < ERROR) {
		if (isspace(*op) || !*op) {
			/* Check for an odd value, adjust to one higher */
			if (newLoc & 1) {
				NEWERROR(*errorPtr, ODD_ADDRESS);
				newLoc++;
				}
			loc = newLoc;
			/* Define the label attached to this directive, if any */
			if (*label)
				define(label, loc, pass2, errorPtr);
			/* Show new location counter on listing */
			listLoc();
			}
		else
			NEWERROR(*errorPtr, SYNTAX);
		}

	return NORMAL;

}


/***********************************************************************
 *
 *	Function end implements the END directive.
 *
 ***********************************************************************/

int	funct_end(size, label, op, errorPtr)
int size;
char *label, *op;
int *errorPtr;
{
	if (size)
		NEWERROR(*errorPtr, INV_SIZE_CODE);
	endFlag = TRUE;

	return NORMAL;

}


/***********************************************************************
 *
 *	Function equ implements the EQU directive.
 *
 ***********************************************************************/

int	equ(size, label, op, errorPtr)
int size;
char *label, *op;
int *errorPtr;
{
long	value;
char backRef;

	if (size)
		NEWERROR(*errorPtr, INV_SIZE_CODE);
	if (!*op) {
		NEWERROR(*errorPtr, SYNTAX);
		return NORMAL;
		}
	op = eval(op, &value, &backRef, errorPtr);
	if (*errorPtr < SEVERE && !backRef) {
		NEWERROR(*errorPtr, INV_FORWARD_REF);
		}
	else if (*errorPtr < ERROR)
		if (isspace(*op) || !*op)
			if (!*label) {
				NEWERROR(*errorPtr, LABEL_REQUIRED);
				}
			else {		
				define(label, value, pass2, errorPtr);
				if (pass2 && listFlag && *errorPtr < MINOR) {
					sprintf(listPtr, "=%08lX ", value);
					listPtr += 10;
					}
				}
		else
			NEWERROR(*errorPtr, SYNTAX);

	return NORMAL;

}


/***********************************************************************
 *
 *	Function set implements the SET directive.
 *
 ***********************************************************************/

int	set(size, label, op, errorPtr)
int size;
char *label, *op;
int *errorPtr;
{
long	value;
int	error;
char backRef;
symbolDef *symbol;

	if (size)
		NEWERROR(*errorPtr, INV_SIZE_CODE);
	if (!*op) {
		NEWERROR(*errorPtr, SYNTAX);
		return NORMAL;
		}
	error = OK;
	op = eval(op, &value, &backRef, errorPtr);
	if (*errorPtr < SEVERE && !backRef) {
		NEWERROR(*errorPtr, INV_FORWARD_REF);
		}
	if (*errorPtr > ERROR)
		if (isspace(*op) || !*op)
			if (!*label) {
				NEWERROR(*errorPtr, LABEL_REQUIRED);
				}
			else {		
				error = OK;
				symbol = define(label, value, pass2, &error);
				if (error == MULTIPLE_DEFS)
					if (symbol->flags & REDEFINABLE)
						symbol->value = value;
					else {
						NEWERROR(*errorPtr, MULTIPLE_DEFS);
						return NORMAL;
						}
				symbol->flags |= REDEFINABLE;
				if (pass2 & listFlag) {
					sprintf(listPtr, "=%08lX ", value);
					listPtr += 10;
					}
				}
		else
			NEWERROR(*errorPtr, SYNTAX);

	return NORMAL;

}


/***********************************************************************
 *
 *	Function dc implements the DC directive.
 *
 ***********************************************************************/

int	dc(size, label, op, errorPtr)
int size;
char *label, *op;
int *errorPtr;
{
long	outVal;
char backRef;
char string[260], *p;

	if (size == SHORT) {
		NEWERROR(*errorPtr, INV_SIZE_CODE);
		size = WORD;
		}
	else if (!size)
		size = WORD;
	/* Move location counter to a word boundary and fix the listing if doing

	   DC.W or DC.L (but not if doing DC.B, so DC.B's can be contiguous) */
	if ((size & (WORD | LONG)) && (loc & 1)) {
		loc++;
		listLoc();
		}
	/* Define the label attached to this directive, if any */
	if (*label)
		define(label, loc, pass2, errorPtr);
	/* Check for the presence of the operand list */
	if (!*op) {
		NEWERROR(*errorPtr, SYNTAX);
		return NORMAL;
		}
	do {
		if (*op == '\'') {
			op = collect(++op, string);
			if (!isspace(*op) && *op != ',') {
				NEWERROR(*errorPtr, SYNTAX);
				return NORMAL;
				}
			p = string;
			while (*p) {
				outVal = *p++;
				if (size > BYTE)
					outVal = (outVal << 8) + *p++;
				if (size > WORD) {
					outVal = (outVal << 16) + (*p++ << 8);
					outVal += *p++;
					}
				if (pass2)
					output(outVal, size);
				loc += size;
				}
			}
		else {
			op = eval(op, &outVal, &backRef, errorPtr);
			if (*errorPtr > SEVERE)
				return NORMAL;
			if (!isspace(*op) && *op != ',') {
				NEWERROR(*errorPtr, SYNTAX);
				return NORMAL;
				}
			if (pass2)
				output(outVal, size);
			loc += size;
			if (size == BYTE && (outVal < -128 || outVal > 255)) {
				NEWERROR(*errorPtr, INV_8_BIT_DATA);
				}
			else if (size == WORD && (outVal < -32768 || outVal > 65535))
				NEWERROR(*errorPtr, INV_16_BIT_DATA);
			}
	} while (*op++ == ',');
	--op;
	if (!isspace(*op) && *op)
		NEWERROR(*errorPtr, SYNTAX);

	return NORMAL;

}

/**********************************************************************
 *
 *	Function collect parses strings for dc. Each output string
 *	is padded with four nulls at the end.
 *
 **********************************************************************/

char *collect(s, d)
char *s, *d;
{
	while (*s) {
		if (*s == '\'')
			if (*(s+1) == '\'') {
				*d++ = *s;
				s += 2;
				}
			else {
				*d++ = '\0';
				*d++ = '\0';
				*d++ = '\0';
				*d++ = '\0';
				return ++s;
				}
		else
			*d++ = *s++;
		}
	return s;
}
		

/***********************************************************************
 *
 *	Function dcb implements the DCB directive.
 *
 ***********************************************************************/

int	dcb(size, label, op, errorPtr)
int size;
char *label, *op;
int *errorPtr;
{
long	blockSize, blockVal, i;
char backRef;

	if (size == SHORT) {
		NEWERROR(*errorPtr, INV_SIZE_CODE);
		size = WORD;
		}
	else if (!size)
		size = WORD;
	/* Move location counter to a word boundary and fix the listing if doing

	   DCB.W or DCB.L (but not if doing DCB.B, so DCB.B's can be contiguous)
 */
	if ((size & (WORD | LONG)) && (loc & 1)) {
		loc++;
		listLoc();
		}
	/* Define the label attached to this directive, if any */
	if (*label)
		define(label, loc, pass2, errorPtr);
	/* Evaluate the size of the block (in bytes, words, or longwords) */
	op = eval(op, &blockSize, &backRef, errorPtr);
	if (*errorPtr < SEVERE && !backRef) {
		NEWERROR(*errorPtr, INV_FORWARD_REF);
		return NORMAL;
		}
	if (*errorPtr > SEVERE)
		return NORMAL;
	if (*op != ',') {
		NEWERROR(*errorPtr, SYNTAX);
		return NORMAL;
		}
	if (blockSize < 0) {
		NEWERROR(*errorPtr, INV_LENGTH);
		return NORMAL;
		}
	/* Evaluate the data to put in block */
	op = eval(++op, &blockVal, &backRef, errorPtr);
	if (*errorPtr < SEVERE) {
		if (!isspace(*op) && *op) {
			NEWERROR(*errorPtr, SYNTAX);
			return NORMAL;
			}
		/* On pass 2, output the block of values directly
		   to the object file (without putting them in the listing) */
		if (pass2)
			for (i = 0; i < blockSize; i++) {
				outputObj(loc, blockVal, size);
				loc += size;
				}
		else
			loc += blockSize * size;
		}

	return NORMAL;

}


/***********************************************************************
 *
 *	Function ds implements the DS directive.
 *
 ***********************************************************************/

int	ds(size, label, op, errorPtr)
int	size;
char	*label, *op;
int	*errorPtr;
{
long	blockSize;
char	backRef;

	if (size == SHORT) {
		NEWERROR(*errorPtr, INV_SIZE_CODE);
		size = WORD;
		}
	else if (!size)
		size = WORD;
	/* Move location counter to a word boundary and fix the listing if doing
	   DS.W or DS.L (but not if doing DS.B, so DS.B's can be contiguous) */
	if ((size & (WORD | LONG)) && (loc & 1)) {
		loc++;
		listLoc();
		}
	/* Define the label attached to this directive, if any */
	if (*label)
		define(label, loc, pass2, errorPtr);
	/* Evaluate the size of the block (in bytes, words, or longwords) */
	op = eval(op, &blockSize, &backRef, errorPtr);
	if (*errorPtr < SEVERE && !backRef) {
		NEWERROR(*errorPtr, INV_FORWARD_REF);
		return NORMAL;
		}
	if (*errorPtr > SEVERE)
		return NORMAL;
	if (!isspace(*op) && *op) {
		NEWERROR(*errorPtr, SYNTAX);
		return NORMAL;
		}
	if (blockSize < 0) {
		NEWERROR(*errorPtr, INV_LENGTH);
		return NORMAL;
		}
	loc += blockSize * size;

	return NORMAL;

}

