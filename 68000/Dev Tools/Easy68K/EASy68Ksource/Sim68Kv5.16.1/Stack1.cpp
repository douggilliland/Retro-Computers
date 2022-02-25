//---------------------------------------------------------------------------
//   Author: Chuck Kelly,
//           Monroe County Community College
//           http://www.monroeccc.edu/ckelly
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "Stack1.h"
#include "extern.h"
#include "SIM68Ku.h"
#include "hardwareu.h"


//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "CSPIN"
#pragma resource "*.dfm"

extern int ProtectedStart, ProtectedEnd, InvalidStart, InvalidEnd;
extern bool ROMMap, ReadMap, ProtectedMap, InvalidMap;

TStackFrm *StackFrm;

int stackTextX, stackTextY;

int stackRowHeight, stackColWidth;        // row height and col width of text
int stackAddr, midAddr, A7stackAddr, AregAddr;

//---------------------------------------------------------------------------
__fastcall TStackFrm::TStackFrm(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TStackFrm::FormCreate(TObject *Sender)
{
  stackAddr = A[8];
  stackAddr -= stackAddr%2;     // force even address
  midAddr = stackAddr;
  stackRowHeight = Canvas->TextHeight("Xp");
  stackColWidth  = Canvas->TextWidth("W");
}
//---------------------------------------------------------------------------

void __fastcall TStackFrm::FormPaint(TObject *Sender)
{
  DisplayStack();
}
//---------------------------------------------------------------------------


void __fastcall TStackFrm::FormResize(TObject *Sender)
{
  DisplayStack();
}

//---------------------------------------------------------------------------
void __fastcall TStackFrm::updateDisplay()
{
  stackAddr = A[whichStack->ItemIndex];
  AregAddr = stackAddr;
  stackAddr -= stackAddr%2;     // force even address
  midAddr = stackAddr;
  DisplayStack();
}

//---------------------------------------------------------------------------
void __fastcall TStackFrm::DisplayStack()
{
  AnsiString str;
  TPoint scrPos;
  int nRows, midRow, dispAddr;

  dispAddr = midAddr;
  A7stackAddr = A[a_reg(7)] & ADDRMASK;  // address of current system stack

  // erase bottom row
  TRect BotRect = Rect(0,ClientHeight - stackRowHeight,ClientWidth,ClientHeight);
  Canvas->CopyMode = cmPatPaint;         // erase
  Canvas->CopyRect(BotRect, Canvas, BotRect);
  Canvas->CopyMode = cmSrcCopy;

  // how many rows of text will fit?
  nRows = ClientHeight/stackRowHeight;
  // which address is at top of display when stack pointer is in middle?
  midRow = nRows/2;
  dispAddr = (dispAddr - midRow * 4) & ADDRMASK;

  // display stack by rows of 4 bytes
  stackTextX = stackTextY = 0;
  for (int r=0; r<nRows; r++) {
    Canvas->Brush->Color = clWhite;
    Canvas->TextOutA(stackTextX, stackTextY,(str.sprintf ("%08X: ",dispAddr)));
    scrPos = Canvas->PenPos;
    for (int i=0; i<4; i++) {
     // if Invalid memory area
      if(InvalidMap && (dispAddr+i >= InvalidStart) && (dispAddr+i <= InvalidEnd))
        Canvas->Font->Color = clRed;

      if(dispAddr+i == AregAddr)                // if address of current A reg
        Canvas->Brush->Color = clAqua;
      else if (dispAddr+i == A7stackAddr)       // if address of system stack
        Canvas->Brush->Color = clYellow;
      else
        Canvas->Brush->Color = clWhite;

      Canvas->TextOutA(scrPos.x, scrPos.y,
      (str.sprintf ("%02hX ",(unsigned char)memory[dispAddr+i & ADDRMASK] )));
      scrPos = Canvas->PenPos;
      Canvas->Font->Color = clBlack;
    }
    dispAddr += 4;
    dispAddr &= ADDRMASK;
    stackTextY += stackRowHeight;
  }
}
//---------------------------------------------------------------------------


void __fastcall TStackFrm::whichStackChange(TObject *Sender)
{
  updateDisplay();
}
//---------------------------------------------------------------------------


void __fastcall TStackFrm::FormShow(TObject *Sender)
{
  updateDisplay();
}
//---------------------------------------------------------------------------

void __fastcall TStackFrm::CSpinButton1UpClick(TObject *Sender)
{
  midAddr -= 4;               // display lower address
  DisplayStack();
}
//---------------------------------------------------------------------------

void __fastcall TStackFrm::CSpinButton1DownClick(TObject *Sender)
{
  midAddr += 4;               // display higher address
  DisplayStack();
}
//---------------------------------------------------------------------------

void __fastcall TStackFrm::FormMouseWheelDown(TObject *Sender,
      TShiftState Shift, TPoint &MousePos, bool &Handled)
{
  midAddr += 4;               // display higher address
  DisplayStack();
}
//---------------------------------------------------------------------------

void __fastcall TStackFrm::FormMouseWheelUp(TObject *Sender,
      TShiftState Shift, TPoint &MousePos, bool &Handled)
{
  midAddr -= 4;               // display lower address
  DisplayStack();
}
//---------------------------------------------------------------------------

void __fastcall TStackFrm::FormKeyDown(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
   if (Key == VK_F1)
     Form1->displayHelp("STACK");
   else if (Key == VK_TAB && Shift.Contains(ssCtrl))    // if Ctrl-Tab
     Hardware->BringToFront();
}
//---------------------------------------------------------------------------

void __fastcall TStackFrm::BringToFront()
{
  if(StackFrm->Visible)
    StackFrm->SetFocus();
  else
    Hardware->BringToFront();
}
//---------------------------------------------------------------------------



