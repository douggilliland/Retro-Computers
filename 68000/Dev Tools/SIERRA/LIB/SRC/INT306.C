/*
 * int306.c
 * Copyright 1994 by Sierra Systems.  All rights reserved.
 *
 * Warning: Do not compile with the -Os4 or -Os5 flag because the assembly
 * language routines called by the functions in this file require arguments
 * to be pushed as short's (2 bytes).
 */

#define BUF_SIZE 100

#define XOFF	0x13
#define XON	0x11

typedef struct {
    unsigned int baud_rate;
    char buf[BUF_SIZE];
    char *get;
    char *put;
    unsigned int count;
    char xoff_sent;
    char xoff_rcvd;
} PORT_CONFIG;

void _putch_a(short ch, char *xoff_rcvd);
void _putch_b(short ch, char *xoff_rcvd);

extern PORT_CONFIG _port_a;
extern PORT_CONFIG _port_b;

/*------------------------------ _put_in_buf() -----------------------------*/

/*
 * _put_in_buf puts a character in the specified channel buffer
 *
 * called from duart_int interrupt handler routine in file int306a.s
 */

void _put_in_buf(short ch, short channel_b)
{
    PORT_CONFIG *p;

    p = channel_b ? &_port_b : &_port_a;

    /* XOFF received don't send any more characters until XON is received */

    if( ch == XOFF ) {
	p->xoff_rcvd = 1;
	return;
    }

    else if( ch == XON ) {
	p->xoff_rcvd = 0;
	return;
    }

    /* buffer almost full send xoff */

    if( p->count >= (BUF_SIZE * 2 / 3) ) {
	if( channel_b )
	    _putch_b(XOFF, &p->xoff_rcvd);
	else
	    _putch_a(XOFF, &p->xoff_rcvd);
	p->xoff_sent = 1;
	if( p->count >= BUF_SIZE )
	    return;
    }

    /* put the character received in the buffer */

    *p->put++ = ch;
    if( p->put >= (p->buf + BUF_SIZE) )
	p->put = p->buf;
    p->count++;
}
