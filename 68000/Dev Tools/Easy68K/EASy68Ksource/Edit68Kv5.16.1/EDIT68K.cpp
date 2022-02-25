//---------------------------------------------------------------------------
//   Author: Charles Kelly,
//           Monroe County Community College
//           http://www.monroeccc.edu/ckelly
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop
USEFORM("textS.cpp", TextStuff);
USEFORM("aboutS.cpp", AboutBox);
USEFORM("assembleS.cpp", AssemblerBox);
USEFORM("chksaveS.cpp", ChkSave);
USEFORM("mainS.cpp", Main);
USEFORM("optionsS.cpp", Options);
USEFORM("editorOptions.cpp", EditorOptionsForm);
USEFORM("findDialogS.cpp", findDialogFrm);
USEFORM("replaceDialogS.cpp", replaceDialogFrm);
//---------------------------------------------------------------------------
WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
{
        try
        {
                 Application->Initialize();
                 Application->Title = "EASy68K";
                 Application->CreateForm(__classid(TMain), &Main);
                 Application->CreateForm(__classid(TAboutBox), &AboutBox);
                 Application->CreateForm(__classid(TAssemblerBox), &AssemblerBox);
                 Application->CreateForm(__classid(TChkSave), &ChkSave);
                 Application->CreateForm(__classid(TOptions), &Options);
                 Application->CreateForm(__classid(TEditorOptionsForm), &EditorOptionsForm);
                 Application->CreateForm(__classid(TfindDialogFrm), &findDialogFrm);
                 Application->CreateForm(__classid(TreplaceDialogFrm), &replaceDialogFrm);
                 Application->Run();
        }
        catch (Exception &exception)
        {
                 Application->ShowException(&exception);
        }
        return 0;
}
//---------------------------------------------------------------------------
