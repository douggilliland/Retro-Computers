/* /////////////////////////////////////////////////////////////////////
//      xdemo3.c
//
//  Demo for the xgraph graphical and text functions.
//
//  Copyright (c)2019 Kurt Mueller written for Multicomp Z80
//  ===================================================================
//
//  -------------------------------------------------------------------
//   MESCC:
//   Copyright (c) 2015 Miguel I. Garcia Lopez / FloppySoftware, Spain
//   (MESCC is part of Miguel I. Garcia Lopez RetroProjects
//                                            'xpcw' package on Github)
//  -------------------------------------------------------------------
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
//  To compile with MESCC:
//
//  cc xdemo3
//  zsm xdemo3
//  hexcom xdemo3
//  gencom xdemo3.com xgraph.rsx
//
//  Changes:
//
//  31 Jan 2019 : First Version for Multicomp-Graphic
//
///////////////////////////////////////////////////////////////////// */

/* Some defines for MESCC
// ----------------------
*/
#define CC_NO_ARGS  /* No argc and argv[] in main */

/* MESCC libraries
// ---------------
*/

#include "mescc.h"
#include "conio.h"

/* Xgraph libraries
// --------------
*/
#include "xgraph.h"
#include "xdraw.h"
#include "xbitmap.h"
#include "xchrdef.h"
#include "xtext.h"
#include "xsys.h"

/* Project defs.
   -------------
*/
#define APP_NAME    "xdemo3"
#define APP_VERSION "v1.00 / 15 Mar 2019"
#define APP_COPYRGT "(c) 2019 K. Mueller"
#define APP_USAGE   "xdemo3 <cr>"

/* -------------------------------------
// -------------- XDemo3 ---------------
// -------------------------------------
*/

/* ;=== Copy of Data-Structure defintion that the returned pointer =====
// ;============== from 'FnEllipse()' is pointing to ===================
// ;
// ;           +==+==+==+==+==+
// OctCoord:;  |+0|+2|+4|+6|+8| <= Offset
// ;===========+==+==+==+==+==+=========================================
// O_ELL: defw   0, 0, 0, 0, 0  ; Data of Ellipse when called
// ;             ^  ^  ^  ^  ^--- Hight Radius
// ;             |  |  |  +------ Width Radius
// ;             |  |  +--------- Y-Center Coord.
// ;             |  +------------ X-Center Coord.
// ;             +--------------- LByte= plotted Oct. Mask, HByte = Array-Length
// ;                              HByte is set in 'ClrOctArray' Routine !
// O_BXEL: defw  0, 0, 0, 0, 0  ; Data of RBOX-Ellipse (when requested) ELSE '0'
// ;             ^  ^  ^  ^  ^--- ywidth = RBox-Hight between rounded corners
// ;             |  |  |  +------ xhight = RBox-Width between rounded corners
// ;             |  |  +--------- Surounding rectangular box hight
// ;             |  +------------ Surounding rectangular box width
// ;             +--------------- LByte= -1 if RBox ELSE '0', HByte = Zero
// ;--------------------------------------------------------------------
// ;           +==+==+==+==+==+
// ;           |OL|X0|Y0|X1|Y1|   'O' = LByte: Oct., 'L' = HByte:Linestyle
// OctCoord0: ;|+0|+2|+4|+6|+8| <= Offset
// ;===========+==+==+==+==+==+=========================================
// O_NNW:  defw  0, 0, 0, 0, 0  ; Coord. North-North-West Octant
// O_NNE:  defw  0, 0, 0, 0, 0  ; Coord. North-North-East Octant
// O_WWN:  defw  0, 0, 0, 0, 0  ; Coord. West-West-North  Octant
// O_EEN:  defw  0, 0, 0, 0, 0  ; Coord. East-East-North  Octant
// O_SSW:  defw  0, 0, 0, 0, 0  ; Coord. South-South-West Octant
// O_SSE:  defw  0, 0, 0, 0, 0  ; Coord. South-South-East Octant
// O_WWS:  defw  0, 0, 0, 0, 0  ; Coord. West-West-South  Octant
// O_EES:  defw  0, 0, 0, 0, 0  ; Coord. East-East-South  Octant
// ;             ^  ^  ^  ^  ^--- Oct. End Y-Coord.
// ;             |  |  |  +------ Oct. End X-Coord.
// ;             |  |  +--------- Oct. Start Y-Coord.
// ;             |  +------------ Oct. Start X_Coord.
// ;             +--------------- LByte= Oct. Number, HByte = Linestyle
// ;--------------------------------------------------------------------
// OctCoord1:;Coord.-Array End
*/

main()
{
    int x,y,x0,y0,x1,y1;
    int r1,r2,r3;
    int width,hight;
    int xwidth,yhight;
    int OctCoord;


    AClrScr();
/* puts("ASCII Clear-Screen"); */

/* puts("Check if the RSX is in memory"); */
    if(!HelloRsx()) {
        // puts("The RSX is not in memory!");
        return -1;
    }

/* puts("Init Graphic"); */
    InitGraphic();

/* puts("Graphic switched ON"); */
    GScreen(X_ON);

/* puts("Clear Graphic Screen"); */
    GClrScr(X_BLACK);

/* puts("Hide the Cursor"); */
    HideCursor();

/* puts("Set Pixel Draw-Mode"); */
    SetPixMode(XM_SET);

/* puts("Plot Frame Box"); */
      FnBox(1, 3, 319, 236);
    SetTxMode(XA_RC);
      PrintStr(1,0,"RSX-Name: ");
      PrintStr(11,0,RSXName());
    SetTxMode(XA_SW);
    SetTxMode(XA_XY);
      PrintStr(3, 229, "Demo3: Large Ellipse as RBox, ");
    SetTxMode(XA_TI);
      PrintStr(3+30*4, 229, "Oct. Start-Points");
    SetTxMode(XA_TN);
      PrintStr(3+47*4, 229, " connected by Lines...");

/* =============================== */
/*    puts("Plot RBox Ellipse");   */
/* =============================== */
    SetTxMode(XA_XY);
    SetPixMode(XM_LoRes);
    SetPixMode(XM_SET);
    SetLnStyle(0);

    x=160;      y=120;
    r1=55;      r2 = 28;    r3=7;
    width=180;  hight=180;
    xwidth=35;  yhight=20;

/* ========================================================================
// For Param.-Definition in "SearchStruct()" see 'xdraw.h' and 'xgraph.h'.
// Remember: The example below only uses 'Quadrants'. As each 'Quadrant'
//           has 2 Octants, there are more Start-and Endpoints in the Ell-
//           Struct. you can use. The Ell-Struct contains the Information
//           which Octants are realy plotted along with the used LineStyle.
//           This could be used to construct a small database that holds
//           all the data where each element of the ellipse is plotted on
//           the screen !
//           Normaly only the center-point and the two radii of the ellipse
//           are known, but not all octant coordinates. This gives more
//           flexibility when constructing complicated figures with curved
//           lines. The Struct. even holds the coord. of not plotted octants.
//           May be that this is usefull in one or the other situation...
// ======================================================================== */

    SetLnStyle(0);
    SetRBox(XO_ALL,xwidth+4,yhight+1);
      OctCoord = FnEllipse( x, y, (width>>1)-8, (hight/5));

      /* Southern Hemisphere Quadrants */
      PrintStr(x-105,y-40,"South-West-Quadr.");
      PrintStr(x+40,y-40,"South-East-Quadr.");

      /* Northern Hemisphere Quadrants */
      PrintStr(x-105,y+30,"North-West-Quadr.");
      PrintStr(x+40,y+30,"North-East-Quadr.");

    SetLnStyle(5);
      FnLine(SearchStruct(XO_SSW, XO_OctStXCo, OctCoord),
             SearchStruct(XO_SSW, XO_OctStYCo, OctCoord),
             SearchStruct(XO_NNE, XO_OctStXCo, OctCoord),
             SearchStruct(XO_NNE, XO_OctStYCo, OctCoord));

    SetLnStyle(5);
      FnLine(SearchStruct(XO_SSE, XO_OctStXCo, OctCoord),
             SearchStruct(XO_SSE, XO_OctStYCo, OctCoord),
             SearchStruct(XO_NNW, XO_OctStXCo, OctCoord),
             SearchStruct(XO_NNW, XO_OctStYCo, OctCoord));

    SetLnStyle(6);
      FnLine(SearchStruct(XO_EES, XO_OctStXCo, OctCoord),
             SearchStruct(XO_EES, XO_OctStYCo, OctCoord),
             SearchStruct(XO_WWN, XO_OctStXCo, OctCoord),
             SearchStruct(XO_WWN, XO_OctStYCo, OctCoord));

    SetLnStyle(6);
      FnLine(SearchStruct(XO_WWS, XO_OctStXCo, OctCoord),
             SearchStruct(XO_WWS, XO_OctStYCo, OctCoord),
             SearchStruct(XO_EEN, XO_OctStXCo, OctCoord),
             SearchStruct(XO_EEN, XO_OctStYCo, OctCoord));

/* =============================== */
/* puts("Plot small RBox Circle"); */
/* =============================== */
    x=160;  y=120;
    SetLnStyle(0);
    SetPixMode(XM_LoRes);
    SetRBox(XO_ALL,13,5);
      PrintStr(139,35,"RBox Circle");
      OctCoord = FnCircle( x, y>>1, 10);

    SetLnStyle(0);
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

/* =============================== */
/* puts("Plot small RBox Ellipse"); */
/* =============================== */
    x=160;  y=120;
    SetPixMode(XM_HiRes);
    SetLnStyle(0);
    SetRBox(XO_ALL,10,5);
      PrintStr(136,200,"RBox Ellipse");
      OctCoord = FnEllipse( x, y+(y>>1), 15, 10);

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

/* ================================ */
/*      put a frame around all      */
/* ================================ */
      FnRBEllipse(160,120,80,50,50,50);

/* ================================ */
/*  puts("\n\rShow ASCII-Cursor");  */
/* ================================ */
    ShowCursor();

}

/* ============================ */
/* ==== Nothing more to do ==== */
/* ============================ */
