//---------------------------------------------------------------------------
/*
Program: 68K Editor IDE
Written By: Tim Larson
Program Start Date: January 24, 2002
Modified By: Charles Kelly

*******
PURPOSE
*******
I have designed this program for my CIS 258 Assembly Language Programming using
the 68000 class at Monroe County Community College.


***********
Description
***********

The 68K Editor is a 68000 code editing program that has an integrated assembler.
The IDE allows you to write programs and easily assemble them using a familar
Windows look.  It is designed to work with the 68000 Simulator, written by Charles
Kelly, to run the assembled programs.

------------------------------------------------------------------------------*/


#include <vcl.h>
#include <vcl\Printers.hpp>
#include <fstream.h>

#pragma hdrstop

#include "HtmlHelp.h"
#include "help.h"
#include "mainS.h"
#include "optionsS.h"
#include "editorOptions.h"
#include "assembleS.h"
#include "listS.h"
#include "aboutS.h"
#include "textS.h"
#include "chksaveS.h"
#include "findDialogS.h"
#include "asm.h"


//---------------------------------------------------------------------------
#pragma package(smart_init)

#pragma resource "*.dfm"
TMain *Main;

extern bool listFlag;           // create Listing file
extern bool objFlag;            // create S-Record file
extern bool CEXflag;            // expand constants
extern bool BITflag;            // True to assemble bitfield instructions
extern bool CREflag;            // display symbol table in listing
extern bool MEXflag;            // macro expansion
extern bool SEXflag;            // structured expansion
extern bool WARflag;            // display warnings
extern tabTypes tabType;
extern bool maximizedEdit;      // true starts child edit window maximized

void __fastcall SaveFont(TTextStuff *);

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
  catch(...) {
    ShowMessage("Error loading Html Help");
    return false;
  }
}


//---------------------------------------------------------------------------
__fastcall TMain::TMain(TComponent* Owner)
        : TForm(Owner)
{
  iNewFiles   = 0;     //used to name new files
  iListsOpen  = 0;
  iSourceOpen = 0;

  // Make size 2/3 of screen
  Main->Width = Screen->Width*2.0/3.0;
  Main->Height = Screen->Height*2.0/3.0;

  // initialize helpfile location -- m_asHelpFile is an AnsiString type private
  // member of the TForm1 class

  m_asHelpFile = ExtractFilePath(Application->ExeName) + "help.chm";
  m_asHelpFile = ExpandFileName(m_asHelpFile);

  // make sure the helpfile exists and display a message if not
  if (!FileExists(m_asHelpFile))
    ShowMessage("Help file not found\n" + m_asHelpFile);

  // Load the HTML Help library
  if (!LoadHtmlHelp())
  {
    ShowMessage("HTML Help was not detected on this computer. EASy68K help may not work correctly.");
  }

  // With dynamic loading it's advised to use HH_INITIALIZE. See the comments
  // for OnClose for more information on why...
  if (HHLibrary != 0)
    __HtmlHelp(NULL, NULL, HH_INITIALIZE, (DWORD)&m_Cookie);

  // initialize the Context combobox items
  //ContextComboBox->Items->AddObject("1000 (home page)", (TObject*)1000);
  //ContextComboBox->Items->AddObject("1001 (test topic1)", (TObject*)1001);
  //ContextComboBox->Items->AddObject("1002 (test topic2)", (TObject*)1002);
  // set initial combobox selection
  //TopicComboBox->ItemIndex = 0;
  //ContextComboBox->ItemIndex = 0;

  DragAcceptFiles(Handle, true);        // enable drag-n-drop from explorer
}

//---------------------------------------------------------------------------
// Shows save as dialog.
// Proper flags are set for the FileInfo structure (Project).
void __fastcall TMain::mnuSaveAsClick(TObject *Sender)
{
  //grab active mdi child
  TTextStuff *Active = (TTextStuff*)this->ActiveMDIChild;

  if(Active->Project.HasName) //if file has been named
    // default to current name
    SaveDialog->FileName = Active->Project.CurrentFile;

  if(SaveDialog->Execute())
  {
    if (FileExists(SaveDialog->FileName))
      if (Application->MessageBox("File exists! OK to overwrite?","Caution!",MB_YESNO) == IDNO)
        return;
    AnsiString ext = ExtractFileExt(SaveDialog->FileName);
    Active->Project.CurrentFile = SaveDialog->FileName;
    if(ext == ".X68") //make sure the file structure is set for a source file to allow assembly
    {
      Active->Project.IsSource = true;
      //Active->Project.SourceOpen = true;
    }
    else if(ext == "*.*") //setup the form for a list
    {
      Active->Project.IsSource = false;
      //Active->Project.SourceOpen = false;
    }
    Active->SourceText->Lines->SaveToFile(Active->Project.CurrentFile);
    SaveFont(Active);           // save font and tab info to file if source
    //Active->clearUndoRedo();

    //update modified StatusBar item
    Active->SourceText->Modified = false;
    Active->UpdateStatusBar();
    Active->Caption = ExtractFileName(Active->Project.CurrentFile);
    Active->Project.HasName = true;
    //Application->Title = Main->Caption + "-" + Active->Caption; //<---taskbar
  }
}

//---------------------------------------------------------------------------
//Saves file, if file has not been named yet then the SaveAs function is called
void __fastcall TMain::mnuSaveClick(TObject *Sender)
{
  //grab active mdi child
  TTextStuff *Active = (TTextStuff*)this->ActiveMDIChild;
  if(Active->Project.HasName) //file has been named so save it
  {
    Active->SourceText->Lines->SaveToFile(Active->Project.CurrentFile);
    SaveFont(Active);
    // Active->clearUndoRedo();

    //update modified StatusBar item
    Active->SourceText->Modified = false;
    Active->UpdateStatusBar();
  }
  else  //file has not been previously saved so call the Save As dialog
  {
    mnuSaveAsClick(Sender);
  }
}

//---------------------------------------------------------------------------
// Add font and tab info to .X68 source file
void __fastcall SaveFont(TTextStuff *active)
{
  fstream file;
  try {
    if (active->Project.IsSource) {
      AnsiString ext = UpperCase(ExtractFileExt(active->Project.CurrentFile));
      if (ext == ".X68") {              // if .X68 file
        file.open(active->Project.CurrentFile.c_str(), ios::app | ios::out);  //open source file for append
        file << "\n"
             << "*~Font name~" << active->SourceText->Font->Name.c_str() << "~\n"
             << "*~Font size~" << active->SourceText->Font->Size         << "~\n"
             << "*~Tab type~"  << active->Project.TabType                << "~\n"
             << "*~Tab size~"  << active->Project.TabSize                << "~\n";
        file.close();
      }
    }
  }
  catch( ... ) {
    MessageDlg("Error in SaveFont()",mtInformation, TMsgDlgButtons() << mbOK,0);
    return;
  }
}

//---------------------------------------------------------------------------
void __fastcall TMain::mnuExitClick(TObject *Sender)
{
  Main->Close();
}

//---------------------------------------------------------------------------
// Opens file in a new window.
// Proper FileInfo structure (Project) flags are set after the file is opened.
void __fastcall TMain::OpenFile(AnsiString name)
{

  // check to see if file exists
  if (FileExists(name) == false) {      // if file does not exist
    TMsgDlgButtons temp_set;
    temp_set << mbOK;
    MessageDlg("File Access Error.  Please verify the file name and that you have the proper permissions to open the file.", mtError,temp_set,0);
    return;
  }

  TTextStuff *TextStuff;

  // check to see if file is already open
  for(int i = MDIChildCount-1; i >= 0; i--) {
    TextStuff = (TTextStuff*)MDIChildren[i];
    if(TextStuff->Project.CurrentFile == name) { // if file already open
      if (TextStuff->Project.Modified) {         // if it is modified
        TMsgDlgButtons temp_set;
        temp_set << mbYes << mbNo;
        AnsiString asBuffer = ExtractFileName(name) + " is already open. Do you want to discard changes and reopen?";
        int iMsg = MessageDlg(asBuffer, mtConfirmation, temp_set, 0);
        if(iMsg == mrNo) {  //do not load file
          TextStuff->BringToFront();
          return;
        }
      }
      // close current open file so it will be replaced
      TextStuff->Project.Modified = false;
      TextStuff->SourceText->Modified = false;
      TextStuff->Close();   // close current
    }
  }

  //create the window
  TextStuff = new TTextStuff(Application);
  TextStuff->LoadFile(name);
}

//--------------------------------------------------------------------------
// Open Click
void __fastcall TMain::mnuOpenClick(TObject *Sender)
{
  OpenDialog->Title = "Open File";
  Main->SetFocus();
  if(OpenDialog->Execute()) {
    OpenFile(OpenDialog->FileName);
  }
}

//--------------------------------------------------------------------------
// handler for drag-n-drop from explorer
void __fastcall TMain::WmDropFiles(TWMDropFiles& Message)
{
  AnsiString fileName;
  char buff[MAX_PATH];                  // filename buffer
  HDROP hDrop = (HDROP)Message.Drop;
  int numFiles = DragQueryFile(hDrop, -1, NULL, NULL);  // number of files dropped
  for (int i=0;i < numFiles;i++) {      // loop for all files dropped
    DragQueryFile(hDrop, i, buff, sizeof(buff));        // get name of file i
    fileName = buff;
    if (FileExists(fileName)) {
      OpenFile(fileName);               // open specified file
    }
  }
  DragFinish(hDrop);                    // free memory Windows allocated
}

//--------------------------------------------------------------------------
// Assembles active source file window. Makes a check to see if the file
// loaded is a source file before loading it into assembler.
void __fastcall TMain::mnuDoAssemblerClick(TObject *Sender)
{
  AnsiString sourceFile, tempFile;

  //grab active child window
  TTextStuff *Active = (TTextStuff*)this->ActiveMDIChild;
  //if(Active->Project.IsSource) //only try to assemble a source file
  //{
    // if autosave and source has been modified
    if(Options->bSave && Active->SourceText->Modified)
    {
      Main->mnuSaveClick(Sender); //save source file
    }
    Active->Messages->Items->Clear();

    try //try to assemble the file
    {
      // set assembler option flags
      listFlag = Options->chkGenList->Checked;
      objFlag  = Options->chkGenSRec->Checked;
      CEXflag  = Options->chkConstantsEx->Checked;
      BITflag  = Options->chkBitfield->Checked;
      CREflag  = Options->chkCrossRef->Checked;
      MEXflag  = Options->chkMacEx->Checked;
      SEXflag  = Options->chkStrucEx->Checked;
      WARflag  = Options->chkShowWarnings->Checked;

      // use path of selected source file as temp working directory
      SetCurrentDir(ExtractFilePath(Active->Project.CurrentFile));
      sourceFile = ExtractFilePath(Active->Project.CurrentFile) + "EASy68Ks.tmp";
      tempFile = ExtractFilePath(Active->Project.CurrentFile) + "EASy68Km.tmp";
      Active->SourceText->Lines->SaveToFile(sourceFile);
      assembleFile(sourceFile.c_str(), tempFile.c_str(), Active->Project.CurrentFile);
      DeleteFile(sourceFile);              // delete temporary files
      DeleteFile(tempFile);
      AssemblerBox->ShowModal();
    }
    catch(...) //if there is an error then cancel assemble
    {
      TMsgDlgButtons temp_set;
      temp_set << mbOK;
      MessageDlg("File Access Error.  Please verify that you have write permission to the folder where the selected file is located.", mtError,temp_set,0);
    }
  //}
  //else
  //{
  //  TMsgDlgButtons temp_set;
  //  temp_set << mbOK;
  //  MessageDlg("Cannot assemble a non-source file", mtError ,temp_set, 0);
  //}
}
//---------------------------------------------------------------------------

void __fastcall TMain::mnuEditorOptionsClick(TObject *Sender)
{
  EditorOptionsForm->ShowModal();
}

//---------------------------------------------------------------------------

void __fastcall TMain::mnuPrinterSetupClick(TObject *Sender)
{
  PrinterSetupDialog->Execute();
}

//---------------------------------------------------------------------------
// Prints the text from the active window
void __fastcall TMain::mnuPrintSourceClick(TObject *Sender)
{
  int startLine, endLine, line;
  int copies, linesPerPage, lineOnPage, pageNumber;
  bool newPage = false;
  TTextStuff *RichPrint = NULL;

  try // Try to print the text
  {
    if(!PrintDialog->Execute())   // if printDialog OK button not pressed
      return;

    // Grab the active Child Form
    TTextStuff *Active = (TTextStuff*)this->ActiveMDIChild;

    // Create printer interface
    TPrinter *Prntr = Printer();
    Prntr->BeginDoc();          // start the print job
    Prntr->Canvas->Font = Active->SourceText->Font; // set printer font

    //Create temp TTextStuff and copy text to print
    RichPrint = new TTextStuff(Application);
    RichPrint->SourceText->Font = Active->SourceText->Font;

    if(PrintDialog->PrintRange)         // if print selected text
      RichPrint->SourceText->Text = Active->SourceText->SelText;
    else                                // else, print all text
      RichPrint->SourceText->Text = Active->SourceText->Text;

    RichPrint->Project = Active->Project;
    RichPrint->SetTabsAll();
    RichPrint->SourceText->SelectAll();
    RichPrint->replaceTabs();

    // if Print w/Black checked
    //if (EditorOptionsForm->PrintBlack->Checked) {
      // set color to black
    //  RichPrint->SourceText->SelectAll();
    //  RichPrint->SourceText->SelAttributes->Color = clBlack;
    //}

    // Calculate number of lines that can fit on a page
    linesPerPage = (Prntr->PageHeight / Prntr->Canvas->TextHeight("W"));

    copies = PrintDialog->Copies;

    // Set the title used by the print manager to identify this job
    Prntr->Title = "EASy68K " + Active->Project.CurrentFile;
    lineOnPage = 0;

    for(int i=0; i<copies; i++)
    {
      //pageNumber = 1;
      line = 0;
      do
      {
        if(newPage)
        {
          Prntr->NewPage();
          lineOnPage = 0;
        }
        newPage = true;
        endLine = line + linesPerPage;

        // Adjust the ending line count for the last page (which may not be full)
        if(endLine >= RichPrint->SourceText->Lines->Count)
          endLine = RichPrint->SourceText->Lines->Count;

        // For each line of text
        for (; line<endLine; line++)
        {
          // If new page marker
          if(RichPrint->SourceText->Lines->Strings[line] == NEW_PAGE_MARKER)
          {
            line++;   // skip new page marker
            break;    // exit For each line of text, newPage is already true
          }
          else
          {
            // Print one line
            Prntr->Canvas->TextOutA(
              20,
              Prntr->Canvas->TextHeight(RichPrint->SourceText->Lines->Strings[line]) * lineOnPage,
              RichPrint->SourceText->Lines->Strings[line].c_str()
              );
            lineOnPage++;
          }
        }
        //pageNumber++;
      } while(line < RichPrint->SourceText->Lines->Count);
    }
    Prntr->EndDoc();
  }
  catch(...) //if there is an error then cancel print
  {
    TMsgDlgButtons temp_set;
    temp_set << mbOK;
    Printer()->Abort();
    Printer()->EndDoc();
    MessageDlg("Printer error.  Please check printer.", mtError,temp_set,0);
  }
  if(RichPrint)
    delete RichPrint;
}

//---------------------------------------------------------------------------
void __fastcall TMain::tbOpenClick(TObject *Sender)
{
  mnuOpenClick(Sender); //call the menu function because it has the code already there
}

//---------------------------------------------------------------------------
void __fastcall TMain::tbSaveClick(TObject *Sender)
{
  mnuSaveClick(Sender); //call the menu function because it has the code already there
}

//---------------------------------------------------------------------------
// Create a new source file
void __fastcall TMain::mnuNewClick(TObject *Sender)
{
  //create the source window
  TTextStuff *TextStuff;
  TextStuff = new TTextStuff(Application);

  TextStuff->NewSourceFile();
}
//---------------------------------------------------------------------------

void __fastcall TMain::tbNewClick(TObject *Sender)
{
  mnuNewClick(Sender);
}
//---------------------------------------------------------------------------

void __fastcall TMain::tbAssembleClick(TObject *Sender)
{
  mnuDoAssemblerClick(Sender);
}
//---------------------------------------------------------------------------

void __fastcall TMain::mnuAboutClick(TObject *Sender)
{
  AboutBox->ShowModal();
}

//---------------------------------------------------------------------------
void __fastcall TMain::mnuHelpClick(TObject *Sender)
{
  displayHelp("INTRO");
}

//---------------------------------------------------------------------------
void __fastcall TMain::displayHelp(char* context)
{
  HWND H = ::GetDesktopWindow();  //this->Handle;  //::GetDesktopWindow();
  if (HHLibrary != 0)
    m_hWindow = __HtmlHelp(H, m_asHelpFile.c_str(), HH_HELP_CONTEXT, getHelpContext(context));
  else
    ShowMessage("HTML Help was not detected on this computer. The HTML help viewer may be downloaded from msdn.microsoft.com");

}

//---------------------------------------------------------------------------

void __fastcall TMain::mnuFindClick(TObject *Sender)
{
  //grab active mdi child
  TTextStuff *Active = (TTextStuff*)this->ActiveMDIChild;

  //if text selected in the source window use it for find text
  if(Active->SourceText->SelText != "")        // if text selected
    findDialogFrm->findText->Text = Active->SourceText->SelText;
  findDialogFrm->Show();
}

//---------------------------------------------------------------------------
// The find dialog is displayed
//void __fastcall TMain::FindDialogShow(TObject *Sender)
//{
  //grab active mdi child
//  TTextStuff *Active = (TTextStuff*)this->ActiveMDIChild;

  //if we have selected text in the source window use that for selection
//  if(Active->SourceText->SelText != "")
//    FindDialog->FindText = Active->SourceText->SelText;
//}


//---------------------------------------------------------------------------
// Searches the active source window for the given text, displays message
// if it is not found.
void __fastcall TMain::FindDialogFind(AnsiString findText, bool wholeWord, bool matchCase) {

  TMsgDlgButtons temp_set; //message dialog stuff
  temp_set << mbOK;

  TSearchTypes st;
  int FoundAt, StartPos, ToEnd; //tracks positions of text

  //grab active mdi child
  TTextStuff *Active = (TTextStuff*)this->ActiveMDIChild;

  //set appropriate search flags
  if (matchCase) //->Options.Contains(frMatchCase))
    st << stMatchCase;
  if (wholeWord) //Options.Contains(frWholeWord))
    st << stWholeWord;

  // begin the search after the current selection if there is one
  // otherwise, begin at the start of the text
  if (Active->SourceText->SelLength)
    StartPos = Active->SourceText->SelStart + Active->SourceText->SelLength;
  else
    StartPos = 0;

  // ToEnd is the length from StartPos
  // to the end of the text in the rich edit control
  ToEnd = Active->SourceText->Text.Length() - StartPos;

  FoundAt = Active->SourceText->FindText(findText,StartPos,ToEnd,st);

  if(FoundAt != -1)
  {
    Main->SetFocus(); //return focus
    Active->SourceText->SelStart = FoundAt;
    Active->SourceText->SelLength = findText.Length();
  }
  else
  {
    MessageDlg("End of document reached.", mtInformation, temp_set, 0);
    Active->SourceText->SelLength = 0;
  }
}

//---------------------------------------------------------------------------

void __fastcall TMain::tbFindClick(TObject *Sender)
{
  mnuFindClick(Sender);
}

//---------------------------------------------------------------------------

void __fastcall TMain::mnuFindAndReplace1Click(TObject *Sender)
{
  //grab active mdi child
  TTextStuff *Active = (TTextStuff*)this->ActiveMDIChild;
  replaceDialogFrm->findText->Text = Active->SourceText->SelText;
  replaceDialogFrm->replaceText->Text = Active->SourceText->SelText;
  replaceDialogFrm->Show();
}
//---------------------------------------------------------------------------

void __fastcall TMain::ReplaceDialogReplace()
{
  int startSave, lengthSave;

   //grab active mdi child
  TTextStuff *Active = (TTextStuff*)this->ActiveMDIChild;

  if(Active->SourceText->SelLength == 0)
  {
    FindDialogFind(replaceDialogFrm->findText->Text,
                   replaceDialogFrm->wholeWordChk->Checked,
                   replaceDialogFrm->matchCaseChk->Checked);
  }

  do {
    if(Active->SourceText->SelLength != 0)
    {
      startSave = Active->SourceText->SelStart;
      lengthSave = max(1, replaceDialogFrm->replaceText->Text.Length());
      Active->SourceText->SelText = replaceDialogFrm->replaceText->Text;
      Active->SourceText->SelStart = startSave;
      Active->SourceText->SelLength = lengthSave;
      FindDialogFind(replaceDialogFrm->findText->Text,
                     replaceDialogFrm->wholeWordChk->Checked,
                     replaceDialogFrm->matchCaseChk->Checked);
    }
  } while ( replaceDialogFrm->replaceAll  &&
            Active->SourceText->SelLength != 0 );
}

//---------------------------------------------------------------------------

//search for text item specified in find dialog
void __fastcall TMain::FindNext()
{
  FindDialogFind(findDialogFrm->findText->Text, findDialogFrm->wholeWordChk->Checked, findDialogFrm->matchCaseChk->Checked);
}

//---------------------------------------------------------------------------
void __fastcall TMain::Edit1Click(TObject *Sender)
//need to prevent user from "find next" if no windows are open or no find
//text has been input yet
{
  if(Main->MDIChildCount == 0 || findDialogFrm->findText->Text == "")
  {
    mnuFindNext->Enabled = false;
  }
  else
  {
    mnuFindNext->Enabled = true;
  }
}
//---------------------------------------------------------------------------

void __fastcall TMain::mnuFindNextClick(TObject *Sender)
{
  FindNext();
}
//---------------------------------------------------------------------------

// Intialize variables

void __fastcall TMain::FormShow(TObject *Sender)
{
  AnsiString fileName;

  Options->LoadSettings();  //load editor settings from file

  if (ParamCount() > 0)         // if parameters are present
  {
    fileName = ParamStr(1);     // get file name

    if (FileExists(fileName)) {
      OpenFile(fileName);       // open specified file
    }
    else
      mnuNewClick(Sender);      // open new edit window
  }
   else
     mnuNewClick(Sender);        // open new edit window

  Main->Caption = TITLE;
  if (maximizedEdit) {
    TTextStuff *Active = (TTextStuff*)Main->ActiveMDIChild;
    Active->WindowState = wsMaximized;
  }

}
//---------------------------------------------------------------------------


void __fastcall TMain::mnuAssemblerOptionsClick(TObject *Sender)
{
  Options->Show();
}
//---------------------------------------------------------------------------

/*
  WARNING: When you close an application that uses HtmlHelp and at the point of
  exit may have HTML Help Windows still open, you _must_ close these windows
  prior to exit. Failing to do this may result in access violations.

  The most generic way is to use the HH_CLOSE_ALL command. This will close
  all HTML Help windows opened by the application and is the most convenient
  way because it doesn't require a handle to the HTML Help Window:

  ::HtmlHelp(0, NULL, HH_CLOSE_ALL, 0);

  There are a few gotcha's when using the HH_CLOSE_ALL command with a dynamically
  loaded HTML Help API. More specifically the problem lies in unloading the HTML
  Help API. You want to be a good Windows citizen so you unload all dynamically
  loaded library before you terminate. So after the mandatory HH_CLOSE_ALL you
  call FreeLibrary and then...bang, an access violation. The problem is that
  normally HH_CLOSE_ALL results in the creation of a secondary thread that performs
  the actual action of closing all open HTML Help Windows while your application
  thread is allowed to continue running. If you immediately call FreeLibrary
  after HH_CLOSE_ALL, that secondary - which exists in hhctrl.ocx, may still be
  running. When it continues running the operating system finds that hhctrl.ocx
  is already unloaded and an access violation occurs. There are multiple ways
  to work around this problem but the recommended one is to use HH_INITIALIZE
  when you load HTML HELP and HH_UNINITIALIZE before you unload HTML Help, as
  is done in this example (doing this results in HH_CLOSE_ALL not spawning a
  secondary thread but using the calling thread, elimanating the problem).

*/

void __fastcall TMain::FormClose(TObject *Sender, TCloseAction &Action)
{
  try{
    Options->SaveSettings();  //save editor settings to file

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
    ShowMessage("Html Help may not have closed correctly");
  }
}
//---------------------------------------------------------------------------

void __fastcall TMain::FormKeyDown(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
   if (Key == VK_F1)
     displayHelp("MAIN");
}
//---------------------------------------------------------------------------
// Paste the clipboard to the current child. Format the pasted text.

void __fastcall TMain::EditPaste1Execute(TObject *Sender)
{
  if (Clipboard()->HasFormat(CF_TEXT) == false) // if clipboard empty
    return;

  TTextStuff *Active = (TTextStuff*)Main->ActiveMDIChild;

  if(Active->ActiveControl->Focused()) {
    int selStart = Active->SourceText->SelStart;

    // create a REPASTESPECIAL structure to use in the
    // EM_PASTESPECIAL message
    REPASTESPECIAL reps = { 0, 0 };

    // tell the Rich Edit control to insert unformatted text (CF_TEXT)
    ::SendMessage(Active->SourceText->Handle, EM_PASTESPECIAL, CF_TEXT, (LPARAM) &reps);

    int selLength = Active->SourceText->SelStart - selStart;
    Active->SourceText->SelStart = selStart;
    Active->SourceText->SelLength = selLength;

    ::UpdateWindow(Active->SourceText->Handle);   // force Richtext box to update

    Active->SetTabs();            // set tabs

    Active->SourceText->SelStart = selStart + selLength;
  } else if(findDialogFrm->findText->Focused()) { // if find dialog selected
    findDialogFrm->findText->Text = Clipboard()->AsText;
  } else if(replaceDialogFrm->findText->Focused()) {  // if replace findText selected
    replaceDialogFrm->findText->Text = Clipboard()->AsText;
  } else if(replaceDialogFrm->replaceText->Focused()) {  // if replace replaceText selected
    replaceDialogFrm->replaceText->Text = Clipboard()->AsText;
  }  
}
//---------------------------------------------------------------------------

void __fastcall TMain::EditCommentAdd1Execute(TObject *Sender)
{
  TTextStuff *Active = (TTextStuff*)Main->ActiveMDIChild;
  Active->commentSelection();
}
//---------------------------------------------------------------------------

void __fastcall TMain::EditUncomment1Execute(TObject *Sender)
{
  TTextStuff *Active = (TTextStuff*)Main->ActiveMDIChild;
  Active->unCommentSelection();
}
//---------------------------------------------------------------------------


void __fastcall TMain::EditUndoExecute(TObject *Sender)
{
  //grab active mdi child
  TTextStuff *Active = (TTextStuff*)this->ActiveMDIChild;

  Active->Undo();
}
//---------------------------------------------------------------------------

void __fastcall TMain::EditRedoExecute(TObject *Sender)
{
  //grab active mdi child
  TTextStuff *Active = (TTextStuff*)this->ActiveMDIChild;

  Active->Redo();

}
//---------------------------------------------------------------------------

void __fastcall TMain::Reload1Click(TObject *Sender)
{
  TTextStuff *Active = (TTextStuff*)Main->ActiveMDIChild;
  Active->EditorReload1Click(Sender);
}
//---------------------------------------------------------------------------

