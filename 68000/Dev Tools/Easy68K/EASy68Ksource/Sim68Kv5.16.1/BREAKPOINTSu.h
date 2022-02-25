//---------------------------------------------------------------------------

#ifndef BREAKPOINTSuH
#define BREAKPOINTSuH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <Mask.hpp>
#include <Grids.hpp>
#include <ValEdit.hpp>
#include <ExtCtrls.hpp>
//---------------------------------------------------------------------------
class TBreaksFrm : public TForm
{
__published:	// IDE-managed Components
        TGroupBox *RegGroupBox;
        TStringGrid *RegStringGrid;
        TComboBox *RegSelectCombo;
        TComboBox *RegOperatorCombo;
        TMaskEdit *RegValueMaskEdit;
        TGroupBox *AddrGroupBox;
        TStringGrid *AddrStringGrid;
        TMaskEdit *AddrSelectMaskEdit;
        TMaskEdit *AddrValueMaskEdit;
        TComboBox *AddrOperatorCombo;
        TComboBox *AddrReadWriteCombo;
        TButton *RegSetButton;
        TButton *RegClearButton;
        TButton *RegClearAllButton;
        TButton *AddrSetButton;
        TButton *AddrClearButton;
        TButton *AddrClearAllButton;
        TGroupBox *ExprGroupBox;
        TStringGrid *ExprStringGrid;
        TComboBox *ExprEnabledCombo;
        TButton *ExprSetButton;
        TButton *ExprClearButton;
        TButton *ExprClearAllButton;
        TButton *ExprRegAppendButton;
        TButton *ExprAddrAppendButton;
        TMaskEdit *ExprRegMaskEdit;
        TMaskEdit *ExprAddrMaskEdit;
        TButton *ExprAndAppendButton;
        TButton *ExprOrAppendButton;
        TButton *ExprBackspaceButton;
        TEdit *ExprExprEdit;
        TMaskEdit *ExprCountMaskEdit;
        TComboBox *RegSizeCombo;
        TComboBox *AddrSizeCombo;
        TButton *ExprLParenAppendButton;
        TButton *ExprRParenAppendButton;
        TLabel *debugLabel1;
        TLabel *debugLabel2;
        TLabel *debugLabel3;
        TLabel *debugLabel4;
        TLabel *debugLabel5;
        TLabel *debugLabel6;
        TLabel *debugLabel7;
        void __fastcall RegStringGridClick(TObject *Sender);
        void __fastcall AddrStringGridClick(TObject *Sender);
        void __fastcall ExprStringGridClick(TObject *Sender);
        void __fastcall RegSetButtonClick(TObject *Sender);
        void __fastcall AddrSetButtonClick(TObject *Sender);
        void __fastcall ExprSetButtonClick(TObject *Sender);
        void __fastcall ExprRegAppendButtonClick(TObject *Sender);
        void __fastcall ExprAddrAppendButtonClick(TObject *Sender);
        void __fastcall ExprAndAppendButtonClick(TObject *Sender);
        void __fastcall ExprOrAppendButtonClick(TObject *Sender);
        void __fastcall ExprBackspaceButtonClick(TObject *Sender);
        void __fastcall RegClearButtonClick(TObject *Sender);
        void __fastcall RegClearAllButtonClick(TObject *Sender);
        void __fastcall AddrClearButtonClick(TObject *Sender);
        void __fastcall AddrClearAllButtonClick(TObject *Sender);
        void __fastcall RegValueKeyPress(TObject *Sender, char &Key);
        void __fastcall AddrSelectKeyPress(TObject *Sender, char &Key);
        void __fastcall AddrValueKeyPress(TObject *Sender, char &Key);
        void __fastcall ExprCountKeyPress(TObject *Sender, char &Key);
        void __fastcall ExprClearButtonClick(TObject *Sender);
        void __fastcall ExprClearAllButtonClick(TObject *Sender);
        void __fastcall RegStringGridDblClick(TObject *Sender);
        void __fastcall AddrStringGridDblClick(TObject *Sender);
        void __fastcall ExprStringGridDblClick(TObject *Sender);
        void __fastcall RegColumnMoved(TObject *Sender, int FromIndex,
          int ToIndex);
        void __fastcall AddrColumnMoved(TObject *Sender, int FromIndex,
          int ToIndex);
        void __fastcall ExprColumnMoved(TObject *Sender, int FromIndex,
          int ToIndex);
        void __fastcall RegRowMoved(TObject *Sender, int FromIndex,
          int ToIndex);
        void __fastcall RegTopLeftChanged(TObject *Sender);
        void __fastcall AddrTopLeftChanged(TObject *Sender);
        void __fastcall AddrRowMoved(TObject *Sender, int FromIndex,
          int ToIndex);
        void __fastcall ExprRowMoved(TObject *Sender, int FromIndex,
          int ToIndex);
        void __fastcall ExprTopLeftChanged(TObject *Sender);
        void __fastcall ExprLParenAppendButtonClick(TObject *Sender);
        void __fastcall ExprRParenAppendButtonClick(TObject *Sender);
        void __fastcall FormKeyDown(TObject *Sender, WORD &Key,
          TShiftState Shift);
private:	// User declarations
public:		// User declarations
        __fastcall TBreaksFrm(TComponent* Owner);
        void __fastcall BringToFront();
        int __fastcall sbpoint(int loc);
        int __fastcall cbpoint(int loc);
        void __fastcall setRegButtons();
        void __fastcall setAddrButtons();
        void __fastcall setExprButtons();
        int __fastcall precedence(int op_prec);
        void __fastcall resetDebug();
};
//---------------------------------------------------------------------------
extern PACKAGE TBreaksFrm *BreaksFrm;
//---------------------------------------------------------------------------
#endif
