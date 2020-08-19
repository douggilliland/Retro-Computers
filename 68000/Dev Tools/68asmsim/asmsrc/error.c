/***********************************************************************
 *
 *		ERROR.C
 *		Error message printer for 68000 Assembler
 *
 *    Function: printError()
 *		Prints an appropriate message to the specified output
 *		file according to the error code supplied. If the
 *		errorCode is OK, no message is printed; otherwise an
 *		WARNING or ERROR message is produced. The line number
 *		will be included in the message unless lineNum = -1.
 *
 *	 Usage:	printError(outFile, errorCode, lineNum)
 *		FILE *outFile;
 *		int errorCode, lineNum;
 *
 *      Author: Paul McKee
 *		ECE492    North Carolina State University
 *
 *        Date:	12/12/86
 *
 ************************************************************************/


#include <stdio.h>
#include "asm.h"

int	printError(outFile, errorCode, lineNum)
FILE *outFile;
int errorCode, lineNum;
{
char numBuf[20];

	if (lineNum >= 0)
		sprintf(numBuf, " in line %d", lineNum);
	else
		numBuf[0] = '\0';

	switch (errorCode) {
		case SYNTAX	     : fprintf(outFile, "ERROR%s: Invalid syntax\n", numBuf); break;
		case UNDEFINED	     : fprintf(outFile, "ERROR%s: Undefined symbol\n", numBuf); break;
		case DIV_BY_ZERO     : fprintf(outFile, "ERROR%s: Division by zero attempted\n", numBuf); break;
		case NUMBER_TOO_BIG  : fprintf(outFile, "WARNING%s: Numeric constant exceeds 32 bits\n", numBuf); break;
		case ASCII_TOO_BIG   : fprintf(outFile, "WARNING%s: ASCII constant exceeds 4 characters\n", numBuf); break;
		case INV_OPCODE      : fprintf(outFile, "ERROR%s: Invalid opcode\n", numBuf); break;
		case INV_SIZE_CODE   : fprintf(outFile, "WARNING%s: Invalid size code\n", numBuf); break;
		case INV_ADDR_MODE   : fprintf(outFile, "ERROR%s: Invalid addressing mode\n", numBuf); break;
		case MULTIPLE_DEFS   : fprintf(outFile, "ERROR%s: Symbol multiply defined\n", numBuf); break;
		case PHASE_ERROR     : fprintf(outFile, "ERROR%s: Symbol value differs between first and second pass\n", numBuf); break;
		case INV_QUICK_CONST : fprintf(outFile, "ERROR%s: MOVEQ instruction constant out of range\n", numBuf); break;
		case INV_VECTOR_NUM  : fprintf(outFile, "ERROR%s: Invalid vector number\n", numBuf); break;
		case INV_BRANCH_DISP : fprintf(outFile, "ERROR%s: Branch instruction displacement is out of range or invalid\n", numBuf); break;
		case LABEL_REQUIRED  : fprintf(outFile, "ERROR%s: Label required with this directive\n", numBuf); break;
		case INV_DISP	       : fprintf(outFile, "ERROR%s: Displacement out of range\n", numBuf); break;
		case INV_ABS_ADDRESS : fprintf(outFile, "ERROR%s: Absolute address exceeds 16 bits\n", numBuf); break;
		case INV_8_BIT_DATA  : fprintf(outFile, "ERROR%s: Immediate data exceeds 8 bits\n", numBuf); break;
		case INV_16_BIT_DATA : fprintf(outFile, "ERROR%s: Immediate data exceeds 16 bits\n", numBuf); break;
		case INCOMPLETE      : fprintf(outFile, "WARNING%s: Evaluation of expression could not be completed\n", numBuf); break;
		case NOT_REG_LIST    : fprintf(outFile, "ERROR%s: The symbol specified is not a register list symbol\n", numBuf); break;
		case REG_LIST_SPEC   : fprintf(outFile, "ERROR%s: Register list symbol used in an expression\n", numBuf); break;
		case REG_LIST_UNDEF  : fprintf(outFile, "ERROR%s: Register list symbol not previously defined\n", numBuf); break;
		case INV_SHIFT_COUNT : fprintf(outFile, "ERROR%s: Invalid constant shift count\n", numBuf); break;
		case INV_FORWARD_REF : fprintf(outFile, "ERROR%s: Forward references not allowed with this directive\n", numBuf); break;
		case INV_LENGTH      : fprintf(outFile, "ERROR%s: Block length is less that zero\n", numBuf); break;
		case ODD_ADDRESS     : fprintf(outFile, "ERROR%s: Origin value is odd (Location counter set to next highest address)\n", numBuf); break;
		default : if (errorCode > ERROR)
				fprintf(outFile, "ERROR%s: No message defined\n", numBuf);
			  else if (errorCode > WARNING)
				fprintf(outFile, "WARNING%s: No message defined\n", numBuf);
		}

	return NORMAL;

}

