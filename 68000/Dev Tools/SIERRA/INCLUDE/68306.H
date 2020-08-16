/*--------------------------------- 68306.h ---------------------------------*/

/*
 * Copyright 1994 by Sierra Systems.  All rights reserved.
 */

int _setup_port(int port, int baud, int parity, int length, int stop_bits);
int _close_port(int port);
int _putch_port(int port, int ch);
int _checkch_port(int port);
int _getch_port(int port);
void _start_timer(void);
unsigned long _stop_timer(int resolution);

