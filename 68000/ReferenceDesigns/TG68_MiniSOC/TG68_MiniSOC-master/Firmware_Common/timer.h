#ifndef TIMER_H
#define TIMER_H

#define TIMERBASE 0x81000000
#define HW_TIMER(x) *(volatile unsigned short *)(TIMERBASE+x)


/* Timers */

#define REG_TIMER_CONTROL 0xE

/* Control bits */
#define BIT_TIMER_TR6 6
#define BIT_TIMER_TR5 5
#define BIT_TIMER_TR4 4
#define BIT_TIMER_TR3 3
#define BIT_TIMER_TR2 2
#define BIT_TIMER_TR1 1

#define BIT_TIMER_EN6 14
#define BIT_TIMER_EN5 13
#define BIT_TIMER_EN4 12
#define BIT_TIMER_EN3 11
#define BIT_TIMER_EN2 10
#define BIT_TIMER_EN1 9

/* Divisor registers */
#define REG_TIMER_DIV0 0x10
#define REG_TIMER_DIV1 0x12
#define REG_TIMER_DIV2 0x14
#define REG_TIMER_DIV3 0x16
#define REG_TIMER_DIV4 0x18
#define REG_TIMER_DIV5 0x1A
#define REG_TIMER_DIV6 0x1C
#define REG_TIMER_DIV7 0x1E	/* SPI speed */


/* Interrupts */

#define TIMER_INT 3


#endif

