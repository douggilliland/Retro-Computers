//---------------------------------------------------------------------------
//   Author: Chuck Kelly,
//           http://www.easy68k.com
//---------------------------------------------------------------------------
// File Name: EASyBIN.cpp
// WinMain().
// EASyBIN binary file creation and editing utility for EASy68K
//---------------------------------------------------------------------------

#include <vcl.h>
#include <windows.h>
#include <dstring.h>

#pragma hdrstop
USEFORM("Form1u.cpp", Form1);
USEFORM("aboutS.cpp", AboutFrm);
//---------------------------------------------------------------------------
WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
{
  try{
    Application->Initialize();
    Application->Title = "EASyBIN";
                 Application->CreateForm(__classid(TForm1), &Form1);
                 Application->CreateForm(__classid(TAboutFrm), &AboutFrm);
                 Application->Run();
  }catch (Exception &exception){
    Application->ShowException(&exception);
  }
  return 0;
}
//---------------------------------------------------------------------------
