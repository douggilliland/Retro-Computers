//---------------------------------------------------------------------------

#ifndef editorOptionsH
#define editorOptionsH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include "CSPIN.h"
#include <ExtCtrls.hpp>
#include <ComCtrls.hpp>
//---------------------------------------------------------------------------
class TEditorOptionsForm : public TForm
{
__published:	// IDE-managed Components
        TButton *cmdOK;
        TButton *cmdCancel;
        TButton *cmdHelp;
        TPageControl *OptionsTabs;
        TTabSheet *General;
        TGroupBox *NewSettings;
        TLabel *Label1;
        TLabel *Label2;
        TLabel *Label5;
        TComboBox *cbFont;
        TComboBox *cbSize;
        TCSpinEdit *FixedTabSize;
        TRadioButton *AssemblyTabs;
        TRadioButton *FixedTabs;
        TGroupBox *ActiveInfo;
        TLabel *Label3;
        TLabel *Label4;
        TLabel *Label6;
        TLabel *Label7;
        TLabel *CurrentFont;
        TLabel *CurrentFontSize;
        TLabel *CurrentTabSize;
        TLabel *CurrentTabType;
        TGroupBox *Environment;
        TCheckBox *AutoIndent;
        TCheckBox *RealTabs;
        TTabSheet *Colors;
        TGroupBox *ColorBos;
        TStaticText *StaticText1;
        TStaticText *StaticText2;
        TStaticText *StaticText3;
        TStaticText *StaticText4;
        TStaticText *StaticText5;
        TStaticText *StaticText6;
        TStaticText *StaticText7;
        TStaticText *StaticText8;
        TStaticText *StaticText9;
        TStaticText *StaticText10;
        TStaticText *StaticText11;
        TStaticText *StaticText12;
        TStaticText *StaticText13;
        TStaticText *StaticText14;
        TStaticText *StaticText15;
        TStaticText *StaticText16;
        TListBox *Element;
        TLabel *Label8;
        TGroupBox *TextAttributes;
        TCheckBox *Bold;
        TCheckBox *Italic;
        TCheckBox *Underline;
        TPanel *Panel1;
        TLabel *commentLbl;
        TLabel *labelLbl;
        TLabel *errorLbl;
        TLabel *codeLbl;
        TLabel *structuredLbl;
        TLabel *otherLbl;
        TLabel *directiveLbl;
        TLabel *textLbl;
        TComboBox *SyntaxCombo;
        TLabel *Label9;
        TCheckBox *PrintBlack;
        TLabel *Label10;
        void __fastcall cmdCancelClick(TObject *Sender);
        void __fastcall cmdOKClick(TObject *Sender);
        void __fastcall FormShow(TObject *Sender);
        void __fastcall cbFontChange(TObject *Sender);
        void __fastcall FormKeyDown(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall AutoIndentClick(TObject *Sender);
        void __fastcall AutoIndentKeyPress(TObject *Sender, char &Key);
        void __fastcall RealTabsClick(TObject *Sender);
        void __fastcall RealTabsKeyPress(TObject *Sender, char &Key);
        void __fastcall cmdHelpClick(TObject *Sender);
        void __fastcall StaticTextClick(TObject *Sender);
        void __fastcall ItalicClick(TObject *Sender);
        void __fastcall UnderlineClick(TObject *Sender);
        void __fastcall ElementClick(TObject *Sender);
        void __fastcall BoldClick(TObject *Sender);
        void __fastcall FormClose(TObject *Sender, TCloseAction &Action);
        void __fastcall SyntaxComboChange(TObject *Sender);
private:	// User declarations
public:		// User declarations
        __fastcall TEditorOptionsForm(TComponent* Owner);
        void __fastcall setSyntaxPreviewColor(TColor color);
        void __fastcall setSyntaxPreviewStyle();
        void __fastcall highlightPreview();
};
//---------------------------------------------------------------------------
extern PACKAGE TEditorOptionsForm *EditorOptionsForm;
//---------------------------------------------------------------------------
#endif
