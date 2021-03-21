/* /////////////////////////////////////////////////////////////////////
//        xsys.h
//
//
//  Copyright (c) 2018 Kurt Mueller / Adapted/Modified for Multicomp Z80
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
//  31 Jan 2019 . V1.00 : For Multicomp-Graphic
//
//  Notes:
//
///////////////////////////////////////////////////////////////////// */

/* Return RSX-Version Number
// ---------------------------------------------
// Return: hl = Ver-Number
*/
RSXVersion()
{
    x_func   = X_RSXVersion;

    return x_call();
}

/* Returns Pointer to RSX-Name
// ---------------------------------------------
// Name string is zero terminated
// Return: hl = *Ptr
*/
RSXName()
{
    x_func   = X_RSXName;

    return x_call();
}

/* Write Byte to Screen using
// addr from CalcXY or CalcRC
// --------------------------------
*/
ScrPortWr(addr, data)
int addr, data;
{
    x_func   = X_ScrPortWr;
    x_par[3] = data;
    x_par[4] = addr;

    x_call();
}

/* Read Byte from Screen using
// addr from CalcXY or CalcRC
// --------------------------------
// Ret.-Value = 0..255 only
*/
ScrPortRd(addr)
int addr;
{
    x_func   = X_ScrPortRd;
    x_par[4] = addr;

    return x_call();
}

/* Set Pattern-Rotation ON/OFF
// -------------------------------------
// Possible Param.:
//   X_ON  = Rotation ON
//   X_OFF = Rotation OFF
// ON/OFF doesn't change pattern
// rotation state
*/
SetPatRot(stat)
int stat;
{
    x_func   = X_SetPatRot;
    x_par[2] = stat;

    x_call();
}

/* Rotate Pattern 1 position left
// ----------------------------------
//
*/
RotatePat()
{
    x_func   = X_RotatePat;

    x_call();
}

/* Re-Load selected Pattern
// ----------------------------------
//
*/
ReLoadPat()
{
    x_func   = X_ReLoadPat;

    x_call();
}

/* Return the Pixel-Mask for Px(X;Y)
// ------------------------------------
// Pixel-Mask in LByte of returned value
*/
GetPixMask(x, y)
int x, y;
{
    x_func   = X_GetPxMask;
    x_par[0] = x;
    x_par[1] = y;

    return x_call();
}

/* Get Status-Bits of RSX-Graphic
// ---------------------------
// IF STAT-Bit = 'SET' then 'TRUE' ELSE 'FALSE';
// Possible Mask-Param.:
//  XS_ALLBITS  =  0 Enables all Status-Bits
//  XS_RCXY     =  2   0=RC       or 1=XY mode for text
//  XS_TWIDTH   =  4   0=Single   or 1=Double width text
//  XS_TMODE    =  8   0=invers   or 1=noninvers text
//  XS_HIRES    =  16  0=LoRes    or 1=HiRes for Pixel-Graphic
//  XS_PxMODSC  =  32  0=SET      or 1=CLR pixel mode
//  XS_PxMODIN  =  64  0=nonINV   or 1=INV (1=INV pixel mode, 'INV'
//                                     has precedence over SET/CLR)
//  XS_TxTFNT   =  128 0=internal or 1=external text font
//                     if 'TxTFNT' is set and 'addr' for ext. text-font
//                     is 0x0000, 'TxTFNT' will be reset by RSX-system
//  XS_USEPAT   =  256 0=No Line-Pattern    or 1=Use Line-Pattern
//  XS_PATROT   =  512 0=Patter-Rot. active or 1=Pattern-Rot. inactive
//  XS_RBOX     = 1024 0=No RBox plotting   or 1=RBox plotting requested
//                     This Bit is auto-reset to '0' after plotting !
// =====================================================================
// the readback value is: 'NOT SET' = '0' = FALSE | 'SET' = '-1' = TRUE
*/
GetStat(mask)
int mask;
{
    x_func   = X_GetSTAT;
    x_par[2] = mask;

    return x_call();
}

/* Return the RAM-Addr. for Px(X;Y)
// ------------------------------------
//
// Px(X;Y) points to a Pixel. Coord.-
// Range is Px[0..319;0..239]. The
// returned [addr] points to the Byte
// that holds the Pixel !
//
*/
CalcXY(x, y)
int x, y;
{
    x_func   = X_CalcXY;
    x_par[0] = x;
    x_par[1] = y;

    return x_call();
}

/* Return the RAM-Addr. for Pc(X;Y)
// ------------------------------------
// Pc(X;Y) points to Byte[0] of a Char.-
// Cell. 1 Char.-Cell: Byte[0]..Byte[7]
// Coord.-Range is Px[0..79;0..29].
*/
CalcRC(x, y)
int x, y;
{
    x_func   = X_CalcXY;
    x_par[0] = x;
    x_par[1] = y;

    return x_call();
}

