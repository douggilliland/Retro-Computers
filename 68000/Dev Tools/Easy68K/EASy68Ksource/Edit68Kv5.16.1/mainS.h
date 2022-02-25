//---------------------------------------------------------------------------

#ifndef mainSH
#define mainSH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ActnList.hpp>
#include <Dialogs.hpp>
#include <ImgList.hpp>
#include <Menus.hpp>
#include <StdActns.hpp>
#include <ComCtrls.hpp>
#include <ToolWin.hpp>
#include <ExtCtrls.hpp>
#include <SHELLAPI.H>           // required for drag-n-drop from explorer
#include <Clipbrd.hpp>
#include "findDialogS.h"
#include "replaceDialogS.h"
#include <NMHttp.hpp>
#include <Psock.hpp>

//---------------------------------------------------------------------------



class TMain : public TForm
{
__published:	// IDE-managed Components
        TOpenDialog *OpenDialog;
        TSaveDialog *SaveDialog;
        TMainMenu *MainMenu1;
        TMenuItem *File1;
        TMenuItem *mnuNew;
        TMenuItem *mnuOpen;
        TMenuItem *N2;
        TMenuItem *mnuSave;
        TMenuItem *mnuSaveAs;
        TMenuItem *N3;
        TMenuItem *N4;
        TMenuItem *mnuExit;
        TImageList *ImageList1;
        TActionList *ActionList1;
        TEditCopy *EditCopy1;
        TEditCut *EditCut1;
        TEditPaste *EditPaste1;
        TEditSelectAll *EditSelectAll1;
        TMenuItem *Edit1;
        TMenuItem *Cut1;
        TMenuItem *Copy1;
        TMenuItem *Paste1;
        TMenuItem *N5;
        TMenuItem *SelectAll1;
        TMenuItem *Undo1;
        TMenuItem *N6;
        TMenuItem *Compile1;
        TMenuItem *mnuDoAssembler;
        TMenuItem *N7;
        TMenuItem *mnuPrintSource;
        TToolBar *ToolBar1;
        TToolButton *tbOpen;
        TToolButton *tbSave;
        TToolButton *tbPrint;
        TToolButton *ToolButton1;
        TToolButton *tbCopy;
        TToolButton *tbCut;
        TToolButton *tbPaste;
        TToolButton *tbUndo;
        TToolButton *tbNew;
        TToolButton *ToolButton2;
        TToolButton *tbAssemble;
        TToolButton *ToolButton4;
        TMenuItem *About1;
        TMenuItem *mnuHelp;
        TMenuItem *N1;
        TMenuItem *mnuAbout;
        TMenuItem *mnuFind;
        TToolButton *tbFind;
        TPrinterSetupDialog *PrinterSetupDialog;
        TMenuItem *mnuPrinterSetup;
        TWindowArrange *WindowArrange1;
        TWindowCascade *WindowCascade1;
        TWindowClose *WindowClose1;
        TWindowMinimizeAll *WindowMinimizeAll1;
        TWindowTileHorizontal *WindowTileHorizontal1;
        TWindowTileVertical *WindowTileVertical1;
        TMenuItem *Window1;
        TMenuItem *Arrange1;
        TMenuItem *Cascade1;
        TMenuItem *TileHorizontally1;
        TMenuItem *TileVertically1;
        TMenuItem *MinimizeAll1;
        TMenuItem *Close1;
        TMenuItem *N10;
        TPrintDialog *PrintDialog;
        TMenuItem *mnuFindAndReplace1;
        TMenuItem *mnuFindNext;
        TMenuItem *Options1;
        TMenuItem *mnuAssemblerOptions;
        TMenuItem *mnuEditorOptions;
        TMenuItem *N9;
        TToolButton *ToolButton3;
        TToolButton *ToolButton5;
        TToolButton *tbCommentAdd;
        TToolButton *ToolButton6;
        TToolButton *tbUncomment;
        TAction *EditCommentAdd1;
        TAction *EditUncomment1;
        TMenuItem *CommentSelection1;
        TMenuItem *UncommentSelection1;
        TMenuItem *N11;
        TAction *EditUndo;
        TAction *EditRedo;
        TMenuItem *Redo1;
        TToolButton *ToolButton7;
        TNMHTTP *NMHTTP1;
        void __fastcall mnuSaveAsClick(TObject *Sender);
        void __fastcall mnuExitClick(TObject *Sender);
        void __fastcall mnuOpenClick(TObject *Sender);
        void __fastcall mnuDoAssemblerClick(TObject *Sender);
        void __fastcall mnuEditorOptionsClick(TObject *Sender);
        void __fastcall mnuSaveClick(TObject *Sender);
        void __fastcall mnuPrintSourceClick(TObject *Sender);
        void __fastcall tbOpenClick(TObject *Sender);
        void __fastcall tbSaveClick(TObject *Sender);
//        void __fastcall tbPrintClick(TObject *Sender);
        void __fastcall mnuNewClick(TObject *Sender);
        void __fastcall tbNewClick(TObject *Sender);
        void __fastcall tbAssembleClick(TObject *Sender);
        void __fastcall mnuAboutClick(TObject *Sender);
        void __fastcall mnuHelpClick(TObject *Sender);
        void __fastcall mnuFindClick(TObject *Sender);
        void __fastcall tbFindClick(TObject *Sender);
        void __fastcall mnuPrinterSetupClick(TObject *Sender);
        void __fastcall mnuFindAndReplace1Click(TObject *Sender);
//        void __fastcall ReplaceDialog1Replace(TObject *Sender);
        void __fastcall FormShow(TObject *Sender);
        void __fastcall Edit1Click(TObject *Sender);
        void __fastcall mnuFindNextClick(TObject *Sender);
        void __fastcall mnuAssemblerOptionsClick(TObject *Sender);
        void __fastcall FormClose(TObject *Sender, TCloseAction &Action);
        void __fastcall FormKeyDown(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall EditPaste1Execute(TObject *Sender);
        void __fastcall EditCommentAdd1Execute(TObject *Sender);
        void __fastcall EditUncomment1Execute(TObject *Sender);
        void __fastcall EditUndoExecute(TObject *Sender);
        void __fastcall EditRedoExecute(TObject *Sender);
        void __fastcall Reload1Click(TObject *Sender);
private:	// User declarations
        void __fastcall WmDropFiles(TWMDropFiles& Message);     // handle drag-n-drop from explorer
//        void __fastcall HandleVScroll(TMessage& msg);
public:		// User declarations
        __fastcall TMain(TComponent* Owner);
        //function prototypes
        void __fastcall OpenFile(AnsiString name);
        void __fastcall FindNext(); //searches for text inputted in the search dialog
        void __fastcall displayHelp(char * context);
        void __fastcall FindDialogFind(AnsiString findText, bool wholeWord, bool matchCase);
        void __fastcall ReplaceDialogReplace();
        
        //variable declarations
        int iNewFiles; //keeps track of how many new files have been opened and the number is used with the naming of new files ex. "untitled1"
        int iListsOpen; //tracks how many list files are open
        int iSourceOpen; //track how many source files are open

        // needed for HTML help
        HWND m_hWindow;
        AnsiString m_asHelpFile;
        DWORD m_Cookie;

        // message map for handling drag-n-drop from explorer
        BEGIN_MESSAGE_MAP
          MESSAGE_HANDLER(WM_DROPFILES, TWMDropFiles, WmDropFiles)
//          MESSAGE_HANDLER(WM_VSCROLL, TMessage, HandleVScroll)
        END_MESSAGE_MAP(TForm)

        // message map for handling vertical scroll bar
//        BEGIN_MESSAGE_MAP
//            MESSAGE_HANDLER(WM_VSCROLL, TMessage, HandleVScroll)
//        END_MESSAGE_MAP(TForm)


};


//---------------------------------------------------------------------------
extern PACKAGE TMain *Main;
//---------------------------------------------------------------------------
#endif
