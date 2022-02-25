//---------------------------------------------------------------------------
//   Author: Charles Kelly,
//           Monroe County Community College
//           http://www.monroeccc.edu/ckelly
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "editorOptions.h"
#include "mainS.h"
#include "textS.h"
#include "asm.h"

//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "CSPIN"
#pragma resource "*.dfm"
TEditorOptionsForm *EditorOptionsForm;

extern tabTypes tabType;
extern bool autoIndent;
extern bool realTabs;

extern FontStyle codeStyle;
extern FontStyle unknownStyle;
extern FontStyle directiveStyle;
extern FontStyle commentStyle;
extern FontStyle labelStyle;
extern FontStyle structureStyle;
extern FontStyle errorStyle;
extern FontStyle textStyle;
extern TColor backColor;

FontStyle codeStyleTemp;
FontStyle unknownStyleTemp;
FontStyle directiveStyleTemp;
FontStyle commentStyleTemp;
FontStyle labelStyleTemp;
FontStyle structureStyleTemp;
FontStyle errorStyleTemp;
FontStyle textStyleTemp;
TColor    backColorTemp;

bool inElementClick = false;
bool styleChange = false;
bool syntaxDisabled = false;
extern bool highlightDisabled;

//---------------------------------------------------------------------------
__fastcall TEditorOptionsForm::TEditorOptionsForm(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TEditorOptionsForm::cmdCancelClick(TObject *Sender)
{
  Close();
}

//---------------------------------------------------------------------------
void __fastcall TEditorOptionsForm::cmdOKClick(TObject *Sender)
{
  AnsiString str;
  TPoint CurPos; //saves the cursor position
  bool modifiedSave;
  TTextStuff *Active;
  int eventMask;
  int selStart, selLength;

  try {

    // Set font for active window only
    Active = (TTextStuff*)Main->ActiveMDIChild;
    //disable all RichEdit events
    eventMask = ::SendMessage(Active->SourceText->Handle,EM_SETEVENTMASK,0,0);
    ::SendMessage(Active->SourceText->Handle,WM_SETREDRAW,false,0);

    selStart = Active->SourceText->SelStart;
    selLength = Active->SourceText->SelLength;
    Active->SourceText->SelectAll();                    // Select all text
    Active->SourceText->SelAttributes->Protected = false;      // turn off protection
    Active->SourceText->SelAttributes->Name = cbFont->Text;
    Active->SourceText->SelAttributes->Size = StrToInt(cbSize->Text);
    Active->SourceText->Font->Name = cbFont->Text;      // set font name
    Active->SourceText->Font->Size = StrToInt(cbSize->Text);

    if (EditorOptionsForm->AssemblyTabs->Checked == true)
      Active->Project.TabType = Assembly;
    else
      Active->Project.TabType = Fixed;

    // limit tab sizes
    if (FixedTabSize->Value < FixedTabSize->MinValue)
      FixedTabSize->Value = FixedTabSize->MinValue;
    else if (FixedTabSize->Value > FixedTabSize->MaxValue )
      FixedTabSize->Value = FixedTabSize->MaxValue;
    // Some users were requesting tab size of 6. By commenting out the following
    // line they will be able to manually enter the number 6 in the tab size
    // text box but the spacing will not be correct for all font sizes.
    //FixedTabSize->Value -= (FixedTabSize->Value % FixedTabSize->Increment);

    Active->Project.TabSize = FixedTabSize->Value;
    Active->SourceText->SelectAll();      // Select all text
    Active->SetTabs();                    // set tabs

    ::SendMessage(Active->SourceText->Handle,WM_SETREDRAW,true,0);
    ::InvalidateRect(Active->SourceText->Handle,0,true);

    Active->SourceText->SelectAll();                    // Select all text
    Active->SourceText->SelAttributes->Protected = true;      // protect all text
    Active->SourceText->SelStart = selStart;
    Active->SourceText->SelLength = selLength;
    Active->SourceText->Modified = modifiedSave;  // restore modified

    // enable RichEdit events
    ::SendMessage(Active->SourceText->Handle,EM_SETEVENTMASK,0,eventMask);

    // Set color and syntax style for all text windows
    for (int i = Main->MDIChildCount-1; i >= 0; i--)
    {
      Active = (TTextStuff*)Main->MDIChildren[i];
      modifiedSave = Active->SourceText->Modified;     // save modified

      //disable all RichEdit events
      eventMask = ::SendMessage(Active->SourceText->Handle,EM_SETEVENTMASK,0,0);
      ::SendMessage(Active->SourceText->Handle,WM_SETREDRAW,false,0);

      if (styleChange) {
        highlightDisabled = false;
        // save font styles
        codeStyle = codeStyleTemp;
        unknownStyle = unknownStyleTemp;
        directiveStyle = directiveStyleTemp;
        commentStyle = commentStyleTemp;
        labelStyle = labelStyleTemp;
        structureStyle = structureStyleTemp;
        errorStyle = errorStyleTemp;
        textStyle = textStyleTemp;
        if (syntaxDisabled) {
          Active->SourceText->SelectAll();
          Active->SourceText->SelAttributes->Color = codeStyle.color;
          Active->SourceText->SelAttributes->Style = TFontStyles();   // clear styles
        } else
          Active->colorHighlight(0,Active->SourceText->Lines->Count);
        highlightDisabled = syntaxDisabled;
        backColor = backColorTemp;
        Active->SourceText->Color = backColor;
      }

      // force update
      ::SendMessage(Active->SourceText->Handle,WM_SETREDRAW,true,0);
      ::InvalidateRect(Active->SourceText->Handle,0,true);

      Active->SourceText->SelectAll();                    // Select all text
      Active->SourceText->SelAttributes->Protected = true;      // protect all text
      Active->SourceText->SelStart = selStart;
      Active->SourceText->SelLength = selLength;
      Active->SourceText->Modified = modifiedSave;  // restore modified

      // enable RichEdit events
      ::SendMessage(Active->SourceText->Handle,EM_SETEVENTMASK,0,eventMask);

      Active->UpdateStatusBar();
    }
  } catch( ... ) {
    MessageDlg("Error in NewProject()." ,mtWarning, TMsgDlgButtons() << mbOK,0);
  }

  Close();      // close Editor Options
}

//---------------------------------------------------------------------------
void __fastcall TEditorOptionsForm::FormShow(TObject *Sender)
{
  try {
    //grab active mdi child
    TTextStuff *Active = (TTextStuff*)Main->ActiveMDIChild;
    CurrentFont->Caption = Active->SourceText->Font->Name;
    CurrentFontSize->Caption = IntToStr(Active->SourceText->Font->Size);
    CurrentTabSize->Caption = Active->Project.TabSize;
    if (Active->Project.TabType == Assembly)
      CurrentTabType->Caption = "Assembly";
    else
      CurrentTabType->Caption = "Fixed";

    codeStyleTemp = codeStyle;
    unknownStyleTemp = unknownStyle;
    directiveStyleTemp = directiveStyle;
    commentStyleTemp = commentStyle;
    labelStyleTemp = labelStyle;
    structureStyleTemp = structureStyle;
    errorStyleTemp = errorStyle;
    textStyleTemp = textStyle;
    backColorTemp = backColor;
    if (CurrentFont->Caption == "Courier")
      cbFont->ItemIndex = 0;
    else if(CurrentFont->Caption == "Fixedsys")
      cbFont->ItemIndex = 2;
    else
      cbFont->ItemIndex = 1;

    cbFontChange(Sender);       // preset available font sizes
    highlightPreview();
  } catch( ... ) {
  }

}

//---------------------------------------------------------------------------
void __fastcall TEditorOptionsForm::cbFontChange(TObject *Sender)
{
  try {
  //grab active mdi child
  TTextStuff *Active = (TTextStuff*)Main->ActiveMDIChild;
  int fontSize = Active->SourceText->Font->Size;

  cbSize->Items->Clear();
  if (cbFont->Text == "Fixedsys") {
    cbSize->Items->Add("9");
    cbSize->Items->Add("18");
    if (fontSize < 15)
      cbSize->Text = "9";
    else
      cbSize->Text = "18";
  } else if (cbFont->Text == "Courier") {
    cbSize->Items->Add("10");
    cbSize->Items->Add("12");
    cbSize->Items->Add("15");
    if (fontSize < 12)
      cbSize->Text = "10";
    else if (fontSize < 15)
      cbSize->Text = "12";
    else
      cbSize->Text = "15";
  } else {               // Courier New
    cbSize->Items->Add("8");
    cbSize->Items->Add("9");
    cbSize->Items->Add("10");
    cbSize->Items->Add("11");
    cbSize->Items->Add("12");
    cbSize->Items->Add("14");
    cbSize->Items->Add("16");
    cbSize->Items->Add("18");
    if (fontSize < 12)
      cbSize->Text = "10";
    else if (fontSize < 15)
      cbSize->Text = "12";
    else
      cbSize->Text = "16";
  }
  } catch( ... ) {
  }

}
//---------------------------------------------------------------------------


void __fastcall TEditorOptionsForm::FormKeyDown(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
   if (Key == VK_F1)
     Main->displayHelp("EDIT_OPTIONS");

}
//---------------------------------------------------------------------------

void __fastcall TEditorOptionsForm::AutoIndentClick(TObject *Sender)
{
  autoIndent = AutoIndent->Checked;
}
//---------------------------------------------------------------------------

void __fastcall TEditorOptionsForm::AutoIndentKeyPress(TObject *Sender,
      char &Key)
{
  autoIndent = AutoIndent->Checked;
}
//---------------------------------------------------------------------------

void __fastcall TEditorOptionsForm::RealTabsClick(TObject *Sender)
{
  realTabs = RealTabs->Checked;
}
//---------------------------------------------------------------------------

void __fastcall TEditorOptionsForm::RealTabsKeyPress(TObject *Sender,
      char &Key)
{
  realTabs = RealTabs->Checked;
}
//---------------------------------------------------------------------------


void __fastcall TEditorOptionsForm::cmdHelpClick(TObject *Sender)
{
  Main->displayHelp("EDIT_OPTIONS");
}
//---------------------------------------------------------------------------



void __fastcall TEditorOptionsForm::StaticTextClick(TObject *Sender)
{
  setSyntaxPreviewColor(dynamic_cast<TStaticText*>(Sender)->Color);
}

//---------------------------------------------------------------------------

void __fastcall TEditorOptionsForm::BoldClick(TObject *Sender)
{
  if (!inElementClick)
    setSyntaxPreviewStyle();
}
//---------------------------------------------------------------------------

void __fastcall TEditorOptionsForm::ItalicClick(TObject *Sender)
{
  if (!inElementClick)
    setSyntaxPreviewStyle();
}
//---------------------------------------------------------------------------

void __fastcall TEditorOptionsForm::UnderlineClick(TObject *Sender)
{
  if (!inElementClick)
    setSyntaxPreviewStyle();
}
//---------------------------------------------------------------------------

void __fastcall TEditorOptionsForm::setSyntaxPreviewColor(TColor color)
{
  try {
  switch(Element->ItemIndex) {
    case 0:     // Code
      codeStyleTemp.color = color;
    break;
    case 1:     // Comment
      commentStyleTemp.color = color;
    break;
    case 2:     // Directive
      directiveStyleTemp.color = color;
    break;
    case 3:     // Label
      labelStyleTemp.color = color;
    break;
    case 4:     // Other
      unknownStyleTemp.color = color;
    break;
    case 5:     // Structured
      structureStyleTemp.color = color;
    break;
    case 6:     // Structure Error
      errorStyleTemp.color = color;
    break;
    case 7:     // Text
      textStyleTemp.color = color;
    break;
    case 8:     // Background
      backColorTemp = color;
    break;
  }
  highlightPreview();
  styleChange = true;
  SyntaxCombo->ItemIndex = 3;   // custom
  syntaxDisabled = false;
  
  } catch( ... ) {
  }

}

//---------------------------------------------------------------------------
void __fastcall TEditorOptionsForm::setSyntaxPreviewStyle()
{
  try {
  switch(Element->ItemIndex) {
    case 0:     // Code
      codeStyleTemp.bold = Bold->Checked;
      codeStyleTemp.italic = Italic->Checked;
      codeStyleTemp.underline = Underline->Checked;
    break;
    case 1:     // Comment
      commentStyleTemp.bold = Bold->Checked;
      commentStyleTemp.italic = Italic->Checked;
      commentStyleTemp.underline = Underline->Checked;
    break;
    case 2:     // Directive
      directiveStyleTemp.bold = Bold->Checked;
      directiveStyleTemp.italic = Italic->Checked;
      directiveStyleTemp.underline = Underline->Checked;
    break;
    case 3:     // Label
      labelStyleTemp.bold = Bold->Checked;
      labelStyleTemp.italic = Italic->Checked;
      labelStyleTemp.underline = Underline->Checked;
    break;
    case 4:     // Other
      unknownStyleTemp.bold = Bold->Checked;
      unknownStyleTemp.italic = Italic->Checked;
      unknownStyleTemp.underline = Underline->Checked;
    break;
    case 5:     // Structured
      structureStyleTemp.bold = Bold->Checked;
      structureStyleTemp.italic = Italic->Checked;
      structureStyleTemp.underline = Underline->Checked;
    break;
    case 6:     // Structure Error
      errorStyleTemp.bold = Bold->Checked;
      errorStyleTemp.italic = Italic->Checked;
      errorStyleTemp.underline = Underline->Checked;
    break;
    case 7:     // Text
      textStyleTemp.bold = Bold->Checked;
      textStyleTemp.italic = Italic->Checked;
      textStyleTemp.underline = Underline->Checked;
    break;
  }
  highlightPreview();
  styleChange = true;
  SyntaxCombo->ItemIndex = 3;   // custom
  syntaxDisabled = false;

  } catch( ... ) {
  }
}

//---------------------------------------------------------------------------
void __fastcall TEditorOptionsForm::ElementClick(TObject *Sender)
{
  try {
  inElementClick = true;
  switch(Element->ItemIndex) {
    case 0:     // Code
      Bold->Checked = codeStyleTemp.bold;
      Italic->Checked = codeStyleTemp.italic;
      Underline->Checked = codeStyleTemp.underline;
    break;
    case 1:     // Comment
      Bold->Checked = commentStyleTemp.bold;
      Italic->Checked = commentStyleTemp.italic;
      Underline->Checked = commentStyleTemp.underline;
    break;
    case 2:     // Directive
      Bold->Checked = directiveStyleTemp.bold;
      Italic->Checked = directiveStyleTemp.italic;
      Underline->Checked = directiveStyleTemp.underline;
    break;
    case 3:     // Label
      Bold->Checked = labelStyleTemp.bold;
      Italic->Checked = labelStyleTemp.italic;
      Underline->Checked = labelStyleTemp.underline;
    break;
    case 4:     // Other
      Bold->Checked = unknownStyleTemp.bold;
      Italic->Checked = unknownStyleTemp.italic;
      Underline->Checked = unknownStyleTemp.underline;
    break;
    case 5:     // Structured
      Bold->Checked = structureStyleTemp.bold;
      Italic->Checked = structureStyleTemp.italic;
      Underline->Checked = structureStyleTemp.underline;
    break;
    case 6:     // Structure Error
      Bold->Checked = errorStyleTemp.bold;
      Italic->Checked = errorStyleTemp.italic;
      Underline->Checked = errorStyleTemp.underline;
    break;
    case 7:     // Text
      Bold->Checked = textStyleTemp.bold;
      Italic->Checked = textStyleTemp.italic;
      Underline->Checked = textStyleTemp.underline;
    break;
  }
//  highlightPreview();
  inElementClick = false;
  } catch( ... ) {
  }

}
//---------------------------------------------------------------------------

void __fastcall TEditorOptionsForm::highlightPreview()
{
  try {
  commentLbl->Font->Color = commentStyleTemp.color;
  commentLbl->Font->Style = TFontStyles();      // clear styles
  if (commentStyleTemp.bold)
    commentLbl->Font->Style = commentLbl->Font->Style << fsBold;
  if (commentStyleTemp.italic)
    commentLbl->Font->Style = commentLbl->Font->Style << fsItalic;
  if (commentStyleTemp.underline)
    commentLbl->Font->Style = commentLbl->Font->Style << fsUnderline;
  labelLbl->Font->Color = labelStyleTemp.color;
  labelLbl->Font->Style = TFontStyles();
  if (labelStyleTemp.bold)
    labelLbl->Font->Style = labelLbl->Font->Style << fsBold;
  if (labelStyleTemp.italic)
    labelLbl->Font->Style = labelLbl->Font->Style << fsItalic;
  if (labelStyleTemp.underline)
    labelLbl->Font->Style = labelLbl->Font->Style << fsUnderline;
  codeLbl->Font->Color = codeStyleTemp.color;
  codeLbl->Font->Style = TFontStyles();
  if (codeStyleTemp.bold)
    codeLbl->Font->Style = codeLbl->Font->Style << fsBold;
  if (codeStyleTemp.italic)
    codeLbl->Font->Style = codeLbl->Font->Style << fsItalic;
  if (codeStyleTemp.underline)
    codeLbl->Font->Style = codeLbl->Font->Style << fsUnderline;
  otherLbl->Font->Color = unknownStyleTemp.color;
  otherLbl->Font->Style = TFontStyles();
  if (unknownStyleTemp.bold)
    otherLbl->Font->Style = otherLbl->Font->Style << fsBold;
  if (unknownStyleTemp.italic)
    otherLbl->Font->Style = otherLbl->Font->Style << fsItalic;
  if (unknownStyleTemp.underline)
    otherLbl->Font->Style = otherLbl->Font->Style << fsUnderline;
  structuredLbl->Font->Color = structureStyleTemp.color;
  structuredLbl->Font->Style = TFontStyles();
  if (structureStyleTemp.bold)
    structuredLbl->Font->Style = structuredLbl->Font->Style << fsBold;
  if (structureStyleTemp.italic)
    structuredLbl->Font->Style = structuredLbl->Font->Style << fsItalic;
  if (structureStyleTemp.underline)
    structuredLbl->Font->Style = structuredLbl->Font->Style << fsUnderline;
  errorLbl->Font->Color = errorStyleTemp.color;
  errorLbl->Font->Style = TFontStyles();
  if (errorStyleTemp.bold)
    errorLbl->Font->Style = errorLbl->Font->Style << fsBold;
  if (errorStyleTemp.italic)
    errorLbl->Font->Style = errorLbl->Font->Style << fsItalic;
  if (errorStyleTemp.underline)
    errorLbl->Font->Style = errorLbl->Font->Style << fsUnderline;
  directiveLbl->Font->Color = directiveStyleTemp.color;
  directiveLbl->Font->Style = TFontStyles();
  if (directiveStyleTemp.bold)
    directiveLbl->Font->Style = directiveLbl->Font->Style << fsBold;
  if (directiveStyleTemp.italic)
    directiveLbl->Font->Style = directiveLbl->Font->Style << fsItalic;
  if (directiveStyleTemp.underline)
    directiveLbl->Font->Style = directiveLbl->Font->Style << fsUnderline;
  textLbl->Font->Color = textStyleTemp.color;
  textLbl->Font->Style = TFontStyles();
  if (textStyleTemp.bold)
    textLbl->Font->Style = textLbl->Font->Style << fsBold;
  if (textStyleTemp.italic)
    textLbl->Font->Style = textLbl->Font->Style << fsItalic;
  if (textStyleTemp.underline)
    textLbl->Font->Style = textLbl->Font->Style << fsUnderline;
  Panel1->Color = backColorTemp;
  } catch( ... ) {
  }

}

//---------------------------------------------------------------------------

void __fastcall TEditorOptionsForm::FormClose(TObject *Sender,
      TCloseAction &Action)
{
  styleChange = false;
}
//---------------------------------------------------------------------------

void __fastcall TEditorOptionsForm::SyntaxComboChange(TObject *Sender)
{
  try {
  Element->ItemIndex = -1;                      // clear item selection
  Bold->Checked = false;
  Italic->Checked = false;
  Underline->Checked = false;
  syntaxDisabled = false;
  if (SyntaxCombo->ItemIndex == 3)      // if Custom
    return;

  codeStyleTemp.bold = false;
  codeStyleTemp.italic = false;
  codeStyleTemp.underline = false;
  unknownStyleTemp.bold = false;
  unknownStyleTemp.italic = false;
  unknownStyleTemp.underline = false;
  directiveStyleTemp.bold = false;
  directiveStyleTemp.italic = false;
  directiveStyleTemp.underline = false;
  commentStyleTemp.bold = false;
  commentStyleTemp.italic = false;
  commentStyleTemp.underline = false;
  labelStyleTemp.bold = false;
  labelStyleTemp.italic = false;
  labelStyleTemp.underline = false;
  structureStyleTemp.bold = false;
  structureStyleTemp.italic = false;
  structureStyleTemp.underline = false;
  errorStyleTemp.bold = false;
  errorStyleTemp.italic = false;
  errorStyleTemp.underline = false;
  textStyleTemp.bold = false;
  textStyleTemp.italic = false;
  textStyleTemp.underline = false;

  switch(SyntaxCombo->ItemIndex) {
    case 0:     // Color 1
      codeStyleTemp.color = DEFAULT_CODE_COLOR;
      unknownStyleTemp.color = DEFAULT_UNKNOWN_COLOR;
      directiveStyleTemp.color = DEFAULT_DIRECTIVE_COLOR;
      commentStyleTemp.color = DEFAULT_COMMENT_COLOR;
      labelStyleTemp.color = DEFAULT_LABEL_COLOR;
      structureStyleTemp.color = DEFAULT_STRUCTURE_COLOR;
      errorStyleTemp.color = DEFAULT_ERROR_COLOR;
      textStyleTemp.color = DEFAULT_TEXT_COLOR;
    break;
    case 1:     // Color 2
      codeStyleTemp.color = DEFAULT_CODE_COLOR;
      unknownStyleTemp.color = clPurple;
      directiveStyleTemp.color = clBlue;
      commentStyleTemp.color = clGreen;
      labelStyleTemp.color = clNavy;
      structureStyleTemp.color = clBlue;
      errorStyleTemp.color = clRed;
      textStyleTemp.color = clMaroon;
    break;
    case 2:     // Mono
      codeStyleTemp.color = DEFAULT_CODE_COLOR;
      unknownStyleTemp.color = DEFAULT_CODE_COLOR;
      directiveStyleTemp.color = DEFAULT_CODE_COLOR;
      commentStyleTemp.color = DEFAULT_CODE_COLOR;
      labelStyleTemp.color = DEFAULT_CODE_COLOR;
      structureStyleTemp.color = DEFAULT_CODE_COLOR;
      errorStyleTemp.color = DEFAULT_CODE_COLOR;
      textStyleTemp.color = DEFAULT_CODE_COLOR;
      unknownStyleTemp.italic = true;
      unknownStyleTemp.underline = true;
      directiveStyleTemp.bold = true;
      commentStyleTemp.italic = true;
      labelStyleTemp.bold = true;
      structureStyleTemp.bold = true;
      errorStyleTemp.underline = true;
    break;
    default:    // Disabled
      codeStyleTemp.color = DEFAULT_CODE_COLOR;
      unknownStyleTemp.color = DEFAULT_CODE_COLOR;
      directiveStyleTemp.color = DEFAULT_CODE_COLOR;
      commentStyleTemp.color = DEFAULT_CODE_COLOR;
      labelStyleTemp.color = DEFAULT_CODE_COLOR;
      structureStyleTemp.color = DEFAULT_CODE_COLOR;
      errorStyleTemp.color = DEFAULT_CODE_COLOR;
      textStyleTemp.color = DEFAULT_CODE_COLOR;
      syntaxDisabled = true;
  }

  highlightPreview();
  styleChange = true;
  } catch( ... ) {
  }

}
//---------------------------------------------------------------------------

