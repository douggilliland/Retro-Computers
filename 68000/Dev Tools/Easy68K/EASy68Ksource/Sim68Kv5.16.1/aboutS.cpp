//---------------------------------------------------------------------------
//   Author: Charles Kelly
//           www.easy68k.com
//---------------------------------------------------------------------------

//---------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop

#include "aboutS.h"
#include "def.h"
#include "SIM68Ku.h"


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

