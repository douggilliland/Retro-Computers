/* /////////////////////////////////////////////////////////////////////
//      RestFont.c
//
//  Restores the the Multicomp main Font in Font-ROMs.
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
//  cc RestFont
//  zsm RestFont
//  hexcom RestFont
//  gencom RestFont.com xgraph.rsx
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

/* -------------------------------------
// -------------- XDemo5 ---------------
// -------------------------------------
*/

main()
{

/* ASCII Clear-Screen */
    AClrScr();

/* Check if the RSX is in memory */
    if(!HelloRsx()) {
        puts("The RSX is not in memory!");
        return -1;
    }

/* Init Graphic */
    InitGraphic();

/* Graphic switched OFF */
    GScreen(X_OFF);

/* Show restore full char-set font-rom */
       WrFntROM(255, 0x00, CGASanSerEx);
}

#asm
CGASanSerEx: New 'CGASanSerifExtended'-Font for Multicomp
 DEFB 000h, 000h, 066h, 0DBh, 0DBh, 0DBh, 066h, 000h, 03Ch, 042h, 081h, 099h, 081h, 042h, 03Ch, 000h
 DEFB 0FEh, 0C6h, 0C0h, 0C0h, 0C0h, 0C0h, 0C0h, 000h, 010h, 038h, 038h, 06Ch, 06Ch, 0C6h, 0FEh, 000h
 DEFB 03Ch, 042h, 0A5h, 099h, 0A5h, 042h, 03Ch, 000h, 000h, 000h, 000h, 024h, 018h, 024h, 000h, 000h
 DEFB 000h, 000h, 018h, 000h, 07Eh, 000h, 018h, 000h, 000h, 000h, 018h, 018h, 000h, 066h, 066h, 000h
 DEFB 0FEh, 06Ch, 06Ch, 06Ch, 06Ch, 06Ch, 06Ch, 000h, 018h, 018h, 018h, 018h, 07Eh, 03Ch, 018h, 000h
 DEFB 0FEh, 0C6h, 060h, 030h, 060h, 0C6h, 0FEh, 000h, 000h, 020h, 060h, 0FEh, 0FEh, 060h, 020h, 000h
 DEFB 000h, 008h, 00Ch, 0FEh, 0FEh, 00Ch, 008h, 000h, 000h, 018h, 018h, 07Eh, 018h, 018h, 07Eh, 000h
 DEFB 000h, 024h, 066h, 0FFh, 0FFh, 066h, 024h, 000h, 07Ch, 0C6h, 0C6h, 0C6h, 0C6h, 06Ch, 0EEh, 000h
 DEFB 000h, 000h, 073h, 0DEh, 0CCh, 0DEh, 073h, 000h, 07Ch, 0C6h, 0C6h, 0FCh, 0C6h, 0C6h, 0F8h, 0C0h
 DEFB 066h, 066h, 03Ch, 066h, 066h, 066h, 03Ch, 000h, 03Ch, 060h, 03Ch, 066h, 066h, 066h, 03Ch, 000h
 DEFB 000h, 000h, 01Eh, 030h, 07Ch, 030h, 01Eh, 000h, 038h, 06Ch, 0C6h, 0FEh, 0C6h, 06Ch, 038h, 000h
 DEFB 000h, 0C0h, 060h, 030h, 038h, 06Ch, 0C6h, 000h, 000h, 000h, 066h, 066h, 066h, 07Ch, 060h, 060h
 DEFB 000h, 000h, 0FEh, 06Ch, 06Ch, 06Ch, 06Ch, 000h, 000h, 000h, 03Ch, 066h, 066h, 07Ch, 060h, 060h
 DEFB 000h, 000h, 07Eh, 0D8h, 0D8h, 0D8h, 070h, 000h, 000h, 073h, 0CEh, 018h, 018h, 018h, 00Ch, 000h
 DEFB 003h, 006h, 03Ch, 066h, 066h, 03Ch, 060h, 0C0h, 000h, 0E6h, 03Ch, 018h, 038h, 06Ch, 0C7h, 000h
 DEFB 003h, 006h, 066h, 066h, 066h, 03Ch, 060h, 0C0h, 000h, 000h, 066h, 0C3h, 0DBh, 0DBh, 07Eh, 000h
 DEFB 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 018h, 018h, 018h, 018h, 018h, 000h, 018h, 000h
 DEFB 06Ch, 06Ch, 06Ch, 000h, 000h, 000h, 000h, 000h, 06Ch, 06Ch, 0FEh, 06Ch, 0FEh, 06Ch, 06Ch, 000h
 DEFB 018h, 03Eh, 058h, 03Ch, 01Ah, 07Ch, 018h, 000h, 000h, 0C6h, 0CCh, 018h, 030h, 066h, 0C6h, 000h
 DEFB 038h, 06Ch, 038h, 076h, 0DCh, 0CCh, 076h, 000h, 018h, 018h, 018h, 000h, 000h, 000h, 000h, 000h
 DEFB 00Ch, 018h, 030h, 030h, 030h, 018h, 00Ch, 000h, 030h, 018h, 00Ch, 00Ch, 00Ch, 018h, 030h, 000h
 DEFB 000h, 066h, 03Ch, 0FFh, 03Ch, 066h, 000h, 000h, 000h, 018h, 018h, 07Eh, 018h, 018h, 000h, 000h
 DEFB 000h, 000h, 000h, 000h, 000h, 018h, 018h, 030h, 000h, 000h, 000h, 07Eh, 000h, 000h, 000h, 000h
 DEFB 000h, 000h, 000h, 000h, 000h, 018h, 018h, 000h, 006h, 00Ch, 018h, 030h, 060h, 0C0h, 080h, 000h
 DEFB 07Ch, 0C6h, 0CEh, 0D6h, 0E6h, 0C6h, 07Ch, 000h, 018h, 078h, 018h, 018h, 018h, 018h, 018h, 000h
 DEFB 07Ch, 0C6h, 006h, 01Ch, 070h, 0C0h, 0FEh, 000h, 07Ch, 0C6h, 006h, 01Ch, 006h, 0C6h, 07Ch, 000h
 DEFB 01Ch, 03Ch, 06Ch, 0CCh, 0FEh, 00Ch, 00Ch, 000h, 0FEh, 0C0h, 0C0h, 0FCh, 006h, 0C6h, 07Ch, 000h
 DEFB 07Ch, 0C6h, 0C0h, 0FCh, 0C6h, 0C6h, 07Ch, 000h, 0FEh, 006h, 00Ch, 018h, 030h, 030h, 030h, 000h
 DEFB 07Ch, 0C6h, 0C6h, 07Ch, 0C6h, 0C6h, 07Ch, 000h, 07Ch, 0C6h, 0C6h, 07Eh, 006h, 0C6h, 07Ch, 000h
 DEFB 000h, 000h, 018h, 018h, 000h, 018h, 018h, 000h, 000h, 000h, 018h, 018h, 000h, 018h, 018h, 030h
 DEFB 00Ch, 018h, 030h, 060h, 030h, 018h, 00Ch, 000h, 000h, 000h, 07Eh, 000h, 07Eh, 000h, 000h, 000h
 DEFB 060h, 030h, 018h, 00Ch, 018h, 030h, 060h, 000h, 07Ch, 0C6h, 0C6h, 00Ch, 018h, 000h, 018h, 000h
 DEFB 07Ch, 0C6h, 0DEh, 0DEh, 0DEh, 0C0h, 07Ch, 000h, 038h, 06Ch, 0C6h, 0C6h, 0FEh, 0C6h, 0C6h, 000h
 DEFB 0FCh, 0C6h, 0C6h, 0FCh, 0C6h, 0C6h, 0FCh, 000h, 03Ch, 066h, 0C0h, 0C0h, 0C0h, 066h, 03Ch, 000h
 DEFB 0F8h, 0CCh, 0C6h, 0C6h, 0C6h, 0CCh, 0F8h, 000h, 0FEh, 0C0h, 0C0h, 0F8h, 0C0h, 0C0h, 0FEh, 000h
 DEFB 0FEh, 0C0h, 0C0h, 0F8h, 0C0h, 0C0h, 0C0h, 000h, 03Ch, 066h, 0C0h, 0C0h, 0CEh, 066h, 03Eh, 000h
 DEFB 0C6h, 0C6h, 0C6h, 0FEh, 0C6h, 0C6h, 0C6h, 000h, 07Eh, 018h, 018h, 018h, 018h, 018h, 07Eh, 000h
 DEFB 01Eh, 00Ch, 00Ch, 00Ch, 0CCh, 0CCh, 078h, 000h, 0C6h, 0CCh, 0D8h, 0F0h, 0D8h, 0CCh, 0C6h, 000h
 DEFB 0C0h, 0C0h, 0C0h, 0C0h, 0C0h, 0C0h, 0FEh, 000h, 0C6h, 0EEh, 0FEh, 0D6h, 0C6h, 0C6h, 0C6h, 000h
 DEFB 0C6h, 0E6h, 0F6h, 0DEh, 0CEh, 0C6h, 0C6h, 000h, 07Ch, 0C6h, 0C6h, 0C6h, 0C6h, 0C6h, 07Ch, 000h
 DEFB 0FCh, 0C6h, 0C6h, 0FCh, 0C0h, 0C0h, 0C0h, 000h, 07Ch, 0C6h, 0C6h, 0C6h, 0DAh, 0CCh, 076h, 000h
 DEFB 0FCh, 0C6h, 0C6h, 0FCh, 0D8h, 0CCh, 0C6h, 000h, 07Ch, 0C6h, 0C0h, 07Ch, 006h, 0C6h, 07Ch, 000h
 DEFB 0FCh, 030h, 030h, 030h, 030h, 030h, 030h, 000h, 0C6h, 0C6h, 0C6h, 0C6h, 0C6h, 0C6h, 07Ch, 000h
 DEFB 0C6h, 0C6h, 0C6h, 0C6h, 0C6h, 06Ch, 038h, 000h, 0C6h, 0C6h, 0C6h, 0D6h, 0FEh, 0EEh, 0C6h, 000h
 DEFB 0C6h, 06Ch, 038h, 038h, 06Ch, 0C6h, 0C6h, 000h, 066h, 066h, 066h, 03Ch, 018h, 018h, 018h, 000h
 DEFB 0FEh, 006h, 00Ch, 018h, 030h, 060h, 0FEh, 000h, 03Ch, 030h, 030h, 030h, 030h, 030h, 03Ch, 000h
 DEFB 0C0h, 060h, 030h, 018h, 00Ch, 006h, 002h, 000h, 03Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 03Ch, 000h
 DEFB 018h, 03Ch, 07Eh, 018h, 018h, 018h, 018h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 0FFh
 DEFB 030h, 018h, 00Ch, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 07Ch, 006h, 07Eh, 0C6h, 07Eh, 000h
 DEFB 0C0h, 0C0h, 0FCh, 0C6h, 0C6h, 0C6h, 0FCh, 000h, 000h, 000h, 07Ch, 0C6h, 0C0h, 0C6h, 07Ch, 000h
 DEFB 006h, 006h, 07Eh, 0C6h, 0C6h, 0C6h, 07Eh, 000h, 000h, 000h, 07Ch, 0C6h, 0FEh, 0C0h, 07Ch, 000h
 DEFB 03Ch, 066h, 060h, 0FCh, 060h, 060h, 060h, 000h, 000h, 000h, 07Eh, 0C6h, 0C6h, 07Eh, 006h, 07Ch
 DEFB 0C0h, 0C0h, 0FCh, 0C6h, 0C6h, 0C6h, 0C6h, 000h, 018h, 000h, 018h, 018h, 018h, 018h, 018h, 000h
 DEFB 006h, 000h, 006h, 006h, 006h, 0C6h, 0C6h, 07Ch, 0C0h, 0C0h, 0C6h, 0CCh, 0F8h, 0CCh, 0C6h, 000h
 DEFB 030h, 030h, 030h, 030h, 030h, 030h, 01Ch, 000h, 000h, 000h, 06Ch, 0FEh, 0D6h, 0D6h, 0C6h, 000h
 DEFB 000h, 000h, 0FCh, 0C6h, 0C6h, 0C6h, 0C6h, 000h, 000h, 000h, 07Ch, 0C6h, 0C6h, 0C6h, 07Ch, 000h
 DEFB 000h, 000h, 0FCh, 0C6h, 0C6h, 0FCh, 0C0h, 0C0h, 000h, 000h, 07Eh, 0C6h, 0C6h, 07Eh, 006h, 006h
 DEFB 000h, 000h, 0DEh, 0F0h, 0C0h, 0C0h, 0C0h, 000h, 000h, 000h, 07Ch, 0C0h, 07Ch, 006h, 07Ch, 000h
 DEFB 060h, 060h, 0FCh, 060h, 060h, 066h, 03Ch, 000h, 000h, 000h, 0C6h, 0C6h, 0C6h, 0C6h, 07Eh, 000h
 DEFB 000h, 000h, 0C6h, 0C6h, 0C6h, 06Ch, 038h, 000h, 000h, 000h, 0C6h, 0D6h, 0D6h, 0FEh, 06Ch, 000h
 DEFB 000h, 000h, 0C6h, 06Ch, 038h, 06Ch, 0C6h, 000h, 000h, 000h, 0C6h, 0C6h, 0C6h, 07Eh, 006h, 0FCh
 DEFB 000h, 000h, 0FEh, 01Ch, 038h, 070h, 0FEh, 000h, 00Eh, 018h, 018h, 070h, 018h, 018h, 00Eh, 000h
 DEFB 018h, 018h, 018h, 018h, 018h, 018h, 018h, 000h, 070h, 018h, 018h, 00Eh, 018h, 018h, 070h, 000h
 DEFB 076h, 0DCh, 000h, 000h, 000h, 000h, 000h, 000h, 038h, 06Ch, 0C6h, 0C6h, 0C6h, 06Ch, 038h, 000h
 DEFB 000h, 000h, 03Ch, 03Ch, 03Ch, 03Ch, 000h, 000h, 018h, 018h, 0FFh, 000h, 000h, 0FFh, 000h, 000h
 DEFB 024h, 024h, 024h, 027h, 027h, 024h, 024h, 024h, 024h, 024h, 027h, 020h, 020h, 03Fh, 000h, 000h
 DEFB 000h, 000h, 0FFh, 000h, 000h, 0FFh, 018h, 018h, 024h, 024h, 024h, 024h, 024h, 024h, 024h, 024h
 DEFB 000h, 000h, 03Fh, 020h, 020h, 027h, 024h, 024h, 024h, 024h, 027h, 020h, 020h, 027h, 024h, 024h
 DEFB 024h, 024h, 024h, 0E4h, 0E4h, 024h, 024h, 024h, 024h, 024h, 0E4h, 004h, 004h, 0FCh, 000h, 000h
 DEFB 000h, 000h, 0FFh, 000h, 000h, 0FFh, 000h, 000h, 024h, 024h, 0E7h, 000h, 000h, 0FFh, 000h, 000h
 DEFB 000h, 000h, 0FCh, 004h, 004h, 0E4h, 024h, 024h, 024h, 024h, 0E4h, 004h, 004h, 0E4h, 024h, 024h
 DEFB 000h, 000h, 0FFh, 000h, 000h, 0E7h, 024h, 024h, 024h, 024h, 0E7h, 000h, 000h, 0E7h, 024h, 024h
 DEFB 000h, 000h, 000h, 018h, 018h, 000h, 000h, 000h, 018h, 018h, 018h, 018h, 018h, 000h, 000h, 000
 DEFB 000h, 000h, 000h, 01Fh, 01Fh, 000h, 000h, 000h, 018h, 018h, 018h, 01Fh, 00Fh, 000h, 000h, 000h
 DEFB 000h, 000h, 000h, 018h, 018h, 018h, 018h, 018h, 018h, 018h, 018h, 018h, 018h, 018h, 018h, 018h
 DEFB 000h, 000h, 000h, 00Fh, 01Fh, 018h, 018h, 018h, 018h, 018h, 018h, 01Fh, 01Fh, 018h, 018h, 018h
 DEFB 000h, 000h, 000h, 0F8h, 0F8h, 000h, 000h, 000h, 018h, 018h, 018h, 0F8h, 0F0h, 000h, 000h, 000h
 DEFB 000h, 000h, 000h, 0FFh, 0FFh, 000h, 000h, 000h, 018h, 018h, 018h, 0FFh, 0FFh, 000h, 000h, 000h
 DEFB 000h, 000h, 000h, 0F0h, 0F8h, 018h, 018h, 018h, 018h, 018h, 018h, 0F8h, 0F8h, 018h, 018h, 018h
 DEFB 000h, 000h, 000h, 0FFh, 0FFh, 018h, 018h, 018h, 018h, 018h, 018h, 0FFh, 0FFh, 018h, 018h, 018h
 DEFB 078h, 00Ch, 07Ch, 0CCh, 076h, 000h, 0FEh, 000h, 03Ch, 066h, 066h, 066h, 03Ch, 000h, 07Eh, 000h
 DEFB 038h, 044h, 038h, 000h, 000h, 000h, 000h, 000h, 03Ch, 066h, 060h, 0F8h, 060h, 066h, 0FEh, 000h
 DEFB 038h, 044h, 0BAh, 0A2h, 0BAh, 044h, 038h, 000h, 07Eh, 0F4h, 0F4h, 074h, 034h, 034h, 034h, 000h
 DEFB 01Eh, 030h, 038h, 06Ch, 038h, 018h, 0F0h, 000h, 018h, 018h, 07Eh, 018h, 018h, 018h, 018h, 000h
 DEFB 040h, 0C0h, 044h, 04Ch, 054h, 01Eh, 004h, 000h, 040h, 0C0h, 04Ch, 052h, 044h, 008h, 01Eh, 000h
 DEFB 0E0h, 010h, 062h, 016h, 0EAh, 00Fh, 002h, 000h, 000h, 033h, 066h, 0CCh, 066h, 033h, 000h, 000h
 DEFB 000h, 0CCh, 066h, 033h, 066h, 0CCh, 000h, 000h, 0E0h, 090h, 094h, 0EEh, 084h, 084h, 083h, 000h
 DEFB 018h, 000h, 018h, 030h, 066h, 066h, 03Ch, 000h, 018h, 000h, 018h, 018h, 018h, 018h, 018h, 000h
 DEFB 01Ch, 036h, 030h, 0FCh, 030h, 030h, 0E0h, 000h, 000h, 018h, 03Ch, 066h, 060h, 066h, 03Ch, 018h
 DEFB 000h, 066h, 000h, 000h, 000h, 000h, 000h, 000h, 00Ch, 018h, 030h, 000h, 000h, 000h, 000h, 000h
 DEFB 010h, 038h, 06Ch, 0C6h, 000h, 000h, 000h, 000h, 000h, 0C6h, 0CCh, 018h, 020h, 05Bh, 0DBh, 000h
 DEFB 040h, 0C0h, 046h, 049h, 046h, 009h, 006h, 000h, 0E0h, 010h, 066h, 019h, 0E6h, 009h, 006h, 000h
 DEFB 0F0h, 080h, 0E6h, 019h, 0E6h, 009h, 006h, 000h, 0F0h, 010h, 026h, 049h, 086h, 009h, 006h, 000h
 DEFB 038h, 0C6h, 0C6h, 0F8h, 0C6h, 0C6h, 0F8h, 000h, 000h, 038h, 06Ch, 0C6h, 0C6h, 06Ch, 038h, 000h
 DEFB 000h, 038h, 07Ch, 0FEh, 0FEh, 07Ch, 038h, 000h, 066h, 066h, 03Ch, 018h, 07Eh, 018h, 03Ch, 000h
 DEFB 03Ch, 042h, 0B9h, 0A5h, 0B9h, 0A9h, 066h, 03Ch, 0FBh, 055h, 051h, 051h, 000h, 000h, 000h, 000h
 DEFB 00Ch, 030h, 018h, 03Ch, 066h, 07Eh, 066h, 000h, 00Ch, 030h, 07Eh, 060h, 07Ch, 060h, 07Eh, 000h
 DEFB 00Ch, 030h, 07Eh, 018h, 018h, 018h, 07Eh, 000h, 00Ch, 030h, 03Ch, 066h, 066h, 066h, 03Ch, 000h
 DEFB 00Ch, 030h, 066h, 066h, 066h, 066h, 03Ch, 000h, 018h, 066h, 018h, 03Ch, 066h, 07Eh, 066h, 000h
 DEFB 018h, 066h, 07Eh, 060h, 07Ch, 060h, 07Eh, 000h, 018h, 066h, 07Eh, 018h, 018h, 018h, 07Eh, 000h
 DEFB 018h, 066h, 03Ch, 066h, 066h, 066h, 03Ch, 000h, 018h, 066h, 066h, 066h, 066h, 066h, 03Ch, 000h
 DEFB 030h, 00Ch, 018h, 03Ch, 066h, 07Eh, 066h, 000h, 030h, 00Ch, 07Eh, 060h, 07Ch, 060h, 07Eh, 000h
 DEFB 030h, 00Ch, 07Eh, 018h, 018h, 018h, 07Eh, 000h, 030h, 00Ch, 03Ch, 066h, 066h, 066h, 03Ch, 000h
 DEFB 030h, 00Ch, 066h, 066h, 066h, 066h, 03Ch, 000h, 066h, 000h, 066h, 03Ch, 018h, 018h, 018h, 000h
 DEFB 066h, 000h, 018h, 03Ch, 066h, 07Eh, 066h, 000h, 066h, 000h, 07Eh, 060h, 07Ch, 060h, 07Eh, 000h
 DEFB 066h, 000h, 07Eh, 018h, 018h, 018h, 07Eh, 000h, 066h, 000h, 03Ch, 066h, 066h, 066h, 03Ch, 000h
 DEFB 066h, 000h, 066h, 066h, 066h, 066h, 03Ch, 000h, 03Ch, 066h, 0C0h, 0C0h, 066h, 03Ch, 000h, 018h
 DEFB 03Eh, 078h, 0D8h, 0FEh, 0D8h, 0D8h, 0DEh, 000h, 018h, 000h, 018h, 03Ch, 066h, 07Eh, 066h, 000h
 DEFB 07Ah, 0CCh, 0CEh, 0D6h, 0E6h, 066h, 0BCh, 000h, 032h, 04Ch, 000h, 066h, 076h, 06Eh, 066h, 000h
 DEFB 032h, 04Ch, 000h, 03Ch, 066h, 07Eh, 066h, 000h, 032h, 04Ch, 03Ch, 066h, 066h, 066h, 03Ch, 000h
 DEFB 0C0h, 030h, 00Ch, 030h, 0CCh, 030h, 0C0h, 000h, 006h, 018h, 060h, 018h, 066h, 018h, 006h, 000h
 DEFB 006h, 00Ch, 07Eh, 018h, 07Eh, 030h, 060h, 000h, 000h, 000h, 032h, 04Ch, 000h, 07Eh, 000h, 000h
 DEFB 00Ch, 030h, 078h, 00Ch, 07Ch, 0CCh, 076h, 000h, 00Ch, 030h, 03Ch, 066h, 07Eh, 060h, 03Ch, 000h
 DEFB 00Ch, 030h, 000h, 038h, 018h, 018h, 03Ch, 000h, 00Ch, 030h, 000h, 03Ch, 066h, 066h, 03Ch, 000h
 DEFB 00Ch, 030h, 000h, 066h, 066h, 066h, 03Eh, 000h, 018h, 066h, 078h, 00Ch, 07Ch, 0CCh, 076h, 000h
 DEFB 018h, 066h, 03Ch, 066h, 07Eh, 060h, 03Ch, 000h, 018h, 066h, 000h, 038h, 018h, 018h, 03Ch, 000h
 DEFB 018h, 066h, 000h, 03Ch, 066h, 066h, 03Ch, 000h, 018h, 066h, 000h, 066h, 066h, 066h, 03Ch, 000h
 DEFB 030h, 00Ch, 078h, 00Ch, 07Ch, 0CCh, 076h, 000h, 030h, 00Ch, 03Ch, 066h, 07Eh, 060h, 03Ch, 000h
 DEFB 030h, 00Ch, 000h, 038h, 018h, 018h, 03Ch, 000h, 030h, 00Ch, 000h, 03Ch, 066h, 066h, 03Ch, 000h
 DEFB 030h, 00Ch, 000h, 066h, 066h, 066h, 03Ch, 000h, 066h, 000h, 066h, 066h, 066h, 03Eh, 006h, 07Ch
 DEFB 066h, 000h, 078h, 00Ch, 07Ch, 0CCh, 076h, 000h, 066h, 000h, 03Ch, 066h, 07Eh, 060h, 03Ch, 000h
 DEFB 066h, 000h, 038h, 018h, 018h, 018h, 03Ch, 000h, 066h, 000h, 000h, 03Ch, 066h, 066h, 03Ch, 000h
 DEFB 066h, 000h, 000h, 066h, 066h, 066h, 03Eh, 000h, 000h, 000h, 03Ch, 060h, 060h, 03Ch, 000h, 018h
 DEFB 000h, 000h, 06Ch, 01Ah, 07Eh, 0D8h, 06Eh, 000h, 018h, 000h, 078h, 00Ch, 07Ch, 0CCh, 076h, 000h
 DEFB 000h, 000h, 07Ah, 0CCh, 0D6h, 066h, 0BCh, 000h, 032h, 04Ch, 000h, 0DCh, 066h, 066h, 066h, 000h
 DEFB 032h, 04Ch, 078h, 00Ch, 07Ch, 0CCh, 076h, 000h, 032h, 04Ch, 000h, 03Ch, 066h, 066h, 03Ch, 000h
 DEFB 008h, 00Ch, 0FEh, 007h, 0FEh, 00Ch, 008h, 000h, 010h, 030h, 07Fh, 0E0h, 07Fh, 030h, 010h, 000h
 DEFB 000h, 024h, 07Eh, 0C3h, 07Eh, 024h, 000h, 000h, 000h, 07Eh, 000h, 07Eh, 000h, 07Eh, 000h, 000h
#endasm

