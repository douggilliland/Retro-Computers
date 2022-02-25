//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "listS.h"
#include "mainS.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TListFile *ListFile;
//---------------------------------------------------------------------------
__fastcall TListFile::TListFile(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TListFile::FormClose(TObject *Sender, TCloseAction &Action)
{
  ListFile->DestroyWindowHandle(); //this will close the window

  
          
}
//---------------------------------------------------------------------------

void __fastcall TListFile::ListKeyDown(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  CurPos = List->CaretPos; //store posistion of cursor
  StatusBar->Panels->Items[0]->Text = "ln " +IntToStr(CurPos.y + 1)  + "  col " + IntToStr(CurPos.x + 1);
}
//---------------------------------------------------------------------------

void __fastcall TListFile::ListKeyPress(TObject *Sender, char &Key)
{
  CurPos = List->CaretPos; //store posistion of cursor
  StatusBar->Panels->Items[0]->Text = "ln " +IntToStr(CurPos.y + 1)  + "  col " + IntToStr(CurPos.x + 1);

}
//---------------------------------------------------------------------------

void __fastcall TListFile::ListKeyUp(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  CurPos = List->CaretPos; //store posistion of cursor
  StatusBar->Panels->Items[0]->Text = "ln " +IntToStr(CurPos.y + 1)  + "  col " + IntToStr(CurPos.x + 1);
        
}
//---------------------------------------------------------------------------


void __fastcall TListFile::ListMouseUp(TObject *Sender,
      TMouseButton Button, TShiftState Shift, int X, int Y)
{
  CurPos = List->CaretPos; //store posistion of cursor
  StatusBar->Panels->Items[0]->Text = "ln " +IntToStr(CurPos.y + 1)  + "  col " + IntToStr(CurPos.x + 1);
}
//---------------------------------------------------------------------------

void __fastcall TListFile::ListMouseDown(TObject *Sender,
      TMouseButton Button, TShiftState Shift, int X, int Y)
{
  CurPos = List->CaretPos; //store posistion of cursor
  StatusBar->Panels->Items[0]->Text = "ln " +IntToStr(CurPos.y + 1)  + "  col " + IntToStr(CurPos.x + 1);
}
//---------------------------------------------------------------------------

