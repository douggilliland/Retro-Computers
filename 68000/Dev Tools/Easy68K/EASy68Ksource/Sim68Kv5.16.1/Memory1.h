//---------------------------------------------------------------------------

#ifndef Memory1H
#define Memory1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include "CSPIN.h"
#include <ExtCtrls.hpp>
#include <Mask.hpp>
#include <Dialogs.hpp>
#include <Buttons.hpp>
//---------------------------------------------------------------------------
class TMemoryFrm : public TForm
{
__published:	// IDE-managed Components
        TPanel *Panel1;
        TLabel *Label1;
        TPanel *Panel2;
        TLabel *Label2;
        TCSpinButton *RowSpin;
        TCSpinButton *PageSpin;
        TLabel *Label3;
        TTimer *prompt;
        TButton *Copy;
        TLabel *Label4;
        TLabel *Label5;
        TLabel *Label6;
        TLabel *Label7;
        TButton *Fill;
        TLabel *Label8;
        TCheckBox *LiveCheckBox;
        TSaveDialog *SaveDialog;
        TPanel *Panel3;
        TLabel *Label18;
        TMaskEdit *Address1;
        TLabel *Label24;
        TPanel *FromPanel;
        TLabel *Label15;
        TMaskEdit *From;
        TLabel *Label9;
        TPanel *Panel4;
        TLabel *Label16;
        TMaskEdit *To;
        TMaskEdit *Bytes;
        TLabel *Label10;
        TLabel *Label11;
        TSpeedButton *Save;
        void __fastcall FormCreate(TObject *Sender);
        void __fastcall FormPaint(TObject *Sender);
        void __fastcall FormResize(TObject *Sender);
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
        void __fastcall FormKeyDown(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall CopyClick(TObject *Sender);
        void __fastcall AddrKeyPress(TObject *Sender, char &Key);
        void __fastcall FillClick(TObject *Sender);
        void __fastcall Address1KeyUp(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall Address1Change(TObject *Sender);
        void __fastcall SaveClick(TObject *Sender);
private:	// User declarations
        int row, col, rowHeight, colWidth;
        int textX, textY, nRows;
        bool promptVisible;
public:		// User declarations
        __fastcall TMemoryFrm(TComponent* Owner);
        void __fastcall BringToFront();
        void __fastcall erasePrompt();
        void __fastcall gotoRC(TObject *Sender, int r, int c);
        void __fastcall drawPrompt();
        void __fastcall LivePaint(unsigned int);

};

//---------------------------------------------------------------------------
extern PACKAGE TMemoryFrm *MemoryFrm;
//---------------------------------------------------------------------------
#endif
