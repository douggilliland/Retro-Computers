//---------------------------------------------------------------------------
//   Author: Chuck Kelly,
//           Monroe County Community College
//           http://www.monroeccc.edu/ckelly
//---------------------------------------------------------------------------

#include <vcl.h>
#include <fstream.h>
#pragma hdrstop

#include "logU.h"
#include "SIM68Ku.h"
#include "extern.h"
#include "simIOu.h"
#include "Memory1.h"
#include "Stack1.h"
#include "hardwareu.h"
#include "LogfileDialogu.h"

//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TLog *Log;

extern char ElogFlag;            // log file setting
extern FILE *ElogFile;
extern char OlogFlag;           // Output log file setting
extern FILE *OlogFile;
extern char buffer[256];
//extern bool exceptions;

//Save state of form for restore by Cancel button
int eLogType, oLogType;
AnsiString eLogName, oLogName, memoryFrom, memoryBytes;

//---------------------------------------------------------------------------
__fastcall TLog::TLog(TComponent* Owner)
        : TForm(Owner)
{
}

//---------------------------------------------------------------------------
void __fastcall TLog::ELogOpenBtnClick(TObject *Sender)
{
  // select log file
  if(ELogSaveDlg->Execute())
    ELogFileName->Text = ELogSaveDlg->FileName;
}

//---------------------------------------------------------------------------
void __fastcall TLog::OLogOpenBtnClick(TObject *Sender)
{
  // select log file
  if(OLogSaveDlg->Execute())
    OLogFileName->Text = OLogSaveDlg->FileName;
}

//---------------------------------------------------------------------------
void __fastcall TLog::setLogFileNames(AnsiString name)
{
  // Set ELogFileName & OLogFileName
  if(logging)
  {
    stopLog();              // stop current log
    Application->MessageBox("Current Log Stopped.", "Information", MB_OK);
  }
  ELogFileName->Text = ChangeFileExt(name,"_RunLog.txt");
  OLogFileName->Text = ChangeFileExt(name,"_OutLog.txt");
  if (ElogFlag || OlogFlag) {
    Form1->ToolLogStart->Enabled = true;
    Form1->LogStart->Enabled = true;
  }
}

//---------------------------------------------------------------------------
void __fastcall TLog::OKBtnClick(TObject *Sender)
{
  ElogFlag = ELogType->ItemIndex;
  OlogFlag = OLogType->ItemIndex;
  if (ElogFlag || OlogFlag) {
    Form1->ToolLogStart->Enabled = true;
    Form1->LogStart->Enabled = true;
  }
  Log->Close();
}

//---------------------------------------------------------------------------
void __fastcall TLog::CancelBtnClick(TObject *Sender)
{
  // restore any changes made
  ELogType->ItemIndex = eLogType;
  OLogType->ItemIndex = oLogType;
  ELogFileName->Text = eLogName;
  OLogFileName->Text = oLogName;
  MemFrom->EditText = memoryFrom;
  MemBytes->EditText = memoryBytes;
  // close log window
  Log->Close();
}

//--------------------------------------------------------------------------
// prepare log files
void __fastcall TLog::prepareLogFile()
{
  AnsiString str;
  try {
    Form1->LoggingLbl->Visible = false;       // hide logging label
    AnsiString timeStr = DateTimeToStr(Now()); // date & time to a string

    // Execution logging
    if (ElogFlag)               // if execution log selected
    {
      ElogFile = fopen(ELogFileName->Text.c_str(), "r");  // does file exist
      if (ElogFile) {      // if file exists
        fclose(ElogFile);  // close log file
        LogfileDialog->setMessage("Execution Log File exists!");
        switch(LogfileDialog->ShowModal())       // Replace, Append, Cancel?
        {
          case mrOk:
            ElogFile = fopen(ELogFileName->Text.c_str(), "wt"); // open log file
            break;
          case mrAll:
            ElogFile = fopen(ELogFileName->Text.c_str(), "at"); // append to log file
            break;
          default:
            stopLog();
            return;
        }
      } else {                        // file does not exist
        ElogFile = fopen(ELogFileName->Text.c_str(), "wt"); // open log file
      }
      if (!ElogFile) {                // if file error
        sprintf(buffer,"Can't open log file. Check log file name., Error number %d\n", ElogFile);
        Application->MessageBox(buffer, "Error", MB_OK);
        stopLog();
        Log->Show();            // display log form
        return;
      }
      // label file
      fprintf(ElogFile, "EASy68K execution log file: %s\n\n", timeStr.c_str());
      Form1->LoggingLbl->Visible = true;        // display logging label
      Form1->ToolLogStart->Enabled = false;
      Form1->ToolLogStop->Enabled = true;
      Form1->LogStart->Enabled = false;
      Form1->LogStop->Enabled = true;
      if (ElogFlag == INST_REG_MEM) {           // if logging memory
        str = "0x";
        logMemAddr = StrToInt(str + MemFrom->EditText);   // get address to log
        logMemAddr -= logMemAddr%16;            // force to $10 boundary
        logMemBytes = StrToInt(str + MemBytes->EditText); // get byte count
        logMemBytes += 15;
        logMemBytes -= logMemBytes%16;          // force to increment of $10
      }
    }

    // Output logging
    if (OlogFlag)                       // if output log selected
    {
      OlogFile = fopen(OLogFileName->Text.c_str(), "r");  // does file exist
      if (OlogFile) {      // if file exists
        fclose(OlogFile);  // close log file
        LogfileDialog->setMessage("Output Log File exists!");
        switch(LogfileDialog->ShowModal())       // Replace, Append, Cancel?
        {
          case mrOk:
            OlogFile = fopen(OLogFileName->Text.c_str(), "wb"); // open log file
            break;
          case mrAll:
            OlogFile = fopen(OLogFileName->Text.c_str(), "ab"); // append to log file
            break;
          default:
            stopLog();
            return;
        }
      } else {                        // file does not exist
        OlogFile = fopen(OLogFileName->Text.c_str(), "wb"); // open log file
      }
      if (!OlogFile) {           // if error
        sprintf(buffer,"Can't open log file, error %d\n", OlogFile);
        Application->MessageBox(buffer, "Error", MB_OK);
        stopLog();
        return;
      }
      // label file
      fprintf(OlogFile, "EASy68K output log file: %s\r\n\r\n", timeStr.c_str());
      Form1->LoggingLbl->Visible = true;        // display logging label
      Form1->ToolLogStart->Enabled = false;
      Form1->ToolLogStop->Enabled = true;
      Form1->LogStart->Enabled = false;
      Form1->LogStop->Enabled = true;
    }
    Form1->SaveSettings();
    Log->Close();         // close log window
  }
  catch( ... ) {
    sprintf(buffer, "ERROR 999: An exception occurred in routine 'TLog::OKBtnClick'. \n");
    Application->MessageBox(buffer, "Error", MB_OK);
  }
}

//---------------------------------------------------------------------------
void __fastcall TLog::stopLog()
{
  if (logging) {        // if log in progress
    fclose(ElogFile);   // close log file
    fclose(OlogFile);   // close log file
    logging = false;
    Form1->ToolLogStart->Enabled = true;
    Form1->ToolLogStop->Enabled = false;
    Form1->LogStart->Enabled = true;
    Form1->LogStop->Enabled = false;
    Form1->LoggingLbl->Visible = false;  // hide logging label
  }
}

//---------------------------------------------------------------------------
void __fastcall TLog::stopLogWithAnnounce()
{
  if (logging){
    Application->MessageBox("Current Log Stopped.", "Information", MB_OK);
    stopLog();
  }
}

//---------------------------------------------------------------------------

void __fastcall TLog::startLog()
{
  prepareLogFile();
  logging = true;
  Form1->ToolLogStart->Enabled = false;
  Form1->ToolLogStop->Enabled = true;
  Form1->LogStart->Enabled = false;
  Form1->LogStop->Enabled = true;
}
//---------------------------------------------------------------------------


void __fastcall TLog::FormKeyDown(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
   if (Key == VK_F1)
     Form1->displayHelp("SIM_OPTIONS");
}
//---------------------------------------------------------------------------

void __fastcall TLog::ELogTypeClick(TObject *Sender)
{
  if (ELogType->ItemIndex == INST_REG_MEM) { // if "Instruction, Registers and Memory"
    MemRange->Show();
  }else{
    MemRange->Hide();
  }
}
//---------------------------------------------------------------------------

void __fastcall TLog::MemFromKeyPress(TObject *Sender, char &Key)
{
  if ( (Key >= '0' && Key <= '9') ||
       (toupper(Key) >= 'A' && toupper(Key) <= 'F') )
    Key = toupper(Key);
  else {
    Beep();
    Key = 0;
  }
}
//---------------------------------------------------------------------------

void __fastcall TLog::MemFromExit(TObject *Sender)
{
  AnsiString str = "0x";
  int addr = StrToInt(str + MemFrom->EditText);
  if (addr < 0 || addr >= MEMSIZE)   // if invalid address
    MessageDlg("Invalid Address", mtInformation, TMsgDlgButtons() << mbOK, 0);
}
//---------------------------------------------------------------------------

void __fastcall TLog::FormShow(TObject *Sender)
{
  eLogType = ELogType->ItemIndex;
  oLogType = OLogType->ItemIndex;
  eLogName = ELogFileName->Text;
  oLogName = OLogFileName->Text;
  memoryFrom = MemFrom->EditText;
  memoryBytes = MemBytes->EditText;
}
//---------------------------------------------------------------------------

void __fastcall TLog::addMessage(AnsiString msg)
{
  if (logging && eLogType)
    fprintf(ElogFile, msg.c_str());
  if (logging && oLogType)
    fprintf(OlogFile, msg.c_str());
}
