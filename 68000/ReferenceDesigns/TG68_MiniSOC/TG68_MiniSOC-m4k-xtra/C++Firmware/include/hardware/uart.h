#ifndef UART_H
#define UART_H

#include "minisoc_hardware.h"

#define PER_UART 0

// Bit definitions for reads from PER_UART
#define PER_UART_TXINT	10
#define PER_UART_RXINT	9
#define PER_UART_TXREADY 8


// System clock/baud rate
#define PER_UART_CLKDIV 2

#endif

