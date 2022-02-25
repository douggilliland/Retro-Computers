//---------------------------------------------------------------------------
#ifndef undoH
#define undoH
//---------------------------------------------------------------------------
#include <ComCtrls.hpp>
#include <vcl.h>
#include <StrUtils.hpp>
#include <stdio.h>
#include "textS.h"
//---------------------------------------------------------------------------

#define UNDO_NOP    'n'         // no op
#define UNDO_MARK   'x'         // beginning
#define UNDO_ADD    'a'         // added line
#define UNDO_DEL    'd'         // deleted line
#define UNDO_MOD    'm'         // modified
#define UNDO_BLOCK  0x80        // continuation
#define UNDO_CHAR   'c'         // added char
#define UNDO_MOVE   'v'         // moved cursor (explicit)
#define UNDO_SEP    's'         // separator or delimiter

const int UNDO_LIMIT = 10000;

// function prototypes
void SaveUndo(TTextStuff *v1, int tpe, int row, int col, AnsiString str);
void SaveRedo(TTextStuff *v1, int tpe, int row, int col, AnsiString str);
void UnDo(TTextStuff *v1);
void ReDo(TTextStuff *v1);
void exec_undo(TTextStuff *v1, int cc, int dd, int ee, int ff, AnsiString &str);
void WorkUndo(TTextStuff *v1, int redo);

#endif
