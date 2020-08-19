/***********************************************************************
 *
 *		INSTLOOKUP.C
 *		Instruction Table Lookup Routine for 68000 Assembler
 *
 *    Function: instLookup()
 *		Parses an instruction and looks it up in the instruction
 *		table. The input to the function is a pointer to the
 *		instruction on a line of assembly code. The routine 
 *		scans the instruction and notes the size code if 
 *		present. It then (binary) searches the instruction 
 *		table for the specified opcode. If it finds the opcode, 
 *		it returns a pointer to the instruction table entry for 
 *		that instruction (via the instPtrPtr argument) as well 
 *		as the size code or 0 if no size was specified (via the 
 *		sizePtr argument). If the opcode is not in the 
 *		instruction table, then the routine returns INV_OPCODE. 
 *		The routine returns an error value via the standard
 *		mechanism. 
 *
 *	 Usage:	char *instLookup(p, instPtrPtr, sizePtr, errorPtr)
 *		char *p;
 *		instruction *(*instPtrPtr);
 *		char *sizePtr;
 *		int *errorPtr;
 *
 *	Errors: SYNTAX
 *		INV_OPCODE
 *		INV_SIZE_CODE
 *
 *      Author: Paul McKee
 *		ECE492    North Carolina State University
 *
 *        Date:	9/24/86
 *
 ************************************************************************/


#include <stdio.h>
#include <ctype.h>
#include "asm.h"


extern instruction instTable[];
extern int tableSize;


char *instLookup(p, instPtrPtr, sizePtr, errorPtr)
char *p;
instruction *(*instPtrPtr);
char *sizePtr;
int *errorPtr;
{
char opcode[8];
int i, hi, lo, mid, cmp;

/*	printf("InstLookup: Input string is \"%s\"\n", p); */
	i = 0;
	do {
		if (i < 7)
			opcode[i++] = *p;
		p++;
	} while (isalpha(*p));
	opcode[i] = '\0';
	if (*p == '.')
		if (isspace(p[2]) || !p[2]) {
			if (p[1] == 'B')
				*sizePtr = BYTE;
			else if (p[1] == 'W')
				*sizePtr = WORD;
			else if (p[1] == 'L')
				*sizePtr = LONG;
			else if (p[1] == 'S')
				*sizePtr = SHORT;
			else {
				*sizePtr = 0;
				NEWERROR(*errorPtr, INV_SIZE_CODE);
				}
			p += 2;
			}
		else {
			NEWERROR(*errorPtr, SYNTAX);
			return NULL;
			}
	else if (!isspace(*p) && *p) {
		NEWERROR(*errorPtr, SYNTAX);
		return NULL;
		}
	else
		*sizePtr = 0;

	lo = 0;
	hi = tableSize - 1;
	do {
		mid = (hi + lo) / 2;
		cmp = strcmp(opcode, instTable[mid].mnemonic);
		if (cmp > 0)
			lo = mid + 1;
		else if (cmp < 0)
			hi = mid - 1;
	} while (cmp && (hi >= lo));
	if (!cmp) {
		*instPtrPtr = &instTable[mid];
		return p;
		}
	else {
		NEWERROR(*errorPtr, INV_OPCODE);
		return NULL;
		}

	return NORMAL;

}

