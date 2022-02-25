//---------------------------------------------------------------------------

#ifndef Stack1H
#define Stack1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ComCtrls.hpp>
#include <ExtCtrls.hpp>
#include <Buttons.hpp>
#include "CSPIN.h"
//---------------------------------------------------------------------------
class TStackFrm : public TForm
{
__published:	// IDE-managed Components
        TPanel *Panel1;
        TLabel *Label2;
        TCSpinButton *CSpinButton1;
        TComboBox *whichStack;
        void __fastcall FormCreate(TObject *Sender);
        void __fastcall FormPaint(TObject *Sender);
        void __fastcall FormResize(TObject *Sender);
        void __fastcall FormShow(TObject *Sender);
        void __fastcall CSpinButton1UpClick(TObject *Sender);
        void __fastcall CSpinButton1DownClick(TObject *Sender);
        void __fastcall FormMouseWheelDown(TObject *Sender,
          TShiftState Shift, TPoint &MousePos, bool &Handled);
        void __fastcall FormMouseWheelUp(TObject *Sender,
          TShiftState Shift, TPoint &MousePos, bool &Handled);
        void __fastcall FormKeyDown(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall whichStackChange(TObject *Sender);
private:	// User declarations
public:		// User declarations
        __fastcall TStackFrm(TComponent* Owner);
        void __fastcall BringToFront();
        void __fastcall DisplayStack();
        void __fastcall updateDisplay();
};
//---------------------------------------------------------------------------
extern PACKAGE TStackFrm *StackFrm;
//---------------------------------------------------------------------------
#endif
