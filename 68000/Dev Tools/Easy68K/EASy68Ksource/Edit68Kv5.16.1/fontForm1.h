//---------------------------------------------------------------------------

#ifndef fontForm1H
#define fontForm1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
//---------------------------------------------------------------------------
class TfontForm : public TForm
{
__published:	// IDE-managed Components
        TComboBox *cbFont;
        TComboBox *cbSize;
        TLabel *Label1;
        TLabel *Label2;
        TButton *cmdChange;
        TButton *cmdClose;
        TLabel *Label3;
        TEdit *currentSize;
        TLabel *Label4;
        TEdit *currentFont;
        void __fastcall cmdCloseClick(TObject *Sender);
        void __fastcall cmdChangeClick(TObject *Sender);
        void __fastcall FormShow(TObject *Sender);
        void __fastcall cbFontChange(TObject *Sender);
private:	// User declarations
public:		// User declarations
        __fastcall TfontForm(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TfontForm *fontForm;
//---------------------------------------------------------------------------
#endif
