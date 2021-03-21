/* /////////////////////////////////////////////////////////////////////
//      xdemo5.c
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
//  cc xdemo5
//  zsm xdemo5
//  hexcom xdemo5
//  gencom xdemo5.com xgraph.rsx
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
#include "xchrdef.h"
#include "xtext.h"
#include "xsys.h"

/* Project defs.
// -------------
*/
#define APP_NAME    "xdemo5"
#define APP_VERSION "v1.00 / 15 Mar 2019"
#define APP_COPYRGT "(c) 2019 K. Mueller"
#define APP_USAGE   "xdemo5 <cr>"

/* -------------------------------------
// -------------- XDemo5 ---------------
// -------------------------------------
*/

main()
{
    int  i,j,k,y,x,x0;
    int  xchar;

/* Set Coord. for 'Show-Char' on screen */

    AClrScr();
/* ASCII Clear-Screen */

/* Check if the RSX is in memory */
    if(!HelloRsx()) {
        puts("The RSX is not in memory!");
        return -1;
    }

/* Init Graphic */
    InitGraphic();

/* Graphic switched ON */
    GScreen(X_ON);

/* Clear Graphic Screen */
    GClrScr(X_BLACK);

/* Hide the Cursor */
    HideCursor();

/* Set Pixel Draw-Mode */
    SetPixMode(XM_SET);

/* Plot Frame Box */
      FnBox(1, 3, 319, 236);
    SetTxMode(XA_RC);
      PrintStr(1,0,"RSX-Name: ");
      PrintStr(11,0,RSXName());
    SetTxMode(XA_XY);
      PrintStr(3, 229, "Demo5: Reprogramming the Font-ROM... ");

/* Show old upper 128 char. of font-rom on display*/
    SetTxMode(XA_RC);

       y  = 2;
       x0 = 5;
       y  = 2;
       x  = x0;

/* First let us backup the cp/m char-set to memory... */
       PrintStr(x,y++,"First we backup the original CP/M font-set to memory..."); y++;
       RdFntROM(255, 0x00, cpmfontset);

       PrintStr(x,y++,"Next we will redefine upper 128 char with semi block-graphic symbols"); y++;
       PrintStr(x,y++,"First start printing \"old\" upper 128 char..."); y++;
       for(i = 0x80; i < 0xFF; i++) {
          PrintChr(x++,y,i); //x++;
          if((x-x/0x40*0x40) == 0) {y++; x = x0;}
       }

/* Now let us transfer the new char-set to the upper half of CROM... */
       y += 2;
       x = x0;

       PrintStr(x,y--,"Redefining upper 128 char...");
       WrFntROM(127, 0x80, CgaBlkGrf);

/* Show new upper 128 char. of font-rom on display*/
       y += 2;
       x = x0;

       PrintStr(x,y++,"Now we start printing \"new\" upper 128 char..."); y++;
       for(i = 0x80; i < 0xFF; i++) {
          PrintChr(x++,y,i); //x++;
          if((x-x/0x40*0x40) == 0) {y++; x = x0;}
       }

/* Show restored upper 128 char. of font-rom on display*/
       y += 2;
       x = x0;

       WrFntROM(127, 0x80, cpmfontset);
       PrintStr(x,y++,"Restoring upper 128 char...");
       PrintStr(x,y++,"Now we show \"restored\" upper 128 char..."); y++;
       for(i = 0x80; i < 0xFF; i++) {
          PrintChr(x++,y,i); // x++;
          if((x-x/0x40*0x40) == 0) {y++; x = x0;}
       }

       y += 2;
       x = x0;

       PrintStr(x,y,"The same is possible with single char. redefinition");

/* Show the cursor again */
      ShowCursor();
}

#asm
cpmfontset:
   DEFS 2048
#endasm

#asm
CgaBlkGrf:
   ;256 Semi Block-Graphic Character, 2x4 pixel matrix per char-cell
   DEFB 000h,000h,000h,000h,000h,000h,000h,000h,0F0h,0F0h,000h,000h,000h,000h,000h,000h
   DEFB 00Fh,00Fh,000h,000h,000h,000h,000h,000h,0FFh,0FFh,000h,000h,000h,000h,000h,000h
   DEFB 000h,000h,0F0h,0F0h,000h,000h,000h,000h,0F0h,0F0h,0F0h,0F0h,000h,000h,000h,000h
   DEFB 00Fh,00Fh,0F0h,0F0h,000h,000h,000h,000h,0FFh,0FFh,0F0h,0F0h,000h,000h,000h,000h
   DEFB 000h,000h,00Fh,00Fh,000h,000h,000h,000h,0F0h,0F0h,00Fh,00Fh,000h,000h,000h,000h
   DEFB 00Fh,00Fh,00Fh,00Fh,000h,000h,000h,000h,0FFh,0FFh,00Fh,00Fh,000h,000h,000h,000h
   DEFB 000h,000h,0FFh,0FFh,000h,000h,000h,000h,0F0h,0F0h,0FFh,0FFh,000h,000h,000h,000h
   DEFB 00Fh,00Fh,0FFh,0FFh,000h,000h,000h,000h,0FFh,0FFh,0FFh,0FFh,000h,000h,000h,000h
   DEFB 000h,000h,000h,000h,0F0h,0F0h,000h,000h,0F0h,0F0h,000h,000h,0F0h,0F0h,000h,000h
   DEFB 00Fh,00Fh,000h,000h,0F0h,0F0h,000h,000h,0FFh,0FFh,000h,000h,0F0h,0F0h,000h,000h
   DEFB 000h,000h,0F0h,0F0h,0F0h,0F0h,000h,000h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,000h,000h
   DEFB 00Fh,00Fh,0F0h,0F0h,0F0h,0F0h,000h,000h,0FFh,0FFh,0F0h,0F0h,0F0h,0F0h,000h,000h
   DEFB 000h,000h,00Fh,00Fh,0F0h,0F0h,000h,000h,0F0h,0F0h,00Fh,00Fh,0F0h,0F0h,000h,000h
   DEFB 00Fh,00Fh,00Fh,00Fh,0F0h,0F0h,000h,000h,0FFh,0FFh,00Fh,00Fh,0F0h,0F0h,000h,000h
   DEFB 000h,000h,0FFh,0FFh,0F0h,0F0h,000h,000h,0F0h,0F0h,0FFh,0FFh,0F0h,0F0h,000h,000h
   DEFB 00Fh,00Fh,0FFh,0FFh,0F0h,0F0h,000h,000h,0FFh,0FFh,0FFh,0FFh,0F0h,0F0h,000h,000h
   DEFB 000h,000h,000h,000h,00Fh,00Fh,000h,000h,0F0h,0F0h,000h,000h,00Fh,00Fh,000h,000h
   DEFB 00Fh,00Fh,000h,000h,00Fh,00Fh,000h,000h,0FFh,0FFh,000h,000h,00Fh,00Fh,000h,000h
   DEFB 000h,000h,0F0h,0F0h,00Fh,00Fh,000h,000h,0F0h,0F0h,0F0h,0F0h,00Fh,00Fh,000h,000h
   DEFB 00Fh,00Fh,0F0h,0F0h,00Fh,00Fh,000h,000h,0FFh,0FFh,0F0h,0F0h,00Fh,00Fh,000h,000h
   DEFB 000h,000h,00Fh,00Fh,00Fh,00Fh,000h,000h,0F0h,0F0h,00Fh,00Fh,00Fh,00Fh,000h,000h
   DEFB 00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,000h,000h,0FFh,0FFh,00Fh,00Fh,00Fh,00Fh,000h,000h
   DEFB 000h,000h,0FFh,0FFh,00Fh,00Fh,000h,000h,0F0h,0F0h,0FFh,0FFh,00Fh,00Fh,000h,000h
   DEFB 00Fh,00Fh,0FFh,0FFh,00Fh,00Fh,000h,000h,0FFh,0FFh,0FFh,0FFh,00Fh,00Fh,000h,000h
   DEFB 000h,000h,000h,000h,0FFh,0FFh,000h,000h,0F0h,0F0h,000h,000h,0FFh,0FFh,000h,000h
   DEFB 00Fh,00Fh,000h,000h,0FFh,0FFh,000h,000h,0FFh,0FFh,000h,000h,0FFh,0FFh,000h,000h
   DEFB 000h,000h,0F0h,0F0h,0FFh,0FFh,000h,000h,0F0h,0F0h,0F0h,0F0h,0FFh,0FFh,000h,000h
   DEFB 00Fh,00Fh,0F0h,0F0h,0FFh,0FFh,000h,000h,0FFh,0FFh,0F0h,0F0h,0FFh,0FFh,000h,000h
   DEFB 000h,000h,00Fh,00Fh,0FFh,0FFh,000h,000h,0F0h,0F0h,00Fh,00Fh,0FFh,0FFh,000h,000h
   DEFB 00Fh,00Fh,00Fh,00Fh,0FFh,0FFh,000h,000h,0FFh,0FFh,00Fh,00Fh,0FFh,0FFh,000h,000h
   DEFB 000h,000h,0FFh,0FFh,0FFh,0FFh,000h,000h,0F0h,0F0h,0FFh,0FFh,0FFh,0FFh,000h,000h
   DEFB 00Fh,00Fh,0FFh,0FFh,0FFh,0FFh,000h,000h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,000h,000h
   DEFB 000h,000h,000h,000h,000h,000h,0F0h,0F0h,0F0h,0F0h,000h,000h,000h,000h,0F0h,0F0h
   DEFB 00Fh,00Fh,000h,000h,000h,000h,0F0h,0F0h,0FFh,0FFh,000h,000h,000h,000h,0F0h,0F0h
   DEFB 000h,000h,0F0h,0F0h,000h,000h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,000h,000h,0F0h,0F0h
   DEFB 00Fh,00Fh,0F0h,0F0h,000h,000h,0F0h,0F0h,0FFh,0FFh,0F0h,0F0h,000h,000h,0F0h,0F0h
   DEFB 000h,000h,00Fh,00Fh,000h,000h,0F0h,0F0h,0F0h,0F0h,00Fh,00Fh,000h,000h,0F0h,0F0h
   DEFB 00Fh,00Fh,00Fh,00Fh,000h,000h,0F0h,0F0h,0FFh,0FFh,00Fh,00Fh,000h,000h,0F0h,0F0h
   DEFB 000h,000h,0FFh,0FFh,000h,000h,0F0h,0F0h,0F0h,0F0h,0FFh,0FFh,000h,000h,0F0h,0F0h
   DEFB 00Fh,00Fh,0FFh,0FFh,000h,000h,0F0h,0F0h,0FFh,0FFh,0FFh,0FFh,000h,000h,0F0h,0F0h
   DEFB 000h,000h,000h,000h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,000h,000h,0F0h,0F0h,0F0h,0F0h
   DEFB 00Fh,00Fh,000h,000h,0F0h,0F0h,0F0h,0F0h,0FFh,0FFh,000h,000h,0F0h,0F0h,0F0h,0F0h
   DEFB 000h,000h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h
   DEFB 00Fh,00Fh,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0FFh,0FFh,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h
   DEFB 000h,000h,00Fh,00Fh,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,00Fh,00Fh,0F0h,0F0h,0F0h,0F0h
   DEFB 00Fh,00Fh,00Fh,00Fh,0F0h,0F0h,0F0h,0F0h,0FFh,0FFh,00Fh,00Fh,0F0h,0F0h,0F0h,0F0h
   DEFB 000h,000h,0FFh,0FFh,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0FFh,0FFh,0F0h,0F0h,0F0h,0F0h
   DEFB 00Fh,00Fh,0FFh,0FFh,0F0h,0F0h,0F0h,0F0h,0FFh,0FFh,0FFh,0FFh,0F0h,0F0h,0F0h,0F0h
   DEFB 000h,000h,000h,000h,00Fh,00Fh,0F0h,0F0h,0F0h,0F0h,000h,000h,00Fh,00Fh,0F0h,0F0h
   DEFB 00Fh,00Fh,000h,000h,00Fh,00Fh,0F0h,0F0h,0FFh,0FFh,000h,000h,00Fh,00Fh,0F0h,0F0h
   DEFB 000h,000h,0F0h,0F0h,00Fh,00Fh,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,00Fh,00Fh,0F0h,0F0h
   DEFB 00Fh,00Fh,0F0h,0F0h,00Fh,00Fh,0F0h,0F0h,0FFh,0FFh,0F0h,0F0h,00Fh,00Fh,0F0h,0F0h
   DEFB 000h,000h,00Fh,00Fh,00Fh,00Fh,0F0h,0F0h,0F0h,0F0h,00Fh,00Fh,00Fh,00Fh,0F0h,0F0h
   DEFB 00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,0F0h,0F0h,0FFh,0FFh,00Fh,00Fh,00Fh,00Fh,0F0h,0F0h
   DEFB 000h,000h,0FFh,0FFh,00Fh,00Fh,0F0h,0F0h,0F0h,0F0h,0FFh,0FFh,00Fh,00Fh,0F0h,0F0h
   DEFB 00Fh,00Fh,0FFh,0FFh,00Fh,00Fh,0F0h,0F0h,0FFh,0FFh,0FFh,0FFh,00Fh,00Fh,0F0h,0F0h
   DEFB 000h,000h,000h,000h,0FFh,0FFh,0F0h,0F0h,0F0h,0F0h,000h,000h,0FFh,0FFh,0F0h,0F0h
   DEFB 00Fh,00Fh,000h,000h,0FFh,0FFh,0F0h,0F0h,0FFh,0FFh,000h,000h,0FFh,0FFh,0F0h,0F0h
   DEFB 000h,000h,0F0h,0F0h,0FFh,0FFh,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0FFh,0FFh,0F0h,0F0h
   DEFB 00Fh,00Fh,0F0h,0F0h,0FFh,0FFh,0F0h,0F0h,0FFh,0FFh,0F0h,0F0h,0FFh,0FFh,0F0h,0F0h
   DEFB 000h,000h,00Fh,00Fh,0FFh,0FFh,0F0h,0F0h,0F0h,0F0h,00Fh,00Fh,0FFh,0FFh,0F0h,0F0h
   DEFB 00Fh,00Fh,00Fh,00Fh,0FFh,0FFh,0F0h,0F0h,0FFh,0FFh,00Fh,00Fh,0FFh,0FFh,0F0h,0F0h
   DEFB 000h,000h,0FFh,0FFh,0FFh,0FFh,0F0h,0F0h,0F0h,0F0h,0FFh,0FFh,0FFh,0FFh,0F0h,0F0h
   DEFB 00Fh,00Fh,0FFh,0FFh,0FFh,0FFh,0F0h,0F0h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0F0h,0F0h
   DEFB 000h,000h,000h,000h,000h,000h,00Fh,00Fh,0F0h,0F0h,000h,000h,000h,000h,00Fh,00Fh
   DEFB 00Fh,00Fh,000h,000h,000h,000h,00Fh,00Fh,0FFh,0FFh,000h,000h,000h,000h,00Fh,00Fh
   DEFB 000h,000h,0F0h,0F0h,000h,000h,00Fh,00Fh,0F0h,0F0h,0F0h,0F0h,000h,000h,00Fh,00Fh
   DEFB 00Fh,00Fh,0F0h,0F0h,000h,000h,00Fh,00Fh,0FFh,0FFh,0F0h,0F0h,000h,000h,00Fh,00Fh
   DEFB 000h,000h,00Fh,00Fh,000h,000h,00Fh,00Fh,0F0h,0F0h,00Fh,00Fh,000h,000h,00Fh,00Fh
   DEFB 00Fh,00Fh,00Fh,00Fh,000h,000h,00Fh,00Fh,0FFh,0FFh,00Fh,00Fh,000h,000h,00Fh,00Fh
   DEFB 000h,000h,0FFh,0FFh,000h,000h,00Fh,00Fh,0F0h,0F0h,0FFh,0FFh,000h,000h,00Fh,00Fh
   DEFB 00Fh,00Fh,0FFh,0FFh,000h,000h,00Fh,00Fh,0FFh,0FFh,0FFh,0FFh,000h,000h,00Fh,00Fh
   DEFB 000h,000h,000h,000h,0F0h,0F0h,00Fh,00Fh,0F0h,0F0h,000h,000h,0F0h,0F0h,00Fh,00Fh
   DEFB 000h,000h,000h,000h,0FFh,0FFh,0F0h,0F0h,0F0h,0F0h,000h,000h,0FFh,0FFh,0F0h,0F0h
   DEFB 00Fh,00Fh,000h,000h,0FFh,0FFh,0F0h,0F0h,0FFh,0FFh,000h,000h,0FFh,0FFh,0F0h,0F0h
   DEFB 000h,000h,0F0h,0F0h,0FFh,0FFh,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0FFh,0FFh,0F0h,0F0h
   DEFB 00Fh,00Fh,0F0h,0F0h,0FFh,0FFh,0F0h,0F0h,0FFh,0FFh,0F0h,0F0h,0FFh,0FFh,0F0h,0F0h
   DEFB 000h,000h,00Fh,00Fh,0FFh,0FFh,0F0h,0F0h,0F0h,0F0h,00Fh,00Fh,0FFh,0FFh,0F0h,0F0h
   DEFB 00Fh,00Fh,00Fh,00Fh,0FFh,0FFh,0F0h,0F0h,0FFh,0FFh,00Fh,00Fh,0FFh,0FFh,0F0h,0F0h
   DEFB 000h,000h,0FFh,0FFh,0FFh,0FFh,0F0h,0F0h,0F0h,0F0h,0FFh,0FFh,0FFh,0FFh,0F0h,0F0h
   DEFB 00Fh,00Fh,0FFh,0FFh,0FFh,0FFh,0F0h,0F0h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0F0h,0F0h
   DEFB 000h,000h,000h,000h,000h,000h,00Fh,00Fh,0F0h,0F0h,000h,000h,000h,000h,00Fh,00Fh
   DEFB 00Fh,00Fh,000h,000h,000h,000h,00Fh,00Fh,0FFh,0FFh,000h,000h,000h,000h,00Fh,00Fh
   DEFB 000h,000h,0F0h,0F0h,000h,000h,00Fh,00Fh,0F0h,0F0h,0F0h,0F0h,000h,000h,00Fh,00Fh
   DEFB 00Fh,00Fh,0F0h,0F0h,000h,000h,00Fh,00Fh,0FFh,0FFh,0F0h,0F0h,000h,000h,00Fh,00Fh
   DEFB 000h,000h,00Fh,00Fh,000h,000h,00Fh,00Fh,0F0h,0F0h,00Fh,00Fh,000h,000h,00Fh,00Fh
   DEFB 00Fh,00Fh,00Fh,00Fh,000h,000h,00Fh,00Fh,0FFh,0FFh,00Fh,00Fh,000h,000h,00Fh,00Fh
   DEFB 000h,000h,0FFh,0FFh,000h,000h,00Fh,00Fh,0F0h,0F0h,0FFh,0FFh,000h,000h,00Fh,00Fh
   DEFB 00Fh,00Fh,0FFh,0FFh,000h,000h,00Fh,00Fh,0FFh,0FFh,0FFh,0FFh,000h,000h,00Fh,00Fh
   DEFB 000h,000h,000h,000h,0F0h,0F0h,00Fh,00Fh,0F0h,0F0h,000h,000h,0F0h,0F0h,00Fh,00Fh
   DEFB 00Fh,00Fh,000h,000h,0F0h,0F0h,00Fh,00Fh,0FFh,0FFh,000h,000h,0F0h,0F0h,00Fh,00Fh
   DEFB 000h,000h,0F0h,0F0h,0F0h,0F0h,00Fh,00Fh,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,00Fh,00Fh
   DEFB 00Fh,00Fh,0F0h,0F0h,0F0h,0F0h,00Fh,00Fh,0FFh,0FFh,0F0h,0F0h,0F0h,0F0h,00Fh,00Fh
   DEFB 000h,000h,00Fh,00Fh,0F0h,0F0h,00Fh,00Fh,0F0h,0F0h,00Fh,00Fh,0F0h,0F0h,00Fh,00Fh
   DEFB 00Fh,00Fh,00Fh,00Fh,0F0h,0F0h,00Fh,00Fh,0FFh,0FFh,00Fh,00Fh,0F0h,0F0h,00Fh,00Fh
   DEFB 000h,000h,0FFh,0FFh,0F0h,0F0h,00Fh,00Fh,0F0h,0F0h,0FFh,0FFh,0F0h,0F0h,00Fh,00Fh
   DEFB 00Fh,00Fh,0FFh,0FFh,0F0h,0F0h,00Fh,00Fh,0FFh,0FFh,0FFh,0FFh,0F0h,0F0h,00Fh,00Fh
   DEFB 000h,000h,000h,000h,00Fh,00Fh,00Fh,00Fh,0F0h,0F0h,000h,000h,00Fh,00Fh,00Fh,00Fh
   DEFB 00Fh,00Fh,000h,000h,00Fh,00Fh,00Fh,00Fh,0FFh,0FFh,000h,000h,00Fh,00Fh,00Fh,00Fh
   DEFB 000h,000h,0F0h,0F0h,00Fh,00Fh,00Fh,00Fh,0F0h,0F0h,0F0h,0F0h,00Fh,00Fh,00Fh,00Fh
   DEFB 00Fh,00Fh,0F0h,0F0h,00Fh,00Fh,00Fh,00Fh,0FFh,0FFh,0F0h,0F0h,00Fh,00Fh,00Fh,00Fh
   DEFB 000h,000h,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,0F0h,0F0h,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh
   DEFB 00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,0FFh,0FFh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh
   DEFB 000h,000h,0FFh,0FFh,00Fh,00Fh,00Fh,00Fh,0F0h,0F0h,0FFh,0FFh,00Fh,00Fh,00Fh,00Fh
   DEFB 00Fh,00Fh,0FFh,0FFh,00Fh,00Fh,00Fh,00Fh,0FFh,0FFh,0FFh,0FFh,00Fh,00Fh,00Fh,00Fh
   DEFB 000h,000h,000h,000h,0FFh,0FFh,00Fh,00Fh,0F0h,0F0h,000h,000h,0FFh,0FFh,00Fh,00Fh
   DEFB 00Fh,00Fh,000h,000h,0FFh,0FFh,00Fh,00Fh,0FFh,0FFh,000h,000h,0FFh,0FFh,00Fh,00Fh
   DEFB 000h,000h,0F0h,0F0h,0FFh,0FFh,00Fh,00Fh,0F0h,0F0h,0F0h,0F0h,0FFh,0FFh,00Fh,00Fh
   DEFB 00Fh,00Fh,0F0h,0F0h,0FFh,0FFh,00Fh,00Fh,0FFh,0FFh,0F0h,0F0h,0FFh,0FFh,00Fh,00Fh
   DEFB 000h,000h,00Fh,00Fh,0FFh,0FFh,00Fh,00Fh,0F0h,0F0h,00Fh,00Fh,0FFh,0FFh,00Fh,00Fh
   DEFB 00Fh,00Fh,00Fh,00Fh,0FFh,0FFh,00Fh,00Fh,0FFh,0FFh,00Fh,00Fh,0FFh,0FFh,00Fh,00Fh
   DEFB 000h,000h,0FFh,0FFh,0FFh,0FFh,00Fh,00Fh,0F0h,0F0h,0FFh,0FFh,0FFh,0FFh,00Fh,00Fh
   DEFB 00Fh,00Fh,0FFh,0FFh,0FFh,0FFh,00Fh,00Fh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,00Fh,00Fh
   DEFB 000h,000h,000h,000h,000h,000h,0FFh,0FFh,0F0h,0F0h,000h,000h,000h,000h,0FFh,0FFh
   DEFB 00Fh,00Fh,000h,000h,000h,000h,0FFh,0FFh,0FFh,0FFh,000h,000h,000h,000h,0FFh,0FFh
   DEFB 000h,000h,0F0h,0F0h,000h,000h,0FFh,0FFh,0F0h,0F0h,0F0h,0F0h,000h,000h,0FFh,0FFh
   DEFB 00Fh,00Fh,0F0h,0F0h,000h,000h,0FFh,0FFh,0FFh,0FFh,0F0h,0F0h,000h,000h,0FFh,0FFh
   DEFB 000h,000h,00Fh,00Fh,000h,000h,0FFh,0FFh,0F0h,0F0h,00Fh,00Fh,000h,000h,0FFh,0FFh
   DEFB 00Fh,00Fh,00Fh,00Fh,000h,000h,0FFh,0FFh,0FFh,0FFh,00Fh,00Fh,000h,000h,0FFh,0FFh
   DEFB 000h,000h,0FFh,0FFh,000h,000h,0FFh,0FFh,0F0h,0F0h,0FFh,0FFh,000h,000h,0FFh,0FFh
   DEFB 00Fh,00Fh,0FFh,0FFh,000h,000h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,000h,000h,0FFh,0FFh
   DEFB 000h,000h,000h,000h,0F0h,0F0h,0FFh,0FFh,0F0h,0F0h,000h,000h,0F0h,0F0h,0FFh,0FFh
   DEFB 00Fh,00Fh,000h,000h,0F0h,0F0h,0FFh,0FFh,0FFh,0FFh,000h,000h,0F0h,0F0h,0FFh,0FFh
   DEFB 000h,000h,0F0h,0F0h,0F0h,0F0h,0FFh,0FFh,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0FFh,0FFh
   DEFB 00Fh,00Fh,0F0h,0F0h,0F0h,0F0h,0FFh,0FFh,0FFh,0FFh,0F0h,0F0h,0F0h,0F0h,0FFh,0FFh
   DEFB 000h,000h,00Fh,00Fh,0F0h,0F0h,0FFh,0FFh,0F0h,0F0h,00Fh,00Fh,0F0h,0F0h,0FFh,0FFh
   DEFB 00Fh,00Fh,00Fh,00Fh,0F0h,0F0h,0FFh,0FFh,0FFh,0FFh,00Fh,00Fh,0F0h,0F0h,0FFh,0FFh
   DEFB 000h,000h,0FFh,0FFh,0F0h,0F0h,0FFh,0FFh,0F0h,0F0h,0FFh,0FFh,0F0h,0F0h,0FFh,0FFh
   DEFB 00Fh,00Fh,0FFh,0FFh,0F0h,0F0h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0F0h,0F0h,0FFh,0FFh
   DEFB 000h,000h,000h,000h,00Fh,00Fh,0FFh,0FFh,0F0h,0F0h,000h,000h,00Fh,00Fh,0FFh,0FFh
   DEFB 00Fh,00Fh,000h,000h,00Fh,00Fh,0FFh,0FFh,0FFh,0FFh,000h,000h,00Fh,00Fh,0FFh,0FFh
   DEFB 000h,000h,0F0h,0F0h,00Fh,00Fh,0FFh,0FFh,0F0h,0F0h,0F0h,0F0h,00Fh,00Fh,0FFh,0FFh
   DEFB 00Fh,00Fh,0F0h,0F0h,00Fh,00Fh,0FFh,0FFh,0FFh,0FFh,0F0h,0F0h,00Fh,00Fh,0FFh,0FFh
   DEFB 000h,000h,00Fh,00Fh,00Fh,00Fh,0FFh,0FFh,0F0h,0F0h,00Fh,00Fh,00Fh,00Fh,0FFh,0FFh
   DEFB 00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,0FFh,0FFh,0FFh,0FFh,00Fh,00Fh,00Fh,00Fh,0FFh,0FFh
   DEFB 000h,000h,0FFh,0FFh,00Fh,00Fh,0FFh,0FFh,0F0h,0F0h,0FFh,0FFh,00Fh,00Fh,0FFh,0FFh
   DEFB 00Fh,00Fh,0FFh,0FFh,00Fh,00Fh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,00Fh,00Fh,0FFh,0FFh
   DEFB 000h,000h,000h,000h,0FFh,0FFh,0FFh,0FFh,0F0h,0F0h,000h,000h,0FFh,0FFh,0FFh,0FFh
   DEFB 00Fh,00Fh,000h,000h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,000h,000h,0FFh,0FFh,0FFh,0FFh
   DEFB 000h,000h,0F0h,0F0h,0FFh,0FFh,0FFh,0FFh,0F0h,0F0h,0F0h,0F0h,0FFh,0FFh,0FFh,0FFh
   DEFB 00Fh,00Fh,0F0h,0F0h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0F0h,0F0h,0FFh,0FFh,0FFh,0FFh
   DEFB 000h,000h,00Fh,00Fh,0FFh,0FFh,0FFh,0FFh,0F0h,0F0h,00Fh,00Fh,0FFh,0FFh,0FFh,0FFh
   DEFB 00Fh,00Fh,00Fh,00Fh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,00Fh,00Fh,0FFh,0FFh,0FFh,0FFh
   DEFB 000h,000h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0F0h,0F0h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
   DEFB 00Fh,00Fh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
#endasm

