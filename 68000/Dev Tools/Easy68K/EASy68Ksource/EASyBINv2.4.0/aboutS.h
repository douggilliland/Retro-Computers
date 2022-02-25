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
//----------------------------------------------------------------------------
class TAboutFrm : public TForm
{
__published:
	TPanel *Panel1;
	TImage *ProgramIcon;
        TLabel *Title;
	TLabel *Copyright;
	TLabel *Comments;
	TButton *OKButton;
        TLabel *Label1;
        TLabel *Label5;
        TLabel *Label4;
        void __fastcall FormShow(TObject *Sender);
        void __fastcall FormKeyDown(TObject *Sender, WORD &Key,
          TShiftState Shift);
private:
public:
	virtual __fastcall TAboutFrm(TComponent* AOwner);
};
//----------------------------------------------------------------------------
extern PACKAGE TAboutFrm *AboutFrm;
//----------------------------------------------------------------------------
#endif    
