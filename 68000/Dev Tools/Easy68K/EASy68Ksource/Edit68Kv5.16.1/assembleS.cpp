//---------------------------------------------------------------------------
//   Author: Charles Kelly,
//           Monroe County Community College
//           http://www.monroeccc.edu/ckelly
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "assembleS.h"
#include "mainS.h"
#include "listS.h"
#include "textS.h"
#include "asm.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TAssemblerBox *AssemblerBox;
//---------------------------------------------------------------------------
__fastcall TAssemblerBox::TAssemblerBox(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TAssemblerBox::cmdExecuteClick(TObject *Sender)
{
  AnsiString sim68K, S68;

  //grab the active child window
  TTextStuff *Active = (TTextStuff*)Main->ActiveMDIChild;

  // get name of current S-Record file
  S68 = "\"" + ChangeFileExt(Active->Project.CurrentFile,".S68") + "\"";

  //run simulator
  sim68K = ExtractFilePath(Application->ExeName) + "SIM68K.EXE";
  spawnl(P_NOWAITO, sim68K.c_str(), ParamStr(0).c_str(), S68.c_str(), NULL);

  AssemblerBox->Close();
}
//---------------------------------------------------------------------------
void __fastcall TAssemblerBox::cmdCloseClick(TObject *Sender)
{
  AssemblerBox->Close();
}
//---------------------------------------------------------------------------

void __fastcall TAssemblerBox::FormClose(TObject *Sender,
      TCloseAction &Action)
{
  cmdExecute->Enabled = false;
}
//---------------------------------------------------------------------------

void __fastcall TAssemblerBox::FormShow(TObject *Sender)
{
  //grab the active child window
  TTextStuff *Active = (TTextStuff*)Main->ActiveMDIChild;

  Caption = "Assembler Status - " + ExtractFileName(Active->Project.CurrentFile);
  /*
  if(StrToInt(lblStatus->Caption) == 0 && StrToInt(lblStatus2->Caption = 0)
  {

  }
  */
}
//---------------------------------------------------------------------------

void __fastcall TAssemblerBox::cmdLoadL68Click(TObject *Sender)
{
  AnsiString L68;

  //grab the active child window
  TTextStuff *Active = (TTextStuff*)Main->ActiveMDIChild;

  // get name of current L68 file
  L68 = ChangeFileExt(Active->Project.CurrentFile,".L68");

  Main->OpenFile(L68);        // open specified file
  AssemblerBox->Close();
}
//---------------------------------------------------------------------------

