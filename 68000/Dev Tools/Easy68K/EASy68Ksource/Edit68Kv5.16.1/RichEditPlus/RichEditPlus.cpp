//---------------------------------------------------------------------------
// Create by: Chuck Kelly
// Description: RichEditPlus adds Vertical Scroll events to the standard
// RichEdit control.
//
#include <vcl.h>

#pragma hdrstop

#include "RichEditPlus.h"
#pragma package(smart_init)
//---------------------------------------------------------------------------
// ValidCtrCheck is used to assure that the components created do not have
// any pure virtual functions.
//

static inline void ValidCtrCheck(TRichEditPlus *)
{
        new TRichEditPlus(NULL);
}
//---------------------------------------------------------------------------
__fastcall TRichEditPlus::TRichEditPlus(TComponent* Owner)
        : TRichEdit(Owner)
{
}
//---------------------------------------------------------------------------
namespace Richeditplus
{
  void __fastcall PACKAGE Register()
  {
    TComponentClass classes[1] = {__classid(TRichEditPlus)};
    RegisterComponents("Win32", classes, 0);
  }
}

//---------------------------------------------------------------------------
// The three following functions: CreateWnd, CNCommand and WMVScroll
// Are used to respond to Vertical Scroll messages.
//---------------------------------------------------------------------------
void __fastcall TRichEditPlus::CreateWnd()
{
  TRichEdit::CreateWnd();
  DWORD dwMask = SNDMSG(Handle, EM_GETEVENTMASK, 0, 0);
  dwMask = dwMask | ENM_SCROLL;
  SNDMSG(Handle, EM_SETEVENTMASK, 0, dwMask);
}
//---------------------------------------------------------------------------
void __fastcall TRichEditPlus::CNCommand(TMessage &Msg)
{
  TRichEdit::Dispatch(&Msg);
  if (Msg.WParamHi == EN_VSCROLL)
  {
    if (FOnVertScroll) FOnVertScroll(this);
  }
}
//---------------------------------------------------------------------------
void __fastcall TRichEditPlus::WMVScroll(TMessage &Msg)
{
  TRichEdit::Dispatch(&Msg);
  if (FOnVertScroll) FOnVertScroll(this);
}
//---------------------------------------------------------------------------



