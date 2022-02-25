//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "fontForm1.h"
#include "mainS.h"
#include "textS.h"

//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TfontForm *fontForm;
//---------------------------------------------------------------------------
__fastcall TfontForm::TfontForm(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TfontForm::cmdCloseClick(TObject *Sender)
{
  Close();
}

//---------------------------------------------------------------------------
void __fastcall TfontForm::cmdChangeClick(TObject *Sender)
{
  TTextStuff *Active = (TTextStuff*)Main->ActiveMDIChild;
  Active->SourceText->Font->Name = cbFont->Text;
  Active->SourceText->Font->Size = StrToInt(cbSize->Text);
  fontForm->currentFont->Text = Active->SourceText->Font->Name;
  fontForm->currentSize->Text = IntToStr(Active->SourceText->Font->Size);
}

//---------------------------------------------------------------------------
void __fastcall TfontForm::FormShow(TObject *Sender)
{
  //grab active mdi child
  TTextStuff *Active = (TTextStuff*)Main->ActiveMDIChild;
  fontForm->currentFont->Text = Active->SourceText->Font->Name;
  fontForm->currentSize->Text = IntToStr(Active->SourceText->Font->Size);
}
//---------------------------------------------------------------------------
void __fastcall TfontForm::cbFontChange(TObject *Sender)
{
  cbSize->Items->Clear();
  if (cbFont->Text == "Fixedsys") {
    cbSize->Items->Add("9");
    cbSize->Items->Add("18");
  } else if (cbFont->Text == "Courier") {
    cbSize->Items->Add("10");
    cbSize->Items->Add("12");
    cbSize->Items->Add("15");
  } else {               // Courier New
    cbSize->Items->Add("8");
    cbSize->Items->Add("9");
    cbSize->Items->Add("10");
    cbSize->Items->Add("11");
    cbSize->Items->Add("12");
    cbSize->Items->Add("14");
    cbSize->Items->Add("16");
    cbSize->Items->Add("18");
  }
}
//---------------------------------------------------------------------------
