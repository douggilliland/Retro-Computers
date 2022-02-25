
/***************************** 68000 SIMULATOR ****************************

File Name: BPointExpr.cpp
Version: 1.0
Debugger Component

This file contains various routines and data members to store and access the
BPointExpr data structure that contains breakpoint expression information
entered manually by the user.

The routines are : BPointExpr(); ~BPointExpr(); int getId(); void setId(int);
void setPostfixExpr(int *, int); void getPostfixExpr(int *, int &);
void setInfixExpr(int *, int); void getInfixExpr(int *, int &);
AnsiString getExprString(); void setExprString(AnsiString); int getCount();
void setCount(int); bool isBreak(); bool isEnabled(); void isEnabled(bool);

***************************************************************************/

#include <assert.h>
#include "extern.h"
#include "BPointExpr.h"

#include "BREAKPOINTSu.h"

// Default constructor
BPointExpr::BPointExpr() {}

// Destructor
BPointExpr::~BPointExpr() {}


int BPointExpr::getId() {
        return id;
}

void BPointExpr::setId(int _id) {
        id = _id;
}

void BPointExpr::setPostfixExpr(int * _postfix_expr, int _p_count) {
        p_count = _p_count;
        for(int p = 0; p < p_count; p++)
                postfix_expr[p] = _postfix_expr[p];
}

void BPointExpr::getPostfixExpr(int * _postfix_expr, int & _p_count) {
        _p_count = p_count;
        for(int p = 0; p < p_count; p++)
                _postfix_expr[p] = postfix_expr[p];
}


void BPointExpr::setInfixExpr(int * _infix_expr, int _i_count) {
        i_count = _i_count;
        for(int i = 0; i < i_count; i++)
                infix_expr[i] = _infix_expr[i];
}

void BPointExpr::getInfixExpr(int * _infix_expr, int & _i_count) {
        _i_count = i_count;
        for(int i = 0; i < i_count; i++)
                _infix_expr[i] = infix_expr[i];
}

AnsiString BPointExpr::getExprString() {
        return expr;
}

void BPointExpr::setExprString(AnsiString _expr) {
        expr = _expr;
}

int BPointExpr::getCount() {
	return count;
}

void BPointExpr::setCount(int _count) {
	count = _count;
}

bool BPointExpr::isEnabled() {
	return isEnab;
}

void BPointExpr::isEnabled(bool _isEnab) {
	isEnab = _isEnab;
}

/*Postfix expression evaluation
(http://www-106.ibm.com/developerworks/java/library/j-w3eval/?dwzone=java)
Evaluating a postfix expression is simpler than directly evaluating an
infix expression. In postfix notation, the need for parentheses is eliminated
and the priority of the operators is no longer relevant.
You can use the following algorithm to evaluate postfix expressions:
*/
bool BPointExpr::isBreak() {
        // If the breakpoint is turned off, then don't process
        if(!isEnab)
                return false;

        // Initialize an empty stack.
        stack<bool> s_operand;
        int curToken;

        // Read the postfix expression from left to right.
        for(int e = 0; e < p_count; e++) {
                curToken = postfix_expr[e];

                // If the character is an operand, push it onto the stack.
                if(curToken >= 0 && curToken < MAX_BPOINTS)  {
                        // Is the current breakpoint valid?
                        // Push the result onto the operand stack.
                        s_operand.push(breakPoints[curToken].isBreak());
                }
                else {
                        // If the character is an operator, pop two operands, perform the
                        // appropriate operation, and then push the result onto the stack.
                        // If you could not pop two operators, the syntax of the postfix
                        // expression was not correct.
                        bool aCondition = s_operand.top();
                        s_operand.pop();
                        bool bCondition = s_operand.top();
                        s_operand.pop();
                        bool curCondition = false;
                        switch(curToken) {
                                case MAX_BPOINTS + AND_OP:
                                        curCondition = aCondition && bCondition;
                                        break;
                                case MAX_BPOINTS + OR_OP:
                                        curCondition = aCondition || bCondition;
                                        break;
                                default:
                                        curCondition = false;
                                        break;
                        }
                        s_operand.push(curCondition);
                }
        }

        // At the end of the postfix expression, pop a result from the stack.
        // If the postfix expression was correctly formed, the stack should be empty.
        isBrk = s_operand.top();
        s_operand.pop();

        // Verify that the condition has been met the specified number of times.
        if(isBrk) bpCountCond[id]++;
        isBrk = (count == bpCountCond[id]);
        if(isBrk) bpCountCond[id] = 0;          // Reset counter for next iteration.
	return isBrk;
}




