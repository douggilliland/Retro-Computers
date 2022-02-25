//---------------------------------------------------------------------------
//   Author: Charles Kelly
//           www.easy68k.com
//---------------------------------------------------------------------------

#include <vcl.h>
#include <windows.h>
#include <dstring.h>

#include "extern.h"

#pragma hdrstop
USEFORM("SIM68Ku.cpp", Form1);
USEFORM("Stack1.cpp", StackFrm);
USEFORM("Memory1.cpp", MemoryFrm);
USEFORM("BREAKPOINTSu.cpp", BreaksFrm);
USEFORM("aboutS.cpp", AboutFrm);
USEFORM("logU.cpp", Log);
USEFORM("simIOu.cpp", simIO);
USEFORM("Optionsu.cpp", AutoTraceOptions);
USEFORM("hardwareu.cpp", Hardware);
USEFORM("FullscreenOptions.cpp", frmFullscreenOptions);
USEFORM("LogfileDialogu.cpp", LogfileDialog);
USEFORM("findDialogS.cpp", findDialogFrm);
//---------------------------------------------------------------------------
WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
{
  // Find out if we are able to use the multi-monitor APIs
  char SystemDirectory[MAX_PATH];
  DWORD dwShellDllVersion;
  AnsiString User32DLLPath;

  MultimonitorAPIsExist = false;

  if (GetSystemDirectory(SystemDirectory, MAX_PATH)){
    User32DLLPath = static_cast<AnsiString>(SystemDirectory) + "\\User32.dll";
    // test for fully qualified path (dont take this out, big security booch if omitted)
    if (FileExists(User32DLLPath)){

      // get handle to user32.dll
      HANDLE hinstDll = LoadLibrary(TEXT(User32DLLPath.c_str()));

      // if handle is good
      if (hinstDll){
        ChangeDisplaySettingsExAPtr = (CHANGEDISPLAYSETTINGSEXAPROC)GetProcAddress(hinstDll, TEXT("ChangeDisplaySettingsExA"));
        EnumDisplaySettingsExAPtr = (ENUMDISPLAYSETTINGSEXAPROC)GetProcAddress(hinstDll, TEXT("EnumDisplaySettingsExA"));
        EnumDisplayDevicesAPtr = (ENUMDISPLAYDEVICESAPROC)GetProcAddress(hinstDll, TEXT("EnumDisplayDevicesA"));

        if ((ChangeDisplaySettingsExAPtr) && (EnumDisplaySettingsExAPtr) && (EnumDisplayDevicesAPtr)){
          MultimonitorAPIsExist = true;
        }else{
          MultimonitorAPIsExist = false;
        }
      // if user32.dll handle is invalid
      }else{
          MultimonitorAPIsExist = false;
      }
      // close user32.dll handle
      FreeLibrary(hinstDll);

    }else{
      MultimonitorAPIsExist = false;
    }
  }else{
    MultimonitorAPIsExist = false;
  }

  // Find out if we are able to use dsound.dll
  dsoundExist = true;

  if (GetSystemDirectory(SystemDirectory, MAX_PATH)){
    User32DLLPath = static_cast<AnsiString>(SystemDirectory) + "\\dsound.dll";

    // test for fully qualified path (dont take this out, big security booch if omitted)
    if (FileExists(User32DLLPath)){

      // get handle to dsound.dll
      HANDLE hinstDll = LoadLibrary(TEXT(User32DLLPath.c_str()));

      // if handle is invalid
      if (hinstDll == 0)
        dsoundExist = false;

      // close handle
      FreeLibrary(hinstDll);

    }else
      dsoundExist = false;
  }else
    dsoundExist = false;


  try{
    Application->Initialize();
    Application->Title = "SIM68K";
    Application->CreateForm(__classid(TForm1), &Form1);
         Application->CreateForm(__classid(TStackFrm), &StackFrm);
         Application->CreateForm(__classid(TMemoryFrm), &MemoryFrm);
         Application->CreateForm(__classid(TBreaksFrm), &BreaksFrm);
         Application->CreateForm(__classid(TAboutFrm), &AboutFrm);
         Application->CreateForm(__classid(TLog), &Log);
         Application->CreateForm(__classid(TsimIO), &simIO);
         Application->CreateForm(__classid(TAutoTraceOptions), &AutoTraceOptions);
         Application->CreateForm(__classid(THardware), &Hardware);
         Application->CreateForm(__classid(TfrmFullscreenOptions), &frmFullscreenOptions);
         Application->CreateForm(__classid(TLogfileDialog), &LogfileDialog);
         Application->CreateForm(__classid(TfindDialogFrm), &findDialogFrm);
         Application->Run();
  }catch (Exception &exception){
    Application->ShowException(&exception);
  }
  return 0;
}
//---------------------------------------------------------------------------
