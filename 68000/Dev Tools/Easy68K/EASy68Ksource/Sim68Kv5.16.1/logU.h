//---------------------------------------------------------------------------

#ifndef logUH
#define logUH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <Buttons.hpp>
#include <ExtCtrls.hpp>
#include <Dialogs.hpp>
#include <Mask.hpp>
//---------------------------------------------------------------------------
class TLog : public TForm
{
__published:	// IDE-managed Components
        TRadioGroup *ELogType;
        TEdit *ELogFileName;
        TLabel *Label1;
        TButton *OKBtn;
        TBitBtn *ELogOpenBtn;
        TSaveDialog *ELogSaveDlg;
        TRadioGroup *OLogType;
        TEdit *OLogFileName;
        TBitBtn *OLogOpenBtn;
        TLabel *Label2;
        TSaveDialog *OLogSaveDlg;
        TGroupBox *MemRange;
        TLabel *MemLbl2;
        TMaskEdit *MemFrom;
        TLabel *MemLbl3;
        TMaskEdit *MemBytes;
        TButton *CancelBtn;
        void __fastcall ELogOpenBtnClick(TObject *Sender);
        void __fastcall OKBtnClick(TObject *Sender);
        void __fastcall CancelBtnClick(TObject *Sender);
        void __fastcall OLogOpenBtnClick(TObject *Sender);
        void __fastcall FormKeyDown(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall ELogTypeClick(TObject *Sender);
        void __fastcall MemFromKeyPress(TObject *Sender, char &Key);
        void __fastcall MemFromExit(TObject *Sender);
        void __fastcall FormShow(TObject *Sender);
private:	// User declarations
public:		// User declarations
        __fastcall TLog(TComponent* Owner);
        void __fastcall setLogFileNames(AnsiString name);
        void __fastcall prepareLogFile();
        void __fastcall stopLog();
        void __fastcall stopLogWithAnnounce();
        void __fastcall startLog();
        void __fastcall addMessage(AnsiString msg);


};
//---------------------------------------------------------------------------
extern PACKAGE TLog *Log;
//---------------------------------------------------------------------------
#endif
