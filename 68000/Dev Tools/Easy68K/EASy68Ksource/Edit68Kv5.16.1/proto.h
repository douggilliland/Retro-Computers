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
 *    Modified: Jan-28-2002 by Chuck Kelly,
 *              Monroe County Community College
 *              http://www.monroeccc.edu/ckelly
 *
 *              Feb-13-2002 CK  Dec-9-2005 CK
 ************************************************************************/

/* ANSI C function prototype definitions */


int	processFile(void);

int	assemble(char *, int *);

int     createCode(char *, int *);

int     assembleFile(char fileName[], char tempName[], AnsiString workName);

char    *fieldParse(char *p, opDescriptor *d, int *errorPtr);

int	pickMask(int, flavor *, int *);

int	move(int, int, opDescriptor *, opDescriptor *, int *);

int	zeroOp(int, int, opDescriptor *, opDescriptor *, int *);

int	oneOp(int, int, opDescriptor *, opDescriptor *, int *);

int	arithReg(int, int, opDescriptor *, opDescriptor *, int *);

int	arithAddr(int, int, opDescriptor *, opDescriptor *, int *);

int	bitField(int, int, opDescriptor *, opDescriptor *, int *);

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

int	output(int, int);

int	effAddr(opDescriptor *);

int	extWords(opDescriptor *, int, int *);

int	org(int, char *, char *, int *);

int	offset(int, char *, char *, int *);

int	funct_end(int, char *, char *, int *);

int	equ(int, char *, char *, int *);

int	set(int, char *, char *, int *);

int     section(int, char *, char *, int *);

int     simhalt(int, char *, char *, int *);

int     page(int, char *, char *, int *);

int	dc(int, char *, char *, int *);

char	*collect(char *, char *);

int	dcb(int, char *, char *, int *);

int	ds(int, char *, char *, int *);

int	printError(FILE *, int, int);

char	*eval(char *, int *, bool *, int *);

char	*evalNumber(char *, int *, bool *, int *);

int	precedence(char);

int	doOp(int, int, char, int *);

char	*instLookup(char *, instruction *(*), char *, int *);

int	initList(char *);

int	listLine(char[], char[] = "\0");

int	listLoc(void);

int     listCond(bool);

int     listError(char *lineNum, char *errMsg);

int     listText(const char *text);

int	listObj(int, int);

int	strcap(char *, char *);

char	*skipSpace(char *);

int	setFlags(int, char *[], int *);

//int	getopt(int, char *[], char *, int *);

int	help(void);

int	movem(int, char *, char *, int *);

int	reg(int, char *, char *, int *);

int	opt(int, char *, char *, int *);

int     macro(int, char *, char *, int *);      //ck

int     asmMacro(int, char *, char *, int *);   //ck

int     asmStructure(int, char *, char *, int *);  //ck

int     tokenize(char* , char*, char*[], char*);  //ck

int     optCRE();                               //ck

char	*evalList(char *, unsigned short *, int *);

int	initObj(char *);

int	outputObj(int, int, int);

int	checkValue(int);

int     finishList();

int	finishObj(void);

char	*opParse(char *, opDescriptor *, int *);

symbolDef *lookup(char *, int, int *);

int	hash(char *);

symbolDef *define(char *, int, bool, bool, int *);

void clearSymbols();

int	writeObj(void);

int include(int, char *, char *, int *);

int incbin(int, char *, char *, int *);

int failError(int, char *, char *, int *);

int listOn(int, char *, char *, int *);

int listOff(int, char *, char *, int *);

int memory(int, char *, char *, int *);
