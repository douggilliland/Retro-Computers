/*
 *  ctypetab.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <ctype.h>

/*------------------------------- _ctype_tab[] ------------------------------*

/*
 * _ctype_tab is the table used by the ctype.h macros to determine the
 * charcter types by table look-up.
 */

const unsigned char _ctype_tab[] = {
    0,
    _C, _C, _C, _C, _C, _C, _C, _C, 
    _C, _S|_C, _S|_C, _S|_C, _S|_C, _S|_C, _C, _C, 
    _C, _C, _C, _C, _C, _C, _C, _C, 
    _C, _C, _C, _C, _C, _C, _C, _C, 
    _S, _P, _P, _P, _P, _P, _P, _P, 
    _P, _P, _P, _P, _P, _P, _P, _P, 
    _X|_O|_D, _X|_O|_D, _X|_O|_D, _X|_O|_D,
    _X|_O|_D, _X|_O|_D, _X|_O|_D, _X|_O|_D, 
    _X|_D, _X|_D, _P, _P, _P, _P, _P, _P, 
    _P, _U|_X, _U|_X, _U|_X, _U|_X, _U|_X, _U|_X, _U, 
    _U, _U, _U, _U, _U, _U, _U, _U, 
    _U, _U, _U, _U, _U, _U, _U, _U, 
    _U, _U, _U, _P, _P, _P, _P, _P, 
    _P, _L|_X, _L|_X, _L|_X, _L|_X, _L|_X, _L|_X, _L, 
    _L, _L, _L, _L, _L, _L, _L, _L, 
    _L, _L, _L, _L, _L, _L, _L, _L, 
    _L, _L, _L, _P, _P, _P, _P, _C
};
