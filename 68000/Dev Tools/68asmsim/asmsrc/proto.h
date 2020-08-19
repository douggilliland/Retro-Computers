/***********************************************************************
 *
 *		PROTO.H
 *		Global Definitions for 68000 Assembler
 *
 *      Author: Paul McKee
 *		ECE492    North Carolina State University
 *
 *        Date:	9/5/88
 *
 ************************************************************************/



/* ANSI C function prototype definitions */

int	processFile(void);

int	assemble(char *, int *);

int	pickMask(int, flavor *, int *);

int	move(int, int, opDescriptor *, opDescriptor *, int *);

int	zeroOp(int, int, opDescriptor *, opDescriptor *, int *);

int	oneOp(int, int, opDescriptor *, opDescriptor *, int *);

int	arithReg(int, int, opDescriptor *, opDescriptor *, int *);

int	arithAddr(int, int, opDescriptor *, opDescriptor *, int *);

int	immedInst(int, int, opDescriptor *, opDescriptor *, int *);

int	quickMath(int, int, opDescriptor *, opDescriptor *, int *);

int	movep(int, int, opDescriptor *, opDescriptor *, int *);

int	moves(int, int, opDescriptor *, opDescriptor *, int *);

int	moveReg(int, int, opDescriptor *, opDescriptor *, int *);

int	staticBit(int, int, opDescriptor *, opDescriptor *, int *);

int	movec(int, int, opDescriptor *, opDescriptor *, int *);

int	trap(int, int, opDescriptor *, opDescriptor *, int *);

int	branch(int, int, opDescriptor *, opDescriptor *, int *);

int	moveq(int, int, opDescriptor *, opDescriptor *, int *);

int	immedToCCR(int, int, opDescriptor *, opDescriptor *, int *);

int	immedWord(int, int, opDescriptor *, opDescriptor *, int *);

int	dbcc(int, int, opDescriptor *, opDescriptor *, int *);

int	scc(int, int, opDescriptor *, opDescriptor *, int *);

int	shiftReg(int, int, opDescriptor *, opDescriptor *, int *);

int	exg(int, int, opDescriptor *, opDescriptor *, int *);

int	twoReg(int, int, opDescriptor *, opDescriptor *, int *);

int	oneReg(int, int, opDescriptor *, opDescriptor *, int *);

int	moveUSP(int, int, opDescriptor *, opDescriptor *, int *);

int	link(int, int, opDescriptor *, opDescriptor *, int *);

int	output(long, int);

int	effAddr(opDescriptor *);

int	extWords(opDescriptor *, int, int *);

int	org(int, char *, char *, int *);

int	funct_end(int, char *, char *, int *);

int	equ(int, char *, char *, int *);

int	set(int, char *, char *, int *);

int	dc(int, char *, char *, int *);

char	*collect(char *, char *);

int	dcb(int, char *, char *, int *);

int	ds(int, char *, char *, int *);

int	printError(FILE *, int, int);

char	*eval(char *, long *, char *, int *);

char	*evalNumber(char *, long *, char *, int *);

int	precedence(char);

int	doOp(long, long, char, long *);

char	*instLookup(char *, instruction *(*), char *, int *);

int	initList(char *);

int	listLine(void);

int	listLoc(void);

int	listObj(long, int);

int	main(int, char *[]);

int	strcap(char *, char *);

char	*skipSpace(char *);

int	setFlags(int, char *[], int *);

int	getopt(int, char *[], char *, int *);

int	help(void);

int	movem(int, char *, char *, int *);

int	reg(int, char *, char *, int *);

char	*evalList(char *, unsigned short *, int *);

int	initObj(char *);

int	outputObj(long, long, int);

long	checkValue(long);

int	finishObj(void);

char	*opParse(char *, opDescriptor *, int *);

symbolDef *lookup(char *, int, int *);

int	hash(char *);

symbolDef *define(char *, long, int, int *);

int	writeObj(void);

