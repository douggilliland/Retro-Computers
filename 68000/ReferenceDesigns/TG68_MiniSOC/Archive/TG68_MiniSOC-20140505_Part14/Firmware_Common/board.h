#ifndef BOARD_H
#define BOARD_H

#define PERIPHERALBASE 0x81000000
#define HW_BOARD(x) *(volatile unsigned short *)(PERIPHERALBASE+x)

/* Misc board features */

#define REG_HEX 0x06

/* Capability registers */

#define REG_CAP_RAMSIZE 0x28
#define REG_CAP_CLOCKSPEED 0x2A
#define REG_CAP_SPISPEED 0x2C

#endif

