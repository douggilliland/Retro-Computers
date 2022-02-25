//---------------------------------------------------------------------------
//   Author: Chuck Kelly,
//           http://www.easy68k.com
//---------------------------------------------------------------------------
// File Name: help.cpp
// HTML help.
// EASyBIN binary file creation and editing utility for EASy68K
//---------------------------------------------------------------------------

#pragma hdrstop
#include <string.h>
#include "help.h"
#include "ez68k.h"
#pragma package(smart_init)

//------------------------------------------------------------------------

typedef struct {
  char   *name;
  int    id;
} idh_cont;


idh_cont context[] = {
        {"EASyBIN",		IDH_EASYBIN},
        {"CREDITS",		IDH_CREDITS},
        {"CHUCK",		IDH_CREDITS},
        };

// Declare a global variable containing the size of the context table

int contextSize = sizeof(context)/sizeof(idh_cont);

//---------------------------------------------------------------------------
// returns context ID for HTML help
int __fastcall getHelpContext(char* str)
{
  int i, cmp;
  int contextID;

  // search for help context in context table
  i = 0;
  do {
    cmp = strcmpi(str, context[i].name);
    i++;
  } while (cmp && (i < contextSize));

  // if context found
  if (!cmp)
    contextID = context[i-1].id;
  else                  // else, context not found
    contextID = 1000;   // use INTRO contextID

  return contextID;
}
