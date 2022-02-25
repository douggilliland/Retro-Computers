/***********************************************************************
 *
 *		SYMBOL.CPP
 *		Symbol Handling Routines for 68000 Assembler
 *
 *
 *      Author: Paul McKee
 *		ECE492    North Carolina State University
 *
 *        Date:	11/28/86
 *
 *    Modified: Charles Kelly
 *              Monroe County Community College
 *              http://www.monroeccc.edu/ckelly
 *
 ************************************************************************/


#include <stdio.h>
#include <ctype.h>
#include "mainS.h"
#include "textS.h"
#include "asm.h"

extern FILE *listFile;
extern char buffer[256];  //ck used to form messages for display in windows
extern char numBuf[20];
extern char globalLabel[SIGCHARS+1];


/* MAXHASH is the range of the hash function. hash()
   returns values from 0 to MAXHASH inclusive. */

#define MAXHASH 26

symbolDef *htable[MAXHASH+1];
bool symbolInit = false;

//---------------------------------------------------
// delete the symbol table memory
void clearSymbols()
{
  symbolDef *last, *s;         //last, symbol;

  try {
  for (int i=0; i<=MAXHASH; i++) {      // for all values of hash()
    s = htable[i];
    if (s) {
      htable[i] = NULL;         // clear pointer
      while (s) {               // while symbols remain in the list
        last = s;
        s = s->next;
        delete last;            // delete symbol from memory
      }
    }
  }
  symbolInit = false;
  }
  catch( ... ) {
    sprintf(buffer, "ERROR: An exception occurred in routine 'clearSymbols'. \n");
    printError(NULL, EXCEPTION, 0);
  }
}

//--------------------------------------------------------------------------
//    Function: lookup()
//		Searches the symbol table for a previously defined
//		symbol or creates a new symbol. The routine functions
//		as follows:
//
//		Symbol
//		Found				  Returned
//		In	Create	  Action	  Error
//		Table?  Flag	  Taken		  Code
//		------  ------    --------------  -----------
//		  N     FALSE     None		  UNDEFINED
//		  N     true      Symbol created  OK
//      	  Y     FALSE     None		  OK
//		  Y	true      None		  MULTIPLE_DEFS
//
//		In addition, the routine always returns a pointer to
//		the structure (type symbolDef) which contains the
//		symbol that was found or created. The routine uses a
//		hash function to index into an array of pointers to
//		ordered linked lists of symbol definitions.
//
//	 Usage:	symbolDef *lookup(sym, create, errorPtr)
//		char *sym;
//		int create, *errorPtr;

symbolDef *lookup(char *sym, int create, int *errorPtr)
{
  int h, cmp;
  symbolDef *s, *last, *t;
  char sym2[SIGCHARS+1];        // CK for local labels
  int i, j;

  try {

  // Local label code  CK May-22-2009 mod Sep-23-2009
  // Local labels begin with '.'
  // A local label is converted to a unique label here by appending the
  // local label to the last global label stored in globalLabel.
  // Simple name mangling is done by replacing . with : to prevent
  // duplicate symbol errors with user created labels and to prevent labels
  // that contain dots in the middle of the label that confuses the parser
  // because of the .L that may be used to force long addressing with labels.
  // The new unique label takes the form of global:local.
  if (*sym == '.') {            // if local label
    *sym = ':';
    i = 0;
    j = 0;
    while(i<SIGCHARS && globalLabel[i] != '\0') {
      sym2[i] = globalLabel[i]; // make unique global label from local label
      i++;
    }
    while(i<SIGCHARS && sym[j])
      sym2[i++] = sym[j++];
    sym2[i] = '\0';
    if (i >= SIGCHARS)
      NEWERROR(*errorPtr, LABEL_TOO_LONG);

    strcpy(sym, sym2);
  }

  if (!symbolInit) {
    for (h = 0; h <= MAXHASH; h++)
      htable[h] = 0;
    symbolInit = true;
  }
  h = hash(sym);
  s = htable[h];
  if (s) {
    // Search the linked list for a matching symbol
    last = NULL;
    while (s && (cmp = strcmp(s->name, sym)) < 0) {
      last = s;
      s = s->next;
    }
    // If a match was found, return pointer to the structure
    if (s && !cmp) {
      if (create) {
        if (!(s->flags & REDEFINABLE))  // if not SET directive (CK 10/12/2009)
 	  NEWERROR(*errorPtr, MULTIPLE_DEFS);
      }
      t = s;
    }
    // Otherwise insert the symbol in the list
    else if (create)
      if (last) {
	// The symbol goes after an existing symbol
	t = new symbolDef;
	last->next = t;
	t->next = s;
	strcpy(t->name, sym);
      } else {
	/* The symbol goes at the head of a list */
	t = new symbolDef;
	t->next = htable[h];
	htable[h] = t;
	strcpy(t->name, sym);
      }
    else
      NEWERROR(*errorPtr, UNDEFINED);
  } else if (create) {
    t = new symbolDef;
    htable[h] = t;
    t->next = NULL;
    strcpy(t->name, sym);
  } else
    NEWERROR(*errorPtr, UNDEFINED);

  }
  catch( ... ) {
    NEWERROR(*errorPtr, EXCEPTION);
    sprintf(buffer, "ERROR: An exception occurred in routine 'lookup'. \n");
    return NULL;
  }
  return t;
}

//----------------------------------------------
// Write the symbol table to the listing file
int optCRE()
{
  symbolDef *s;         //, *last;
  int bytes;

  fprintf(listFile, "\n\nSYMBOL TABLE INFORMATION\n");
  fprintf(listFile, "Symbol-name         Value\n");
  fprintf(listFile, "-------------------------\n");

  for (int i=0; i<=MAXHASH; i++) {      // for all values of hash()
    s = htable[i];
    if (s) {
      //last = NULL;
      while (s) {               // while symbols remain in the list
        //last = s;
        //fprintf(listFile, "%s\t\t%X\n",s->name, s->value);
        bytes = fprintf(listFile, "%s",s->name);
        // print value in column 20 or 2 spaces after label if label >= 18 chars
        while (bytes++ < 18)
          fprintf(listFile, " ");
        fprintf(listFile, "  %X\n",s->value);
        s = s->next;
      }
    }
  }
  return NORMAL;
}

//---------------------------------------------------------------------
// Return index for array of pointers to linked lists
// Returns 0 to MAXHASH inclusive based on first character of symbol.
int hash(char *symbol)
{
  if (isupper(*symbol))
    return (*symbol - 'A');
  else
    return MAXHASH;
}


//----------------------------------------------------------------------
//	define()
//	Defines the symbol whose name is specified to have the
//	value specified. If check is true, then the symbol is
//	is assumed to already exist and its value is checked
//	against the passed value; a PHASE_ERROR results if the
//	values are not the same. When check is true the routine
//	also sets the backRef bit for the symbol. If check is
//	FALSE, then the symbol is defined and its value is set
//	equal to the supplied number. The function returns a
//	pointer to the symbol definition structure.
//
//      Usage:	symbolDef *define(sym, value, pass2, check, errorPtr)
//      	char *sym;
//      	int value, check, *errorPtr;

symbolDef *define(char *sym, int value, bool pass2, bool check, int *errorPtr) {
  symbolDef *symbol;
  bool labelIsGlobal = (*sym != '.');   // local label code CK Sep-23-2009

  symbol = lookup(sym, !pass2, errorPtr);
  if (*errorPtr < ERRORN) {

    // local label code CK Sep-23-2009
    if (labelIsGlobal)
      strncpy(globalLabel, sym, SIGCHARS); // set globalLabel for future use

    if (pass2) {
      if (check) {      // if check for phase error
        if (symbol->value != value)
          if (symbol->flags & BACKREF)  // if symbol already defined
            NEWERROR(*errorPtr, MULTIPLE_DEFS);
          else
            NEWERROR(*errorPtr, PHASE_ERROR);
      }
      symbol->flags |= BACKREF;       // mark symbol as defined
      if (symbol->flags & REDEFINABLE)  // ck 1-10-2008
        symbol->value = value;          //  "
    } else {  // define the symbol
      symbol->value = value;
      symbol->flags = 0;
    }
  }
  return symbol;
}

