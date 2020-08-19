/***********************************************************************
 *
 *		EVAL.C
 *		Expression Evaluator for 68000 Assembler
 *
 *    Function: eval()
 *		Evaluates a constant expression. The p argument points
 *		to the string to be evaluated, and the function returns
 *		a pointer to the first character beyond the end of the
 *		expression. The value of the expression and an error
 *		code are returned via output arguments. The function 
 *		handles errors according to the following table:
 *
 *				   Pass1        Pass1   Pass2         Pass2
 *		Condition          Error        *refPtr Error         *refPtr
 *		----------------   ----------   -----   -----------   -----
 *		Undefined symbol   INCOMPLETE   FALSE   UNDEFINED     FALSE
 *		Division by zero   INCOMPLETE   FALSE   DIV_BY_ZERO   FALSE
 *		Syntax error       SYNTAX	  --      SYNTAX        --
 * 		Constant error     x_TOO_BIG    T/F     x_TOO_BIG     T/F
 *		No error           OK           T/F     OK            T/F
 *
 *		The char pointed to by refPtr is set to TRUE if all the
 *		symbols encountered in the expression are backwards
 *		references or FALSE if at least one symbol is a forward
 *		reference. 
 *
 *	 Usage:	char *eval(p, valuePtr, refPtr, errorPtr)
 *		char *p;
 *		long	*valuePtr;
 *		char *refPtr;
 *		int *errorPtr;
 *
 *	Errors: ASCII_TOO_BIG
 *		DIV_BY_ZERO
 *		INCOMPLETE
 *		NUMBER_TOO_BIG
 *		REG_LIST_SPEC
 *		SYNTAX
 *		UNDEFINED
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

extern char pass2;

/* Largest number that can be represented in an unsigned int
	- MACHINE DEPENDENT */
#define INTLIMIT 0xFFFF
#define LONGLIMIT 0xFFFFFFFF

#define STACKMAX 5

char	*eval(p, valuePtr, refPtr, errorPtr)
char	*p;
long	*valuePtr;
char	*refPtr;
int	*errorPtr;
{
long	valStack[STACKMAX];
char	opStack[STACKMAX-1];
int	valPtr = 0;
int	opPtr = 0;
long	t;
int	prec;
long	i;
char	evaluate, backRef;
int	status;

/*	printf("EVAL: Input string is \"%s\"\n", p); */
	/* Assume that the expression is to be evaluated,
	   at least until an undefined symbol is found */
	evaluate = TRUE;
	/* Assume initially that all symbols are backwards references */
	*refPtr = TRUE;
	/* Loop until terminator character is found (loop is exited via return) */
	while (TRUE) {
		/************************************************
		 *						*
		 *		EXPECT AN OPERAND		*
		 *						*
		 ************************************************/
		/* Use evalNumber to read in a number or symbol */
		status = OK;
		p = evalNumber(p, &t, &backRef, &status);
		NEWERROR(*errorPtr, status);
		if (!backRef && (status > ERROR || status == INCOMPLETE)) {
			/* Stop evaluating the expression */
			evaluate = FALSE;
			*refPtr = FALSE;
			}
		else if (*errorPtr > SEVERE)
			/* Pass any other error to the caller */
			return NULL;
		else {
			/* If OK or WARNING, push the value on the stack */
			if (evaluate)
				valStack[valPtr++] = t;
			/* Set *refPtr to reflect the symbol just parsed */
			*refPtr = (char) (*refPtr && backRef);
			}
/*		printf("Operand read - stack contains (bottom to top):\n");
		for (i = 0; i < valPtr || i < opPtr; i++) {
			printf("%2d: ", i);
			if (i < valPtr)
				printf("%10d ", valStack[i]);
			else
				printf("           ");
			if (i < opPtr)
				putchar(opStack[i]);
			putchar('\n');
			} */

		/************************************************
		 *						*
		 *		EXPECT AN OPERATOR		*
		 *						*
		 ************************************************/
		/* Handle the >> and << operators */
		if (*p == '>' || *p == '<') {
			p++;
			if (*p != *(p-1)) {
				NEWERROR(*errorPtr, SYNTAX);
				return NULL;
				}
			}
		prec = precedence(*p);
		/* Do all stacked operations that are of higher
		   precedence than the operator just examined. */
		while (opPtr && evaluate && (prec <= precedence(opStack[opPtr-1]))) {
			/* Pop operands and operator and do the operation */
			t = valStack[--valPtr];
			i = valStack[--valPtr];
			status = doOp(i, t, opStack[--opPtr], &t);
			if (status != OK) {
				/* Report error from doOp */
				if (pass2) {
					NEWERROR(*errorPtr, status);
					}
				else
					NEWERROR(*errorPtr, INCOMPLETE);
				evaluate = FALSE;
				*refPtr = FALSE;
				}
			else
				/* Otherwise push result on the stack */
				valStack[valPtr++] = t;
			}
		if (prec) {
			if (evaluate)
				/* If operator is valid, push it on the stack */

				opStack[opPtr++] = *p;
			p++;
			}
		else if (*p == ',' || *p == '(' || *p == ')' || !(*p) || isspace(*p)) {
			/* If the character terminates the expression,
			   then return the various results needed. */
			if (evaluate)
				*valuePtr = valStack[--valPtr];
			else
				*valuePtr = 0;
/*			printf("EVAL: The expression is \"");
			while (start < p)
				putchar(*start++);
			printf("\"\n"); */
			return p;
			}
		else {
			/* Otherwise report the syntax error */
			NEWERROR(*errorPtr,  SYNTAX);
			return NULL;
			}

/*		printf("Operator processed - stack contains (bottom to top):\n")
;
		for (i = 0; i < valPtr || i < opPtr; i++) {
			printf("%2d: ", i);
			if (i < valPtr)
				printf("%10d ", valStack[i]);
			else
				printf("           ");
			if (i < opPtr)
				putchar(opStack[i]);
			putchar('\n');
			} */
		}

	return NORMAL;

}




char	*evalNumber(p, numberPtr, refPtr, errorPtr)
char	*p;
long	*numberPtr;
char	*refPtr;
int	*errorPtr;
{
int	status;
long	base;
long	x;
char	name[SIGCHARS+1];
symbolDef *symbol, *lookup();
int	i;
char	endFlag;

	*refPtr = TRUE;
	if (*p == '-') {
		/* Evaluate unary minus operator recursively */
		p = evalNumber(++p, &x, refPtr, errorPtr);
		*numberPtr = -x;
		return p;
		}
	else if (*p == '~') {
		/* Evaluate one's complement operator recursively */
		p = evalNumber(++p, &x, refPtr, errorPtr);
		*numberPtr = ~x;
		return p;
		}
	else if (*p == '(') {
		/* Evaluate parenthesized expressions recursively */
		p = eval(++p, &x, refPtr, errorPtr);
		if (*errorPtr > SEVERE)
			return NULL;
		else if (*p != ')') {
			NEWERROR(*errorPtr, SYNTAX);
			return NULL;
			}
		else {
			*numberPtr = x;
			return ++p;
			}
		}
	else if (*p == '$' && isxdigit(*(p+1))) {
		/* Convert hex digits until another character is
		   found. (At least one hex digit is present.) */
		x = 0;
		while (isxdigit(*++p)) {
			if ((unsigned long)x > (unsigned long)LONGLIMIT/16)
				NEWERROR(*errorPtr, NUMBER_TOO_BIG);
			if (*p > '9')
				x = 16 * x + (*p - 'A' + 10);
			else
				x = 16 * x + (*p - '0');
			}
		*numberPtr = x;
		return p;
		}
	else if (*p == '%' || *p == '@' || isdigit(*p)) {
		/* Convert digits in the appropriate base (binary, 
		   octal, or decimal) until an invalid digit is found. */
		if (*p == '%') {
			base = 2;
			p++;
			}
		else if (*p == '@') {
			base = 8;
			p++;
			}
		else base = 10;
		/* Check that at least one digit is present */
		if (*p < '0' || *p >= '0' + base) {
			NEWERROR(*errorPtr, SYNTAX);
			return NULL;
			}
		x = 0;
		/* Convert the digits into an integer */
		while (*p >= '0' && *p < '0' + base) {
			if (x > (LONGLIMIT - (*p - '0')) / base) {
				NEWERROR(*errorPtr, NUMBER_TOO_BIG);
				printf ("number is too big\n");
				}
			x = (long) ( (long) ((long) base * x) + (long) (*p - '0') );
			p++;
			}
		*numberPtr = x;
		return p;
		}
	else if (*p == '\'') {
		endFlag = FALSE;
		i = 0;
		x = 0;
		p++;
		while (!endFlag) {
			if (*p == '\'') 
				if (*(p+1) == '\'') {
					x = (x << 8) + *p;
					i++;
					p++;
					}
				else
					endFlag = TRUE;
			else {
				x = (x << 8) + *p;
				i++;
				}
			p++;
			}
		if (i == 0) {
			NEWERROR(*errorPtr, SYNTAX);
			return NULL;
			}
		else if (i == 3)
			x = x << 8;
		else if (i > 4)
			NEWERROR(*errorPtr, ASCII_TOO_BIG);
		*numberPtr = x;
		return p;
		}
	else if (isalpha(*p) || *p == '.') {
		/* Determine the value of a symbol */
		i = 0;
		/* Collect characters of the symbol's name
		   (only SIGCHARS characters are significant) */
		do {
			if (i < SIGCHARS)
				name[i++] = *p;
			p++;
		} while (isalnum(*p) || *p == '.' || *p == '_' || *p == '$');
		name[i] = '\0';
		/* Look up the name in the symbol table, resulting
		   in a pointer to the symbol table entry */
		status = OK;
		symbol = lookup(name, FALSE, &status);
/*		printf("EvalNumber: Status from lookup = %04X\n", status); */
		if (status == OK)
			/* If symbol was found, and it's not a register
			   list symbol, then return its value */
			if (!(symbol->flags & REG_LIST_SYM)) {
				*numberPtr = symbol->value;
/*				printf("The value of the symbol \"%s\" is %08lX\n",
					name, *numberPtr); */
				if (pass2)
					*refPtr = (symbol->flags & BACKREF);
				}
			else {
				/* If it is a register list symbol, return error */
				*numberPtr = 0;
				NEWERROR(*errorPtr, REG_LIST_SPEC);
				}
		else {
			/* Otherwise return an error */
			if (pass2) {
				NEWERROR(*errorPtr, UNDEFINED);
				}
			else
				NEWERROR(*errorPtr, INCOMPLETE);
			*refPtr = FALSE;
			}
/*		printf("The symbol \"%s\" is%s a backwards reference\n",
			name, (*refPtr) ? "" : " not"); */
		return p;
 		}
	else {
		/* Otherwise, the character was not a valid operand */
		NEWERROR(*errorPtr, SYNTAX);
		return NULL;
		}

	return NORMAL;

}



int precedence(op)
char op;
{
	/* Compute the precedence of an operator. Higher numbers indicate
	   higher precedence, e.g., precedence('*') > precedence('+').
	   Any character which is not a binary operator will be assigned
	   a precedence of zero. */
	switch (op) {
		case '+' :
		case '-' : return 1;
		case '&' :
 		case '!' : return 3;
		case '>' :
		case '<' : return 4;
		case '*' :
		case '/' : 
		case '\\': return 2;
		default  : return 0;
		}

	return NORMAL;

}



int doOp(val1, val2, op, result)
long	val1, val2;
char	op;
long	*result;
{

	/* Performs the operation of the operator on the two operands.
	   Returns OK or DIV_BY_ZERO. */

	switch (op) {
		case '+' : *result = val1 + val2;  return OK;
		case '-' : *result = val1 - val2;  return OK;
		case '&' : *result = val1 & val2;  return OK;
		case '!' : *result = val1 | val2;  return OK;
		case '>' : *result = val1 >> val2; return OK;
		case '<' : *result = val1 << val2; return OK;
		case '*' : *result = val1 * val2;  return OK;
		case '/' : if (val2 != 0) {
				   *result = val1 / val2;
				   return OK;
				   }
			   else
				   return DIV_BY_ZERO;
		case '\\': if (val2 != 0) {
				   *result = val1 % val2;
				   return OK;
				   }
			   else
				   return DIV_BY_ZERO;
		default  : printf("DoOp: Operator error  op = '%c' val1 = %d val2 = %d\n", op, val1, val2);
		}

	return NORMAL;

}


