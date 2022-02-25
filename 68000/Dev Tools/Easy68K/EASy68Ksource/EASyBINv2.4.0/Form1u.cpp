//---------------------------------------------------------------------------
//   Author: Chuck Kelly,
//           http://www.easy68k.com
//---------------------------------------------------------------------------
// File Name: Form1u.cpp
// Code for main form.
// EASyBIN binary file creation and editing utility for EASy68K
//---------------------------------------------------------------------------

#include <vcl.h>
#include <fstream.h>
#include <process.h>
#pragma hdrstop

#include "HtmlHelp.h"
#include "help.h"
#include "Form1u.h"
#include "aboutS.h"
#include "fileIO.h"

//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "CSPIN"
#pragma resource "*.dfm"
TForm1 *Form1;


// constants
const int HEX_LEFT  = 10;
const int HEX_RIGHT = 56;
const int ASC_RIGHT = 73;
const int ASC_LEFT  = 58;

// global variables
AnsiString str;

unsigned int memAddr;           // current memory address
unsigned int startAddr;         // start address of loaded S-Record
unsigned int endAddr;           // ending address of loaded S-Record
unsigned int length;            // length of data loaded
char *memory = NULL;            // pointer for main binary memory


//------------------------------------------------------------------------------
// this is the registry key where HTML Help registers the location of hhctrl.ocx

#define HHPathRegKey "CLSID\\{adb880a6-d8ff-11cf-9377-00aa003b7a11}\\InprocServer32"

// typedef for the HtmlHelp() function

typedef HWND WINAPI (*HTML_HELP_PROC)(HWND, LPCSTR, UINT, DWORD_PTR);

// global variables the HTML Help libary

HANDLE HHLibrary = 0;       // handle to the loaded hhctrl.ocx, 0 if not loaded
HTML_HELP_PROC __HtmlHelp;  // function pointer for the HtmlHelp() function. Note
                            // that you cannot name it HtmlHelp because that would
                            // create a conflict with the declaration in htmlhelp.h

//---------------------------------------------------------------------------
bool __fastcall LoadHtmlHelp()
{
  HKEY HHKey;
  DWORD PathSize = 255;
  char Path[255];
  bool R = false;

  // try to get the location of hhctrl.ocx from the registry and load it
  if (::RegOpenKeyExA(HKEY_CLASSES_ROOT, HHPathRegKey, 0, KEY_QUERY_VALUE, (void **)&HHKey) == ERROR_SUCCESS)
  {
    if (::RegQueryValueExA(HHKey, "", NULL, NULL, (LPBYTE)Path, &PathSize) == ERROR_SUCCESS)
    {
      HHLibrary = ::LoadLibrary(Path);
    }
    ::RegCloseKey(HHKey);
  }

  // if hhctrl.ocx did not load let LoadLibrary look for it
  if (HHLibrary == 0)
  {
    HHLibrary = ::LoadLibrary("hhctrl.ocx");
  }

  // if hhctrl.ocx loaded set __HtmlHelp to point to HtmlHelp function
  if (HHLibrary != 0)
  {
    __HtmlHelp = (HTML_HELP_PROC) ::GetProcAddress(HHLibrary, "HtmlHelpA");
    R = (__HtmlHelp != NULL);
    if (!R)
    {
      ::FreeLibrary(HHLibrary);
      HHLibrary = 0;
    }
  }
  return R;
}

//---------------------------------------------------------------------------
// Form1 Constructor
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
  // initialize helpfile location -- m_asHelpFile is an AnsiString type private
  // member of the TForm1 class
  m_asHelpFile = ExtractFilePath(Application->ExeName) + "help.chm";
  m_asHelpFile = ExpandFileName(m_asHelpFile);

  // make sure the helpfile exists and display a message if not
  if (!FileExists(m_asHelpFile)) ShowMessage("Help file not found\n" + m_asHelpFile);

  // Load the HTML Help library, exit if it doesn't exist. Notice that, unlike
  // when using static loading (Example 1), it's our choice to exit the
  // application, it's not enforced by the Operating System. You could allow
  // your application to continue running with a disable help system,
  // automatically install HTML Help on demand or whatever you choose...

  if (!LoadHtmlHelp())
  {
    ShowMessage("HTML Help was not detected on this computer. EASy68K help may not work correctly.");
  }

  // With dynamic loading it's advised to use HH_INITIALIZE. See the comments
  // for OnClose for more information on why...
  if (HHLibrary != 0)
    __HtmlHelp(NULL, NULL, HH_INITIALIZE, (DWORD)&m_Cookie);

  Form1->Caption = TITLE;
  Form1->DoubleBuffered = true;         // stop screen flicker
  
  rowHeight = Canvas->TextHeight("Xp");
  colWidth  = Canvas->TextWidth("W");

  split = OutputSplit->ItemIndex << 1;
  
  try {
    memory = new char[MEMSIZE];      // reserve 68000 memory space
    for (int i=0; i<MEMSIZE; i++)
      memory[i] = 0xFF;              // erase 68000 memory to $FF
  }
  catch(...){
    Application->MessageBox("Error reserving 16Meg memory block",NULL,mbOK);
    exit(1);    // force application exit
  }

  DragAcceptFiles(Handle, true);        // enable drag-n-drop from explorer
}

//---------------------------------------------------------------------------
// Form1 Destructor
//---------------------------------------------------------------------------
__fastcall TForm1::~TForm1()
{
  if (memory != NULL)
    delete[] memory;            // free 68000 memory space

  /*
  WARNING: When you close an application that uses HtmlHelp and at the point of
  exit may have HTML Help Windows still open, you _must_ close these windows
  prior to exit. Failing to do this may result in access violations.

  The most generic way is to use the HH_CLOSE_ALL command. This will close
  all HTML Help windows opened by the application and is the most convenient
  way because it doesn't require a handle to the HTML Help Window:

  There are a few gotcha's when using the HH_CLOSE_ALL command with a dynamically
  loaded HTML Help API. More specifically the problem lies in unloading the HTML
  Help API. You want to be a good Windows citizen so you unload all dynamically
  loaded librarys before you terminate. So after the mandatory HH_CLOSE_ALL you
  call FreeLibrary and then...bang, an access violation. The problem is that
  normally HH_CLOSE_ALL results in the creation of a secondary thread that performs
  the actual action of closing all open HTML Help Windows while your application
  thread is allowed to continue running. If you immediately call FreeLibrary
  after HH_CLOSE_ALL, that secondary - which exists in hhctrl.ocx, may still be
  running. When it continues running the operating system finds that hhctrl.ocx
  is already unloaded and an access violation occurs. There are multiple ways
  to work around this problem but the recommended one is to use HH_INITIALIZE
  when you load HTML HELP and HH_UNINITIALIZE before you unload HTML Help, as
  is done in this code (doing this results in HH_CLOSE_ALL not spawning a
  secondary thread but using the calling thread, eliminating the problem).
  */
  if (HHLibrary != 0)
  {
    __HtmlHelp(0, NULL, HH_CLOSE_ALL, 0);
    Sleep(0);
    __HtmlHelp(NULL, NULL, HH_UNINITIALIZE, (DWORD)m_Cookie);
    ::FreeLibrary(HHLibrary);
    HHLibrary = 0;
  }
}

//---------------------------------------------------------------------------
// Close the Form
// Exit
void __fastcall TForm1::ExitExecute(TObject *Sender)
{
  Application->Terminate();
}

//---------------------------------------------------------------------------
// Open S-Record file
void __fastcall TForm1::OpenSRecordFile(AnsiString name)
{
  AnsiString str;
  int addr;

  try {
    // load S-Record file
    if(loadSrec(name.c_str())) {   // if no errors
      // display file name in title bar
      Form1->Caption = name;
      startAddress->Text = str.sprintf("%08lX",startAddr);
      Address1->Text = startAddress->EditText;
      OutputFirstAddress->Text = Address1->EditText;    // Address1 formats number to 6 digits
      S68length->Caption = str.sprintf("%06lX",length);
      OutputLength->Text = S68length->Caption;
      S68endAddress->Caption = str.sprintf("%06lX",endAddr);
    } // end if
  }
  catch( ... ) {
    ShowMessage("Error in OpenSRecordFile()");
    return;
  }
}

//--------------------------------------------------------------------------
// handler for drag-n-drop from explorer
void __fastcall TForm1::WmDropFiles(TWMDropFiles& Message)
{
  AnsiString fileName;
  int size;
  char buff[MAX_PATH];                  // filename buffer

  HDROP hDrop = (HDROP)Message.Drop;
  int numFiles = DragQueryFile(hDrop, -1, NULL, NULL);  // number of files dropped
  for (int i=0;i < numFiles;i++) {      // loop for all files dropped
    DragQueryFile(hDrop, i, buff, sizeof(buff));        // get name of file i
    fileName = buff;
    if (FileExists(fileName)) {
      // attempt to load S-Record file
      if(loadSrec(fileName.c_str())) {   // if no errors
        // display file name in title bar
        Form1->Caption = fileName;
        startAddress->Text = str.sprintf("%08lX",startAddr);
        Address1->Text = startAddress->EditText;
        OutputFirstAddress->Text = Address1->EditText;    // Address1 formats number to 6 digits
        S68length->Caption = str.sprintf("%06lX",length);
        OutputLength->Text = S68length->Caption;
        S68endAddress->Caption = str.sprintf("%06lX",endAddr);
      } else {                            // else open as binary
        ShowMessage("Opening as binary file.");
        size = loadBinary(fileName.c_str(), split);
        if (size) {       // if no errors
          // display file name in title bar
          Form1->Caption = fileName;
          startAddress->Text = "00000000";
          Address1->Text = OutputFirstAddress->EditText;
          length = size;
          OutputLength->Text = str.sprintf("%06lX",length);
        } // end if
      }
    }
  }
  DragFinish(hDrop);                    // free memory Windows allocated
}

//---------------------------------------------------------------------------
// Display Open File Dialog for S-Record load
void __fastcall TForm1::OpenExecute(TObject *Sender)
{
  try {
    OpenDialog->Filter = "EASy68K S-Record [.S68]|*.S68|Motorola S-Record [.S3][.S19]|*.S3;*.S19|Other S-Record|*.*";
    if (OpenDialog->Execute()) {
      OpenSRecordFile(OpenDialog->FileName);
    }
  }
  catch( ... ) {
    ShowMessage("Error in OpenExecute()");
    return;
  }
}

//---------------------------------------------------------------------------
// Save S-Record File
void __fastcall TForm1::SaveSRecFile(TObject *Sender)
{
  try {
    AnsiString msg;
    SaveDialog->Filter = "EASy68K S-Record [.S68]|*.S68|Motorola S-Record [.S3]|*.S3|Other S-Record|*.*";
    SaveDialog->DefaultExt = "S68";
    msg = "S-Record file information:\n\nFrom:$" + From->EditText +
          "  To:$" + To->EditText + "\nStart Address:$" + startAddress->EditText +
          "\n\nCreate S-Record?";
    int response = Application->MessageBox(msg.c_str(), "S-Record Creation", MB_YESNO);
    if (response == IDNO)
      return;

    saveSRecord();
  }
  catch( ... ) {
    ShowMessage("Error in SaveSRecFile()");
    return;
  }
}


//---------------------------------------------------------------------------
// Display Open Binary File
void __fastcall TForm1::OpenBinFile(TObject *Sender)
{
  try {
    int size;
    AnsiString str;

    OpenDialog->Filter = "Binary File [.BIN]|*.BIN|Any File|*.*";
    if (OpenDialog->Execute()) {
      // load binary file
      size = loadBinary(OpenDialog->FileName.c_str(), split);
      if (size) {       // if no errors
        // display file name in title bar
        Form1->Caption = OpenDialog->FileName;
        startAddress->Text = "00000000";
        Address1->Text = OutputFirstAddress->EditText;
        length = size;
        OutputLength->Text = str.sprintf("%06lX",length);
      } // end if
    }
  }
  catch( ... ) {
    ShowMessage("Error in OpenBinFile()");
    return;
  }
}

//---------------------------------------------------------------------------
void __fastcall TForm1::SaveBinFile(TObject *Sender)
{
  try {
    // save binary file
    SaveDialog->Filter = "Binary File [.BIN]|*.BIN|Other Binary File|*.*";
    SaveDialog->DefaultExt = "BIN";
    saveBinary(split);
  }
  catch( ... ) {
    ShowMessage("Error in SaveBinFile()");
    return;
  }
}

//---------------------------------------------------------------------------
// New Environment
void __fastcall TForm1::NewExecute(TObject *Sender)
{
  try {
    if((Application->MessageBox
    ("The current environment will be lost, click OK to continue.",
      "Caution",MB_OKCANCEL)) == IDOK)
    {
      for (int i=0; i<MEMSIZE; i++)
        memory[i] = 0xFF;              // erase 68000 memory to $FF

      Form1->Caption = TITLE;
      startAddress->Text = "00000000";
      S68endAddress->Caption = "000000";
      S68length->Caption = "000000";
      Address1->Text = "00000000";
      OutputFirstAddress->Text = "000000";
      OutputLength->Text = "000000";
      length = 0;
      memAddr = 0;
      startAddr = 0;
      endAddr = 0;
      OutputSplit->ItemIndex = 0;
      Repaint();
    }
  }
  catch( ... ) {
    ShowMessage("Error in NewExecute()");
    return;
  }
}

//---------------------------------------------------------------------------
void __fastcall TForm1::AboutExecute(TObject *Sender)
{
  AboutFrm->ShowModal();
}

//---------------------------------------------------------------------------
void __fastcall TForm1::FormShow(TObject *Sender)
{
  AnsiString fileName, ext, option;

  if (ParamCount() > 0)         // if parameters are present
  {
    fileName = ParamStr(1);     // get file name to open
    ext = ExtractFileExt(fileName.UpperCase());     // get file extension

    if (FileExists(fileName)) {
      OpenDialog->FileName = fileName; // save for reload
      OpenSRecordFile(fileName);       // open specified file
    }
  }
  // check for additional command line parameters       CK 1-25-2008
//  for (int i=2;i<=ParamCount();i++)
//  {
//    if (LowerCase(ParamStr(i)) == "/r")
//    }
//  }
}

//---------------------------------------------------------------------------
void __fastcall TForm1::FormResize(TObject *Sender)
{
  Form1->Repaint();
}

//---------------------------------------------------------------------------
void __fastcall TForm1::displayHelp(char* context)
{
  HWND H = ::GetDesktopWindow();  //this->Handle;  //::GetDesktopWindow();
  if (HHLibrary != 0)
    m_hWindow = __HtmlHelp(H, m_asHelpFile.c_str(), HH_HELP_CONTEXT, getHelpContext(context));
  else
    ShowMessage("HTML Help was not detected on this computer. The HTML help viewer may be downloaded from msdn.microsoft.com");
}

//---------------------------------------------------------------------------
void __fastcall TForm1::HelpExecute(TObject *Sender)
{
  displayHelp("EASyBIN");
}

//---------------------------------------------------------------------------
void __fastcall TForm1::FormKeyDown(TObject *Sender, WORD &Key,
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
      Form1->displayHelp("EASyBIN");
      break;
  }
  prompt->Enabled = true;       // display prompt
}

//---------------------------------------------------------------------------
void __fastcall TForm1::OutputStartAddressKeyPress(TObject *Sender, char &Key)
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
void __fastcall TForm1::Address1Change(TObject *Sender)
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
// display binary data
void __fastcall TForm1::FormPaint(TObject *Sender)
{
  try {
    TPoint scrPos;
    int tX, tY;
    unsigned int addr = memAddr;

    str = "0x";
    unsigned int outFirst;        // first address of data to output
    unsigned int outLength;       // length of binary output
    unsigned int outLast;         // last address of data to output
    outFirst = StrToInt(str + OutputFirstAddress->EditText);
    outLength = StrToInt(str + OutputLength->EditText);
    if (outLength == 0)
      outLast = 0;
    else
      outLast = outFirst + outLength - 1;

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
      } else {                            // valid address
        Canvas->Font->Color = clBlack;
        Canvas->TextOutA(tX, tY,(str.sprintf ("%08X: ",addr)));
      }

      scrPos = Canvas->PenPos;

      // display 16 hex bytes of memory
      for (int i=0; i<16; i++) {
        if (addr+i >= MEMSIZE) { // if invalid address
          Canvas->Font->Color = clRed;
          Canvas->TextOutA(scrPos.x, scrPos.y, "xx ");
          scrPos = Canvas->PenPos;
        } else {
          // set color of font to indicate binary output file
          // clLtGray = data will not be written
          // clBlack = file 0
          // clOlive = file 1
          // clGreen = file 2
          // clBlue  = file 3
          if (addr+i < outFirst || addr+i > outLast || outLength == 0)
            Canvas->Font->Color = clGray;
          else if (split == 0)
            Canvas->Font->Color = clBlack;
          else {
            switch((addr+i - outFirst)%split) {
              case 0:
                Canvas->Font->Color = clBlack;
                break;
              case 1:
                Canvas->Font->Color = clOlive;
                break;
              case 2:
                Canvas->Font->Color = clGreen;
                break;
              case 3:
                Canvas->Font->Color = clBlue;
                break;
            }
          }
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
        } else {
          Canvas->Font->Color = clBlack;
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
  catch( ... ) {
    ShowMessage("Error in FormPaint()");
    return;
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::RowSpinUpClick(TObject *Sender)
{
  int addr;

  str = "0x";
  addr = StrToInt(str + Address1->EditText);

  addr -= 16;               // display lower address
  if (addr < 0)
    addr = 0;
  Address1->Text = str.sprintf("%08lX",addr);

  Repaint();
  Address1->SetFocus();         // give address box focus to remove focus from everyone else
  Address1->Enabled = false;    // disable address box to loose focus
  Form1->SetFocus();        // give form the focus
  Address1->Enabled = true;     // turn address box back on
  prompt->Enabled = true;       // display prompt

}
//---------------------------------------------------------------------------

void __fastcall TForm1::RowSpinDownClick(TObject *Sender)
{
  int addr;

  str = "0x";
  addr = StrToInt(str + Address1->EditText);

  addr += 16;               // display higher address
  if (addr >= MEMSIZE)
    addr = MEMSIZE - 16;
  Address1->Text = str.sprintf("%08lX",addr);

  Repaint();
  Address1->SetFocus();         // give address box focus to remove focus from everyone else
  Address1->Enabled = false;    // disable address box to loose focus
  Form1->SetFocus();        // give form the focus
  Address1->Enabled = true;     // turn address box back on
  prompt->Enabled = true;       // display prompt

}
//---------------------------------------------------------------------------

void __fastcall TForm1::PageSpinUpClick(TObject *Sender)
{
  int addr;

  str = "0x";
  addr = StrToInt(str + Address1->EditText);

  addr -= nRows*16;               // display lower address
  if (addr <= 0)
    addr = 0;
  Address1->Text = str.sprintf("%08lX",addr);
  Repaint();
  Address1->SetFocus();         // give address box focus to remove focus from everyone else
  Address1->Enabled = false;    // disable address box to loose focus
  Form1->SetFocus();        // give form the focus
  Address1->Enabled = true;     // turn address box back on
  prompt->Enabled = true;       // display prompt

}
//---------------------------------------------------------------------------

void __fastcall TForm1::PageSpinDownClick(TObject *Sender)
{
  int addr;

  str = "0x";
  addr = StrToInt(str + Address1->EditText);

  addr += nRows*16;               // display higher address
  if (addr >= MEMSIZE)
    addr = MEMSIZE - 16;
  Address1->Text = str.sprintf("%08lX",addr);
  Repaint();
  Address1->SetFocus();         // give address box focus to remove focus from everyone else
  Address1->Enabled = false;    // disable address box to loose focus
  Form1->SetFocus();        // give form the focus
  Address1->Enabled = true;     // turn address box back on
  prompt->Enabled = true;       // display prompt

}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormMouseWheelDown(TObject *Sender,
      TShiftState Shift, TPoint &MousePos, bool &Handled)
{
  RowSpinDownClick(Sender);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormMouseWheelUp(TObject *Sender,
      TShiftState Shift, TPoint &MousePos, bool &Handled)
{
  RowSpinUpClick(Sender);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Address1KeyDown(TObject *Sender, WORD &Key,
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
      Form1->displayHelp("EASyBIN");
      break;
    case VK_RETURN:             // Enter
      Repaint();
      break;
  }
}

//---------------------------------------------------------------------------
// goto row, col
void __fastcall TForm1::gotoRC(TObject *Sender, int r, int c)
{
  try {
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
  catch( ... ) {
    ShowMessage("Error in gotoRC()");
    return;
  }
}


//---------------------------------------------------------------------------
void __fastcall TForm1::FormMouseDown(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{
  erasePrompt();                // erase old prompt
  Address1->SetFocus();         // give address box focus to remove focus from everyone else
  Address1->Enabled = false;    // disable address box to loose focus
  Form1->SetFocus();        // give form the focus
  Address1->Enabled = true;     // turn address box back on

  row = (Y-Panel1->Height)/rowHeight;
  col = X/colWidth;
  gotoRC(Sender, row,col);

  prompt->Enabled = true;       // display prompt

  Repaint();
}

//---------------------------------------------------------------------------
void __fastcall TForm1::promptTimer(TObject *Sender)
{
  drawPrompt();
}

//---------------------------------------------------------------------------
// draw prompt
void __fastcall TForm1::drawPrompt()
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
void __fastcall TForm1::erasePrompt()
{
  int promptX = colWidth * col;

  prompt->Enabled = false;    // stop display of prompt
  Canvas->FrameRect(TRect(promptX,textY+rowHeight/4-1,
                        promptX+colWidth+1, textY+rowHeight/4+rowHeight-1));
}

//---------------------------------------------------------------------------
void __fastcall TForm1::FormKeyPress(TObject *Sender, char &Key)
{
  try {
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
    Repaint();
  }
  catch( ... ) {
    ShowMessage("Error in FormKeyPress()");
    return;
  }
}

//---------------------------------------------------------------------------
void __fastcall TForm1::CopyClick(TObject *Sender)
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

void __fastcall TForm1::AddrKeyPress(TObject *Sender, char &Key)
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
void __fastcall TForm1::FillClick(TObject *Sender)
{
  try {
    unsigned int fromAddr, toAddr, fill, i;
    unsigned char data;

    str = "0x";
    fromAddr = StrToInt(str + From->EditText);
    toAddr = StrToInt(str + To->EditText);
    fill = StrToInt(str + FillByte->EditText);
    data = (char)(fill & 0xFF);

    // fill memory with byte
    for (i=fromAddr; i<=toAddr; i++) {
      if (i >= MEMSIZE) { // if invalid address
        ShowMessage("Invalid memory range");
        return;
      } else {
        memory[i] = data;
      }
    }

    Repaint();      // update display
  }
  catch( ... ) {
    ShowMessage("Error in FillClick()");
    return;
  }

}
//---------------------------------------------------------------------------

void __fastcall TForm1::Address1KeyUp(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  Repaint();      // update display
}
//---------------------------------------------------------------------------

void __fastcall TForm1::OutputSplitClick(TObject *Sender)
{
  try {
    // split is 0, 2 or 4
    split = OutputSplit->ItemIndex << 1;
    switch (split) {
      case 0:
        split1Lbl->Visible = false;
        split2Lbl->Visible = false;
        split3Lbl->Visible = false;
        break;
      case 2:
        split1Lbl->Visible = true;
        split2Lbl->Visible = false;
        split3Lbl->Visible = false;
        break;
      case 4:
        split1Lbl->Visible = true;
        split2Lbl->Visible = true;
        split3Lbl->Visible = true;
    }
    OutputLengthChange(Sender);   // may need to round Length up
    Repaint();
  }
  catch( ... ) {
    ShowMessage("Error in OutputSplitClick()");
    return;
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::OutputFirstAddressChange(TObject *Sender)
{
  Repaint();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::OutputLengthChange(TObject *Sender)
{
//  unsigned int outLength;
//  str = "0x";
//  outLength = StrToInt(str + OutputLength->EditText);
//  if (split > 0 && outLength > 0)
//    outLength = ((outLength-1)/split)*split + split; // round outLength up to next highest split
//  OutputLength->Text = str.sprintf("%06lX",outLength);
  Repaint();
}
//---------------------------------------------------------------------------



void __fastcall TForm1::startAddressEnter(TObject *Sender)
{
  erasePrompt();                // turn off main window prompt
}
//---------------------------------------------------------------------------

void __fastcall TForm1::OutputFirstAddressEnter(TObject *Sender)
{
  erasePrompt();                // turn off main window prompt
        
}
//---------------------------------------------------------------------------

void __fastcall TForm1::OutputLengthEnter(TObject *Sender)
{
  erasePrompt();                // turn off main window prompt
        
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FromEnter(TObject *Sender)
{
  erasePrompt();                // turn off main window prompt
        
}
//---------------------------------------------------------------------------

void __fastcall TForm1::ToEnter(TObject *Sender)
{
  erasePrompt();                // turn off main window prompt
        
}
//---------------------------------------------------------------------------

void __fastcall TForm1::BytesEnter(TObject *Sender)
{
  erasePrompt();                // turn off main window prompt
        
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FillByteEnter(TObject *Sender)
{
  erasePrompt();                // turn off main window prompt
        
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Address1Enter(TObject *Sender)
{
  erasePrompt();                // turn off main window prompt
        
}
//---------------------------------------------------------------------------

