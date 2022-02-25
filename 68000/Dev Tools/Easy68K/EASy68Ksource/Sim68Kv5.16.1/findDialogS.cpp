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
  findNext = false;
}

//---------------------------------------------------------------------------
void __fastcall TfindDialogFrm::findNextBtnClick(TObject *Sender)
{
  Form1->find(findText->Text, findNext);
  findNext = true;      // search for next
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
  findNext = false;     // search from top
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
  findNext = false;     // search from top
}


void __fastcall TfindDialogFrm::FormKeyDown(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
   // if F3 AND Searching
   if(Key == VK_F3 && findDialogFrm->findText->Text != "")
     Form1->find(findText->Text, true);

}
//---------------------------------------------------------------------------

