//---------------------------------------------------------------------------

#ifndef FullscreenOptionsH
#define FullscreenOptionsH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
//---------------------------------------------------------------------------
class TfrmFullscreenOptions : public TForm
{
__published:	// IDE-managed Components
        TEdit *txtScreenNumber;
        TLabel *Label1;
        TButton *cmdOk;
        TButton *cmdCancel;
        void __fastcall FormShow(TObject *Sender);
        void __fastcall txtScreenNumberChange(TObject *Sender);
        void __fastcall cmdOkClick(TObject *Sender);
        void __fastcall cmdCancelClick(TObject *Sender);
private:	// User declarations
public:		// User declarations
        __fastcall TfrmFullscreenOptions(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TfrmFullscreenOptions *frmFullscreenOptions;
//---------------------------------------------------------------------------
#endif
