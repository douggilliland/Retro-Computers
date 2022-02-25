//----------------------------------------------------------------------------
#ifndef aboutSH
#define aboutSH
//----------------------------------------------------------------------------
#include <vcl\System.hpp>
#include <vcl\Windows.hpp>
#include <vcl\SysUtils.hpp>
#include <vcl\Classes.hpp>
#include <vcl\Graphics.hpp>
#include <vcl\Forms.hpp>
#include <vcl\Controls.hpp>
#include <vcl\StdCtrls.hpp>
#include <vcl\Buttons.hpp>
#include <vcl\ExtCtrls.hpp>
#include <jpeg.hpp>
#include <NMURL.hpp>
#include <NMHttp.hpp>
#include <Psock.hpp>
//----------------------------------------------------------------------------
class TAboutBox : public TForm
{
__published:
	TPanel *Panel1;
	TImage *ProgramIcon;
        TLabel *Title;
	TLabel *Copyright;
	TLabel *Comments;
	TButton *OKButton;
        TLabel *Label2;
        TLabel *Label3;
        TLabel *Label7;
        TLabel *Label1;
        TImage *img;
        TTimer *Timer1;
        TButton *CheckButton;
        TLabel *VersionLabel;
        TNMHTTP *NMHTTP1;
        void __fastcall FormCreate(TObject *Sender);
        void __fastcall FormKeyPress(TObject *Sender, char &Key);
        void __fastcall Timer1Timer(TObject *Sender);
        void __fastcall Label1Click(TObject *Sender);
        void __fastcall Label1MouseEnter(TObject *Sender);
        void __fastcall Label1MouseLeave(TObject *Sender);
        void __fastcall CheckButtonClick(TObject *Sender);
    void __fastcall NMHTTP1Failure(CmdType Cmd);
    void __fastcall NMHTTP1InvalidHost(bool &Handled);
    void __fastcall NMHTTP1ConnectionFailed(TObject *Sender);
private:
public:
	virtual __fastcall TAboutBox(TComponent* AOwner);
};
//----------------------------------------------------------------------------
extern PACKAGE TAboutBox *AboutBox;
//----------------------------------------------------------------------------
#endif    
