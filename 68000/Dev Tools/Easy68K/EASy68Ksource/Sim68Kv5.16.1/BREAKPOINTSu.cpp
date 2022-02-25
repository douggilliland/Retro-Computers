//---------------------------------------------------------------------------
// Debugger Component

#include <vcl.h>
#pragma hdrstop

#include "BREAKPOINTSu.h"
#include "SIM68Ku.h"
#include "extern.h"
#include "BPoint.h"
#include "BPointExpr.h"
#pragma hdrstop

const int MAX_REG_BREAKS = 50;
const int MAX_ADDR_BREAKS = 50;
const int MAX_EXPR_BREAKS = 50;

const int REG_BRK_ID_COL = 0;
const int REG_SELECT_COL = 1;
const int REG_OPERATOR_COL = 2;
const int REG_VALUE_COL = 3;
const int REG_SIZE_COL = 4;

const int ADDR_BRK_ID_COL = 0;
const int ADDR_SELECT_COL = 1;
const int ADDR_OPERATOR_COL = 2;
const int ADDR_VALUE_COL = 3;
const int ADDR_SIZE_COL = 4;
const int ADDR_READ_WRITE_COL = 5;

const int EXPR_BRK_ID_COL = 0;
const int EXPR_ENABLED_COL = 1;
const int EXPR_EXPR_COL = 2;
const int EXPR_COUNT_COL = 3;

int reg_edit_row = 1;
int addr_edit_row = 1;
int expr_edit_row = 1;

//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TBreaksFrm *BreaksFrm;
//---------------------------------------------------------------------------
__fastcall TBreaksFrm::TBreaksFrm(TComponent* Owner)
        : TForm(Owner)
{
        // Set the column titles and row IDs of the TStringGrids
        for(int row = 1; row <= MAX_REG_BREAKS; row++) {
                RegStringGrid->Cells[REG_BRK_ID_COL][row] = row;
        }
        RegStringGrid->Cells[REG_SELECT_COL][0] = "PC/Reg";
        RegStringGrid->Cells[REG_OPERATOR_COL][0] = "Op";
        RegStringGrid->Cells[REG_VALUE_COL][0] = "Value";
        RegStringGrid->Cells[REG_SIZE_COL][0] = "Size";

        for(int row = 1; row <= MAX_ADDR_BREAKS; row++) {
                AddrStringGrid->Cells[ADDR_BRK_ID_COL][row] = row;
        }
        AddrStringGrid->Cells[ADDR_SELECT_COL][0] = "Address";
        AddrStringGrid->Cells[ADDR_OPERATOR_COL][0] = "Op";
        AddrStringGrid->Cells[ADDR_VALUE_COL][0] = "Value";
        AddrStringGrid->Cells[ADDR_SIZE_COL][0] = "Size";
        AddrStringGrid->Cells[ADDR_READ_WRITE_COL][0] = "R/W";

        for(int row = 1; row <= MAX_ADDR_BREAKS; row++) {
                ExprStringGrid->Cells[EXPR_BRK_ID_COL][row] = row;
        }
        ExprStringGrid->Cells[EXPR_ENABLED_COL][0] = "Enabled";
        ExprStringGrid->Cells[EXPR_EXPR_COL][0] = "Expression";
        ExprStringGrid->Cells[EXPR_COUNT_COL][0] = "Count";

        // Initialize the alignment of the editable fields
        // within the TStringGrids.
        RegStringGrid->ColWidths[REG_BRK_ID_COL] = 25;
        RegStringGrid->ColWidths[REG_SELECT_COL] = RegSelectCombo->Width;
        RegStringGrid->ColWidths[REG_OPERATOR_COL] = RegOperatorCombo->Width;
        RegStringGrid->ColWidths[REG_VALUE_COL] = RegValueMaskEdit->Width;
        RegStringGrid->ColWidths[REG_SIZE_COL] = RegSizeCombo->Width;
        int curLeft = RegStringGrid->Left + 5;
        RegSelectCombo->Left = curLeft += RegStringGrid->ColWidths[REG_BRK_ID_COL];
        RegOperatorCombo->Left = curLeft += RegStringGrid->ColWidths[REG_SELECT_COL];
        RegValueMaskEdit->Left = curLeft += RegStringGrid->ColWidths[REG_OPERATOR_COL];
        RegSizeCombo->Left = curLeft += RegStringGrid->ColWidths[REG_VALUE_COL];

        AddrStringGrid->ColWidths[ADDR_BRK_ID_COL] = 25;
        AddrStringGrid->ColWidths[ADDR_SELECT_COL] = AddrSelectMaskEdit->Width;
        AddrStringGrid->ColWidths[ADDR_OPERATOR_COL] = AddrOperatorCombo->Width;
        AddrStringGrid->ColWidths[ADDR_VALUE_COL] = AddrValueMaskEdit->Width;
        AddrStringGrid->ColWidths[ADDR_SIZE_COL] = AddrSizeCombo->Width;
        AddrStringGrid->ColWidths[ADDR_READ_WRITE_COL] = AddrReadWriteCombo->Width;
        curLeft = AddrStringGrid->Left + 5;
        AddrSelectMaskEdit->Left = curLeft += AddrStringGrid->ColWidths[ADDR_BRK_ID_COL];
        AddrOperatorCombo->Left = curLeft += AddrStringGrid->ColWidths[ADDR_SELECT_COL];
        AddrValueMaskEdit->Left = curLeft += AddrStringGrid->ColWidths[ADDR_OPERATOR_COL];
        AddrSizeCombo->Left = curLeft += AddrStringGrid->ColWidths[ADDR_VALUE_COL];
        AddrReadWriteCombo->Left = curLeft += AddrStringGrid->ColWidths[ADDR_SIZE_COL];

        ExprStringGrid->ColWidths[EXPR_BRK_ID_COL] = 25;
        ExprStringGrid->ColWidths[EXPR_ENABLED_COL] = ExprEnabledCombo->Width;
        ExprStringGrid->ColWidths[EXPR_EXPR_COL] = ExprExprEdit->Width;
        ExprStringGrid->ColWidths[EXPR_COUNT_COL] = ExprCountMaskEdit->Width;
        curLeft = ExprStringGrid->Left + 5;
        ExprEnabledCombo->Left = curLeft += ExprStringGrid->ColWidths[EXPR_BRK_ID_COL];
        ExprExprEdit->Left = curLeft += ExprStringGrid->ColWidths[EXPR_ENABLED_COL];
        ExprCountMaskEdit->Left = curLeft += ExprStringGrid->ColWidths[EXPR_EXPR_COL];
}
//---------------------------------------------------------------------------


// Sets PC breakpoints only
int __fastcall TBreaksFrm::sbpoint(int loc)     // set break point
{
  int i;
  AnsiString str;

  // set breakpoint in table and increment counter
  for (i = 0; i<bpoints; i++)
    if(brkpt[i] == loc)
      return SUCCESS;

  if (bpoints < 100)
    brkpt[bpoints++] = loc;
  else
    Application->MessageBox("Breakpoint Limit Reached!", NULL, MB_OK);

  Form1->ListBox1->Repaint();
  return SUCCESS;
}

// Clears PC break points only
int __fastcall TBreaksFrm::cbpoint(int loc)     // clear break point
{
  int i, j;
  AnsiString str;

  if (loc == -1) {              // if clear all breakpoints
    bpoints = 0;                        // clear index

  } else {                      // else clear one breakpoint

    // find break point specified
    for (i = 0; i < bpoints; i++)
      if (brkpt[i] == loc)
        break;

    --bpoints;                            // decrement counter
    for (j = i; j < bpoints; j++)         // adjust breakpoint table
      brkpt[j] = brkpt[j + 1];

  }

  // refresh display
  Form1->ListBox1->Repaint();
  return SUCCESS;
}

//---------------------------------------------------------------------------


void __fastcall TBreaksFrm::resetDebug() {
        // Reset all breakpoint condition met counts to zero.
        for(int c = 0; c < MAX_BPOINTS; c++)
                bpCountCond[c] = 0;
}

void __fastcall TBreaksFrm::setRegButtons()
{
        // Are the editable fields exposed for data entry?
        if(RegOperatorCombo->Visible) {
                RegSetButton->Enabled = true;
                RegClearButton->Enabled = false;
                RegClearAllButton->Enabled = false;
        }
        else {
                RegSetButton->Enabled = false;
                if(regCount > 0) {
                        RegClearButton->Enabled = true;
                        RegClearAllButton->Enabled = true;
                }
                else {
                        RegClearButton->Enabled = false;
                        RegClearAllButton->Enabled = false;
                }
        }
}

void __fastcall TBreaksFrm::setAddrButtons()
{
        // Are the editable fields exposed for data entry?
        if(AddrOperatorCombo->Visible) {
                AddrSetButton->Enabled = true;
                AddrClearButton->Enabled = false;
                AddrClearAllButton->Enabled = false;
        }
        else {
                AddrSetButton->Enabled = false;
                if(addrCount > 0) {
                        AddrClearButton->Enabled = true;
                        AddrClearAllButton->Enabled = true;
                }
                else {
                        AddrClearButton->Enabled = false;
                        AddrClearAllButton->Enabled = false;
                }
        }
}

void __fastcall TBreaksFrm::setExprButtons()
{
        // Are the editable fields exposed for data entry?
        if(ExprEnabledCombo->Visible) {
                // Don't allow hanging operators or incomplete expressions
                if(parenCount == 0 && (mruOperand || (infixExpr[infixCount-1] == RPAREN)))
                        ExprSetButton->Enabled = true;
                else
                        ExprSetButton->Enabled = false;
                ExprClearButton->Enabled = false;
                ExprClearAllButton->Enabled = false;
        }
        else {
                ExprSetButton->Enabled = false;
                if(exprCount > 0) {
                        ExprClearButton->Enabled = true;
                        ExprClearAllButton->Enabled = true;
                }
                else {
                        ExprClearButton->Enabled = false;
                        ExprClearAllButton->Enabled = false;
                }
        }

        // Enable / disable appropriate expression builder buttons
        if(ExprExprEdit->Visible) {
                int mruElement = 0;
                bool startExpr = false;
                if(infixCount > 0)
                        mruElement = infixExpr[infixCount - 1];
                else
                        startExpr = true;

                // Force operands to be separated by operators.
                if(mruOperator || (mruElement == LPAREN) || startExpr) {
                        ExprRegAppendButton->Enabled = true;
                        ExprAddrAppendButton->Enabled = true;
                        ExprAndAppendButton->Enabled = false;
                        ExprOrAppendButton->Enabled = false;
                }
                else if(mruOperand || (mruElement == RPAREN)) {
                        ExprRegAppendButton->Enabled = false;
                        ExprAddrAppendButton->Enabled = false;
                        ExprAndAppendButton->Enabled = true;
                        ExprOrAppendButton->Enabled = true;
                }

                // Is there an legal element preceding the left paren,
                // or is this the first element in the expression?
                if(infixCount == 0 || mruOperator ||
                   (infixExpr[infixCount - 1] == LPAREN))
                        ExprLParenAppendButton->Enabled = true;
                else
                        ExprLParenAppendButton->Enabled = false;

                // Are there already left parens and not an operator in the last element?
                if(parenCount > 0 && !mruOperator && (mruElement != LPAREN))
                        ExprRParenAppendButton->Enabled = true;
                else
                        ExprRParenAppendButton->Enabled = false;

                // Is there anything available to delete from the expression?
                if(infixCount > 0)
                        ExprBackspaceButton->Enabled = true;
                else
                        ExprBackspaceButton->Enabled = false;

                // Regardless of anything else, if max count has been reached,
                // disable all except the backspace key.
                if(infixCount >= MAX_LB_NODES) {
                        ExprRegAppendButton->Enabled = false;
                        ExprAddrAppendButton->Enabled = false;
                        ExprAndAppendButton->Enabled = false;
                        ExprOrAppendButton->Enabled = false;
                        ExprBackspaceButton->Enabled = true;
                        ExprLParenAppendButton->Enabled = false;
                        ExprRParenAppendButton->Enabled = false;
                }
        }
        else {
                ExprRegAppendButton->Enabled = false;
                ExprAddrAppendButton->Enabled = false;
                ExprAndAppendButton->Enabled = false;
                ExprOrAppendButton->Enabled = false;
                ExprBackspaceButton->Enabled = false;
                ExprLParenAppendButton->Enabled = false;
                ExprRParenAppendButton->Enabled = false;
        }
}

void __fastcall TBreaksFrm::RegStringGridClick(TObject *Sender)
{
        // Assist the user interface for the expression builder by
        // allowing the user to select a reg breakpoint by click.
        if(RegStringGrid->Row > regCount)
                reg_edit_row = regCount;
        else
                reg_edit_row = RegStringGrid->Row;
        AnsiString original = "";
        if(reg_edit_row < 10)
                original += "0";
        original += IntToStr(reg_edit_row);
        ExprRegMaskEdit->Text = original;

        RegSelectCombo->Visible = false;
        RegOperatorCombo->Visible = false;
        RegValueMaskEdit->Visible = false;
        RegSizeCombo->Visible = false;
        setRegButtons();
}
//---------------------------------------------------------------------------

void __fastcall TBreaksFrm::AddrStringGridClick(TObject *Sender)
{
        // Assist the user interface for the expression builder by
        // allowing the user to select an addr breakpoint by click.
        if(AddrStringGrid->Row > addrCount)
                addr_edit_row = addrCount;
        else
                addr_edit_row = AddrStringGrid->Row;
        AnsiString original = "";
        if(addr_edit_row < 10)
                original += "0";
        original += IntToStr(addr_edit_row);
        ExprAddrMaskEdit->Text = original;

        AddrSelectMaskEdit->Visible = false;
        AddrOperatorCombo->Visible = false;
        AddrValueMaskEdit->Visible = false;
        AddrSizeCombo->Visible = false;
        AddrReadWriteCombo->Visible = false;
        setAddrButtons();
}
//---------------------------------------------------------------------------


void __fastcall TBreaksFrm::ExprStringGridClick(TObject *Sender)
{
        ExprEnabledCombo->Visible = false;
        ExprExprEdit->Visible = false;
        ExprCountMaskEdit->Visible = false;
        setExprButtons();
}
//---------------------------------------------------------------------------

void __fastcall TBreaksFrm::RegSetButtonClick(TObject *Sender)
{
        // Make sure valid data was entered in each field
        if((RegSelectCombo->Text == "") ||
           (RegOperatorCombo->Text == "") ||
           (RegValueMaskEdit->EditText == "") ||
           (RegSizeCombo->Text == ""))
        {
                Application->MessageBox("Entry not stored.  Fields missing.",
                                        NULL, MB_OK);
                return;
        }
        // Capture the text from editable fields into the RegStringGrid.
        RegStringGrid->Cells[REG_SELECT_COL][reg_edit_row] = RegSelectCombo->Text;
        RegSelectCombo->Visible = false;
        RegStringGrid->Cells[REG_OPERATOR_COL][reg_edit_row] = RegOperatorCombo->Text;
        RegOperatorCombo->Visible = false;
        RegStringGrid->Cells[REG_VALUE_COL][reg_edit_row] = RegValueMaskEdit->EditText;
        RegValueMaskEdit->Visible = false;
        RegStringGrid->Cells[REG_SIZE_COL][reg_edit_row] = RegSizeCombo->Text;
        RegSizeCombo->Visible = false;

        // Get the BPoint associated with the current register count and
        // set the fields of the breakpoint.
        BPoint * curBPoint = &breakPoints[reg_edit_row-1];
        curBPoint->setId(regCount);
        curBPoint->setType(PC_REG_TYPE);
        curBPoint->setTypeId(RegSelectCombo->ItemIndex);
        curBPoint->setOperator(RegOperatorCombo->ItemIndex);
        AnsiString str = "0x";
        curBPoint->setValue(StrToInt(str + RegValueMaskEdit->EditText));
        curBPoint->setSize(RegSizeCombo->ItemIndex);
        curBPoint->isEnabled(true);

        // Increment the counter to reflect the additional PC/Reg breakpoint,
        // unless the user is editing an existing PC/Reg breakpoint row.
        if(reg_edit_row > regCount)
                regCount++;
        setRegButtons();
}
//---------------------------------------------------------------------------

void __fastcall TBreaksFrm::AddrSetButtonClick(TObject *Sender)
{
        // Make sure valid data was entered in each field
        if((AddrSelectMaskEdit->EditText == "") ||
           (AddrOperatorCombo->Text == "") ||
           (AddrValueMaskEdit->EditText == "") ||
           (AddrReadWriteCombo->Text == "") ||
           (AddrSizeCombo->Text == ""))
        {
                Application->MessageBox("Entry not stored.  Fields missing.",
                                        NULL, MB_OK);
                return;
        }
        // Capture the text from editable fields into the AddrStringGrid.
        AddrStringGrid->Cells[ADDR_SELECT_COL][addr_edit_row] = AddrSelectMaskEdit->EditText;
        AddrSelectMaskEdit->Visible = false;
        AddrStringGrid->Cells[ADDR_OPERATOR_COL][addr_edit_row] = AddrOperatorCombo->Text;
        AddrOperatorCombo->Visible = false;
        AddrStringGrid->Cells[ADDR_VALUE_COL][addr_edit_row] = AddrValueMaskEdit->EditText;
        AddrValueMaskEdit->Visible = false;
        AddrStringGrid->Cells[ADDR_SIZE_COL][addr_edit_row] = AddrSizeCombo->Text;
        AddrSizeCombo->Visible = false;
        AddrStringGrid->Cells[ADDR_READ_WRITE_COL][addr_edit_row] = AddrReadWriteCombo->Text;
        AddrReadWriteCombo->Visible = false;

        // Get the BPoint associated with the current register count and
        // set the fields of the breakpoint.
        BPoint * curBPoint = &breakPoints[addr_edit_row-1 + ADDR_ID_OFFSET];
        curBPoint->setId(addrCount);
        curBPoint->setType(ADDR_TYPE);
        AnsiString str = "0x";
        long typeId = StrToInt(str + AddrSelectMaskEdit->EditText);
        curBPoint->setTypeId(typeId);
        curBPoint->setOperator(AddrOperatorCombo->ItemIndex);
        curBPoint->setValue(StrToInt(str + AddrValueMaskEdit->EditText));
        curBPoint->setSize(StrToInt(AddrSizeCombo->ItemIndex));
        curBPoint->setReadWrite(AddrReadWriteCombo->ItemIndex);
        curBPoint->isEnabled(true);

        // Increment the counter to reflect the additional Addr breakpoint.
        // unless the user is editing an existing Addr breakpoint row.
        if(addr_edit_row > addrCount)
                addrCount++;
        setAddrButtons();
}
//---------------------------------------------------------------------------

void __fastcall TBreaksFrm::ExprSetButtonClick(TObject *Sender)
{
        // Make sure valid data was entered in each field
        if((ExprEnabledCombo->Text == "") ||
           (ExprExprEdit->Text == "") ||
           (ExprCountMaskEdit->EditText == ""))
        {
                Application->MessageBox("Entry not stored.  Fields missing.",
                                        NULL, MB_OK);
                return;
        }

        // Capture the text from editable fields into the ExprStringGrid.
        ExprStringGrid->Cells[EXPR_ENABLED_COL][expr_edit_row] = ExprEnabledCombo->Text;
        ExprEnabledCombo->Visible = false;
        ExprStringGrid->Cells[EXPR_EXPR_COL][expr_edit_row] = ExprExprEdit->Text;
        ExprExprEdit->Visible = false;
        ExprStringGrid->Cells[EXPR_COUNT_COL][expr_edit_row] = ExprCountMaskEdit->EditText;
        ExprCountMaskEdit->Visible = false;

        // Initialize current bpExpression element
        bpExpressions[expr_edit_row-1].setId(expr_edit_row);
        bpExpressions[expr_edit_row-1].isEnabled(ExprEnabledCombo->Text == "ON");
        bpExpressions[expr_edit_row-1].setExprString(ExprExprEdit->Text);
        AnsiString str = "0x";
        bpExpressions[expr_edit_row-1].setCount(StrToInt(str + ExprCountMaskEdit->EditText));
        bpExpressions[expr_edit_row-1].setInfixExpr(infixExpr, infixCount);
        
        // Convert infix expression to binary expression tree.
        int curToken = 0;
        int stackToken;
        postfixCount = 0;

        for(int tok = 0; tok < infixCount; tok++) {
                curToken = infixExpr[tok];
                switch(curToken) {
                case MAX_BPOINTS + AND_OP:
                case MAX_BPOINTS + OR_OP:
                        while(!s_operator.empty() &&
                             ((stackToken = s_operator.top()) != LPAREN) &&
                             (precedence(curToken) <= precedence(stackToken))){
                                postfixExpr[postfixCount++] = stackToken;
                                s_operator.pop();
                        };
                        s_operator.push(curToken);
                        break;
                case LPAREN:
                        s_operator.push(curToken);
                        break;
                case RPAREN:
                        while((stackToken = s_operator.top()) != LPAREN) {
                                postfixExpr[postfixCount++] = stackToken;
                                s_operator.pop();
                        };
                        break;
                default:     // if the token is an operand ...
                        postfixExpr[postfixCount++] = curToken;
                        break;
                }
        }
        while(!s_operator.empty()) {
                stackToken = s_operator.top();
                if(stackToken != LPAREN)
                        postfixExpr[postfixCount++] = stackToken;
                s_operator.pop();
        };
        bpExpressions[expr_edit_row-1].setPostfixExpr(postfixExpr, postfixCount);
        infixCount = 0;
        parenCount = 0;
        mruOperand = false;
        mruOperator = false;

        // Increment the counter to reflect the additional breakpoint expression,
        // unless the user is editing an existing breakpoint expression row.
        if(expr_edit_row > exprCount)
                exprCount++;
        setExprButtons();
}
//---------------------------------------------------------------------------

int __fastcall TBreaksFrm::precedence(int op_prec) {
        // Currently this is a trivial operation.  The highest precedence
        // operator (AND) has the lowest integer value.  For readability in
        // the infix to postfix conversion algorithm, the precedence function
        // is used to reverse the logic.
        return -op_prec;
}
//---------------------------------------------------------------------------


void __fastcall TBreaksFrm::ExprRegAppendButtonClick(TObject *Sender)
{
        // Make sure there is room for more array elements
        if(infixCount < MAX_LB_NODES) {
                ExprExprEdit->Enabled = true;
                AnsiString original = ExprExprEdit->Text;
                int regIndex = StrToInt(ExprRegMaskEdit->EditText);
                if(regIndex > 0 && regIndex <= regCount) {
                        infixExpr[infixCount++] = regIndex - 1;
                        original += (" R" + IntToStr(regIndex));
                        if(regIndex < 10)
                                original += (" ");
                        original += (" ");
                        ExprExprEdit->Text = original;
                }
                else {
                        Application->MessageBoxA("Invalid PC/Reg Breakpoint. Set PC/Reg in Registers area first.",
                                                 NULL, MB_OK);
                }
                ExprExprEdit->Enabled = false;
                mruOperand = true;
                mruOperator = false;
        }
        setExprButtons();
}
//---------------------------------------------------------------------------

void __fastcall TBreaksFrm::ExprAddrAppendButtonClick(TObject *Sender)
{
        // Make sure there is room for more array elements
        if(infixCount < MAX_LB_NODES) {
                AnsiString original = ExprExprEdit->Text;
                int addrIndex = ADDR_ID_OFFSET + StrToInt(ExprAddrMaskEdit->EditText);
                if(addrIndex > ADDR_ID_OFFSET && addrIndex <= ADDR_ID_OFFSET + addrCount) {
                        infixExpr[infixCount++] = addrIndex - 1;
                        original += (" A" + IntToStr(addrIndex - ADDR_ID_OFFSET));
                        if(addrIndex < 10)
                                original += (" ");
                        original += (" ");
                        ExprExprEdit->Text = original;
                }
                else {
                        Application->MessageBoxA("Invalid Memory Breakpoint. Set Memory in Memory area first.",
                                                 NULL, MB_OK);
                }
                mruOperand = true;
                mruOperator = false;
        }
        setExprButtons();
}
//---------------------------------------------------------------------------

void __fastcall TBreaksFrm::ExprAndAppendButtonClick(TObject *Sender)
{
        // Make sure there is room for more array elements
        if(infixCount < MAX_LB_NODES) {
                // Represent and AND_OP in the int array
                AnsiString original = ExprExprEdit->Text;
                infixExpr[infixCount++] = MAX_BPOINTS + AND_OP;
                original += (" AND ");
                ExprExprEdit->Text = original;
                mruOperand = false;
                mruOperator = true;
        }
        setExprButtons();
}
//---------------------------------------------------------------------------

void __fastcall TBreaksFrm::ExprOrAppendButtonClick(TObject *Sender)
{
        // Make sure there is room for more array elements
        if(infixCount < MAX_LB_NODES) {
                // Represent and OR_OP in the int array
                AnsiString original = ExprExprEdit->Text;
                infixExpr[infixCount++] = MAX_BPOINTS + OR_OP;
                original += (" OR  ");
                ExprExprEdit->Text = original;
                mruOperand = false;
                mruOperator = true;
        }
        setExprButtons();
}
//---------------------------------------------------------------------------

void __fastcall TBreaksFrm::ExprBackspaceButtonClick(TObject *Sender)
{
        AnsiString original = ExprExprEdit->Text;
        AnsiString edited = original.SubString(0, (original.Length() - 5));
        ExprExprEdit->Text = edited;
        // Are we deleting a left paren?
        if(infixExpr[infixCount - 1] == LPAREN)
                parenCount--;
        // Are we deleting a right paren?
        else if(infixExpr[infixCount - 1] == RPAREN)
                parenCount++;
        infixCount--;

        // Is the last element an operand (between 0 and MAX_BPOINTS)?
        if(infixCount > 0 &&
           infixExpr[infixCount-1] < MAX_BPOINTS && infixExpr[infixCount-1] >= 0)
                mruOperand = true;
        else {
                mruOperand = false;
                // Is the last element not a left paren or a right paren?
                if((infixExpr[infixCount - 1] != LPAREN) &&
                   (infixExpr[infixCount - 1] != RPAREN))
                        mruOperator = true;
                else
                        mruOperator = false;
        }
        setExprButtons();
}
//---------------------------------------------------------------------------

void __fastcall TBreaksFrm::RegClearButtonClick(TObject *Sender)
{
        if(reg_edit_row > 0 && reg_edit_row <= regCount) {
                // Remove the selected row from the TStringGrid
                for(int curRow = reg_edit_row; curRow <= regCount; curRow++) {
                        int upperRow = (curRow < MAX_REG_ROWS ? curRow + 1 : curRow);
                        RegStringGrid->Cells[REG_SELECT_COL][curRow] =
                                RegStringGrid->Cells[REG_SELECT_COL][upperRow];
                        RegStringGrid->Cells[REG_OPERATOR_COL][curRow] =
                                RegStringGrid->Cells[REG_OPERATOR_COL][upperRow];
                        RegStringGrid->Cells[REG_VALUE_COL][curRow] =
                                RegStringGrid->Cells[REG_VALUE_COL][upperRow];
                        RegStringGrid->Cells[REG_SIZE_COL][curRow] =
                                RegStringGrid->Cells[REG_SIZE_COL][upperRow];
                        if(upperRow == MAX_REG_ROWS) {
                                RegStringGrid->Cells[REG_SELECT_COL][curRow] = "";
                                RegStringGrid->Cells[REG_OPERATOR_COL][curRow] = "";
                                RegStringGrid->Cells[REG_VALUE_COL][curRow] = "";
                                RegStringGrid->Cells[REG_SIZE_COL][curRow] = "";
                        }
                }

                // Once again, hide the editable fields that were displayed upon user click.
                RegSelectCombo->Visible = false;
                RegOperatorCombo->Visible = false;
                RegValueMaskEdit->Visible = false;
                RegSizeCombo->Visible = false;

                // Shift the elements in the breakPoints array and decrement the count.
                BPoint * temp = &breakPoints[reg_edit_row - 1];
                for(int curRow = reg_edit_row; curRow < regCount; curRow++) {
                        breakPoints[curRow - 1] = breakPoints[curRow];
                }
                regCount--;
                breakPoints[regCount] = *temp;
                breakPoints[regCount].isEnabled(false);
                //temp = NULL;
        }
        else {
                Application->MessageBoxA("Select a Valid Row.",
                                                 NULL, MB_OK);
        }
        setRegButtons();
}
//---------------------------------------------------------------------------

void __fastcall TBreaksFrm::RegClearAllButtonClick(TObject *Sender)
{
        // Remove all rows from the TStringGrid
        for(int curRow = 1; curRow <= regCount; curRow++) {
                RegStringGrid->Cells[REG_SELECT_COL][curRow] = "";
                RegStringGrid->Cells[REG_OPERATOR_COL][curRow] = "";
                RegStringGrid->Cells[REG_VALUE_COL][curRow] = "";
                RegStringGrid->Cells[REG_SIZE_COL][curRow] = "";
        }

        // Once again, hide the editable fields that were displayed upon user click.
        RegSelectCombo->Visible = false;
        RegOperatorCombo->Visible = false;
        RegValueMaskEdit->Visible = false;
        RegSizeCombo->Visible = false;

        // Invalidate all PC/Reg breakpoints
        for(int cur = 0; cur < regCount; cur++)
                breakPoints[cur].isEnabled(false);
        regCount = 0;

        setRegButtons();
}
//---------------------------------------------------------------------------

void __fastcall TBreaksFrm::AddrClearButtonClick(TObject *Sender)
{
        if(addr_edit_row > 0 && addr_edit_row <= addrCount) {
                // Remove the selected row from the TStringGrid
                for(int curRow = addr_edit_row; curRow <= addrCount; curRow++) {
                        int upperRow = (curRow < MAX_ADDR_ROWS ? curRow + 1 : curRow);
                        AddrStringGrid->Cells[ADDR_SELECT_COL][curRow] =
                                AddrStringGrid->Cells[ADDR_SELECT_COL][upperRow];
                        AddrStringGrid->Cells[ADDR_OPERATOR_COL][curRow] =
                                AddrStringGrid->Cells[ADDR_OPERATOR_COL][upperRow];
                        AddrStringGrid->Cells[ADDR_VALUE_COL][curRow] =
                                AddrStringGrid->Cells[ADDR_VALUE_COL][upperRow];
                        AddrStringGrid->Cells[ADDR_SIZE_COL][curRow] =
                                AddrStringGrid->Cells[ADDR_SIZE_COL][upperRow];
                        AddrStringGrid->Cells[ADDR_READ_WRITE_COL][curRow] =
                                AddrStringGrid->Cells[ADDR_READ_WRITE_COL][upperRow];
                        if(upperRow == MAX_ADDR_ROWS) {
                                AddrStringGrid->Cells[ADDR_SELECT_COL][curRow] = "";
                                AddrStringGrid->Cells[ADDR_OPERATOR_COL][curRow] = "";
                                AddrStringGrid->Cells[ADDR_VALUE_COL][curRow] = "";
                                AddrStringGrid->Cells[ADDR_SIZE_COL][curRow] = "";
                                AddrStringGrid->Cells[ADDR_READ_WRITE_COL][curRow] = "";
                        }
                }

                // Once again, hide the editable fields that were displayed upon user click.
                AddrSelectMaskEdit->Visible = false;
                AddrOperatorCombo->Visible = false;
                AddrValueMaskEdit->Visible = false;
                AddrSizeCombo->Visible = false;
                AddrReadWriteCombo->Visible = false;

                // Shift the elements in the breakPoints array and decrement the count.
                BPoint * temp = &breakPoints[addr_edit_row - 1 + ADDR_ID_OFFSET];
                for(int curRow = AddrStringGrid->Row; curRow < addrCount; curRow++) {
                        breakPoints[curRow - 1 + ADDR_ID_OFFSET] = breakPoints[curRow];
                }
                addrCount--;
                breakPoints[addrCount + ADDR_ID_OFFSET] = *temp;
                breakPoints[addrCount + ADDR_ID_OFFSET].isEnabled(false);
                //temp = NULL;
        }
        else {
                Application->MessageBoxA("Select a Valid Row.",
                                                 NULL, MB_OK);
        }
        setAddrButtons();
}
//---------------------------------------------------------------------------

void __fastcall TBreaksFrm::AddrClearAllButtonClick(TObject *Sender)
{
        // Remove the selected row from the TStringGrid
        for(int curRow = 1; curRow <= addrCount; curRow++) {
                AddrStringGrid->Cells[ADDR_SELECT_COL][curRow] = "";
                AddrStringGrid->Cells[ADDR_OPERATOR_COL][curRow] = "";
                AddrStringGrid->Cells[ADDR_VALUE_COL][curRow] = "";
                AddrStringGrid->Cells[ADDR_SIZE_COL][curRow] = "";
                AddrStringGrid->Cells[ADDR_READ_WRITE_COL][curRow] = "";
        }

        // Once again, hide the editable fields that were displayed upon user click.
        AddrSelectMaskEdit->Visible = false;
        AddrOperatorCombo->Visible = false;
        AddrValueMaskEdit->Visible = false;
        AddrSizeCombo->Visible = false;
        AddrReadWriteCombo->Visible = false;

        // Invalidate all Addr breakpoints
        for(int cur = ADDR_ID_OFFSET; cur < ADDR_ID_OFFSET + addrCount; cur++)
                breakPoints[cur].isEnabled(false);
        addrCount = 0;

        setAddrButtons();
}
//---------------------------------------------------------------------------

void __fastcall TBreaksFrm::RegValueKeyPress(TObject *Sender, char &Key)
{
        if ( (Key >= '0' && Key <= '9') ||
             (toupper(Key) >= 'A' && toupper(Key) <= 'F') )
                Key = toupper(Key);
        else {
                Beep();
                Key = 0;
        }
}
//---------------------------------------------------------------------------

void __fastcall TBreaksFrm::AddrSelectKeyPress(TObject *Sender, char &Key)
{
        if ( (Key >= '0' && Key <= '9') ||
             (toupper(Key) >= 'A' && toupper(Key) <= 'F') )
                Key = toupper(Key);
        else {
                Beep();
                Key = 0;
        }
}
//---------------------------------------------------------------------------

void __fastcall TBreaksFrm::AddrValueKeyPress(TObject *Sender, char &Key)
{
        if ( (Key >= '0' && Key <= '9') ||
             (toupper(Key) >= 'A' && toupper(Key) <= 'F') )
                Key = toupper(Key);
        else {
                Beep();
                Key = 0;
        }        
}
//---------------------------------------------------------------------------

void __fastcall TBreaksFrm::ExprCountKeyPress(TObject *Sender, char &Key)
{
        if (Key < '0' || Key > '9') {
                Beep();
                Key = 0;
        }
}
//---------------------------------------------------------------------------



void __fastcall TBreaksFrm::ExprClearButtonClick(TObject *Sender)
{
        if(expr_edit_row > 0 && expr_edit_row <= exprCount) {
                // Remove the selected row from the TStringGrid
                for(int curRow = ExprStringGrid->Row; curRow <= exprCount; curRow++) {
                        int upperRow = (curRow < MAX_EXPR_ROWS ? curRow + 1 : curRow);
                        ExprStringGrid->Cells[EXPR_ENABLED_COL][curRow] =
                                ExprStringGrid->Cells[EXPR_ENABLED_COL][upperRow];
                        ExprStringGrid->Cells[EXPR_EXPR_COL][curRow] =
                                ExprStringGrid->Cells[EXPR_EXPR_COL][upperRow];
                        ExprStringGrid->Cells[EXPR_COUNT_COL][curRow] =
                                ExprStringGrid->Cells[EXPR_COUNT_COL][upperRow];
                        if(upperRow == MAX_EXPR_ROWS) {
                                ExprStringGrid->Cells[EXPR_ENABLED_COL][curRow] = "";
                                ExprStringGrid->Cells[EXPR_EXPR_COL][curRow] = "";
                                ExprStringGrid->Cells[EXPR_COUNT_COL][curRow] = "";
                        }
                }

                // Once again, hide the editable fields that were displayed upon user click.
                ExprEnabledCombo->Visible = false;
                ExprExprEdit->Visible = false;
                ExprCountMaskEdit->Visible = false;

                // Shift the elements in the breakPoints array and decrement the count.
                BPointExpr * temp = &bpExpressions[expr_edit_row - 1];
                for(int curRow = ExprStringGrid->Row; curRow < exprCount; curRow++) {
                        bpExpressions[curRow - 1] = bpExpressions[curRow];
                }
                exprCount--;
                bpExpressions[exprCount] = *temp;
                bpExpressions[exprCount].isEnabled(false);
                //temp = NULL;
        }
        else {
                Application->MessageBoxA("Select a Valid Row.",
                                                 NULL, MB_OK);
        }
        setExprButtons();
}
//---------------------------------------------------------------------------

void __fastcall TBreaksFrm::ExprClearAllButtonClick(TObject *Sender)
{
        // Remove the selected row from the TStringGrid
        for(int curRow = 1; curRow <= exprCount; curRow++) {
                ExprStringGrid->Cells[EXPR_ENABLED_COL][curRow] = "";
                ExprStringGrid->Cells[EXPR_EXPR_COL][curRow] = "";
                ExprStringGrid->Cells[EXPR_COUNT_COL][curRow] = "";
        }

        // Once again, hide the editable fields that were displayed upon user click.
        ExprEnabledCombo->Visible = false;
        ExprExprEdit->Visible = false;
        ExprCountMaskEdit->Visible = false;

        // Invalidate all breakpoint expressions
        exprCount = 0;

        setExprButtons();
}
//---------------------------------------------------------------------------

void __fastcall TBreaksFrm::RegStringGridDblClick(TObject *Sender)
{
        // Force data to be entered into consecutive rows
        if(RegStringGrid->Row > regCount) {
                // Set editable fields to default values
                reg_edit_row = regCount + 1;
                RegSelectCombo->Text = "PC";
                RegOperatorCombo->Text = "==";
                RegValueMaskEdit->Text = "00000000";
                RegSizeCombo->Text = "L";
                RegSelectCombo->ItemIndex = PC_TYPE_ID;
                RegOperatorCombo->ItemIndex = EQUAL_OP;
                RegSizeCombo->ItemIndex = LONG_SIZE;
        }
        else {
                // Set editable fields to existing values
                reg_edit_row = RegStringGrid->Row;
                RegSelectCombo->Text = RegStringGrid->Cells[REG_SELECT_COL][reg_edit_row];
                RegOperatorCombo->Text = RegStringGrid->Cells[REG_OPERATOR_COL][reg_edit_row];
                RegValueMaskEdit->Text = RegStringGrid->Cells[REG_VALUE_COL][reg_edit_row];
                RegSizeCombo->Text = RegStringGrid->Cells[REG_SIZE_COL][reg_edit_row];
                RegSelectCombo->ItemIndex = breakPoints[reg_edit_row-1].getTypeId();
                RegOperatorCombo->ItemIndex = breakPoints[reg_edit_row-1].getOperator();
                RegSizeCombo->ItemIndex = breakPoints[reg_edit_row-1].getSize();
        }

        // Align the editable fields with the position of the currently
        // selected row within the RegStringGrid.
        int relativeHeight = RegStringGrid->Top + 5 +
                (reg_edit_row - RegStringGrid->TopRow + 1) *
                (RegStringGrid->DefaultRowHeight + 1);
        RegSelectCombo->Visible = true;
        RegSelectCombo->Top = relativeHeight;
        RegOperatorCombo->Visible = true;
        RegOperatorCombo->Top = relativeHeight;
        RegValueMaskEdit->Visible = true;
        RegValueMaskEdit->Top = relativeHeight;
        RegSizeCombo->Visible = true;
        RegSizeCombo->Top = relativeHeight;
        setRegButtons();
}
//---------------------------------------------------------------------------

void __fastcall TBreaksFrm::AddrStringGridDblClick(TObject *Sender)
{
        // Force data to be entered into consecutive rows
        if(AddrStringGrid->Row > addrCount) {
                // Set editable fields to default values
                addr_edit_row = addrCount + 1;
                AddrSelectMaskEdit->Text = "00000000";
                AddrOperatorCombo->Text = "==";
                AddrValueMaskEdit->Text = "00000000";
                AddrSizeCombo->Text = "L";
                AddrReadWriteCombo->Text = "R/W";
                AddrOperatorCombo->ItemIndex = EQUAL_OP;
                AddrSizeCombo->ItemIndex = LONG_SIZE;
                AddrReadWriteCombo->ItemIndex = RW_TYPE;
        }
        else {
                // Set editable fields to existing values
                addr_edit_row = AddrStringGrid->Row;
                AddrSelectMaskEdit->Text = AddrStringGrid->Cells[ADDR_SELECT_COL][addr_edit_row];
                AddrOperatorCombo->Text = AddrStringGrid->Cells[ADDR_OPERATOR_COL][addr_edit_row];
                AddrValueMaskEdit->Text = AddrStringGrid->Cells[ADDR_VALUE_COL][addr_edit_row];
                AddrSizeCombo->Text = AddrStringGrid->Cells[ADDR_SIZE_COL][addr_edit_row];
                AddrReadWriteCombo->Text = AddrStringGrid->Cells[ADDR_READ_WRITE_COL][addr_edit_row];
                AddrOperatorCombo->ItemIndex = breakPoints[reg_edit_row-1].getOperator();
                AddrSizeCombo->ItemIndex = breakPoints[reg_edit_row-1].getSize();
                AddrReadWriteCombo->ItemIndex = breakPoints[reg_edit_row-1].getReadWrite();
        }

        // Align the editable fields with the position of the currently
        // selected row within the AddrStringGrid.
        int relativeHeight = AddrStringGrid->Top + 5 +
                (addr_edit_row - AddrStringGrid->TopRow + 1) *
                (AddrStringGrid->DefaultRowHeight + 1);
        AddrSelectMaskEdit->Visible = true;
        AddrSelectMaskEdit->Top = relativeHeight;
        AddrOperatorCombo->Visible = true;
        AddrOperatorCombo->Top = relativeHeight;
        AddrValueMaskEdit->Visible = true;
        AddrValueMaskEdit->Top = relativeHeight;
        AddrSizeCombo->Visible = true;
        AddrSizeCombo->Top = relativeHeight;
        AddrReadWriteCombo->Visible = true;
        AddrReadWriteCombo->Top = relativeHeight;
        setAddrButtons();
}
//---------------------------------------------------------------------------

void __fastcall TBreaksFrm::ExprStringGridDblClick(TObject *Sender)
{
        // Force data to be entered into consecutive rows
        if(ExprStringGrid->Row > exprCount) {
                expr_edit_row = exprCount + 1;
                ExprEnabledCombo->Text = "ON";
                ExprExprEdit->Text = "";
                ExprCountMaskEdit->Text = "01";
                ExprEnabledCombo->ItemIndex = EXPR_ON;

                // Reset the expression array elements, so a new expression can be constructed.
                for(int i = 0; i < MAX_LB_NODES; i++) {
                        infixExpr[i] = -1;
                }
                infixCount = 0;
                parenCount = 0;
                mruOperand = false;
                mruOperator = false;
        }
        else {
                expr_edit_row = ExprStringGrid->Row;
                ExprEnabledCombo->Text = ExprStringGrid->Cells[EXPR_ENABLED_COL][expr_edit_row];
                ExprExprEdit->Text = ExprStringGrid->Cells[EXPR_EXPR_COL][expr_edit_row];
                ExprCountMaskEdit->Text = ExprStringGrid->Cells[EXPR_COUNT_COL][expr_edit_row];
                if(ExprEnabledCombo->Text == "ON")
                        ExprEnabledCombo->ItemIndex = EXPR_ON;
                else
                        ExprEnabledCombo->ItemIndex = EXPR_OFF;

                // Reset the expression array elements, so a new expression can be constructed.
                for(int i = 0; i < MAX_LB_NODES; i++) {
                        infixExpr[i] = -1;
                }

                // Since an expression has already begun to be built,
                // reload the expression to allow for continued editing options.
                bpExpressions[expr_edit_row-1].getInfixExpr(infixExpr, infixCount);
                parenCount = 0;
                if(infixExpr[infixCount-1] != RPAREN)
                        mruOperand = true;
                else
                        mruOperand = false;
                mruOperator = false;
        }

        // Align the editable fields with the position of the currently
        // selected row within the ExpressStringGrid.
        int relativeHeight = ExprStringGrid->Top + 5 +
                (expr_edit_row - ExprStringGrid->TopRow + 1) *
                (ExprStringGrid->DefaultRowHeight + 1);
        ExprEnabledCombo->Visible = true;
        ExprEnabledCombo->Top = relativeHeight;
        ExprExprEdit->Visible = true;
        ExprExprEdit->Top = relativeHeight;
        ExprCountMaskEdit->Visible = true;
        ExprCountMaskEdit->Top = relativeHeight;

        setExprButtons();
}
//---------------------------------------------------------------------------

void __fastcall TBreaksFrm::RegColumnMoved(TObject *Sender, int FromIndex,
      int ToIndex)
{
        RegSelectCombo->Visible = false;
        RegOperatorCombo->Visible = false;
        RegValueMaskEdit->Visible = false;
        RegSizeCombo->Visible = false;
        setRegButtons();
}
//---------------------------------------------------------------------------

void __fastcall TBreaksFrm::AddrColumnMoved(TObject *Sender, int FromIndex,
      int ToIndex)
{
        AddrSelectMaskEdit->Visible = false;
        AddrOperatorCombo->Visible = false;
        AddrValueMaskEdit->Visible = false;
        AddrSizeCombo->Visible = false;
        AddrReadWriteCombo->Visible = false;
        setAddrButtons();
}
//---------------------------------------------------------------------------

void __fastcall TBreaksFrm::ExprColumnMoved(TObject *Sender, int FromIndex,
      int ToIndex)
{
        ExprEnabledCombo->Visible = false;
        ExprExprEdit->Visible = false;
        ExprCountMaskEdit->Visible = false;
        setExprButtons();
}
//---------------------------------------------------------------------------

void __fastcall TBreaksFrm::RegRowMoved(TObject *Sender, int FromIndex,
      int ToIndex)
{
        RegSelectCombo->Visible = false;
        RegOperatorCombo->Visible = false;
        RegValueMaskEdit->Visible = false;
        RegSizeCombo->Visible = false;
        setRegButtons();
}
//---------------------------------------------------------------------------


void __fastcall TBreaksFrm::RegTopLeftChanged(TObject *Sender)
{
        RegSelectCombo->Visible = false;
        RegOperatorCombo->Visible = false;
        RegValueMaskEdit->Visible = false;
        RegSizeCombo->Visible = false;
        setRegButtons();
}
//---------------------------------------------------------------------------

void __fastcall TBreaksFrm::AddrTopLeftChanged(TObject *Sender)
{
        AddrSelectMaskEdit->Visible = false;
        AddrOperatorCombo->Visible = false;
        AddrValueMaskEdit->Visible = false;
        AddrSizeCombo->Visible = false;
        AddrReadWriteCombo->Visible = false;
        setAddrButtons();
}
//---------------------------------------------------------------------------

void __fastcall TBreaksFrm::AddrRowMoved(TObject *Sender, int FromIndex,
      int ToIndex)
{
        AddrSelectMaskEdit->Visible = false;
        AddrOperatorCombo->Visible = false;
        AddrValueMaskEdit->Visible = false;
        AddrSizeCombo->Visible = false;
        AddrReadWriteCombo->Visible = false;
        setAddrButtons();
}
//---------------------------------------------------------------------------

void __fastcall TBreaksFrm::ExprRowMoved(TObject *Sender, int FromIndex,
      int ToIndex)
{
        ExprEnabledCombo->Visible = false;
        ExprExprEdit->Visible = false;
        ExprCountMaskEdit->Visible = false;
        setExprButtons();
}
//---------------------------------------------------------------------------

void __fastcall TBreaksFrm::ExprTopLeftChanged(TObject *Sender)
{
        ExprEnabledCombo->Visible = false;
        ExprExprEdit->Visible = false;
        ExprCountMaskEdit->Visible = false;
        setExprButtons();        
}
//---------------------------------------------------------------------------

void __fastcall TBreaksFrm::ExprLParenAppendButtonClick(TObject *Sender)
{
        // Make sure there is room for more array elements
        if(infixCount < MAX_LB_NODES) {
                AnsiString original = ExprExprEdit->Text;
                infixExpr[infixCount++] = LPAREN;
                original += ("  (  ");
                ExprExprEdit->Text = original;
                mruOperand = false;
                mruOperator = false;
                parenCount++;
        }
        setExprButtons();
}
//---------------------------------------------------------------------------

void __fastcall TBreaksFrm::ExprRParenAppendButtonClick(TObject *Sender)
{
        // Make sure there is room for more array elements
        if(infixCount < MAX_LB_NODES) {
                AnsiString original = ExprExprEdit->Text;
                infixExpr[infixCount++] = RPAREN;
                original += ("  )  ");
                ExprExprEdit->Text = original;
                mruOperand = false;
                mruOperator = false;
                parenCount--;
        }
        setExprButtons();
}
//---------------------------------------------------------------------------

void __fastcall TBreaksFrm::FormKeyDown(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
   if (Key == VK_F1)
     Form1->displayHelp("BREAKPOINT");
   else if (Key == VK_TAB && Shift.Contains(ssCtrl))    // if Ctrl-Tab
     Form1->BringToFront();
}
//---------------------------------------------------------------------------

void __fastcall TBreaksFrm::BringToFront()
{
  if(BreaksFrm->Visible)
    BreaksFrm->SetFocus();
  else
    Form1->BringToFront();
}
//---------------------------------------------------------------------------

