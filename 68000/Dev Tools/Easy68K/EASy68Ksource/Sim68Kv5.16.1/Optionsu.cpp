//---------------------------------------------------------------------------
//   Author: Chuck Kelly,
//           Monroe County Community College
//           http://www.monroeccc.edu/ckelly
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "Optionsu.h"
#include "SIM68Ku.h"

//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TAutoTraceOptions *AutoTraceOptions;
//---------------------------------------------------------------------------
__fastcall TAutoTraceOptions::TAutoTraceOptions(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TAutoTraceOptions::OKClick(TObject *Sender)
{
  Form1->AutoTraceTimer->Interval = StrToInt(AutoTraceInterval->Text);
  Close();        
}
//---------------------------------------------------------------------------

void __fastcall TAutoTraceOptions::CancelClick(TObject *Sender)
{
  Close();        
}
//---------------------------------------------------------------------------

