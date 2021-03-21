/* /////////////////////////////////////////////////////////////////////
//      xdemo6.c
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
//  cc xdemo6
//  zsm xdemo6
//  hexcom xdemo6
//  gencom xdemo6.com xgraph.rsx
//
//  Changes:
//
//  31 Jan 2019 : First Version for Multicomp-Graphic
//
///////////////////////////////////////////////////////////////////// */


/* Some defines for MESCC
// ----------------------
*/
// #define CC_STDIO        // Support for stdin, stdout, stderr.
// #define CC_REDIR        // Support for command line redirection - needs CC_STDIO.
//
// #define CC_CONIO_BIOS   // Console I/O through BIOS instead of BDOS.
//
#define CC_FCX          // Support for user number in filenames.
#define CC_FCX_DIR      // Support for named user numbers - needs CC_FCX and DirToDrvUsr().
//
// #define CC_FOPEN_A   // Enable modes "a" and "ab" for fopen.
// #define CC_FREAD     // Include fread().
// #define CC_FWRITE    // Include fwrite().
// #define CC_FGETS     // Include fgets().
//
// #define CC_NO_MUL       // Exclude support for MULTIPLICATION.
// #define CC_NO_DIV       // Exclude support for DIVISION and MODULUS.
// #define CC_NO_SWITCH    // Exclude support for SWITCH.
//
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

#define APP_NAME    "xdemo6"
#define APP_VERSION "v1.00 / 15 Mar 2019"
#define APP_COPYRGT "(c) 2019 K. Mueller"
#define APP_USAGE   "xdemo6 <cr>"

/* -------------------------------------
// -------------- XDemo6 ---------------
// -------------------------------------
*/

/* ===================================
// ====       Redefine a chr       ===
// ===================================
// chr1  = char. used for redefinition
// addr1 = address from where the char. is red
// chr2  = char. that is replaced
// addr2 = Buffer where the replaced char. is saved to
//
// Remark: No buffer overrun check is done !
*/
RedefChr(chr1, addr1, chr2, addr2)
int   chr1, chr2;
BYTE *addr1, *addr2;
{
    RdChfrAddr(chr1, addr1);    /* get new char data */
    *addr2++ = chr2;            /* write replaced chr-code to buffer */
    WrChToAddr(chr2, addr2);    /* write new char to buffer at addr2 */
    WrFntROM(1,chr2, addr2);    /* write new char to Font-ROM */
}


main()
{
    int  i,j,k,y,x,x0;
    int  chr;

/* ASCII Clear-Screen */
    AClrScr();

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
      PrintStr(3, 229, "Demo6: Redefining single characters... ");

/* Show old upper 128 char. of font-rom on display*/
    SetTxMode(XA_RC);

       y  = 2;
       x0 = 5;
       y  = 2;
       x  = x0;

/* First let us backup the cp/m char-set to memory... */
       PrintStr(x,y++,"First we backup the original CP/M font-set to memory..."); y++;
       RdFntROM(255, 0x00, cpmfontset);

       PrintStr(x,y++,"Next we will redefine 16 char. ..."); y++;
       PrintStr(x,y++,"First start printing \"old\" 16 char..."); y++;
       for(i = 0x80; i < 0x8F; i++) {
          PrintChr(3+x++,y,i); //x++;
          if((x-x/0x40*0x40) == 0) {y++; x = x0;}
       }

/* Now let us transfer the new char to the upper half of CROM... */
       y += 2;
       x = x0;
       chr = 0x80;

/* Redefined char's = 0x80...0x8A with "Hello Dolly" */
       PrintStr(x,y,"Redefining char...");
       RedefChr('H', CpmFontSet, chr++, ReplChrBuf);
       RedefChr('e', CpmFontSet, chr++, ReplChrBuf);
       RedefChr('l', CpmFontSet, chr++, ReplChrBuf);
       RedefChr('l', CpmFontSet, chr++, ReplChrBuf);
       RedefChr('o', CpmFontSet, chr++, ReplChrBuf);
       RedefChr(' ', CpmFontSet, chr++, ReplChrBuf);
       RedefChr('D', CpmFontSet, chr++, ReplChrBuf);
       RedefChr('o', CpmFontSet, chr++, ReplChrBuf);
       RedefChr('l', CpmFontSet, chr++, ReplChrBuf);
       RedefChr('l', CpmFontSet, chr++, ReplChrBuf);
       RedefChr('y', CpmFontSet, chr++, ReplChrBuf);
       RedefChr(' ', CpmFontSet, chr++, ReplChrBuf);
       RedefChr('!', CpmFontSet, chr++, ReplChrBuf);
       RedefChr(' ', CpmFontSet, chr++, ReplChrBuf);
//     RedefChr(' ', CpmFontSet, chr++, ReplChrBuf);
//     RedefChr(' ', CpmFontSet, chr++, ReplChrBuf);

/* Show new replaced char. on display*/
       y += 2;
       x = x0;

       PrintStr(x,y++,"Now we start printing \"new\" defined char's..."); y++;
       for(i = 0x80; i < 0x8F; i++) {
          PrintChr(3+x++,y,i);
          if((x-x/0x40*0x40) == 0) {y++; x = x0;}
       }

/* Show restored char. on display*/
       y += 2;
       x = x0;

       WrFntROM(16, 0x80, cpmfontset);
       PrintStr(x,y++,"Restoring redefined char..."); y++;
       PrintStr(x,y++,"Now we show \"restored\" char..."); y++;
       for(i = 0x80; i < 0x8F; i++) {
          PrintChr(3+x++,y,i);
          if((x-x/0x40*0x40) == 0) {y++; x = x0;}
       }

/* Show the cursor again */
      ShowCursor();
}

#asm
CpmFontSet:
   DEFS 2048
#endasm

#asm
ReplChrBuf:
   DEFS 256
#endasm
