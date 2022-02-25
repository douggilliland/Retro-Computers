/***********************************************************************
 *
 *		ASSEMBLE.CPP
 *		Assembly Routines for 68000 Assembler
 *
 *    Function: processFile()
 *		Assembles the input file. For each pass, the function
 *		passes each line of the input file to assemble() to be
 *		assembled. The routine also makes sure that errors are
 *		printed on the screen and listed in the listing file
 *		and keeps track of the error counts and the line
 *		number.
 *
 *		assemble()
 *		Assembles one line of assembly code. The line argument
 *		points to the line to be assembled, and the errorPtr
 *		argument is used to return an error code via the
 *		standard mechanism. The routine first determines if the
 *		line contains a label and saves the label for later
 *		use. It then calls instLookup() to look up the
 *		instruction (or directive) in the instruction table. If
 *		this search is successful and the parseFlag for that
 *		instruction is TRUE, it defines the label and parses
 *		the source and destination operands of the instruction
 *		(if appropriate) and searches the flavor list for the
 *		instruction, calling the proper routine if a match is
 *		found. If parseFlag is FALSE, it passes pointers to the
 *		label and operands to the specified routine for
 *		processing.
 *
 *	 Usage: processFile()
 *
 *		assemble(line, errorPtr)
 *		char *line;
 *		int *errorPtr;
 *
 *      Author: Paul McKee
 *		ECE492    North Carolina State University
 *        Date:	12/13/86

     Modified: Charles Kelly
               Monroe County Community College
               http://www.monroeccc.edu/ckelly

       IFxx <string1>,<string2>
            <statements>
       ENDC

       The condition xx is either C or NC. IFC means if compare. IFNC means
       if not compare. If the condition is true the following statements
       are included in the program.

       Another syntax is:

       IFxx <expression>
            <statements>
       ENDC

       The condition xx is either: EQ (equal to), NE (not equal to),
                LT (less than), LE (less than or equal to),
                GT (greater than), GE (greater than or equal to)

       The expression is compared with 0. If the condition is true the
       following statements are included in the program.

       IFARG n
            <statements>
       ENDC

       If the argument number n exists the following statements in the macro
       are included in the program.

       ENDC ends the conditional section.
 ************************************************************************/

#include <vcl.h>
#include <stdio.h>
#include <ctype.h>
#include "asm.h"
#include "assembleS.h"
#include "mainS.h"
#include "textS.h"
#include "editorOptions.h"



extern int loc;		// The assembler's location counter
extern int sectionLoc[16];     // section locations
extern int  sectI;              // current section
extern int offsetMode;         // True when processing Offset directive
extern bool showEqual;          // true to display equal after address in listing
extern char pass;		// pass counter
extern bool pass2;		// Flag set during second pass
extern bool endFlag;		// Flag set when the END directive is encountered
extern bool continuation;	// TRUE if the listing line is a continuation
extern char empty[];            // used in conditional assembly

extern int lineNum;
extern int lineNumL68;
extern int errorCount, warningCount;

extern char line[256];		// Source line
extern FILE *inFile;		// Input file
extern FILE *listFile;		// Listing file
extern FILE *objFile;	        // Object file
extern FILE *errFile;		// error message file
extern FILE *tmpFile;           // temp file

extern int labelNum;            // macro label \@ number
extern bool listFlag;           // True if a listing is desired
extern bool objFlag;	        // True if an object code file is desired
extern bool xrefFlag;	        // True if a cross-reference is desired
extern bool CEXflag;	        // True is Constants are to be EXpanded
extern bool BITflag;            // True to assemble bitfield instructions
extern char lineIdent[];        // "mmm" used to identify macro in listing
//extern char arguments[MAX_ARGS][ARG_SIZE+1];    // macro arguments

extern bool CREflag, MEXflag, SEXflag;   // assembler directive flags
extern bool noENDM;             // set true if no ENDM in macro
extern int macroNestLevel;      // count nested macro calls
extern char buffer[256];  //ck used to form messages for display in windows
extern char numBuf[20];
extern char globalLabel[SIGCHARS+1];
extern int includeNestLevel;    // count nested include directives
extern char includeFile[256];  // name of current include file
extern bool includedFileError; // true if include error message displayed

extern unsigned int stcLabelI;  // structured if label number
extern unsigned int stcLabelW;  // structured while label number
extern unsigned int stcLabelR;  // structured repeat label number
extern unsigned int stcLabelF;  // structured for label number
extern unsigned int stcLabelD;  // structured dbloop label number

bool skipList;                  // true to skip listing line
bool skipCond;                  // true conditionally skips lines
bool printCond;                 // true to print condition on listing line
bool skipCreateCode;            // true to skip calling createCode during macro processing

const int MAXT = 128;           // maximum number of tokens
const int MAX_SIZE = 512;       // maximun size of input line
char *token[MAXT];              // pointers to tokens
char tokens[MAX_SIZE];          // place tokens here
char *tokenEnd[MAXT];           // where tokens end in source line
int nestLevel = 0;              // nesting level of conditional directives

extern bool mapROM;             // memory map flags
extern bool mapRead;
extern bool mapProtected;
extern bool mapInvalid;

extern stack<int,vector<int> > stcStack;
extern stack<char, vector<char> > dbStack;
extern stack<String, vector<String> > forStack;

//------------------------------------------------------------
// Assemble source file
int assembleFile(char fileName[], char tempName[], AnsiString workName)
{
  AnsiString outName;
  int i;

  try {
    tmpFile = fopen(tempName, "w+");
    if (!tmpFile) {
      sprintf(buffer,"Error creating temp file.");
      Application->MessageBox(buffer, "Error", MB_OK);
      return SEVERE;
    }

    inFile = fopen(fileName, "r");
    if (!inFile) {
      Application->MessageBox("Error reading source file.", "Error", MB_OK);
      return SEVERE;
    }

    // if generate listing is checked then create .L68 file
    if (Options->chkGenList->Checked) {
      outName = ChangeFileExt(workName, ".L68");
      initList(outName.c_str());                // initialize list file
    }

    // if Object file flag then create .S68 file (S-Record)
    if (objFlag) {
      outName = ChangeFileExt(workName, ".S68");
      if(initObj(outName.c_str()) != NORMAL)     // if error initializing object file
        objFlag = false;                        // disable object file creation
    }

    // Assemble the file
    processFile();

    // Close files and print error and warning counts
    fclose(inFile);
    fclose(tmpFile);
    finishList();
    if (objFlag)
      finishObj();

    clearSymbols();               //ck clear symbol table memory

    // clear stacks used in structured assembly
    while(stcStack.empty() == false)
      stcStack.pop();
    while(dbStack.empty() == false)
      dbStack.pop();
    while(forStack.empty() == false)
      forStack.pop();

    // minimize message area if no errors or warnings
    if (warningCount == 0 && errorCount == 0) {
      TTextStuff *Active = (TTextStuff*)Main->ActiveMDIChild; //grab active mdi child
        Active->Messages->Height = 7;
    }

    AssemblerBox->lblStatus->Caption = IntToStr(warningCount);
    AssemblerBox->lblStatus2->Caption = IntToStr(errorCount);

    if(errorCount == 0 && errorCount == 0)
    {
      AssemblerBox->cmdExecute->Enabled = true;
    }
  }
  catch( ... ) {
    sprintf(buffer, "ERROR: An exception occurred in routine 'assembleFile'. \n");
    printError(NULL, EXCEPTION, 0);
    return NULL;
  }

  return NORMAL;
}


int strcap(char *d, char *s)
{
  bool capFlag;

  try {
	capFlag = true;
	while (*s) {
		if (capFlag)
			*d = toupper(*s);
		else
			*d = *s;
		if (*s == '\'')
			capFlag = !capFlag;
		d++;
		s++;
		}
	*d = '\0';
  }
  catch( ... ) {
    sprintf(buffer, "ERROR: An exception occurred in routine 'strcap'. \n");
    printError(NULL, EXCEPTION, 0);
    return NULL;
  }

  return NORMAL;
}


char *skipSpace(char *p)
{
  try {
	while (isspace(*p))
		p++;
	return p;
  }
  catch( ... ) {
    sprintf(buffer, "ERROR: An exception occurred in routine 'skipSpace'. \n");
    printError(NULL, EXCEPTION, 0);
    return NULL;
  }
}

// continue assembly process by reading source file and sending each
// line to assemble()
// does 2 passes from here
int processFile()
{
  int error;
  bool comment;                 // true when line is comment
  int value;
  bool backRef;

  try {
    offsetMode = false;         // clear flags
    showEqual = false;
    pass2 = false;
    macroNestLevel = 0;         // count nested macro calls
    noENDM = false;             // set to true if no ENDM in macro
    includedFileError = false;  // true if include error message displayed
    mapROM = false;             // memory map flags
    mapRead = false;
    mapProtected = false;
    mapInvalid = false;

    for (pass = 0; pass < 2; pass++) {
      globalLabel[0] = '\0';    // for local labels
      labelNum = 0;             // macro label \@ number
      // evalNumber() contains error code that depends on the range of these numbers
      stcLabelI = 0x00000000;   // structured if label number
      stcLabelW = 0x10000000;   // structured while label number
      stcLabelF = 0x20000000;   // structured for label number
      stcLabelR = 0x30000000;   // structured repeat label number
      stcLabelD = 0x40000000;   // structured dbloop label number
      includeNestLevel = 0;     // count nested include directives
      includeFile[0] = '\0';    // name of current include file

      loc = 0;
      for (int i=0; i<16; i++)  // clear section locations
        sectionLoc[i] = 0;
      sectI = 0;                // current section

      lineNum = 1;
      lineNumL68 = 1;
      endFlag = false;
      errorCount = warningCount = 0;
      skipCond = false;             // true conditionally skips lines in code
      while(!endFlag && fgets(line, 256, inFile)) {
        error = OK;
        continuation = false;
        skipList = false;
        printCond = false;           // true to print condition on listing line
        skipCreateCode = false;

        assemble(line, &error);      // assemble one line of code

        lineNum++;
      }
      if (!pass2) {
        pass2 = true;
        //    ************************************************************
        //    ********************  STARTING PASS 2  *********************
        //    ************************************************************
      } else {                  // pass2 just completed
        if(!endFlag) {          // if no END directive was found
          error = END_MISSING;
          warningCount++;
          printError(listFile, error, lineNum);
        }
      }
      rewind(inFile);
    }
  }
  catch( ... ) {
    sprintf(buffer, "ERROR: An exception occurred in routine 'processFile'. \n");
    printError(NULL, EXCEPTION, 0);
    return NULL;
  }

  return NORMAL;
}

// Conditionally Assemble one line of code
int assemble(char *line, int *errorPtr)
{
  int value = 0;
  bool backRef = false;
  int error2Ptr = 0;
  char capLine[256];
  char *p;
  bool comment;                   // true when line is comment

  try {

    if (pass2 && listFlag)
      listLoc();

    strcap(capLine, line);
    p = skipSpace(capLine);               // skip leading white space
    tokenize(capLine, ", \t\n", token, tokens); // tokenize line
    if (*p == '*' || *p == ';')         // if comment
      comment = true;
    else
      comment = false;

    if (comment)                                // if comment
      if (pass2 && listFlag) {
        listLine(line, lineIdent);
        return NORMAL;
      }

    // conditional assembly for all code

    // ----- IFC -----
    if(!(stricmp(token[1], "IFC"))) {       // if IFC opcode
      if (token[0] != empty)                // if label present
        NEWERROR(*errorPtr, LABEL_ERROR);
      if (skipCond)
        nestLevel++;                        // nest level of skip
      else {
        if (stricmp(token[2], token[3])) {  // If IFC strings don't match
          skipCond = true;                  // conditionally skip lines
          nestLevel++;                      // nest level of skip
        }
        printCond = true;
      }

    // ----- IFNC -----
    } else if(!(stricmp(token[1], "IFNC"))) { // if IFNC opcode
      if (token[0] != empty)                  // if label present
        NEWERROR(*errorPtr, LABEL_ERROR);
      if (skipCond)
        nestLevel++;                          // nest level of skip
      else {
        if (token[3] == empty) {                // if IFNC arguments missing
          NEWERROR(*errorPtr, INVALID_ARG);
        } else {
          if (!(stricmp(token[2], token[3]))) { // if IFNC strings match
            skipCond = true;                    // conditionally skip lines
            nestLevel++;                        // nest level of skip
          }
        }
        printCond = true;
      }

    // ----- IFEQ -----
    } else if(!(stricmp(token[1], "IFEQ"))) { // if IFEQ opcode
      if (token[0] != empty)                  // if label present
        NEWERROR(*errorPtr, LABEL_ERROR);
      if (skipCond)
        nestLevel++;                          // nest level of skip
      else {
        if (token[2] == empty) {                // if argument missing
          NEWERROR(*errorPtr, INVALID_ARG);
        } else {
          eval(token[2], &value, &backRef, &error2Ptr);
          if (error2Ptr < ERRORN && value != 0) { // if not condition
            skipCond = true;                    // conditionally skip lines
            nestLevel++;                        // nest level of skip
          }
        }
        printCond = true;
      }

    // ----- IFNE -----
    } else if(!(stricmp(token[1], "IFNE"))) {  // if IFNE opcode
      if (token[0] != empty)                  // if label present
        NEWERROR(*errorPtr, LABEL_ERROR);
      if (skipCond)
        nestLevel++;                          // nest level of skip
      else {
        if (token[2] == empty) {                // if argument missing
          NEWERROR(*errorPtr, INVALID_ARG);
        } else {
          eval(token[2], &value, &backRef, &error2Ptr);
          if (error2Ptr < ERRORN && value == 0) { // if not condition
            skipCond = true;                    // skip lines in macro
            nestLevel++;                        // nest level of skip
          }
        }
        printCond = true;
      }

    // ----- IFLT -----
    } else if(!(stricmp(token[1], "IFLT"))) {  // if IFLT opcode
      if (token[0] != empty)                  // if label present
        NEWERROR(*errorPtr, LABEL_ERROR);
      if (skipCond)
        nestLevel++;                          // nest level of skip
      else {
        if (token[2] == empty) {                // if argument missing
          NEWERROR(*errorPtr, INVALID_ARG);
        } else {
          eval(token[2], &value, &backRef, &error2Ptr);
          if (error2Ptr < ERRORN && value >= 0) { // if not condition
            skipCond = true;                    // conditionally skip lines
            nestLevel++;                        // nest level of skip
          }
        }
        printCond = true;
      }

    // ----- IFLE -----
    } else if(!(stricmp(token[1], "IFLE"))) {  // if IFLE opcode
      if (token[0] != empty)                  // if label present
        NEWERROR(*errorPtr, LABEL_ERROR);
      if (skipCond)
        nestLevel++;                          // nest level of skip
      else {
        if (token[2] == empty) {                // if argument missing
          NEWERROR(*errorPtr, INVALID_ARG);
        } else {
          eval(token[2], &value, &backRef, &error2Ptr);
          if (error2Ptr < ERRORN && value > 0) { // if not condition
            skipCond = true;                    // conditionally skip lines
            nestLevel++;                        // nest level of skip
          }
        }
        printCond = true;
      }

    // ----- IFGT -----
    } else if(!(stricmp(token[1], "IFGT"))) {  // if IFGT opcode
      if (token[0] != empty)                  // if label present
        NEWERROR(*errorPtr, LABEL_ERROR);
      if (skipCond)
        nestLevel++;                          // nest level of skip
      else {
        if (token[2] == empty) {                // if argument missing
          NEWERROR(*errorPtr, INVALID_ARG);
        } else {
          eval(token[2], &value, &backRef, &error2Ptr);
          if (error2Ptr < ERRORN && value <= 0) { // if not condition
            skipCond = true;                    // conditionally skip lines
            nestLevel++;                        // nest level of skip
          }
        }
        printCond = true;
      }

    // ----- IFGE -----
    } else if(!(stricmp(token[1], "IFGE"))) {  // if IFGE opcode
      if (token[0] != empty)                  // if label present
        NEWERROR(*errorPtr, LABEL_ERROR);
      if (skipCond)
        nestLevel++;                          // nest level of skip
      else {
        if (token[2] == empty) {                // if argument missing
          NEWERROR(*errorPtr, INVALID_ARG);
        } else {
          eval(token[2], &value, &backRef, &error2Ptr);
          if (error2Ptr < ERRORN && value < 0) {  // if not condition
            skipCond = true;                    // conditionally skip lines
            nestLevel++;                        // nest level of skip
          }
        }
        printCond = true;
      }

    // ----- ENDC -----
    } else if(!(stricmp(token[1], "ENDC"))) {  // if ENDC opcode
      if (token[0] != empty)                  // if label present
        NEWERROR(*errorPtr, LABEL_ERROR);
      if (nestLevel > 0)
        nestLevel--;                          // decrease nesting level
      if (nestLevel == 0) {
        skipCond = false;                     // stop skipping lines
      } else
        printCond = false;

    } else if (!skipCond && !skipCreateCode) {  // else, if not skip condition and not skip create

      createCode(capLine, errorPtr);
    }

    // display and list errors and source line
    if (pass2) {
      if (*errorPtr > MINOR)
        errorCount++;
      else if (*errorPtr > WARNING)
        warningCount++;
      printError(listFile, *errorPtr, lineNum);
      if (printCond && !skipList)
      {
        listCond(skipCond);
        listLine(line, lineIdent);
      } else if ( (listFlag && (!skipCond && !skipList)) || *errorPtr > WARNING)
        listLine(line, lineIdent);
    }

  }
  catch( ... ) {
    NEWERROR(*errorPtr, EXCEPTION);
    sprintf(buffer, "ERROR: An exception occurred in routine 'assemble'. \n");
    return NULL;
  }

  return NORMAL;
}

// create machine code for instruction
int createCode(char *capLine, int *errorPtr) {
  instruction *tablePtr;
  flavor *flavorPtr;
  opDescriptor source, dest;
  char *p, *start, label[SIGCHARS+1], size, f;
  bool sourceParsed, destParsed;
  unsigned short mask, i;

  p = start = skipSpace(capLine);  // skip leading spaces and tabs
  if (*p && *p != '*' && *p != ';') {  // if line not empty and not comment
    // if first char is not alpha . or _
    if( !isalpha(*p) && *p != '.' && *p != '_')
      NEWERROR(*errorPtr,ILLEGAL_SYMBOL);
    // assume the line starts with a label
    i = 0;
    do {
      if (i < SIGCHARS)         // only first SIGCHARS of label are used
        label[i++] = *p;
      p++;
    } while (isalnum(*p) || *p == '.' || *p == '_' || *p == '$');
    label[i] = '\0';            // end label string with null
    if (i >= SIGCHARS)
      NEWERROR(*errorPtr, LABEL_TOO_LONG);

    // if next character is space AND the label was at the start of the line
    // OR the label ends with ':'
    if ((isspace(*p) && start == capLine) || *p == ':') {
      if (*p == ':')            // if label ends with :
        p++;                    // skip it
      p = skipSpace(p);         // skip trailing spaces
      if (*p == '*' || *p == ';' || !*p) {   // if the next char is '*' or ';' or end of line
        define(label, loc, pass2, true, errorPtr);  // add label to list of labels
        return NORMAL;
      }
    } else {
      p = start;                // reset p to start of line
      label[0] = '\0';          // clear label
    }
    p = instLookup(p, &tablePtr, &size, errorPtr);
    if (*errorPtr > SEVERE)
      return NORMAL;
    p = skipSpace(p);
    if (tablePtr->parseFlag) {
      // Move location counter to a word boundary and fix
      //   the listing before assembling an instruction
      if (loc & 1) {
        loc++;
        listLoc();
      }
      if (*label)
        define(label, loc, pass2, true, errorPtr);
      if (*errorPtr > SEVERE)
        return NORMAL;
      sourceParsed = destParsed = false;
      flavorPtr = tablePtr->flavorPtr;
      for (f = 0; (f < tablePtr->flavorCount); f++, flavorPtr++) {
        if (!sourceParsed && flavorPtr->source) {
          p = opParse(p, &source, errorPtr);    // parse source
          if (*errorPtr > SEVERE)
            return NORMAL;

          if (flavorPtr && flavorPtr->exec == bitField) {     // if bitField instruction
            p = skipSpace(p);           // skip spaces after source operand
            if (*p != ',') {            // if not Dn,addr{offset:width}
              p = fieldParse(p, &source, errorPtr);     // parse {offset:width}
              if (*errorPtr > SEVERE)
                return NORMAL;
            }
          }
          sourceParsed = true;
        }
        if (!destParsed && flavorPtr->dest) {   // if destination needs parsing
          p = skipSpace(p);     // skip spaces after source operand
          if (*p != ',') {
            NEWERROR(*errorPtr, COMMA_EXPECTED);
            return NORMAL;
          }
          p++;                   // skip over comma
          p = skipSpace(p);      // skip spaces before destination operand
          p = opParse(p, &dest, errorPtr);      // parse destination
          if (*errorPtr > SEVERE)
            return NORMAL;

          if (flavorPtr && flavorPtr->exec == bitField &&
              flavorPtr->source == DnDirect)  // if bitField instruction Dn,addr{offset:width}
          {
            p = skipSpace(p);           // skip spaces after destination operand
            if (*p != '{') {
              NEWERROR(*errorPtr, BAD_BITFIELD);
              return NORMAL;
            }
            p = fieldParse(p, &dest, errorPtr);
            if (*errorPtr > SEVERE)
              return NORMAL;
          }

          if (!isspace(*p) && *p) {     // if next character is not whitespace
            NEWERROR(*errorPtr, SYNTAX);
            return NORMAL;
          }
          destParsed = true;
        }
        if (!flavorPtr->source) {
          mask = pickMask( (int) size, flavorPtr, errorPtr);
          // The following line calls the function defined for the current
          // instruction as a flavor in instTable[]
          (*flavorPtr->exec)(mask, (int) size, &source, &dest, errorPtr);
          return NORMAL;
        }
        else if ((source.mode & flavorPtr->source) && !flavorPtr->dest) {
          if (*p!='{' && !isspace(*p) && *p) {
            NEWERROR(*errorPtr, SYNTAX);
            return NORMAL;
          }
          mask = pickMask( (int) size, flavorPtr, errorPtr);
          // The following line calls the function defined for the current
          // instruction as a flavor in instTable[]
          (*flavorPtr->exec)(mask, (int) size, &source, &dest, errorPtr);
          return NORMAL;
        }
        else if (source.mode & flavorPtr->source
                 && dest.mode & flavorPtr->dest) {
          mask = pickMask( (int) size, flavorPtr, errorPtr);
          // The following line calls the function defined for the current
          // instruction as a flavor in instTable[]

          (*flavorPtr->exec)(mask, (int) size, &source, &dest, errorPtr);
          return NORMAL;
        }
      }
      NEWERROR(*errorPtr, INV_ADDR_MODE);
    } else {
      // The following line calls the function defined for the current
      // instruction as a flavor in instTable[]
      (*tablePtr->exec)( (int) size, label, p, errorPtr);
      return NORMAL;
    }
  }
  return NORMAL;
}

//-------------------------------------------------------
// parse {offset:width}
char *fieldParse(char *p, opDescriptor *d, int *errorPtr)
{
  int offset, width;
  bool backRef;

  d->field = 0;

  if (*p != '{') {
    NEWERROR(*errorPtr, BAD_BITFIELD);
    return p;
  }
  p++;                          // skip '{'
  p = skipSpace(p);

  // parse offset
  if ((p[0] == 'D') && isRegNum(p[1])) {        // if offset in data register
    d->field |= 0x0800;         // set Do to 1 for Dn offset
    d->field |= ((p[1] - '0') << 6);    // put reg number in bits[8:6]
    p+=2;                       // skip Dn
  } else {                      // else offset is immediate
    if (p[0] == '#')
      p++;                      // skip '#'
    p = eval(p, &offset, &backRef, errorPtr);   // read offset number
    if (*errorPtr > SEVERE) {
      NEWERROR(*errorPtr, BAD_BITFIELD);
      return p;
    }
    if (!backRef)
      NEWERROR(*errorPtr, INV_FORWARD_REF);
    if (offset < 0 || offset > 31) {
      NEWERROR(*errorPtr, BAD_BITFIELD);
      return p;
    }
    d->field |= offset << 6;    // put offset in bits[10:6]
  }
  p = skipSpace(p);

  if (*p != ':') {
    NEWERROR(*errorPtr, BAD_BITFIELD);
    return p;
  }
  p++;          // skip ':'
  p = skipSpace(p);

  // parse width
  if ((p[0] == 'D') && isRegNum(p[1])) {        // if width in data register
    d->field |= 0x0020;         // set Dw to 1 for Dn width
    d->field |= (p[1] - '0');   // put reg number in bits[2:0]
    p+=2;                       // skip Dn
  } else {                      // else width is immediate
    if (p[0] == '#')
      p++;                      // skip '#'
    p = eval(p, &width, &backRef, errorPtr);   // read width number
    if (*errorPtr > SEVERE) {
      NEWERROR(*errorPtr, BAD_BITFIELD);
      return p;
    }
    if (!backRef)
      NEWERROR(*errorPtr, INV_FORWARD_REF);
    if (width < 1 || width > 32) {
      NEWERROR(*errorPtr, BAD_BITFIELD);
      return p;
    }
    if (width == 32)            // 0 specifies a field width of 32
      width = 0;
    d->field |= width;          // put width in bits[4:0]
  }
  if (*p != '}') {
    NEWERROR(*errorPtr, BAD_BITFIELD);
    return p;
  }
  p++;          // skip '}'
  return p;
}

//-------------------------------------------------------
int pickMask(int size, flavor *flavorPtr, int *errorPtr)
{
  if (!size || size & flavorPtr->sizes)
    if (size & (BYTE_SIZE | SHORT_SIZE))
      return flavorPtr->bytemask;
  else if (!size || size == WORD_SIZE)
    return flavorPtr->wordmask;
  else
    return flavorPtr->longmask;
  NEWERROR(*errorPtr, INV_SIZE_CODE);
  return flavorPtr->wordmask;
}

//---------------------------------------------------
// Tokenize a string to tokens.
// Each element of token[] is a pointer to the corresponding token in
//   tokens. token[0] is always reserved for the label if any. A value
//   of empty in token[] indicates no token.
// Each token is null terminated.
// Items inside parenthesis (  ) are one token
// Items inside single quotes ' ' are one token
// Parameters:
//      instr = the string to tokenize
//      delim = string of delimiter characters
//              (spaces are not default delimiters)
//              period delimiters are included in the start of the next token
//      token[] = pointers to tokens
//      tokens = new string full of tokens
// Returns number of tokens extracted.
int tokenize(char* instr, char* delim, char *token[], char* tokens){
  int i, size, tokN = 0, tokCount = 0;
  char* start;
  int parenCount;
  bool dotDelimiter;
  bool quoted = false;

  dotDelimiter = (strchr(delim, '.'));  // set true if . is a delimiter
  // clear token pointers
  for (i=0; i<MAXT; i++) {
    token[i] = empty;           // this makes the pointer point to empty
    tokenEnd[i] = NULL;         // clear positions
  }

  start = instr;
  while(*instr && isspace(*instr))              // skip leading spaces
    instr++;
  if (*instr != '*' && *instr != ';') {         // if not comment line
    if (start != instr)                         // if no label
      tokN = 1;
    size = 0;
    while (*instr && tokN < MAXT && size < MAX_SIZE) { // while tokens remain
      parenCount = 0;
      token[tokN] = &tokens[size];              // pointer to token
      //while (*instr && strchr(delim, *instr))   // skip leading delimiters
      while(*instr && isspace(*instr))              // skip leading spaces
        instr++;
      if (*instr == '\'' && *(instr+1) == '\'') { // if argument starts with '' (NULL)
        tokens[size++] = '\0';
        instr+=2;
      }
      if (dotDelimiter && *instr == '.') {      // if . delimiter
        tokens[size++] = *instr++;              // start token with .
      }
      // while more chars AND (not delimiter OR inside parens) AND token size limit not reached OR quoted
      while (*instr && (!(strchr(delim, *instr)) || parenCount > 0 || quoted) && (size < MAX_SIZE-1) ) {
        if (*instr == '\'')                     // if found '
          if (quoted)
            quoted = false;
          else
            quoted = true;
        if (*instr == '(')                      // if found (
          parenCount++;
        else if (*instr == ')')
          parenCount--;
        tokens[size++] = *instr++;
      }

      tokens[size++] = '\0';                    // terminate
      tokenEnd[tokN] = instr;                   // save token end position in source line
      if (*instr && (!dotDelimiter || *instr != '.')) // if not . delimiter
        instr++;                                // skip delimiter
      tokCount++;                               // count tokens
      tokN++;                                   // next token index
      //while (*instr && strchr(delim, *instr))       // skip trailing delimiters
      while (*instr && isspace(*instr))         // skip trailing spaces *ck 12-10-2005
        instr++;
    }
  }
  return tokCount;
}


