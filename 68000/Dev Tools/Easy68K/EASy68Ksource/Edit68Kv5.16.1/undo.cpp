//---------------------------------------------------------------------------
//   Author: Chuck Kelly,
//           Monroe County Community College
//           http://www.monroeccc.edu/ckelly
//   Adapted from the open source WED Windows Editor by: Peter Glen
//---------------------------------------------------------------------------
// Undo/Redo
//
// How it works:
//
// Undo is line based. Information is saved on what we are about to do
// to the buffer, along with current coordinates, and the old line.
//
// The undo routine interprets the instructions, and reapplies the
// transaction. Most of the time it is a simple copy of the undo
// buffer over the old line.
// The cursor is positioned to the undone transaction's place.
//
// A string of transactions are marked as UNDO_BLOCK and we continue
// until an undo event comes without the block undo flag
//
// The UNDO_MARK is used as the begin of undo mark
// The UNDO_NOP is used as the block mark
//
// Undo data format:  undotype, row, col, strlen, string
#include "undo.h"

// global variables for undo/redo
static int prev    = 0;
static int prevrow = 0;
static int prevlen = 0;
bool 	in_undo = false;
bool 	in_redo = false;

//---------------------------------------------------------------------------
// save data so current change may be undone
void SaveUndo(TTextStuff *v1, int typ, int row, int col, AnsiString str)
{
  if (v1 == NULL)
    return;

  AnsiString header;
  int len = str.Length();

  // Same line, small transaction, do not save
  if( prev == UNDO_CHAR && prevrow == row && abs(prevlen - len) < 6 && !in_redo )
    return;

  // Undo field header: undotype, row, col, strlen
  header.sprintf("%d %d %d %d ", typ, row, col, len);

  if(v1->undo->Count > UNDO_LIMIT)
  {
    v1->undo->Delete(0);
    // Signal that it is not full undo
    v1->notfullundo = true;
  }
  v1->undo->Add(header + str);

  prev = typ;
  prevrow = row;
  prevlen = len;
}

//---------------------------------------------------------------------------
// SaveRedo

void SaveRedo(TTextStuff *v1, int typ, int row, int col, AnsiString str)

{
  if (v1 == NULL)
    return;

  AnsiString header;

  header.sprintf("%d %d %d %d ", typ, row, col, str.Length());
  v1->redo->Add(header + str);
}

//---------------------------------------------------------------------------
// Execute undo/redo

void WorkUndo(TTextStuff *v1, int redo)

{
  TStringList *strlist;
  AnsiString  str, str2, action;
  int         ccc, cc, dd, ee, ff;
  bool repeat = false;

  // Atomic ============================
  if(in_undo)
    return;
  in_undo = true;
  // Atomic ============================

  //	v1->Busy(TRUE);
  v1->SourceText->Modified = true;

  // Select list we use:
  if(redo)
  {
    action =  "Redo";
    strlist = v1->redo;
  } else {
    action =  "Undo";
    strlist = v1->undo;
  }
  // Set cache:
  prev = 0; prevrow = 0;

  do {
    repeat = false;
    if(strlist->Count == 0)   // if strlist is empty
    {
      AnsiString header;
      header.sprintf("Nothing to %s", action);
      MessageDlg(header,mtInformation, TMsgDlgButtons() << mbOK,0);
      break;  // force loop exit
    }
    // Pop information off the undo stack:
    str = strlist->Strings[0];
    strlist->Delete(0);

    sscanf(str.c_str(), "%d %d %d %d ", &cc , &dd, &ee, &ff);

    // Push old line to redo
    if(!redo)
    {
      str2 = v1->SourceText->Lines->Strings[dd];  
      SaveRedo(v1, cc, dd, ee, str2);
    }

    // See if block undo ...
    ccc = cc;
    if(cc & UNDO_BLOCK)
    {
      // yes
      repeat = true;
      ccc &= ((~UNDO_BLOCK) & 0xff);
    } else {
      repeat = false;
    }
    if(redo)
    {
      // Reverse flag
      switch(ccc)
      {
        case UNDO_DEL:
          ccc = UNDO_ADD;
          break;

        case UNDO_ADD:
          ccc = UNDO_DEL;
          break;

        // All other actions are reversed by just reapplying them
      }

      str2 = v1->SourceText->Lines->Strings[dd];
      SaveUndo(v1, cc, dd, ee,  str2);
    }
    // Do it
    exec_undo(v1, ccc, dd, ee, ff, str);

    /*
    // Show message and see if user wants to interact
    if(!(strlist->Count % 100)) // if more than 100 strings in undo list
    {
      AnsiString header;

      header.sprintf("Using item %d", action, strlist->Count);
      message(num);

		pDoc->UpdateAllViews(NULL); v1->SyncCaret(1);
		if(YieldToWinEx())
			{
			// Stop by force repeat to FALSE
			num.Format("Aborted %s", action);
			AfxMessageBox(num);
			repeat = FALSE;
			}
		}
	// Was a block undo, go get next item
    */
    }while(repeat);

    // If met original position, this is clean file
    if(v1->undoorig == strlist->Count || v1->undoorig + 1 == strlist->Count)
       v1->SourceText->Modified = false;

    //v1->SyncCaret();
    //YieldToWin();
    //pDoc->UpdateAllViews(NULL);

    //v1->Busy(FALSE);
    in_undo = false;

}

//---------------------------------------------------------------------------
//  UnDo
void UnDo(TTextStuff *v1)
{
  WorkUndo(v1, FALSE);
}

//---------------------------------------------------------------------------
//  ReDo

void ReDo(TTextStuff *v1)

{
  // Call undo with redo flag set
  in_redo = TRUE;
  WorkUndo(v1, TRUE);
  in_redo = FALSE;
}

//---------------------------------------------------------------------------
// Exec undo
//

void exec_undo(TTextStuff *v1, int cc, int dd, int ee, int ff, AnsiString &str)

{
  switch(cc)
  {
    case UNDO_MARK:
      // This opcode is pushed as a marker
      MessageDlg("Undo/Redo limit reached. File save recommended." ,mtInformation, TMsgDlgButtons() << mbOK,0);
      v1->notfullundo = true;
      break;

    case UNDO_DEL:
      // Deleted, line restore it
      v1->CurPos.y = dd;

      if(dd >= v1->SourceText->Lines->Count-1)
      {
        v1->SourceText->Lines->Strings[dd] += RightStr(str, ff);
      } else {
        v1->SourceText->Lines->Insert(dd, RightStr(str, ff));
      }
      break;

    case UNDO_ADD:
      // Added line, remove it:
      v1->CurPos.y = dd;
      v1->SourceText->Lines->Delete(dd);
      break;

    case  UNDO_SEP:
    case  UNDO_CHAR:
    case  UNDO_MOD:
      // Modified:
      v1->CurPos.x = ee;
      v1->CurPos.y = dd;
      //pDoc->strlist.SetLine(dd, str.Right(ff));
      break;

    case  UNDO_MOVE:
      // Cursor moved:
      v1->CurPos.y = dd;
      v1->CurPos.x = ee;
      break;

    case UNDO_NOP:
      // No operation
      break;
    default:
  //    message("Warning: Invalid undo opcode");
      break;
  }

}

