//---------------------------------------------------------------------------
//   Author: Charles Kelly,
//           Monroe County Community College
//           http://www.monroeccc.edu/ckelly
//---------------------------------------------------------------------------

#include <vcl.h>
#include <fstream.h>
#pragma hdrstop

#include "asm.h"
#include "optionsS.h"
#include "mainS.h"
#include "textS.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TOptions *Options;

extern bool listFlag;           // create Listing file
extern bool objFlag;            // create S-Record file
extern bool CEXflag;            // expand constants
extern bool BITflag;            // True to assemble bitfield instructions
extern bool CREflag;            // display symbol table in listing
extern bool MEXflag;            // macro expansion
extern bool SEXflag;            // structured assembly expansion
extern bool WARflag;            // Show Warnings
extern tabTypes tabType;
extern bool maximizedEdit;      // true starts child edit window maximized
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
extern bool highlightDisabled;

//---------------------------------------------------------------------------
__fastcall TOptions::TOptions(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TOptions::cmdCancelClick(TObject *Sender)
{
  Options->Close();
}
//-----------------------------------------------------------------------------
void __fastcall TOptions::cmdOKClick(TObject *Sender)
{
  AnsiString msgbuff = "You have unchecked options that are required for use "
                       "by the 68000 simulator Sim68K.  Without these options"
                       " many features of Sim68K will be unavailable.  Do you"
                       " wish to continue?";
  TMsgDlgButtons temp_set;
  temp_set << mbYes << mbNo; //flags for msgdialog

  //check for reccommened options
  if(!chkGenSRec->Checked || !chkGenList->Checked)
  {
    int ret = MessageDlg(msgbuff,mtInformation,temp_set,0);

    if(ret == mrYes)
    {
      //update all assembler flags
      listFlag = chkGenList->Checked;
      objFlag  = chkGenSRec->Checked;
      CEXflag  = chkConstantsEx->Checked;
      BITflag  = chkBitfield->Checked;
      CREflag  = chkCrossRef->Checked;
      MEXflag  = chkMacEx->Checked;
      SEXflag  = chkStrucEx->Checked;
      bSave    = chkSave->Checked;
      WARflag  = chkShowWarnings->Checked;

      SaveSettings();
      Options->Close();
    }
    else  //user didn't want to save those settings so check the recommended settings
    {
      chkGenList->Checked = true;
      chkGenSRec->Checked = true;
    }
  }
  else
  {
    //update all assembler flags
    listFlag = chkGenList->Checked;
    objFlag  = chkGenSRec->Checked;
    CEXflag  = chkConstantsEx->Checked;
    BITflag  = chkBitfield->Checked;
    CREflag  = chkCrossRef->Checked;
    MEXflag  = chkMacEx->Checked;
    SEXflag  = chkStrucEx->Checked;
    bSave    = chkSave->Checked;
    WARflag  = chkShowWarnings->Checked;

    SaveSettings();
    Options->Close();
  }
}
//---------------------------------------------------------------------------

void __fastcall TOptions::FormShow(TObject *Sender)
{
  PageControl->ActivePageIndex = 0;  //first sheet is default

  //load up template
  if (FileExists(ExtractFilePath(Application->ExeName) + "template.NEW"))
    Template->Lines->LoadFromFile
                      (ExtractFilePath(Application->ExeName) + "template.NEW");

  Template->Font->Name = EditorOptionsForm->cbFont->Text;
  Template->Font->Size = StrToInt(EditorOptionsForm->cbSize->Text);
  Template->Modified = false;

}
//---------------------------------------------------------------------------


void __fastcall TOptions::SaveClick(TObject *Sender)
{
  Template->Lines->SaveToFile(
                ExtractFilePath(Application->ExeName) + "template.NEW");
}
//---------------------------------------------------------------------------


void __fastcall TOptions::SaveSettings()
//saves editor settings to file, true  & false  settings are saved as 1 and 0
{
   maximizedEdit = false;
  //grab active mdi child
  TTextStuff *Active = (TTextStuff*)Main->ActiveMDIChild;
  if (Active) {
    if (Active->WindowState == wsMaximized)
      maximizedEdit = true;
  }

  try {
    AnsiString str;
    str = ExtractFilePath(Application->ExeName) + "settings.dat";
    char fileName[256];
    strcpy(fileName, str.c_str());        // fileName is path + settings.dat
    ofstream File(fileName);              //open settings file
    if (EditorOptionsForm->AssemblyTabs->Checked)
      tabType = Assembly;
    else
      tabType = Fixed;

    //save all assembler and editor flags
    File << "$Settings for " << TITLE << "  DO NOT EDIT THIS FILE!!!!\n"
         << listFlag                                    << "$generate list\n"
         << objFlag                                     << "$generate s-record\n"
         << bSave                                       << "$save then assemble\n"
         << chkShowWarnings->Checked                    << "$show warnings\n"
         << chkCrossRef->Checked                        << "$cross reference\n"
         << chkMacEx->Checked                           << "$macros expanded\n"
         << chkStrucEx->Checked                         << "$structured expand\n"
         << chkConstantsEx->Checked                     << "$constants expand\n"
         << EditorOptionsForm->cbFont->Text.c_str()     << "$font name\n"
         << EditorOptionsForm->cbSize->Text.c_str()     << "$font size\n"
         << tabType                                     << "$tab type\n"
         << EditorOptionsForm->FixedTabSize->Value      << "$fixed tab size\n"
         << maximizedEdit                               << "$maximized edit\n"
         << autoIndent                                  << "$auto indent\n"
         << realTabs                                    << "$real tabs\n"
         << chkBitfield->Checked                        << "$assemble bit field\n"
         << Main->Top                                   << "$main top\n"
         << Main->Left                                  << "$main left\n"
         << Main->Height                                << "$main height\n"
         << Main->Width                                 << "$main width\n"
         << codeStyle.color                             << "$code color\n"
         << codeStyle.bold                              << "$code bold\n"
         << codeStyle.italic                            << "$code italic\n"
         << codeStyle.underline                         << "$code underline\n"
         << unknownStyle.color                          << "$unknown color\n"
         << unknownStyle.bold                           << "$unknown bold\n"
         << unknownStyle.italic                         << "$unknown italic\n"
         << unknownStyle.underline                      << "$unknown underline\n"
         << directiveStyle.color                        << "$directive color\n"
         << directiveStyle.bold                         << "$directive bold\n"
         << directiveStyle.italic                       << "$directive italic\n"
         << directiveStyle.underline                    << "$directive underline\n"
         << commentStyle.color                          << "$comment color\n"
         << commentStyle.bold                           << "$comment bold\n"
         << commentStyle.italic                         << "$comment italic\n"
         << commentStyle.underline                      << "$comment underline\n"
         << labelStyle.color                            << "$label color\n"
         << labelStyle.bold                             << "$label bold\n"
         << labelStyle.italic                           << "$label italic\n"
         << labelStyle.underline                        << "$label underline\n"
         << structureStyle.color                        << "$structure color\n"
         << structureStyle.bold                         << "$structure bold\n"
         << structureStyle.italic                       << "$structure italic\n"
         << structureStyle.underline                    << "$structure underline\n"
         << errorStyle.color                            << "$error color\n"
         << errorStyle.bold                             << "$error bold\n"
         << errorStyle.italic                           << "$error italic\n"
         << errorStyle.underline                        << "$error underline\n"
         << textStyle.color                             << "$text color\n"
         << textStyle.bold                              << "$text bold\n"
         << textStyle.italic                            << "$text italic\n"
         << textStyle.underline                         << "$text underline\n"
         << highlightDisabled                           << "$highlight disabled\n"
         << EditorOptionsForm->PrintBlack->Checked      << "$print w/black\n"
         << backColor                                   << "$background color\n"
         << EditorOptionsForm->SyntaxCombo->ItemIndex   << "$color presets\n";

    File.close();
  }
  catch( ... ) {
    MessageDlg("Error saving editor settings",mtInformation, TMsgDlgButtons() << mbOK,0);
    return;
  }
}

//--------------------------------------------------------------------------
// Loads all the editor settings from file.  True and false settings are saved
//  as 1 and 0.
//  If the contents of settings.dat to not match expected then default values
//  are used.
void __fastcall TOptions::LoadSettings()
{
  try {
    const int SIZE = 256;
    AnsiString str;
    str = ExtractFilePath(Application->ExeName) + "settings.dat";
    char fileName[SIZE];
    strcpy(fileName, str.c_str());        // fileName is path + settings.dat

    defaultSettings();          // start with default settings

    if(FileExists(fileName))    //check if settings file exists
    {                           //if it did then load all the settings
      char buffer[SIZE+1];
      char temp[SIZE+1];        //temp storage
      unsigned int index;       //looping index
      ifstream File(fileName);  //open settings file

      // read and set flags from file
      File.getline(buffer, SIZE); //first line contains version number

      File.getline(buffer, SIZE); // 'generate list' setting
      if (!strcmp(&buffer[1],"$generate list")) {   // if expected setting
        if(buffer[0] == '1') {
          listFlag = true;
          chkGenList->Checked = true;
        } else {
          listFlag   = false;
          chkGenList->Checked = false;
        }
      }

      File.getline(buffer, SIZE); // 'generate s-record' setting
      if (!strcmp(&buffer[1],"$generate s-record")) {   // if expected setting
        if(buffer[0] == '1') {
          objFlag = true;
          chkGenSRec->Checked = true;
        } else {
          objFlag    = false;
          chkGenSRec->Checked = false;
        }
      }

      File.getline(buffer, SIZE); // 'save before assemble' setting
      if (!strcmp(&buffer[1],"$save then assemble")) {  // if expected setting
        if(buffer[0] == '1') {
          bSave = true;
          chkSave->Checked = true;
        } else {
          bSave      = false;
          chkSave->Checked = false;
        }
      }

      File.getline(buffer, SIZE); // 'Show Warnings' setting
      if (!strcmp(&buffer[1],"$show warnings")) {  // if expected setting
        if(buffer[0] == '1') {
          WARflag = true;
          chkShowWarnings->Checked = true;
        } else {
          WARflag    = false;
          chkShowWarnings->Checked = false;
        }
      }

      File.getline(buffer, SIZE); // 'cross reference' setting
      if (!strcmp(&buffer[1],"$cross reference")) {  // if expected setting
        if(buffer[0] == '1') {
          CREflag = true;
          chkCrossRef->Checked = true;
        } else {
          CREflag    = false;
          chkCrossRef->Checked = false;
        }
      }

      File.getline(buffer, SIZE); // 'macro expanded setting' setting
      if (!strcmp(&buffer[1],"$macros expanded")) {  // if expected setting
        if(buffer[0] == '1') {
          MEXflag = true;
          chkMacEx->Checked = true;
        } else {
          MEXflag    = false;
          chkMacEx->Checked = false;
        }
      }

      File.getline(buffer, SIZE); // 'structured assembly expanded setting' setting
      if (!strcmp(&buffer[1],"$structured expand")) {  // if expected setting
        if(buffer[0] == '1') {
          SEXflag = true;
          chkStrucEx->Checked = true;
        } else {
          SEXflag    = false;
          chkStrucEx->Checked = false;
        }
      }

      File.getline(buffer, SIZE); // 'constants expanded setting' setting
      if (!strcmp(&buffer[1],"$constants expand")) {  // if expected setting
        if(buffer[0] == '1') {
          CEXflag = true;
          chkConstantsEx->Checked = true;
        } else {
          CEXflag    = false;
          chkConstantsEx->Checked = false;
        }
      }

      index = 0;
      File.getline(buffer, SIZE);        // 'font name' setting
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$font name")) {  // if expected setting
        EditorOptionsForm->cbFont->Text = temp;
      }

      File.getline(buffer, SIZE);        // 'font size' setting
      index = 0;                       //reset looping index
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$font size")) {  // if expected setting
        EditorOptionsForm->cbSize->Text = temp;
      }

      File.getline(buffer, SIZE);        // Tab Type setting
      if (!strcmp(&buffer[1],"$tab type")) {  // if expected setting
        if(buffer[0] == '0') {
          EditorOptionsForm->AssemblyTabs->Checked = true;
          EditorOptionsForm->FixedTabs->Checked = false;
          tabType = Assembly;
        } else {
          EditorOptionsForm->AssemblyTabs->Checked = false;
          EditorOptionsForm->FixedTabs->Checked = true;
          tabType = Fixed;
        }
      }

      File.getline(buffer, SIZE);         // Fixed Tab Size
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$fixed tab size")) {  // if expected setting
        EditorOptionsForm->FixedTabSize->Value = atoi(temp);
      }

      File.getline(buffer, SIZE);        // maximizedEdit setting
      if (!strcmp(&buffer[1],"$maximized edit")) {  // if expected setting
        if(buffer[0] == '1') {
          maximizedEdit = true;
        } else {
          maximizedEdit = false;
        }
      }

      File.getline(buffer, SIZE);        // autoIndent setting
      if (!strcmp(&buffer[1],"$auto indent")) {  // if expected setting
        if(buffer[0] == '1') {
          autoIndent = true;
          EditorOptionsForm->AutoIndent->Checked = true;
        } else {
          autoIndent = false;
          EditorOptionsForm->AutoIndent->Checked = false;
        }
      }

      File.getline(buffer, SIZE);        // realTabs setting
      if (!strcmp(&buffer[1],"$real tabs")) {  // if expected setting
        if(buffer[0] == '1') {
          realTabs = true;
          EditorOptionsForm->RealTabs->Checked = true;
        } else {
          realTabs = false;
          EditorOptionsForm->RealTabs->Checked = false;
        }
      }

      File.getline(buffer, SIZE);        // Bitfield setting
      if (!strcmp(&buffer[1],"$assemble bit field")) {  // if expected setting
        if(buffer[0] == '1') {
          BITflag = true;
          chkBitfield->Checked = true;
        } else {
          BITflag    = false;
          chkBitfield->Checked = false;
        }
      }

      File.getline(buffer, SIZE);         // 'Main Form Top' setting
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$main top")) {  // if expected setting
        Main->Top = atoi(temp);
      }

      File.getline(buffer, SIZE);         // 'Main Form Left' setting
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$main left")) {  // if expected setting
        Main->Left = atoi(temp);
      }

      File.getline(buffer, SIZE);         // 'Main Form Height' setting
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$main height")) {  // if expected setting
        Main->Height = atoi(temp);
      }

      File.getline(buffer, SIZE);         // 'Main Form Width' setting
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$main width")) {  // if expected setting
        Main->Width = atoi(temp);
      }

      // Syntax Highlight stuff
      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$code color")) {  // if expected setting
        codeStyle.color = (TColor)atoi(temp);
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$code bold")) {  // if expected setting
        codeStyle.bold = atoi(temp);
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$code italic")) {  // if expected setting
        codeStyle.italic = atoi(temp);
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$code underline")) {  // if expected setting
        codeStyle.underline = atoi(temp);
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$unknown color")) {  // if expected setting
        unknownStyle.color = (TColor)atoi(temp);
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$unknown bold")) {  // if expected setting
        unknownStyle.bold = atoi(temp);
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$unknown italic")) {  // if expected setting
        unknownStyle.italic = atoi(temp);
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$unknown underline")) {  // if expected setting
        unknownStyle.underline = atoi(temp);
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$directive color")) {  // if expected setting
        directiveStyle.color = (TColor)atoi(temp);
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$directive bold")) {  // if expected setting
        directiveStyle.bold = atoi(temp);
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$directive italic")) {  // if expected setting
        directiveStyle.italic = atoi(temp);
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$directive underline")) {  // if expected setting
        directiveStyle.underline = atoi(temp);
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$comment color")) {  // if expected setting
        commentStyle.color = (TColor)atoi(temp);
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$comment bold")) {  // if expected setting
        commentStyle.bold = atoi(temp);
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$comment italic")) {  // if expected setting
        commentStyle.italic = atoi(temp);
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$comment underline")) {  // if expected setting
        commentStyle.underline = atoi(temp);
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$label color")) {  // if expected setting
        labelStyle.color = (TColor)atoi(temp);
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$label bold")) {  // if expected setting
        labelStyle.bold = atoi(temp);
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$label italic")) {  // if expected setting
        labelStyle.italic = atoi(temp);
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$label underline")) {  // if expected setting
        labelStyle.underline = atoi(temp);
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$structure color")) {  // if expected setting
        structureStyle.color = (TColor)atoi(temp);
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$structure bold")) {  // if expected setting
        structureStyle.bold = atoi(temp);
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$structure italic")) {  // if expected setting
        structureStyle.italic = atoi(temp);
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$structure underline")) {  // if expected setting
        structureStyle.underline = atoi(temp);
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$error color")) {  // if expected setting
        errorStyle.color = (TColor)atoi(temp);
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$error bold")) {  // if expected setting
        errorStyle.bold = atoi(temp);
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$error italic")) {  // if expected setting
        errorStyle.italic = atoi(temp);
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$error underline")) {  // if expected setting
        errorStyle.underline = atoi(temp);
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$text color")) {  // if expected setting
        textStyle.color = (TColor)atoi(temp);
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$text bold")) {  // if expected setting
        textStyle.bold = atoi(temp);
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$text italic")) {  // if expected setting
        textStyle.italic = atoi(temp);
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$text underline")) {  // if expected setting
        textStyle.underline = atoi(temp);
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$highlight disabled")) {  // if expected setting
        highlightDisabled = atoi(temp);
      }

      File.getline(buffer, SIZE);        // Print w/Black
      if (!strcmp(&buffer[1],"$print w/black")) {  // if expected setting
        if(buffer[0] == '1')
          EditorOptionsForm->PrintBlack->Checked = true;
        else
          EditorOptionsForm->PrintBlack->Checked = false;
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$background color")) {  // if expected setting
        backColor = (TColor)atoi(temp);
      }

      File.getline(buffer,SIZE);
      index = 0;
      while(buffer[index] != '$' && index < SIZE)
      {
        temp[index] = buffer[index];
        index++;
      }
      temp[index] = '\0';
      if (!strcmp(&buffer[index],"$color presets")) {  // if expected setting
         EditorOptionsForm->SyntaxCombo->ItemIndex = atoi(temp);
      }

      File.close();
    } // endif
  }
  catch( ... ) {
    MessageDlg("Error loading editor settings",mtInformation, TMsgDlgButtons() << mbOK,0);
    return;
  }
}

//--------------------------------------------------------------------------
void __fastcall TOptions::defaultSettings()
//  default settings
{
  try {
    AnsiString str;
    str = ExtractFilePath(Application->ExeName) + "settings.dat";
    char fileName[256];
    strcpy(fileName, str.c_str());        // fileName is path + settings.dat

    listFlag = chkGenList->Checked;
    objFlag  = chkGenSRec->Checked;
    bSave    = chkSave->Checked;
    WARflag  = chkShowWarnings->Checked;
    CREflag  = chkCrossRef->Checked;
    MEXflag  = chkMacEx->Checked;
    SEXflag  = chkStrucEx->Checked;
    CEXflag  = chkConstantsEx->Checked;
    if (EditorOptionsForm->FixedTabs->Checked)
      tabType = Fixed;
    else
      tabType = Assembly;
    autoIndent = EditorOptionsForm->AutoIndent->Checked;
    realTabs = EditorOptionsForm->RealTabs->Checked;
    BITflag  = chkBitfield->Checked;

    codeStyle.color = DEFAULT_CODE_COLOR;
    codeStyle.bold = false;
    codeStyle.italic = false;
    codeStyle.underline = false;
    unknownStyle.color = DEFAULT_UNKNOWN_COLOR;
    unknownStyle.bold = false;
    unknownStyle.italic = false;
    unknownStyle.underline = false;
    directiveStyle.color = DEFAULT_DIRECTIVE_COLOR;
    directiveStyle.bold = false;
    directiveStyle.italic = false;
    directiveStyle.underline = false;
    commentStyle.color = DEFAULT_COMMENT_COLOR;
    commentStyle.bold = false;
    commentStyle.italic = false;
    commentStyle.underline = false;
    labelStyle.color = DEFAULT_LABEL_COLOR;
    labelStyle.bold = false;
    labelStyle.italic = false;
    labelStyle.underline = false;
    structureStyle.color = DEFAULT_STRUCTURE_COLOR;
    structureStyle.bold = false;
    structureStyle.italic = false;
    structureStyle.underline = false;
    errorStyle.color = DEFAULT_ERROR_COLOR;
    errorStyle.bold = false;
    errorStyle.italic = false;
    errorStyle.underline = false;
    textStyle.color = DEFAULT_TEXT_COLOR;
    textStyle.bold = false;
    textStyle.italic = false;
    textStyle.underline = false;
    highlightDisabled = false;
    backColor = DEFAULT_BACK_COLOR;

  }
  catch( ... ) {
    MessageDlg("Error configuring default editor settings",mtInformation, TMsgDlgButtons() << mbOK,0);
    return;
  }
}

//---------------------------------------------------------------------------

void __fastcall TOptions::FormKeyDown(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
   if (Key == VK_F1)
     Main->displayHelp("EDIT_OPTIONS");
}
//---------------------------------------------------------------------------




