//---------------------------------------------------------------------------
//   Author: Charles Kelly
//           www.easy68k.com
//---------------------------------------------------------------------------

#include <vcl.h>
#include <fstream.h>
#include <process.h>
#include <string>
#pragma hdrstop

#include "HtmlHelp.h"
#include "help.h"
#include "SIM68Ku.h"
#include "Stack1.h"
#include "Memory1.h"
#include "simIOu.h"
#include "BREAKPOINTSu.h"
#include "aboutS.h"
#include "logU.h"
#include "Optionsu.h"
#include "hardwareu.h"
#include "var.h"
#include "FullscreenOptions.h"

extern AnsiString errstr;
extern AnsiString str;

// global to this file
bool done;
bool clRun = false;
bool disableKeyCommands = false;
String HeadingStr = " Address  --------Code---------   Line -----------Source----------->>";
const int HEADING_LIMIT = 41;   // horizontal scroll limit for above heading

// save shortcuts here for trap task 19 restore
TShortCut openCut;
TShortCut runCut;
TShortCut stepCut;
TShortCut traceCut;
TShortCut pauseCut;
TShortCut rewindCut;
TShortCut reloadCut;
TShortCut autoTraceCut;
TShortCut runToCursorCut;
TShortCut logStartCut;
TShortCut logStopCut;

void displayReg(); 	// update register display


//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TForm1 *Form1;


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
  try {
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
  catch(...)
  {
    ShowMessage("Error loading HTML help.");
    return false;
  }
}

//---------------------------------------------------------------------------
// Form1 Constructor
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
  runMode = false;
  HeadingsLbl->Caption = HeadingStr;

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

  try {
    memory = new char[MEMSIZE];      // reserve 68000 memory space
    for (int i=0; i<MEMSIZE; i++)
      memory[i] = 0xFF;              // erase 68000 memory to $FF
  } catch(...){
    Application->MessageBox("Error reserving main 68000 memory in Form1::FormCreate",NULL,mbOK);
    exit(1);    // force application exit
  }

  // save shortcuts for trap task 19 restore
  openCut = Open->ShortCut;
  runCut = Run->ShortCut;
  stepCut = Step->ShortCut;
  traceCut = Trace->ShortCut;
  pauseCut = Pause->ShortCut;
  rewindCut = Rewind->ShortCut;
  reloadCut = Reload->ShortCut;
  autoTraceCut = AutoTrace->ShortCut;
  runToCursorCut = RunToCursor->ShortCut;
  logStartCut = LogStart->ShortCut;
  logStopCut = LogStop->ShortCut;

  DragAcceptFiles(Handle, true);        // enable drag-n-drop from explorer
}

//---------------------------------------------------------------------------
// Form1 Destructor
//---------------------------------------------------------------------------
__fastcall TForm1::~TForm1()
{
  try{
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
  catch(...)
  {
    // Adobe reader can cause errors in help if it is not installed properly.
    // Just ignore any error and close.
    ShowMessage("Html help may not have closed correctly");
  }
}

//---------------------------------------------------------------------------
// Close the Form
void __fastcall TForm1::FormClose(TObject *Sender, TCloseAction &Action)
{
  runMode = false;
  SaveSettings();               // save environment settings
  Log->stopLog();               // stop log if active
}

//---------------------------------------------------------------------------
// Exit
void __fastcall TForm1::ExitExecute(TObject *Sender)
{
  runMode = false;
  SaveSettings();               // save environment settings
  Log->stopLog();               // stop log if active
  Application->Terminate();
}

//---------------------------------------------------------------------------
// This is the function that runs the 68000 program
void __fastcall TForm1::runLoop()
{
  static bool running = false;
  if (running)          // prevent nested calls
    return;
  running = true;
  try {
    while(runMode){
      runprog();          // run next 68000 instruction
      Application->ProcessMessages();
    }
  }
  catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Unexpected error in runLoop"));
  }
  running = false;
  return;
}

//---------------------------------------------------------------------------
// Open program file
void __fastcall TForm1::OpenFile(AnsiString name)
{
  AnsiString str;
  int addr;

  initSim();            // initialize simulator

  for (int i=0; i<MEMSIZE; i++)
    memory[i] = 0xFF;        // erase 68000 memory to $FF

  // set toggle switch memory to 0
  str = "0x";
  memory[StrToInt(str + Hardware->switchAddr->EditText)] = 0x00;

  Hardware->initialize();
  simhalt_on = true;            // default to SIMHALT enabled

  try {
    Message->Lines->Clear();
    ListBox1->Items->Clear();

    // load S-Record file
    if(loadSrec(name.c_str()) == false) {  // if S-Record loads with no errors
      startPC = PC;               // save PC starting address for Reset
      Reload1->Enabled = true;
      ToolReload->Enabled = true;

      // load Listing file
      str = ChangeFileExt(name,".L68");
      if (FileExists(str)) {
        ListBox1->Items->LoadFromFile(str);
        ListBox1->Enabled = true;

        // set PC to address in first line of listing
        str = ListBox1->Items->Strings[0];
        str = str.SubString(1,8);
        if (str >= "00000000" && str < "01000000")  // *ck 12-3-2005
          regPC->EditText = str;
        startPC = PC = StrToInt("0x" + regPC->EditText);

        // scan listing file for *[sim68k] commands
        // A comment line that has the following form will
        // automatically set an option in Sim68K
        //
        // *[sim68k]break      sets a PC breakpoint on the following line of code:
        // *[sim68k]bitfield   enables support for bitfield instructions
        // *[sim68k]SIMHALT_OFF disables SIMHALT, line FFFF performs as expected
        //
        for (int i=0; i<ListBox1->Items->Count; i++) {
          str = ListBox1->Items->Strings[i].LowerCase();  // force str to lowercase
          if (str.SubString(41,14) == "*[sim68k]break") { // if break set
            // get text from following line
            str = ListBox1->Items->Strings[i+1];
            // if valid address on this line
            if (i+1 > 2 && isInstruction(str))            // if instruction
            {
              addr = StrToInt("0x" + str.SubString(1,8)); // get address from line
              BreaksFrm->sbpoint(addr); // set break point
            }
          }
          if (str.SubString(41,17) == "*[sim68k]bitfield") { // if bitfield enabled
            bitfield = true;
            BitFieldEnabled->Checked = true;
          }
          if (str.SubString(41,20) == "*[sim68k]simhalt_off") { // if turn off SIMHALT
            simhalt_on = false;         // program control only (default is on)
          }
        }

      } else {          // no .L68 file
        regPC->Text = str.sprintf("%08lX",PC);          // set display PC
        Message->Lines->Add("Unable to open .L68 file.");
        ListBox1->Items->Add("A matching .L68 file was not found. The .L68 file");
        ListBox1->Items->Add("is used to provide source level debugging.");
        ListBox1->Items->Add("");
        ListBox1->Items->Add("Use EASy68K to assemble the source file to create");
        ListBox1->Items->Add("a properly formatted .L68 file and make sure the");
        ListBox1->Items->Add(".L68 and .S68 files are in the same directory.");
        ListBox1->Items->Add("");
        ListBox1->Items->Add("You may run the program without an .L68 file but");
        ListBox1->Items->Add("source level debugging will not be available.");
      }
      // display file name in title bar
      Form1->Caption = name;

      BreaksFrm->Repaint();
      MemoryFrm->Repaint();
    } // end if
  }
  catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Unexpected error in OpenFile"));
    return;
  }
}

//---------------------------------------------------------------------------
// Open program file
// Sets ELogFileName & OLogFileName if program file is loaded
void __fastcall TForm1::OpenExecute(TObject *Sender)
{
  BreaksFrm->cbpoint(-1);  // clear all break points
  if (OpenDialog1->Execute()) {
    OpenFile(OpenDialog1->FileName);
    Log->setLogFileNames(OpenDialog1->FileName);
  }
}

//---------------------------------------------------------------------------
// Open Data file
void __fastcall TForm1::OpenDataExecute(TObject *Sender)
{
  try {
    if (OpenDialog1->Execute())
      // load S-Record data file
      loadSrec(OpenDialog1->FileName.c_str());
  } catch( ... ) {
    Form1->Message->Lines->Add(errstr.sprintf("Unexpected error in OpenDataExecute"));
    return;
  }
}


//--------------------------------------------------------------------------
// handler for drag-n-drop from explorer
// should dropped files be added as data?
// set modified flag and prompt before replacing current file?
void __fastcall TForm1::WmDropFiles(TWMDropFiles& Message)
{
  AnsiString fileName, ext;
  int size;
  char buff[MAX_PATH];                  // filename buffer
  int result = IDOK;

  if (Reload1->Enabled == true)         // if debug file has been loaded
    result = Application->MessageBox("The current debug environment will be lost, click OK to continue.",
                                     "Caution",MB_OKCANCEL);
  if(result == IDOK) {
    HDROP hDrop = (HDROP)Message.Drop;
    //int numFiles = DragQueryFile(hDrop, -1, NULL, NULL);  // number of files dropped
    //for (int i=0;i < numFiles;i++) {      // loop for all files dropped
    //DragQueryFile(hDrop, i, buff, sizeof(buff));        // get name of file i
    DragQueryFile(hDrop, 0, buff, sizeof(buff));          // get name of file 0
    fileName = buff;
    ext = ExtractFileExt(fileName.UpperCase());           // get file extension
    if (FileExists(fileName) && ext == ".S68") {
      OpenDialog1->FileName = fileName;   // save for reload
      OpenFile(fileName);                 // open specified file
      Log->setLogFileNames(fileName);
    }
    //}
    DragFinish(hDrop);                    // free memory Windows allocated
  }
}

//---------------------------------------------------------------------------
// Close Open File
void __fastcall TForm1::CloseExecute(TObject *Sender)
{
  if((Application->MessageBox
  ("The current debug environment will be lost, click OK to continue.",
    "Caution",MB_OKCANCEL)) == IDOK) {

    ListBox1->Clear();    // clear program
    //setMenuInactive();    // disable some menu items
    initSim();            // initialize simulator
    BreaksFrm->cbpoint(-1);  // clear all break points
  }
}

//---------------------------------------------------------------------------
// Run
void __fastcall TForm1::RunExecute(TObject *Sender)
{
  setMenuTrace();               // disable some commands
  BreaksFrm->resetDebug();      // Reset break condition counters
  trace = false;
  sstep = false;
  loadRegs();                   // load registers from screen
  runMode = true;               // enable runLoop()
  runModeSave = runMode;        // save current runMode
  //simIO->Show();              // display the output form
  if (simIO->Visible)
    simIO->BringToFront();      // display the output form
  Hardware->autoIRQon();        // enable auto interrupt timers
  runLoop();                    // enter runLoop
}

//---------------------------------------------------------------------------
// Run after being halted by a STOP instruction
// This routine is called after an IRQ or Hardware Reset
//void __fastcall TForm1::RunAfterSTOP()
//{
//  runMode = true;               // enable runLoop()
//  runModeSave = runMode;        // save current runMode
//  runLoop();                    // enter runLoop
//}

//---------------------------------------------------------------------------
void __fastcall TForm1::RunToCursorExecute(TObject *Sender)
{
  int i, addr, Index;
  AnsiString str;

  try{
    // get text from Highlighted line
    str = ListBox1->Items->Strings[ListBox1->ItemIndex];

    // if valid address on this line
    if (ListBox1->ItemIndex > 2 && isInstruction(str))
    {
      addr = StrToInt("0x" + str.SubString(1,8)); // get address from line

      // is this address a break point?
      for (i = 0; i < bpoints; i++)
        if (brkpt[i] == addr)
          break;
      if (i >= bpoints)         // if this address is not already a break point
        runToAddr = addr;    // set runToAddress for break point
    }
    else
      Application->MessageBox("Selected line does not have a valid address.",NULL,mbOK);
  }
  catch(...)
  {
    Application->MessageBox("Invalid Run-To-Cursor Selection",NULL,mbOK);
  }
  RunExecute(Sender);

}
//---------------------------------------------------------------------------

void __fastcall TForm1::StepExecute(TObject *Sender)
{
  setMenuTrace();               // disable some commands
  trace = true;
  sstep = true;
  stepToAddr = 0;               // reset step to address

  loadRegs();                   // load registers from screen
  runMode = true;               // enable runLoop()
  runModeSave = runMode;        // save current runMode
  runLoop();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::TraceExecute(TObject *Sender)
{
  setMenuTrace();               // disable some commands
  trace = true;
  sstep = false;
  loadRegs();                   // load registers from screen
  runprog();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::PauseExecute(TObject *Sender)
{
  trace = true;
  sstep = false;
  runMode = false;
  if (inputMode) {
    inputMode = false;        // disable input mode  ck v2.3
    simIO->erasePrompt();     //                     ck v2.3
  }
  scrshow();            // update the screen
  setMenuActive();
  // the next two lines must be after setMenuActive()
  AutoTraceTimer->Enabled = false;      // turn off auto trace
  Hardware->autoIRQoff();       // turn off auto interrupt timers
}
//---------------------------------------------------------------------------

void __fastcall TForm1::RewindExecute(TObject *Sender)
{
  AutoTraceTimer->Enabled = false;      // turn off auto trace
  PC = startPC;
  initSim();            // initialize simulator, sets runMode to false
  setMenuActive();
  Log->addMessage("\n***** Reset Program Pressed *****\n");
}
//---------------------------------------------------------------------------


void __fastcall TForm1::AboutExecute(TObject *Sender)
{
  AboutFrm->ShowModal();
}

//---------------------------------------------------------------------------
// Set the menu and toolbar to work with an active source file
void __fastcall TForm1::setMenuActive()
{
  if (AutoTraceTimer->Enabled)
    return;
  Open1->Enabled = true;
  ToolOpen->Enabled = true;
  Close1->Enabled = true;
  Run1->Enabled = true;
  ToolRun->Enabled = true;
  RunToCursor1->Enabled = true;
  ToolRunToCursor->Enabled = true;
  AutoTrace1->Enabled = true;
  ToolAutoTrace->Enabled = true;
  StepOver1->Enabled = true;
  ToolStep->Enabled = true;
  TraceInto1->Enabled = true;
  ToolTrace->Enabled = true;
  Pause1->Enabled = true;
  ToolPause->Enabled = true;
  Reset1->Enabled = true;
  ToolReset->Enabled = true;
}

//---------------------------------------------------------------------------
// Set the menu and toolbar to inactive
void __fastcall TForm1::setMenuInactive()
{
  Open1->Enabled = false;
  ToolOpen->Enabled = false;
  Close1->Enabled = false;
  Run1->Enabled = false;
  ToolRun->Enabled = false;
  RunToCursor1->Enabled = false;
  ToolRunToCursor->Enabled = false;
  AutoTrace1->Enabled = false;
  ToolAutoTrace->Enabled = false;
  StepOver1->Enabled = false;
  ToolStep->Enabled = false;
  TraceInto1->Enabled = false;
  ToolTrace->Enabled = false;
  Pause1->Enabled = false;
  ToolPause->Enabled = false;
  Reset1->Enabled = false;
  ToolReset->Enabled = false;
}

//---------------------------------------------------------------------------
// Set the menu and toolbar to trace mode
void __fastcall TForm1::setMenuTrace()
{
  setMenuInactive();            // disable some debug commands
  Pause1->Enabled = true;       // except for reset and pause
  ToolPause->Enabled = true;
  Reset1->Enabled = true;
  ToolReset->Enabled = true;
  Close1->Enabled = true;     // except close
}

//---------------------------------------------------------------------------
void __fastcall TForm1::setMenuTask19()
{
  Open->ShortCut = 0;           // disable shortcut
  Run->ShortCut = 0;
  Step->ShortCut = 0;
  Trace->ShortCut = 0;
  Pause->ShortCut = 0;
  Rewind->ShortCut = 0;
  Reload->ShortCut = 0;
  AutoTrace->ShortCut = 0;
  RunToCursor->ShortCut = 0;
  LogStart->ShortCut = 0;
  LogStop->ShortCut = 0;
  disableKeyCommands = true;
}

//---------------------------------------------------------------------------
void __fastcall TForm1::restoreMenuTask19()
{
  Open->ShortCut = openCut;
  Run->ShortCut = runCut;
  Step->ShortCut = stepCut;
  Trace->ShortCut = traceCut;
  Pause->ShortCut = pauseCut;
  Rewind->ShortCut = rewindCut;
  Reload->ShortCut = reloadCut;
  AutoTrace->ShortCut = autoTraceCut;
  RunToCursor->ShortCut = runToCursorCut;
  LogStart->ShortCut = logStartCut;
  LogStop->ShortCut = logStopCut;
  disableKeyCommands = false;
}

//---------------------------------------------------------------------------
// Display the program listing
void __fastcall TForm1::ListBox1DrawItem(TWinControl *Control, int Index,
      TRect &Rect, TOwnerDrawState State)
{
  int i, tab, nSpaces, addr;
  AnsiString str;

  // note that we draw on the listbox’s canvas, not on the form
  TCanvas *pCanvas = ((TListBox *)Control)->Canvas;
  pCanvas->FillRect(Rect); // clear the rectangle

  int p = ScrollBar1->Position;

  // get text from current line
  str = ListBox1->Items->Strings[Index];

  // replace tab with correct number of spaces
  while((tab = str.Pos("\t")) != 0) {  // find next tab char
    str.Delete(tab,1);          // delete tab char from string
    nSpaces = tab - 1;          // calculate spaces needed for tab
    nSpaces = 8 - nSpaces%8;
    for (i = 0; i < nSpaces; i++)       // insert spaces into string
      str.Insert(" ",tab++);
  }

  breakP->Repaint();

  // adjust for scroll left & right
  if (p < str.Length() )
    str = str.SubString(p,str.Length() - p + 1);

  else
    str = "";

  pCanvas->TextOut(Rect.Left, Rect.Top, str);
}

//---------------------------------------------------------------------------
// Draw break point dots
void __fastcall TForm1::breakPPaint(TObject *Sender)
{
  int i, top, addr, Index, botIndex;
  AnsiString str;

  // if ListBox is empty
  if (ListBox1->Items->Count == 0)
    return;

  // index of bottom row
  botIndex = ListBox1->TopIndex + ListBox1->Height/ListBox1->ItemHeight;
  if (botIndex >= ListBox1->Items->Count)
    botIndex = ListBox1->Items->Count - 1;

  // for all rows in ListBox1
  for(Index = ListBox1->TopIndex; Index <= botIndex; Index++) {
    // location of image top
    top = (Index - ListBox1->TopIndex) * ListBox1->ItemHeight;

    // get text at Index
    str = ListBox1->Items->Strings[Index];

    if (Index > 2 && isInstruction(str))          // if instruction
    {
      // draw dot

      // is this address a break point?
      addr = StrToInt("0x" + str.SubString(1,8));
      for (i = 0; i < bpoints; i++)
        if (brkpt[i] == addr)
          break;
      if (i < bpoints)            // if this address is a break point
        ImageList1->Draw(breakP->Canvas,1,top,11,true);  // draw red dot
      else                        // else this address is not a break point
        ImageList1->Draw(breakP->Canvas,1,top,10,true);  // draw green dot
    }
    else {
      // erase old dot
      breakP->Canvas->FillRect(TRect(1,top,breakP->Width,top+ListBox1->ItemHeight));
    }
  }
}


//---------------------------------------------------------------------------
// set or clear break on this line
void __fastcall TForm1::breakPMouseDown(TObject *Sender,
      TMouseButton Button, TShiftState Shift, int X, int Y)
{
  int i, addr, Index;
  AnsiString str;

  try{
    if (Button == mbLeft) {
      // determine ListBox Index of mouse click
      Index = Y/ListBox1->ItemHeight + ListBox1->TopIndex;

      // get text from Index line
      str = ListBox1->Items->Strings[Index];

      // if valid address on this line
      if (Index > 2 && isInstruction(str))          // if instruction
      {
        addr = StrToInt("0x" + str.SubString(1,8)); // get address from line

        // is this address a break point?
        for (i = 0; i < bpoints; i++)
          if (brkpt[i] == addr)
            break;
        if (i < bpoints)            // if this address is a break point
          BreaksFrm->cbpoint(addr); // clear break point
        else
          BreaksFrm->sbpoint(addr); // set break point
      }
    //  breakP->Repaint();            // update display of breakpoints
    }
  }
  catch(...)
  {
    Application->MessageBox("Invalid Breakpoint Selection",NULL,mbOK);
  }
}

//---------------------------------------------------------------------------
// clear all break points from popup menu
void __fastcall TForm1::ClearAllPCBreakpoints1Click(TObject *Sender)
{
  BreaksFrm->cbpoint(-1);          // clear all break points
//  breakP->Repaint();            // update display of breakpoints
}

//---------------------------------------------------------------------------
// highlight the instruction
void __fastcall TForm1::highlight()
{
  int i, botIndex;
  AnsiString str;

  //ListBox1->ItemIndex = -1;   // remove highlight *ck 12-3-2005 for better macro behavior

  for (i=3; i<ListBox1->Items->Count; i++) {
    str = ListBox1->Items->Strings[i];
    if (regPC->EditText == str.UpperCase().SubString(1,8))  // if current instruction
      if (isInstruction(str) || halt)           // if instruction or program halted
        ListBox1->ItemIndex = i;                // highlight line
  }

  // make sure current instruction line is on screen
  if (ListBox1->ItemIndex > -1) {               // if line highlighted
    // index of bottom row
    botIndex = ListBox1->TopIndex + ListBox1->Height/ListBox1->ItemHeight;
    if (ListBox1->ItemIndex < ListBox1->TopIndex ||
        ListBox1->ItemIndex > botIndex)             // if not on screen
      ListBox1->TopIndex = ListBox1->ItemIndex - 2; // position highlighted row
  }
}

//---------------------------------------------------------------------------
void toUpper(string& str) {
  for(unsigned int x=0; x<str.length(); x++)
    str[x]=toupper(str[x]);
}

//---------------------------------------------------------------------------
// search for searchStr in ListBox and highlight line if found
// next = true to search for next match, false to search from top
void __fastcall TForm1::find(AnsiString str, bool next)
{
  int botIndex;
  static int i = 3;
  string searchStr, codeStr;

  if (!next)    // if not next item search
    i = 3;      // start search from top

  if (i>=ListBox1->Items->Count)                // if end of document
    return;

  searchStr = str.c_str();
  toUpper(searchStr);

  for (;i<ListBox1->Items->Count; i++) {        // for all rows of ListBox
    codeStr = ListBox1->Items->Strings[i].c_str();   // get text from this row
    toUpper(codeStr);

    if (codeStr.find(searchStr) != -1) {        // if string found
      ListBox1->ItemIndex = i++;                // highlight line
      break;
    }
  }

  // make sure highlighted line is on screen
  if (ListBox1->ItemIndex > -1) {               // if line highlighted
    // index of bottom row
    botIndex = ListBox1->TopIndex + ListBox1->Height/ListBox1->ItemHeight;
    if (ListBox1->ItemIndex < ListBox1->TopIndex ||
        ListBox1->ItemIndex > botIndex)             // if not on screen
      ListBox1->TopIndex = ListBox1->ItemIndex - 2; // position highlighted row
  }
}

// check to see if str contains a machine code instruction
// pre: str contains a line of code from the L68 file
// post: returns true if instruction, false if not
bool inline __fastcall TForm1::isInstruction(AnsiString &str)
{
  if (str.SubString(1,2) == "00" &&             // address
                 str[11] != ' ' &&              // data present
                 str[9] != '=' &&               // not DS or DC
                 str[11] != '=')                // not EQU or SET
    return true;
  return false;
}

//---------------------------------------------------------------------------
// write the current instruction line to the log file
// returns true on success
bool __fastcall TForm1::lineToLog()
{
  int topIndex, botIndex, midIndex;
  AnsiString str;
  bool foundPC = false;
  const int TOP_INDEX = 3;

  // index of bottom row
  botIndex = ListBox1->Count;
  if (botIndex > TOP_INDEX) {
    topIndex = TOP_INDEX;

    // do binary search for the current PC in the Listing
    do {
      midIndex = (botIndex - topIndex) / 2 + topIndex;
      str = ListBox1->Items->Strings[midIndex];
      if (regPC->EditText == str.SubString(1,8))     // if PC == Listing PC
        foundPC = true;
      else if (regPC->EditText < str.SubString(1,8)) // if PC < Listing PC
        botIndex = midIndex - 1;
      else                                           // else PC > Listing PC
        topIndex = midIndex + 1;
    } while(!foundPC && topIndex <= botIndex);

    if (foundPC) {
      do {      // skip comments and go to last row with this PC
        midIndex++;
        str = ListBox1->Items->Strings[midIndex];
      } while(regPC->EditText == str.SubString(1,8));
      midIndex--;
      str = ListBox1->Items->Strings[midIndex];
      str.Insert("PC=",0);              // add labels
      str.Insert("Code=",14);           // add labels
      str.Insert("Line=",42);           // add labels
      fprintf(ElogFile, str.c_str());   // output instruction to log file
      fprintf(ElogFile,"\n");
      fflush(ElogFile);                  // write all bufferred data to file
    }
  }
  return foundPC;
}

//---------------------------------------------------------------------------
void __fastcall TForm1::ScrollBar1Change(TObject *Sender)
{
  ListBox1->Repaint();
  // scroll HeadingLbl left and right
  int p = ScrollBar1->Position;
  if (p < HEADING_LIMIT)
    HeadingsLbl->Caption = HeadingStr.SubString(p,HeadingStr.Length() - p + 1);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormActivate(TObject *Sender)
{
  ListBox1->DoubleBuffered = true;
  MemoryFrm->DoubleBuffered = true;
  StackFrm->DoubleBuffered = true;
  //simIO->DoubleBuffered = true;
  breakP->Canvas->Brush->Color = clBtnFace;
  // clear the rectangle
//  breakP->Canvas->FillRect(TRect(0,0,breakP->Width,breakP->Height));
  if (clRun) {            // if command line Run
    clRun = false;
    RunExecute(Sender);
  }

}

//---------------------------------------------------------------------------
// change source window font
void __fastcall TForm1::FontSourceExecute(TObject *Sender)
{
  if (FontDialogSource->Execute()) {                 // if OK selected
    ListBox1->Font->Assign(FontDialogSource->Font);  // apply new font
    HeadingsLbl->Font->Assign(FontDialogSource->Font);
    int height = FontDialogSource->Font->Height;
    if (height < 0)
      height *= -1.1;
    height++;
    ListBox1->ItemHeight = height;
    Message->Font->Assign(FontDialogSource->Font);
  }
}

//---------------------------------------------------------------------------
// change output window font
void __fastcall TForm1::FontOutputExecute(TObject *Sender)
{
  if (FontDialogSimIO->Execute()) {                  // if OK selected
    simIO->BackBuffer->Canvas->Font->Assign(FontDialogSimIO->Font);  // apply new font
    simIO->Font->Assign(FontDialogSimIO->Font);
    simIO->setTextSize();
  }
}

//---------------------------------------------------------------------------
// printer font
void __fastcall TForm1::FontPrinterExecute(TObject *Sender)
{
  if (FontDialogPrinter->Execute()) {               // if OK selected
    initPrint();
  }
}

//---------------------------------------------------------------------------
// Source view font
void __fastcall TForm1::FontDialogSourceApply(TObject *Sender, HWND Wnd)
{
  ListBox1->Font->Assign(FontDialogSource->Font);
}

//---------------------------------------------------------------------------
// simIO font
void __fastcall TForm1::FontDialogSimIOApply(TObject *Sender, HWND Wnd)
{
  simIO->BackBuffer->Canvas->Font->Assign(FontDialogSimIO->Font);
}

//---------------------------------------------------------------------------
// Load registers from screen
void __fastcall TForm1::loadRegs()
{
  AnsiString str = "0x";

  // load each bit of SR
  SR = 0;
  for (int j=15;j>=0;j--)
  {
    if (regSR->EditText[16-j] == '1')
      SR = SR | 1<<j;
  }

  D[0] = StrToInt(str + regD0->EditText);
  D[1] = StrToInt(str + regD1->EditText);
  D[2] = StrToInt(str + regD2->EditText);
  D[3] = StrToInt(str + regD3->EditText);
  D[4] = StrToInt(str + regD4->EditText);
  D[5] = StrToInt(str + regD5->EditText);
  D[6] = StrToInt(str + regD6->EditText);
  D[7] = StrToInt(str + regD7->EditText);
  A[0] = StrToInt(str + regA0->EditText);
  A[1] = StrToInt(str + regA1->EditText);
  A[2] = StrToInt(str + regA2->EditText);
  A[3] = StrToInt(str + regA3->EditText);
  A[4] = StrToInt(str + regA4->EditText);
  A[5] = StrToInt(str + regA5->EditText);
  A[6] = StrToInt(str + regA6->EditText);
  A[a_reg(7)] = StrToInt(str + regA7->EditText);
  A[8] = StrToInt(str + regA8->EditText);
  PC = OLD_PC = StrToInt(str + regPC->EditText);

}


//---------------------------------------------------------------------------

void __fastcall TForm1::regSRKeyPress(TObject *Sender, char &Key)
{
  if (regSR->SelLength > 1)     // allow only one char to be changed at a time
    regSR->SelLength = 1;

  if (Key == VK_BACK) {
    regSR->SelLength = 0;
    Key = '0';
  }
  if (Key<'0' || Key>'1') {
    Beep();                     // allow only 0's and 1's
    regSR->SelLength = 0;
    Key = '0';
  }

}
//---------------------------------------------------------------------------
void __fastcall TForm1::regSRChange(TObject *Sender)
{
  String str;
  if (regSR->EditText[3] == '1')   // if Supervisor mode
    regA7->Text = str.sprintf("%08lX",A[8]);
  else
    regA7->Text = str.sprintf("%08lX",A[7]);

  StackFrm->updateDisplay();
}

//---------------------------------------------------------------------------


void __fastcall TForm1::Stack1Click(TObject *Sender)
{
  StackFrm->Show();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::OutputWindow1Click(TObject *Sender)
{
  if (simIO->fullScreen){
    simIO->fullScreen = false;
    simIO->setupWindow();
  }else{
    simIO->Show();
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::regKeyPress(TObject *Sender, char &Key)
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

void __fastcall TForm1::RegChange(TObject *Sender)
{
  //loadRegs();
  StackFrm->updateDisplay();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::regA0KeyUp(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  str = "0x";
  A[0] = StrToInt(str + regA0->EditText);
  StackFrm->updateDisplay();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::regA1KeyUp(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  str = "0x";
  A[1] = StrToInt(str + regA1->EditText);
  StackFrm->updateDisplay();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::regA2KeyUp(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  str = "0x";
  A[2] = StrToInt(str + regA2->EditText);
  StackFrm->updateDisplay();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::regA3KeyUp(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  str = "0x";
  A[3] = StrToInt(str + regA3->EditText);
  StackFrm->updateDisplay();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::regA4KeyUp(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  str = "0x";
  A[4] = StrToInt(str + regA4->EditText);
  StackFrm->updateDisplay();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::regA5KeyUp(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  str = "0x";
  A[5] = StrToInt(str + regA5->EditText);
  StackFrm->updateDisplay();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::regA6KeyUp(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  str = "0x";
  A[6] = StrToInt(str + regA6->EditText);
  StackFrm->updateDisplay();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::regA7KeyUp(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  AnsiString str = "0x";
  if (regSR->EditText[3] == '1') {   // if Supervisor mode
    regA8->Text = regA7->EditText;
    A[8] = StrToInt(str + regA8->EditText);
  } else {
    regUS->Text = regA7->EditText;
    A[7] = StrToInt(str + regA7->EditText);
  }
  StackFrm->updateDisplay();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::regUSKeyUp(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  AnsiString str = "0x";
  if (regSR->EditText[3] == '0')    // if User mode
    regA7->Text = regUS->EditText;
  A[7] = StrToInt(str + regUS->EditText);
  StackFrm->updateDisplay();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::regA8KeyUp(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  AnsiString str = "0x";
  if (regSR->EditText[3] == '1')   // if Supervisor mode
    regA7->Text = regA8->EditText;
  A[8] = StrToInt(str + regA8->EditText);
  StackFrm->updateDisplay();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::regPCChange(TObject *Sender)
{
  // If NOT (auto trace AND display is disabled)
  if(!(autoTraceInProgress && AutoTraceOptions->DisableDisplay->Checked))
  {
    StackFrm->updateDisplay();
    highlight();                  // highlight code at PC
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Memory1Click(TObject *Sender)
{
  MemoryFrm->Show();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormShow(TObject *Sender)
{
  AnsiString fileName, ext, option;

  Form1->Caption = TITLE;       // set title

  LoadSettings();               // load simulator settings from file
  initSim();                    // don't call before LoadSettings()

  if (ParamCount() > 0)         // if parameters are present
  {
    fileName = ParamStr(1);     // get file name to open
    ext = ExtractFileExt(fileName.UpperCase());     // get file extension

    if (FileExists(fileName) && ext == ".S68") {
      OpenDialog1->FileName = fileName;         // save for reload
      OpenFile(fileName);       // open specified file
      Log->setLogFileNames(fileName);
    }
  }
  // check for additional command line parameters       CK 1-25-2008
  for (int i=2;i<=ParamCount();i++)
  {
    if (LowerCase(ParamStr(i)) == "/r")
      clRun = true;
    else if (LowerCase(ParamStr(i)) == "/f") {
      simIO->fullScreen = true;
      simIO->setupWindow();
    } else if (LowerCase(ParamStr(i)) == "/e") {
      exceptions = true;
      ExceptionsEnabled->Checked = true;
    } else if (LowerCase(ParamStr(i)) == "/b") {
      bitfield = true;
      BitFieldEnabled->Checked = true;
    }
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::BreakPoints1Click(TObject *Sender)
{
  BreaksFrm->Show();
}
//---------------------------------------------------------------------------


void __fastcall TForm1::FormResize(TObject *Sender)
{
  Form1->Repaint();
}
//---------------------------------------------------------------------------

// Clear Cycles button pressed
void __fastcall TForm1::ClearCyclesClick(TObject *Sender)
{
  AnsiString str;

  cycles = 0;
  cyclesDisplay->Caption = str.sprintf("%u",cycles);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::LogOutput1Click(TObject *Sender)
{
  Log->Show();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::ExceptionsEnabledClick(TObject *Sender)
{
  if (exceptions) {
    exceptions = false;
    ExceptionsEnabled->Checked = false;
  } else {
    exceptions = true;
    ExceptionsEnabled->Checked = true;
  }
  SaveSettings();
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
  displayHelp("SIM_BASIC");
}

//---------------------------------------------------------------------------

void __fastcall TForm1::FormKeyDown(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
   if (disableKeyCommands)
     return;

   // this logic requires checking for Ctrl keys first
   if (Key == VK_F1)
     Form1->displayHelp("SIM_BASIC");
   else if (Key == VK_TAB && Shift.Contains(ssCtrl))    // if Ctrl+Tab
     simIO->BringToFront();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::BringToFront()
{
  Form1->SetFocus();
}
//---------------------------------------------------------------------------

// Set PC to address on Double-Clicked line
void __fastcall TForm1::ListBox1DblClick(TObject *Sender)
{
  int i, botIndex;
  AnsiString str;

  str = ListBox1->Items->Strings[ListBox1->ItemIndex];
  if (isInstruction(str))          // if instruction
    regPC->EditText = str.SubString(1,8);           // set PC to this line
}
//---------------------------------------------------------------------------

void __fastcall TForm1::AutoTraceExecute(TObject *Sender)
{
  AutoTraceTimer->Enabled = true;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::AutoTraceTimerTimer(TObject *Sender)
{
  if (!inputMode)
  {
    if(!autoTraceInProgress)
    {
      autoTraceInProgress = true;   // prevent calling until finished
      TraceExecute(Sender);
      autoTraceInProgress = false;
    }
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::SimulatorOptionsClick(TObject *Sender)
{
  AutoTraceOptions->ShowModal();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Hardware1Click(TObject *Sender)
{
  Hardware->Show();
}
//---------------------------------------------------------------------------


void __fastcall TForm1::ReloadExecute(TObject *Sender)
{
  OpenFile(OpenDialog1->FileName);
  Log->addMessage("\n***** Reload Program Pressed *****\n");
}
//---------------------------------------------------------------------------




void __fastcall TForm1::PrinterSetup1Click(TObject *Sender)
{
  PrinterSetupDialog1->Execute();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::mmuFullscreenOptionsClick(TObject *Sender)
{
  if (MultimonitorAPIsExist){
    if (simIO->fullScreen == false){
      frmFullscreenOptions->ShowModal();
    }else{
      Application->MessageBox("Please deactivate fullscreen mode before attempting to change the fullscreen settings.",NULL,MB_OK);
    }
  }else{
    Application->MessageBox("Sorry, but your system does not seem to support multiple monitors.",NULL, MB_OK); 
  }
}

//---------------------------------------------------------------------------

void TForm1::OnDisplayChange(TWMDisplayChange& temp){
  //Form1->Left = Form1->Left;
  //Application->MessageBox(static_cast<AnsiString>(Form1->Left).c_str(), NULL, MB_OK);
}

//---------------------------------------------------------------------------


void __fastcall TForm1::regPCDblClick(TObject *Sender)
{
  highlight();          // highlight current PC in program listing
}
//---------------------------------------------------------------------------

void __fastcall TForm1::regDblClick(TObject *Sender)
{
  MemoryFrm->Address1->EditText = ((TMaskEdit*)(Sender))->EditText;
  MemoryFrm->Show();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::LogStartExecute(TObject *Sender)
{
  Log->startLog();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::LogStopExecute(TObject *Sender)
{
  Log->stopLog();
}

//---------------------------------------------------------------------------
void __fastcall TForm1::SaveSettings()
// saves simulator settings to file
{
  try {
    AnsiString str;
    str = ExtractFilePath(Application->ExeName) + "sim68K.dat";
    char fileName[256];
    strcpy(fileName, str.c_str());        // fileName is path + sim68K.dat
    ofstream File(fileName);              //open settings file

    // write settings to file
    File << "$Settings for " << TITLE << "  DO NOT EDIT THIS FILE!!!!\n"
         << ElogFlag                                     << "$exec log\n"
         << OlogFlag                                     << "$output log\n"
         << exceptions                                   << "$exceptions\n"
         << Form1->Top                                   << "$main top\n"
         << Form1->Left                                  << "$main left\n"
         << Form1->Height                                << "$main height\n"
         << Form1->Width                                 << "$main width\n"
         << simIO->Top                                   << "$simIO top\n"
         << simIO->Left                                  << "$simIO left\n"
         << simIO->Visible                               << "$simIO visible\n"
         << MemoryFrm->Top                               << "$memory top\n"
         << MemoryFrm->Left                              << "$memory left\n"
         << MemoryFrm->Address1->EditText.Trim().c_str() << "$memory address\n"
         << MemoryFrm->Visible                           << "$memory visible\n"
         << StackFrm->Top                                << "$stack top\n"
         << StackFrm->Left                               << "$stack left\n"
         << StackFrm->Height                             << "$stack height\n"
         << StackFrm->whichStack->ItemIndex              << "$which stack\n"
         << StackFrm->Visible                            << "$stack visible\n"
         << Hardware->Top                                << "$hardware top\n"
         << Hardware->Left                               << "$hardware left\n"
         << Hardware->seg7addr->EditText.Trim().c_str()  << "$7-segment address\n"
         << Hardware->LEDaddr->EditText.Trim().c_str()   << "$LED address\n"
         << Hardware->switchAddr->EditText.Trim().c_str()<< "$switch address\n"
         << Hardware->pbAddr->EditText.Trim().c_str()    << "$button address\n"
         << Hardware->Visible                            << "$hardware visible\n"
         << simIO->Font->Name.c_str()                    << "$output font name\n"
         << simIO->Font->Size                            << "$output font size\n"
         << Form1->ListBox1->Font->Name.c_str()          << "$listing font name\n"
         << Form1->ListBox1->Font->Size                  << "$listing font size\n"
         << Form1->FontDialogPrinter->Font->Name.c_str() << "$printer font name\n"
         << Form1->FontDialogPrinter->Font->Size         << "$printer font size\n"
         << FullScreenMonitor                            << "$fullscreen monitor\n"
         << bitfield                                     << "$bit field enabled\n"
         << AutoTraceOptions->AutoTraceInterval->Text.c_str() << "$auto trace interval\n"
         << AutoTraceOptions->DisableDisplay->Checked    << "$disable display\n";

    File.close();
  }
  catch( ... ) {
    MessageDlg("Error saving Sim68K settings",mtInformation, TMsgDlgButtons() << mbOK,0);
    return;
  }
}

//--------------------------------------------------------------------------
// Sets default settings for simulator
void __fastcall TForm1::defaultSettings()
{
  try {
    ElogFlag = 0;               // disable logging on startup
    OlogFlag = 0;
    logging = false;
    exceptions = false;         // default to exceptions off
    bitfield = false;           // default to bitfield instruction off
    simhalt_on = true;          // default to SIMHALT enabled

    Form1->ToolLogStart->Enabled = false;
    Form1->ToolLogStop->Enabled = false;
    Form1->LogStart->Enabled = false;
    Form1->LogStop->Enabled = false;

    Log->ELogType->ItemIndex = 0;
    Log->OLogType->ItemIndex = 0;

    simIO->Top = SIMIO_FORM_TOP;            //'SimIO Form Top' setting
    simIO->Left = SIMIO_FORM_LEFT;          //'SimIO Form Left' setting
    simIO->Visible = true;                  //'simIO Visible'
    MemoryFrm->Top = MEMORY_FORM_TOP;       //'Memory Form Top' setting
    MemoryFrm->Left = MEMORY_FORM_LEFT;     //'Memory Form Left' setting
    StackFrm->Top = STACK_FORM_TOP;         //'Stack Form Top' setting
    StackFrm->Left = STACK_FORM_LEFT;       //'Stack Form Left' setting
    StackFrm->Height = STACK_FORM_HEIGHT;   //'Stack Form Height' setting
    StackFrm->whichStack->ItemIndex = 8;    // which stack
    Hardware->Top = HARDWARE_FORM_TOP;
    Hardware->Left = HARDWARE_FORM_LEFT;
    Hardware->seg7addr->Text   = "E00000";
    Hardware->LEDaddr->Text    = "E00010";
    Hardware->switchAddr->Text = "E00012";
    Hardware->pbAddr->Text     = "E00014";

    // SimIO Font
    Form1->FontDialogSimIO->Font->Name = "Fixedsys";
    Form1->FontDialogSimIO->Font->Size = 9;

    // Source Font
    Form1->FontDialogSource->Font->Name = "Courier New";
    Form1->FontDialogSource->Font->Size = 10;

    // Printer Font
    Form1->FontDialogPrinter->Font->Name = "Courier New";
    Form1->FontDialogPrinter->Font->Size = 10;

    // Auto Trace Options
    AutoTraceOptions->AutoTraceInterval->Text = "200";
    AutoTraceOptions->DisableDisplay->Checked = false;

  }
  catch( ... ) {
    MessageDlg("Error setting default Sim68K settings",mtInformation, TMsgDlgButtons() << mbOK,0);
    return;
  }
}

//--------------------------------------------------------------------------
// Loads the simulator settings from sim68K.dat file.  True and false settings
// are saved as 1 and 0.
// If the contents of sim68K.dat to not match expected then default values
// are used.
void __fastcall TForm1::LoadSettings()
{
  try {
    const int SIZE = 256;
    AnsiString str;
    str = ExtractFilePath(Application->ExeName) + "sim68K.dat";
    char fileName[SIZE];
    strcpy(fileName, str.c_str());      // fileName is path + sim68K.dat

    defaultSettings();            // start with defaults

    if(FileExists(fileName))      //check if settings file exists
    {                             //if it did then load all the settings
      char buffer[SIZE+1];
      char temp[SIZE+1];          //temp storage
      unsigned int index;         //looping index
      ifstream File(fileName);    //open settings file

      // read and set flags from file
      File.getline(buffer, SIZE); //first line contains version number

      File.getline(buffer, SIZE);       //this is the 'log type' setting
      if (!strcmp(&buffer[1],"$exec log")) {    // if expected setting
        if(buffer[0] >= 0 && buffer[0] <= 3) {  // if valid range
          Log->ELogType->ItemIndex = buffer[0];
          ElogFlag = Log->ELogType->ItemIndex;
        }
      }

      File.getline(buffer, SIZE);  //this is the 'Output log type' setting
      if (!strcmp(&buffer[1],"$output log")) {  // if expected setting
        if(buffer[0] >= 0 && buffer[0] <= 1) {  // if valid range
          Log->OLogType->ItemIndex = buffer[0];
          OlogFlag = Log->OLogType->ItemIndex;
        }
      }

      File.getline(buffer, SIZE); //this is the 'exceptions' setting
      if (!strcmp(&buffer[1],"$exceptions")) {  // if expected setting
        if(buffer[0] == '1')
          exceptions = true;
      }

      File.getline(buffer, SIZE); //this is 'Main Form Top' setting
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$main top")) {  // if expected setting
        int top = atoi(temp);
        if(top > Screen->Height - 20)   // If off screen bottom
          Form1->Top = FORM1_TOP;       // Force on screen
        else
          Form1->Top = top;             // Use saved value
      }

      File.getline(buffer, SIZE); //this is 'Main Form Left' setting
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$main left")) {  // if expected setting
        int left = atoi(temp);  // Form left
        if(left > Screen->Width - 20)   // If off screen right
          Form1->Left = FORM1_LEFT;     // Force on screen
        else
          Form1->Left = left;   // Use saved value
      }

      File.getline(buffer, SIZE); //this is 'Main Form Height' setting
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$main height")) {  // if expected setting
        int height = atoi(temp);
        if(height > Screen->Height) // If taller than screen
          Form1->Height = Screen->Height;   // Set to screen height
        else
          Form1->Height = atoi(temp);   // Use saved value
      }

      File.getline(buffer, SIZE); //this is 'Main Form Width' setting
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$main width")) {  // if expected setting
        int width = atoi(temp);
        if(width > Screen->Width)   // If wider than screen
          Form1->Width = Screen->Width; // Set to sreen width
        else
          Form1->Width = atoi(temp);    // Used saved value
      }

      File.getline(buffer, SIZE); //this is 'SimIO Form Top' setting
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$simIO top")) {  // if expected setting
        int top = atoi(temp);
        if(top > Screen->Height - 20)   // If off screen bottom
        {
          simIO->Top = SIMIO_FORM_TOP;     // Force on screen
        }else
          simIO->Top = top;
      }

      File.getline(buffer, SIZE); //this is 'SimIO Form Left' setting
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$simIO left")) {  // if expected setting
        int left = atoi(temp);
        if(left > Screen->Width - 20)   // If off screen right
        {
          simIO->Left = SIMIO_FORM_LEFT;
        }else
          simIO->Left = atoi(temp);
      }

      File.getline(buffer, SIZE); //this is 'SimIO Visible' setting
      if (!strcmp(&buffer[1],"$simIO visible")) {  // if expected setting
        if(buffer[0] == '1')
          simIO->Show();
      }

      File.getline(buffer, SIZE); //this is 'Memory Form Top' setting
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$memory top")) {  // if expected setting
        int top = atoi(temp);
        if(top > Screen->Height - 20) // If off screen bottom
          MemoryFrm->Top = MEMORY_FORM_TOP; // Force on screen
        else
          MemoryFrm->Top = top;     // Use saved value
      }

      File.getline(buffer, SIZE); //this is 'Memory Form Left' setting
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$memory left")) {  // if expected setting
        int left = atoi(temp);
        if(left > Screen->Width - 20)   // If off screen right
          MemoryFrm->Left = MEMORY_FORM_LEFT;        // Force on screen
        else
          MemoryFrm->Left = left;       // Use saved value
      }

      File.getline(buffer, SIZE); //this is 'Memory Form Address' setting
      index = 0;                  //reset looping index
      while(buffer[index] != '$'
            && index < strlen(buffer)) //we need to extract only the number
      {                                //which is all the chars before the '$'
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$memory address")) {  // if expected setting
        MemoryFrm->Address1->Text = temp;
      }

      File.getline(buffer, SIZE); //this is 'Memory Form Visible' setting
      if (!strcmp(&buffer[1],"$memory visible")) {  // if expected setting
        if(buffer[0] == '1')
          MemoryFrm->Show();
      }

      File.getline(buffer, SIZE); //this is 'Stack Form Top' setting
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$stack top")) {  // if expected setting
        int top = atoi(temp);
        if(top > Screen->Height - 20)
          top = STACK_FORM_TOP;
        StackFrm->Top = top;
      }

      File.getline(buffer, SIZE); //this is 'Stack Form Left' setting
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$stack left")) {  // if expected setting
        int left = atoi(temp);
        if(left > Screen->Width - 20)
          left = STACK_FORM_LEFT;
        StackFrm->Left = left;
      }

      File.getline(buffer, SIZE); //this is 'Stack Form Height' setting
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$stack height")) {  // if expected setting
        StackFrm->Height = atoi(temp);
      }

      File.getline(buffer, SIZE); //this is 'Stack Form which Stack' setting
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$which stack")) {  // if expected setting
        StackFrm->whichStack->ItemIndex = atoi(temp);
      }

      File.getline(buffer, SIZE); //this is 'Stack Form Visible' setting
      if (!strcmp(&buffer[1],"$stack visible")) {  // if expected setting
        if(buffer[0] == '1')
          StackFrm->Show();
      }

      // ----- Hardware form settings -----

      File.getline(buffer, SIZE); //this is 'Hardware Form Top' setting
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$hardware top")) {  // if expected setting
        int top = atoi(temp);
        if(top > Screen->Height - 20)
          top = HARDWARE_FORM_TOP;
        Hardware->Top = top;
      }

      File.getline(buffer, SIZE); //this is 'Hardware Form Left' setting
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$hardware left")) {  // if expected setting
        int left = atoi(temp);
        if(left > Screen->Width - 20)
          left = HARDWARE_FORM_LEFT;
        Hardware->Left = left;
      }

      File.getline(buffer, SIZE); //this is 'Hardware 7-seg Address' setting
      index = 0;                  //reset looping index
      while(buffer[index] != '$'
            && index < strlen(buffer)) //we need to extract only the number
      {                                //which is all the chars before the '$'
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$7-segment address")) {  // if expected setting
        Hardware->seg7addr->Text = temp;
      }

      File.getline(buffer, SIZE); //this is 'Hardware LED Address' setting
      index = 0;                  //reset looping index
      while(buffer[index] != '$'
            && index < strlen(buffer)) //we need to extract only the number
      {                                //which is all the chars before the '$'
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$LED address")) {  // if expected setting
        Hardware->LEDaddr->Text = temp;
      }

      File.getline(buffer, SIZE); //this is 'Hardware switch Address' setting
      index = 0;                  //reset looping index
      while(buffer[index] != '$'
            && index < strlen(buffer)) //we need to extract only the number
      {                                //which is all the chars before the '$'
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$switch address")) {  // if expected setting
        Hardware->switchAddr->Text = temp;
      }

      File.getline(buffer, SIZE); //this is 'Hardware push button Address' setting
      index = 0;                  //reset looping index
      while(buffer[index] != '$'
            && index < strlen(buffer)) //we need to extract only the number
      {                                //which is all the chars before the '$'
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$button address")) {  // if expected setting
        Hardware->pbAddr->Text = temp;
      }

      File.getline(buffer, SIZE);        //this is 'Hardware Form Visible' setting
      if (!strcmp(&buffer[1],"$hardware visible")) {  // if expected setting
        if(buffer[0] == '1')
          Hardware->Show();
      }

      // SimIO Font
      File.getline(buffer, SIZE);   //this is 'SimIO Font Name"
      index = 0;                  //reset looping index
      while(buffer[index] != '$'
            && index < strlen(buffer)) //we need to extract only the number
      {                                //which is all the chars before the '$'
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$output font name")) {  // if expected setting
        Form1->FontDialogSimIO->Font->Name = temp;
      }

      File.getline(buffer, SIZE);   //this is 'SimIO Font Size"
      index = 0;                  //reset looping index
      while(buffer[index] != '$'
            && index < strlen(buffer)) //we need to extract only the number
      {                                //which is all the chars before the '$'
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$output font size")) {  // if expected setting
        Form1->FontDialogSimIO->Font->Size = atoi(temp);
      }

      // Listing Font
      File.getline(buffer, SIZE);   //this is 'Listing Font Name"
      index = 0;                  //reset looping index
      while(buffer[index] != '$'
            && index < strlen(buffer)) //we need to extract only the number
      {                                //which is all the chars before the '$'
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$listing font name")) {  // if expected setting
        Form1->FontDialogSource->Font->Name = temp;
      }

      File.getline(buffer, SIZE);   //this is 'Listing Font Size"
      index = 0;                  //reset looping index
      while(buffer[index] != '$'
            && index < strlen(buffer)) //we need to extract only the number
      {                                //which is all the chars before the '$'
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$listing font size")) {  // if expected setting
        Form1->FontDialogSource->Font->Size = atoi(temp);
      }

      // Printer Font
      File.getline(buffer, SIZE);   //this is 'Printer Font Name"
      index = 0;                  //reset looping index
      while(buffer[index] != '$'
            && index < strlen(buffer)) //we need to extract only the number
      {                                //which is all the chars before the '$'
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$printer font name")) {  // if expected setting
        Form1->FontDialogPrinter->Font->Name = temp;
      }

      File.getline(buffer, SIZE);   //this is 'Printer Font Size"
      index = 0;                  //reset looping index
      while(buffer[index] != '$'
            && index < strlen(buffer)) //we need to extract only the number
      {                                //which is all the chars before the '$'
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$printer font size")) {  // if expected setting
        Form1->FontDialogPrinter->Font->Size = atoi(temp);
      }

      File.getline(buffer, SIZE);   // FullScreenMonitor
      index = 0;                  //reset looping index
      while(buffer[index] != '$'
            && index < strlen(buffer)) //we need to extract only the number
      {                                //which is all the chars before the '$'
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$fullscreen monitor")) {  // if expected setting
        FullScreenMonitor = atoi(temp);
      }

      File.getline(buffer, SIZE);         //this is the 'bit field' setting
      if (!strcmp(&buffer[1],"$bit field enabled")) {  // if expected setting
        if(buffer[0] == '1')
          bitfield = true;
      }


      File.getline(buffer, SIZE);       //this is 'auto trace interval'
      index = 0;                        //reset looping index
      while(buffer[index] != '$'
            && index < strlen(buffer))  //we need to extract only the number
      {                                 //which is all the chars before the '$'
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$auto trace interval")) {  // if expected setting
        AutoTraceOptions->UpDown1->Position = atoi(temp);
      }

      File.getline(buffer, SIZE);       // 'disable display' setting
      if (!strcmp(&buffer[1],"$disable display")) {  // if expected setting
        if(buffer[0] == '1') {
          AutoTraceOptions->DisableDisplay->Checked = true;
        } else {
          AutoTraceOptions->DisableDisplay->Checked = false;
        }
      }


      File.close();
    } // endif

  Form1->ExceptionsEnabled->Checked = exceptions;
  Form1->BitFieldEnabled->Checked = bitfield;

  }
  catch( ... ) {
    MessageDlg("Error loading Sim68k settings",mtInformation, TMsgDlgButtons() << mbOK,0);
    return;
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::BitFieldEnabledClick(TObject *Sender)
{
  if (bitfield) {
    bitfield = false;
    BitFieldEnabled->Checked = false;
  } else {
    bitfield = true;
    BitFieldEnabled->Checked = true;
  }
  SaveSettings();
}
//---------------------------------------------------------------------------


void __fastcall TForm1::WindowSizeClick(TObject *Sender)
{
  switch(((TComponent *)Sender)->Tag)
  {
    case 0:     // 640x480
      simIO->setWindowSize((short)640,(short)480);
      break;
    case 1:     // 800x600
      simIO->setWindowSize((short)800,(short)600);
      break;
    case 2:     // 1024x768
      simIO->setWindowSize((short)1024,(short)768);
      break;
    case 3:     // 1280x800
      simIO->setWindowSize((short)1280,(short)800);
      break;
    case 4:     // 1280x1024
      simIO->setWindowSize((short)1280,(short)1024);
      break;
    case 5:     // 1440x900
      simIO->setWindowSize((short)1440,(short)900);
      break;
    case 6:     // 1680x1050
      simIO->setWindowSize((short)1680,(short)1050);
      break;
    case 7:     // 1920x1080
      simIO->setWindowSize((short)1920,(short)1080);
      break;
    case 8:     // 1920x1200
      simIO->setWindowSize((short)1920,(short)1200);
      break;
    default:    // 640x480
      simIO->setWindowSize((short)640,(short)480);
  }
  ((TMenuItem *)Sender)->Checked = true;

}
//---------------------------------------------------------------------------

void __fastcall TForm1::WindowSizeChecked()
{
  ushort width, height;
  simIO->getWindowSize(width, height);
  Size640x480->Checked = false;
  Size800x600->Checked = false;
  Size1024x768->Checked = false;
  Size1280x800->Checked = false;
  Size1280x1024->Checked = false;
  Size1440x900->Checked = false;
  Size1680x1050->Checked = false;
  Size1920x1080->Checked = false;
  Size1920x1200->Checked = false;
  if(width == 640 && height == 480)
    Size640x480->Checked = true;
  else if(width == 800 && height == 600)
    Size800x600->Checked = true;
  else if(width == 1024 && height == 768)
    Size1024x768->Checked = true;
  else if(width == 1280 && height == 800)
    Size1280x800->Checked = true;
  else if(width == 1280 && height == 1024)
    Size1280x1024->Checked = true;
  else if(width == 1440 && height == 900)
    Size1440x900->Checked = true;
  else if(width == 1680 && height == 1050)
    Size1680x1050->Checked = true;
  else if(width == 1920 && height == 1080)
    Size1920x1080->Checked = true;
  else if(width == 1920 && height == 1200)
    Size1920x1200->Checked = true;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::OutputWindowTextWrap1Click(TObject *Sender)
{
  if(OutputWindowTextWrap1->Checked)
  {
    simIO->setTextWrap(false);
    OutputWindowTextWrap1->Checked = false;
  } else {
    simIO->setTextWrap(true);
    OutputWindowTextWrap1->Checked = true;
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::SearchExecute(TObject *Sender)
{
  findDialogFrm->Show();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::GotoPC1Click(TObject *Sender)
{
  highlight();        
}
//---------------------------------------------------------------------------

void __fastcall TForm1::EASyBIN1Click(TObject *Sender)
{
  AnsiString easybin;
  //run EASyBIN
  easybin = ExtractFilePath(Application->ExeName) + "EASyBIN.EXE";
  spawnl(P_NOWAITO, easybin.c_str(), ParamStr(0).c_str(), NULL);
}
//---------------------------------------------------------------------------

