//---------------------------------------------------------------------------

#ifndef listSH
#define listSH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ComCtrls.hpp>
#include <ExtCtrls.hpp>
//---------------------------------------------------------------------------
class TListFile : public TForm
{
__published:	// IDE-managed Components
        TRichEdit *List;
        TSplitter *Splitter1;
        void __fastcall FormClose(TObject *Sender, TCloseAction &Action);
        void __fastcall ListKeyDown(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall ListKeyPress(TObject *Sender, char &Key);
        void __fastcall ListKeyUp(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall ListMouseUp(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
        void __fastcall ListMouseDown(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
private:	// User declarations
public:		// User declarations
        __fastcall TListFile(TComponent* Owner);
        TPoint CurPos;
};
//---------------------------------------------------------------------------
extern PACKAGE TListFile *ListFile;
//---------------------------------------------------------------------------
#endif
