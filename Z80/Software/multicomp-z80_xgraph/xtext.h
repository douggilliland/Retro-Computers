/* /////////////////////////////////////////////////////////////////////
//  xtext.h
//
//  Text Graphic functions for the Multicomp-Z80.
//
//  Text output library.
//  ====================
//
//  Copyright (c) 2019 Kurt Mueller / Written for Multicomp-Z80
//  ===================================================================
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the
//  Free Software Foundation; either version 2, or (at your option) any
//  later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
//
//  Changes:
//
//  31 Jan 2019 : 1st Version for Multicomp-Graphic w/ xgraph
//
///////////////////////////////////////////////////////////////////// */
/*
    Notes:

    Needs the xgraph.h library.
*/


/* Clear ASCII screen, and cursor to 0,0
// --------------------------------------
*/
AClrScr()
{
    putch(27); putch('['); putch('H');             /* Home */
    putch(27); putch('['); putch('2'); putch('J'); /* Cls  */

}

/* Switch Cursor OFF
// -------------------
*/
HideCursor()
{
    x_func   = X_ACON;
    x_par[2] = X_OFF;

    x_call();
}

/* Switch Cursor ON
// ------------------
*/
ShowCursor()
{
    x_func   = X_ACON;
    x_par[2] = X_ON;

    x_call();
}

/* Set int. Font
// ---------------------------------
*/
SetIntFnt()
{
    x_func   = X_ResTxFnt;

    x_call();
}

/* Set ext. Font-Address
// ---------------------------------
*/
SetExtFnt(addr)
int addr;
{
    x_func   = X_SetTxFnt;
    x_par[4] = addr;

    x_call();
}

/* Set text mode
// ---------------------------------
//Possible func. param.:
// XA_RC = set RC-coord. mode
// XA_XY = set XY-coord. mode
// XA_DW = Prt. Double-Width Text
// XA_SW = Prt. Single-Width Text
// XA_TI = Prt. text invers
// XA_TN = Prt. text noninvers
*/
SetTxMode(mode)
int mode;
{
    x_func   = X_SetTxMode;
    x_par[2] = mode;

    x_call();
}

/* Print a character n times
// -------------------------
// 'chr' is the ASCII-Code,
// this enshures the use of
// non-printable char's too.
// Non-Printable code should
// be entered as: 0x10, key-
// board reachable char. en-
// closed in single quotes
// as 'x'.
*/
PrintChRpt(x,y,n,chr)
int x, y, n, chr;
{
    n &= 0xFF;
    while(n--) {
        PrintChr(x++, y, chr);
    }
}

/* Print a character
// -------------------------
// 'chr' is the ASCII-Code !
// non-pritable Codes are shown
// in there symbol representation !
// Non-Printable code should
// be entered as 0x10 or key-
// board reachable char. en-
// closed in single quotes
// as 'x'.
*/
PrintChr(x, y, chr)
int x, y, chr;
{
    x_func   = X_PrintChr;
    x_par[0] = x;
    x_par[1] = y;
    x_par[3] = chr;

    x_call();
}

/* Print Chr-String on Screen
// ---------------------------------
// str should be entered in double-
// quotes as "Hello Dolly".
*/
PrintStr(x, y, str)
int x, y;
char *str;
{
    x_func   = X_PrintStr;
    x_par[0] = x;
    x_par[1] = y;
    x_par[4] = str;

    x_call();
}

