/* /////////////////////////////////////////////////////////////////////
//         xchrdef.h
//
//  Text-Def. Functions for the Multicomp.
//
//
//  Get / set definitions of internal/ext. Char-font.
//
//  Copyright (c) 2019 Kurt Mueller / written for Multicomp Z80
//  ===================================================================
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2, or (at your option)
//  any later version.
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
//  31 Jan 2019 : 1.0 : 1st Version for Multicomp-Graphic
//  ===================================================================
//
//  Notes:
//
//  Needs the xgraph.h library.
///////////////////////////////////////////////////////////////////// */


/* Set address for ext. Font-ROM
// -----------------------------
*/
SetTxFnt(addr)
int addr;
{
    x_func   = X_SetTxFnt;

    x_par[4] = addr;

    x_call();
}

/* Reset ext. Font-ROM address to internal Font-ROM
// -------------------------------------------------
*/
ResTxFnt()
{
    x_func   = X_ResTxFnt;

    x_call();
}


/* Read 1 Char from addr to internal ChrBuf
// -----------------------------------------
// HL = Returns pointer to next position
//      behind last char-byte in memory
// Address-Calc.: addr = addr + (chr * 8)
// If 'addr' should be used without offset,
// set 'chr' to '0x00'
*/
RdChfrAddr(chr, addr)
int chr; BYTE *addr;
{
    x_func   = X_RdChfrAddr;

    x_par[3] = chr;
    x_par[4] = addr;

    return x_call();
}

/* Write 1 Char from internal ChrBuf to addr
// -------------------------------------------
// HL = Returns pointer to next position
//      behind last char-byte in memory
// Address-Calc.: addr = addr + (chr * 8)
// If 'addr' should be used without offset,
// set 'chr' to '0x00'
*/
WrChToAddr(chr, addr)
int chr; BYTE *addr;
{
    x_func   = X_WrChToAddr;

    x_par[3] = chr;
    x_par[4] = addr;

    return x_call();
}

/* Write 1 Char from CharBuf to screen
// -----------------------------------
// (Row,Col)-Coord. are used for addr-calc.
*/
PutChRC(x, y)
int x, y;
{
    x_func   = X_PutChRC;

    x_par[0] = x;
    x_par[1] = y;

    x_call();
}

/* Read 1 Char from screen to CharBuf
// ----------------------------------
// (Row,Col)-Coord. are used for addr-calc.
*/
GetChRC(x, y)
int x, y;
{
    x_func   = X_GetChRC;

    x_par[0] = x;
    x_par[1] = y;

    x_call();
}

/* Read 1..n Char from Font-ROM and write to addr
// ----------------------------------------------
// Transfer starts at (0x000 + (chr * 8)) in Font-ROM !
// If a ext. Font-ROM is defined, the address set with
// 'SetTxFnt' is used for Font-ROM access.
// 'addr' to memory is used without any offset !
*/
RdFntROM(n, chr, addr)
int n, chr; BYTE *addr;
{
    x_func   = X_RdfrFnROM;

    x_par[2] = n;
    x_par[3] = chr;
    x_par[4] = addr;

    x_call();
}

/* Write 1..n Char from addr to Font-ROM
// ------------------------------------
// Transfer starts at 'chr' in Font-ROM !
// If a ext. Font-ROM is defined, the address set with
// 'SetTxFnt' is used for Font-ROM access.
// 'addr' is used without any offset !
*/
WrFntROM(n, chr, addr)
int n, chr; BYTE *addr;
{
    x_func   = X_WrToFnROM;

    x_par[2] = n;
    x_par[3] = chr;
    x_par[4] = addr;

    x_call();
}
