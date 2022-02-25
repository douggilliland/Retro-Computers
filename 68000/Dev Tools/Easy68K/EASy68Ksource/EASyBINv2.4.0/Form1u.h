//---------------------------------------------------------------------------

#ifndef Form1uH
#define Form1uH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ActnList.hpp>
#include <ComCtrls.hpp>
#include <ImgList.hpp>
#include <Menus.hpp>
#include <ToolWin.hpp>
#include <ExtCtrls.hpp>
#include <SHELLAPI.H>           // required for drag-n-drop from explorer
#include <Mask.hpp>
#include <Dialogs.hpp>
#include "CSPIN.h"
#include "def.h"
#include <Buttons.hpp>

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TActionList *ActionList1;
        TMainMenu *MainMenu1;
        TAction *Open;
        TMenuItem *File1;
        TImageList *ImageList1;
        TMenuItem *Open1;
        TMenuItem *Exit1;
        TMenuItem *Close1;
        TMenuItem *Help1;
        TMenuItem *About1;
        TAction *New;
        TAction *Exit;
        TAction *About;
        TAction *Help;
        TMenuItem *Help2;
        TMenuItem *N7;
        TMenuItem *N8;
        TOpenDialog *OpenDialog;
        TSaveDialog *SaveDialog;
        TPanel *Panel1;
        TLabel *Label1;
        TLabel *Label12;
        TGroupBox *S68File;
        TLabel *Label2;
        TLabel *Label3;
        TLabel *S68endAddress;
        TLabel *Label4;
        TLabel *S68length;
        TRadioGroup *OutputSplit;
        TGroupBox *OutputData;
        TLabel *Label6;
        TLabel *Label7;
        TMaskEdit *OutputLength;
        TPanel *Panel2;
        TLabel *Label13;
        TLabel *Label14;
        TCSpinButton *RowSpin;
        TCSpinButton *PageSpin;
        TTimer *prompt;
        TPanel *Panel3;
        TLabel *Label18;
        TMaskEdit *Address1;
        TPanel *Panel5;
        TLabel *Label17;
        TMaskEdit *OutputFirstAddress;
        TLabel *Label5;
        TLabel *Label8;
        TLabel *Label19;
        TAction *OpenBin;
        TAction *SaveBin;
        TMenuItem *Save1;
        TMenuItem *N1;
        TMenuItem *OpenB;
        TLabel *Label24;
        TLabel *Label25;
        TLabel *Label26;
        TBitBtn *BitBtn1;
        TBitBtn *BitBtn2;
        TLabel *Label28;
        TLabel *Label29;
        TLabel *split0Lbl;
        TLabel *split1Lbl;
        TLabel *split2Lbl;
        TLabel *split3Lbl;
        TMenuItem *SaveSRecord1;
        TAction *SaveSRecord;
        TPanel *Panel6;
        TLabel *Label10;
        TLabel *Label22;
        TMaskEdit *Bytes;
        TButton *Copy;
        TPanel *Panel7;
        TLabel *Label9;
        TLabel *Label20;
        TPanel *FromPanel;
        TLabel *Label15;
        TMaskEdit *From;
        TLabel *Label11;
        TLabel *Label21;
        TPanel *Panel4;
        TLabel *Label16;
        TMaskEdit *To;
        TPanel *Panel8;
        TLabel *Label23;
        TMaskEdit *FillByte;
        TButton *Fill;
        TMaskEdit *startAddress;
        void __fastcall NewExecute(TObject *Sender);
        void __fastcall ExitExecute(TObject *Sender);
        void __fastcall AboutExecute(TObject *Sender);
        void __fastcall FormShow(TObject *Sender);
        void __fastcall FormResize(TObject *Sender);
        void __fastcall HelpExecute(TObject *Sender);
        void __fastcall FormKeyDown(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall OutputStartAddressKeyPress(TObject *Sender, char &Key);
        void __fastcall Address1Change(TObject *Sender);
        void __fastcall FormPaint(TObject *Sender);
        void __fastcall RowSpinUpClick(TObject *Sender);
        void __fastcall RowSpinDownClick(TObject *Sender);
        void __fastcall PageSpinUpClick(TObject *Sender);
        void __fastcall PageSpinDownClick(TObject *Sender);
        void __fastcall FormMouseWheelDown(TObject *Sender,
          TShiftState Shift, TPoint &MousePos, bool &Handled);
        void __fastcall FormMouseWheelUp(TObject *Sender,
          TShiftState Shift, TPoint &MousePos, bool &Handled);
        void __fastcall Address1KeyDown(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall FormMouseDown(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
        void __fastcall promptTimer(TObject *Sender);
        void __fastcall FormKeyPress(TObject *Sender, char &Key);
        void __fastcall CopyClick(TObject *Sender);
        void __fastcall AddrKeyPress(TObject *Sender, char &Key);
        void __fastcall FillClick(TObject *Sender);
        void __fastcall Address1KeyUp(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall OpenBinFile(TObject *Sender);
        void __fastcall SaveBinFile(TObject *Sender);
        void __fastcall OutputSplitClick(TObject *Sender);
        void __fastcall OpenExecute(TObject *Sender);
        void __fastcall OutputFirstAddressChange(TObject *Sender);
        void __fastcall OutputLengthChange(TObject *Sender);
        void __fastcall SaveSRecFile(TObject *Sender);
        void __fastcall startAddressEnter(TObject *Sender);
        void __fastcall OutputFirstAddressEnter(TObject *Sender);
        void __fastcall OutputLengthEnter(TObject *Sender);
        void __fastcall FromEnter(TObject *Sender);
        void __fastcall ToEnter(TObject *Sender);
        void __fastcall BytesEnter(TObject *Sender);
        void __fastcall FillByteEnter(TObject *Sender);
        void __fastcall Address1Enter(TObject *Sender);
private:	// User declarations
        void __fastcall WmDropFiles(TWMDropFiles& Message);     // handle drag-n-drop from explorer
        int row, col, rowHeight, colWidth;
        int textX, textY, nRows;
        bool promptVisible;
        int split;      // 0, 2, or 4 how binary output data is split

public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
        __fastcall ~TForm1();
        void __fastcall displayHelp(char * context);
        void __fastcall OpenSRecordFile(AnsiString name);
        void __fastcall erasePrompt();
        void __fastcall drawPrompt();
        void __fastcall gotoRC(TObject *Sender, int r, int c);



        // needed for HTML help
        HWND m_hWindow;
        AnsiString m_asHelpFile;
        DWORD m_Cookie;

        // message map for handling drag-n-drop from explorer
        BEGIN_MESSAGE_MAP
          MESSAGE_HANDLER(WM_DROPFILES, TWMDropFiles, WmDropFiles)
        END_MESSAGE_MAP(TForm)

};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------

#endif
