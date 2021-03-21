/* /////////////////////////////////////////////////////////////////////
//      xdemo2.c
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
//  cc xdemo2
//  zsm xdemo2
//  hexcom xdemo2
//  gencom xdemo2.com xgraph.rsx
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
#define APP_NAME    "xdemo2"
#define APP_VERSION "v1.00 / 15 Mar 2019"
#define APP_COPYRGT "(c) 2019 K. Mueller"
#define APP_USAGE   "xdemo2 <cr>"

/* -------------------------------------
// -------------- XDemo2 ---------------
// -------------------------------------
*/

main()
{
    int x,y;
    int r1,r2,r3;
    int width,hight;
    int rbwidth,rbhight;


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
      PrintStr(3, 229, "Demo2: Box/Circle/Ellipse...");

/* puts("Plot Box, Circle & Elipse"); */
    SetTxMode(XA_XY);
    SetPixMode(XM_LoRes);
    SetPixMode(XM_SET);
    SetLnStyle(0);

    x=160;     y=120;
    r1=55;     r2 = 28;   r3=7;
    width=180; hight=180;
    rbwidth=2; rbhight=2;

    SetLnStyle(1);
      FnBox(x-(width>>1), y-(hight>>1), width, hight);

    SetLnStyle(0);
      FnCircle( x, y, (width>>1)-2);

    SetLnStyle(1);
      FnCircle( x, y, (width>>1)-4);

    SetLnStyle(1);
      FnEllipse( x, y, (width>>1)-8, (hight/5));
    SetLnStyle(6);
      FnEllipse( x, y, (width/5), (hight>>1)-8);

    SetLnStyle(0);
    SetRBox(XO_ALL,rbwidth+4,rbhight+1);
      FnEllipse( x, y, (width/5)-10, (hight/14));
    SetLnStyle(1);
      FnCircle( x, y, r3);

    SetLnStyle(0);
    SetRBox((XO_SEQ+XO_NWQ),(width>>1)-8,(hight>>1));
      FnEllipse( x, y, r3<<1,r3);

    SetRBox(XO_NEQ,4,4);
      FnCircle( x-(width>>1), y-(hight>>1), r3+3);
    SetRBox(XO_SWQ,4,4);
      FnCircle( x+(width>>1), y+(hight>>1), r3+3);

    SetQuad(XO_SEQ+XO_SWQ+XO_NWQ);
      FnCircle( x-(width>>1), y-(hight>>1), r3+3);
    SetQuad(XO_NWQ+XO_NEQ+XO_SEQ);
      FnCircle( x+(width>>1), y+(hight>>1), r3+3);

/* puts("\n\rShow ASCII-Cursor"); */
    ShowCursor();

}
