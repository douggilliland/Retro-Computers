//---------------------------------------------------------------------------

#ifndef replaceDialogSH
#define replaceDialogSH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include "mainS.h"

//---------------------------------------------------------------------------
class TreplaceDialogFrm : public TForm
{
__published:	// IDE-managed Components
        TLabel *Label1;
        TEdit *findText;
        TCheckBox *wholeWordChk;
        TLabel *Label2;
        TCheckBox *matchCaseChk;
        TLabel *Label3;
        TLabel *Label4;
        TEdit *replaceText;
        TButton *findNextBtn;
        TButton *cancelBtn;
        TButton *replaceBtn;
        TButton *replaceAllBtn;
        void __fastcall findNextBtnClick(TObject *Sender);
        void __fastcall cancelBtnClick(TObject *Sender);
        void __fastcall findTextChange(TObject *Sender);
        void __fastcall replaceBtnClick(TObject *Sender);
        void __fastcall replaceAllBtnClick(TObject *Sender);
private:	// User declarations
public:		// User declarations
        __fastcall TreplaceDialogFrm(TComponent* Owner);
        bool replaceAll;
};
//---------------------------------------------------------------------------
extern PACKAGE TreplaceDialogFrm *replaceDialogFrm;
//---------------------------------------------------------------------------
#endif
