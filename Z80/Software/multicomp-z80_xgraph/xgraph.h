/* /////////////////////////////////////////////////////////////////////
//        xgraph.h
//
//  Graphical Definitions functions for the Multicomp Z80.
//
//  Basic library.
//  ==============
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
//  Needs the RSX xgraph.asm
///////////////////////////////////////////////////////////////////// */

/* RSX functions
// --------------
//
// *****************************************************************************
// ************************** Function Table: **********************************
// *****************************************************************************
// Func Param.       Number     RSX-Name     Description
// =============================================================================
//      x_call Label: Func-Num: Ass.-Label:  Comment:
// ============================================================================= */
#define X_Hello        0;   /*  Hello        Detect RSX */
#define X_RSXVersion   1;   /*  RSX-Vers.    Return RSX-Version No. */
#define X_RSXName      2;   /*  RSX-Name     Return Pointer to RSX-Name */
#define X_Initgraph    3;   /*  Initgraph    Init Graphic-System */
#define X_GetSTAT      4;   /*  GetStat      Get 'STAT'-Register Bits */
#define X_SetPxMode    5;   /*  SetPxMode    Set Bit-Flags for Pixel-Mode */
#define X_SetTxMode    6;   /*  SetTxMode    Set Bit-Flags for Text-Mode */
#define X_GRON         7;   /*  GRON         Graphic-Screen ON/OFF */
#define X_ACON         8;   /*  ACON         ASCII-Cursor   ON/OFF */
#define X_GClrScr      9;   /*  GClrScr      Clear entire Graphic Screen (Write w/ Byte) */
#define X_PutScrRC    10;   /*  PutScrRC     Write to screen from addr to addr+count with 'byte' */
#define X_WrToFnROM   11;   /*  WrToFnROM    Write n Char from addr     to Font-ROM */
#define X_RdfrFnROM   12;   /*  RdfrFnROM    Read  n Char from Font-ROM to addr */
#define X_SetTxFnt    13;   /*  SetTxFNT     Define Addr. of ext. Font set */
#define X_ResTxFnt    14;   /*  ResTxFnt     Define Font as internal */
#define X_SetLnSty    15;   /*  SetLnSty     Set Line Style Pattern */
#define X_SetPatRot   16;   /*  SetPatRot    Stop or Enable Line Pattern Rotation */
#define X_RotatePat   17;   /*  RotatePat    Rotate Line Pattern by 1 Position to the left */
#define X_ReLoadPat   18;   /*  LoadPat      Re-Load Pattern from 'SELPAT' to 'USEPAT' */
#define X_PrintChr    19;   /*  OutChr       Print single ASCII-Char on Screen at Px(x,y)|Pc(r,c) */
#define X_PrintStr    20;   /*  OutStr       Print ASCII-String on Screen at Px(x,y)|Pc(r,c) */
#define X_PltPix      21;   /*  PltPix       Set/Clr/Inv Pixel on Screen (for 640/320 Res.) */
#define X_GetPix      22;   /*  GetPix       Get status of pixel at Px(x,y) */
#define X_GetPxMask   23;   /*  GetPxMask    Get Pixel Mask for Pixel at Px(x,y) */
#define X_ScrPortRd   24;   /*  ScrPortRd    Read  Byte from addr on Screen */
#define X_ScrPortWr   25;   /*  ScrPortWr    Write Byte to addr on Screen */
#define X_PutChRC     26;   /*  PutChRC      Write 1 Char from ChrBuf to Screen */
#define X_GetChRC     27;   /*  GetChRC      Read  1 Char from Screen to ChrBuf */
#define X_WrChToAddr  28;   /*  WrChToAddr   Write 1 Char from ChrBuf to 'addr' in memory */
#define X_RdChfrAddr  29;   /*  RdChToAddr   Read  1 Char from 'addr' in memory to ChrBuf */
#define X_GetBmpRC    30;   /*  GetBmpRC     Read Bitmap  from Pc(r,c,width,hight) to addr */
#define X_PutBmpRC    31;   /*  PutBmpRC     Write Bitmap from addr to Pc(r,c,width,hight) */
#define X_WriteBmpRC  32;   /*  WriteBmpRC   copy a Bitmap from addr to screen w/ aspect-ratio corr. */
#define X_CalcRC      33;   /*  CalcRC       Calculate addr from Pc(r,c) */
#define X_CalcXY      34;   /*  CalcXY       Calculate addr from Px(x,y) and Pix-Mask */
#define X_SetQuad     35;   /*  SetQuad      Load Quadrant definition for FnCircle/FnEllipse*/
#define X_ResQuad     36;   /*  ResQuad      Reset Quadrant disable status */
#define X_ChkQuad     37;   /*  ChkQuadStat  Check Quadrant against Bit-Mask*/
#define X_GetStruct   38;   /*  GetStruct    Get Ell.-Struct. or requested single Param. */
#define X_SetRBox     39;   /*  SetRBox      Set 'PltRBox'-Flag & 'xwidth'/'yhight' for RBox */
#define X_ResRBox     40;   /*  ResRBox      Rseet PltRBox, width & hight for RBox-Plotting */
#define X_FnLine      41;   /*  FnLine       Plot Line Px(x1,y1,x2,y2) */
#define X_FnLine2     42;   /*  FnLine2      Plot Line Px(x1,y1,width,hight) */
#define X_FnBox       43;   /*  FnBox        Plot Box  Px(x,y,width,hight) */
#define X_FnEllipse   44;   /*  FnEllipse    Plot a Ellipse at Px(x,y,width,hight */
/* ************************************************************************************************** */


/* STAT-Register
// -------------
*/
#define XS_ALL        -1
#define XS_RCXY        2
#define XS_TWIDTH      4
#define XS_TMODE       8
#define XS_HIRES      16
#define XS_PxMODSC    32
#define XS_PxMODIN    64
#define XS_TxTFNT    128
#define XS_USEPAT    256
#define XS_PATROT    512
#define XS_RBOX     1024

/* Draw modes
// ----------
*/
#define XM_HiRes 0
#define XM_LoRes 1
#define XM_SET   2
#define XM_CLR   3
#define XM_INV   4

/* Line Graphic
// -----------------------------------
// Circle, Ellipse, Box, Triangle
// Bit-Flags for Sector switching
// Beware: also defined in 'xgraph.asm' ! Defiintion
//         precedence is here, 'xgraph.asm' follows !
*/
#define XO_NULL   0  /* Plot nothing (for testing etc.) */
#define XO_ALL   -1  /* Plot all Quadrants              */
#define XO_NNW    1  /* Plot North-North-West Octant */
#define XO_NNE    2  /* Plot North-North-East Octant */
#define XO_WWN    4  /* Plot West-West-North  Octant */
#define XO_EEN    8  /* Plot East-East-North  Octant */
#define XO_SSW   16  /* Plot South-South-West Octant */
#define XO_SSE   32  /* Plot South-South-East Octant */
#define XO_WWS   64  /* Plot West-West-South  Octant */
#define XO_EES  128  /* Plot East-East-South  Octant */

/* Def's of Octant-Numbers for Procesing the FnEllipse Data-Structure */
#define XO_OctLnNum 0  /* Oct. + Linestyle-Number */
#define XO_OctStXCo 1  /* Oct. Start X_Coord.     */
#define XO_OctStYCo 2  /* Oct. Start Y-Coord.     */
#define XO_OctEnXCo 3  /* Oct. End X-Coord.       */
#define XO_OctEnYCo 4  /* Oct. End Y-Coord.       */

/*Definition of Hemisphere's as addition of single Octants */
#define XO_NOH  (XO_NNW + XO_NNE + XO_WWN + XO_EEN) /* Northern Hem. */
#define XO_SOH  (XO_SSW + XO_SSE + XO_WWS + XO_EES) /* Southern Hem. */
#define XO_WEH  (XO_NNW + XO_SSW + XO_WWS + XO_WWN) /* Western  Hem. */
#define XO_EAH  (XO_NNE + XO_EEN + XO_EES + XO_SSE) /* Eastern  Hem. */

/*Definition of Quadrant's as addition of single Octants */
#define XO_NWQ  (XO_NNW + XO_WWN) /* Plot North-West Quadr. */
#define XO_NEQ  (XO_NNE + XO_EEN) /* Plot North-East Quadr. */
#define XO_SWQ  (XO_SSW + XO_WWS) /* Plot South-West Quadr. */
#define XO_SEQ  (XO_SSE + XO_EES) /* Plot South-East Quadr. */

/* Line Style PatNumbers
// ----------
*/
#define XP_Pat0   0  /* '****************' */
#define XP_Pat1   1  /* '-*-*-*-*-*-*-*-*' */
#define XP_Pat2   2  /* '-**--**--**--**-' */
#define XP_Pat3   3  /* '-**----**---**--' */
#define XP_Pat4   4  /* '-**------**-----' */
#define XP_Pat5   5  /* '-******--**--**-' */
#define XP_Pat6   6  /* '-******--******-' */
#define XP_Pat7   7  /* '-**-------------' */

/* Text attributes
// ---------------
*/
#define XA_RC      0  /* set RC-coord. mode     */
#define XA_XY      1  /* set XY-coord. mode     */
#define XA_DW      2  /* Prt. Double-Width Text */
#define XA_SW      3  /* Prt. Single-Width Text */
#define XA_TI      4  /* Prt. text invers       */
#define XA_TN      5  /* Prt. text noninvers    */

/* Other
// -----
*/
#define X_BUFSIZE      640     /* Buffer size for 1 Char-Line */
#define X_BUFCOLS      80      /* Buffer size in Char-columns */
#define X_SCRROWS      30      /* Max. Rows on ASCII & Graphic Screen */
#define X_SIGNATURE    0xDADA  /* RSX signature for X_Hello function */
#define X_MaxGraphRAM  19200   /* Graphic-RAM = 19200 Byte in length */
#define X_ON           0       /* Set to "ON"  */
#define X_OFF          -1      /* Set to "OFF" */
#define X_BLACK        0       /* Set to "Black"  */
#define X_WHITE        -1      /* Set to "White" */

/* Globals
// -------
*/
extern WORD x_dat;    /* Start-Label of RSX data block */
extern WORD x_func;   /* RSX function number */
extern WORD x_par[7]; /* RSX function parameters array */


#asm                  /* RSX data block */
x_dat:
       defb 9  ;Function
       defb 7  ;# of parameters (defw below, incl. x_func.)
x_func:
       defw 0  ;# of Subfunction called
x_par:
       defw 0  ;X
       defw 0  ;Y
       defw 0  ;mode
       defw 0  ;char
       defw 0  ;addr
#endasm


/* Call to RSX
// -----------
// Returns something or nothing, according to the called function.
*/
#asm
x_call:
    ld c,60
    ld de,x_dat
    jp 5
#endasm

/* Check if the RSX is in memory
// -----------------------------
// Returns NZ if true, else Z
*/
HelloRsx()
{
    x_func = X_Hello;

    return x_call() == X_SIGNATURE;
}
