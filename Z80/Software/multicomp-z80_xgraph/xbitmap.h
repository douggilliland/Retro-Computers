/* ////////////////////////////////////////////////////////////////////
//       xbitmap.h
//
//  Graphic functions for the Multicomp Z80.
//
//  Get/Put Bitmaps.
//  ================
//
//  Copyright (c) 2019 Kurt Mueller / written for Multicomp Z80
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
//  31 Jan 2019 : V1.00 : 1st Version for Multicomp-Graphic
//
//  Notes:
//  ======
//  The char-cells are organized in screen memory with an interleave
//  of 8 bytelike this (the example uses 6 byte):
//
//  Fig. 1:
//
//  <------------------------ R  o  w ----------------------------->
//  byte(0,1), byte(0,2), byte(0,3), byte(0,4), byte(0,5), byte(0,6),...
//  byte(1,1), byte(1,2), byte(1,3), byte(1,4), byte(1,5), byte(1,6),...
//  byte(2,1), byte(2,2), byte(2,3), byte(2,4), byte(2,5), byte(2,6),...
//
//  each line represents a vertical char-cell on screen like this:
//
//  Fig. 2:
//
//  byte(0,1), byte(1,1), byte(2,1)  ^  \
//  byte(0,2), byte(1,2), byte(2,2)  R   |
//  byte(0,3), byte(1,3), byte(2,3)  o   |
//  byte(0,4), byte(1,4), byte(2,4)  w   | with interleave = 8
//  byte(0,5), byte(1,5), byte(2,5)  :   |
//  byte(0,6), byte(1,6), byte(2,6)  v  /
//  ........., ...
//
//  If the bitmap is written to memory, this is converted to a
//  linear structure of like shown in Fig. 3:
//
//  Fig. 3:
//
//  byte(0,1), byte(1,1), byte(2,1); byte(0,2), byte(1,2), byte(2,2); ...
//
//  The reverse procedure is done when copied from memory to screen (Fig.1)
//
//  The bitmaps are drawn in a row,col position (not x,y), and their
//  size is specified in rows and columns (not pixel).
//
//  As a row is 8 pixel in hight and a column is 8 pixels in
//  width, the bitmap width and hight in pixel must to be an 8th
//  multiply: 8, 16, 24, 32, etc. In other words, you have to specify
//  bitmap dimension like this: Bitmap(row,col,width,hight). The origin
//  is in the upper left corner, expanding the screen downwards.
//
//  Needs the xgraph.h library.
///////////////////////////////////////////////////////////////////// */

/* Read out Bitmap from Screen to Memory
// --------------------------------------
// Error: width    = 0 -> -1; > 79 -> -3
//        hight    = 0 -< -2; > 29 -> -4
//        addr     = no checks !
//        row, col = no checks !
*/
GetBmpRC(row, col, width, hight, addr)
int row, col, width, hight;
BYTE *addr;
{
    x_func = X_GetBmpRC;

    x_par[0] = row;
    x_par[1] = col;
    x_par[2] = width;
    x_par[3] = hight;
    x_par[4] = addr;

    return x_call();
}

/* Write Bitmap from Memory to Screen
// -----------------------------------
// Error: width    = 0 -> -1; > 79 -> -3
//        hight    = 0 -< -2; > 29 -> -4
//        addr     = no checks !
//        row, col = no checks !
*/
PutBmpRC(row, col, width, hight, addr)
int row, col, width, hight;
BYTE *addr;
{
    x_func = X_PutBmpRC;

    x_par[0] = row;
    x_par[1] = col;
    x_par[2] = width;
    x_par[3] = hight;
    x_par[4] = addr;

    return x_call();
}

/* Write Bitmap from Memory to Screen
/ with aspect-ratio correction
// -----------------------------------
// Error: width    = 0 -> -1; > 79 -> -3
//        hight    = 0 -< -2; > 29 -> -4
//        addr     = no checks !
//        row, col = no checks !
*/
WriteBmpRC(row, col, width, hight, addr)
int row, col, width, hight;
BYTE *addr;
{
    x_func = X_WriteBmpRC;

    x_par[0] = row;
    x_par[1] = col;
    x_par[2] = width;
    x_par[3] = hight;
    x_par[4] = addr;

    return x_call();
}
