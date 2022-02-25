
/***************************** 68000 SIMULATOR ****************************

File Name: BPointExpr.h
Version: 1.0
Debugger Component

This file contains the definitions of various routines and data members
to store and access the BPointExpr data structure that contains breakpoint
expression information entered manually by the user.

***************************************************************************/

#include <vcl.h>
#pragma hdrstop

#include "BPoint.h"

#ifndef BPOINT_EXPR
#define BPOINT_EXPR

class BPointExpr {

	public:
                        BPointExpr();
                        ~BPointExpr();
                        int getId();
                        void setId(int);
                        void setPostfixExpr(int *, int);
                        void getPostfixExpr(int *, int &);
                        void setInfixExpr(int *, int);
                        void getInfixExpr(int *, int &);
                        AnsiString getExprString();
                        void setExprString(AnsiString);
                        int getCount();
                        void setCount(int);
                        bool isBreak();
                        bool isEnabled();
                        void isEnabled(bool);

	private:
                        int id;		// Uniquely identifies breakpoint expression.
                        int postfix_expr[MAX_LB_NODES];
                        int infix_expr[MAX_LB_NODES];
                        int p_count; // Number of valid postfix_expr elements
                        int i_count;
                        AnsiString expr;    // Expression is stored linearly for display.
                        int count;	    // Specifies a count for the number of times the other
                                            // expression conditions must be met before isBrk is true.
                        bool isBrk;	    // Flag whether or not the condition to break has been met.
                        bool isEnab;	// Flag whether or not the expression is being tested.
};

#endif