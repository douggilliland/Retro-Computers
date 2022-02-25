//---------------------------------------------------------------------------
//   Author: Chuck Kelly,
//           http://www.easy68k.com
//---------------------------------------------------------------------------
// File Name: aboutS.cpp
// About dialog.
// EASyBIN binary file creation and editing utility for EASy68K
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "aboutS.h"
#include "def.h"
#include "Form1u.h"


//---------------------------------------------------------------------
#pragma resource "*.dfm"
TAboutFrm *AboutFrm;
//--------------------------------------------------------------------- 
__fastcall TAboutFrm::TAboutFrm(TComponent* AOwner)
	: TForm(AOwner)
{
}
//---------------------------------------------------------------------

void __fastcall TAboutFrm::FormShow(TObject *Sender)
{
  Title->Caption = TITLE;        
}
//---------------------------------------------------------------------------


void __fastcall TAboutFrm::FormKeyDown(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
   if (Key == VK_F1)
     Form1->displayHelp("CHUCK");
}
//---------------------------------------------------------------------------

