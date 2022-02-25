//---------------------------------------------------------------------------

#ifndef optionsSH
#define optionsSH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ComCtrls.hpp>
#include <Dialogs.hpp>
#include <Mask.hpp>
//---------------------------------------------------------------------------
class TOptions : public TForm
{
__published:	// IDE-managed Components
        TButton *cmdOK;
        TButton *cmdCancel;
        TPageControl *PageControl;
        TTabSheet *tbsAssOpt;
        TGroupBox *GroupBox1;
        TCheckBox *chkGenList;
        TCheckBox *chkGenSRec;
        TCheckBox *chkSave;
        TGroupBox *GroupBox2;
        TCheckBox *chkCrossRef;
        TCheckBox *chkMacEx;
        TCheckBox *chkConstantsEx;
        TTabSheet *TabSheet1;
        TButton *Save;
        TRichEdit *Template;
        TCheckBox *chkStrucEx;
        TCheckBox *chkShowWarnings;
        TCheckBox *chkBitfield;
        void __fastcall cmdCancelClick(TObject *Sender);
        void __fastcall cmdOKClick(TObject *Sender);
        void __fastcall FormShow(TObject *Sender);
        void __fastcall SaveClick(TObject *Sender);
        void __fastcall FormKeyDown(TObject *Sender, WORD &Key,
          TShiftState Shift);
private:	// User declarations
public:		// User declarations
        __fastcall TOptions(TComponent* Owner);
        void __fastcall SaveSettings();   //saves editor settings to file
        void __fastcall LoadSettings();   //loads editor settings from file
        void __fastcall defaultSettings(); // sets editor defaults
        bool bSave;  //checks if editor should save before assemble
        int iSelStart;
};
//---------------------------------------------------------------------------
extern PACKAGE TOptions *Options;
//---------------------------------------------------------------------------
#endif
