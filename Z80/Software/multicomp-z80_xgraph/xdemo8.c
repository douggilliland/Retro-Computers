/* /////////////////////////////////////////////////////////////////////
//      XDemo8.c
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
//  cc XDemo8
//  zsm XDemo8
//  hexcom XDemo8
//  gencom XDemo8.com xgraph.rsx
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
#include "printf.h"

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
#define APP_NAME    "XDemo8"
#define APP_VERSION "v1.00 / 15 Mar 2019"
#define APP_COPYRGT "(c) 2019 K. Mueller"
#define APP_USAGE   "XDemo8 <cr>"

/* -------------------------------------
// -------------- XDemo8 ---------------
// -------------------------------------
*/

main()
{
    int  address,y,x;
    BYTE *OctCoord;

    int  *O_ELL,  *O_BXEL;
    int  *PO_NNW, *PO_NNE, *PO_WWN, *PO_EEN;
    int  *PO_SSW, *PO_SSE, *PO_WWS, *PO_EES;

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
    SetTxMode(XA_RC);
      PrintStr(0,0," RSX-Name: ");
      PrintStr(11,0,RSXName());
      PrintStr(17,0," ");

/* =============================== */
/* puts("Plot small RBox Ellipse") */
/* =============================== */
    x=160;  y=120;
    SetLnStyle(XP_Pat0);
    SetRBox(XO_ALL,10,5);
    SetTxMode(XA_XY);
      PrintStr(136,150,"RBox Ellipse");
      PrintStr(3, 229, "Demo8: FnEllipse Struct-Data Readback (on ASCII-Screen)...");
    SetPixMode(XM_HiRes);
      OctCoord = FnEllipse( x, y, 15, 10);
      O_ELL    = OctCoord + 00;
      O_BXEL   = OctCoord + 10;
      PO_NNW   = OctCoord + 20;
      PO_NNE   = OctCoord + 30;
      PO_WWN   = OctCoord + 40;
      PO_EEN   = OctCoord + 50;
      PO_SSW   = OctCoord + 60;
      PO_SSE   = OctCoord + 70;
      PO_WWS   = OctCoord + 80;
      PO_EES   = OctCoord + 90;

    SetLnStyle(XP_Pat2);
/*    Line south   */
      FnLine(SearchStruct(XO_SSW, XO_OctStXCo, OctCoord),
             SearchStruct(XO_SSW, XO_OctStYCo, OctCoord),
             SearchStruct(XO_SSE, XO_OctStXCo, OctCoord),
             SearchStruct(XO_SSE, XO_OctStYCo, OctCoord));

/*    Line North   */
      FnLine(SearchStruct(XO_NNE, XO_OctStXCo, OctCoord),
             SearchStruct(XO_NNE, XO_OctStYCo, OctCoord),
             SearchStruct(XO_NNW, XO_OctStXCo, OctCoord),
             SearchStruct(XO_NNW, XO_OctStYCo, OctCoord));

/*    Line North KOPIE => Mittenkreuz   */
      FnLine(SearchStruct(XO_SSE, XO_OctEnXCo, OctCoord),
             SearchStruct(XO_SSE, XO_OctEnYCo, OctCoord),
             SearchStruct(XO_NNW, XO_OctEnXCo, OctCoord),
             SearchStruct(XO_NNW, XO_OctEnYCo, OctCoord));

/*    Line North KOPIE => Mittenkreuz   */
      FnLine(SearchStruct(XO_NNE, XO_OctEnXCo, OctCoord),
             SearchStruct(XO_NNE, XO_OctEnYCo, OctCoord),
             SearchStruct(XO_SSW, XO_OctEnXCo, OctCoord),
             SearchStruct(XO_SSW, XO_OctEnYCo, OctCoord));

/*    Line East   */
      FnLine(SearchStruct(XO_EES, XO_OctStXCo, OctCoord),
             SearchStruct(XO_EES, XO_OctStYCo, OctCoord),
             SearchStruct(XO_EEN, XO_OctStXCo, OctCoord),
             SearchStruct(XO_EEN, XO_OctStYCo, OctCoord));

/*    Line West   */
      FnLine(SearchStruct(XO_WWS, XO_OctStXCo, OctCoord),
             SearchStruct(XO_WWS, XO_OctStYCo, OctCoord),
             SearchStruct(XO_WWN, XO_OctStXCo, OctCoord),
             SearchStruct(XO_WWN, XO_OctStYCo, OctCoord));

//      printf("\n\r");
//      printf("Indirect Access via SearchStruct:\n\r");
//      printf("=================================\n\r");
//      printf("OctCoord[0L]: %d, OctCoord[0H]: %d\n\r",OctCoord[20],OctCoord[21]);
//      printf("Start: NNW-X: %d,  NNW-Y: %d   ",SearchStruct(XO_NNW, XO_OctStXCo, OctCoord),
//                                                SearchStruct(XO_NNW, XO_OctStYCo, OctCoord));
//      printf("End:   NNW-X: %d,  NNW-Y: %d\n\r",SearchStruct(XO_NNW, XO_OctEnXCo, OctCoord),
//                                                SearchStruct(XO_NNW, XO_OctEnYCo, OctCoord));
//
//      printf("OctCoord[0L]: %d, OctCoord[0H]: %d\n\r",OctCoord[30],OctCoord[31]);
//      printf("Start: NNE-X: %d,  NNE-Y: %d  ",SearchStruct(XO_NNE, XO_OctStXCo, OctCoord),
//                                                SearchStruct(XO_NNE, XO_OctStYCo, OctCoord));
//      printf("End  : NNE-X: %d,  NNE-Y: %d\n\r",SearchStruct(XO_NNE, XO_OctEnXCo, OctCoord),
//                                                SearchStruct(XO_NNE, XO_OctEnYCo, OctCoord));
//
//      printf("OctCoord[0L]: %d, OctCoord[0H]: %d\n\r",OctCoord[40],OctCoord[41]);
//      printf("Start: WWN-X: %d,  WWN-Y: %d  ",SearchStruct(XO_WWN, XO_OctStXCo, OctCoord),
//                                                SearchStruct(XO_WWN, XO_OctStYCo, OctCoord));
//      printf("End  : WWN-X: %d,  WWN-Y: %d\n\r",SearchStruct(XO_WWN, XO_OctEnXCo, OctCoord),
//                                                SearchStruct(XO_WWN, XO_OctEnYCo, OctCoord));
//
//      printf("OctCoord[0L]: %d, OctCoord[0H]: %d\n\r",OctCoord[50],OctCoord[51]);
//      printf("Start: EEN-X: %d,  EEN-Y: %d  ",SearchStruct(XO_EEN, XO_OctStXCo, OctCoord),
//                                                SearchStruct(XO_EEN, XO_OctStYCo, OctCoord));
//      printf("End  : EEN-X: %d,  EEN-Y: %d\n\r",SearchStruct(XO_EEN, XO_OctEnXCo, OctCoord),
//                                                SearchStruct(XO_EEN, XO_OctEnYCo, OctCoord));
//
//      printf("OctCoord[0L]: %d, OctCoord[0H]: %d\n\r",OctCoord[60],OctCoord[61]);
//      printf("Start: SSW-X: %d,  SSW-Y: %d  ",SearchStruct(XO_SSW, XO_OctStXCo, OctCoord),
//                                                SearchStruct(XO_SSW, XO_OctStYCo, OctCoord));
//      printf("End  : SSW-X: %d,  SSW-Y: %d\n\r",SearchStruct(XO_SSW, XO_OctEnXCo, OctCoord),
//                                                SearchStruct(XO_SSW, XO_OctEnYCo, OctCoord));
//
//      printf("OctCoord[0L]: %d, OctCoord[0H]: %d\n\r",OctCoord[70],OctCoord[71]);
//      printf("Start: SSE-X: %d,  SSE-Y: %d  ",SearchStruct(XO_SSE, XO_OctStXCo, OctCoord),
//                                                SearchStruct(XO_SSE, XO_OctStYCo, OctCoord));
//      printf("End  : SSE-X: %d,  SSE-Y: %d\n\r",SearchStruct(XO_SSE, XO_OctEnXCo, OctCoord),
//                                                SearchStruct(XO_SSE, XO_OctEnYCo, OctCoord));
//
//      printf("OctCoord[0L]: %d, OctCoord[0H]: %d\n\r",OctCoord[80],OctCoord[81]);
//      printf("Start: WWS-X: %d,  WWS-Y: %d  ",SearchStruct(XO_WWS, XO_OctStXCo, OctCoord),
//                                                SearchStruct(XO_WWS, XO_OctStYCo, OctCoord));
//      printf("End  : WWS-X: %d,  WWS-Y: %d\n\r",SearchStruct(XO_WWS, XO_OctEnXCo, OctCoord),
//                                                SearchStruct(XO_WWS, XO_OctEnYCo, OctCoord));
//
//      printf("OctCoord[0L]: %d, OctCoord[0H]: %d\n\r",OctCoord[90],OctCoord[91]);
//      printf("Start: EES-X: %d,  EES-Y: %d  ",SearchStruct(XO_EES, XO_OctStXCo, OctCoord),
//                                                SearchStruct(XO_EES, XO_OctStYCo, OctCoord));
//      printf("End  : EES-X: %d,  EES-Y: %d\n\r",SearchStruct(XO_EES, XO_OctEnXCo, OctCoord),
//                                                SearchStruct(XO_EES, XO_OctEnYCo, OctCoord));


        printf("\n\r");
        printf("Direct Access via Array-Pointer:\n\r");
        printf("================================\n\r");
        printf("PO_NNW[0L]:  %4d, PO_NNW[0H]: %4d\n\r",OctCoord[20],OctCoord[21]);
        printf("PO_NNW[1]:   %4d  ",PO_NNW[1]);
        printf("PO_NNW[2]:   %4d  ",PO_NNW[2]);
        printf("PO_NNW[3]:   %4d  ",PO_NNW[3]);
        printf("PO_NNW[4]:   %4d  ",PO_NNW[4]);

        printf("\n\r");
        printf("PO_NNE[0L]:  %4d, PO_NNE[0H]: %4d\n\r",OctCoord[30],OctCoord[31]);
        printf("PO_NNE[1]:   %4d  ",PO_NNE[1]);
        printf("PO_NNE[2]:   %4d  ",PO_NNE[2]);
        printf("PO_NNE[3]:   %4d  ",PO_NNE[3]);
        printf("PO_NNE[4]:   %4d  ",PO_NNE[4]);

        printf("\n\r");
        printf("PO_WWN[0L]:  %4d, PO_WWN[0H]: %4d\n\r",OctCoord[40],OctCoord[41]);
        printf("PO_WWN[1]:   %4d  ",PO_WWN[1]);
        printf("PO_WWN[2]:   %4d  ",PO_WWN[2]);
        printf("PO_WWN[3]:   %4d  ",PO_WWN[3]);
        printf("PO_WWN[4]:   %4d  ",PO_WWN[4]);

        printf("\n\r");
        printf("PO_EEN[0L]:  %4d, PO_EEN[0H]: %4d\n\r",OctCoord[50],OctCoord[51]);
        printf("PO_EEN[1]:   %4d  ",PO_EEN[1]);
        printf("PO_EEN[2]:   %4d  ",PO_EEN[2]);
        printf("PO_EEN[3]:   %4d  ",PO_EEN[3]);
        printf("PO_EEN[4]:   %4d  ",PO_EEN[4]);

        printf("\n\r");
        printf("PO_SSW[0L]:  %4d, PO_SSW[0H]: %4d\n\r",OctCoord[60],OctCoord[61]);
        printf("PO_SSW[1]:   %4d  ",PO_SSW[1]);
        printf("PO_SSW[2]:   %4d  ",PO_SSW[2]);
        printf("PO_SSW[3]:   %4d  ",PO_SSW[3]);
        printf("PO_SSW[4]:   %4d  ",PO_SSW[4]);

        printf("\n\r");
        printf("PO_SSE[0L]:  %4d, PO_SSE[0H]: %4d\n\r",OctCoord[70],OctCoord[71]);
        printf("PO_SSE[1]:   %4d  ",PO_SSE[1]);
        printf("PO_SSE[2]:   %4d  ",PO_SSE[2]);
        printf("PO_SSE[3]:   %4d  ",PO_SSE[3]);
        printf("PO_SSE[4]:   %4d  ",PO_SSE[4]);

        printf("\n\r");
        printf("PO_WWS[0L]:  %4d, PO_WWS[0H]: %4d\n\r",OctCoord[80],OctCoord[81]);
        printf("PO_WWS[1]:   %4d  ",PO_WWS[1]);
        printf("PO_WWS[2]:   %4d  ",PO_WWS[2]);
        printf("PO_WWS[3]:   %4d  ",PO_WWS[3]);
        printf("PO_WWS[4]:   %4d  ",PO_WWS[4]);

        printf("\n\r");
        printf("PO_EES[0L]:  %4d, PO_EES[0H]: %4d\n\r",OctCoord[90],OctCoord[91]);
        printf("PO_EES[1]:   %4d  ",PO_EES[1]);
        printf("PO_EES[2]:   %4d  ",PO_EES[2]);
        printf("PO_EES[3]:   %4d  ",PO_EES[3]);
        printf("PO_EES[4]:   %4d  ",PO_EES[4]);

        printf("\n\r");
        printf("Direct Access via Array-Pointer:\n\r");
        printf("================================\n\r");
        printf("O_ELL[0L]:  %4d, O_ELL[0H]: %4d\n\r",OctCoord[00],OctCoord[01]);
        printf("O_ELL[2]:   %4d  ",O_ELL[1]);
        printf("O_ELL[4]:   %4d  ",O_ELL[2]);
        printf("O_ELL[6]:   %4d  ",O_ELL[3]);
        printf("O_ELL[8]:   %4d  ",O_ELL[4]);

        printf("\n\r");
        printf("Direct Access via Array-Pointer:\n\r");
        printf("================================\n\r");
        printf("O_BXEL[0L]:  %4d, O_BXEL[0H]: %4d\n\r",OctCoord[10],OctCoord[11]);
        printf("O_BXEL[2]:   %4d  ",O_BXEL[1]);
        printf("O_BXEL[4]:   %4d  ",O_BXEL[2]);
        printf("O_BXEL[6]:   %4d  ",O_BXEL[3]);
        printf("O_BXEL[8]:   %4d  ",O_BXEL[4]);


/* puts("\n\rShow ASCII-Cursor"); */
    ShowCursor();

}
