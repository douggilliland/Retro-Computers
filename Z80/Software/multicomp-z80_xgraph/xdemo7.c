/* /////////////////////////////////////////////////////////////////////
//      xxdemo7.c
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
//  cc xdemo7
//  zsm xdemo7
//  hexcom xdemo7
//  gencom xdemo7.com xgraph.rsx
//
//  Changes:
//
//  20 Mar 2019 : First Version for Multicomp-Graphic
//
///////////////////////////////////////////////////////////////////// */


/* Some defines for MESCC
// ----------------------
*/
#define CC_NO_ARGS  /* No argc and argv[] in main */
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

/* -------------------------------------
// -------------- xdemo7 ---------------
// -------------------------------------
*/

main()
{
    int x,y,x0,y0,r1,r2,i;

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
      PrintStr(3, 229, "Demo7: Switch to ext. Font-ROM and back... ");

/* Predefine some state-variables */
    SetTxMode(XA_RC);

       y  = 2;
       x0 = 5;
       y  = 2;
       x  = x0;

 /* First let us backup the cp/m char-set to memory... */
        x = x0;
        PrintStr(x,y++,"First we will show 16 internal \"old\" char..."); y++;
        for(i = 0x40; i < 0x4F; i++) {
           PrintChr(3+x++,y,i); //x++;
        }
        x = x0; y++;

 /* Redefine Font-ROM to external... */
        x = x0; y++;
        PrintStr(x,y++,"Now we switch to ext. Font-ROM..."); y++;
     SetTxFnt(CGAmodern);
        PrintStr(x,y++,"and show 16 external \"new\" char..."); y++;
        for(i = 0x40; i < 0x4F; i++) {
           PrintChr(3+x++,y,i); //x++;
        }
        x = x0; y++;

 /* Redefine Font-ROM to internal... */
        y++;
        PrintStr(x,y++,"ok, let's switch back to int. Font-ROM..."); y++;
     ResTxFnt();
        PrintStr(x,y++,"and show 16 internal \"old\" char again..."); y++;
        for(i = 0x40; i < 0x4F; i++) {
           PrintChr(3+x++,y,i); //x++;
        }
        x = x0; y++;

/* Show the cursor again */
      ShowCursor();
}

#asm
CGAmodern: ;'modern'-font
  DEFB 000h,000h,066h,0DBh,0DBh,0DBh,066h,000h,03Ch,042h,081h,099h,081h,042h,03Ch,000h
  DEFB 0FEh,0C6h,0C0h,0C0h,0C0h,0C0h,0C0h,000h,010h,038h,038h,06Ch,06Ch,0C6h,0FEh,000h
  DEFB 03Ch,042h,0A5h,099h,0A5h,042h,03Ch,000h,000h,000h,000h,024h,018h,024h,000h,000h
  DEFB 000h,000h,018h,000h,07Eh,000h,018h,000h,000h,000h,018h,018h,000h,066h,066h,000h
  DEFB 0FEh,06Ch,06Ch,06Ch,06Ch,06Ch,06Ch,000h,018h,018h,018h,018h,07Eh,03Ch,018h,000h
  DEFB 0FEh,0C6h,060h,030h,060h,0C6h,0FEh,000h,000h,020h,060h,0FEh,0FEh,060h,020h,000h
  DEFB 000h,008h,00Ch,0FEh,0FEh,00Ch,008h,000h,000h,018h,018h,07Eh,018h,018h,07Eh,000h
  DEFB 000h,024h,066h,0FFh,0FFh,066h,024h,000h,07Ch,0C6h,0C6h,0C6h,0C6h,06Ch,0EEh,000h
  DEFB 000h,000h,073h,0DEh,0CCh,0DEh,073h,000h,07Ch,0C6h,0C6h,0FCh,0C6h,0C6h,0F8h,0C0h
  DEFB 066h,066h,03Ch,066h,066h,066h,03Ch,000h,03Ch,060h,03Ch,066h,066h,066h,03Ch,000h
  DEFB 000h,000h,01Eh,030h,07Ch,030h,01Eh,000h,038h,06Ch,0C6h,0FEh,0C6h,06Ch,038h,000h
  DEFB 000h,0C0h,060h,030h,038h,06Ch,0C6h,000h,000h,000h,066h,066h,066h,07Ch,060h,060h
  DEFB 000h,000h,0FEh,06Ch,06Ch,06Ch,06Ch,000h,000h,000h,03Ch,066h,066h,07Ch,060h,060h
  DEFB 000h,000h,07Eh,0D8h,0D8h,0D8h,070h,000h,000h,073h,0CEh,018h,018h,018h,00Ch,000h
  DEFB 003h,006h,03Ch,066h,066h,03Ch,060h,0C0h,000h,0E6h,03Ch,018h,038h,06Ch,0C7h,000h
  DEFB 003h,006h,066h,066h,066h,03Ch,060h,0C0h,000h,000h,066h,0C3h,0DBh,0DBh,07Eh,000h
  DEFB 000h,000h,000h,000h,000h,000h,000h,000h,008h,008h,008h,00Ch,00Ch,000h,00Ch,000h
  DEFB 06Ch,024h,06Ch,000h,000h,000h,000h,000h,024h,024h,07Eh,024h,07Eh,024h,024h,000h
  DEFB 008h,03Eh,020h,03Eh,006h,03Eh,008h,000h,000h,062h,064h,008h,010h,026h,046h,000h
  DEFB 03Ch,020h,024h,07Eh,064h,064h,07Ch,000h,01Ch,018h,010h,000h,000h,000h,000h,000h
  DEFB 004h,008h,010h,010h,010h,008h,004h,000h,020h,010h,008h,008h,008h,010h,020h,000h
  DEFB 008h,02Ah,01Ch,03Eh,01Ch,02Ah,008h,000h,000h,008h,008h,03Eh,008h,008h,000h,000h
  DEFB 000h,000h,000h,000h,000h,018h,018h,008h,000h,000h,000h,07Eh,000h,000h,000h,000h
  DEFB 000h,000h,000h,000h,000h,018h,018h,000h,000h,002h,004h,008h,010h,020h,040h,000h
  DEFB 07Eh,062h,052h,04Ah,046h,046h,07Eh,000h,018h,008h,008h,018h,018h,01Ah,03Eh,000h
  DEFB 07Eh,042h,002h,07Eh,060h,060h,07Eh,000h,07Ch,044h,004h,01Eh,006h,046h,07Eh,000h
  DEFB 044h,044h,044h,044h,07Eh,00Ch,00Ch,000h,07Eh,040h,07Eh,006h,006h,046h,07Eh,000h
  DEFB 07Eh,042h,040h,07Eh,046h,046h,07Eh,000h,07Eh,002h,002h,006h,006h,006h,006h,000h
  DEFB 03Ch,024h,024h,07Eh,046h,046h,07Eh,000h,07Eh,042h,042h,07Eh,006h,006h,006h,000h
  DEFB 000h,000h,018h,000h,000h,018h,000h,000h,000h,000h,018h,000h,000h,018h,018h,008h
  DEFB 00Eh,018h,030h,060h,030h,018h,00Eh,000h,000h,000h,07Eh,000h,07Eh,000h,000h,000h
  DEFB 070h,018h,00Ch,006h,00Ch,018h,070h,000h,07Eh,002h,002h,07Eh,060h,000h,060h,000h
  DEFB 01Ch,022h,04Ah,056h,04Ch,020h,01Eh,000h,03Ch,024h,024h,07Eh,062h,062h,062h,000h
  DEFB 078h,044h,044h,07Ch,062h,062h,07Eh,000h,07Eh,042h,040h,060h,060h,062h,07Eh,000h
  DEFB 07Ch,046h,042h,062h,062h,066h,07Ch,000h,07Eh,040h,040h,07Ch,060h,060h,07Eh,000h
  DEFB 07Eh,040h,040h,07Eh,060h,060h,060h,000h,07Eh,042h,040h,06Eh,062h,062h,07Eh,000h
  DEFB 042h,042h,042h,07Eh,062h,062h,062h,000h,008h,008h,008h,00Ch,00Ch,00Ch,00Ch,000h
  DEFB 004h,004h,004h,006h,006h,046h,07Eh,000h,042h,044h,048h,07Ch,062h,062h,062h,000h
  DEFB 040h,040h,040h,060h,060h,060h,07Eh,000h,07Eh,04Ah,04Ah,06Ah,06Ah,06Ah,06Ah,000h
  DEFB 07Eh,042h,042h,062h,062h,062h,062h,000h,07Eh,046h,042h,042h,042h,042h,07Eh,000h
  DEFB 07Eh,042h,042h,07Eh,060h,060h,060h,000h,07Eh,042h,042h,042h,04Ah,04Eh,07Eh,000h
  DEFB 07Ch,044h,044h,07Ch,062h,062h,062h,000h,07Eh,042h,040h,07Eh,006h,046h,07Eh,000h
  DEFB 03Eh,010h,010h,018h,018h,018h,018h,000h,042h,042h,042h,062h,062h,062h,07Eh,000h
  DEFB 062h,062h,062h,066h,024h,024h,03Ch,000h,04Ah,04Ah,04Ah,06Ah,06Ah,06Ah,07Eh,000h
  DEFB 042h,042h,066h,018h,066h,062h,062h,000h,022h,022h,022h,03Eh,018h,018h,018h,000h
  DEFB 07Eh,042h,006h,018h,060h,062h,07Eh,000h,03Ch,020h,020h,020h,020h,020h,03Ch,000h
  DEFB 000h,040h,020h,010h,008h,004h,002h,000h,03Ch,004h,004h,004h,004h,004h,03Ch,000h
  DEFB 000h,008h,01Ch,02Ah,008h,008h,008h,000h,000h,000h,000h,000h,000h,000h,07Eh,000h
  DEFB 01Ch,018h,010h,000h,000h,000h,000h,000h,000h,000h,03Ch,004h,07Ch,064h,07Ch,000h
  DEFB 040h,040h,07Eh,042h,062h,062h,07Eh,000h,000h,000h,07Eh,042h,060h,062h,07Eh,000h
  DEFB 002h,002h,07Eh,042h,062h,062h,07Eh,000h,000h,000h,07Eh,042h,07Eh,060h,07Eh,000h
  DEFB 01Eh,012h,010h,07Ch,018h,018h,018h,000h,000h,000h,07Eh,042h,062h,07Eh,002h,07Eh
  DEFB 040h,040h,07Eh,042h,062h,062h,062h,000h,018h,000h,010h,010h,018h,018h,018h,000h
  DEFB 00Ch,000h,008h,00Ch,00Ch,00Ch,044h,07Ch,040h,040h,044h,048h,078h,064h,064h,000h
  DEFB 010h,010h,010h,010h,018h,018h,018h,000h,000h,000h,07Fh,049h,06Dh,06Dh,06Dh,000h
  DEFB 000h,000h,07Eh,042h,062h,062h,062h,000h,000h,000h,07Eh,042h,062h,062h,07Eh,000h
  DEFB 000h,000h,07Eh,042h,062h,07Eh,040h,040h,000h,000h,07Eh,042h,046h,07Eh,002h,002h
  DEFB 000h,000h,07Eh,040h,060h,060h,060h,000h,000h,000h,07Eh,040h,07Eh,006h,07Eh,000h
  DEFB 010h,010h,07Ch,010h,018h,018h,018h,000h,000h,000h,042h,042h,062h,062h,07Eh,000h
  DEFB 000h,000h,062h,062h,066h,024h,03Ch,000h,000h,000h,049h,049h,06Dh,06Dh,07Fh,000h
  DEFB 000h,000h,042h,042h,03Ch,062h,062h,000h,000h,000h,062h,062h,042h,07Eh,002h,07Eh
  DEFB 000h,000h,07Eh,006h,018h,060h,07Eh,000h,006h,008h,018h,070h,018h,008h,006h,000h
  DEFB 018h,018h,018h,018h,018h,018h,018h,000h,060h,010h,018h,00Eh,018h,010h,060h,000h
  DEFB 034h,048h,000h,000h,000h,000h,000h,000h,038h,06Ch,044h,044h,044h,06Ch,038h,000h
  DEFB 000h,000h,03Ch,03Ch,03Ch,03Ch,000h,000h,018h,018h,0FFh,000h,000h,0FFh,000h,000h
  DEFB 024h,024h,024h,027h,027h,024h,024h,024h,024h,024h,027h,020h,020h,03Fh,000h,000h
  DEFB 000h,000h,0FFh,000h,000h,0FFh,018h,018h,024h,024h,024h,024h,024h,024h,024h,024h
  DEFB 000h,000h,03Fh,020h,020h,027h,024h,024h,024h,024h,027h,020h,020h,027h,024h,024h
  DEFB 024h,024h,024h,0E4h,0E4h,024h,024h,024h,024h,024h,0E4h,004h,004h,0FCh,000h,000h
  DEFB 000h,000h,0FFh,000h,000h,0FFh,000h,000h,024h,024h,0E7h,000h,000h,0FFh,000h,000h
  DEFB 000h,000h,0FCh,004h,004h,0E4h,024h,024h,024h,024h,0E4h,004h,004h,0E4h,024h,024h
  DEFB 000h,000h,0FFh,000h,000h,0E7h,024h,024h,024h,024h,0E7h,000h,000h,0E7h,024h,024h
  DEFB 000h,000h,000h,018h,018h,000h,000h,000h,018h,018h,018h,018h,018h,000h,000h,000h
  DEFB 000h,000h,000h,01Fh,01Fh,000h,000h,000h,018h,018h,018h,01Fh,00Fh,000h,000h,000h
  DEFB 000h,000h,000h,018h,018h,018h,018h,018h,018h,018h,018h,018h,018h,018h,018h,018h
  DEFB 000h,000h,000h,00Fh,01Fh,018h,018h,018h,018h,018h,018h,01Fh,01Fh,018h,018h,018h
  DEFB 000h,000h,000h,0F8h,0F8h,000h,000h,000h,018h,018h,018h,0F8h,0F0h,000h,000h,000h
  DEFB 000h,000h,000h,0FFh,0FFh,000h,000h,000h,018h,018h,018h,0FFh,0FFh,000h,000h,000h
  DEFB 000h,000h,000h,0F0h,0F8h,018h,018h,018h,018h,018h,018h,0F8h,0F8h,018h,018h,018h
  DEFB 000h,000h,000h,0FFh,0FFh,018h,018h,018h,018h,018h,018h,0FFh,0FFh,018h,018h,018h
  DEFB 078h,00Ch,07Ch,0CCh,076h,000h,0FEh,000h,03Ch,066h,066h,066h,03Ch,000h,07Eh,000h
  DEFB 038h,044h,038h,000h,000h,000h,000h,000h,03Ch,066h,060h,0F8h,060h,066h,0FEh,000h
  DEFB 038h,044h,0BAh,0A2h,0BAh,044h,038h,000h,07Eh,0F4h,0F4h,074h,034h,034h,034h,000h
  DEFB 01Eh,030h,038h,06Ch,038h,018h,0F0h,000h,018h,018h,07Eh,018h,018h,018h,018h,000h
  DEFB 042h,0C4h,04Ah,056h,06Ah,05Fh,082h,000h,042h,0C4h,04Ch,052h,064h,048h,09Eh,000h
  DEFB 0E2h,014h,06Ah,016h,0EAh,02Fh,042h,000h,000h,033h,066h,0CCh,066h,033h,000h,000h
  DEFB 000h,0CCh,066h,033h,066h,0CCh,000h,000h,0E0h,090h,094h,0EEh,084h,084h,083h,000h
  DEFB 018h,000h,018h,030h,066h,066h,03Ch,000h,018h,000h,018h,018h,018h,018h,018h,000h
  DEFB 01Ch,036h,030h,0FCh,030h,030h,0E0h,000h,000h,018h,03Ch,066h,060h,066h,03Ch,018h
  DEFB 000h,066h,000h,000h,000h,000h,000h,000h,00Ch,018h,030h,000h,000h,000h,000h,000h
  DEFB 010h,038h,06Ch,0C6h,000h,000h,000h,000h,000h,0C6h,0CCh,018h,020h,05Bh,0DBh,000h
  DEFB 042h,0C4h,04Eh,049h,056h,029h,046h,000h,0E2h,014h,06Eh,019h,0E6h,029h,046h,000h
  DEFB 0F2h,084h,0EEh,019h,0F6h,029h,046h,000h,0F2h,014h,02Eh,059h,0A6h,049h,086h,000h
  DEFB 038h,0C6h,0C6h,0F8h,0C6h,0C6h,0F8h,000h,000h,038h,06Ch,0C6h,0C6h,06Ch,038h,000h
  DEFB 000h,038h,07Ch,0FEh,0FEh,07Ch,038h,000h,066h,066h,03Ch,018h,07Eh,018h,03Ch,000h
  DEFB 03Ch,042h,0B9h,0A5h,0B9h,0A9h,066h,03Ch,0FBh,055h,051h,051h,000h,000h,000h,000h
  DEFB 00Ch,030h,018h,03Ch,066h,07Eh,066h,000h,00Ch,030h,07Eh,060h,07Ch,060h,07Eh,000h
  DEFB 00Ch,030h,07Eh,018h,018h,018h,07Eh,000h,00Ch,030h,03Ch,066h,066h,066h,03Ch,000h
  DEFB 00Ch,030h,066h,066h,066h,066h,03Ch,000h,018h,066h,018h,03Ch,066h,07Eh,066h,000h
  DEFB 018h,066h,07Eh,060h,07Ch,060h,07Eh,000h,018h,066h,07Eh,018h,018h,018h,07Eh,000h
  DEFB 018h,066h,03Ch,066h,066h,066h,03Ch,000h,018h,066h,066h,066h,066h,066h,03Ch,000h
  DEFB 030h,00Ch,018h,03Ch,066h,07Eh,066h,000h,030h,00Ch,07Eh,060h,07Ch,060h,07Eh,000h
  DEFB 030h,00Ch,07Eh,018h,018h,018h,07Eh,000h,030h,00Ch,03Ch,066h,066h,066h,03Ch,000h
  DEFB 030h,00Ch,066h,066h,066h,066h,03Ch,000h,066h,000h,066h,03Ch,018h,018h,018h,000h
  DEFB 066h,000h,018h,03Ch,066h,07Eh,066h,000h,066h,000h,07Eh,060h,07Ch,060h,07Eh,000h
  DEFB 066h,000h,07Eh,018h,018h,018h,07Eh,000h,066h,000h,03Ch,066h,066h,066h,03Ch,000h
  DEFB 066h,000h,066h,066h,066h,066h,03Ch,000h,03Ch,066h,0C0h,0C0h,066h,03Ch,000h,018h
  DEFB 03Eh,078h,0D8h,0FEh,0D8h,0D8h,0DEh,000h,018h,000h,018h,03Ch,066h,07Eh,066h,000h
  DEFB 07Ah,0CCh,0CEh,0D6h,0E6h,066h,0BCh,000h,032h,04Ch,000h,066h,076h,06Eh,066h,000h
  DEFB 032h,04Ch,000h,03Ch,066h,07Eh,066h,000h,032h,04Ch,03Ch,066h,066h,066h,03Ch,000h
  DEFB 0C0h,030h,00Ch,030h,0CCh,030h,0C0h,000h,006h,018h,060h,018h,066h,018h,006h,000h
  DEFB 006h,00Ch,07Eh,018h,07Eh,030h,060h,000h,000h,000h,032h,04Ch,000h,07Eh,000h,000h
  DEFB 00Ch,030h,078h,00Ch,07Ch,0CCh,076h,000h,00Ch,030h,03Ch,066h,07Eh,060h,03Ch,000h
  DEFB 00Ch,030h,000h,038h,018h,018h,03Ch,000h,00Ch,030h,000h,03Ch,066h,066h,03Ch,000h
  DEFB 00Ch,030h,000h,066h,066h,066h,03Eh,000h,018h,066h,078h,00Ch,07Ch,0CCh,076h,000h
  DEFB 018h,066h,03Ch,066h,07Eh,060h,03Ch,000h,018h,066h,000h,038h,018h,018h,03Ch,000h
  DEFB 018h,066h,000h,03Ch,066h,066h,03Ch,000h,018h,066h,000h,066h,066h,066h,03Ch,000h
  DEFB 030h,00Ch,078h,00Ch,07Ch,0CCh,076h,000h,030h,00Ch,03Ch,066h,07Eh,060h,03Ch,000h
  DEFB 030h,00Ch,000h,038h,018h,018h,03Ch,000h,030h,00Ch,000h,03Ch,066h,066h,03Ch,000h
  DEFB 030h,00Ch,000h,066h,066h,066h,03Ch,000h,066h,000h,066h,066h,066h,03Eh,006h,07Ch
  DEFB 066h,000h,078h,00Ch,07Ch,0CCh,076h,000h,066h,000h,03Ch,066h,07Eh,060h,03Ch,000h
  DEFB 066h,000h,038h,018h,018h,018h,03Ch,000h,066h,000h,000h,03Ch,066h,066h,03Ch,000h
  DEFB 066h,000h,000h,066h,066h,066h,03Eh,000h,000h,000h,03Ch,060h,060h,03Ch,000h,018h
  DEFB 000h,000h,06Ch,01Ah,07Eh,0D8h,06Eh,000h,018h,000h,078h,00Ch,07Ch,0CCh,076h,000h
  DEFB 000h,000h,07Ah,0CCh,0D6h,066h,0BCh,000h,032h,04Ch,000h,0DCh,066h,066h,066h,000h
  DEFB 032h,04Ch,078h,00Ch,07Ch,0CCh,076h,000h,032h,04Ch,000h,03Ch,066h,066h,03Ch,000h
  DEFB 008h,00Ch,0FEh,007h,0FEh,00Ch,008h,000h,010h,030h,07Fh,0E0h,07Fh,030h,010h,000h
  DEFB 000h,024h,07Eh,0C3h,07Eh,024h,000h,000h,000h,07Eh,000h,07Eh,000h,07Eh,000h,000h
#endasm
