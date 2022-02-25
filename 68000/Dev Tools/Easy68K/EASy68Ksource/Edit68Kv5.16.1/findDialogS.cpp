//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "findDialogS.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TfindDialogFrm *findDialogFrm;
//---------------------------------------------------------------------------
__fastcall TfindDialogFrm::TfindDialogFrm(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TfindDialogFrm::findNextBtnClick(TObject *Sender)
{
  Main->FindDialogFind(findText->Text, wholeWordChk->Checked, matchCaseChk->Checked);
}
//---------------------------------------------------------------------------

void __fastcall TfindDialogFrm::cancelBtnClick(TObject *Sender)
{
  this->Close();
}

//---------------------------------------------------------------------------

void __fastcall TfindDialogFrm::findTextChange(TObject *Sender)
{
  if (findText->Text == "") {
    findNextBtn->Enabled = false;
    findNextBtn->Default = false;
  } else {
    findNextBtn->Enabled = true;
    findNextBtn->Default = true;
  }
}

//---------------------------------------------------------------------------

void __fastcall TfindDialogFrm::FormShow(TObject *Sender)
{
  if (findText->Text == "") {
    findNextBtn->Enabled = false;
    findNextBtn->Default = false;
  } else {
    findNextBtn->Enabled = true;
    findNextBtn->Default = true;
    findNextBtn->SetFocus();
  }
}
//---------------------------------------------------------------------------

