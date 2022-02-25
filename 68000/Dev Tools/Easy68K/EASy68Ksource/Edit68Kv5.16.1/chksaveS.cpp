//---------------------------------------------------------------------------
//   Author: Charles Kelly,
//           Monroe County Community College
//           http://www.monroeccc.edu/ckelly
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "chksaveS.h"
#include "mainS.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TChkSave *ChkSave;
//---------------------------------------------------------------------------
__fastcall TChkSave::TChkSave(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TChkSave::FormCreate(TObject *Sender)
{
  lblMessage->Caption = "Source has been modified. Save before exiting?";
  ChkSave->Caption = "Save source file?";        
}
//---------------------------------------------------------------------------
void __fastcall TChkSave::btnOKClick(TObject *Sender)
{
  Main->mnuSaveClick(Sender);
  ChkSave->Close();
}
//---------------------------------------------------------------------------
void __fastcall TChkSave::Button2Click(TObject *Sender)
{
  ChkSave->Close();
}
//---------------------------------------------------------------------------
