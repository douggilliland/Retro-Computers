//---------------------------------------------------------------------------

#ifndef hardwareuH
#define hardwareuH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <Buttons.hpp>
#include <ExtCtrls.hpp>
#include <Mask.hpp>
#include "extern.h"             // contains global declarations

//---------------------------------------------------------------------------

class THardware : public TForm
{
__published:	// IDE-managed Components
        TBitBtn *switch7;
        TBitBtn *switch6;
        TBitBtn *switch5;
        TBitBtn *switch4;
        TBitBtn *switch3;
        TBitBtn *switch2;
        TBitBtn *switch1;
        TBitBtn *switch0;
        TPanel *Panel1;
        TShape *LED7;
        TShape *LED6;
        TShape *LED5;
        TShape *LED4;
        TShape *LED3;
        TShape *LED2;
        TShape *LED1;
        TShape *LED0;
        TLabel *Label1;
        TLabel *Label2;
        TLabel *Label3;
        TLabel *Label4;
        TLabel *Label5;
        TLabel *Label6;
        TLabel *Label7;
        TLabel *Label8;
        TPanel *Panel2;
        TShape *seg3a;
        TShape *seg3b;
        TShape *seg3c;
        TShape *seg3d;
        TShape *seg3e;
        TShape *seg3f;
        TShape *seg3g;
        TShape *seg3h;
        TShape *seg2a;
        TShape *seg2f;
        TShape *seg2b;
        TShape *seg2g;
        TShape *seg2e;
        TShape *seg2c;
        TShape *seg2d;
        TShape *seg2h;
        TShape *seg1a;
        TShape *seg1f;
        TShape *seg1b;
        TShape *seg1g;
        TShape *seg1e;
        TShape *seg1c;
        TShape *seg1d;
        TShape *seg1h;
        TShape *seg0a;
        TShape *seg0f;
        TShape *seg0b;
        TShape *seg0g;
        TShape *seg0e;
        TShape *seg0c;
        TShape *seg0d;
        TShape *seg0h;
        TMaskEdit *seg7addr;
        TLabel *Label9;
        TMaskEdit *LEDaddr;
        TLabel *Label10;
        TMaskEdit *switchAddr;
        TLabel *Label11;
        TShape *seg7a;
        TShape *seg7f;
        TShape *seg7b;
        TShape *seg7g;
        TShape *seg7e;
        TShape *seg7c;
        TShape *seg7d;
        TShape *seg7h;
        TShape *seg6a;
        TShape *seg6f;
        TShape *seg6b;
        TShape *seg6g;
        TShape *seg6e;
        TShape *seg6c;
        TShape *seg6d;
        TShape *seg6h;
        TShape *seg5a;
        TShape *seg5f;
        TShape *seg5b;
        TShape *seg5g;
        TShape *seg5e;
        TShape *seg5c;
        TShape *seg5d;
        TShape *seg5h;
        TShape *seg4a;
        TShape *seg4f;
        TShape *seg4b;
        TShape *seg4g;
        TShape *seg4e;
        TShape *seg4c;
        TShape *seg4d;
        TShape *seg4h;
        TGroupBox *GroupBox1;
        TLabel *Label13;
        TLabel *Label14;
        TLabel *Label15;
        TLabel *Label16;
        TLabel *Label17;
        TLabel *Label18;
        TLabel *Label19;
        TSpeedButton *IRQ7Btn;
        TSpeedButton *IRQ6Btn;
        TSpeedButton *IRQ5Btn;
        TSpeedButton *IRQ4Btn;
        TSpeedButton *IRQ3Btn;
        TSpeedButton *IRQ2Btn;
        TSpeedButton *IRQ1Btn;
        TGroupBox *GroupBox2;
        TSpeedButton *ResetBtn;
        TTimer *IRQ1timer;
        TGroupBox *GroupBox3;
        TComboBox *AutoIRQ;
        TLabel *Label20;
        TMaskEdit *IRQinterval;
        TLabel *Label12;
        TMaskEdit *pbAddr;
        TLabel *Label21;
        TBitBtn *pb0;
        TBitBtn *pb1;
        TBitBtn *pb2;
        TBitBtn *pb3;
        TBitBtn *pb4;
        TBitBtn *pb5;
        TBitBtn *pb6;
        TBitBtn *pb7;
        TCheckBox *CheckBox1;
        TCheckBox *CheckBox2;
        TCheckBox *CheckBox3;
        TCheckBox *CheckBox4;
        TCheckBox *CheckBox5;
        TCheckBox *CheckBox6;
        TCheckBox *CheckBox7;
        TLabel *AutoLbl;
        TTimer *IRQ2timer;
        TTimer *IRQ3timer;
        TTimer *IRQ4timer;
        TTimer *IRQ5timer;
        TTimer *IRQ6timer;
        TTimer *IRQ7timer;
        TGroupBox *GroupBox4;
        TLabel *Label22;
        TLabel *Label23;
        TLabel *Label24;
        TLabel *Label25;
        TLabel *Label26;
        TLabel *Label27;
        TCheckBox *ROMChk;
        TCheckBox *ReadChk;
        TCheckBox *ProtectedChk;
        TCheckBox *InvalidChk;
        TLabel *Label28;
        TLabel *Label29;
        TLabel *Label30;
        TLabel *Label31;
        TMaskEdit *MaskEdit9;
        TMaskEdit *MaskEdit10;
        TMaskEdit *MaskEdit11;
        TMaskEdit *MaskEdit12;
        TMaskEdit *ROMStartEdit;
        TMaskEdit *MaskEdit2;
        TMaskEdit *MaskEdit3;
        TMaskEdit *ReadStartEdit;
        TMaskEdit *MaskEdit5;
        TMaskEdit *ProtectedStartEdit;
        TMaskEdit *MaskEdit7;
        TMaskEdit *InvalidStartEdit;
        TMaskEdit *MaskEdit13;
        TMaskEdit *ROMEndEdit;
        TMaskEdit *MaskEdit15;
        TMaskEdit *ReadEndEdit;
        TMaskEdit *MaskEdit17;
        TMaskEdit *ProtectedEndEdit;
        TMaskEdit *MaskEdit19;
        TMaskEdit *InvalidEndEdit;
        void __fastcall switch0Click(TObject *Sender);
        void __fastcall switch1Click(TObject *Sender);
        void __fastcall switch2Click(TObject *Sender);
        void __fastcall switch3Click(TObject *Sender);
        void __fastcall switch4Click(TObject *Sender);
        void __fastcall switch5Click(TObject *Sender);
        void __fastcall switch6Click(TObject *Sender);
        void __fastcall switch7Click(TObject *Sender);
        void __fastcall FormShow(TObject *Sender);
        void __fastcall addrKeyPress(TObject *Sender, char &Key);
        void __fastcall seg7addrChange(TObject *Sender);
        void __fastcall LEDaddrChange(TObject *Sender);
        void __fastcall switchAddrChange(TObject *Sender);
        void __fastcall addrKeyUp(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall IRQ1(TObject *Sender);
        void __fastcall IRQ2(TObject *Sender);
        void __fastcall IRQ3(TObject *Sender);
        void __fastcall IRQ4(TObject *Sender);
        void __fastcall IRQ5(TObject *Sender);
        void __fastcall IRQ6(TObject *Sender);
        void __fastcall IRQ7(TObject *Sender);
        void __fastcall ResetBtnClick(TObject *Sender);
        void __fastcall IRQintervalChange(TObject *Sender);
        void __fastcall AutoIRQChange(TObject *Sender);
        void __fastcall pbAddrChange(TObject *Sender);
        void __fastcall pb0KeyDown(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall pb0MouseDown(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
        void __fastcall pb0MouseUp(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
        void __fastcall pb0KeyUp(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall pb1KeyDown(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall pb1KeyUp(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall pb1MouseDown(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
        void __fastcall pb1MouseUp(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
        void __fastcall pb2KeyDown(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall pb2KeyUp(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall pb2MouseDown(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
        void __fastcall pb2MouseUp(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
        void __fastcall pb3KeyDown(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall pb3KeyUp(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall pb3MouseDown(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
        void __fastcall pb3MouseUp(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
        void __fastcall pb4KeyDown(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall pb4MouseDown(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
        void __fastcall pb4KeyUp(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall pb4MouseUp(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
        void __fastcall pb5KeyDown(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall pb5MouseDown(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
        void __fastcall pb5KeyUp(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall pb5MouseUp(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
        void __fastcall pb6KeyDown(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall pb6MouseDown(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
        void __fastcall pb6KeyUp(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall pb6MouseUp(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
        void __fastcall pb7KeyDown(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall pb7MouseDown(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
        void __fastcall pb7KeyUp(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall pb7MouseUp(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
        void __fastcall pbAddrKeyDown(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall pbAddrExit(TObject *Sender);
        void __fastcall FormCreate(TObject *Sender);
        void __fastcall FormKeyDown(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall CheckBox1Click(TObject *Sender);
        void __fastcall CheckBox2Click(TObject *Sender);
        void __fastcall CheckBox3Click(TObject *Sender);
        void __fastcall CheckBox4Click(TObject *Sender);
        void __fastcall CheckBox5Click(TObject *Sender);
        void __fastcall CheckBox6Click(TObject *Sender);
        void __fastcall CheckBox7Click(TObject *Sender);
        void __fastcall switchAddrExit(TObject *Sender);
        void __fastcall switchAddrKeyDown(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall ROMStartEditChange(TObject *Sender);
        void __fastcall ROMEndEditChange(TObject *Sender);
        void __fastcall ReadStartEditChange(TObject *Sender);
        void __fastcall ReadEndEditChange(TObject *Sender);
        void __fastcall ProtectedStartEditChange(TObject *Sender);
        void __fastcall ProtectedEndEditChange(TObject *Sender);
        void __fastcall InvalidStartEditChange(TObject *Sender);
        void __fastcall InvalidEndEditChange(TObject *Sender);
        void __fastcall ROMChkClick(TObject *Sender);
        void __fastcall ReadChkClick(TObject *Sender);
        void __fastcall ProtectedChkClick(TObject *Sender);
        void __fastcall InvalidChkClick(TObject *Sender);
private:	// User declarations
public:		// User declarations
        __fastcall THardware(TComponent* Owner);
        void __fastcall initialize();
        void __fastcall BringToFront();
        void __fastcall update();
        void __fastcall updateIfNeeded(int);
        void __fastcall autoIRQoff();
        void __fastcall autoIRQon();
        void __fastcall setAutoIRQ(uint irq, uint interval);
        void __fastcall disable();
        void __fastcall enable();
        void __fastcall IRQprocess(int);

};
//---------------------------------------------------------------------------
extern PACKAGE THardware *Hardware;
//---------------------------------------------------------------------------
#endif
