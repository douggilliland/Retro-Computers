/* /////////////////////////////////////////////////////////////////////
//      xdemo1.c
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
//  cc xdemo1
//  zsm xdemo1
//  hexcom xdemo1
//  gencom xdemo1.com xgraph.rsx
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
#define APP_NAME    "xdemo1"
#define APP_VERSION "v1.00 / 15 Mar 2019"
#define APP_COPYRGT "(c) 2019 K. Mueller"
#define APP_USAGE   "xdemo1 <cr>"

/* -------------------------------------
// -------------- XDemo1 ---------------
// -------------------------------------
*/

main()
{
    int  address;

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
      FnBox(1, 0, 319, 239);

/* puts("Plot Line on Screen upper side"); */
    SetPixMode(XM_HiRes);
    SetLnStyle(0);
      FnLine(10, 20, 309, 20);
    SetLnStyle(5);
      FnLine(10, 30, 309, 30);

/* puts("Text-String output"); */
    SetTxMode(XA_XY);
      PrintStr(10, 11, "XY:(16;11) One Line...");
    SetTxMode(XA_DW);
      PrintStr(13*8+40, 11, "Hello World in Dwidth");
    SetTxMode(XA_SW);
      PrintStr(10, 23, "XY:(20;22) \"and Hello World below\" ");
    SetTxMode(XA_RC);
      PrintStr(20,6,"LoRes/HiRes always in 320x240 coord. !");
      PrintStr(0,0," RSX-Name: ");
      PrintStr(11,0,RSXName());
      PrintStr(17,0," ");
    SetTxMode(XA_XY);
      PrintStr(3, 229, "Demo1: xgraph all functions...");

/* puts("Plot Boxes"); */
    SetTxMode(XA_SW);
    SetTxMode(XA_XY);
    SetPixMode(XM_LoRes);
    SetLnStyle(0);
      FnBox(  10, 59, 29, 19);
    SetPixMode(XM_HiRes);
      FnBox(  10, 80, 29, 19);
    /* Print some text */
      PrintStr(45,65,"320x240px (LoRes)");
      PrintStr(45,86,"640x240px (HiRes)");
      PrintStr(7,50,"Two Boxes");
      PrintStr(14,65,"29x19");
      PrintStr(14,86,"29x19");

/* puts("Plot Triangles"); */
    SetTxMode(XA_SW);
    SetTxMode(XA_XY);
      PrintStr(152,226, "Triangles in HiRes");
      PrintStr(240,226, "Triangle in LoRes");
    SetLnStyle(5);
      FnTriangle(120, 229, 25, -40);
    SetLnStyle(2);
      FnTriangle(135, 209, 25, -40);
    SetLnStyle(1);
      FnTriangle(160, 219, 25, -40);
    SetLnStyle(0);
    SetPixMode(XM_LoRes);
      FnTriangle(  260, 219, 25, -40);

/* puts("Plot Circle & Elipse"); */
    SetTxMode(XA_XY);
    SetPixMode(XM_HiRes);
    SetPixMode(XM_SET);
    PrintStr(156,69,"Plot a Circle");
    if (GetStat(XS_HIRES))
      PrintStr(164,100,"in HiRes");
    else
      PrintStr(164,100,"in LoRes");
    SetLnStyle(0);
    SetRBox(XO_ALL,2,2);
      FnCircle( 180, 120, 41);
      FnCircle( 180, 120, 41);
      FnCircle( 180, 120, 34);
    SetRBox(XO_ALL,2,2);
      FnCircle( 180, 120, 29);
    SetLnStyle(1);
      FnCircle( 180, 120, 40);
      FnCircle( 180, 120, 39);
      FnCircle( 180, 120, 38);
      FnCircle( 180, 120, 37);
      FnCircle( 180, 120, 36);
      FnCircle( 180, 120, 35);
    PrintStr(203, 170, "Plot a Ellipse");
    SetPixMode(XM_LoRes);
    SetLnStyle(0);
    SetRBox(XO_ALL,2,2);
      FnEllipse(230, 200, 24, 19);
      FnEllipse(230, 200, 24, 19);
    SetRBox(XO_ALL,2,2);
      FnEllipse(230, 200, 15, 10);
    SetLnStyle(1);
      FnEllipse(230, 200, 23, 18);
      FnEllipse(230, 200, 22, 17);
      FnEllipse(230, 200, 21, 16);
    SetLnStyle(0);
      FnEllipse(230, 200, 20, 15);
    SetRBox(XO_ALL,3,3);
      FnCircle(230, 200, 3);
      FnCircle(230, 200, 3);

/* puts("Text-String output"); */
    SetTxMode(XA_XY);
      PrintStr(8, 128, "XY:(8;128) Hello World !");
    SetTxMode(XA_TI);
      PrintStr(8, 136, "XY:(8;136) Hello World !");
    SetTxMode(XA_RC);
    SetTxMode(XA_TN);
      PrintStr(2,13, "RC:(2;13) \"Text non-inverted\"");
    SetTxMode(XA_TI);
      PrintStr(2,14, "RC:(2;14) \"Text inverted\"");
    SetTxMode(XA_TN);
      PrintChRpt(2,18, 24, '=');
      PrintStr(2,19, "Possible Line Pattern:");

/* puts("Demonstrate the line-Styles"); */
    SetPixMode(XM_HiRes);
    SetLnStyle(1);
    SetPatRot(X_ON);
      FnLine(8, 152+8, 94, 152+8);
    SetLnStyle(2);
      FnLine(8, 156+8, 94, 156+8);
    SetLnStyle(3);
      FnLine(8, 160+8, 94, 160+8);
    SetLnStyle(4);
      FnLine(8, 164+8, 94, 164+8);
    SetLnStyle(5);
      FnLine(8, 168+8, 94, 168+8);
    SetLnStyle(6);
      FnLine(8, 172+8, 94, 172+8);
    SetLnStyle(7);
      FnLine(8, 176+8, 94, 176+8);

    SetPixMode(XM_LoRes);
    SetLnStyle(1);
      FnLine(8, 152+38, 94, 152+38);
    SetLnStyle(2);
      FnLine(8, 156+38, 94, 156+38);
    SetLnStyle(3);
      FnLine(8, 160+38, 94, 160+38);
    SetLnStyle(4);
      FnLine(8, 164+38, 94, 164+38);
    SetLnStyle(5);
      FnLine(8, 168+38, 94, 168+38);
    SetLnStyle(6);
      FnLine(8, 172+38, 94, 172+38);
    SetLnStyle(7);
      FnLine(8, 176+38, 94, 176+38);
    SetLnStyle(0);
    SetTxMode(XA_RC);
    SetTxMode(XA_TN);
      PrintStr( 2, 27, "Triangles as a small forest");

/* puts("ASCII-Char. output"); */
    SetTxMode(XA_RC);
    SetTxMode(XA_TN);
      PrintStr(39, 14, "PrintChr. '9'");
    SetTxMode(XA_TI);
      PrintChr(44, 16, '9');

/* puts("Put random bitmap to screen"); */
    SetPixMode(XM_LoRes);
    SetTxMode(XA_TN);
      PrintStr(61,  8, "A Random-Bitmap");
      PrintStr(60,  9, "taken from  0x1100");
      PrintStr(61, 20, "RC-Size: (20x10)");
    for(address = 0x1100; address >= 0x0100; address -= 20) {
      PutBmpRC(59, 10, 20, 10, address);
    }
/* puts("\n\rShow ASCII-Cursor"); */
    ShowCursor();

}
