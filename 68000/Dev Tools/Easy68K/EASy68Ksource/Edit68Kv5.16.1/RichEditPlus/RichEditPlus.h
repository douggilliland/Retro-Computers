//---------------------------------------------------------------------------

#ifndef RichEditPlusH
#define RichEditPlusH
//---------------------------------------------------------------------------
#include <SysUtils.hpp>
#include <Classes.hpp>
#include <ComCtrls.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
//---------------------------------------------------------------------------
class PACKAGE TRichEditPlus : public TRichEdit
{
private:
    TNotifyEvent FOnVertScroll; 
    MESSAGE void __fastcall CNCommand(TMessage &Msg);
    MESSAGE void __fastcall WMVScroll(TMessage &Msg);

//---------------------------------------------------------------------------
// Used to respond to Vertical Scroll messages.
protected:
    virtual void __fastcall CreateWnd();

//---------------------------------------------------------------------------
public:
    __fastcall TRichEditPlus(TComponent* Owner);

//---------------------------------------------------------------------------
// Used to respond to Vertical Scroll messages.
__published:
    __property TNotifyEvent OnVertScroll =
        {read = FOnVertScroll, write = FOnVertScroll};

//---------------------------------------------------------------------------
// Used to respond to Vertical Scroll messages.
BEGIN_MESSAGE_MAP
    MESSAGE_HANDLER(CN_COMMAND, TMessage, CNCommand)
    MESSAGE_HANDLER(WM_VSCROLL, TMessage, WMVScroll)
END_MESSAGE_MAP(TRichEdit);
};
//---------------------------------------------------------------------------
#endif
