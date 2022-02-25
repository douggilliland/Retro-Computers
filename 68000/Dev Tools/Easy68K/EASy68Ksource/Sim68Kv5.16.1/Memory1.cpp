//---------------------------------------------------------------------------
//   Author: Chuck Kelly,
//           Monroe County Community College
//           http://www.monroeccc.edu/ckelly
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#include <vcl.h>
#include <fstream.h>
#pragma hdrstop

#include "Memory1.h"
#include "extern.h"
#include "SIM68Ku.h"
#include "hardwareu.h"
#include "Stack1.h"


//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "CSPIN"
#pragma resource "*.dfm"
TMemoryFrm *MemoryFrm;

// constants
const int HEX_LEFT  = 10;
const int HEX_RIGHT = 56;
const int ASC_RIGHT = 73;
const int ASC_LEFT  = 58;

extern AnsiString str;

unsigned int memAddr;

//---------------------------------------------------------------------------
__fastcall TMemoryFrm::TMemoryFrm(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TMemoryFrm::FormCreate(TObject *Sender)
{
  rowHeight = Canvas->TextHeight("Xp");
  colWidth  = Canvas->TextWidth("W");
}

//---------------------------------------------------------------------------
void __fastcall TMemoryFrm::Address1Change(TObject *Sender)
{
  try {
    str = "0x";
    memAddr = StrToInt(str + Address1->EditText);
    memAddr -= memAddr%16;      // force to $10 boundary
    Address1->Text = str.sprintf("%06lX",memAddr);
    nRows = (ClientHeight-Panel1->Height)/rowHeight;
    Repaint();
  }
  catch( ... ) {
    ShowMessage("Error in Address1Change()");
    return;
  }
}

//---------------------------------------------------------------------------
// diplays full screen of memory
void __fastcall TMemoryFrm::FormPaint(TObject *Sender)
{
  TPoint scrPos;
  int tX, tY;
  unsigned int addr = memAddr;

  //str = "0x";
  //addr = StrToInt(str + Address1->EditText);
  //addr -= addr%16;      // force to $10 boundary
  //Address1->Text = str.sprintf("%08lX",addr);
  nRows = (ClientHeight-Panel1->Height)/rowHeight;
  // display memory by rows of 16 bytes
  tX = 0;
  tY = Panel1->Height+1;
  for (int r=0; r<nRows; r++) {
    if (addr >= MEMSIZE) {              // if invalid address
      Canvas->Font->Color = clRed;
      Canvas->TextOutA(tX, tY,(str.sprintf ("%08X: ",addr)));
    } else                                // valid address
      Canvas->TextOutA(tX, tY,(str.sprintf ("%08X: ",addr)));

    Canvas->Font->Color = clBlack;
    scrPos = Canvas->PenPos;

    // display 16 hex bytes of memory
    for (int i=0; i<16; i++) {
      if (addr+i >= MEMSIZE) { // if invalid address
        Canvas->Font->Color = clRed;
        Canvas->TextOutA(scrPos.x, scrPos.y, "xx ");
        scrPos = Canvas->PenPos;
        Canvas->Font->Color = clBlack;
      } else {
        Canvas->TextOutA(scrPos.x, scrPos.y,
         (str.sprintf ("%02hX ",(unsigned char)memory[addr+i] )));
        scrPos = Canvas->PenPos;
      }
    }

    // display 16 bytes as ASCII
    for (int i=0; i<16; i++) {
      if (addr+i >= MEMSIZE) { // if invalid address
        Canvas->Font->Color = clRed;
        Canvas->TextOutA(scrPos.x, scrPos.y, "-");
        scrPos = Canvas->PenPos;
        Canvas->Font->Color = clBlack;
      } else {
        if (memory[addr+i] >= ' ')    // if displayable char
          Canvas->TextOutA(scrPos.x, scrPos.y,
           (str.sprintf ("%hc",memory[addr+i] )));
        else
          Canvas->TextOutA(scrPos.x, scrPos.y, "-");
        scrPos = Canvas->PenPos;
      }
    }
    addr += 16;
    tY += rowHeight;
  }
}


//---------------------------------------------------------------------------
// displays memory around loc only.
void __fastcall TMemoryFrm::LivePaint(unsigned int loc)
{
  if (loc >= memAddr-3 && loc <= (memAddr + nRows*16) &&
      loc < MEMSIZE && LiveCheckBox->Checked)
  {
  //    Repaint();
    TPoint scrPos;
    int tX, tY, row;
    unsigned int curAddr;

    // display memory by rows of 16 bytes
    tX = 0;
    row = (loc - memAddr) / 16;
    tY = Panel1->Height+1 + (row * rowHeight);
    curAddr = memAddr + row * 16;

    do {
      Canvas->Font->Color = clBlack;
      Canvas->TextOutA(tX, tY,(str.sprintf ("%08X: ",curAddr)));
      scrPos = Canvas->PenPos;
      // display 16 hex bytes of memory
      for (int i=0; i<16; i++) {
        if (curAddr+i >= MEMSIZE) { // if invalid address
          Canvas->Font->Color = clRed;
          Canvas->TextOutA(scrPos.x, scrPos.y, "xx ");
          scrPos = Canvas->PenPos;
          Canvas->Font->Color = clBlack;
        } else {
          Canvas->TextOutA(scrPos.x, scrPos.y,
           (str.sprintf ("%02hX ",(unsigned char)memory[curAddr+i] )));
          scrPos = Canvas->PenPos;
        }
      }

      // display 16 bytes as ASCII
      for (int i=0; i<16; i++) {
        if (curAddr+i >= MEMSIZE) { // if invalid address
          Canvas->Font->Color = clRed;
          Canvas->TextOutA(scrPos.x, scrPos.y, "-");
          scrPos = Canvas->PenPos;
          Canvas->Font->Color = clBlack;
        } else {
          if (memory[curAddr+i] >= ' ')    // if displayable char
            Canvas->TextOutA(scrPos.x, scrPos.y,
             (str.sprintf ("%hc",memory[curAddr+i] )));
          else
            Canvas->TextOutA(scrPos.x, scrPos.y, "-");
          scrPos = Canvas->PenPos;
        }
      }
      curAddr += 16;
      tY += rowHeight;
    }while(curAddr <= loc+19);
  }
}

//---------------------------------------------------------------------------
void __fastcall TMemoryFrm::FormResize(TObject *Sender)
{
  Repaint();
}
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
void __fastcall TMemoryFrm::RowSpinUpClick(TObject *Sender)
{
  AnsiString str;
  int addr;

  str = "0x";
  addr = StrToInt(str + Address1->EditText);

  addr -= 16;               // display lower address
  if (addr < 0)
    addr = 0;
  Address1->Text = str.sprintf("%08lX",addr);

  Repaint();
}
//---------------------------------------------------------------------------

void __fastcall TMemoryFrm::RowSpinDownClick(TObject *Sender)
{
  AnsiString str;
  int addr;

  str = "0x";
  addr = StrToInt(str + Address1->EditText);

  addr += 16;               // display higher address
  if (addr >= MEMSIZE)
    addr = MEMSIZE - 16;
  Address1->Text = str.sprintf("%08lX",addr);

  Repaint();
}
//---------------------------------------------------------------------------

void __fastcall TMemoryFrm::PageSpinUpClick(TObject *Sender)
{
  AnsiString str;
  int addr;

  str = "0x";
  addr = StrToInt(str + Address1->EditText);

  addr -= nRows*16;               // display lower address
  if (addr <= 0)
    addr = 0;
  Address1->Text = str.sprintf("%08lX",addr);

  Repaint();

}
//---------------------------------------------------------------------------

void __fastcall TMemoryFrm::PageSpinDownClick(TObject *Sender)
{
  AnsiString str;
  int addr;

  str = "0x";
  addr = StrToInt(str + Address1->EditText);

  addr += nRows*16;               // display higher address
  if (addr >= MEMSIZE)
    addr = MEMSIZE - 16;
  Address1->Text = str.sprintf("%08lX",addr);

  Repaint();

}
//---------------------------------------------------------------------------

void __fastcall TMemoryFrm::FormMouseWheelDown(TObject *Sender,
      TShiftState Shift, TPoint &MousePos, bool &Handled)
{
  RowSpinDownClick(Sender);
}
//---------------------------------------------------------------------------

void __fastcall TMemoryFrm::FormMouseWheelUp(TObject *Sender,
      TShiftState Shift, TPoint &MousePos, bool &Handled)
{
  RowSpinUpClick(Sender);
}
//---------------------------------------------------------------------------


void __fastcall TMemoryFrm::Address1KeyDown(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  switch (Key) {
    case VK_PRIOR:              // Page Up
      PageSpinUpClick(Sender);
      break;
    case VK_NEXT:               // Page Down
      PageSpinDownClick(Sender);
      break;
    case VK_UP:                 // Up arrow
      RowSpinUpClick(Sender);
      break;
    case VK_DOWN:               // Down arrow
      RowSpinDownClick(Sender);
      break;
    case VK_F1:
      Form1->displayHelp("MEMORY");
      break;
    case VK_RETURN:             // Enter
      Repaint();
      break;
    case VK_TAB:
      if(Shift.Contains(ssCtrl))        // if Ctrl-Tab
        StackFrm->BringToFront();
      break;
  }
}

//---------------------------------------------------------------------------
// goto row, col
void __fastcall TMemoryFrm::gotoRC(TObject *Sender, int r, int c)
{
  row = r;
  col = c;

  if (row < 0) {
    row = 0;
    RowSpinUpClick(Sender);
  } else if (row > nRows-1) {
    row = nRows-1;
    RowSpinDownClick(Sender);
  }

  if (col < HEX_LEFT)           // don't put cursor in address column
    col = HEX_LEFT;
  else if (col < ASC_LEFT) {
    if (col%3 == 0)
      col++;
  } else if (col > ASC_RIGHT)
    col = ASC_RIGHT;

  textY = row * rowHeight + Panel1->Height;
  textX = col * colWidth;

  promptVisible = false;        // make prompt visible if enabled
  drawPrompt();                 // draw prompt immediately
}


//---------------------------------------------------------------------------
// Mouse Button Down
void __fastcall TMemoryFrm::FormMouseDown(TObject *Sender,
      TMouseButton Button, TShiftState Shift, int X, int Y)
{
  erasePrompt();                // erase old prompt
  Address1->SetFocus();         // give address box focus to remove focus from everyone else
  Address1->Enabled = false;    // disable address box to loose focus
  MemoryFrm->SetFocus();        // give form the focus
  Address1->Enabled = true;     // turn address box back on

  row = (Y-Panel1->Height)/rowHeight;
  col = X/colWidth;
  gotoRC(Sender, row,col);

  prompt->Enabled = true;       // display prompt

  Repaint();
}
//---------------------------------------------------------------------------

void __fastcall TMemoryFrm::promptTimer(TObject *Sender)
{
  drawPrompt();
}


//---------------------------------------------------------------------------
// draw prompt
void __fastcall TMemoryFrm::drawPrompt()
{
  int promptX = colWidth * col;

  if (promptVisible) {                  // if prompt visible
    promptVisible = false;
  } else {
    Canvas->Brush->Color = clBlack;
    promptVisible = true;
  }

  Canvas->FrameRect(TRect(promptX,textY+rowHeight/4-1,
                        promptX+colWidth+1, textY+rowHeight/4+rowHeight-1));
  Canvas->Brush->Color = clWhite;
}

//---------------------------------------------------------------------------
// erase prompt
void __fastcall TMemoryFrm::erasePrompt()
{
  int promptX = colWidth * col;

  prompt->Enabled = false;    // stop display of prompt
  Canvas->FrameRect(TRect(promptX,textY+rowHeight/4-1,
                        promptX+colWidth+1, textY+rowHeight/4+rowHeight-1));
}


//---------------------------------------------------------------------------
// Handle key press on form
void __fastcall TMemoryFrm::FormKeyPress(TObject *Sender, char &Key)
{
  AnsiString str;
  TPoint scrPos;
  int addr;
  unsigned char byte, data;
  bool lowNybble, hexData;

  // Determine address that is being changed
  str = "0x";
  addr = StrToInt(str + Address1->EditText);    // get address of top row
  addr += row*16;       // address of current row

  if (col <= HEX_RIGHT) {       // if changing hex data
    addr += (col-HEX_LEFT)/3;   // address being changed
    lowNybble = (col-HEX_LEFT)%3; // true if lower nybble
    hexData = true;
  } else {                      // else, changing ASCII data
    addr += col-ASC_LEFT;       // address being changed
    hexData = false;
  }

  if (addr >= MEMSIZE) { // if invalid address
    Beep();
    return;
  }

  // if hex data is being changed
  if (hexData) {
    Key = toupper(Key);
    if (Key >= '0' && Key <= '9')
      data = Key - '0';         // convert to binary
    else if (Key >= 'A' && Key <= 'F')
      data = Key - 'A' + 10;    // convert to binary
    else {                      // else invalid key
      Beep();
      return;
    }

    byte = memory[addr];        // get byte being modified
    if (lowNybble) {
      byte &= 0xF0;             // strip off low nybble
      byte |= data;             // put new low nybble
    } else {
      byte &= 0x0F;             // strip off hi nybble
      byte |= (data << 4);      // put new hi nybble
    }
    memory[addr] = byte;        // update memory

    col++;                      // advance to next byte
    if (col > HEX_RIGHT) {
      col = HEX_LEFT;
      row++;
    }
    gotoRC(Sender, row,col);
  }

  // else, character data is being changed
  else {
    memory[addr] = Key;
    col++;                      // advance to next character
    if (col > ASC_RIGHT) {
      col = ASC_LEFT;
      row++;
    }
    gotoRC(Sender, row,col);
  }
  Hardware->updateIfNeeded(addr);       // update hardware display
  StackFrm->DisplayStack();             // update stack display
  Repaint();
}
//---------------------------------------------------------------------------

void __fastcall TMemoryFrm::FormKeyDown(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  erasePrompt();                // erase old prompt
  switch (Key) {
    case VK_PRIOR:              // Page Up
      PageSpinUpClick(Sender);
      break;
    case VK_NEXT:               // Page Down
      PageSpinDownClick(Sender);
      break;
    case VK_UP:                 // Up arrow
      row--;
      gotoRC(Sender, row,col);
      break;
    case VK_DOWN:               // Down arrow
      row++;
      gotoRC(Sender, row,col);
      break;
    case VK_LEFT:               // Left arrow
      col--;
      if (col < 58)
        if (col%3 == 0)
          col--;
      gotoRC(Sender, row,col);
      break;
    case VK_RIGHT:               // Down arrow
      col++;
      gotoRC(Sender, row,col);
      break;
    case VK_F1:
      Form1->displayHelp("MEMORY");
      break;
    case VK_TAB:
      if(Shift.Contains(ssCtrl))        // if Ctrl-Tab
        StackFrm->BringToFront();
      break;
  }
  prompt->Enabled = true;       // display prompt

}
//---------------------------------------------------------------------------

void __fastcall TMemoryFrm::BringToFront()
{
  if(MemoryFrm->Visible)
    MemoryFrm->SetFocus();
  else
    StackFrm->BringToFront();
}

//---------------------------------------------------------------------------
// move data in the 68000's memory space
void __fastcall TMemoryFrm::CopyClick(TObject *Sender)
{
  try {
    unsigned int fromAddr, toAddr, bytes, i;

    str = "0x";
    fromAddr = StrToInt(str + From->EditText);
    toAddr = StrToInt(str + To->EditText);
    bytes = StrToInt(str + Bytes->EditText);

    // if invalid copy
    if (toAddr == fromAddr || bytes == 0 ) {
      ShowMessage("Invalid copy range");
      return;
    }

    // ----- copy data in memory -----

    // if copy from low address to high address
    if (fromAddr < toAddr) {
      fromAddr += bytes - 1;  // copy highest bytes first incase ranges overlap
      toAddr += bytes - 1;
      if (toAddr >= MEMSIZE || fromAddr >= MEMSIZE) { // if invalid copy range
        ShowMessage("Invalid copy range");
        return;
      }
      for (i=0; i<bytes; i++) {                 // for copy size
        memory[toAddr-i] = memory[fromAddr-i];  // copy a byte
      }

    // else, copy from high address to low address
    } else {
      for (i=0; i<bytes; i++) {
        if (toAddr+i >= MEMSIZE || fromAddr+i >= MEMSIZE) { // if invalid address
          ShowMessage("Invalid copy range");
          return;
        }
        memory[toAddr+i] = memory[fromAddr+i];  // copy a byte
      }
    }

    Repaint();      // update display
  }
  catch( ... ) {
    ShowMessage("Error in CopyClick()");
    return;
  }
}
//---------------------------------------------------------------------------


void __fastcall TMemoryFrm::AddrKeyPress(TObject *Sender, char &Key)
{
  if ( (Key >= '0' && Key <= '9') ||
       (toupper(Key) >= 'A' && toupper(Key) <= 'F') )
    Key = toupper(Key);
  else {
    Beep();
    Key = 0;
  }
}
//---------------------------------------------------------------------------



void __fastcall TMemoryFrm::FillClick(TObject *Sender)
{
  AnsiString str;
  unsigned int fromAddr, toAddr, bytes, i;
  char data[4];

  str = "0x";
  fromAddr = StrToInt(str + From->EditText);
  toAddr = StrToInt(str + To->EditText);
  bytes = StrToInt(str + Bytes->EditText);
  data[3] = (char)(bytes & 0xFF);            // low byte
  data[2] = (char)((bytes>>8) & 0xFF);       // next byte
  data[1] = (char)((bytes>>16) & 0xFF);
  data[0] = (char)((bytes>>24) & 0xFF);

  // fill memory with bytes
  for (i=fromAddr; i<=toAddr; i++) {
    if (i >= MEMSIZE) { // if invalid address
      ShowMessage("Invalid memory range");
      return;
    } else {
      memory[i] = data[(i-fromAddr)%4];
    }
  }

  Repaint();      // update display
}
//---------------------------------------------------------------------------


void __fastcall TMemoryFrm::Address1KeyUp(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  Repaint();      // update display
}
//---------------------------------------------------------------------------

void __fastcall TMemoryFrm::SaveClick(TObject *Sender)
{
  AnsiString str;
  unsigned int fromAddr, toAddr, i;
  int bytes;
  char data[4];

  str = "0x";
  fromAddr = StrToInt(str + From->EditText);
  toAddr = StrToInt(str + To->EditText);
  bytes = toAddr - fromAddr + 1;
  if ( bytes <= 0 || toAddr >= MEMSIZE) {
    Beep();
    Application->MessageBox("Invalid memory range.", "Information", MB_OK);
    return;
  }

  try {
    if(SaveDialog->Execute()) {
      str = SaveDialog->FileName;
      if (FileExists(str)) {
        int response = Application->MessageBox("File exists! OK to replace?", "Alert", MB_YESNO);
        if (response == IDNO)
          return;
      }
      ofstream oFile(str.c_str(),ios::binary);
      oFile.write( reinterpret_cast<char*>(&memory[fromAddr & ADDRMASK]), bytes);
      oFile.close();
    }
  }
  catch( ... ) {
    MessageDlg("Error saving 68K memory to file.",mtInformation, TMsgDlgButtons() << mbOK,0);
    return;
  }
}
//---------------------------------------------------------------------------



