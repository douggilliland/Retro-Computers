//---------------------------------------------------------------------------
//   Author: Chuck Kelly,
//           Monroe County Community College
//           http://www.monroeccc.edu/ckelly
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#include <vcl.h>

#pragma hdrstop

#include "hardwareu.h"
#include "Memory1.h"
#include "Stack1.h"
#include "SIM68Ku.h"
#include "BREAKPOINTSu.h"

//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
THardware *Hardware;

static const TColor clDrkMaroon = 0x02000040;
static const SWITCH_ADDR = 0xE0000A;

AnsiString str1;
int seg7loc, LEDloc, switchLoc, pbLoc;
bool pbInit;
bool autoIRQ;
bool hardwareEnabled;
int ROMStart=0, ROMEnd=0, ReadStart=0, ReadEnd=0;
int ProtectedStart=0, ProtectedEnd=0, InvalidStart=0, InvalidEnd=0;
bool ROMMap=false, ReadMap=false, ProtectedMap=false, InvalidMap=false;

//---------------------------------------------------------------------------
__fastcall THardware::THardware(TComponent* Owner)
        : TForm(Owner)
{
}

//---------------------------------------------------------------------------
// Return hardware to new positions
void __fastcall THardware::initialize()
{
  switch0->Layout = blGlyphLeft;
  switch1->Layout = blGlyphLeft;
  switch2->Layout = blGlyphLeft;
  switch3->Layout = blGlyphLeft;
  switch4->Layout = blGlyphLeft;
  switch5->Layout = blGlyphLeft;
  switch6->Layout = blGlyphLeft;
  switch7->Layout = blGlyphLeft;
  CheckBox1->Checked = false;
  CheckBox2->Checked = false;
  CheckBox3->Checked = false;
  CheckBox4->Checked = false;
  CheckBox5->Checked = false;
  CheckBox6->Checked = false;
  CheckBox7->Checked = false;
  autoIRQoff();
  update();
}

//---------------------------------------------------------------------------
void __fastcall THardware::switch0Click(TObject *Sender)
{
  if(switch0->Layout == blGlyphLeft) {
    // switch on
    switch0->Layout = blGlyphRight;
    memory[switchLoc] |= 0x01;
  }else {
    // switch off
    switch0->Layout = blGlyphLeft;
    memory[switchLoc] &= 0xFE;
  }
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}
//---------------------------------------------------------------------------
void __fastcall THardware::switch1Click(TObject *Sender)
{
  if(switch1->Layout == blGlyphLeft) {
    // switch on
    switch1->Layout = blGlyphRight;
    memory[switchLoc] |= 0x02;
  }else {
    // switch off
    switch1->Layout = blGlyphLeft;
    memory[switchLoc] &= 0xFD;
  }
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}
//---------------------------------------------------------------------------
void __fastcall THardware::switch2Click(TObject *Sender)
{
  if(switch2->Layout == blGlyphLeft) {
    // switch on
    switch2->Layout = blGlyphRight;
    memory[switchLoc] |= 0x04;
  }else {
    // switch off
    switch2->Layout = blGlyphLeft;
    memory[switchLoc] &= 0xFB;
  }
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}
//---------------------------------------------------------------------------
void __fastcall THardware::switch3Click(TObject *Sender)
{
  if(switch3->Layout == blGlyphLeft) {
    // switch on
    switch3->Layout = blGlyphRight;
    memory[switchLoc] |= 0x08;
  }else {
    // switch off
    switch3->Layout = blGlyphLeft;
    memory[switchLoc] &= 0xF7;
  }
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}
//---------------------------------------------------------------------------
void __fastcall THardware::switch4Click(TObject *Sender)
{
  if(switch4->Layout == blGlyphLeft) {
    // switch on
    switch4->Layout = blGlyphRight;
    memory[switchLoc] |= 0x10;
  }else {
    // switch off
    switch4->Layout = blGlyphLeft;
    memory[switchLoc] &= 0xEF;
  }
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}
//---------------------------------------------------------------------------
void __fastcall THardware::switch5Click(TObject *Sender)
{
  if(switch5->Layout == blGlyphLeft) {
    // switch on
    switch5->Layout = blGlyphRight;
    memory[switchLoc] |= 0x20;
  }else {
    // switch off
    switch5->Layout = blGlyphLeft;
    memory[switchLoc] &= 0xDF;
  }
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}
//---------------------------------------------------------------------------
void __fastcall THardware::switch6Click(TObject *Sender)
{
  if(switch6->Layout == blGlyphLeft) {
    // switch on
    switch6->Layout = blGlyphRight;
    memory[switchLoc] |= 0x40;
  }else {
    // switch off
    switch6->Layout = blGlyphLeft;
    memory[switchLoc] &= 0xBF;
  }
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}
//---------------------------------------------------------------------------
void __fastcall THardware::switch7Click(TObject *Sender)
{
  if(switch7->Layout == blGlyphLeft) {
    // switch on
    switch7->Layout = blGlyphRight;
    memory[switchLoc] |= 0x80;
  }else {
    // switch off
    switch7->Layout = blGlyphLeft;
    memory[switchLoc] &= 0x7F;
  }
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}

//---------------------------------------------------------------------------
void __fastcall THardware::FormShow(TObject *Sender)
{
  update();
  memory[switchLoc] = 0x00;
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}
//---------------------------------------------------------------------------

void __fastcall THardware::updateIfNeeded(int adr)
{
  if (adr < MEMSIZE) {          // if in valid memory space
    if((adr >= seg7loc-4 && adr <= seg7loc+15) || // if address in seg7 display
       (adr >= LEDloc-4  && adr <= LEDloc) ) {    // if address of LEDs
      update();
    }
  }
}

//---------------------------------------------------------------------------

// update displays
void __fastcall THardware::update()
{
  unsigned char data;

  if (Hardware->Visible){

    // ---------- update 7-segment display ----------
    if (seg7loc < MEMSIZE-8) {                       // if valid address

      // segment7
      data = (unsigned char)memory[seg7loc];            // get byte from memory
      if(data & 0x01)
        seg7a->Brush->Color = clRed;
      else
        seg7a->Brush->Color = clDrkMaroon;
      if(data & 0x02)
        seg7b->Brush->Color = clRed;
      else
        seg7b->Brush->Color = clDrkMaroon;
      if(data & 0x04)
        seg7c->Brush->Color = clRed;
      else
        seg7c->Brush->Color = clDrkMaroon;
      if(data & 0x08)
        seg7d->Brush->Color = clRed;
      else
        seg7d->Brush->Color = clDrkMaroon;
      if(data & 0x10)
        seg7e->Brush->Color = clRed;
      else
        seg7e->Brush->Color = clDrkMaroon;
      if(data & 0x20)
        seg7f->Brush->Color = clRed;
      else
        seg7f->Brush->Color = clDrkMaroon;
      if(data & 0x40)
        seg7g->Brush->Color = clRed;
      else
        seg7g->Brush->Color = clDrkMaroon;
      if(data & 0x80)
        seg7h->Brush->Color = clRed;
      else
        seg7h->Brush->Color = clDrkMaroon;

      // segment 6
      data = (unsigned char)memory[seg7loc+2];          // get byte from memory
      if(data & 0x01)
        seg6a->Brush->Color = clRed;
      else
        seg6a->Brush->Color = clDrkMaroon;
      if(data & 0x02)
        seg6b->Brush->Color = clRed;
      else
        seg6b->Brush->Color = clDrkMaroon;
      if(data & 0x04)
        seg6c->Brush->Color = clRed;
      else
        seg6c->Brush->Color = clDrkMaroon;
      if(data & 0x08)
        seg6d->Brush->Color = clRed;
      else
        seg6d->Brush->Color = clDrkMaroon;
      if(data & 0x10)
        seg6e->Brush->Color = clRed;
      else
        seg6e->Brush->Color = clDrkMaroon;
      if(data & 0x20)
        seg6f->Brush->Color = clRed;
      else
        seg6f->Brush->Color = clDrkMaroon;
      if(data & 0x40)
        seg6g->Brush->Color = clRed;
      else
        seg6g->Brush->Color = clDrkMaroon;
      if(data & 0x80)
        seg6h->Brush->Color = clRed;
      else
        seg6h->Brush->Color = clDrkMaroon;

      // segment 5
      data = (unsigned char)memory[seg7loc+4];          // get byte from memory
      if(data & 0x01)
        seg5a->Brush->Color = clRed;
      else
        seg5a->Brush->Color = clDrkMaroon;
      if(data & 0x02)
        seg5b->Brush->Color = clRed;
      else
        seg5b->Brush->Color = clDrkMaroon;
      if(data & 0x04)
        seg5c->Brush->Color = clRed;
      else
        seg5c->Brush->Color = clDrkMaroon;
      if(data & 0x08)
        seg5d->Brush->Color = clRed;
      else
        seg5d->Brush->Color = clDrkMaroon;
      if(data & 0x10)
        seg5e->Brush->Color = clRed;
      else
        seg5e->Brush->Color = clDrkMaroon;
      if(data & 0x20)
        seg5f->Brush->Color = clRed;
      else
        seg5f->Brush->Color = clDrkMaroon;
      if(data & 0x40)
        seg5g->Brush->Color = clRed;
      else
        seg5g->Brush->Color = clDrkMaroon;
      if(data & 0x80)
        seg5h->Brush->Color = clRed;
      else
        seg5h->Brush->Color = clDrkMaroon;

      // segment 4
      data = (unsigned char)memory[seg7loc+6];          // get byte from memory
      if(data & 0x01)
        seg4a->Brush->Color = clRed;
      else
        seg4a->Brush->Color = clDrkMaroon;
      if(data & 0x02)
        seg4b->Brush->Color = clRed;
      else
        seg4b->Brush->Color = clDrkMaroon;
      if(data & 0x04)
        seg4c->Brush->Color = clRed;
      else
        seg4c->Brush->Color = clDrkMaroon;
      if(data & 0x08)
        seg4d->Brush->Color = clRed;
      else
        seg4d->Brush->Color = clDrkMaroon;
      if(data & 0x10)
        seg4e->Brush->Color = clRed;
      else
        seg4e->Brush->Color = clDrkMaroon;
      if(data & 0x20)
        seg4f->Brush->Color = clRed;
      else
        seg4f->Brush->Color = clDrkMaroon;
      if(data & 0x40)
        seg4g->Brush->Color = clRed;
      else
        seg4g->Brush->Color = clDrkMaroon;
      if(data & 0x80)
        seg4h->Brush->Color = clRed;
      else
        seg4h->Brush->Color = clDrkMaroon;

      // segment 3
      data = (unsigned char)memory[seg7loc+8];          // get byte from memory
      if(data & 0x01)
        seg3a->Brush->Color = clRed;
      else
        seg3a->Brush->Color = clDrkMaroon;
      if(data & 0x02)
        seg3b->Brush->Color = clRed;
      else
        seg3b->Brush->Color = clDrkMaroon;
      if(data & 0x04)
        seg3c->Brush->Color = clRed;
      else
        seg3c->Brush->Color = clDrkMaroon;
      if(data & 0x08)
        seg3d->Brush->Color = clRed;
      else
        seg3d->Brush->Color = clDrkMaroon;
      if(data & 0x10)
        seg3e->Brush->Color = clRed;
      else
        seg3e->Brush->Color = clDrkMaroon;
      if(data & 0x20)
        seg3f->Brush->Color = clRed;
      else
        seg3f->Brush->Color = clDrkMaroon;
      if(data & 0x40)
        seg3g->Brush->Color = clRed;
      else
        seg3g->Brush->Color = clDrkMaroon;
      if(data & 0x80)
        seg3h->Brush->Color = clRed;
      else
        seg3h->Brush->Color = clDrkMaroon;

      // segment 2
      data = (unsigned char)memory[seg7loc+10];          // get byte from memory
      if(data & 0x01)
        seg2a->Brush->Color = clRed;
      else
        seg2a->Brush->Color = clDrkMaroon;
      if(data & 0x02)
        seg2b->Brush->Color = clRed;
      else
        seg2b->Brush->Color = clDrkMaroon;
      if(data & 0x04)
        seg2c->Brush->Color = clRed;
      else
        seg2c->Brush->Color = clDrkMaroon;
      if(data & 0x08)
        seg2d->Brush->Color = clRed;
      else
        seg2d->Brush->Color = clDrkMaroon;
      if(data & 0x10)
        seg2e->Brush->Color = clRed;
      else
        seg2e->Brush->Color = clDrkMaroon;
      if(data & 0x20)
        seg2f->Brush->Color = clRed;
      else
        seg2f->Brush->Color = clDrkMaroon;
      if(data & 0x40)
        seg2g->Brush->Color = clRed;
      else
        seg2g->Brush->Color = clDrkMaroon;
      if(data & 0x80)
        seg2h->Brush->Color = clRed;
      else
        seg2h->Brush->Color = clDrkMaroon;

      // segment 1
      data = (unsigned char)memory[seg7loc+12];          // get byte from memory
      if(data & 0x01)
        seg1a->Brush->Color = clRed;
      else
        seg1a->Brush->Color = clDrkMaroon;
      if(data & 0x02)
        seg1b->Brush->Color = clRed;
      else
        seg1b->Brush->Color = clDrkMaroon;
      if(data & 0x04)
        seg1c->Brush->Color = clRed;
      else
        seg1c->Brush->Color = clDrkMaroon;
      if(data & 0x08)
        seg1d->Brush->Color = clRed;
      else
        seg1d->Brush->Color = clDrkMaroon;
      if(data & 0x10)
        seg1e->Brush->Color = clRed;
      else
        seg1e->Brush->Color = clDrkMaroon;
      if(data & 0x20)
        seg1f->Brush->Color = clRed;
      else
        seg1f->Brush->Color = clDrkMaroon;
      if(data & 0x40)
        seg1g->Brush->Color = clRed;
      else
        seg1g->Brush->Color = clDrkMaroon;
      if(data & 0x80)
        seg1h->Brush->Color = clRed;
      else
        seg1h->Brush->Color = clDrkMaroon;

      // segment 0
      data = (unsigned char)memory[seg7loc+14];          // get byte from memory
      if(data & 0x01)
        seg0a->Brush->Color = clRed;
      else
        seg0a->Brush->Color = clDrkMaroon;
      if(data & 0x02)
        seg0b->Brush->Color = clRed;
      else
        seg0b->Brush->Color = clDrkMaroon;
      if(data & 0x04)
        seg0c->Brush->Color = clRed;
      else
        seg0c->Brush->Color = clDrkMaroon;
      if(data & 0x08)
        seg0d->Brush->Color = clRed;
      else
        seg0d->Brush->Color = clDrkMaroon;
      if(data & 0x10)
        seg0e->Brush->Color = clRed;
      else
        seg0e->Brush->Color = clDrkMaroon;
      if(data & 0x20)
        seg0f->Brush->Color = clRed;
      else
        seg0f->Brush->Color = clDrkMaroon;
      if(data & 0x40)
        seg0g->Brush->Color = clRed;
      else
        seg0g->Brush->Color = clDrkMaroon;
      if(data & 0x80)
        seg0h->Brush->Color = clRed;
      else
        seg0h->Brush->Color = clDrkMaroon;

    } // endif valid address

    // ---------- update LEDs ----------
    if (LEDloc < MEMSIZE) {                            // if valid address

      data = (unsigned char)memory[LEDloc];            // get byte from memory
      if(data & 0x01)
        LED0->Brush->Color = clRed;
      else
        LED0->Brush->Color = clDrkMaroon;
      if(data & 0x02)
        LED1->Brush->Color = clRed;
      else
        LED1->Brush->Color = clDrkMaroon;
      if(data & 0x04)
        LED2->Brush->Color = clRed;
      else
        LED2->Brush->Color = clDrkMaroon;
      if(data & 0x08)
        LED3->Brush->Color = clRed;
      else
        LED3->Brush->Color = clDrkMaroon;
      if(data & 0x10)
        LED4->Brush->Color = clRed;
      else
        LED4->Brush->Color = clDrkMaroon;
      if(data & 0x20)
        LED5->Brush->Color = clRed;
      else
        LED5->Brush->Color = clDrkMaroon;
      if(data & 0x40)
        LED6->Brush->Color = clRed;
      else
        LED6->Brush->Color = clDrkMaroon;
      if(data & 0x80)
        LED7->Brush->Color = clRed;
      else
        LED7->Brush->Color = clDrkMaroon;
    } // endif valid address
  }
}
//---------------------------------------------------------------------------

void __fastcall THardware::addrKeyPress(TObject *Sender, char &Key)
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

// this is called on startup when LoadSettings() initializes the address
// and each time the user changes the address.
void __fastcall THardware::seg7addrChange(TObject *Sender)
{
  str1 = "0x";
  seg7loc = StrToInt(str1 + seg7addr->EditText);   // get 7-seg address
  update();
}
//---------------------------------------------------------------------------

// this is called on startup when LoadSettings() initializes the address
// and each time the user changes the address.
void __fastcall THardware::LEDaddrChange(TObject *Sender)
{
  str1 = "0x";
  LEDloc = StrToInt(str1 + LEDaddr->EditText);    // get LED address
  update();
}
//---------------------------------------------------------------------------

// this is called on startup when LoadSettings() initializes the address
// and each time the user changes the address.
void __fastcall THardware::switchAddrChange(TObject *Sender)
{
  str1 = "0x";
  switchLoc = StrToInt(str1 + switchAddr->EditText);  // get switch address
  switch0->Layout = blGlyphLeft;
  switch1->Layout = blGlyphLeft;
  switch2->Layout = blGlyphLeft;
  switch3->Layout = blGlyphLeft;
  switch4->Layout = blGlyphLeft;
  switch5->Layout = blGlyphLeft;
  switch6->Layout = blGlyphLeft;
  switch7->Layout = blGlyphLeft;
  if (switchLoc >= MEMSIZE) {                         // if invalid address
    switch0->Enabled = false;
    switch1->Enabled = false;
    switch2->Enabled = false;
    switch3->Enabled = false;
    switch4->Enabled = false;
    switch5->Enabled = false;
    switch6->Enabled = false;
    switch7->Enabled = false;
  } else {
    switch0->Enabled = true;
    switch1->Enabled = true;
    switch2->Enabled = true;
    switch3->Enabled = true;
    switch4->Enabled = true;
    switch5->Enabled = true;
    switch6->Enabled = true;
    switch7->Enabled = true;
  }
}

//---------------------------------------------------------------------------
void __fastcall THardware::switchAddrExit(TObject *Sender)
{
  str1 = "0x";
  switchLoc = StrToInt(str1 + switchAddr->EditText);  // get switch address
  memory[switchLoc] = 0x00;     // set switch memory to 0
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}
//---------------------------------------------------------------------------

void __fastcall THardware::switchAddrKeyDown(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  if (Key == VK_RETURN)
  {
    str1 = "0x";
    switchLoc = StrToInt(str1 + switchAddr->EditText);  // get switch address
    memory[switchLoc] = 0x00;     // set switch memory to 0
    MemoryFrm->Repaint();
    StackFrm->Repaint();
  }
}

//---------------------------------------------------------------------------

void __fastcall THardware::pbAddrChange(TObject *Sender)
{
  str1 = "0x";
  pbLoc = StrToInt(str1 + pbAddr->EditText);  // get push button address
  if (pbLoc >= MEMSIZE) {                         // if invalid address
    pb0->Enabled = false;
    pb1->Enabled = false;
    pb2->Enabled = false;
    pb3->Enabled = false;
    pb4->Enabled = false;
    pb5->Enabled = false;
    pb6->Enabled = false;
    pb7->Enabled = false;
  } else {
    pb0->Enabled = true;
    pb1->Enabled = true;
    pb2->Enabled = true;
    pb3->Enabled = true;
    pb4->Enabled = true;
    pb5->Enabled = true;
    pb6->Enabled = true;
    pb7->Enabled = true;
    if (!pbInit) {
      memory[pbLoc] = 0xFF;     // init pb data in memory
      MemoryFrm->Repaint();
      StackFrm->Repaint();
      pbInit = true;
    }
  }

}
//---------------------------------------------------------------------------


void __fastcall THardware::addrKeyUp(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  // check 7-seg address for conflicts
  if ((seg7loc >= MEMSIZE-8) ||                           // if invalid address
      (seg7loc <= LEDloc    && seg7loc+15 >= LEDloc) ||   // if conflict with LED address
      (seg7loc <= switchLoc && seg7loc+15 >= switchLoc)|| // if conflict with switch address
      (seg7loc <= pbLoc && seg7loc+15 >= pbLoc) )         // if conflict with push button address
    seg7addr->Font->Color = clRed;        // set red font color for warning
  else
    seg7addr->Font->Color = clBlack;
  // check LED address for conflicts
  if ((LEDloc >= MEMSIZE) ||                         // if invalid address
      (LEDloc >= seg7loc && LEDloc <= seg7loc+15) || // if conflict with seg7 address
      (LEDloc == switchLoc) ||                       // if conflict with switch address
      (LEDloc == pbLoc) )                            // if conflict with push button address
    LEDaddr->Font->Color = clRed;        // set red font color for warning
  else
    LEDaddr->Font->Color = clBlack;
  // check switch address for conflicts
  if ((switchLoc >= MEMSIZE) ||                            // if invalid address
      (switchLoc >= seg7loc && switchLoc <= seg7loc+15) || // if conflict with seg7 address
      (switchLoc == LEDloc)                             || // if conflict with LED address
      (switchLoc == pbLoc) )                               // if conflict with push button address
    switchAddr->Font->Color = clRed;     // set red font color for warning
  else
    switchAddr->Font->Color = clBlack;
  // check push button address for conflicts
  if ((pbLoc >= MEMSIZE) ||                        // if invalid address
      (pbLoc <= seg7loc+15 && pbLoc >= seg7loc) || // if conflict with seg7 address
      (pbLoc == LEDloc)                         || // if conflict with LED address
      (pbLoc == switchLoc) )                       // if conflict with switch address
    pbAddr->Font->Color = clRed;         // set red font color for warning
  else
    pbAddr->Font->Color = clBlack;

}
//---------------------------------------------------------------------------

void __fastcall THardware::IRQ1(TObject *Sender)
{
  IRQprocess(1);
}
//---------------------------------------------------------------------------

void __fastcall THardware::IRQ2(TObject *Sender)
{
  IRQprocess(2);
}
//---------------------------------------------------------------------------

void __fastcall THardware::IRQ3(TObject *Sender)
{
  IRQprocess(3);
}
//---------------------------------------------------------------------------

void __fastcall THardware::IRQ4(TObject *Sender)
{
  IRQprocess(4);
}
//---------------------------------------------------------------------------

void __fastcall THardware::IRQ5(TObject *Sender)
{
  IRQprocess(5);
}
//---------------------------------------------------------------------------

void __fastcall THardware::IRQ6(TObject *Sender)
{
  IRQprocess(6);
}
//---------------------------------------------------------------------------

void __fastcall THardware::IRQ7(TObject *Sender)
{
  IRQprocess(7);
}
//---------------------------------------------------------------------------

void __fastcall THardware::IRQprocess(int irqN)
{
  static int intMask;
  if(hardwareEnabled) {
    if (irqN > 0)               // Reset calls IRQprocess with irqN = 0
      irq |= (0x01 << (irqN-1));
    if (stopInstruction) {      // if CPU halted after STOP instruction
     intMask = 0xFF80 >> (7 - ((SR & intmsk) >> 8)) | 0x40;
      if (!( irq & intMask))    // if IRQ masked
        return;
    }
    inc_cyc (44);               // Interrupt execution time
    if (!trace)
      runMode = true;           // enable runLoop() if not tracing ck 1-11-2008
    if (runMode) {
      Form1->runLoop();         // enter runLoop
    }
  }
}

//---------------------------------------------------------------------------
void __fastcall THardware::ResetBtnClick(TObject *Sender)
{
  if (hardwareEnabled) {
    hardReset = true;
    SR = SR | sbit;		        // force processor into supervisor state
    SR = SR & ~tbit;                    // turn off trace mode
    SR = SR | 0x700;                    // set SR mask to 111
    mem_req (0x00, LONG_MASK, &A[8]);
    mem_req (0x04, LONG_MASK, &PC);
    inc_cyc (40);                       // Reset execution time
    stopInstruction = false;
    scrshow();                          // update the screen
    IRQprocess(0);
  }
}

//---------------------------------------------------------------------------
// turn off all auto IRQ timers
void __fastcall THardware::autoIRQoff()
{
  IRQ1timer->Enabled = false;
  IRQ2timer->Enabled = false;
  IRQ3timer->Enabled = false;
  IRQ4timer->Enabled = false;
  IRQ5timer->Enabled = false;
  IRQ6timer->Enabled = false;
  IRQ7timer->Enabled = false;
  AutoLbl->Caption = "Automatic Disabled";
  autoIRQ = false;
}

//---------------------------------------------------------------------------
// turn on all auto IRQ timers
void __fastcall THardware::autoIRQon()
{
  IRQ1timer->Enabled = CheckBox1->Checked;
  IRQ2timer->Enabled = CheckBox2->Checked;
  IRQ3timer->Enabled = CheckBox3->Checked;
  IRQ4timer->Enabled = CheckBox4->Checked;
  IRQ5timer->Enabled = CheckBox5->Checked;
  IRQ6timer->Enabled = CheckBox6->Checked;
  IRQ7timer->Enabled = CheckBox7->Checked;
  AutoLbl->Caption = "Automatic Enabled";
  autoIRQ = true;
}

//---------------------------------------------------------------------------
// Called by trap task #32 to set auto IRQ
// Pre: irq  = 00 to disable all auto IRQs
//        or   Bit 7 = 0 to disable an auto IRQ
//             Bit 7 = 1 to enable an auto IRQ
//             Bits 6-0 = IRQ number 1 through 7
//  interval = Auto Interval in mS, 1 through 99999999
void __fastcall THardware::setAutoIRQ(uint irq, uint interval)
{
  switch (irq) {
    case 0x00:          // disable all auto IRQs
      autoIRQoff();
      CheckBox1->Checked = false;
      CheckBox2->Checked = false;
      CheckBox3->Checked = false;
      CheckBox4->Checked = false;
      CheckBox5->Checked = false;
      CheckBox6->Checked = false;
      CheckBox7->Checked = false;
      break;
    case 0x01:        // disable auto IRQ 1
      CheckBox1->Checked = false;
      IRQ1timer->Enabled = false;
      break;
    case 0x02:        // disable auto IRQ 2
      CheckBox2->Checked = false;
      IRQ2timer->Enabled = false;
      break;
    case 0x03:        // disable auto IRQ 3
      CheckBox3->Checked = false;
      IRQ3timer->Enabled = false;
      break;
    case 0x04:        // disable auto IRQ 4
      CheckBox4->Checked = false;
      IRQ4timer->Enabled = false;
      break;
    case 0x05:        // disable auto IRQ 5
      CheckBox5->Checked = false;
      IRQ5timer->Enabled = false;
      break;
    case 0x06:        // disable auto IRQ 6
      CheckBox6->Checked = false;
      IRQ6timer->Enabled = false;
      break;
    case 0x07:        // disable auto IRQ 7
      CheckBox7->Checked = false;
      IRQ7timer->Enabled = false;
      break;
    case 0x81:        // enable auto IRQ 1
      IRQ1timer->Interval = interval;
      CheckBox1->Checked = true;
      break;
    case 0x82:        // enable auto IRQ 2
      IRQ2timer->Interval = interval;
      CheckBox2->Checked = true;
      break;
    case 0x83:        // enable auto IRQ 3
      IRQ3timer->Interval = interval;
      CheckBox3->Checked = true;
      break;
    case 0x84:        // enable auto IRQ 4
      IRQ4timer->Interval = interval;
      CheckBox4->Checked = true;
      break;
    case 0x85:        // enable auto IRQ 5
      IRQ5timer->Interval = interval;
      CheckBox5->Checked = true;
      break;
    case 0x86:        // enable auto IRQ 6
      IRQ6timer->Interval = interval;
      CheckBox6->Checked = true;
      break;
    case 0x87:        // enable auto IRQ 7
      IRQ7timer->Interval = interval;
      CheckBox7->Checked = true;
      break;
  } // end switch

  AutoIRQChange(this);  // update Auto Interval mS display
}

//---------------------------------------------------------------------------
// disable hardware
void __fastcall THardware::disable()
{
  autoIRQoff();
  hardwareEnabled = false;
  ResetBtn->Enabled = false;
  IRQ1Btn->Enabled = false;
  IRQ2Btn->Enabled = false;
  IRQ3Btn->Enabled = false;
  IRQ4Btn->Enabled = false;
  IRQ5Btn->Enabled = false;
  IRQ6Btn->Enabled = false;
  IRQ7Btn->Enabled = false;
}

//---------------------------------------------------------------------------
// enable hardware
void __fastcall THardware::enable()
{
  autoIRQon();
  hardwareEnabled = true;
  ResetBtn->Enabled = true;
  IRQ1Btn->Enabled = true;
  IRQ2Btn->Enabled = true;
  IRQ3Btn->Enabled = true;
  IRQ4Btn->Enabled = true;
  IRQ5Btn->Enabled = true;
  IRQ6Btn->Enabled = true;
  IRQ7Btn->Enabled = true;
}

//---------------------------------------------------------------------------
void __fastcall THardware::IRQintervalChange(TObject *Sender)
{
  switch(AutoIRQ->ItemIndex) {
    case 0:
      IRQ1timer->Interval = IRQinterval->EditText.ToInt() ;
      break;
    case 1:
      IRQ2timer->Interval = IRQinterval->EditText.ToInt() ;
      break;
    case 2:
      IRQ3timer->Interval = IRQinterval->EditText.ToInt() ;
      break;
    case 3:
      IRQ4timer->Interval = IRQinterval->EditText.ToInt() ;
      break;
    case 4:
      IRQ5timer->Interval = IRQinterval->EditText.ToInt() ;
      break;
    case 5:
      IRQ6timer->Interval = IRQinterval->EditText.ToInt() ;
      break;
    case 6:
      IRQ7timer->Interval = IRQinterval->EditText.ToInt() ;
      break;
  }
}
//---------------------------------------------------------------------------

void __fastcall THardware::AutoIRQChange(TObject *Sender)
{
  switch(AutoIRQ->ItemIndex) {
    case 0:
      IRQinterval->Text = IRQ1timer->Interval;
      break;
    case 1:
      IRQinterval->Text = IRQ2timer->Interval;
      break;
    case 2:
      IRQinterval->Text = IRQ3timer->Interval;
      break;
    case 3:
      IRQinterval->Text = IRQ4timer->Interval;
      break;
    case 4:
      IRQinterval->Text = IRQ5timer->Interval;
      break;
    case 5:
      IRQinterval->Text = IRQ6timer->Interval;
      break;
    case 6:
      IRQinterval->Text = IRQ7timer->Interval;
      break;
  }
}
//---------------------------------------------------------------------------

void __fastcall THardware::pb0KeyDown(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  memory[pbLoc] &= 0xFE;
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}

void __fastcall THardware::pb0MouseDown(TObject *Sender,
      TMouseButton Button, TShiftState Shift, int X, int Y)
{
  memory[pbLoc] &= 0xFE;
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}

void __fastcall THardware::pb0MouseUp(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{
  memory[pbLoc] |= 0x01;
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}

void __fastcall THardware::pb0KeyUp(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  memory[pbLoc] |= 0x01;
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}

//---------------------------------------------------------------------------
void __fastcall THardware::pb1KeyDown(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  memory[pbLoc] &= 0xFD;
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}

void __fastcall THardware::pb1MouseDown(TObject *Sender,
      TMouseButton Button, TShiftState Shift, int X, int Y)
{
  memory[pbLoc] &= 0xFD;
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}

void __fastcall THardware::pb1KeyUp(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  memory[pbLoc] |= 0x02;
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}

void __fastcall THardware::pb1MouseUp(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{
  memory[pbLoc] |= 0x02;
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}

//---------------------------------------------------------------------------
void __fastcall THardware::pb2KeyDown(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  memory[pbLoc] &= 0xFB;
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}

void __fastcall THardware::pb2MouseDown(TObject *Sender,
      TMouseButton Button, TShiftState Shift, int X, int Y)
{
  memory[pbLoc] &= 0xFB;
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}

void __fastcall THardware::pb2KeyUp(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  memory[pbLoc] |= 0x04;
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}

void __fastcall THardware::pb2MouseUp(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{
  memory[pbLoc] |= 0x04;
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}

//---------------------------------------------------------------------------
void __fastcall THardware::pb3KeyDown(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  memory[pbLoc] &= 0xF7;
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}

void __fastcall THardware::pb3MouseDown(TObject *Sender,
      TMouseButton Button, TShiftState Shift, int X, int Y)
{
  memory[pbLoc] &= 0xF7;
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}

void __fastcall THardware::pb3KeyUp(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  memory[pbLoc] |= 0x08;
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}

void __fastcall THardware::pb3MouseUp(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{
  memory[pbLoc] |= 0x08;
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}
//---------------------------------------------------------------------------

void __fastcall THardware::pb4KeyDown(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  memory[pbLoc] &= 0xEF;
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}

void __fastcall THardware::pb4MouseDown(TObject *Sender,
      TMouseButton Button, TShiftState Shift, int X, int Y)
{
  memory[pbLoc] &= 0xEF;
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}

void __fastcall THardware::pb4KeyUp(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  memory[pbLoc] |= 0x10;
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}

void __fastcall THardware::pb4MouseUp(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{
  memory[pbLoc] |= 0x10;
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}
//---------------------------------------------------------------------------

void __fastcall THardware::pb5KeyDown(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  memory[pbLoc] &= 0xDF;
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}

void __fastcall THardware::pb5MouseDown(TObject *Sender,
      TMouseButton Button, TShiftState Shift, int X, int Y)
{
  memory[pbLoc] &= 0xDF;
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}

void __fastcall THardware::pb5KeyUp(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  memory[pbLoc] |= 0x20;
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}

void __fastcall THardware::pb5MouseUp(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{
  memory[pbLoc] |= 0x20;
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}
//---------------------------------------------------------------------------

void __fastcall THardware::pb6KeyDown(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  memory[pbLoc] &= 0xBF;
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}

void __fastcall THardware::pb6MouseDown(TObject *Sender,
      TMouseButton Button, TShiftState Shift, int X, int Y)
{
  memory[pbLoc] &= 0xBF;
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}

void __fastcall THardware::pb6KeyUp(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  memory[pbLoc] |= 0x40;
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}

void __fastcall THardware::pb6MouseUp(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{
  memory[pbLoc] |= 0x40;
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}
//---------------------------------------------------------------------------

void __fastcall THardware::pb7KeyDown(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  memory[pbLoc] &= 0x7F;
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}
//---------------------------------------------------------------------------

void __fastcall THardware::pb7MouseDown(TObject *Sender,
      TMouseButton Button, TShiftState Shift, int X, int Y)
{
  memory[pbLoc] &= 0x7F;
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}
//---------------------------------------------------------------------------

void __fastcall THardware::pb7KeyUp(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  memory[pbLoc] |= 0x80;
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}
//---------------------------------------------------------------------------

void __fastcall THardware::pb7MouseUp(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{
  memory[pbLoc] |= 0x80;
  update();
  MemoryFrm->Repaint();
  StackFrm->Repaint();
}
//---------------------------------------------------------------------------

void __fastcall THardware::pbAddrKeyDown(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  if(Key == VK_RETURN && pbLoc < MEMSIZE)     // if valid address
  {
    memory[pbLoc] = 0xFF;
    update();
    MemoryFrm->Repaint();
    StackFrm->Repaint();
  }
}
//---------------------------------------------------------------------------

void __fastcall THardware::pbAddrExit(TObject *Sender)
{
  if (pbLoc < MEMSIZE) {                         // if valid address
    memory[pbLoc] = 0xFF;
    update();
    MemoryFrm->Repaint();
    StackFrm->Repaint();
  }
}
//---------------------------------------------------------------------------


void __fastcall THardware::FormCreate(TObject *Sender)
{
  pbInit = false;       // push buttons not initialized
  autoIRQ = false;    // automatic IRQ disabled
  hardwareEnabled = true;
}
//---------------------------------------------------------------------------

void __fastcall THardware::FormKeyDown(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
   if (Key == VK_F1)
     Form1->displayHelp("HARDWARE");
   else if (Key == VK_TAB && Shift.Contains(ssCtrl))    // if Ctrl-Tab
     BreaksFrm->BringToFront();
}
//---------------------------------------------------------------------------

void __fastcall THardware::BringToFront()
{
  if(Hardware->Visible)
    Hardware->SetFocus();
  else
    BreaksFrm->BringToFront();
}
//---------------------------------------------------------------------------


void __fastcall THardware::CheckBox1Click(TObject *Sender)
{
  if (autoIRQ)
    IRQ1timer->Enabled = CheckBox1->Checked;
}
//---------------------------------------------------------------------------

void __fastcall THardware::CheckBox2Click(TObject *Sender)
{
  if (autoIRQ)
    IRQ2timer->Enabled = CheckBox2->Checked;
}
//---------------------------------------------------------------------------

void __fastcall THardware::CheckBox3Click(TObject *Sender)
{
  if (autoIRQ)
    IRQ3timer->Enabled = CheckBox3->Checked;
}
//---------------------------------------------------------------------------

void __fastcall THardware::CheckBox4Click(TObject *Sender)
{
  if (autoIRQ)
    IRQ4timer->Enabled = CheckBox4->Checked;
}
//---------------------------------------------------------------------------

void __fastcall THardware::CheckBox5Click(TObject *Sender)
{
  if (autoIRQ)
    IRQ5timer->Enabled = CheckBox5->Checked;
}
//---------------------------------------------------------------------------

void __fastcall THardware::CheckBox6Click(TObject *Sender)
{
  if (autoIRQ)
    IRQ6timer->Enabled = CheckBox6->Checked;
}
//---------------------------------------------------------------------------

void __fastcall THardware::CheckBox7Click(TObject *Sender)
{
  if (autoIRQ)
    IRQ7timer->Enabled = CheckBox7->Checked;
}
//---------------------------------------------------------------------------

void __fastcall THardware::ROMStartEditChange(TObject *Sender)
{
  ROMStart = StrToInt("0x" + Hardware->ROMStartEdit->EditText);
}
//---------------------------------------------------------------------------

void __fastcall THardware::ROMEndEditChange(TObject *Sender)
{
  ROMEnd = StrToInt("0x" + Hardware->ROMEndEdit->EditText);
}
//---------------------------------------------------------------------------

void __fastcall THardware::ReadStartEditChange(TObject *Sender)
{
  ReadStart = StrToInt("0x" + Hardware->ReadStartEdit->EditText);
}
//---------------------------------------------------------------------------

void __fastcall THardware::ReadEndEditChange(TObject *Sender)
{
  ReadEnd = StrToInt("0x" + Hardware->ReadEndEdit->EditText);
}
//---------------------------------------------------------------------------

void __fastcall THardware::ProtectedStartEditChange(TObject *Sender)
{
  ProtectedStart = StrToInt("0x" + Hardware->ProtectedStartEdit->EditText);
}
//---------------------------------------------------------------------------

void __fastcall THardware::ProtectedEndEditChange(TObject *Sender)
{
  ProtectedEnd = StrToInt("0x" + Hardware->ProtectedEndEdit->EditText);
}
//---------------------------------------------------------------------------

void __fastcall THardware::InvalidStartEditChange(TObject *Sender)
{
  InvalidStart = StrToInt("0x" + Hardware->InvalidStartEdit->EditText);
}
//---------------------------------------------------------------------------

void __fastcall THardware::InvalidEndEditChange(TObject *Sender)
{
  InvalidEnd = StrToInt("0x" + Hardware->InvalidEndEdit->EditText);
}
//---------------------------------------------------------------------------

void __fastcall THardware::ROMChkClick(TObject *Sender)
{
  ROMMap = ROMChk->Checked;
}
//---------------------------------------------------------------------------

void __fastcall THardware::ReadChkClick(TObject *Sender)
{
  ReadMap = ReadChk->Checked;
}
//---------------------------------------------------------------------------

void __fastcall THardware::ProtectedChkClick(TObject *Sender)
{
  ProtectedMap = ProtectedChk->Checked;
}
//---------------------------------------------------------------------------

void __fastcall THardware::InvalidChkClick(TObject *Sender)
{
  InvalidMap = InvalidChk->Checked;
}
//---------------------------------------------------------------------------


