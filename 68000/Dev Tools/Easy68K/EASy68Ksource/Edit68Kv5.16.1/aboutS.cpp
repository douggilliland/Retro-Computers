//---------------------------------------------------------------------------
//   Author: Charles Kelly,
//           Monroe County Community College
//           http://www.monroeccc.edu/ckelly
//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop

#include "aboutS.h"
#include "asm.h"

//--------------------------------------------------------------------- 
#pragma resource "*.dfm"
TAboutBox *AboutBox;
//--------------------------------------------------------------------- 
__fastcall TAboutBox::TAboutBox(TComponent* AOwner)
	: TForm(AOwner)
{
}
//---------------------------------------------------------------------

void __fastcall TAboutBox::FormCreate(TObject *Sender)
{
  AboutBox->Title->Caption = AnsiString(TITLE);
  Panel1->DoubleBuffered = true;
}
//---------------------------------------------------------------------------

void __fastcall TAboutBox::FormKeyPress(TObject *Sender, char &Key)
{
  static char lastKey = ' ';
  switch (toupper(Key)) {
    case 'B':
      lastKey = 'B';
      break;
    case 'M':
      if (lastKey == 'B')
        lastKey = 'M';
      else
        lastKey = ' ';
      break;
    case 'W':
      if (lastKey == 'M')
      {
        Timer1->Enabled = true;
        img->Visible = true;
        img->Top = 40;
        img->Left = -160;
      }
    default:
      lastKey = ' ';
  }
}
//---------------------------------------------------------------------------

void __fastcall TAboutBox::Timer1Timer(TObject *Sender)
{
    img->Left += 10;
    if (img->Left > AboutBox->Width) {
      img->Visible = false;
      Timer1->Enabled = false;
    }
}
//---------------------------------------------------------------------------


void __fastcall TAboutBox::Label1Click(TObject *Sender)
{
    ShellExecute(NULL,"open", "http://www.easy68k.com", NULL, NULL, SW_SHOW);
}
//---------------------------------------------------------------------------

void __fastcall TAboutBox::Label1MouseEnter(TObject *Sender)
{
    Panel1->Cursor = crHandPoint;
}
//---------------------------------------------------------------------------

void __fastcall TAboutBox::Label1MouseLeave(TObject *Sender)
{
    Panel1->Cursor = crArrow;
}
//---------------------------------------------------------------------------

void __fastcall TAboutBox::CheckButtonClick(TObject *Sender)
{
    try{
    VersionLabel->Font->Style = TFontStyles() << fsBold;
    NMHTTP1->Get("http://www.easy68k.com/version.txt");
    if(NMHTTP1->Body == VERSION)
        VersionLabel->Caption = "Up to date";
    else
        VersionLabel->Caption = "Update available";
    }catch(...){
        VersionLabel->Caption = "Network error";
    }
}
//---------------------------------------------------------------------------

void __fastcall TAboutBox::NMHTTP1Failure(CmdType Cmd)
{
   VersionLabel->Caption = "Network error";
}
//---------------------------------------------------------------------------


void __fastcall TAboutBox::NMHTTP1InvalidHost(bool &Handled)
{
   VersionLabel->Caption = "Network error";
}
//---------------------------------------------------------------------------

void __fastcall TAboutBox::NMHTTP1ConnectionFailed(TObject *Sender)
{
   VersionLabel->Caption = "Network error";
}
//---------------------------------------------------------------------------

