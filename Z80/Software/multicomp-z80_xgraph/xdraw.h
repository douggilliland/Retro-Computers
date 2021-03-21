/* ////////////////////////////////////////////////////////////////////
//  xdraw.h
//
//  General Graphic functions for the Multicomp Z80.
//
//
//  Copyright (c) 2018 Kurt Mueller / written for Multicomp-Z80
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
//  31 Jan 2019 : V1.00 Version for Multicomp-Graphic
//  ===================================================================
//
//  Notes:
//
//  Needs the xgraph.h library.
//
// Globals
// -------
//
// Structure of parameter field
// ============================
//  For more details see 'xgraph.asm' !
//  x_par[0] & x_par[1] holds always X0, Y0
//  x_par[2]...[4] holds various data depending on called func.
// -------------------------------------------------------------
//  x_par[0] = X0
//  x_par[1] = Y0
//  x_par[2] = mode, Oct, ...
//  x_par[3] = chr, byte, X1, ...
//  x_par[4] = addr, Y1, ...
///////////////////////////////////////////////////////////////////// */

/* Initialze the Graphic
// ---------------------
*/
InitGraphic()
{
    x_func   = X_Initgraph;

    x_call();
}

/* Switch Grahic-Screen ON/OFF
// ---------------------------
// Possible Param.:
//  'X_ON'  for Screen ON
//  'X_OFF' for Screen OFF
*/
GScreen(mode)
int mode;
{
    x_func   = X_GRON;
    x_par[2] = mode;

    x_call();
}

/* Clear Graphic Screen
// --------------------
// Possible Param.:
//  'X_BLACK' for Black Screen
//  'X_WHITE' for White Screen
*/
GClrScr(byte)
int byte;
{
    x_func   = X_GClrScr;
    x_par[3] = byte;

    x_call();
}

/* Set Line-Attr. for Lines on Screen
// ---------------------------------------
// Valid for both 'LoRes' & 'HiRes':
//
// XP_Pat0 = 0 := '****************' = 'OFF'
// XP_Pat1 = 1 := '-*-*-*-*-*-*-*-*'
// XP_Pat2 = 2 := '-**--**--**--**-'
// XP_Pat3 = 3 := '-**----**----**-'
// XP_Pat4 = 4 := '-**------**-----'
// XP_Pat5 = 5 := '-******--**--**-'
// XP_Pat6 = 6 := '-******--******-'
// XP_Pat7 = 7 := '-**-------------'
//
*/
SetLnStyle(PatNo)
int PatNo;
{
    x_func   = X_SetLnSty;
    x_par[2] = PatNo;

    x_call();
}

/*
// Set Bit-Mask for ploting quadrants
// -----------------------------------
// Possible values for 'mask':
// ================================================
//  XL_NULL = Plot nothing (for testing etc.)
//  XL_ALL  = Plot all Octants
//  XO_NNW  = Plot North-North-West Octant
//  XO_NNE  = Plot North-North-East Octant
//  XO_WWN  = Plot West-West-North  Octant
//  XO_EEN  = Plot East-East-North  Octant
//  XO_SSW  = Plot South-South-West Octant
//  XO_SSE  = Plot South-South-East Octant
//  XO_WWS  = Plot West-West-East   Octant
//  XO_EES  = Plot East-East-South  Octant
//
// Definition of Hemisphere's as of single Octant addition
//  XO_NOH  = XO_NNW + XO_NNE + XO_WWN + XO_EEN  : Plot Northern Hem.
//  XO_SOH  = XO_SSW + XO_SSE + XO_WWS + XO_EES  : Plot Southern Hem.
//  XO_WEH  = XO_NNW + XO_SSW + XO_WWS + XO_WWN  : Plot Western  Hem.
//  XO_EAH  = XO_NNE + XO_EEN + XO_EES + XO_SSE  : Plot Eastern  Hem.
//
// Definition of Quadrants's as of single Octant addition
//  XO_NWQ  = XO_NNW + XO_WWN  : Plot Northern Hem.
//  XO_NEQ  = XO_NNE + XO_EEN  : Plot Western  Hem.
//  XO_SWQ  = XO_SSW + XO_WWS  : Plot Southern Hem.
//  XO_SEQ  = XO_SSE + XO_EES  : Plot Eastern  Hem.
*/
SetQuad(mask)
int mask;
{
    x_func   = X_SetQuad;
    x_par[2] = mask;

    x_call();
}

/*
// Copy Ellipse-Struct with Oct.-Data to *ptr
// -------------------------------------------
// 'addr' = pointer to int array[50] or other
//          pointer to buffer with 100 bytes
//          in length.
*  return = LByte := Struct-Len, HByte := plotted oct.
*/
CopyStruct(addr)
int *addr;
{
    x_func   = X_GetStruct;
    x_par[2] = XO_NULL;
    x_par[3] = 0;
    x_par[4] = addr;

    x_call();
}

/*
// Search Ellipse-Struct for Oct.-Mask and
// return requested single Oct.-Coord. value
// ----------------------------------------
// 'octnum' values:
//    XO_NNW, XO_NNE, XO_WWN
//    XO_EEN, XO_SSW, XO_SSE
//    XO_WWS, XO_EES
//
// 'param' values:
//    XO_OctLnNum,
//    XO_OctStXCo, XO_OctStXCo,
//    XO_OctEnXCo, XO_OctEnYCo
//
// 'addr' value:
//   - pointer to int array[50]
//   - ret-value of FnElipse()
//   - pointer to 50 WORD large buffer
*/
SearchStruct(oct, param, addr)
int oct, param, *addr;
{
    x_func   = X_GetStruct;
    x_par[2] = oct;
    x_par[3] = param;
    x_par[4] = addr;

    if(oct == XO_ALL)
       return x_call() >> 8;
    else
       return x_call();
}

/*
// Get plotted Ellipse-Oct's-Mask
// ------------------------------------------
// Ret-Val = plotted Oct-Mask
*/
GetPltOct(addr)
int *addr;
{
    x_func   = X_GetStruct;
    x_par[2] = XO_ALL;
    x_par[3] = 0;
    x_par[4] = addr;

    return x_call() & 0x00FF;
}

/*
// Set Oct.-Mask, width & hight for RBox-Plotting
// -----------------------------------------------
// Possible Param.: As for 'SetQuad()'
// ===============================================
// The 'PltRBox'-Flag in 'STAT' will be automatically
// reset after plotting a circle or ellipse !
*/
SetRBox(mask, width, hight)
int mask, width, hight;
{
    x_func   = X_SetRBox;
    x_par[2] = mask;
    x_par[3] = width;
    x_par[4] = hight;

    x_call();
}

/* Set Pixel-Mode
// ---------------------------------
// Modes are:
//   XM_HiRes
//   XM_LoRes
//   XM_SET
//   XM_CLR
//   XM_INV
*/
SetPixMode(mode)
int mode;
{
    x_func   = X_SetPxMode;
    x_par[2] = mode;

    x_call();
}

/* Plot a pixel in the current draw mode
// -------------------------------------
*/
PlotPixel(x, y)
int x, y;
{
    x_func   = X_PltPix;
    x_par[0] = x;
    x_par[1] = y;

    x_call();
}

/* Return the state of a pixel
// ---------------------------
// Return NZ if set, else Z.
*/
GetPixel(x, y)
int x, y;
{
    x_func   = X_GetPix;
    x_par[0] = x;
    x_par[1] = y;

    return x_call();
}

/* Draw a line in the current draw mode
// ------------------------------------
*/
FnLine(x0, y0, x1, y1)
int x0, y0, x1, y1;
{
    x_func   = X_FnLine;
    x_par[0] = x0;
    x_par[1] = y0;
    x_par[3] = x1;
    x_par[4] = y1;

    x_call();
}


/* Draw a line starting at Px(x0,y0) with
// slope (width,hight) in the current draw
// mode
// ------------------------------------
*/
FnLineWH(x0, y0, width, hight)
int x0, y0, width, hight;
{
    x_func   = X_FnLine2;
    x_par[0] = x0;
    x_par[1] = y0;
    x_par[3] = width;
    x_par[4] = hight;

    x_call();
}


/* Draw a Box in the current draw mode
// -----------------------------------
*/
FnBox(x, y, width, hight)
int x, y, width, hight;
{
    x_func   = X_FnBox;
    x_par[0] = x;
    x_par[1] = y;
    x_par[3] = width;
    x_par[4] = hight;

    x_call();
}

/* Draw a Triangle in the current draw mode
// -----------------------------------------
*/
FnTriangle(x, y, width, hight)
int x, y, width, hight;
{
        FnLineWH(x,y,(width >> 1)+1,hight);
        FnLineWH(x+width,y,-(width >> 1),hight);
        FnLine(x,y,x+width,y);
}

/* Draw a circle in the current draw mode
// --------------------------------------
// Return: hl = Pointer to Oct-Coord. Array
*/
FnCircle(x0, y0, r1)
int x0, y0, r1;
{
    return FnEllipse(x0, y0, r1, r1);
}

/* Draw circle (width =  hight) or
//     ellipse (width <> hight)
// ===========================================
// Return: hl = Pointer to Oct-Coord. Array
*/
FnEllipse(x, y, width, hight)
int x, y, width, hight;
{
    x_func   = X_FnEllipse;
    x_par[0] = x;
    x_par[1] = y;
    x_par[3] = width;
    x_par[4] = hight;

    return x_call();
}

/* Draw a RBox-Circle in the current draw mode
// --------------------------------------
// Return: Pointer to Oct-Coord. Array
*/
FnRBCircle(x0, y0, r1, rbwidth, rbhight)
int x0, y0, r1, rbwidth, rbhight;
{
    int OctCoord;

    SetRBox(XO_ALL,rbwidth,rbhight);
    OctCoord = FnEllipse( x0, y0, r1,r1);

    FnLine(SearchStruct(XO_SSW, XO_OctStXCo, OctCoord),
           SearchStruct(XO_SSW, XO_OctStYCo, OctCoord),
           SearchStruct(XO_SSE, XO_OctStXCo, OctCoord),
           SearchStruct(XO_SSE, XO_OctStYCo, OctCoord));

    FnLine(SearchStruct(XO_NNE, XO_OctStXCo, OctCoord),
           SearchStruct(XO_NNE, XO_OctStYCo, OctCoord),
           SearchStruct(XO_NNW, XO_OctStXCo, OctCoord),
           SearchStruct(XO_NNW, XO_OctStYCo, OctCoord));

    FnLine(SearchStruct(XO_EES, XO_OctStXCo, OctCoord),
           SearchStruct(XO_EES, XO_OctStYCo, OctCoord),
           SearchStruct(XO_EEN, XO_OctStXCo, OctCoord),
           SearchStruct(XO_EEN, XO_OctStYCo, OctCoord));

    FnLine(SearchStruct(XO_WWS, XO_OctStXCo, OctCoord),
           SearchStruct(XO_WWS, XO_OctStYCo, OctCoord),
           SearchStruct(XO_WWN, XO_OctStXCo, OctCoord),
           SearchStruct(XO_WWN, XO_OctStYCo, OctCoord));

    return OctCoord;
}

/* Draw a RBox-Ellipse in the current draw mode
// --------------------------------------
// Return: Pointer to Oct-Coord. Array
*/
FnRBEllipse(x0, y0, r1, r2, rbwidth, rbhight)
int x0, y0, r1, r2, rbwidth, rbhight;
{
    int OctCoord;

    SetRBox(XO_ALL,rbwidth,rbhight);
    OctCoord = FnEllipse( x0, y0, r1,r2);

    FnLine(SearchStruct(XO_SSW, XO_OctStXCo, OctCoord),
           SearchStruct(XO_SSW, XO_OctStYCo, OctCoord),
           SearchStruct(XO_SSE, XO_OctStXCo, OctCoord),
           SearchStruct(XO_SSE, XO_OctStYCo, OctCoord));

    FnLine(SearchStruct(XO_NNE, XO_OctStXCo, OctCoord),
           SearchStruct(XO_NNE, XO_OctStYCo, OctCoord),
           SearchStruct(XO_NNW, XO_OctStXCo, OctCoord),
           SearchStruct(XO_NNW, XO_OctStYCo, OctCoord));

    FnLine(SearchStruct(XO_EES, XO_OctStXCo, OctCoord),
           SearchStruct(XO_EES, XO_OctStYCo, OctCoord),
           SearchStruct(XO_EEN, XO_OctStXCo, OctCoord),
           SearchStruct(XO_EEN, XO_OctStYCo, OctCoord));

    FnLine(SearchStruct(XO_WWS, XO_OctStXCo, OctCoord),
           SearchStruct(XO_WWS, XO_OctStYCo, OctCoord),
           SearchStruct(XO_WWN, XO_OctStXCo, OctCoord),
           SearchStruct(XO_WWN, XO_OctStYCo, OctCoord));

    return OctCoord;
}

/* ***** Schluß mit lustig ***** */
