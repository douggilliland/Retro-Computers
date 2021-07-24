#ifndef _COMMFUNC
#define _COMMFUNC

void uart_init (void);
int uart_test (void);
void uart_put (unsigned char d);
unsigned char uart_get (void);

#endif

