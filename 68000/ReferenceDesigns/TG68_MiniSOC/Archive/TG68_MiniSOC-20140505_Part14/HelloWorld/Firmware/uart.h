#ifndef UART_H
#define UART_H

/* Hardware registers for a supporting UART to the TG68MiniSOC project. */

#define UARTBASE 0xFFFFFFC0
#define HW_UART(x) *(volatile unsigned short *)(UARTBASE+x)

#define REG_UART 0x0
#define REG_UART_RXINT 9
#define REG_UART_TXREADY 8

#ifndef DISABLE_UART_TX
int putchar(int c);
int puts(const char *msg);
#else
#define putchar(x) (x)
#define puts(x)
#endif

#ifndef DISABLE_UART_RX
char getserial();
#else
#define getserial 0
#endif

#endif

