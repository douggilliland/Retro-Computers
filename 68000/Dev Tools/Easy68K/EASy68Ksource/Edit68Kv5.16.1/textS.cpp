//---------------------------------------------------------------------------
//   Author: Charles Kelly,
//           Monroe County Community College
//           http://www.monroeccc.edu/ckelly
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop
#include "textS.h"
#include <time.h>
#include <winuser.h>

//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "RichEditPlus"
#pragma resource "*.dfm"
TTextStuff *TextStuff;

AnsiString leadStr, str, rstr;
extern tabTypes tabType;
extern bool autoIndent;
extern bool realTabs;
extern const int MAXT;          // maximum number of tokens
extern const int MAX_SIZE;      // maximun size of input line

const int TABCOUNT = 20;        // max number of tabs
const int KEY_LT = 188;         // < key
const int KEY_GT= 190;          // > key

int col;                        // current column number of cursor
bool mouseDrag = false, mouseDragging = false;
bool highlightDisabled = false;

// hightlightAbort does nothing in this version. The idea was to abort the
// current highlight operation if a key is pressed or screen scrolled. To
// get it to work would require enabling selective events in the richEditPlus
// control so the key press or scroll event would occur during a highlight.
// It may not be necessary if the performance under Vista feels OK as is.
//bool highlightAbort = false;    // used to halt current highlight operation

extern FontStyle codeStyle;
extern FontStyle unknownStyle;
extern FontStyle directiveStyle;
extern FontStyle commentStyle;
extern FontStyle labelStyle;
extern FontStyle structureStyle;
extern FontStyle errorStyle;
extern FontStyle textStyle;
extern TColor backColor;

char capLine[256];
char *tokenS[256];             // pointers to tokens
char tokensS[512];             // place tokens here
extern char *tokenEnd[256];

//---------------------------------------------------------------------------
// global start end for color highlight
int colorStart = 0, colorEnd = 0;

char *p, *syntaxStart;
int lineStart;

// timer stuff for profiling
const int MAX_PROFILES = 10;
LARGE_INTEGER timeStart[MAX_PROFILES];
LARGE_INTEGER timeEnd;
LARGE_INTEGER timerFreq;
LARGE_INTEGER scoreTime;
float profileTimes[MAX_PROFILES];

//---------------------------------------------------------------------------
__fastcall TTextStuff::TTextStuff(TComponent* Owner)
        : TForm(Owner)
{
  InsertMode = true;
  SourceText->DefAttributes->Protected = true;
  QueryPerformanceFrequency(&timerFreq); 	// set up high resolution timer
  SourceText->Color = backColor;
}

//---------------------------------------------------------------------------
void __fastcall TTextStuff::ProfileStart(unsigned int n)
{
  if (n >= MAX_PROFILES)
    return;
  QueryPerformanceCounter(&timeStart[n]);	// get starting time
}

//---------------------------------------------------------------------------
void __fastcall TTextStuff::ProfileEnd(unsigned int n)
{
  if (n >= MAX_PROFILES)
    return;
  QueryPerformanceCounter(&timeEnd);
  profileTimes[n] += ( (float)timeEnd.QuadPart - (float)timeStart[n].QuadPart ) / timerFreq.QuadPart;
}

//---------------------------------------------------------------------------
void __fastcall TTextStuff::ProfileClear()
{
  for (int i=0; i<MAX_PROFILES; i++)
    profileTimes[i] = 0.0f;
}

//---------------------------------------------------------------------------

void __fastcall TTextStuff::LoadFile(AnsiString name)
{
  AnsiString ext = UpperCase(ExtractFileExt(name));
  AnsiString str;
  char temp[80];
  int cnt,i,j;
  char ch;

  try {

    //disable all RichEdit events
    int eventMask = ::SendMessage(SourceText->Handle,EM_SETEVENTMASK,0,0);
    ::SendMessage(SourceText->Handle,WM_SETREDRAW,false,0);

    if(ext != ".L68" && ext != ".S68") //setup a source window
    {
      //update Text window
      NewProject("Source"); //loading a new form that is for source
      SourceText->SetFocus();
      Project.CurrentFile = name; //get filename
      Project.HasName = true;
      SourceText->Lines->LoadFromFile(Project.CurrentFile);

      // set default tab and font
      if (EditorOptionsForm->AssemblyTabs->Checked == true)
        Project.TabType = Assembly;
      else
        Project.TabType = Fixed;
      Project.TabSize = EditorOptionsForm->FixedTabSize->Value;
      SourceText->Font->Name = EditorOptionsForm->cbFont->Text;
      SourceText->Font->Size = EditorOptionsForm->cbSize->Text.ToInt();

      // check for font & tab info embedded at bottom of file and use if present
      int count = SourceText->Lines->Count;

      for (cnt=count; cnt>count-5; cnt--) {
        str = SourceText->Lines->Strings[cnt];
        if (str.SubString(1,11) == "*~Tab size~") {
          j = 0;
          for(i=12; str[i] != '~' && i<14; i++)
            temp[j++] = str[i];
          temp[j] = '\0';
          Project.TabSize = atoi(temp);
          SourceText->Lines->Delete(cnt);
        } else if(str.SubString(1,11) == "*~Tab type~") {
          if(str.SubString(12,1) == '0') {
            Project.TabType = Assembly;
          } else {
            Project.TabType = Fixed;
          }
          SourceText->Lines->Delete(cnt);
        } else if(str.SubString(1,12) == "*~Font size~") {
          j = 0;
          for(i=13; str[i] != '~' && i<15; i++)
            temp[j++] = str[i];
          temp[j] = '\0';
          SourceText->Font->Size = atoi(temp);
          SourceText->Lines->Delete(cnt);
        } else if(str.SubString(1,12) == "*~Font name~") {
          j = 0;
          for(i=13; str[i] != '~' && i<str.Length(); i++)
            temp[j++] = str[i];
          temp[j] = '\0';
          SourceText->Font->Name = temp;
          SourceText->Lines->Delete(cnt);
        }
      }

      SetTabsAll();         // set tabs
      Caption = ExtractFileName(Project.CurrentFile);
    }
    else  //a list or S-record file
    {
      NewProject("List");

      //now load up the file
      Project.CurrentFile = name; //store list file
      Project.HasName = true;
      SourceText->Lines->LoadFromFile(name);
      Caption = ExtractFileName(name);
    }

    SourceText->SelectAll();                    // Select all text
    SourceText->SelAttributes->Protected = true;      // protect all text
    SourceText->SelStart = 0;      // deselects text
    Project.Modified = false;
    SourceText->Modified = false;

    colorHighlight(0,SourceText->Lines->Count);

    // enable RichEdit events and force update
    ::SendMessage(SourceText->Handle,WM_SETREDRAW,true,0);
    ::InvalidateRect(SourceText->Handle,0,true);
    ::SendMessage(SourceText->Handle,EM_SETEVENTMASK,0,eventMask | ENM_SCROLL);
  } catch( ... ) {
    MessageDlg("Error in LoadFile()",mtInformation, TMsgDlgButtons() << mbOK,0);
    return;
  }

}

//---------------------------------------------------------------------------
void __fastcall TTextStuff::UpdateStatusBar()
{
  AnsiString str;
  int tabSize = EditorOptionsForm->FixedTabSize->Value;

  try {
  // determine column number of cursor
  // account for different tab sizes CK v2.3
  CurPos = SourceText->CaretPos; //store position of cursor
  str = SourceText->Lines->Strings[CurPos.y];   // get current line
  col=0;
  int t=1;
  for (int i=1; i <= CurPos.x && i<=str.Length(); i++) {
    if (str[i] == '\t') {         // if tab
      if (Project.TabType == Assembly) {
        switch(t) {
          case 1: tabSize = TAB1; break;
          case 2: tabSize = TAB2; break;
          case 3: tabSize = TAB3; break;
          default: tabSize = EditorOptionsForm->FixedTabSize->Value;
        }
      }
      col += tabSize - col%tabSize;
      t++;
      if (t > TABCOUNT)
        t = TABCOUNT;
    } else
      col++;
  }
  StatusBar->Panels->Items[0]->Text = IntToStr(CurPos.y + 1)  +
                                          ": " + IntToStr(col + 1);

  if(SourceText->Modified) //if source is modified
  {
    StatusBar->Panels->Items[1]->Text = "Modified";
    Project.Modified = SourceText->Modified;
  }
  else  //source is not modifed
  {
    StatusBar->Panels->Items[1]->Text = "";
    Project.Modified =  SourceText->Modified;
  }

  if (InsertMode)
    StatusBar->Panels->Items[2]->Text = "Insert";
  else
    StatusBar->Panels->Items[2]->Text = "Replace";
  } catch( ... ) {
  }

}

//---------------------------------------------------------------------------
void __fastcall TTextStuff::SourceTextKeyDown(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  try {

  //highlightAbort = true;        // stop current highlight operation

  // reset timer to prevent column position from changing as the user
  // is changing rows after an edit
  if (HighlightTimer->Enabled) {      // if highlight pending
    HighlightTimer->Enabled = false;  // reset timer
    HighlightTimer->Enabled = true;
  }
  
  // create a TshiftState set that corresponds to only the shift key
  TShiftState ss;
  ss = ss << ssShift;

  TShiftState ctrl;
  ctrl = ctrl << ssCtrl;

  TShiftState ctrlShift;
  ctrlShift = ctrlShift << ssCtrl << ssShift;

  if (Key == VK_BACK && Shift == ctrl)
    Key = 0;                    // prevent ctrl-Backspace
  else if(Key == VK_DELETE && Shift == ctrl)
    Key = 0;                    // prevent ctrl-Delete
  else if (Key == 'E' && Shift == ctrl) {
    Key = 0;                    // prevent ctrl-E

   // if F1 (Help)
  } else if (Key == VK_F1) {
    if (SourceText->SelText != "")    // if text selected, use it
      Main->displayHelp(SourceText->SelText.Trim().c_str());
    else {                      // no text selected
      if (isspace(SourceText->Text[SourceText->SelStart]))  // if cursor on space
        Main->displayHelp("INTRO");  // do help intro
      else {                    // cursor on word
        int selectStart = SourceText->SelStart;
        // find start of word (alpha numeric characters only)
        while (selectStart > 1 && (isalnum(SourceText->Text[selectStart-1])))
          selectStart--;
        int selectEnd = SourceText->SelStart+1;
        // find end of word   (alpha numeric characters only)
        while (selectEnd < SourceText->Text.Length() && (isalnum(SourceText->Text[selectEnd])))
          selectEnd++;
        // do help on the current word
        Main->displayHelp(SourceText->Text.SubString(selectStart,selectEnd-selectStart).c_str());
      }
    }

  // if F3 AND Searching
  } else if(Key == VK_F3 && findDialogFrm->findText->Text != "")  {
    Main->FindNext();

  // if Shift-Insert (old DOS way to Paste)?
  } else if (Key == VK_INSERT && Shift == ss) {
    // null out the key code to prevent further processing
    Key = 0;
    Main->EditPaste1Execute(Sender);

  // if Insert key
  } else if(Key == VK_INSERT) {
    InsertMode = !InsertMode;

  // if Tab key & spaces for Tab
  } else if(Key == VK_TAB && !realTabs) {
    Key = 0;    // null out the key code to prevent further processing
    TPoint CurPos2 = SourceText->CaretPos; //store position of cursor
    str = SourceText->Lines->Strings[CurPos2.y];
    // replace tab with spaces
    int j=col, k, t;
    if (Project.TabType == Assembly) {
      if (j <= TAB1)
        t = TAB1 - j;
      else if (j <= TAB2)
        t = TAB2 - j;
      else
        t = TAB3 - j;
    } else {                      // else fixed tabs
      t = Project.TabSize - (j % Project.TabSize);
    }
    for (k=0; k<t; k++) {       // replace with spaces
      str.Insert(" ",CurPos2.x+1);
      CurPos2.x++;
    }
    SourceText->Lines->Strings[CurPos2.y] = str;
    SourceText->CaretPos = CurPos2;

  // if ctrl-Shift >
  } else if(Key == KEY_GT && Shift == ctrlShift) {
    indentSelection();
    Key = 0;                    // prevent further processing

  // if ctrl-Shift <
  } else if(Key == KEY_LT && Shift == ctrlShift) {
    outdentSelection();
    Key = 0;                    // prevent further processing

  // if Enter key
  } else if(Key == VK_RETURN) {

    // autoindent
    if (autoIndent)
    {
      CurPos = SourceText->CaretPos; //store position of cursor
      int len = 0;
      str = SourceText->Lines->Strings[CurPos.y];
      char* chptr = str.c_str();
      while (iswspace(*chptr++))
        len++;                     // count leading whitespace on current line
      leadStr = str.SubString(0,len);  // copy whitespace
    }
  } else if (Shift == ctrlShift)
    Key = 0;                    // prevent RichEdit stuff

  if (!mouseDragging)
    mouseDrag = false;

  UpdateStatusBar();
  } catch( ... ) {
  }

}

//---------------------------------------------------------------------------

void __fastcall TTextStuff::SourceTextKeyUp(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  try {
  // autoindent
  if (Key == VK_RETURN && autoIndent) {
    str = SourceText->Lines->Strings[CurPos.y];
    if (str.Length() == 0)             // if new line is empty
      SourceText->Lines->Strings[CurPos.y] = leadStr; // start with leading whitespace from above
  }
  UpdateStatusBar();
  } catch( ... ) {
  }
}

//---------------------------------------------------------------------------

void __fastcall TTextStuff::SourceTextKeyPress(TObject *Sender, char &Key)
{
  try {
  if(Key == VK_TAB && !realTabs)
    Key = 0;    // null out the key code to prevent further processing
  mouseDrag = false;
  UpdateStatusBar();
  } catch( ... ) {
  }
}

//---------------------------------------------------------------------------
// sets tabs of all text in SourceText
void __fastcall TTextStuff::SetTabsAll()
{
  try {
    SourceText->SelectAll();    // Select all text
    int cursorPosition = SourceText->SelStart;
    SetTabs();

    // restore cursor position and deselects text
    SourceText->SelStart = cursorPosition;

  } catch( ... ) {
    MessageDlg("Error in setting all tabs",mtInformation, TMsgDlgButtons() << mbOK,0);
  }
}

//---------------------------------------------------------------------------
// sets tabs of selected text in SourceText
void __fastcall TTextStuff::SetTabs()
{
  try {
    //disable all RichEdit events
    int eventMask = ::SendMessage(SourceText->Handle,EM_SETEVENTMASK,0,0);
    ::SendMessage(SourceText->Handle,WM_SETREDRAW,false,0);

    int fixedTabSize = Project.TabSize;
    if (fixedTabSize <= 0)
      fixedTabSize = 8;           // default
    int tabsize = 60;             // default tab size

    if (SourceText->Font->Name == "Courier New") {
      switch (SourceText->Font->Size) {
        case 8: case 9: tabsize = 5.25 * fixedTabSize; break;
        case 10: tabsize = 6 * fixedTabSize; break;
        case 11: tabsize = 6.75 * fixedTabSize; break;
        case 12: tabsize = 7.5 * fixedTabSize; break;
        case 14: tabsize = 8.25 * fixedTabSize; break;
        case 16: tabsize = 9.75 * fixedTabSize; break;
        case 18: tabsize = 10.5 * fixedTabSize;
      }
    } else if (SourceText->Font->Name == "Courier") {
      switch (SourceText->Font->Size) {
        case 10: tabsize = 6 * fixedTabSize; break;
        case 12: tabsize = 6.75 * fixedTabSize; break;
        case 15: tabsize = 9 * fixedTabSize;
      }
    } else {                        // else, "Fixed System"
      switch (SourceText->Font->Size) {
        case 9: tabsize = 6 * fixedTabSize; break;
        case 18: tabsize = 12 * fixedTabSize;
      }
    }

    SourceText->Paragraph->TabCount = TABCOUNT;         // set 20 tabs
    SourceText->Paragraph->Tab[0] = tabsize;
    for (int i=1; i<20; i++)
      SourceText->Paragraph->Tab[i] = SourceText->Paragraph->Tab[i-1] + tabsize;

    if ( Project.TabType == Assembly) {                   // if smart tabs
      SourceText->Paragraph->Tab[0] = tabsize/fixedTabSize * TAB1;   // change 1st 3 tabs
      SourceText->Paragraph->Tab[1] = tabsize/fixedTabSize * TAB2;
      SourceText->Paragraph->Tab[2] = tabsize/fixedTabSize * TAB3;
    }

    // enable RichEdit events and force update
    ::SendMessage(SourceText->Handle,WM_SETREDRAW,true,0);
    ::InvalidateRect(SourceText->Handle,0,true);
    ::SendMessage(SourceText->Handle,EM_SETEVENTMASK,0,eventMask);

  } catch( ... ) {
    MessageDlg("Error setting tabs",mtInformation, TMsgDlgButtons() << mbOK,0);
  }

}


//---------------------------------------------------------------------------
// replace tabs in selected rows with spaces
// replaces all tabs in partially selected rows
void __fastcall TTextStuff::replaceTabs()
{
  CurPos = SourceText->CaretPos;        //store position of cursor
  str = SourceText->SelText;           // get selected text
  if (str == "")
    return;

  int i, j, x, t;
  for (i=SourceText->SelStart; i>0 && SourceText->Text[i]!='\n'; i--);  // find preceding \n

  x = SourceText->SelStart - i;         // x starting position
  for (i=1; i <= str.Length(); i++) {  // for all selected text, AnsiString starts at 1
    if (str[i] == '\t')                // if tab
    {
      if (Project.TabType == Assembly) {
        if (x <= TAB1)
          t = TAB1 - x;                 // t is spaces needed to replace tab
        else if (x <= TAB2)
          t = TAB2 - x;
        else
          t = TAB3 - x;
      } else {                          // else fixed tabs
        t = Project.TabSize - (x % Project.TabSize);
      }
      x += t;
      for (j=0; j<t; j++)               // replace with spaces
        str.Insert(" ",i++);
      str.Delete(i--,1);               // delete tab
    }
    else if (str[i] == '\n')           // if newline
      x = 0;                            // start x at beginning of new line
    else
      x++;                              // increment x position
  }
  SourceText->SelText = str;
  SourceText->CaretPos = CurPos;
}


//---------------------------------------------------------------------------
// Comment the selected lines by adding a '*' to the start of each line
void __fastcall TTextStuff::commentSelection()
{
  insertInSelection("*");
}

//---------------------------------------------------------------------------
// Uncomment the selected lines by removing the '*' at the start of each line
void __fastcall TTextStuff::unCommentSelection()
{
  deleteFromSelection("*");
}

//---------------------------------------------------------------------------
// Indent the selected lines by adding a space to the start of each line
void __fastcall TTextStuff::indentSelection()
{
  insertInSelection(" ");
}

//---------------------------------------------------------------------------
// Outdent the selected lines by deleting a space to the start of each line
void __fastcall TTextStuff::outdentSelection()
{
  deleteFromSelection(" ");
}


//---------------------------------------------------------------------------
// Delete dstr from the beginning of the selected lines
void __fastcall TTextStuff::deleteFromSelection(AnsiString dstr)
{
  int startSave, lengthSave, row, startLine, endLine;
  UndoRedo item;

  try {
    //disable all RichEdit events
    int eventMask = ::SendMessage(SourceText->Handle,EM_SETEVENTMASK,0,0);
    ::SendMessage(SourceText->Handle,WM_SETREDRAW,false,0);

    startSave = SourceText->SelStart;
    lengthSave = SourceText->SelLength;

    // save undo info
    item.start = SourceText->SelStart;
    item.str = SourceText->SelText;

    startLine = SourceText->Perform(EM_LINEFROMCHAR, startSave, 0);
    endLine = SourceText->Perform(EM_LINEFROMCHAR, startSave + lengthSave - 1, 0);
    SourceText->SelLength = 0;
    for (row=startLine; row<=endLine; row++) {
      str = SourceText->Lines->Strings[row];
      if (str.SubString(1,1) == dstr) {
        str.Delete(dstr.Length(),1);
        SourceText->Lines->Strings[row] = str;
        lengthSave -= dstr.Length();
        if (lengthSave < 0)
          lengthSave = 0;
      }
    }

    SourceText->SelStart = startSave;
    SourceText->SelLength = lengthSave;

    // save undo
    item.length = SourceText->SelLength;
    SaveUndo(item, true);

    // enable RichEdit events and force update
    ::SendMessage(SourceText->Handle,WM_SETREDRAW,true,0);
    ::InvalidateRect(SourceText->Handle,0,true);
    ::SendMessage(SourceText->Handle,EM_SETEVENTMASK,0,eventMask);

  } catch (...) {
  }
}

//---------------------------------------------------------------------------
// Inserts the string ins in the front of each selected line
void __fastcall TTextStuff::insertInSelection(AnsiString istr)
{
  int startSave, lengthSave, row, startLine, endLine;
  UndoRedo item;

  try {
    //disable all RichEdit events
    int eventMask = ::SendMessage(SourceText->Handle,EM_SETEVENTMASK,0,0);
    ::SendMessage(SourceText->Handle,WM_SETREDRAW,false,0);

    startSave = SourceText->SelStart;
    lengthSave = SourceText->SelLength;

    // save undo info
    item.start = SourceText->SelStart;
    item.str = SourceText->SelText;

    startLine = SourceText->Perform(EM_LINEFROMCHAR, startSave, 0);
    endLine = SourceText->Perform(EM_LINEFROMCHAR, startSave + lengthSave - 1, 0);
    SourceText->SelLength = 0;
    for (row=startLine; row<=endLine; row++) {
      str = SourceText->Lines->Strings[row];
      str.Insert(istr,1);
      SourceText->Lines->Strings[row] = str;
      lengthSave += istr.Length();
    }
    SourceText->SelStart = startSave;
    SourceText->SelLength = lengthSave;

    // save undo
    item.length = SourceText->SelLength;
    SaveUndo(item, true);

    // enable RichEdit events and force update
    ::SendMessage(SourceText->Handle,WM_SETREDRAW,true,0);
    ::InvalidateRect(SourceText->Handle,0,true);
    ::SendMessage(SourceText->Handle,EM_SETEVENTMASK,0,eventMask);

  } catch (...) {
  }
}

//---------------------------------------------------------------------------
void __fastcall TTextStuff::FormClose(TObject *Sender,
      TCloseAction &Action)
{
  //update how many windows are open and what type
  if(Project.IsSource)
  {
    Main->iSourceOpen--;
  }
  else
  {
    Main->iListsOpen--;
  }

  if(Main->MDIChildCount == 1)  //only disable menus if last window is closed
  {
    //Project.SourceOpen = false;
    Project.Modified = false;

    //stop user from using menus that need an open source file
    Main->mnuDoAssembler->Enabled     = false;
    Main->tbAssemble->Enabled         = false;
    Main->mnuPrintSource->Enabled     = false;
    Main->tbPrint->Enabled            = false;
    Main->mnuSave->Enabled            = false;
    Main->mnuSaveAs->Enabled          = false;
    Main->tbSave->Enabled             = false;
    Main->mnuFind->Enabled            = false;
    Main->mnuFindAndReplace1->Enabled = false;
    Main->tbFind->Enabled             = false;
    Main->mnuEditorOptions->Enabled   = false;


  }
  //if source files are closed and lists are open keep some options enabled
  else if( Main->iSourceOpen <= 0 && Main->iListsOpen > 0)
  {
    Main->mnuDoAssembler->Enabled   = false;
    Main->tbAssemble->Enabled       = false;
    Main->mnuSave->Enabled          = false;
    Main->mnuSaveAs->Enabled        = false;
    Main->tbSave->Enabled           = false;
  }

  clearUndoRedo();
  Action = caFree;  //frees this instance of TextStuff
}

//---------------------------------------------------------------------------
void __fastcall TTextStuff::ClearErrorMessages(TObject *Sender)
{
  Messages->Height = 7;
  Messages->Items->Clear();
  Messages->Enabled = false;
}

//---------------------------------------------------------------------------
//Highlights the line with selected error. The selection functions require
//char positions, not a line number so this is found first then selected based
//on those values.
void __fastcall TTextStuff::MessagesDblClick(TObject *Sender)
{
  try {
    int iLineNum = StrToInt(Messages->ItemFocused->Caption);
    int Start = GetFirstPos(iLineNum-1);  //get 1st char pos of needed line
    int End = GetLastPos(iLineNum-1);     //get last char pos of needed line

    //highlight the line with error
    SourceText->Perform(EM_HIDESELECTION,0, 0);
    CHARRANGE LineSelection;
    LineSelection.cpMin = Start;
    LineSelection.cpMax = End - 1;
    SourceText->Perform(EM_EXSETSEL, 0, (LPARAM)&LineSelection);
    SourceText->SetFocus();

    CurPos = SourceText->CaretPos; //store position of cursor
    UpdateStatusBar();
  } catch( ... ) {
  }
}

//---------------------------------------------------------------------------
int __fastcall TTextStuff::GetFirstPos(int line)
{ //returns start of line in Char positions
  try {
    return( SourceText->Perform(EM_LINEINDEX, line, 0));
  } catch( ... ) {
  }
  return 0;
}

//---------------------------------------------------------------------------
int __fastcall TTextStuff::GetLastPos(int line)
{  //returns end of line in Char positions
  try {
    if(line >= SourceText->Lines->Count - 1)      // if last line
      return (SourceText->Text.Length());

    // start of next line - 1
    return(SourceText->Perform(EM_LINEINDEX, line+1, 0) - 1);
  } catch( ... ) {
  }
  return 0;
}
//---------------------------------------------------------------------------

void __fastcall TTextStuff::SourceTextMouseUp(TObject *Sender,
      TMouseButton Button, TShiftState Shift, int X, int Y)
{
  try {
    CurPos = SourceText->CaretPos; //store position of cursor
    mouseDrag = false;
    mouseDragging = false;
    UpdateStatusBar();
  } catch( ... ) {
  }

}
//---------------------------------------------------------------------------

void __fastcall TTextStuff::SourceTextMouseDown(TObject *Sender,
      TMouseButton Button, TShiftState Shift, int X, int Y)
{
  try {
    CurPos = SourceText->CaretPos; //store position of cursor
    UpdateStatusBar();
  } catch( ... ) {
  }

}
//---------------------------------------------------------------------------

void __fastcall TTextStuff::FormShow(TObject *Sender)
{ /*Initialize variables */
  try {
    Main->mnuFind->Enabled = true;
    Main->tbFind->Enabled  = true;

    SourceText->SetFocus();  //give SourceText focus
    CurPos = SourceText->CaretPos; //store position of cursor
    UpdateStatusBar();
  } catch( ... ) {
  }

}
//---------------------------------------------------------------------------

void __fastcall TTextStuff::tbNewClick(TObject *Sender)
{
  Main->mnuNewClick(Sender);
}
//---------------------------------------------------------------------------

void __fastcall TTextStuff::tbPrintClick(TObject *Sender)
{
  Main->mnuPrintSourceClick(Sender);
}
//---------------------------------------------------------------------------
/*Starts up a new file with settings depending on the type sent
   CURRENT VALID PARAMETERS:
     "Source"  -  Create a source file window
     "List"    -  Create a list file window
*/
void __fastcall TTextStuff::NewProject(AnsiString Type)
{
  try {
    //set font of editor window to that which is saved in settings
    SourceText->Font->Name = EditorOptionsForm->cbFont->Text;
    SourceText->Font->Size = StrToInt(EditorOptionsForm->cbSize->Text);

    SourceText->Modified = false;
    clearUndoRedo();

    if(Type == "Source") //set settings source file type
    {
      //reset variables
      Main->iNewFiles++; // increment count for new "untitled" documents
      Project.CurrentFile = "untitled"  + IntToStr(Main->iNewFiles) + ".x68";
      Project.CreateList  = true;
      Project.IsSource    = true;
      //Project.SourceOpen  = true;
      Project.HasName     = false;
      //SourceText->SelectAll();    // Select all text
      SetTabsAll();                  //set tabs, sets modified true
      SourceText->Modified = false;
      Project.Modified =  false;

      Main->iSourceOpen++;

      //set all the menu items that are now useable
      Main->mnuDoAssembler->Enabled     = true;
      Main->tbAssemble->Enabled         = true;
      Main->mnuPrintSource->Enabled     = true;
      Main->tbPrint->Enabled            = true;
      Main->mnuSave->Enabled            = true;
      Main->mnuSaveAs->Enabled          = true;
      Main->tbSave->Enabled             = true;
      Main->mnuEditorOptions->Enabled   = true;
      Main->mnuFindAndReplace1->Enabled = true;

    }
    else if(Type == "List") //set up form for list file
    {
      Project.IsSource                   = false;
      //Project.SourceOpen                 = true;
      Main->mnuPrintSource->Enabled      = true;
      //SourceText->ReadOnly               = true;
      Main->mnuPrintSource->Enabled      = true;
      Main->tbPrint->Enabled             = true;
      Main->mnuEditorOptions->Enabled    = true;
      Main->mnuFindAndReplace1->Enabled  = true;
      Main->iListsOpen++;
    }
  } catch( ... ) {
    MessageDlg("Error in NewProject()." ,mtWarning, TMsgDlgButtons() << mbOK,0);
  }

}

//---------------------------------------------------------------------------

void __fastcall TTextStuff::NewSourceFile()
{
  try {
    //disable all RichEdit events
    int eventMask = ::SendMessage(SourceText->Handle,EM_SETEVENTMASK,0,0);
    ::SendMessage(SourceText->Handle,WM_SETREDRAW,false,0);

    NewProject("Source"); //loading a new form that is for source
    if (EditorOptionsForm->AssemblyTabs->Checked == true)
      Project.TabType = Assembly;
    else
      Project.TabType = Fixed;
    Project.TabSize = EditorOptionsForm->FixedTabSize->Value;
    SourceText->Font->Name = EditorOptionsForm->cbFont->Text;
    SourceText->Font->Size = EditorOptionsForm->cbSize->Text.ToInt();

    Caption = ExtractFileName(Project.CurrentFile);

    //if template exists then load it
    if (FileExists(ExtractFilePath(Application->ExeName) + "template.NEW"))
      SourceText->Lines->LoadFromFile
                        (ExtractFilePath(Application->ExeName) + "template.NEW");

    SourceText->SelectAll();                    // Select all text
    SetTabs();
    SourceText->SelAttributes->Protected = true;      // protect all text
    SourceText->SelStart = 0;      // deselects text
    Project.Modified = false;
    SourceText->Modified = false;

    colorHighlight(0,SourceText->Lines->Count);

    // enable RichEdit events and force update
    ::SendMessage(SourceText->Handle,WM_SETREDRAW,true,0);
    ::InvalidateRect(SourceText->Handle,0,true);
    ::SendMessage(SourceText->Handle,EM_SETEVENTMASK,0,eventMask);
  } catch( ... ) {
    MessageDlg("Error in NewSourceFile()." ,mtWarning, TMsgDlgButtons() << mbOK,0);
  }
}

//---------------------------------------------------------------------------

void __fastcall TTextStuff::FormCloseQuery(TObject *Sender, bool &CanClose)
{ /*Prevents user from closing a form with changes they want to save.*/

  try {
    UpdateStatusBar();
    if(Project.Modified)
    {
      TMsgDlgButtons temp_set;
      temp_set << mbYes << mbNo << mbCancel;
      int iMsg;

      AnsiString asBuffer = "File modified, do you wish to save '" +
                            ExtractFileName(Project.CurrentFile) + "' before closing?";
      iMsg = MessageDlg(asBuffer, mtConfirmation, temp_set, 0);
      if(iMsg == mrYes)  //save file
      {
        Main->mnuSaveClick(Sender);
        CanClose = true;
      }
      else if(iMsg == mrNo)
      {
        CanClose = true;
        //need a handler to close window when app is shut down
      }
      else if(iMsg == mrCancel) //cancel close
      {
        CanClose = false;
      }
    }
  } catch( ... ) {
    MessageDlg("Error in FormCloseQuery()." ,mtWarning, TMsgDlgButtons() << mbOK,0);
  }
}
//---------------------------------------------------------------------------

void __fastcall TTextStuff::EditorOptions1Click(TObject *Sender)
{
  Main->mnuEditorOptionsClick(Sender);
}

//---------------------------------------------------------------------------
// Attempt to correct a text selection bug in the RichEdit1 control
void __fastcall TTextStuff::SourceTextSelectionChange(TObject *Sender)
{
  static int oldSelStart = SourceText->SelStart;
  static int oldSelLength = SourceText->SelLength;

  try {
    // if change to bottom of selection range
    if (SourceText->SelStart == oldSelStart) {
      // if adding to selection at bottom (down)
      if (SourceText->SelLength > oldSelLength + 3) {
        // if end of selection is \r\n\r\n
        if (SourceText->Text.SubString(SourceText->SelStart+SourceText->SelLength-3,4) == "\r\n\r\n")
          SourceText->SelLength = SourceText->SelLength - 2;  // don't select last \r\n pair
      }
      // if removing from bottom of selection (up)
      if (SourceText->SelLength < oldSelLength - 3 && SourceText->SelLength != 0) {
        // if beginning of selection removed was \r\n\r\n
        if (SourceText->Text.SubString(SourceText->SelStart+oldSelLength-3,4) == "\r\n\r\n")
          SourceText->SelLength = oldSelLength - 2;  // only select one \r\n pair
      }
    }

    oldSelStart = SourceText->SelStart;
    oldSelLength = SourceText->SelLength;
  } catch( ... ) {
  }

}

//---------------------------------------------------------------------------
void __fastcall TTextStuff::EditorReload1Click(TObject *Sender)
{
  try {
    if(Project.Modified && Project.HasName)
    {
      TMsgDlgButtons temp_set;
      temp_set << mbYes << mbNo;
      int iMsg;

      AnsiString asBuffer = ExtractFileName(Project.CurrentFile) + " is modified. Do you want to discard changes and reopen?";
      iMsg = MessageDlg(asBuffer, mtConfirmation, temp_set, 0);
      if(iMsg == mrNo)  //do not reload file
        return;
    }
    if(Project.HasName)
    {
      // reload file
      LoadFile(Project.CurrentFile);
    }
    UpdateStatusBar();
  } catch( ... ) {
  }
}


//---------------------------------------------------------------------------
// return number of visible lines in richedit control
int  __fastcall TTextStuff::getVisibleLineCount()
{
   //get the formatting rectangle of the richedit control:
   RECT richRect = {0};
   ::SendMessage(SourceText->Handle,EM_GETRECT,0,(long)&richRect);
   int lineCount = (richRect.bottom - richRect.top) / (abs(SourceText->Font->Height)+3);
   return lineCount;
}

//---------------------------------------------------------------------------
void __fastcall TTextStuff::SourceTextVertScroll(TObject *Sender)
{
  //highlightAbort = true;        // stop current highlight operation
  colorHighlight(0,SourceText->Lines->Count);  // highlight
}

//---------------------------------------------------------------------------
void __fastcall TTextStuff::FormResize(TObject *Sender)
{
  //highlightAbort = true;        // stop current highlight operation
  colorHighlight(0,SourceText->Lines->Count);  // highlight
}

//---------------------------------------------------------------------------
// Call this function with the start and end lines to highlight.
// Saves the lines for highlighting and starts the HighlightTimer.
// The syntax highlight will occur when the timer fires.
// Using a timer prevents the syntax highlight from slowing rapid editing.
// Only visible lines are highlighted.
void __fastcall TTextStuff::colorHighlight(int startLine, int endLine)
{
  try {
    if (highlightDisabled)
      return;
    if (!Project.IsSource)              // only source files are highlighted
      return;
    if (HighlightTimer->Enabled) {      // if highlight pending
      HighlightTimer->Enabled = false;  // reset timer
      if (startLine < colorStart)
        colorStart = startLine;         // minimum startLine
      if (endLine > colorEnd)
        colorEnd = endLine;             // maximum endLine
    } else {                            // else, new highlight
      colorStart = startLine;
      colorEnd = endLine;
    }
    // only visible lines are highlighted
    int firstLine = ::SendMessage(SourceText->Handle,EM_GETFIRSTVISIBLELINE,0,0);
    if (colorEnd < firstLine)           // if none of the highlight lines are on screen
      return;

    if (colorStart < firstLine)
      colorStart = firstLine;
    int lastVisible = firstLine + getVisibleLineCount();
    if (colorEnd > lastVisible)
      colorEnd = lastVisible;

    HighlightTimer->Enabled = true;     // start timer
  } catch( ... ) {
  }
}

//---------------------------------------------------------------------------
// Called by HighlightTimer
// Does the color and syntax highlight for lines from colorStart through colorEnd
// 0 is first line
// The source code is parsed to determine what each word in the code
// represents so it may be properly highlighted.
// Minimize interaction with the RichEdit control (SourceText) as much as possible
// for best performance.
void __fastcall TTextStuff::HighlightTimerTimer(TObject *Sender)
{
  int size, startLine = colorStart, endLine = colorEnd;
  char *start;

  try {

    // save the current caret location
    int selStart = SourceText->SelStart;
    int selLength = SourceText->SelLength;

    // get line number of first visible line
    int firstLine = ::SendMessage(SourceText->Handle,EM_GETFIRSTVISIBLELINE, 0, 0);
    // get horizontal scroll bar position
    int horzScrollPos = ::GetScrollPos(SourceText->Handle, SB_HORZ);

    bool modified;

    //highlightAbort = false;             // set true to halt highlight
    HighlightTimer->Enabled = false;  // reset timer

    if (endLine < startLine || SourceText->Lines->Count == 0)
      return;

    // disable all RichEdit events
    int eventMask = ::SendMessage(SourceText->Handle,EM_SETEVENTMASK,0,0);
    ::SendMessage(SourceText->Handle,WM_SETREDRAW,false,0);

    // enable RichEdit KeyEvents and other as necessary to allow highlightAbort
    // to function.
    //::SendMessage(SourceText->Handle,EM_SETEVENTMASK,0,ENM_KEYEVENTS);

    modified = SourceText->Modified;            // save modified

    if (startLine < 0)
      startLine = 0;
    if (endLine > SourceText->Lines->Count)
      endLine = SourceText->Lines->Count;

    // set all of range to codestyle to minimize interaction with RichEdit
    lineStart = GetFirstPos(startLine);         // get position of line start
    SourceText->SelStart = lineStart;
    SourceText->SelLength = GetLastPos(endLine) - lineStart;
    SourceText->SelAttributes->Color = codeStyle.color;
    SourceText->SelAttributes->Style = TFontStyles();   // clear styles
    if (codeStyle.bold)
      SourceText->SelAttributes->Style = SourceText->SelAttributes->Style << fsBold;
    if (codeStyle.italic)
      SourceText->SelAttributes->Style = SourceText->SelAttributes->Style << fsItalic;
    if (codeStyle.underline)
      SourceText->SelAttributes->Style = SourceText->SelAttributes->Style << fsUnderline;

    for (int ln=startLine; ln<=endLine; ln++) { // for each line
      // get text of this line in all caps
      strcap(capLine, SourceText->Lines->Strings[ln].c_str());
      p = start = skipSpace(capLine);           // skip leading white space
      if (!*p)
        continue;

      lineStart = GetFirstPos(ln);              // get position of line start

      if (*p == '*' || *p == ';') {             // if comment line
        SourceText->SelStart = lineStart;
        SourceText->SelLength = GetLastPos(ln) - lineStart;
        setFontStyle(commentStyle);
        continue;
      }

      while (isalnum(*p) || *p == '.' || *p == '_' || *p == '$')  // skip possible label
        p++;
      if ((start == capLine) || *p == ':') {    // if label
        if (*p == ':')
          p++;                                  // skip :
        SourceText->SelStart = lineStart;
        SourceText->SelLength = p - capLine;
        setFontStyle(labelStyle);
        p = skipSpace(p);                       // skip spaces after label
        if (!*p)
          continue;
      } else {                                  // else not label
        p = start;                              // reset p to start of code on line
        start = capLine;                        // reset start to beginning of line
      }

      if (*p == '*' || *p == ';') {             // if comment after label
        SourceText->SelStart = lineStart + p - capLine;
        SourceText->SelLength = GetLastPos(ln) - SourceText->SelStart;
        setFontStyle(commentStyle);
        continue;
      }

      // highlight rest of line
      tokenize(start, ". \t\n", tokenS, tokensS);  	// tokenize statement

      tokenT tokenType = UNKNOWN;
      syntaxStart = p;                          // save starting position of syntax

      highlightLine(tokenType);

      if (tokenType == ERROR_STYLE) {
        SourceText->SelStart = lineStart + syntaxStart - capLine;
        SourceText->SelLength = GetLastPos(ln) - SourceText->SelStart;
        setFontStyle(errorStyle);
      } else if (tokenType == COMMENT) {
        SourceText->SelStart = lineStart + p - capLine;
        SourceText->SelLength = GetLastPos(ln) - SourceText->SelStart;
        setFontStyle(commentStyle);
      } else if (tokenType == UNKNOWN) {
        SourceText->SelStart = lineStart + syntaxStart - capLine;
        SourceText->SelLength = GetLastPos(ln) - SourceText->SelStart;
        setFontStyle(unknownStyle);
      }
      //  if (highlightAbort)
      //    break;                // stop current highlight operation
    }  // end for each line

    StatusBar->Panels->Items[3]->Text = "";

    SourceText->Cursor = crDefault;
    SourceText->Modified = modified;            // restore modified

    // restore the caret position
    SourceText->SelStart = selStart;
    SourceText->SelLength = selLength;

    // restore vertical scroll position...
    //    get current first visible line,
    //    compute the number of lines to scroll, and scroll...
    int currLine = ::SendMessage(SourceText->Handle, EM_GETFIRSTVISIBLELINE, 0, 0);
    ::SendMessage(SourceText->Handle, EM_LINESCROLL, 0, firstLine - currLine);

    // restore horizontal scroll position
    ::SendMessage(SourceText->Handle, WM_HSCROLL, SB_THUMBPOSITION | (horzScrollPos << 16), 0);
    
    // enable RichEdit events and force update
    ::SendMessage(SourceText->Handle,WM_SETREDRAW,true,0);
    ::InvalidateRect(SourceText->Handle,0,true);
    ::SendMessage(SourceText->Handle,EM_SETEVENTMASK,0,eventMask);

  } catch(...) {
    StatusBar->Panels->Items[1]->Text = "SYNTAX";
  }
}

//---------------------------------------------------------------------------
// Parse the relational test for syntax highlighting
// widest relational tests must be first in array
const int REL_COUNT = 14;
const int REL_WIDTH = 9;
const char relational[REL_COUNT][REL_WIDTH] = {
        '*',    '<',    '*',    '&',    '.',    '*',    '<',    '*',    ' ',
        '*',    '<',    '*',    '|',    '.',    '*',    '<',    '*',    ' ',
        '*',    '<',    '*',    '&',    '*',    '<',    '*',    ' ',    ' ',
        '*',    '<',    '*',    '|',    '*',    '<',    '*',    ' ',    ' ',
        '<',    '&',    '.',    '*',    '<',    '*',    ' ',    ' ',    ' ',
        '<',    '|',    '.',    '*',    '<',    '*',    ' ',    ' ',    ' ',
        '<',    '&',    '*',    '<',    '*',    ' ',    ' ',    ' ',    ' ',
        '<',    '|',    '*',    '<',    '*',    ' ',    ' ',    ' ',    ' ',
        '*',    '<',    '*',    '&',    '<',    ' ',    ' ',    ' ',    ' ',
        '*',    '<',    '*',    '|',    '<',    ' ',    ' ',    ' ',    ' ',
        '<',    '&',    '<',    ' ',    ' ',    ' ',    ' ',    ' ',    ' ',
        '<',    '|',    '<',    ' ',    ' ',    ' ',    ' ',    ' ',    ' ',
        '*',    '<',    '*',    ' ',    ' ',    ' ',    ' ',    ' ',    ' ',
        '<',    ' ',    ' ',    ' ',    ' ',    ' ',    ' ',    ' ',    ' ',
};

// Post: returns number of token following the expression or 0 if no match
int checkRelational(int n) {
  bool match = false;
  int row, col;
  for (row=0; row<REL_COUNT; row++) {
    for (col=0; col<REL_WIDTH; col++) {
      if (relational[row][col] == '<') {        // <??>
        if (tokenS[n+col][0]!='<' || tokenS[n+col][3]!='>')  // if no match
          break;
      }
      if (relational[row][col] == '|') {        // OR
        if( (strcmp(tokenS[n+col], "OR")))       // if no match
          break;
      }
      if (relational[row][col] == '&') {        // AND
        if( (strcmp(tokenS[n+col], "AND")))      // if no match
          break;
      }
      if (relational[row][col] == '.') {        // .size
        if( tokenS[n+col][0] != '.')             // if no match
          break;
      }
      if (relational[row][col] == '*') {        // OPERAND
        if( tokenS[n+col][0] == '\0')            // if no match
          break;
      }
      if (relational[row][col] == ' ') {        // if matching relational found
        match = true;
        break;
      }
    }
    if (match)
      break;
  }
  if (!match)
    return 0;

  return n+col;
}

//---------------------------------------------------------------------------
// Parse the the line for syntax highlighting
// Pre: tokenS and tokensS contain the tokens for the line in all caps.
//      p points to the line
//      The text is already set to codeStyle
// This parser for syntax highlighting only
bool __fastcall TTextStuff::highlightLine(tokenT &tokenType)
{
  const int DIRECTIVE_COUNT = 32;       // 32 directives
  const int NO_OPERAND_I = 7;           // first 7 have no operand
  static char *directives[DIRECTIVE_COUNT] =
                {"ENDC","ENDM","LIST","NOLIST",
                 "PAGE","MEXIT","SIMHALT",      // first 7 have no operand
                 "DC","DCB","DS","END","EQU","FAIL",
                 "INCLUDE","MACRO","MEMORY","OFFSET","OPT","ORG",
                 "REG","SECTION","SET","IFC","IFNC","IFEQ","IFNE","INCBIN",
                 "IFLT","IFLE","IFGT","IFGE","NARG"};
  // code below assumes ELSE is in element 0
  const int STRUCTURE_SINGLES = 5;
  static char *structureSingles[] = {"ELSE","ENDI","ENDF","ENDW","REPEAT"};

  static instruction *tablePtr;
  char size;
  int error;
  int n = 1;                    // token number

  try {
    if(tokenType == OPCODE_FOUND) {
      return true;
    }

    if(tokenS[2][0] == '.')      // if token[2] is .?
      n = 2;

    // directives
    for(int i=0; i<DIRECTIVE_COUNT; i++) {      // for all directives
      if( !(strcmp(tokenS[1], directives[i])) ) {  // if match
        if(tokenEnd[n])
          p = tokenEnd[n];                      // get ending position of directive
        SourceText->SelStart = lineStart + syntaxStart - capLine;
        SourceText->SelLength = p - syntaxStart;
        setFontStyle(directiveStyle);
        p = skipSpace(p);
        syntaxStart = p;
        if( !(strcmp(tokenS[1], "FAIL")) ) {    // if FAIL
          tokenType = OPCODE_FOUND;
          return true;
        }
        if( i < NO_OPERAND_I ) {
          tokenType = COMMENT;
          syntaxStart = p;
          return true;
        }
        p = highlightOperand();                 // highlight operands of directive
        if( !(strcmp(tokenS[1], "MEMORY")) ){   // if MEMORY
          p = highlightOperand();               // highlight additional operands of directive
        }
        tokenType = COMMENT;                    // the rest of the line is comment
        syntaxStart = p;
        return true;
      }
    }

    // structured
    //  token number
    //    1     2     3     4     5     6     7     8     9    10    11    12
    //   IF    .B    D0    <cc>  D1    AND   .B    D2    <cc>  D3   THEN   .S
    if( !(strcmp(tokenS[1], "IF"))) {
      n = checkRelational(n+1);
      if(n) {
        if( !(strcmp(tokenS[n], "THEN")))
          tokenType = STRUCTURE;
        else
          tokenType = ERROR_STYLE;
      } else
        tokenType = ERROR_STYLE;
    } else if( !(strcmp(tokenS[1], "WHILE"))) {
      if( !(strcmp(tokenS[n+1], "<T>")) )
        n+=2;
      else
        n = checkRelational(n+1);
      if(n) {
        if( !(strcmp(tokenS[n], "DO")))
          tokenType = STRUCTURE;
        else
          tokenType = ERROR_STYLE;
      } else
        tokenType = ERROR_STYLE;
    } else if( !(strcmp(tokenS[1], "FOR"))) {
      //op1 = op2 TO     op3
      //op1 = op2 TO     op3 BY op3
      //op1 = op2 DOWNTO op3
      //op1 = op2 DOWNTO op3 BY op3
      if( !(strcmp(tokenS[n+2], "=")) &&
           (!(strcmp(tokenS[n+4], "TO")) || !(strcmp(tokenS[n+4], "DOWNTO"))) )
      {
        if( !(strcmp(tokenS[n+6], "BY")))
          n += 8;                       // number of last token in structure
        else
          n += 6;
        if( !(strcmp(tokenS[n], "DO")))
          tokenType = STRUCTURE;
        else
          tokenType = ERROR_STYLE;
      } else
        tokenType = ERROR_STYLE;
    } else if( !(strcmp(tokenS[1], "DBLOOP"))) {
      // Dn = op1
      if( (tokenS[n+1][0] == 'D') && (isdigit(tokenS[n+1][1])) &&
         ((tokenS[n+2][0] == '=')) && (tokenS[n+3][0] != '\0') )
      {
        n += 3;                         // number of last token in structure
        tokenType = STRUCTURE;
      } else
        tokenType = ERROR_STYLE;
    } else if( !(strcmp(tokenS[1], "UNLESS"))) {
      // empty
      // <F>
      // op1 <cc> op2
      if( (tokenS[n+1][0] == '\0') )
        tokenType = STRUCTURE;
      else if (!(strcmp(tokenS[n+1], "<F>")) ) {
        tokenType = STRUCTURE;
        n += 1;
      } else if( (tokenS[n+2][0] == '<' && tokenS[n+2][3] == '>' && tokenS[n+3][0] != '\0') ) {
        tokenType = STRUCTURE;
        n += 3;                   // number of last token in structure
      } else
        tokenType = ERROR_STYLE;
    } else if( !(strcmp(tokenS[1], "UNTIL"))) {
      n = checkRelational(n+1);
      if(n) {
        if( !(strcmp(tokenS[n], "DO")))
          tokenType = STRUCTURE;
        else
          tokenType = ERROR_STYLE;
      } else
        tokenType = ERROR_STYLE;
    } else {
      tokenType = UNKNOWN;
      // single structure words
      for(int i=0; i<STRUCTURE_SINGLES; i++) {     // for all single structure words
        if( !(strcmp(tokenS[1], structureSingles[i])) ) {  // if match
          if(i == 0 && tokenS[n+1][0] == '.')
            n++;
          tokenType = STRUCTURE;
          break;
        }
      }

      if (tokenType == UNKNOWN) {
        // opcodes
        error = 0;
        instLookup(tokenS[1], &tablePtr, &size, &error);        // look for valid opcode
        if(error < SEVERE) {                    // if opcode found
          tokenType = OPCODE_FOUND;
          if(tokenEnd[n])
            p = tokenEnd[n];                    // get ending position of token 1
          p = skipSpace(p);
          if(tokenS[n+1][0] == '\0') {           // if opcode only
            return true;
          }
          if(tablePtr->flavorPtr && tablePtr->flavorPtr->source) {        // if this opcode wants source
            p = highlightOperand();            // highlight operands of directive
          }
          p = skipSpace(p);
          if(!*p)
            return true;
          syntaxStart = p;
          tokenType = COMMENT;                  // the rest of the line is comment
          return true;
        }
      }
    }

    if (tokenType == STRUCTURE) {
      if (tokenS[n+1][0] == '.')                 // if last token ends with .?
        n++;
      if(tokenEnd[n])
        p = tokenEnd[n];                        // get ending position of last token
      SourceText->SelStart = lineStart + syntaxStart - capLine;
      SourceText->SelLength = p - syntaxStart;
      setFontStyle(structureStyle);             // highlight structure
      p = skipSpace(p);
      syntaxStart = p;
      tokenType = COMMENT;                      // the rest of the line is comment
    }
    return true;

  } catch( ... ) {
    StatusBar->Panels->Items[1]->Text = "SYNTAX";
  }
  return false;
}

//---------------------------------------------------------------------------
// Parse the operand for syntax highlighting
// Pre: The text is already set to codeStyle
char* __fastcall TTextStuff::highlightOperand()
{
  bool more;
  int parenCount;
  char quote;

  try {
    do {
      parenCount = 0;
      // find delimeter
      while (*p && *p != '(' && *p != '\'' && *p != '\"' && *p != ',' && *p != ' ' && *p != '\t')
        p++;
      if (!*p) {
        return p;
      } else if (*p == '(') {                 // if found (
        p++;
        parenCount++;
        while (*p && parenCount) {            // find matching )
          if (*p == '(')
            parenCount++;
          else if (*p == ')')
            parenCount--;
          p++;
        }
        if (!*p && parenCount) {        // if no matching )
          SourceText->SelStart = lineStart + syntaxStart - capLine;
          SourceText->SelLength = p - syntaxStart;
          setFontStyle(errorStyle);
          return p;
        }
        if (*p && !isspace(*p)) {       // if not space
          p++;
          more = true;                  // more operand
          continue;
        }
      } else if (*p == '\'' || *p == '\"') { // if found ' or "
        quote = *p;                     // save quote type
        SourceText->SelStart = lineStart + p - capLine;
        syntaxStart = p;
        do {                            // find matching quote
          p++;
          while( (*p == '\'' && *(p+1) == '\'') )  // skip ''
            p+=2;
        } while (*p && *p != quote);
        if (!*p) {                      // if no matching quote
          SourceText->SelLength = p - syntaxStart;
          setFontStyle(errorStyle);
          return p;
        } else {                        // matching quote found
          p++;
          SourceText->SelLength = p - syntaxStart;
          setFontStyle(textStyle);
        }
        syntaxStart = p;
        if (*p && !isspace(*p)) {       // if not space
          p++;
          more = true;                  // more operand
          continue;
        }
      }
      p = skipSpace(p);
      if (*p == ',') {                  // if ,
        p++;
        p = skipSpace(p);
        more = true;                    // more operand
      } else {                          // else end of operand
        more = false;                   // done
      }
    }while (more);
    return p;

  } catch( ... ) {
    StatusBar->Panels->Items[1]->Text = "SYNTAX";
  }
  return 0;
}

//---------------------------------------------------------------------------
// set the selected text font
// Pre: The text is already set to codeStyle

void __fastcall TTextStuff::setFontStyle(FontStyle fs)
{
  try {
    if (fs.color != codeStyle.color)
      SourceText->SelAttributes->Color = fs.color;

    if (fs.bold != codeStyle.bold ||
        fs.italic != codeStyle.italic ||
        fs.underline != codeStyle.underline)
    {
      SourceText->SelAttributes->Style = TFontStyles();   // clear styles
      if (fs.bold)
        SourceText->SelAttributes->Style = SourceText->SelAttributes->Style << fsBold;
      if (fs.italic)
        SourceText->SelAttributes->Style = SourceText->SelAttributes->Style << fsItalic;
      if (fs.underline)
        SourceText->SelAttributes->Style = SourceText->SelAttributes->Style << fsUnderline;
    }
  } catch( ... ) {
    StatusBar->Panels->Items[1]->Text = "SYNTAX";
  }

}

//---------------------------------------------------------------------------
// Undo/Redo methods
//
// Undo is based on two RichEdit events:
//      SourceTextProtectChange   SourceTextChange
// SourceTextProtectChange is called prior to any attempt to modify protected
// text. In this editor all text is protected so this event always occurs.
// SourceTextChange is called after the text is changed.
// The text that is changed and the location of the change is saved by calling
// SaveUndo(). A call to Undo() restores the change. SaveRedo() and ReDo perform
// the same for redo operations.
// The cursor is positioned to the undone location.

// undo/redo globals
bool undoSaved = false;
int selStart1 = 0, selLength1 = 0;
AnsiString undoStr;
unsigned int textLength = 0;

//---------------------------------------------------------------------------
// save data so current change may be undone
void __fastcall TTextStuff::SaveUndo(UndoRedo item, bool notRedo)
{
  try {
    if(item.length == 0 && item.str == "")    // nothing to save
      return;

    if(notRedo && undoS.empty())        // if notRedo and undo stack is empty
      clearRedo();                      // clear redo

    undoS.push(item);                   // push item on undo stack
    Main->EditUndo->Enabled = true;

    if (notRedo) {
      // syntax highlight changed lines
      int startLine = SourceText->Perform(EM_LINEFROMCHAR, item.start, 0);
      int endLine = SourceText->Perform(EM_LINEFROMCHAR, item.start + item.length, 0);
      colorHighlight(startLine,endLine);
    }

  } catch (...) {
    MessageDlg("Undo/Redo limit reached. File save recommended." ,mtWarning, TMsgDlgButtons() << mbOK,0);
  }
}

//---------------------------------------------------------------------------
// SaveRedo
void __fastcall TTextStuff::SaveRedo(UndoRedo item)
{
  try {
    if(item.length == 0 && item.str == "")    // nothing to save
      return;

    redoS.push(item);
    Main->EditRedo->Enabled = true;

  } catch (...) {
    MessageDlg("Undo/Redo limit reached. File save recommended." ,mtWarning, TMsgDlgButtons() << mbOK,0);
  }
}

//---------------------------------------------------------------------------
// clear redo stack
void __fastcall TTextStuff::clearRedo()
{
  try {
    while(!redoS.empty())
      redoS.pop();
    Main->EditRedo->Enabled = false;
  } catch (...) {
    MessageDlg("Undo/Redo stack error." ,mtWarning, TMsgDlgButtons() << mbOK,0);
  }
}

//---------------------------------------------------------------------------
// clear undo/redo stacks
void __fastcall TTextStuff::clearUndoRedo()
{
  try {
    while(!undoS.empty())
      undoS.pop();
    Main->EditUndo->Enabled = false;
    clearRedo();
  } catch (...) {
    MessageDlg("Undo/Redo stack error." ,mtWarning, TMsgDlgButtons() << mbOK,0);
  }
}

//---------------------------------------------------------------------------
//  Undo
void __fastcall TTextStuff::Undo()
{
  try {
    UndoRedo undoData, redoData;

    if(undoS.empty() )            // if undo stack is empty
      return;                     // force loop exit

    // Pop information off the undo stack:
    undoData = undoS.top();
    undoS.pop();

    // redo data
    redoData.start = undoData.start;
    redoData.length = undoData.str.Length();
    redoData.str = SourceText->Text.SubString(undoData.start+1,undoData.length);

    // Do it
    exec_undo(undoData);

    // push redo data
    if (redoData.length > 0)
      redoData.length = undoData.length;        // use actual undo length
    SaveRedo(redoData);

    // If undo stack empty
    if( undoS.empty() ) {
      SourceText->Modified = false;  // document restored to original
      Main->EditUndo->Enabled = false;
      UpdateStatusBar();
    }
  } catch (...) {
    MessageDlg("Error in Undo." ,mtWarning, TMsgDlgButtons() << mbOK,0);
  }
}

//---------------------------------------------------------------------------
//  Redo
void __fastcall TTextStuff::Redo()
{
  try {
    UndoRedo undoData, redoData;

    if(redoS.empty() )            // if redo stack is empty
      return;                     // force loop exit

    // Pop information off the redo stack:
    redoData = redoS.top();
    redoS.pop();

    // undo data
    undoData.start = redoData.start;
    undoData.length = redoData.str.Length();
    undoData.str = SourceText->Text.SubString(redoData.start+1,redoData.length);

    // Do it
    exec_undo(redoData);

    // push undo data
    if (undoData.length > 0)
      undoData.length = redoData.length;        // use actual redo length
    SaveUndo(undoData, false);

    // If redo stack empty
    if( redoS.empty() )
      Main->EditRedo->Enabled = false;
  } catch (...) {
    MessageDlg("Error in Redo." ,mtWarning, TMsgDlgButtons() << mbOK,0);
  }
}

//---------------------------------------------------------------------------
// Exec undo
// sets item.length with undo length
void __fastcall TTextStuff::exec_undo(UndoRedo &item)
{
  try {
    //disable all RichEdit events
    int eventMask = ::SendMessage(SourceText->Handle,EM_SETEVENTMASK,0,0);
    ::SendMessage(SourceText->Handle,WM_SETREDRAW,false,0);

    SourceText->SelStart = item.start;
    SourceText->SelLength = item.length;
    int undoLength = item.length;
    if (item.str.Length() > 0)
      undoLength = item.str.Length();

    // special case to deal with RichEdit
    // When text is deleted from a RichEdit control at the end of a line
    // but not the entire line, the RichEdit control will add a \r\n pair
    // back to the end of the line. Undo deals with that here.
    if (item.str.Length() > 2)                          // if paste of text, not just \r\n
      if (SourceText->Text.SubString(item.start+item.length+1,2) == "\r\n") // if at end of line
        if (SourceText->Text.SubString(item.start+item.length,1) != "\n")   // if not empty line
          if (item.str.SubString(item.str.Length()-1,2) == "\r\n")          // if undo string ends in \r\n
            {
              SourceText->SelLength += 2;                 // overwrite \r\n
              undoLength -= 2;
            }
    item.length = undoLength;
    SourceText->SelText = item.str;

    // syntax highlight changed lines
    int startLine = SourceText->Perform(EM_LINEFROMCHAR, item.start, 0);
    int endLine = SourceText->Perform(EM_LINEFROMCHAR, item.start + item.str.Length(), 0)+1;
    colorHighlight(startLine,endLine);

    // enable RichEdit events and force update
    ::SendMessage(SourceText->Handle,WM_SETREDRAW,true,0);
    ::InvalidateRect(SourceText->Handle,0,true);
    ::SendMessage(SourceText->Handle,EM_SETEVENTMASK,0,eventMask);
    SourceText->Repaint();
  } catch(...) {
    MessageDlg("Error in exec_undo." ,mtWarning, TMsgDlgButtons() << mbOK,0);
  }
}

//---------------------------------------------------------------------------
// keep track of mouse drag operations for undo/redo
void __fastcall TTextStuff::SourceTextMouseMove(TObject *Sender,
      TShiftState Shift, int X, int Y)
{
  if (Shift.Contains(ssLeft))           // if drag
    mouseDrag = true;                   // used in SourceTextProtectChange
}

//---------------------------------------------------------------------------
// called prior to change in text.
// undo information is collected
void __fastcall TTextStuff::SourceTextProtectChange(TObject *Sender,
      int StartPos, int EndPos, bool &AllowChange)
{
  try {
    int undoStart, undoLength;
    if (!mouseDragging)
    {
      selStart1 = SourceText->SelStart;
      selLength1 = SourceText->SelLength;
      if (SourceText->SelLength > 0) {      // if text selected
        undoStart = selStart1 + 1;          // SubString index starts at 1
        undoLength = selLength1;
      }else{                                // text not selected
        undoStart = selStart1-1;            // this does index - 2 in SubString
        undoLength = selLength1+4;          // get 4 chars incase \r\n|\r\n
      }
      undoStr = SourceText->Text.SubString(undoStart, undoLength);

      if (mouseDrag)
        mouseDragging = true;
      textLength = SourceText->Text.Length();
    }
    AllowChange = true;
  } catch(...) {
    MessageDlg("Error in SourceTextProtectChange()." ,mtWarning, TMsgDlgButtons() << mbOK,0);
  }
}

//---------------------------------------------------------------------------
// Called after the text change
// The Text property contains the change
// Determines what the change operation was and calls SaveUndo with the
// data that needs to be saved.
void __fastcall TTextStuff::SourceTextChange(TObject *Sender)
{
  try {
    UndoRedo item;
    int sizeDiff = SourceText->Text.Length() - textLength;    // difference in text size
    item.start = selStart1, item.length = 0;

    SourceText->ClearUndo();      // clear the RichEdit undo so it doesn't mess us up
    if (selLength1 == 0) {                        // if no text selected
      if (mouseDragging) {
        mouseDragging = false;
        return;
      }
      if (SourceText->SelLength > 0 || sizeDiff == 0) // if RichEdit bug
        return;
      if (selStart1 == SourceText->SelStart) {    // if Delete key
        if (selStart1 == 0)                       // if Delete key at beginning of text
          undoStr.Delete(3,2);                    // keep chars 1,2 in undoStr
        else
          undoStr.Delete(1,2);                    // keep char3,4 in undoStr
        if (sizeDiff == -1)                       // if not \r\n deleted
          undoStr.Delete(2,1);                    // keep char 1 in undoStr

      } else if (selStart1 > SourceText->SelStart) {    // if Backspace key
        item.start = SourceText->SelStart;
        undoStr.Delete(3,2);                      // keep char 1,2 in undoStr
        if (sizeDiff == -1)                       // if not \r\n deleted
          if(selStart1 == 1)                      // if delete of 1st char
            undoStr.Delete(2,1);                  // keep char 1 in undoStr
          else
            undoStr.Delete(1,1);                  // keep char 2 in undoStr
      } else if (selStart1 < SourceText->SelStart) { // if Paste or keypress
        item.length = SourceText->SelStart - selStart1;
        undoStr = "";
      }
    } else {                                      // text selected change
      if (mouseDragging) {                        // if Drag-n-Drop
        item.str = undoStr;
        SaveUndo(item, true);                     // save deleted text
        item.start = SourceText->SelStart;        // drag destination
        item.length = SourceText->SelLength;
        undoStr = "";
      } else if (selStart1 < SourceText->SelStart) {     // if paste
        item.length = SourceText->SelStart - selStart1;
      }
      colorHighlight(0,SourceText->Lines->Count);  // highlight needed if lines deleted
    }
    mouseDrag = false;
    mouseDragging = false;
    item.str = undoStr;
    SaveUndo(item, true);
    UpdateStatusBar();
  } catch(...) {
    MessageDlg("Error in SourceTextChange()." ,mtWarning, TMsgDlgButtons() << mbOK,0);
  }
}

//---------------------------------------------------------------------------
// enable/disable undo/redo menus and buttons
void __fastcall TTextStuff::FormActivate(TObject *Sender)
{
  try {
    if(!undoS.empty())
      Main->EditUndo->Enabled = true;
    else
      Main->EditUndo->Enabled = false;

    if(!redoS.empty())
      Main->EditRedo->Enabled = true;
    else
      Main->EditRedo->Enabled = false;
  } catch (...) {
    MessageDlg("Undo/Redo stack error." ,mtWarning, TMsgDlgButtons() << mbOK,0);
  }
}
//---------------------------------------------------------------------------






