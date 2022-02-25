//---------------------------------------------------------------------------

#ifndef textSH
#define textSH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ComCtrls.hpp>
#include <ImgList.hpp>
#include <Menus.hpp>
#include <ExtCtrls.hpp>
#include <ToolWin.hpp>
#include <StrUtils.hpp>
#include "RichEditPlus.h"
#include <stack>
#include <vector>
#include "asm.h"
#include "mainS.h"
#include "optionsS.h"
#include "editorOptions.h"
#include "findDialogS.h"

using namespace std;

//---------------------------------------------------------------------------

//structure track all the info for the current file loaded into the editor
//these values are used by various parts of the program for different operations
struct FileInfo
{
  AnsiString CurrentFile; //contains the path to the current file loaded in a particular instance of TextStuff
  int TabType;
  int TabSize;
  bool CreateList;
  //bool SourceOpen;
  bool ListOpen;
  bool Modified;
  bool IsSource;    //true if a particular instance of TextStuff is a source file, false for any other file type loaded
  bool HasName;   //true if the file has a valid filename
};

// Information that is saved for one change in the editor for undo/redo.
struct UndoRedo
{
  int   start;          // where the change occurred. (0-n)
  int   length;         // length of characters changed
  AnsiString str;       // the original text
};

enum tokenT {UNKNOWN, CODE, OPCODE_FOUND, COMMENT, ERROR_STYLE, STRUCTURE };

class TTextStuff : public TForm
{
__published:	// IDE-managed Components
        TPopupMenu *PopupMenu1;
        TMenuItem *Copy1;
        TMenuItem *Cut1;
        TMenuItem *Paste1;
        TMenuItem *N1;
        TMenuItem *SelectAll1;
        TMenuItem *Undo1;
        TMenuItem *N2;
        TMenuItem *EditorReload1;
        TSplitter *Splitter3;
        TPopupMenu *PopupMenu2;
        TMenuItem *ClearErrorMessages1;
        TListView *Messages;
        TStatusBar *StatusBar;
        TProgressBar *ProgressBar;
        TTimer *HighlightTimer;
        TMenuItem *Redo1;
        TRichEditPlus *SourceText;
        TMenuItem *CommentSelection1;
        TMenuItem *UncommentSelection1;
        TMenuItem *N3;
        void __fastcall SourceTextKeyDown(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall SourceTextKeyPress(TObject *Sender, char &Key);
        void __fastcall SourceTextKeyUp(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall FormClose(TObject *Sender, TCloseAction &Action);
        void __fastcall ClearErrorMessages(TObject *Sender);
        void __fastcall MessagesDblClick(TObject *Sender);
        void __fastcall SourceTextMouseUp(TObject *Sender,
          TMouseButton Button, TShiftState Shift, int X, int Y);
        void __fastcall SourceTextMouseDown(TObject *Sender,
          TMouseButton Button, TShiftState Shift, int X, int Y);
        void __fastcall FormShow(TObject *Sender);
        void __fastcall tbNewClick(TObject *Sender);
        void __fastcall tbPrintClick(TObject *Sender);
        void __fastcall FormCloseQuery(TObject *Sender, bool &CanClose);
        void __fastcall EditorOptions1Click(TObject *Sender);
        void __fastcall SourceTextSelectionChange(TObject *Sender);
        void __fastcall EditorReload1Click(TObject *Sender);
        void __fastcall SourceTextMouseMove(TObject *Sender,
          TShiftState Shift, int X, int Y);
        void __fastcall SourceTextProtectChange(TObject *Sender,
          int StartPos, int EndPos, bool &AllowChange);
        void __fastcall SourceTextChange(TObject *Sender);
        void __fastcall FormActivate(TObject *Sender);
        void __fastcall HighlightTimerTimer(TObject *Sender);
        void __fastcall SourceTextVertScroll(TObject *Sender);
        void __fastcall FormResize(TObject *Sender);

private:	// User declarations
public:		// User declarations
        __fastcall TTextStuff(TComponent* Owner);


        void __fastcall ProfileStart(unsigned int n);
        void __fastcall ProfileEnd(unsigned int n);
        void __fastcall ProfileClear();



        void __fastcall LoadFile(AnsiString name);
        void __fastcall NewSourceFile();
        void __fastcall UpdateStatusBar();
        void __fastcall SetTabsAll();   // sets tabs of all SourceText
        void __fastcall SetTabs(); //sets tabs of selected text in SourceText
        int __fastcall GetFirstPos(int line); //returns start of line in Char positions
        int __fastcall GetLastPos(int line); //returns end of line in Char positions
        void __fastcall NewProject(AnsiString Type); //reset all controls to new project
        void __fastcall insertInSelection(AnsiString istr);
        void __fastcall deleteFromSelection(AnsiString dstr);
        void __fastcall replaceTabs();
        void __fastcall commentSelection();
        void __fastcall unCommentSelection();
        void __fastcall indentSelection();
        void __fastcall outdentSelection();
        void __fastcall colorHighlight(int startLine, int endLine);
        int  __fastcall getVisibleLineCount();
        bool __fastcall highlightLine(tokenT &tokenType);
        char* __fastcall highlightOperand();
        void __fastcall setFontStyle(FontStyle fs);

        TPoint CurPos; //saves the cursor position
        FileInfo Project; //project info structure
//        int PreviousMatchCount;
//        int PreviousLine;
//        bool First;
        bool InsertMode;        // tracks text insert mode

        // undo items
        // function prototypes
        void __fastcall SaveUndo(UndoRedo item, bool notRedo);
        void __fastcall SaveRedo(UndoRedo item);
        void __fastcall clearRedo();
        void __fastcall clearUndoRedo();
        void __fastcall Undo();
        void __fastcall Redo();
        void __fastcall exec_undo(UndoRedo &item);
        // undo/redo stacks
        stack<UndoRedo,vector<UndoRedo> > undoS;
        stack<UndoRedo,vector<UndoRedo> > redoS;

};
//---------------------------------------------------------------------------
extern PACKAGE TTextStuff *TextStuff;
//---------------------------------------------------------------------------
#endif
