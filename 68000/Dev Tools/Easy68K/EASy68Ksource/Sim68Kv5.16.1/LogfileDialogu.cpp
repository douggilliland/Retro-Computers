//---------------------------------------------------------------------------
//   Author: Chuck Kelly,
//           Monroe County Community College
//           http://www.monroeccc.edu/ckelly
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "LogfileDialogu.h"
#include "extern.h"

//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TLogfileDialog *LogfileDialog;
//---------------------------------------------------------------------------
__fastcall TLogfileDialog::TLogfileDialog(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------

void __fastcall TLogfileDialog::setMessage(AnsiString str)
{
  Message->Caption = str;
}
