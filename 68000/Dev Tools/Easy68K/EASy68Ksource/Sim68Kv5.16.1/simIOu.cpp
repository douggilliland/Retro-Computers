//---------------------------------------------------------------------------
//   Author: Charles Kelly
//           www.easy68k.com
//---------------------------------------------------------------------------

#define INITGUID				// we use GUID's with DMusic

////// Includes
#include <vcl.h>
#include <vcl\mmsystem.hpp> // must have this for PlaySound() to work
#pragma hdrstop

#include "simIOu.h"
#include "SIM68Ku.h"
#include "extern.h"
#include "Memory1.h"
#include "hardwareu.h"


extern AnsiString errstr;
extern bool disableKeyCommands;  // defined in SIM68Ku

//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TsimIO *simIO;
int row, col, textX, textY, x, y;
char *inputCh;                  // char input buffer
const int KEYBUF_SIZE = 256;
char keyBuf[KEYBUF_SIZE];       // text input buffer
char *userBuf;                  // location of user input buffer
long *inputLength;              // length of input
long *inputNumber;              // for numeric input
int keyI;                       // key index
bool promptVisible;             // used to flash prompt
bool charInput;                 // true if char input
bool doubleBuffer = false;
bool textWrap = false;

const ushort MIN_WIDTH = 640;
const ushort MIN_HEIGHT = 480;
int savedLeft = 0;
int savedTop = 0;
int canWidth = MIN_WIDTH;       // width and height of canvas
int canHeight = MIN_HEIGHT;
int rowHeight, colWidth;        // row height and col width of text
AnsiString strCh;               // for faster charOut
TRect r;
uint textRows = 0, textCols = 0;
const int MAX_ROWS = 128, MAX_COLS = 256;
char* text = NULL;              // onscreen characters

// wav pointers, used by trap code 72 when wav files are loaded into memory
const int WAVES = 256;
BYTE *wavemem[WAVES];
int currentWave = -1;           // the index of the current wave playing in standard player

////// DirectMusic variables
IDirectMusicLoader8 *dmusicLoader = NULL;		// the loader
IDirectMusicPerformance8 *dmusicPerformance = NULL;	// the performance
IDirectMusicSegment8 *dmusicSegment;                    // used by playSound to load and play sound
IDirectMusicSegment8 *dmusicSegments[WAVES];  	        // used by playSoundMem to play sound already loaded
HWND hwnd;

// track key presses on I/O screen
bool keys[256];
uchar keyDownCode;              // used by trap task #19
uchar keyUpCode;                // "

//---------------------------------------------------------------------------
// Constructor
//---------------------------------------------------------------------------
__fastcall TsimIO::TsimIO(TComponent* Owner) : TForm(Owner)
{
  try {
  row = 0;
  col = 0;
  textX = 0;
  textY = 0;
  x = 0;
  y = 0;
  inputMode = false;
  charInput = false;
  pendingKey = '\0';

  Canvas->Font->Assign(Form1->FontDialogSimIO->Font);
  Canvas->CopyMode = cmSrcCopy;
  Canvas->Brush->Color = clBlack;

  //create the back buffer "surface"
  BackBuffer = new Graphics::TBitmap;

  setWindowSize(MIN_WIDTH, MIN_HEIGHT);
  text = new char[MAX_COLS * MAX_ROWS];         // for saving onscreen text

  // clear sound pointers
  for (int i=0; i<WAVES; i++) {
    wavemem[i] = NULL;                  // used by PlaySound
    dmusicSegments[i] = NULL;               // used by DirectSound
  }

  // initialize COM for DirectSound
  if (dsoundExist) {
    if (FAILED(CoInitialize(NULL)))
      dsoundExist = false;
  }

  hwnd = Form1->Handle;

  // initialize DirectX Audio
  if (dsoundExist) {
    if (!InitDirectXAudio(hwnd))
       dsoundExist = false;
  }

  // init serial communications stuff
  ctmoNew.ReadIntervalTimeout = 1;
  ctmoNew.ReadTotalTimeoutConstant = 1;
  ctmoNew.ReadTotalTimeoutMultiplier = 1;
  ctmoNew.WriteTotalTimeoutMultiplier = 1;
  ctmoNew.WriteTotalTimeoutConstant = 100;

  // clear serial port hComm
  for(int i=0; i<MAX_COMM; i++)
    hComm[i] = NULL;

  this->DoubleBuffered = true;
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in TsimIO"));
    return;
  }
}

//---------------------------------------------------------------------------
// Destructor
//---------------------------------------------------------------------------
__fastcall TsimIO::~TsimIO()
{
  try {
  if (fullScreen){
    fullScreen = false;
    setupWindow();
  }

//  delete workCanvas;
  for (int i=0; i<WAVES; i++)   // free memory used by sounds
    if(wavemem[i])
      delete[] wavemem[i];

  // close down DirectMusic
  if(dsoundExist)
  {
    if(dmusicPerformance != NULL)
      CloseDown(dmusicPerformance);
    if(dmusicLoader != NULL)
      dmusicLoader->Release();
    if(dmusicPerformance != NULL)
      dmusicPerformance->Release();
    if(dmusicSegment != NULL)
      dmusicSegment->Release();
    for (int i=0; i<WAVES; i++) {  // free segments used by sounds
      if(dmusicSegments[i] != NULL)
        dmusicSegments[i]->Release();
    }
  }

  // close down COM
  CoUninitialize();

  if (text) delete [] text;

  if (BackBuffer) delete BackBuffer;

  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in ~TsimIO"));
    return;
  }
}

//---------------------------------------------------------------------------
//  FORM FUNCTIONS
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
//  Sets the window size
//---------------------------------------------------------------------------
void __fastcall TsimIO::setWindowSize(ushort width, ushort height)
{
  try {
  if (height == 0 && width == 0) {      // if use current height & width
    height = canHeight;
    width = canWidth;
  }
  if (height >= MIN_HEIGHT)
    canHeight = height;
  else
    canHeight = MIN_HEIGHT;
  if (width >= MIN_WIDTH)
    canWidth = width;
  else
    canWidth = MIN_WIDTH;

  simIO->ClientHeight = canHeight;  // height of canvas
  simIO->ClientWidth = canWidth;    // width of canvas
  simIO->PixelsPerInch = 96;

  BackBuffer->Height = canHeight;
  BackBuffer->Width = canWidth;

  TRect r = Rect(0,0,canWidth,canHeight);       // fill canvas with black
  BackBuffer->Canvas->CopyMode = cmBlackness;
  BackBuffer->Canvas->CopyRect(r, BackBuffer->Canvas, r);
  Canvas->CopyRect(r, BackBuffer->Canvas, r);

  BackBuffer->Canvas->Font = Canvas->Font;      // set backbuffer properties
  BackBuffer->Canvas->CopyMode = Canvas->CopyMode;
  BackBuffer->Canvas->Brush = Canvas->Brush;
  BackBuffer->Canvas->Pen = Canvas->Pen;
  BackBuffer->Canvas->PenPos = Canvas->PenPos;

  // save current form top left
  savedLeft = simIO->Left;
  savedTop = simIO->Top;
  setupWindow();

  setTextSize();
  Form1->WindowSizeChecked();

  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in setWindowSize"));
    return;
  }
}

//---------------------------------------------------------------------------
// Changes the resolution of the display device
//---------------------------------------------------------------------------
void __fastcall TsimIO::setupWindow()
{
  try {
  DWORD dwExStyle;
  DWORD dwStyle;
  RECT WindowRect;  //hold the dimensions of the window
  // fill the rectange struct
  WindowRect.left = (long) 0;
  WindowRect.right = (long) canWidth;
  WindowRect.top = (long) 0;
  WindowRect.bottom = (long) canHeight;

  if(fullScreen) {
    // save current form top left
    savedLeft = simIO->Left;
    savedTop = simIO->Top;

    // EnumDisplaySettings returns 0 for the frequency value indicating "Default".
    // However the default for different resolutions is different.
    // When you switch mode to a different frequency, you should set the frequency
    // variable to a different value from the current one if EnumDisplaySettings
    // indicated a different value was required. If it indicated 0, meaning default,
    // you should set the frequency as 0 but also set the DM_FREQUENCY flag in the
    // dmFields member of DEVMODE.  This tells Windows that the new default (0) is
    // not the same as the old default (also 0 but potentially meaning something
    // different from the original 0).

    DEVMODE dmScSettings; // device mode for the screen

    memset(&dmScSettings, 0, sizeof(dmScSettings)); //clear the memory
    dmScSettings.dmSize = sizeof(dmScSettings);
    dmScSettings.dmBitsPerPel = 32; // set the bits
    dmScSettings.dmPelsWidth = canWidth; // set the width
    dmScSettings.dmPelsHeight = canHeight; // set the height
    dmScSettings.dmDisplayFrequency = 0; // set the frequency to default
    dmScSettings.dmFields = DM_BITSPERPEL | DM_PELSWIDTH | DM_PELSHEIGHT | DM_DISPLAYFREQUENCY; // set the fields we used

    // if we can use the 98 and up APIs
    if (MultimonitorAPIsExist){
      DISPLAY_DEVICE mydevice;
      mydevice.cb = sizeof(DISPLAY_DEVICE);

      if ((*EnumDisplayDevicesAPtr)(NULL, FullScreenMonitor, &mydevice, NULL)){
        strcpy(FullScreenDeviceName, mydevice.DeviceName);

        // if fullscreen change fails
        if((*ChangeDisplaySettingsExAPtr)(FullScreenDeviceName, &dmScSettings, NULL, CDS_SET_PRIMARY | CDS_FULLSCREEN, NULL) != DISP_CHANGE_SUCCESSFUL){
          if (FullScreenMonitor != 0){
            FullScreenMonitor = 0;
            setupWindow();
            return;
          }else{
            Application->MessageBoxA("Sorry, this computer's configuration does not support the desired screen resolution in full screen mode.","Information");
            fullScreen = false;
            setupWindow();
            return;
          }
        }
      }else{
        if (FullScreenMonitor != 0){
          FullScreenMonitor = 0;
          setupWindow();
          return;
        }else{
          Application->MessageBoxA("Sorry, the program encountered an error when trying to read your computer's monitor configuration.","Information");
          fullScreen = false;
          return;
        }
      }

      // try to get new window position
      DEVMODE mydevmode;
      mydevmode.dmSize = sizeof(DEVMODE);
      mydevmode.dmDriverExtra = 0;
      if ((*EnumDisplaySettingsExAPtr)(FullScreenDeviceName, ENUM_CURRENT_SETTINGS, &mydevmode, NULL) == false){
        if (FullScreenMonitor != 0){
          fullScreen = false;
          setupWindow();
          FullScreenMonitor = 0;
          fullScreen = true;
          setupWindow();
          return;
        }else{
          Application->MessageBoxA("Sorry, the program encountered an error when trying to read your computer's monitor configuration.","Information");
          fullScreen = false;
          setupWindow();
        }
      }

      simIO->Left = mydevmode.dmPosition.x;
      simIO->Top = mydevmode.dmPosition.y;
    // if the advanced APIs we want to use don't exist
    }else{
      // if fullscreen change fails
      if(ChangeDisplaySettings(&dmScSettings, CDS_FULLSCREEN) != DISP_CHANGE_SUCCESSFUL){
        Application->MessageBoxA("Sorry, this computer's configuration does not support the desired resolution in full screen mode.","Information");
        fullScreen = false;
        return;
      }
      simIO->Left = 0;
      simIO->Top = 0;
    }

    // full screen settings
    simIO->BorderStyle = bsNone;
    simIO->FormStyle = fsStayOnTop;
    simIO->Width = canWidth;
    simIO->Height = canHeight;

  }else{        // window mode
    // if we can use the 98 and up APIs
    if (MultimonitorAPIsExist){
      (*ChangeDisplaySettingsExAPtr)(FullScreenDeviceName, NULL, NULL, 0, NULL);

    // if the advanced APIs we want to use don't exist
    }else{
      ChangeDisplaySettings(NULL, 0);
    }

    // window mode settings
    simIO->BorderStyle = bsSingle;
    simIO->FormStyle = fsNormal;
    simIO->Left = savedLeft;            // restore original top/left
    simIO->Top = savedTop;
    simIO->ClientHeight = canHeight;    // height of canvas in windowed mode
    simIO->ClientWidth = canWidth;      // width
  }
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in setupWindow"));
    return;
  }
}

//---------------------------------------------------------------------------
void __fastcall TsimIO::getWindowSize(ushort &width, ushort &height)
{
  height = canHeight;
  width = canWidth;
}

//---------------------------------------------------------------------------
void __fastcall TsimIO::FormPaint(TObject *Sender)
{
  try {
  //draw back buffer to form
  Canvas->Draw(0,0,BackBuffer);
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in FormPaint"));
    return;
  }
}

//---------------------------------------------------------------------------
// Call setTextSize whenever the font size changes
void __fastcall TsimIO::setTextSize()
{
  try {
  rowHeight = Canvas->TextHeight("Xp");
  colWidth  = Canvas->TextWidth("W");

  textRows = canHeight/rowHeight;
  if (textRows > MAX_ROWS)
    textRows = MAX_ROWS;                // limit number of rows and cols
  textCols = canWidth/colWidth;         // (should never happen)
  if (textCols > MAX_COLS)
    textCols = MAX_COLS;
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in setTextSize"));
    return;
  }
}

//---------------------------------------------------------------------------
void __fastcall TsimIO::FormResize(TObject *Sender)
{
  //simIO->Repaint();
}

//---------------------------------------------------------------------------
void __fastcall TsimIO::FormKeyDown(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  try {
  char inBuf[256];

  keys[(uchar)Key] = true;              // track key press
  keyDownCode = (char)Key;              // save code for use by trap task #19
  if (keyDownIRQ)
    Hardware->IRQprocess(keyDownIRQ);

  if (disableKeyCommands)               // if user has disabled simulator shortcut keys
  {
    Key = 0;
    return;
  }

  if (Key == VK_TAB && Shift.Contains(ssCtrl))    // if Ctrl-Tab
    MemoryFrm->BringToFront();
  else if (Key == VK_RETURN && Shift.Contains(ssAlt)) {  // if Alt-Enter
    fullScreen = !fullScreen;           // toggle full screen output
    setupWindow();
  } else if (Key == VK_INSERT && Shift.Contains(ssShift)) {  // if Shift-Insert
    Clipboard()->GetTextBuf( inBuf, 255);
    inBuf[255] = '\0';
    for (int i=0; inBuf[i]; i++)
      FormKeyPress(Sender, inBuf[i]);   // insert chars
  }
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in FormKeyDown"));
    return;
  }
}

//---------------------------------------------------------------------------
void __fastcall TsimIO::FormKeyUp(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  try {
  keys[(uchar)Key] = false;              // track key press
  keyUpCode = (char)Key;
  if (keyUpIRQ)
    Hardware->IRQprocess(keyUpIRQ);
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in FormKeyUp"));
    return;
  }
}

//-----------------------------------------------------------------------
// Display File Dialog
void __fastcall TsimIO::displayFileDialog(long *mode, int A1, int A2, int A3, short *result)
{
  try {
  char title[256];              // title buffer
  char ext[256];                // extensions
  char path[256];               // file path
  char *inTitle, *inExt, *inPath;
  AnsiString fileName;

  clearKeys();                  // key up/down array is cleared because dialog intercepts key presses
  
  *result = F_SUCCESS;          // default to success
  if (A1 != 0) {
    inTitle = &memory[A1 & ADDRMASK];
    strncpy(title,inTitle,255); // make copy of string so we can terminate it
  } else
    title[0] = '\0';
  title[255] = '\0';        // Terminated!, in case it wasn't already

  if (A2 != 0) {
    inExt = &memory[A2 & ADDRMASK];
    strncpy(ext,inExt,255); // make copy of string so we can terminate it
  } else
    ext[0] = '\0';
  ext[255] = '\0';        // Terminated!, in case it wasn't already

  inPath = &memory[A3 & ADDRMASK];
  strncpy(path,inPath,255); // make copy of string so we can terminate it
  path[255] = '\0';        // Terminated!, in case it wasn't already

  switch (*mode) {
    case 0:             // 'Open' dialog
      if (title[0] != '\0')     // if title present
        OpenDialogIO->Title = AnsiString(title);
      else
        OpenDialogIO->Title = "";
      if (ext[0] != '\0')       // if extension list present
        OpenDialogIO->Filter = AnsiString(ext) + "|" + AnsiString(ext);
      else
        OpenDialogIO->Filter = "";
      if (path[0] != '\0')      // if file path present
        OpenDialogIO->FileName = AnsiString(path);
      else
        OpenDialogIO->FileName = "";
      if (OpenDialogIO->Execute()) {
        fileName = OpenDialogIO->FileName;    // get filename
        int nameLength = fileName.Length();
        if (nameLength > 255)                                   // limit length
          nameLength = 255;
        // if buffer overflows 68000 memory
        if ((unsigned int)(A3 + nameLength) > MEMSIZE) {
          *result = F_ERROR;            // error
          return;
        }
        strncpy(inPath,OpenDialogIO->FileName.c_str(),255);
        inPath[255]='\0';
        *mode = 1;              // d1 = 1 if user opens file
      }else
        *mode = 0;              // d1 = 0 if user cancels
      break;

    case 1:             // 'Save' dialog
      if (title[0] != '\0')     // if title present
        SaveDialogIO->Title = AnsiString(title);
      else
        SaveDialogIO->Title = "";
      if (ext[0] != '\0')       // if extension list present
        SaveDialogIO->Filter = AnsiString(ext) + "|" + AnsiString(ext);
      else
        SaveDialogIO->Filter = "";
      if (path[0] != '\0')      // if file path present
        SaveDialogIO->FileName = AnsiString(path);
      else
        OpenDialogIO->FileName = "";
      if (SaveDialogIO->Execute()) {
        fileName = OpenDialogIO->FileName;    // get filename
        int nameLength = fileName.Length();
        if (nameLength > 255)                                   // limit length
          nameLength = 255;
        // if buffer overflows 68000 memory
        if ((unsigned int)(A3 + nameLength) > MEMSIZE) {
          *result = F_ERROR;            // error
          return;
        }
        strncpy(inPath,SaveDialogIO->FileName.c_str(),255);
        inPath[255]='\0';
        *mode = 1;              // d1 = 1 if user opens file
      }else
        *mode = 0;              // d1 = 0 if user cancels
      break;
  }
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in displayFileDialog"));
    return;
  }
}


//---------------------------------------------------------------------------
void __fastcall TsimIO::BringToFront()
{
  try {
  if(simIO->Visible)
    simIO->SetFocus();
  else
    MemoryFrm->BringToFront();
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in BringToFront"));
    return;
  }
}

//---------------------------------------------------------------------------
// get state of 4 keys as defined in codes (1 byte each)
// return in codes as $00 if key up, $FF if key down (4 bytes)
// or return key code of last keypress
void __fastcall TsimIO::getKeyState(long *codes)
{
  try {
  long code = *codes;
  long keyState = 0;

  if (code == 0) {                // if request scan code of last keypress
    code = (keyUpCode << 16) + keyDownCode;
    *codes = code;
    return;
  }

  if (keys[(uchar)code])
    keyState = 0xFF;
  code = code >> 8;
  if(keys[(uchar)code])
    keyState += 0xFF00;
  code = code >> 8;
  if(keys[(uchar)code])
    keyState += 0xFF0000;
  code = code >> 8;
  if(keys[(uchar)code])
    keyState += 0xFF000000;
  *codes = keyState;
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in getKeyState"));
    return;
  }
}

//---------------------------------------------------------------------------
void __fastcall TsimIO::FormActivate(TObject *Sender)
{
  clearKeys();
}

//---------------------------------------------------------------------------
void __fastcall TsimIO::clearKeys()
{
  try {
  keyDownCode = 0;
  keyUpCode = 0;
  for (int i=0; i<256; i++)
    keys[i] = false;
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in clearKeys"));
    return;
  }
}


//---------------------------------------------------------------------------
void __fastcall TsimIO::FormMouseDown(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{
  try {
  mouseX = X;
  mouseY = Y;
  mouseXDown = X;
  mouseYDown = Y;
  if (Shift.Contains(ssLeft)) {
    mouseLeft = true;
    mouseLeftDown = true;
  } else {
    mouseLeft = false;
    mouseLeftDown = false;
  }
  if (Shift.Contains(ssRight)) {
    mouseRight = true;
    mouseRightDown = true;
  } else {
    mouseRight = false;
    mouseRightDown = false;
  }
  if (Shift.Contains(ssMiddle)) {
    mouseMiddle = true;
    mouseMiddleDown = true;
  } else {
    mouseMiddle = false;
    mouseMiddleDown = false;
  }
  if (Shift.Contains(ssDouble)) {
    mouseDouble = true;
    mouseDoubleDown = true;
  } else {
    mouseDouble = false;
    mouseDoubleDown = false;
  }
  if (Shift.Contains(ssShift)) {
    keyShift = true;
    keyShiftDown = true;
  } else {
    keyShift = false;
    keyShiftDown = false;
  }
  if (Shift.Contains(ssAlt)) {
    keyAlt = true;
    keyAltDown = true;
  } else {
    keyAlt = false;
    keyAltDown = false;
  }
  if (Shift.Contains(ssCtrl)) {
    keyCtrl = true;
    keyCtrlDown = true;
  } else {
    keyCtrl = false;
    keyCtrlDown = false;
  }

  if (mouseDownIRQ)
    Hardware->IRQprocess(mouseDownIRQ);
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in FormMouseDown"));
    return;
  }
}

//---------------------------------------------------------------------------
void __fastcall TsimIO::FormMouseUp(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{
  try {
  mouseX = X;
  mouseY = Y;
  mouseXUp = X;
  mouseYUp = Y;
  if (Shift.Contains(ssLeft)) {
    mouseLeft = true;
    mouseLeftUp = true;
  } else {
    mouseLeft = false;
    mouseLeftUp = false;
  }
  if (Shift.Contains(ssRight)) {
    mouseRight = true;
    mouseRightUp = true;
  } else {
    mouseRight = false;
    mouseRightUp = false;
  }
  if (Shift.Contains(ssMiddle)) {
    mouseMiddle = true;
    mouseMiddleUp = true;
  } else {
    mouseMiddle = false;
    mouseMiddleUp = false;
  }
  if (Shift.Contains(ssDouble)) {
    mouseDouble = true;
    mouseDoubleUp = true;
  } else {
    mouseDouble = false;
    mouseDoubleUp = false;
  }
  if (Shift.Contains(ssShift)) {
    keyShift = true;
    keyShiftUp = true;
  } else {
    keyShift = false;
    keyShiftUp = false;
  }
  if (Shift.Contains(ssAlt)) {
    keyAlt = true;
    keyAltUp = true;
  } else {
    keyAlt = false;
    keyAltUp = false;
  }
  if (Shift.Contains(ssCtrl)) {
    keyCtrl = true;
    keyCtrlUp = true;
  } else {
    keyCtrl = false;
    keyCtrlUp = false;
  }
  if (mouseUpIRQ)
    Hardware->IRQprocess(mouseUpIRQ);
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in FormMouseUp"));
    return;
  }
}

//---------------------------------------------------------------------------
void __fastcall TsimIO::FormMouseMove(TObject *Sender, TShiftState Shift,
      int X, int Y)
{
  try {
  mouseX = X;
  mouseY = Y;
  if (Shift.Contains(ssShift))
    keyShift = true;
  else
    keyShift = false;
  if (Shift.Contains(ssAlt))
    keyAlt = true;
  else
    keyAlt = false;
  if (Shift.Contains(ssCtrl))
    keyCtrl = true;
  else
    keyCtrl = false;
  if (mouseMoveIRQ)
    Hardware->IRQprocess(mouseMoveIRQ);
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in FormMouseMove"));
    return;
  }
}

//---------------------------------------------------------------------------
//  TEXT FUNCTIONS called by Trap #15 handler
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
//  charOut
//  Display character at x,y
//  Handle control characters
//  \a	0x07	BEL	Audible bell
//  \b	0x08	BS	Backspace
//  \f	0x0C	FF	Formfeed
//  \n	0x0A	LF	Newline (linefeed)
//  \r	0x0D	CR	Carriage return
//  \t	0x09	HT	Tab (horizontal)
//  \v	0x0B	VT	Vertical tab

void __fastcall TsimIO::charOut(char ch)
{
  try {
  if (simIO->Visible == false)  // if I/O form not visible,
    simIO->Show();
  switch (ch) {
    case '\a':                  // if Bell
      Beep();
      break;
    case '\b':                  // if Backspace
      col--;
      if (logging && OlogFlag == TEXTONLY) {    // if logging output
        fprintf(OlogFile,"%c",ch);
        fflush(OlogFile);       // write all bufferred data to file
      }
      break;
    case '\f':                  // if Formfeed
      clear();                  // treat like HOME command
      if (logging && OlogFlag == TEXTONLY) {    // if logging output
        fprintf(OlogFile,"%c",ch);
        fflush(OlogFile);       // write all bufferred data to file
      }
      break;
    case '\n':                  // if LF
      row++;
      if (logging && OlogFlag == TEXTONLY) {    // if logging output
        fprintf(OlogFile,"%c",ch);
        fflush(OlogFile);       // write all bufferred data to file
      }
      break;
    case '\r':                  // if CR
      col = 0;
      if (logging && OlogFlag == TEXTONLY) {    // if logging output
        fprintf(OlogFile,"%c",ch);
        fflush(OlogFile);       // write all bufferred data to file
      }
      break;
    case '\t':                  // if Tab
      col += 5;
      if (logging && OlogFlag == TEXTONLY) {    // if logging output
        fprintf(OlogFile,"%c",ch);
        fflush(OlogFile);       // write all bufferred data to file
      }
      break;
    case '\v':                  // if Vertical tab
      row += 4;
      if (logging && OlogFlag == TEXTONLY) {    // if logging output
        fprintf(OlogFile,"%c",ch);
        fflush(OlogFile);       // write all bufferred data to file
      }
      break;
    default:
      if (ch < 0 || ch >= 0x20) {       // if not control char
        strCh = ch;
        BackBuffer->Canvas->TextOutA(textX, textY, strCh);
        text[row*textCols + col] = ch;  // save char in text array
        if (doubleBuffer == false)
          Canvas->TextOutA(textX, textY, strCh);
        col++;
        if (logging && OlogFlag == TEXTONLY) {     // if logging output
          fprintf(OlogFile,"%c",ch);
          fflush(OlogFile);         // write all bufferred data to file
        }
      }
  }

  gotorc(row, col);
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("charOut"));
    return;
  }
}

//---------------------------------------------------------------------------
//  textOut
//  Display string at x,y without CR
void __fastcall TsimIO::textOut(AnsiString str)
{
  try {
  int n = str.Length();
  for (int i=1; i<=n; i++)
    charOut(str[i]);
  if (doubleBuffer == false)
    this->Repaint();  // ck, 2 textOut in a row resulted in delay before 2nd output was visible
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in textOut"));
    return;
  }
}

//---------------------------------------------------------------------------
//  drawText
//  Draw string at x,y as graphics
//  The text is not made part of the text array and may not be read using
//  trap task 22. Allows positioning text at exact pixels.
void __fastcall TsimIO::drawText(AnsiString str, int x, int y)
{
  try {
  BackBuffer->Canvas->TextOutA(x, y, str);
  if (doubleBuffer == false)
    Canvas->TextOutA(x, y, str);
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in drawText"));
    return;
  }
}

//---------------------------------------------------------------------------
//  textOutCR
//  Display string at x,y with CR
void __fastcall TsimIO::textOutCR(AnsiString str)
{
  try {
  int n = str.Length();
  for (int i=1; i<=n; i++)
    charOut(str[i]);
  doCRLF();
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in textOutCR"));
    return;
  }
}

//---------------------------------------------------------------------------
void __fastcall TsimIO::setFontProperties(int c, int s)
{
  TFont* f = NULL;
  try {
  f = new TFont();
  f->Assign(Form1->FontDialogSimIO->Font);

  f->Color = (TColor) c;
  f->Style = TFontStyles();      // clear all styles
  if (s & 0x01) {       // if Bold
    f->Style = TFontStyles()<< fsBold;
  }
  if (s & 0x02) {       // if Italic
    f->Style = TFontStyles()<< fsItalic;
  }
  if (s & 0x04) {       // if Underline
    f->Style = TFontStyles()<< fsUnderline;
  }
  if (s & 0x08) {       // if StrikeOut
    f->Style = TFontStyles()<< fsStrikeOut;
  }

  // Set font name and size
  s = (s & 0xFFFF0000) >> 16;
  if (s != 0) {
    switch ((s & 0xFF00)>>8) {
      case 1:
        f->Name = "Fixedsys";
        break;
      case 2:
        f->Name = "Courier";
        break;
      case 3:
        f->Name = "Courier New";
        break;
      case 4:
        f->Name = "Lucida Console";
        break;
      case 5:
        f->Name = "Lucida Sans Typerwriter";
        break;
      case 6:
        f->Name = "Consolas";
        break;
      case 7:
        f->Name = "Terminal";
        break;
    }
    f->Size = s & 0x00FF;
  }
  BackBuffer->Canvas->Font->Assign(f);
  Canvas->Font->Assign(f);
  setTextSize();
  gotorc(row, col);

  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in setFontProperties"));
  }
  if(f) delete f;
}

//---------------------------------------------------------------------------
//  doCRLF
void __fastcall TsimIO::doCRLF()
{
  try {
  col=0;
  row++;
  gotorc(row, col);
  if (logging && OlogFlag == TEXTONLY) {      // if logging output
    fprintf(OlogFile,"\n");
    fflush(OlogFile);         // write all bufferred data to file
  }
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in doCRLF"));
    return;
  }
}

//---------------------------------------------------------------------------
// clear the screen
void __fastcall TsimIO::clear()
{
  try {
  gotorc(0, 0);
  TRect r = Rect(0,0,ClientWidth,ClientHeight);
  BackBuffer->Canvas->CopyMode = cmBlackness;           // fill canvas with black
  BackBuffer->Canvas->CopyRect(r, BackBuffer->Canvas, r);
  BackBuffer->Canvas->CopyMode = cmSrcCopy;
  if (doubleBuffer == false)
    Canvas->CopyRect(r, BackBuffer->Canvas, r);
  if (text) {
    for (uint i=0; i<MAX_ROWS; i++)
      for (uint j=0; j<MAX_COLS; j++)
        text[i*MAX_COLS + j] = ' ';
  }
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in clear"));
    return;
  }
}

//---------------------------------------------------------------------------
// goto row col
void __fastcall TsimIO::gotorc(int r, int c)
{
  try {
  if (r < 0)
    r = 0;
  else if ( (rowHeight * r) > (canHeight - rowHeight) ) {
    scroll();
    r = canHeight/rowHeight - 1;
  }
  if (c < 0)
    c = 0;
  else if ( (colWidth * c) > (canWidth - colWidth) && textWrap)
  {
    doCRLF();
    return;
  }

  textY = rowHeight * r;
  row = r;
  if (row >= MAX_ROWS)
    row = MAX_ROWS - 1;         // probably never happen but just being careful
  textX = colWidth * c;
  col = c;
  if (col >= MAX_COLS)
    col = MAX_COLS - 1;         // probably never happen .....
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in gotorc"));
    return;
  }
}

//---------------------------------------------------------------------------
// Returns COL in high byte of D1.W and ROW in low byte of D1.W.
void __fastcall TsimIO::getrc(short* d1)
{
  try {
  *d1 = (short)(((char)col << 8) | (char)row);
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in getrc"));
    return;
  }
}

//---------------------------------------------------------------------------
// Returns character at r,c in D1.B
void __fastcall TsimIO::getCharAt(ushort r, ushort c, char* d1)
{
  try {
  if (r >= MAX_ROWS)
    r = MAX_ROWS-1;
  if (c >= MAX_COLS)
    c = MAX_COLS-1;
  *d1 = text[r*textCols + c];
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in getCharAt"));
    return;
  }
}

//---------------------------------------------------------------------------
void __fastcall TsimIO::setTextWrap(bool b)
{
  textWrap = b;
}

//---------------------------------------------------------------------------
// scroll
// scroll the text up by one row
void __fastcall TsimIO::scroll()
{
  try {
  TRect TopRect, BotRect;

  TopRect = Rect(0,                                     // left
                 0,                                     // top
                 canWidth,                              // right
                 canHeight - rowHeight);                // bottom

  BotRect = Rect(0,                                     // left
                 rowHeight,                             // top
                 canWidth,                              // right
                 canHeight);                            // bottom

  BackBuffer->Canvas->CopyRect(TopRect, BackBuffer->Canvas, BotRect);
  if (doubleBuffer == false)
    Canvas->CopyRect(TopRect, BackBuffer->Canvas, TopRect);

  // erase bottom row
  BotRect = Rect(0,canHeight - rowHeight,canWidth,canHeight);
  BackBuffer->Canvas->CopyMode = cmBlackness;           // fill canvas with black
  BackBuffer->Canvas->CopyRect(BotRect, BackBuffer->Canvas, BotRect);
  BackBuffer->Canvas->CopyMode = cmSrcCopy;
  if (doubleBuffer == false)
    Canvas->CopyRect(BotRect, BackBuffer->Canvas, BotRect);

  // scroll text array
  for (uint i=0; i<textRows-1; i++)
    for (uint j=0; j<textCols; j++)
      text[i*textCols + j] = text[(i+1)*textCols + j];
  for (uint j=0; j<textCols; j++)               // fill bottom row with spaces
    text[(textRows-1)*textCols + j] = ' ';
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in scroll"));
    return;
  }
}

//---------------------------------------------------------------------------
// scrollRect
// scroll the text in the specified text rectangle up,down,left or right by one character
// dir = 0 up, 1 down, other values reserved
// invalid text areas are ignored
void __fastcall TsimIO::scrollRect(ushort r, ushort c, ushort h, ushort w, ushort dir)
{
  try {
  TRect TopRect, BotRect, LeftRect, RightRect;

  if ( (r+h >= MAX_ROWS) || (c+w >= MAX_COLS) || (w == 0) || (h == 0) )   // if invalid text rectangle
    return;

  TopRect = Rect(c*colWidth,                            // left
                 r*rowHeight,                           // top
                 (c+w)*colWidth,                        // right
                 (r+h-1)*rowHeight);                    // bottom

  BotRect = Rect(c*colWidth,                            // left
                 (r+1)*rowHeight,                       // top
                 (c+w)*colWidth,                        // right
                 (r+h)*rowHeight);                      // bottom

  LeftRect = Rect(c*colWidth,                           // left
                  r*rowHeight,                          // top
                 (c+w-1)*colWidth,                      // right
                 (r+h)*rowHeight);                      // bottom

  RightRect = Rect((c+1)*colWidth,                      // left
                    r*rowHeight,                        // top
                   (c+w)*colWidth,                      // right
                   (r+h)*rowHeight);                    // bottom


  switch (dir) {

  case 0: // ^^^^^ UP ^^^^^
    BackBuffer->Canvas->CopyRect(TopRect, BackBuffer->Canvas, BotRect);
    if (doubleBuffer == false)
      Canvas->CopyRect(TopRect, BackBuffer->Canvas, TopRect);

    // erase bottom row
    BotRect = Rect(c*colWidth,(r+h-1)*rowHeight,(c+w)*colWidth,(r+h)*rowHeight);
    BackBuffer->Canvas->CopyMode = cmBlackness;           // fill canvas with black
    BackBuffer->Canvas->CopyRect(BotRect, BackBuffer->Canvas, BotRect);
    BackBuffer->Canvas->CopyMode = cmSrcCopy;
    if (doubleBuffer == false)
      Canvas->CopyRect(BotRect, BackBuffer->Canvas, BotRect);

    // scroll text array up
    for (ushort i=r; i<r+h; i++)          // for each row
      for (ushort j=c; j<c+w; j++)        // for each col
        text[i*textCols + j] = text[(i+1)*textCols + j];
    for (ushort j=c; j<c+w; j++)               // fill bottom row with spaces
      text[(r+h-1)*textCols + j] = ' ';

    break;

  case 1: // vvvvv DOWN vvvvv
    BackBuffer->Canvas->CopyRect(BotRect, BackBuffer->Canvas, TopRect);
    if (doubleBuffer == false)
      Canvas->CopyRect(BotRect, BackBuffer->Canvas, BotRect);

    // erase top row
    TopRect = Rect(c*colWidth,r*rowHeight,(c+w)*colWidth,(r+1)*rowHeight);
    BackBuffer->Canvas->CopyMode = cmBlackness;           // fill canvas with black
    BackBuffer->Canvas->CopyRect(TopRect, BackBuffer->Canvas, TopRect);
    BackBuffer->Canvas->CopyMode = cmSrcCopy;
    if (doubleBuffer == false)
      Canvas->CopyRect(TopRect, BackBuffer->Canvas, TopRect);

    // scroll text array down
    for (ushort i=r+h-1; i>r; i--)          // for each row
      for (ushort j=c; j<c+w; j++)          // for each col
        text[i*textCols + j] = text[(i-1)*textCols + j];
    for (ushort j=c; j<c+w; j++)            // fill top row with spaces
      text[r*textCols + j] = ' ';

    break;

  case 2: // <<<<< LEFT <<<<<
    BackBuffer->Canvas->CopyRect(LeftRect, BackBuffer->Canvas, RightRect);
    if (doubleBuffer == false)
      Canvas->CopyRect(LeftRect, BackBuffer->Canvas, LeftRect);

    // erase right col
    RightRect = Rect((c+w-1)*colWidth,r*rowHeight,(c+w)*colWidth,(r+h)*rowHeight);
    BackBuffer->Canvas->CopyMode = cmBlackness;           // fill canvas with black
    BackBuffer->Canvas->CopyRect(RightRect, BackBuffer->Canvas, RightRect);
    BackBuffer->Canvas->CopyMode = cmSrcCopy;
    if (doubleBuffer == false)
      Canvas->CopyRect(RightRect, BackBuffer->Canvas, RightRect);

    // scroll text array left
    for (ushort j=c; j<c+w; j++)        // for each col
      for (ushort i=r; i<r+h; i++)      // for each row
        text[i*textCols + j] = text[i*textCols + j+1];
    for (ushort i=r; i<r+h; i++)        // fill right col with spaces
      text[i*textCols + c+w-1] = ' ';
    break;

  case 3: // >>>>> RIGHT >>>>>
    BackBuffer->Canvas->CopyRect(RightRect, BackBuffer->Canvas, LeftRect);
    if (doubleBuffer == false)
      Canvas->CopyRect(RightRect, BackBuffer->Canvas, RightRect);

    // erase left col
    LeftRect = Rect(c*colWidth,r*rowHeight,(c+1)*colWidth,(r+h)*rowHeight);
    BackBuffer->Canvas->CopyMode = cmBlackness;           // fill canvas with black
    BackBuffer->Canvas->CopyRect(LeftRect, BackBuffer->Canvas, LeftRect);
    BackBuffer->Canvas->CopyMode = cmSrcCopy;
    if (doubleBuffer == false)
      Canvas->CopyRect(LeftRect, BackBuffer->Canvas, LeftRect);

    // scroll text array right
    for (ushort j=c+w-1; j>c; j--)      // for each col
      for (ushort i=r; i<r+h; i++)      // for each row
        text[i*textCols + j] = text[i*textCols + j-1];
    for (ushort i=r; i<r+h; i++)        // fill left col with spaces
      text[i*textCols + c] = ' ';
    break;
  }
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in scrollRect"));
    return;
  }
}


//---------------------------------------------------------------------------
//  charIn
//  get one character from keyboard
void __fastcall TsimIO::charIn(char *ch)
{
  try {
  char str[2];
  long size;
  if (pendingKey) {             // if key already pressed
    *ch = pendingKey;
    if (keyboardEcho) {
      if (pendingKey != '\b')   // if not backspace
        charOut(pendingKey);
      if (pendingKey == '\r')   // if CR
        charOut('\n');          // do LF
    }
    pendingKey = 0;             // clear pendingKey
    return;
  }
  inputCh = ch;                 // location to save input char
  charInput = true;
  textIn(str, &size, NULL);
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in charIn"));
    return;
  }
}

//---------------------------------------------------------------------------
// textIn
// Read keyboard string into str (max 80) set size
// inNum: NULL = leave data as string in buffer
//     address = convert string to number and store at address
//             The conversion happens in FormKeyPress (below)
void __fastcall TsimIO::textIn(char *str, long *size, long *inNum)
{
  try {
  userBuf = str;                // point userBuf at users input buffer
  inputLength = size;           // point to size
  inputNumber = inNum;          // for numeric input
  keyI = 0;                     // clear key index
  inputMode = true;             // enable keyboard input
  if (pendingKey) {             // if key already pressed
    FormKeyPress(this, pendingKey);
    pendingKey = 0;             // clear pendingKey
  }

  if (inputPrompt) {            // if input prompt wanted
    prompt->Enabled = true;     // display prompt
    promptVisible = true;       // flash state
  }
  simIO->Show();                // display input form
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in textIn"));
    return;
  }
}

//---------------------------------------------------------------------------
void __fastcall TsimIO::FormKeyPress(TObject *Sender, char &Key)
{
  try {
  if (inputMode) {
    // if Enter key, limit reached or char input
    if (Key == '\r' || keyI >= 79 || charInput) {
      erasePrompt();
      if (charInput) {
        *inputCh = Key;         // get key
        charInput = false;
        if (keyboardEcho) {
          charOut(Key);
          if (Key == '\r' && inputLFdisplay) // if CR and LF display wanted
            charOut('\n');      // do LF
          //simIO->Repaint();
          this->Invalidate();
        }
      } else {
        doCRLF();                       // display CRLF
        keyBuf[keyI] = '\0';            // terminate input buffer
        if(inputNumber == NULL)         // if string input
        {
          for(int i=0; i<=keyI; i++)    // put string in 68000 memory at userBuf
            mem_put(keyBuf[i], (int)&userBuf[i]-(int)&memory[0], BYTE_MASK);
          *inputLength = keyI;            // length of input string to D1
        }else{                          // else numeric input
          strcpy(inputBuf,keyBuf);        // copy to sim68K inputBuf
          *inputLength = keyI;            // length of input string to D1
          *inputNumber = atoi(inputBuf);  // convert string to int
        }
      }
      inputMode = false;        // disable input mode
      if (trace) {              // if tracing
        Form1->setMenuActive();   // enable debug commands
        Hardware->enable();
        scrshow();              // update register display
        Form1->SetFocus();      // bring Form1 to top
      }
    } else if (Key == VK_BACK) {        // if Backspace key
      keyI--;                   // remove one char from buffer
      if (keyI < 0)
        keyI = 0;
      else {
        erasePrompt();
        gotorc(row,col-1);      // back up 1 column
        keyBuf[keyI] = '\0';    // temporarily terminate input buffer
        if (keyboardEcho) {
          BackBuffer->Canvas->TextOutA(textX, textY, " "); // erase visible char
          if (doubleBuffer == false)
            Canvas->TextOutA(textX, textY, " "); // erase visible char
        }
        //simIO->Repaint();
        this->Invalidate();
        if (inputPrompt)          // if input prompt wanted
          prompt->Enabled = true; // display prompt
      }
    } else {
      keyBuf[keyI++] = Key;     // get key
      keyBuf[keyI] = '\0';      // temporarily terminate input buffer
      prompt->Enabled = false;  // temporarily stop display of prompt
      if (keyboardEcho) {
        BackBuffer->Canvas->TextOutA(textX, textY, keyBuf[keyI-1]); // display input char
        if (doubleBuffer == false)
          Canvas->TextOutA(textX, textY, keyBuf[keyI-1]); // display input char
        if (logging && OlogFlag == TEXTONLY) {      // if logging output
          fprintf(OlogFile,"%c",keyBuf[keyI-1]);
          fflush(OlogFile);         // write all bufferred data to file
        }
      }
      gotorc(row,col+1);        // advance 1 column
      //simIO->Repaint();
      this->Invalidate();
      if (inputPrompt)            // if input prompt wanted
        prompt->Enabled = true;   // display prompt
    }
  } else {
    pendingKey = Key;
  }
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in FormKeyPress"));
    return;
  }
}


//---------------------------------------------------------------------------
void __fastcall TsimIO::promptTimer(TObject *Sender)
{
  try {
  int promptX = colWidth * col;
  if (doubleBuffer == false) {
    if (promptVisible) {          // if prompt visible
      Canvas->TextOutA(promptX, textY, " ");   // erase prompt
      promptVisible = false;
    } else {
      Canvas->TextOutA(promptX, textY, "_");   // display prompt
      promptVisible = true;
    }
  }
  } catch( ... ) {}
}


//---------------------------------------------------------------------------
// erase prompt
void __fastcall TsimIO::erasePrompt()
{
  try {
  if (inputPrompt) {            // if input prompt wanted
    int promptX = colWidth * col;

    prompt->Enabled = false;    // stop display of prompt
    Canvas->TextOutA(promptX, textY, " ");   // erase prompt
  }
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in erasePrompt"));
    return;
  }
}

//--------------------------------------------------------------------
//	DirectMusic Interfaces
//--------------------------------------------------------------------

// InitDirectXAudio()
// desc: initializes the DirectX Audio component for playback
bool TsimIO::InitDirectXAudio(HWND hwnd)
{
  try {
  char pathStr[MAX_PATH];		// path for audio file
  WCHAR wcharStr[MAX_PATH];

  // create the loader object
  if (FAILED(CoCreateInstance(CLSID_DirectMusicLoader, NULL, CLSCTX_INPROC,
                             IID_IDirectMusicLoader8, (void**)&dmusicLoader)))
  {
    Form1->Message->Lines->Add(errstr.sprintf("Unable to create the IDirectMusicLoader8 object!"));
    return false;
  }
  // create the performance object
  if (FAILED(CoCreateInstance(CLSID_DirectMusicPerformance, NULL, CLSCTX_INPROC,
                             IID_IDirectMusicPerformance8, (void**)&dmusicPerformance)))
  {
    Form1->Message->Lines->Add(errstr.sprintf("Unable to create the IDirectMusicPerformance8 object!"));
    return false;
  }
  // initialize the performance with the standard audio path
  dmusicPerformance->InitAudio(NULL, NULL, hwnd, DMUS_APATH_DYNAMIC_STEREO, 64,
                                              DMUS_AUDIOF_ALL, NULL);
  // retrieve the current directory
  GetCurrentDirectory(MAX_PATH, pathStr);

  // convert to unicode string
  MultiByteToWideChar(CP_ACP, 0, pathStr, -1, wcharStr, MAX_PATH);

  // set the search directory
  dmusicLoader->SetSearchDirectory(GUID_DirectMusicAllTypes, wcharStr, FALSE);
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in InitDirectXAudio"));
    return false;
  }
  return true;
}

// LoadSegment()
// desc: load a segment from a file
bool TsimIO::LoadSegment(HWND hwnd, char *filename, IDirectMusicSegment8* &dmSeg)
{
  try {
  WCHAR wcharStr[MAX_PATH];

  // convert filename to unicode string
  MultiByteToWideChar(CP_ACP, 0, filename, -1, wcharStr, MAX_PATH);

  // load the segment from file
  if (FAILED(dmusicLoader->LoadObjectFromFile(CLSID_DirectMusicSegment,
                                              IID_IDirectMusicSegment8,
                                              wcharStr,
                                              (void**)&dmSeg)))
  {
    Form1->Message->Lines->Add(errstr.sprintf("'%s' Error loading ",filename));
    return false;
  }
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in LoadSegment"));
    return false;
  }
  return true;
}

// PlaySegment()
// desc: start playing a segment
void TsimIO::PlaySegment(IDirectMusicPerformance8* dmPerf, IDirectMusicSegment8* dmSeg)
{
  try{
  // download the segment's instruments to the synthesizer
  dmSeg->Download(dmusicPerformance);

  // play the segment
  dmPerf->PlaySegmentEx(dmSeg, NULL, NULL,
                  DMUS_SEGF_DEFAULT | DMUS_SEGF_SECONDARY, 0, NULL, NULL,
                   NULL);
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in PlaySegment"));
    return;
  }
}

// PlaySegmentLoop()
// desc: the sound is looped until stopped
void TsimIO::PlaySegmentLoop(IDirectMusicPerformance8* dmPerf, IDirectMusicSegment8* dmSeg)
{
  try{
  // download the segment's instruments to the synthesizer
  dmSeg->Download(dmusicPerformance);

  // play the segment
  dmSeg->SetRepeats( DMUS_SEG_REPEAT_INFINITE );
  dmPerf->PlaySegmentEx(dmSeg, NULL, NULL,
                  DMUS_SEGF_DEFAULT | DMUS_SEGF_SECONDARY, 0, NULL, NULL,
                   NULL);
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in PlaySegmentLoop"));
    return;
  }
}

// StopSegment()
// desc: stop a segment from playing
void TsimIO::StopSegment(IDirectMusicPerformance8* dmPerf, IDirectMusicSegment8* dmSeg)
{
  try{
  // stop the dmSeg from playing
  dmPerf->StopEx(dmSeg, 0, 0);
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in StopSegment"));
    return;
  }
}

// CloseDown()
// desc: shutdown music performance
void TsimIO::CloseDown(IDirectMusicPerformance8* dmPerf)
{
  try{
  // stop the music
  dmPerf->Stop(NULL, NULL, 0, 0);

  // close down DirectMusic
  dmPerf->CloseDown();
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in simIO::CloseDown"));
    return;
  }
}

// ResetSounds()
// desc: Stops all playing sounds
// clears sound data from memory
void TsimIO::ResetSounds()
{
  try {
  // Stop any sounds that are playing with standard Windows player
  PlaySound(NULL, NULL, SND_PURGE);

  short result;
  // Stop DirectX sounds that are playing
  for (int i=0; i<WAVES; i++) {
    if(dmusicSegments[i] != NULL) {
      stopSoundMemDX(i, &result);
      dmusicSegments[i]->Release();     // release current data
    }
    delete[] wavemem[i];
    wavemem[i] = NULL;                  // used by PlaySound
    dmusicSegments[i] = NULL;           // used by DirectSound
  }
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in ResetSounds"));
    return;
  }
}

//---------------------------------------------------------------------------
//  SOUND FUNCTIONS called by Trap #15 handler
//---------------------------------------------------------------------------
// playSound
// post: result = true if sound played
//       result = 0 if player was busy playing a previous sound
void __fastcall TsimIO::playSound(char *fileName, short *result )
{
  try {
    if (FileExists(AnsiString(fileName))) {
      *result = (short) PlaySound(fileName, NULL,
                        SND_ASYNC | SND_NOSTOP | SND_FILENAME);
    } else {    // file not found
      Form1->Message->Lines->Add(errstr.sprintf("'%s' not found",fileName));
    }
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in playSound"));
    return;
  }
}

// pre: waveIndex is limited to 0 to 255
void __fastcall TsimIO::loadSound(char *fileName, int waveIndex)
{
  try {
    if (FileExists(AnsiString(fileName))) {
      TFileStream *WaveFile = new TFileStream(fileName, fmOpenRead);
      wavemem[waveIndex] = new BYTE[WaveFile->Size + 1];
      WaveFile->Read(wavemem[waveIndex], WaveFile->Size);
      delete WaveFile;
    } else {    // file not found
      Form1->Message->Lines->Add(errstr.sprintf("'%s' not found",fileName));
    }
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in loadSound"));
    return;
  }
}

// pre: waveIndex is limited to 0 to 255
// post: result = true if sound played
//       result = 0 if player was busy playing a previous sound
void __fastcall TsimIO::playSoundMem(int waveIndex, short *result)
{
  try {
    if (wavemem[waveIndex] != NULL) {
      currentWave = waveIndex;          // save index of current wave
      *result = (short) PlaySound(wavemem[waveIndex], NULL,
                                SND_ASYNC | SND_NOSTOP | SND_MEMORY);
    }
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in playSoundMem"));
    return;
  }
}

// control the standard sound player
// pre: waveIndex is limited to 0 to 255
//      control = 0, play sound once (same as playSoundMem)
//              = 1, play sound in loop
//              = 2, stop waveIndex sound
//              = 3, stop all sounds
//              = other values reserved
// post: result = true if sound played
//       result = 0 if player was busy playing a previous sound
void __fastcall TsimIO::controlSound(int control, int waveIndex, short *result)
{
  try {
    *result = 0;                        // default to error condition
    if (wavemem[waveIndex] != NULL) {   // if valid wave index
      switch(control) {
        case 0:         // play sound once
          currentWave = waveIndex;      // save wave index
          *result = (short) PlaySound(wavemem[waveIndex], NULL,
                                SND_ASYNC | SND_NOSTOP | SND_MEMORY);
          break;
        case 1:         // start looping sound
          currentWave = waveIndex;      // save wave index
          *result = (short) PlaySound(wavemem[waveIndex], NULL,
                                SND_ASYNC | SND_NOSTOP | SND_MEMORY | SND_LOOP);
          break;
        case 2:         // stop waveIndex sound
          if (waveIndex == currentWave) // if waveIndex sound playing
            *result = (short) PlaySound(NULL, NULL, SND_PURGE);
          break;
      }
    }
    if (control == 3)   // if stop all sounds command
      *result = (short) PlaySound(NULL, NULL, SND_PURGE);

  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in playSoundMem"));
    return;
  }
}

// Play the WAV file using DirectX player, if available.
//   pre: fileName null terminated path address.
//        Invalid file names are ignored.
//   post:  result = non zero if sound played successfully
//          result = 0 if DirectX player not available, sound is not played
void __fastcall TsimIO::playSoundDX(char *fileName, short *result )
{
  try {
    *result = 0;                        // default to DirectX not available
    if (!dsoundExist)                   // if DirectSound not available
      return;
    if (FileExists(AnsiString(fileName))) {
      if (LoadSegment(hwnd, fileName, dmusicSegment)) {
        // play the segment
        PlaySegment(dmusicPerformance, dmusicSegment);
        *result = 1;
      }
    } else {    // file not found
      Form1->Message->Lines->Add(errstr.sprintf("'%s' not found",fileName));
    }
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in playSoundDX"));
    return;
  }
}

// Load a WAV file into DirectX sound memory (not 68000 memory).
//   pre: fileName is null terminated path address. Invalid file names are ignored.
//        waveIndex is reference number limited to 0 to 255
//        A maximum of 256 sounds may be loaded at any one time.
//        Reusing a reference number causes the previous sound to be erased.
//   post: result = non zero if sound loaded successfully.
//         result = 0 if DirectX sound not available.
void __fastcall TsimIO::loadSoundDX(char *fileName, int waveIndex, short *result)
{
  try {
    *result = 0;                        // default to DirectX not available
    if(!dsoundExist)                    // if DirectSound not available
      return;
    if (FileExists(AnsiString(fileName))) {
      if(dmusicSegments[waveIndex] != NULL)   // if segment in use
        dmusicSegments[waveIndex]->Release(); // release current data
      if (LoadSegment(hwnd, fileName, dmusicSegments[waveIndex]))
        *result = 1;
    } else {    // file not found
      Form1->Message->Lines->Add(errstr.sprintf("'%s' not found",fileName));
    }
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in loadSoundDX"));
    return;
  }
}

// Play sound from DirectX memory using DirectX player.
//   pre:  waveIndex is reference number limited to 0 to 255
//   post: result = non zero if sound played successfully
//         result = 0 if DirectX player not available, sound is not played
void __fastcall TsimIO::playSoundMemDX(int waveIndex, short *result)
{
  try {
    *result = 0;                        // default to DirectX not available
    if(!dsoundExist)                    // if DirectSound not available
      return;
    if(dmusicSegments[waveIndex] != NULL) {
      PlaySegment(dmusicPerformance, dmusicSegments[waveIndex]);
      *result = 1;
    }
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in playSoundMem"));
    return;
  }
}

// Stop the DirectX sound that is playing from DirectX memory.
//   pre:  waveIndex is reference number limited to 0 to 255
//   post: result = non zero on success
//         result = 0 on error
void __fastcall TsimIO::stopSoundMemDX(int waveIndex, short *result)
{
  try {
    *result = 0;                        // default to DirectX not available
    if(!dsoundExist)                    // if DirectSound not available
      return;
    if(dmusicSegments[waveIndex] != NULL) {
      StopSegment(dmusicPerformance, dmusicSegments[waveIndex]);
      *result = 1;
    }
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in stopSoundMem"));
    return;
  }
}

// control the DirectX player.
//   pre: waveIndex is reference number limited to 0 to 255
//        control = 0, play sound once (same as playSoundMem)
//                = 1, play sound in loop
//                = 2, stop indexed sound
//                = 3, stop all sounds
//                = other values reserved
//   post: result = non zero on success
//         result = 0 on error
void __fastcall TsimIO::controlSoundDX(int control, int waveIndex, short *result)
{
  try {
    *result = 0;                        // default to error
    if(!dsoundExist)                    // if DirectSound not available
      return;
    if(dmusicSegments[waveIndex] != NULL) {
      switch(control) {
        case 0:         // play sound once
          playSoundMemDX(waveIndex, result);
          break;
        case 1:         // play sound in loop
          if(dmusicSegments[waveIndex] != NULL) {
            PlaySegmentLoop(dmusicPerformance, dmusicSegments[waveIndex]);
            *result = 1;
          }
          break;
        case 2:         // stop sound
          stopSoundMemDX(waveIndex, result);
          break;
        case 3:         // stop all sounds
          for (int i=0; i<WAVES; i++) {
            stopSoundMemDX(i, result);
          }
          *result = 1;
          break;
      }
    }
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in playSoundMem"));
    return;
  }
}

//---------------------------------------------------------------------------
//  GRAPHICS FUNCTIONS called by Trap #15 handler
//---------------------------------------------------------------------------

void __fastcall TsimIO::setLineColor(int c)
{
  BackBuffer->Canvas->Pen->Color = (TColor) c;
  Canvas->Pen->Color = (TColor) c;
}

void __fastcall TsimIO::setFillColor(int c)
{
  BackBuffer->Canvas->Brush->Color = (TColor) c;
  Canvas->Brush->Color = (TColor) c;
}

void __fastcall TsimIO::drawPixel(int x, int y)
{
  BackBuffer->Canvas->Pixels[x][y] = BackBuffer->Canvas->Pen->Color;
  if (doubleBuffer == false)
    Canvas->Pixels[x][y] = BackBuffer->Canvas->Pen->Color;
  //simIO->Repaint();
}

int  __fastcall TsimIO::getPixel(int x, int y)
{
  return (int) BackBuffer->Canvas->Pixels[x][y];
}

void __fastcall TsimIO::line(int x1, int y1, int x2, int y2)
{
  BackBuffer->Canvas->MoveTo(x1,y1);
  BackBuffer->Canvas->LineTo(x2,y2);
  BackBuffer->Canvas->Pixels[x2][y2] = BackBuffer->Canvas->Pen->Color;  // plot to fix builder bug
  if (doubleBuffer == false) {
    Canvas->MoveTo(x1,y1);
    Canvas->LineTo(x2,y2);
    Canvas->Pixels[x2][y2] = Canvas->Pen->Color;
  }
  //simIO->Repaint();
}

void __fastcall TsimIO::lineTo(int x, int y)
{
  BackBuffer->Canvas->LineTo(x,y);
  BackBuffer->Canvas->Pixels[x][y] = BackBuffer->Canvas->Pen->Color;
  if (doubleBuffer == false) {
    Canvas->LineTo(x,y);
    Canvas->Pixels[x][y] = BackBuffer->Canvas->Pen->Color;
  }
  //simIO->Repaint();
}

// Move pen to X,Y
void __fastcall TsimIO::moveTo(int x, int y)
{
  BackBuffer->Canvas->MoveTo(x,y);
  Canvas->MoveTo(x,y);
}

// Return current X,Y pen position
void __fastcall TsimIO::getXY(short* x, short* y)
{
  *x = (short)Canvas->PenPos.x;
  *y = (short)Canvas->PenPos.y;
}

void __fastcall TsimIO::rectangle(int x1, int y1, int x2, int y2)
{
  if (x1 > x2) {        // if coords are reversed
    int x = x1;
    x1 = x2;
    x2 = x;
  }
  if (y1 > y2) {
    int y = y1;
    y1 = y2;
    y2 = y;
  }
  BackBuffer->Canvas->Rectangle(x1,y1, x2+1,y2+1);   // +1 to fix builder bug
  if (doubleBuffer == false)
    Canvas->Rectangle(x1,y1, x2+1,y2+1);
}

void __fastcall TsimIO::ellipse(int x1, int y1, int x2, int y2)
{
  try {
    if (x1 > x2) {        // if coords are reversed
      int x = x1;
      x1 = x2;
      x2 = x;
    }
    if (y1 > y2) {
      int y = y1;
      y1 = y2;
      y2 = y;
    }
    // on Windows 95 X1 + X2 + Y1 + Y2 cannot exceed 32768.
    if ((x1 + y1 + x2 + y2) < 32768) {
      BackBuffer->Canvas->Ellipse(x1,y1, x2+1,y2+1);    // fix builder bug
      if (doubleBuffer == false)
        Canvas->Ellipse(x1,y1, x2+1,y2+1);
    }
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in ellipse"));
    return;
  }
}

void __fastcall TsimIO::floodFill(int x, int y)
{
  BackBuffer->Canvas->FloodFill(x,y, BackBuffer->Canvas->Pixels[x][y], fsSurface);
  if (doubleBuffer == false)
    Canvas->FloodFill(x,y, Canvas->Pixels[x][y], fsSurface);
}

void __fastcall TsimIO::unfilledRectangle(int x1, int y1, int x2, int y2)
{
  if (x1 > x2) {        // if coords are reversed
    int x = x1;
    x1 = x2;
    x2 = x;
  }
  if (y1 > y2) {
    int y = y1;
    y1 = y2;
    y2 = y;
  }

  TColor c = BackBuffer->Canvas->Brush->Color;  // save fill color
  BackBuffer->Canvas->Brush->Style = bsClear;
  BackBuffer->Canvas->Rectangle(x1,y1, x2+1,y2+1); // +1 to fix builder bug
  if (doubleBuffer == false) {
    Canvas->Brush->Style = bsClear;
    Canvas->Rectangle(x1,y1, x2+1,y2+1);
  }
  BackBuffer->Canvas->Brush->Style = bsSolid;
  BackBuffer->Canvas->Brush->Color = c;         // restore fill color
  Canvas->Brush->Style = bsSolid;
  Canvas->Brush->Color = c;         // restore fill color
}

void __fastcall TsimIO::unfilledEllipse(int x1, int y1, int x2, int y2)
{
  try {
    if (x1 > x2) {        // if coords are reversed
      int x = x1;
      x1 = x2;
      x2 = x;
    }
    if (y1 > y2) {
      int y = y1;
      y1 = y2;
      y2 = y;
    }

    // on Windows 95 X1 + X2 + Y1 + Y2 cannot exceed 32768.
    if ((x1 + y1 + x2 + y2) < 32768) {
      TColor c = BackBuffer->Canvas->Brush->Color;  // save fill color
      BackBuffer->Canvas->Brush->Style = bsClear;
      BackBuffer->Canvas->Ellipse(x1,y1, x2+1,y2+1);
      if (doubleBuffer == false) {
        Canvas->Brush->Style = bsClear;
        Canvas->Ellipse(x1,y1, x2+1,y2+1);
      }
      BackBuffer->Canvas->Brush->Style = bsSolid;
      BackBuffer->Canvas->Brush->Color = c;         // restore fill color
      Canvas->Brush->Style = bsSolid;
      Canvas->Brush->Color = c;         // restore fill color
    }
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Error in unfilledEllipse"));
    return;
  }
}

void __fastcall TsimIO::setDrawingMode(int m)
{
  m &= 0x00FF;
  if (m == 16) {                // if turn off double buffering
    doubleBuffer = false;
    Canvas->PenPos = BackBuffer->Canvas->PenPos;  // get x,y from BackBuffer->Canvas
    FormPaint((TObject *)simIO);
  } else if (m == 17)            // if enable double buffering
    doubleBuffer = true;
  else {
    BackBuffer->Canvas->Pen->Mode = (TPenMode) m;
    Canvas->Pen->Mode = (TPenMode) m;
  }
}

void __fastcall TsimIO::setPenWidth(int w)
{
  w &= 0x00FF;
  BackBuffer->Canvas->Pen->Width = w;
  Canvas->Pen->Width = w;
}


//---------------------------------------------------------------------------
// ----- Serial Communications Code -----
//---------------------------------------------------------------------------
// Close all Comm ports
void __fastcall TsimIO::closeAllComm()
{
  for(int i=0; i<MAX_COMM; i++)
    if (hComm[i] != NULL)
      closeComm(i);
}

//---------------------------------------------------------------------------
// Init a comm port
// If the specified comm port is currently in use it will be closed and reused.
// The port is set to default configuration 9600,N,8,1
// Pre:
//   cid: Comm ID is a user specified number 0 to MAX_COMM used to refer to this
//        comm port in all other comm functions.
//   portName: Null terminated string of comm port name (e.g. COM4)
// Post:
//   result: 0 on success, 1 on invalid CID, 2 on error
void __fastcall TsimIO::initComm(int cid, char *portName, short *result)
{
  *result = 0;           // 0 is success

  if (cid < 0 || cid >= MAX_COMM) {     // if invalid CID
    *result = 1;
    return;
  }

  if (hComm[cid] != NULL)               // if CID in use
    closeComm(cid);                     // close current port and reuse

  // Open the Comm port.
  hComm[cid] = CreateFile(portName,
                     GENERIC_READ | GENERIC_WRITE,
                     0,
                     0,
                     OPEN_EXISTING,
                     0,
                     0);

  // if the port cannot be openned.
  if(hComm[cid] == INVALID_HANDLE_VALUE){
    hComm[cid] = NULL;
    *result = 2;         // error
    return;
  }

  // set default params
  setCommParams(cid, 0, result);
}

//---------------------------------------------------------------------------
// Set baud rate, parity, word size, and stop bits.
// default settings = 0 for 9600,N,8,1
// Pre:
//   cid: from initComm above.
//   settings:
//       Bits 0-7
//            port speed: 0=default, 1=110 baud, 2=300, 3=600,
//            4=1200, 5=2400, 6=4800, 7=9600, 8=19200, 9=38400,
//            10=56000, 11=57600, 12=115200, 13=128000, 14=256000.
//            8 Databits, No parity, One stop bit is assumed.
//       Bits 8-9
//            parity: 0=no, 1=odd, 2=even, 3=mark
//       Bits 10-11
//            number of data bits: 0=8 bits, 1=7 bits, 2=6 bits
//       Bit  12
//            stop bits: 0=1 stop bit, 1=2 stop bits
// Post:
//   result 0 on success, 1 on invalid CID, 2 on error
//   3 on comm port not initialized,

void __fastcall TsimIO::setCommParams(int cid, int settings, short *result)
{
  DCB dcbCommPort;
  char portSettings[] = "9600,N,8,1\0\0\0";     // default settings
  int timeout = 27;

  *result = 0;           // 0 is success

  if (cid < 0 || cid >= MAX_COMM) {     // if invalid CID
    *result = 1;
    return;
  }

  if (hComm[cid] == NULL) {     // if comm port not initialized
    *result = 3;
    return;
  }

  // The argument for BuildCommDCB must be a pointer to a string.
  // BuildCommDCB() defaults to no handshaking.
  dcbCommPort.DCBlength = sizeof(DCB);
  if (!GetCommState(hComm[cid], &dcbCommPort)){
    // error getting state
    *result = 2;
    return;
  }

  switch(settings & 0x000000FF)       // baud rate first
  {
    case 0:
      strcpy(portSettings,"9600");
      timeout = 27;
      break;
    case 1:
      strcpy(portSettings,"110");
      timeout = 73;
      break;
    case 2:
      strcpy(portSettings,"300");
      timeout = 27;
      break;
    case 3:
      strcpy(portSettings,"600");
      timeout = 14;
      break;
    case 4:
      strcpy(portSettings,"1200");
      timeout = 7;
      break;
    case 5:
      strcpy(portSettings,"2400");
      timeout = 4;
      break;
    case 6:
      strcpy(portSettings,"4800");
      timeout = 2;
      break;
    case 7:
      strcpy(portSettings,"9600");
      timeout = 1;
      break;
    case 8:
      strcpy(portSettings,"19200");
      timeout = 1;
      break;
    case 9:
      strcpy(portSettings,"38400");
      timeout = 1;
      break;
    case 10:
      strcpy(portSettings,"56000");
      timeout = 1;
      break;
    case 11:
      strcpy(portSettings,"57600");
      timeout = 1;
      break;
    case 12:
      strcpy(portSettings,"115200");
      timeout = 1;
      break;
    case 13:
      strcpy(portSettings,"128000");
      timeout = 1;
      break;
    case 14:
      strcpy(portSettings,"256000");
      timeout = 1;
      break;
  }
  //       Bits 8-9
  //            parity: 0=no, 1=odd, 2=even, 3=mark
  switch((settings & 0x00000300) >> 8)
  {
    case 0:
      strcat(portSettings,",N");
      break;
    case 1:
      strcat(portSettings,",O");
      break;
    case 2:
      strcat(portSettings,",E");
      break;
    case 3:
      strcat(portSettings,",M");
      break;
  }
  //       Bits 10-11
  //            number of data bits: 0=8 bits, 1=7 bits, 2=6 bits
  switch((settings & 0x00000C00) >> 10)
  {
    case 0:
      strcat(portSettings,",8");
      break;
    case 1:
      strcat(portSettings,",7");
      break;
    case 2:
      strcat(portSettings,",6");
      break;
    default: // 5 data bits not supported because 5 data bits with 2 stop bits is an invalid combination
      strcat(portSettings,",8");
  }
  //       Bit  12
  //            stop bits: 0=1 stop bit, 1=2 stop bits
  switch((settings & 0x00001000) >> 12)
  {
    case 0:
      strcat(portSettings,",1");
      break;
    case 1:
      strcat(portSettings,",2");
      break;
  }

  // set comm timeouts
  GetCommTimeouts(hComm[cid],&ctmoOld[cid]);
  ctmoNew.ReadIntervalTimeout = timeout;
  ctmoNew.ReadTotalTimeoutConstant = 1;
  ctmoNew.ReadTotalTimeoutMultiplier = 1;
  ctmoNew.WriteTotalTimeoutMultiplier = timeout;
  ctmoNew.WriteTotalTimeoutConstant = 100;
  SetCommTimeouts(hComm[cid], &ctmoNew);

  // set port state
  BuildCommDCB(portSettings, &dcbCommPort);
  if (!SetCommState(hComm[cid], &dcbCommPort)) {
    // error setting serial port state
    *result = 2;
    return;
  }

}

//---------------------------------------------------------------------------
// close the comm port
// Pre:
//   cid: valid cid from initComm above
void __fastcall TsimIO::closeComm(int cid)
{
  // purge the internal comm buffer,
  // restore the previous timeout settings,
  // and close the comm port.
  PurgeComm(hComm[cid], PURGE_RXABORT);
  SetCommTimeouts(hComm[cid], &ctmoOld[cid]);
  CloseHandle(hComm[cid]);
  hComm[cid] = NULL;
}

//---------------------------------------------------------------------------
// read string of data from comm port
// Pre:
//   cid: from initComm above
//     n: number of characters to read (1 thru MAX_SERIAL_IN)
// Post:
//   n: number of characters read
//   str: null terminated string stored at str
//   result 0 on success, 1 on invalid CID, 2 on error
//   3 on comm port not initialized, 4 on timeout,
void __fastcall TsimIO::readComm(int cid, uchar *n, char *str, short *result)
{
  DWORD dwBytesRead;

  *result = 0;           // 0 is success

  if (cid < 0 || cid >= MAX_COMM) {     // if invalid CID
    *result = 1;
    return;
  }

  if (hComm[cid] == NULL) {     // if comm port not initialized
    *result = 3;
    return;
  }

  // Try to read character from the serial port
  // If no character to read it will time out
  if(!ReadFile(hComm[cid], InBuff, *n, &dwBytesRead, NULL)){
    *result = 2;                // if read error
    return;
  }

  if(dwBytesRead) {
    str[dwBytesRead] = 0;       // null terminate the string
  }
  if (dwBytesRead < (DWORD)*n)         // if timeout
    *result = 4;
  *n = dwBytesRead;

  // check memory map, initiates bus error if required
  if( memoryMapCheck(Invalid | Read | Rom, (str - memory), (int)dwBytesRead) == SUCCESS)
    strcpy(str,InBuff);         // stores string only to writable memory
}

//---------------------------------------------------------------------------
// send characters to comm port
// Pre:
//   cid: from initComm above
//     n: number of characters to send
//   str: string to send
// Post:
//   n: number of characters sent
//   result 0 on success, 1 on invalid CID, 2 on error
//   3 on comm port not initialized, 4 on timeout,
void __fastcall TsimIO::sendComm(int cid, uchar *n, char *str, short *result)
{
  DWORD dwBytesSent;

  *result = 0;           // 0 is success

  if (cid < 0 || cid >= MAX_COMM) {     // if invalid CID
    *result = 1;
    return;
  }

  if (hComm[cid] == NULL) {     // if comm port not initialized
    *result = 3;
    return;
  }

  // Try to send characters to the serial port
  if(!WriteFile(hComm[cid], str, *n, &dwBytesSent, NULL)){
    *result = 2;                // if send error
    return;
  }
  if (dwBytesSent < (DWORD)*n)         // if timeout
    *result = 4;
  *n = dwBytesSent;
}


//---------------------------------------------------------------------------
//  NETWORK I/O
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
// Create Client
void __fastcall TsimIO::createNetClient(int settings, char *server, int *result)
{
  uint port, type;

  type = (uint)(settings & 0x000000FF);         // connection type
  port = (uint)((settings & 0xFFFF0000) >> 16); // port number
  *result = netCreateClient(server, port, type);
}

//---------------------------------------------------------------------------
// Create Server
void __fastcall TsimIO::createNetServer(int settings, int *result)
{
  uint port, type;

  type = (uint)(settings & 0x000000FF);         // connection type
  port = (uint)((settings & 0xFFFF0000) >> 16); // port number
  *result = netCreateServer(port, type);
}

//---------------------------------------------------------------------------
// Send
void __fastcall TsimIO::sendNet(int settings, char *data, char *remoteIP, int *count, int *result)
{
  unsigned int size;

  size = (uint)(settings & 0x0000FFFF);     // number of bytes to send
  *result = netSendData(data, size, remoteIP);
  if (*result == NET_OK)
    *count = size;
}

//---------------------------------------------------------------------------
// Receive
void __fastcall TsimIO::receiveNet(int settings, char *buffer, int *count, char *senderIP,  int *result)
{
  unsigned int size;

  size = (uint)(settings & 0x0000FFFF); // number of bytes to read
  *result = netReadData(buffer, size, senderIP);
  if (*result == NET_OK)
    *count = size;                      // number of bytes received
}

//---------------------------------------------------------------------------
// Send on port
void __fastcall TsimIO::sendPortNet(long *D0, long *D1, char *data, char *remoteIP)
{
  unsigned int size;
  unsigned short portNum;

  size = (uint)(*D1 & 0x0000FFFF);              // number of bytes to send
  portNum = (uint)((*D1 & 0xFFFF0000)>>16);     // port number
  *D0 = netSendData(data, size, remoteIP, portNum);
  if (*D0 == NET_OK)
    *D1 = size;
}

//---------------------------------------------------------------------------
// Receive data and port
void __fastcall TsimIO::receivePortNet(long *D0, long *D1, char *buffer, char *senderIP)
{
  unsigned int size;
  unsigned short portNum;

  size = (uint)(*D1 & 0x0000FFFF);      // number of bytes to read
  *D0 = netReadData(buffer, size, senderIP, portNum);
  if (*D0 == NET_OK)
  {
    *D1 = ((uint)portNum << 16);        // port number of received data
    *D1 |= size & 0x0000FFFF;           // number of bytes received
  }
}

//---------------------------------------------------------------------------
// Close Connection
void __fastcall TsimIO::closeNetConnection(int closeIP, int *result)
{
  *result = netCloseSockets();
}

//---------------------------------------------------------------------------
// Get Local IP
void __fastcall TsimIO::getLocalIP(char *localIP, int *result)
{
  *result = netLocalIP(localIP);
}

