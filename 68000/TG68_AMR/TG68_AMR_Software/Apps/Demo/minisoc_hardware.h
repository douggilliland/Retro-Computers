#ifndef MINISOC_HARDWARE_H
#define MINISOC_HARDWARE_H

#define VGABASE 0x80000000

#define FRAMEBUFFERPTR 0

#define SP0PTR 0x100
#define SP0XPOS 0x104
#define SP0YPOS 0x106


#define VGACHARBUFFERBASE 0x80000800
extern char *VGACharBuffer;


#define PERIPHERALBASE 0x81000000
#define HW_PER(x) *(volatile unsigned short *)(PERIPHERALBASE+x)
#define HW_PER_L(x) *(volatile unsigned long *)(PERIPHERALBASE+x)



#define PER_UART 0
#define PER_UART_CLKDIV 2

#define PER_FLAGS 4  /* Currently only contains ROM overlay */
#define PER_HEX 6

#define PER_PS2_KEYBOARD 8
#define PER_PS2_MOUSE 0xA

#define PER_PS2_RECV 11
#define PER_PS2_CTS 10

/* Timers */

#define PER_TIMER_CONTROL 0xE

/* Control bits */
#define PER_TIMER_TR5 5
#define PER_TIMER_TR4 4
#define PER_TIMER_TR3 3
#define PER_TIMER_TR2 2
#define PER_TIMER_TR1 1

#define PER_TIMER_EN5 13
#define PER_TIMER_EN4 12
#define PER_TIMER_EN3 11
#define PER_TIMER_EN2 10
#define PER_TIMER_EN1 9

/* Divisor registers */
#define PER_TIMER_DIV0 0x10
#define PER_TIMER_DIV1 0x12
#define PER_TIMER_DIV2 0x14
#define PER_TIMER_DIV3 0x16
#define PER_TIMER_DIV4 0x18
#define PER_TIMER_DIV5 0x1A
#define PER_TIMER_DIV6 0x1C
#define PER_TIMER_DIV7 0x1E	/* SPI speed */

/* SPI register */
#define PER_SPI 0x20
#define PER_SPI_CS 0x22	/* CS bits are write-only, but bit 15 reads as the SPI busy signal */
#define PER_SPI_BLOCKING 0x24
#define PER_SPI_PUMP 0x100 /* Pump registers allow speedy throughput with a construct like "movem.l (a0)+,d0-d4" */

#define PER_SPI_BUSY 15

/* Capability registers */

#define PER_CAP_RAMSIZE 0x28
#define PER_CAP_CLOCKSPEED 0x2A
#define PER_CAP_SPISPEED 0x2C

/* Interrupts */

#define PER_INT_UART 2
#define PER_INT_TIMER 3
#define PER_INT_PS2 4


void SetSprite();

#endif

