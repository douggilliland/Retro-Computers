/***********************************************************************
 *
 *		GLOBALS.C
 *		Global Variable Declarations for 68000 Assembler
 *
 *      Author: Paul McKee
 *		ECE492    North Carolina State University
 *
 *        Date:	12/13/86
 *
 *    Modified: Charles Kelly
 *              Monroe County Community College
 *              http://www.monroeccc.edu/ckelly
 ************************************************************************/


#include <stdio.h>
#include "asm.h"


// General

int loc;		// The assembler's location counter
int locOffset;         // loc is saved here during processing of Offset directive
int sectionLoc[16];    // section locations
int  sectI;             // current section
bool offsetMode;        // set true during processing of Offset directive
bool showEqual;         // true to display '=' after address in listing
char pass;              // pass counter
bool pass2;		/* Flag telling whether or not it's the second pass */
bool endFlag;	        /* Flag set when the END directive is encountered */
int labelNum;           // macro label \@ number (ck)
char buffer[256];       // used to form messages for display in windows (ck)
char numBuf[20];        // "
int errorCount, warningCount;	// Number of errors and warnings
char empty[] = "";      // empty string, used in conditional assembly
unsigned int startAddress;     // starting address of program
char globalLabel[SIGCHARS+1];   // used to build unique global label from local label
int includeNestLevel;    // count nested include directives
char includeFile[256];  // name of current include file
bool includedFileError; // true if include error message displayed

// File pointers
FILE *inFile;		// Input file
FILE *listFile;		// Listing file
FILE *objFile;		// Object file (S-Record)
FILE *binFile;          //ck Object file (Binary)
FILE *tmpFile;          //ck temp file
FILE *errFile;          //ck Error messages file (text)

// Listing information
char line[256];		// Source line
int lineNum;		// source line number
int lineNumL68;		// listing line number
char *listPtr;		// Pointer to buffer where a listing line is assembled
bool continuation;	// TRUE if the listing line is a continuation

// Option flags
bool listFlag;	        // True if a listing is desired
bool objFlag;	        // True if an S-Record object code file is desired
bool CEXflag;	        // True is Constants are to be EXpanded
bool BITflag;           // True to assemble bitfield instructions
bool CREflag;           // true adds symbol table to listing
bool MEXflag;           // true expands macro calls in listing
bool SEXflag;           // true expands structured code in listing
bool WARflag;           // true shows Warnings during assembly
bool noFileName;        // true indicates no name for current source file

// Editor flags
tabTypes tabType;
bool maximizedEdit;     // true starts child window in editor maximized
bool autoIndent;        // true, copies whitespace from preceding line
bool realTabs;          // true, use real tabs in editor, false, use spaces
FontStyle codeStyle;
FontStyle unknownStyle;
FontStyle directiveStyle;
FontStyle commentStyle;
FontStyle labelStyle;
FontStyle structureStyle;
FontStyle errorStyle;
FontStyle textStyle;
TColor backColor;

// Sturctured Assembly
unsigned int stcLabelI;  // structured if label number
unsigned int stcLabelW;  // structured while label number
unsigned int stcLabelR;  // structured repeat label number
unsigned int stcLabelF;  // structured for label number
unsigned int stcLabelD;  // structured dbloop label number

// Memory map
bool mapROM;
bool mapRead;
bool mapProtected;
bool mapInvalid;
int mapROMStart, mapROMEnd;
int mapReadStart, mapReadEnd;
int mapProtectedStart, mapProtectedEnd;
int mapInvalidStart, mapInvalidEnd;
