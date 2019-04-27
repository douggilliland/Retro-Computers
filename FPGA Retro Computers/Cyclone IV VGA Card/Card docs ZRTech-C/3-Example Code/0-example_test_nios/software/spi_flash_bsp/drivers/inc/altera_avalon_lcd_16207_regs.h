/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2003 Altera Corporation, San Jose, California, USA.           *
* All rights reserved.                                                        *
*                                                                             *
* Permission is hereby granted, free of charge, to any person obtaining a     *
* copy of this software and associated documentation files (the "Software"),  *
* to deal in the Software without restriction, including without limitation   *
* the rights to use, copy, modify, merge, publish, distribute, sublicense,    *
* and/or sell copies of the Software, and to permit persons to whom the       *
* Software is furnished to do so, subject to the following conditions:        *
*                                                                             *
* The above copyright notice and this permission notice shall be included in  *
* all copies or substantial portions of the Software.                         *
*                                                                             *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     *
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         *
* DEALINGS IN THE SOFTWARE.                                                   *
*                                                                             *
* This agreement shall be governed in all respects by the laws of the State   *
* of California and by the laws of the United States of America.              *
*                                                                             *
******************************************************************************/

#ifndef __ALTERA_AVALON_LCD_16207_REGS_H__
#define __ALTERA_AVALON_LCD_16207_REGS_H__

/*
///////////////////////////////////////////////////////////////////////////
//
// ALTERA_AVALON_LCD_16207 PERIPHERAL
//
// Provides a hardware interface that allows software to 
// access the two (2) internal 8-bit registers in an Optrex 
// model 16207 (or equivalent) character LCD display (the kind
// shipped with the Nios Development Kit, 2 rows x 16 columns).
//
// Because the interface to the LCD module is "not quite Avalon," 
// the hardware in this module ends-up mapping the module's 
// two physical read-write registers into four Avalon-visible
// registers:  Two read-only registers and two write-only registers.
// A picture is worth a thousand words:
//
// THE REGISTER MAP
// 
//              7     6     5     4     3     2     1     0     Offset
//           +-----+-----+-----+-----+-----+-----+-----+-----+
// RS = 0    |         Command Register (WRITE-Only)         |  0
//           +-----+-----+-----+-----+-----+-----+-----+-----+
// RS = 0    |         Status Register  (READ -Only)         |  1
//           +-----+-----+-----+-----+-----+-----+-----+-----+
// RS = 1    |         Data Register    (WRITE-Only)         |  2
//           +-----+-----+-----+-----+-----+-----+-----+-----+
// RS = 1    |         Data Register    (READ -Only)         |  3
//           +-----+-----+-----+-----+-----+-----+-----+-----+
//
///////////////////////////////////////////////////////////////////////////
*/

#include <io.h>

#define IOADDR_ALTERA_AVALON_LCD_16207_COMMAND(base)      __IO_CALC_ADDRESS_NATIVE(base, 0)
#define IOWR_ALTERA_AVALON_LCD_16207_COMMAND(base, data)  IOWR(base, 0, data)

#define IOADDR_ALTERA_AVALON_LCD_16207_STATUS(base)       __IO_CALC_ADDRESS_NATIVE(base, 1)
#define IORD_ALTERA_AVALON_LCD_16207_STATUS(base)         IORD(base, 1)

#define ALTERA_AVALON_LCD_16207_STATUS_BUSY_MSK           (0x00000080u)
#define ALTERA_AVALON_LCD_16207_STATUS_BUSY_OFST          (7)

#define IOADDR_ALTERA_AVALON_LCD_16207_DATA_WR(base)      __IO_CALC_ADDRESS_NATIVE(base, 2)
#define IOWR_ALTERA_AVALON_LCD_16207_DATA(base, data)     IOWR(base, 2, data)

#define IOADDR_ALTERA_AVALON_LCD_16207_DATA_RD(base)      __IO_CALC_ADDRESS_NATIVE(base, 3)
#define IORD_ALTERA_AVALON_LCD_16207_DATA(base)           IORD(base, 3) 

#endif 
