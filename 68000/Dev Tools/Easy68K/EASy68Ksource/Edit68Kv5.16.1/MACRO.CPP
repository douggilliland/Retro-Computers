/***********************************************************************

 		MACRO.CPP

     This file contains the code for assembling macros. The macro is
     defined using the syntax:
       macName    macro
                  macro code
                  endm
     Up to 37 parameters may be specified as \0 thru \9 & \A thru \Z.
     Conditional assembly is supported. The syntax is:

    Functions: macro - Defines the macro.
               Saves file pointer to macro, defines macro name,
               moves file pointer past ENDM directive.

               asmMacro -
                   for (each line of macro) {
                     if macro label, define
                     perform parameter substitution
                     assemble this line of macro
                   }

               tokenize - Tokenize a string to tokens[].
               Each element of token[] is a pointer to the corresponding
               token in tokens[].  is always reserved for the label
               if any. A value of 0 in token[] indicates no token.
               Each token is null terminated.
               Each token is converted to upper case.


       Author: Charles Kelly
               Feb-13-2002
               Monroe County Community College
 *             http://www.wowgwep.com/EASy68K.htm

 ************************************************************************/


#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include "asm.h"

extern char line[256];		// Source line
extern FILE *inFile;            // source file
extern FILE *listFile;		// Listing file
extern FILE *errFile;		// error message file
extern FILE *tmpFile;
extern bool listFlag;
extern bool continuation;	// TRUE if the listing line is a continuation
extern char pass;		// pass counter
extern bool pass2;		// Flag set during second pass
extern int loc;		        // The assembler's location counter
extern int lineNum;
extern int errorCount, warningCount;
extern int labelNum;            // macro label \@ number
extern bool MEXflag;            // true expands macro listing
extern bool skipList;           // true to skip listing line in ASSEMBLE.CPP
extern char empty[];            // used in conditional assembly
extern bool skipCond;           // true skips lines in macro
extern bool printCond;          // true to print condition on listing line
extern int nestLevel;           // nesting level of conditional directives
extern bool skipCreateCode;     // true to skip calling createCode during macro processing

int macroFP;                    // location of current macro in tmpFile
const int MAC_SIZE = 512;       // maximun size of macro line
int macroNestLevel;             // count nested macro calls
char lineIdent[MACRO_NEST_LIMIT+2];  // "mmm" used to identify macro in listing + 1 for 's' when structured code is called from macro and +1 for '\0'
bool noENDM;                    // set true if no ENDM in macro

//--------------------------------------------------------
// Define macro
// Save file pointer to macro, define macro name, move file pointer
//  past ENDM directive.
int macro(int size, char *label, char *op, int *errorPtr)
{
  symbolDef *symbol;
  int error;
  const int MAXT = 128;           // maximum number of tokens
  char *token[MAXT];              // pointers to tokens
  char tokens[MAC_SIZE];          // place tokens here

  if (size)
    NEWERROR(*errorPtr, INV_SIZE_CODE);
  error = OK;

  fseek(tmpFile,0,SEEK_END);    // prepare tmpFile to receive next macro

  if (pass == 0)
    macroFP = ftell(tmpFile);           // save location of macro in tempFile
  // put macro and it's file pointer in symbol table
  symbol = define(label, macroFP, pass2, true, &error);
  if (error == MULTIPLE_DEFS) {         // ignore all errors except MULTIPLE_DEFS
    NEWERROR(*errorPtr, MULTIPLE_DEFS);
    return NORMAL;
  }
  symbol->flags |= MACRO_SYM;         // set MACRO_SYM flag

  if (pass2 && listFlag)
    listLine(line);

  // move file pointer past ENDM directive
  while(fgets(line, 256, inFile)) {
    if (pass == 0)
      fprintf(tmpFile, line);           // write macro line to tmpFile
    lineNum++;
    tokenize(line, " \t\n", token, tokens);
    if(!(stricmp(token[1], "MACRO"))) { // if unexpected MACRO opcode
      NEWERROR(*errorPtr, NO_ENDM);     // no ENDM found
      noENDM = true;
      return NULL;
    }
    if(!(stricmp(token[1], "ENDM")))     // if ENDM opcode
      return NORMAL;
    if (pass2 && listFlag)
      listLine(line);
  }
  NEWERROR(*errorPtr, NO_ENDM);         // no ENDM found
  noENDM = true;
  return NULL;
}


//--------------------------------------------------------
// Assemble macro
// pre: macroFP contains file pointer to macro
// for (each line of macro) {
//   if macro label, define
//   perform parameter substitution
//   assemble this line of macro
// }
int asmMacro(int size, char *label, char *arg, int *errorPtr)
{
  char capLine[256], macLine[MAC_SIZE], labelNumA[16];
  char *capL, *macL;
  char arguments[MAX_ARGS][ARG_SIZE+1];
  const int MAXT = 128;           // maximum number of tokens
  const int MAX_SIZE = 512;       // maximun size of input line
  char *token[MAXT];              // pointers to tokens
  char tokens[MAX_SIZE];          // place tokens here
  char *tokenEnd[MAXT];           // where tokens end in source line
  int error, argN, i, n;
  int tempFP;                           // temporary File Pointer
  int value;
  bool backRef;
  bool textArg;                         // true for 'text' argument
  bool endmFlag;                  // set true by ENDM instruction

  // clear arguments[] array
  for (argN=0; argN < MAX_ARGS; argN++) // for all of arguments[] array
    arguments[argN][0] = '\0';

  // *ck 12-6-2005 added following to support size extensions on macro calls.
  // Argument \0 is reserved for size and defaults to .W

  switch (size) {
    case BYTE_SIZE:
      strcpy(arguments[0],"B");
      break;
    case WORD_SIZE:
      strcpy(arguments[0],"W");
      break;
    case LONG_SIZE:
      strcpy(arguments[0],"L");
      break;
    default:
      strcpy(arguments[0],"W");
  }
  argN = 0;

  macroNestLevel++;                     // count nested macro calls
  if (macroNestLevel > MACRO_NEST_LIMIT) {  // if nested too deep
    NEWERROR(*errorPtr, MACRO_NEST);    // error, probably in recursive macro call
    macroNestLevel--;                   // count nested macro calls
    return NORMAL;
  }

  // build macro "mmm" identifier for listing
  for (i=0; i < macroNestLevel; i++)
    lineIdent[i] = 'm';
  lineIdent[i] = '\0';

  // Define the label attached to this macro call, if any
  if (*label)
    define(label, loc, pass2, true, errorPtr);

  // parse macro call and put arguments into array
  strcap(capLine, arg);
  capL = capLine;
  if (*capL)
    argN = 1;

  while (*capL) {                       // loop until out of arguments
    i = 0;
    textArg = false;
    while ( *capL && ( (*capL != ',' && !(isspace(*capL)) ) || textArg )) {
      if (*capL == '<') {               // if <         *ck 12-7-2005
        if (!textArg)                   // if not text mode
          textArg = true;               // set text mode flag
        else
          arguments[argN][i++] = *capL; // copy < to argument
      } else if (*capL == '>') {
        if (textArg)                    // if text mode
          textArg = false;              // turn off text mode
        else
          arguments[argN][i++] = *capL; // copy > to argument
      } else if (!textArg && (*capL == '\'' && *(capL+1) == '\'')) // if ''
        capL++;                         // skip ' (NULL Argument)
      else if (i < ARG_SIZE && *capL != '\n')
        arguments[argN][i++] = *capL;   // put argument in arguments[]
      capL++;
    }
    arguments[argN][i] = '\0';          // terminate argument

    if (*capL == ',') {                 // if more arguments remain
      capL++;                           // skip ','
      if (*capL == '\n') {              // if ',' was last char on line
        // macro parameters continue on next line
        if (pass2) {
          if (listFlag) {
            printError(listFile, *errorPtr, lineNum);
            if (!skipList)
              listLine(line, lineIdent);
          } else {
            printError(NULL, *errorPtr, lineNum);
          }
        }

        if (fgets(line, 256, inFile) == NULL) {      // get next line
          NEWERROR(*errorPtr, INVALID_ARG);
          macroNestLevel--;               // count nested macro calls
          return NORMAL;
        }
        strcap(capLine, line);
        capL = capLine;
        error = OK;
        continuation = false;

        if (pass2 && listFlag)
          listLoc();
        if (*capL != '&') {             // continuation line must start with '&'
          NEWERROR(*errorPtr, INVALID_ARG);
          macroNestLevel--;               // count nested macro calls
          return NORMAL;
        }
        *capL++;
      }

      capL = skipSpace(capL);           // skip spaces
      if (!(*capL)) {                   // if syntax error
        NEWERROR(*errorPtr, SYNTAX);
        macroNestLevel--;               // count nested macro calls
        return NORMAL;
      }
      argN++;                           // next spot in arguments[]
      if (argN >= MAX_ARGS) {           // if too many arguments
        NEWERROR(*errorPtr, TOO_MANY_ARGS);
        macroNestLevel--;               // count nested macro calls
        return NORMAL;
      }
    }
    else break;
  }

  if (pass2 && listFlag && !skipList) {   // if macro call should be listed
    listLoc();
    listLine(line, lineIdent);
  }

  // position tempFile to macro definition
  fseek(tmpFile, macroFP, SEEK_SET);   // move to macro definition

  // send each line of macro to assembler
  labelNum++;                           // increment macro label number
  itoa(labelNum, labelNumA, 10);        // convert labelNum to string
  endmFlag = false;
  while(!endmFlag && fgets(line, 256, tmpFile)) {
    strcap(capLine, line);
    tokenize(capLine, ", \t\n", token, tokens); // tokenize line

    error = OK;
    skipList = false;
    printCond = false;
    macL = macLine;
    capL = capLine;
    while(*capL && isspace(*capL))              // copy spaces
      *macL++ = *capL++;
    if (*capL == '*') {                         // if comment line
      while(*capL)                              // copy rest of line
        *macL++ = *capL++;
    } else {                                    // else not comment line

      if (skipCond)                     // if code conditionally skipped
        while(*capL)
          *macL++ = *capL++;            // just copy line to check for ENDC
      else {                            // else, include code
        // do macro parameter substitution and label generation
        while (*capL) {                         // while not empty
          while (*capL && !(isspace(*capL))) {  // while not empty and not space
            if (*capL == '\\') {                // if macro label or parameter
              capL++;
              if (*capL == '@') {               // if \@ macro label
                capL++;
                *macL++ = '_';                  // add '_'
                i = 0;                          // add labelNum to macro label
                while(labelNumA[i]) {
                  *macL++ = labelNumA[i++];
                }
              } else if (isalnum(*capL)) {      // if alpha numeric
                n = -1;
                if (isdigit(*capL))             // if parameter \0 - \9
                  n = *capL++ - '0';         // convert parameter to integer
                else if (*capL >= 'A' && *capL <= 'Z')  // if parameter \A - \Z
                  n = *capL++ - 'A' + 10;    // convert parameter to integer
                else                            // invalid argument
                  NEWERROR(error, INVALID_ARG);
                if (n >= 0 && n < MAX_ARGS) {   // if valid argument number
                  i = 0;
                  while(arguments[n][i]) {
                    *macL++ = arguments[n][i++];
                  }
                } else
                  NEWERROR(error, INVALID_ARG);
              } else
                NEWERROR(error, SYNTAX);
            // if NARG opcode
            //} else if( !(stricmp(token[1], "NARG")) ) {
            } else if( !(strnicmp(capL, "NARG", 4)) && !(isalnum(*(capL+4))) ) {            
              sprintf(macL,"%d",argN);
              if (argN > 9)
                macL++;
              macL++;
              capL += 4;
            } else {
              *macL++ = *capL++;        // copy macro line
            }
          }
          while(*capL && isspace(*capL))  // copy spaces
            *macL++ = *capL++;
        }
      } // end else, include code
    } // end if comment, else not comment

    *macL = '\0';

    tempFP = ftell(tmpFile); // save current file position to support nested macros *ck 12-1-2005
    continuation = false;
    strcpy(line,macLine);   // replace original source line with macro line
    if (!MEXflag)
      skipList = true;

    skipCreateCode = false;

    // pre process macro commands
    // ----- ENDM and MEXIT -----
    if( !(stricmp(token[1], "ENDM")) ||         // if ENDM opcode or
        (!(stricmp(token[1],"MEXIT"))) && !skipCond) { // MEXIT
      if (token[0] != empty)                    // if label present
        NEWERROR(*errorPtr, LABEL_ERROR);
      endmFlag = true;
      skipCreateCode = true;

    // ----- IFARG -----
    } else if(!(stricmp(token[1], "IFARG"))) {  // if IFARG opcode
      if (token[0] != empty)                    // if label present
        NEWERROR(*errorPtr, LABEL_ERROR);
      if (token[2] == empty) {                  // if IFARG argument missing
        NEWERROR(*errorPtr, INVALID_ARG);
      } else {
        eval(token[2], &value, &backRef, &error);
        //value--;
        if (error < ERRORN && value > 0 && value < MAX_ARGS) { // if valid arg number
          if (arguments[value][0] == '\0') { // if argument does not exist
            skipCond = true;                // skip lines in macro
            nestLevel++;                    // nest level of skip
          }
        } else {                            // else, invalid arg number
          NEWERROR(*errorPtr, INVALID_ARG);
        }
      }
      printCond = true;
      skipCreateCode = true;
    }

    if(!noENDM)                 // if no missing ENDM errors
      assemble(line,&error);    // this supports structured statements in macros

    macroFP = tempFP;       // restore macroFP
    fseek(tmpFile, macroFP, SEEK_SET);      // position tmpFile to previous spot *ck 12-1-2005

  } // end while more lines of macro remain

  skipCreateCode = false;

  macroNestLevel--;             // count nested macro calls
  // build macro "mmm" identifier for listing
  for (i=0; i < macroNestLevel; i++)
    lineIdent[i] = 'm';
  lineIdent[i] = '\0';

  skipList = true;              // don't display ENDM twice
  return NORMAL;
}


