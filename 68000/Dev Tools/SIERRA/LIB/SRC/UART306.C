/*
 * uart306.c
 * Copyright 1994 by Sierra Systems.  All rights reserved.
 *
 * Warning: Do not compile with the -Os4 or -Os5 flag because the assembly
 * language routines called by the functions in this file require arguments
 * to be pushed as short's (2 bytes).
 */

#define BUF_SIZE    100
#define XOFF	    0x13
#define XON	    0x11

typedef struct {
    unsigned int baud_rate;
    char buf[BUF_SIZE];
    char *get;
    char *put;
    unsigned int count;
    char xoff_sent;
    char xoff_rcvd;
} PORT_CONFIG;

PORT_CONFIG _port_a;
PORT_CONFIG _port_b;

void _putch_a(short ch, char *xoff_rcvd);
void _putch_b(short ch, char *xoff_rcvd);
void _reset_a(short enabled);
void _reset_b(short enabled);
void _change_baud_set(short set);
void _change_baud_a(short baud_code);
void _change_baud_b(short baud_code);
void _change_length_parity_stop_a(short len_parity_code, short stop_bits_code);
void _change_length_parity_stop_b(short len_parity_code, short stop_bits_code);

static int get_baud_code(short baud_rate, short set);

static unsigned short current_baud_set12;   /* 0 for neither set selected */

static const unsigned short set1[] =
    {50,110,134,200,300,600,1200,1050,2400,4800,7200,9600,38400};
static const unsigned short set2[] =
    {75,110,134,150,300,600,1200,2000,2400,4800,1800,9600,19200};

/*------------------------------- _setup_port() ------------------------------*/

/*
 * _setup_port
 */

int _setup_port(int port, int baud, int parity, int length, int stop_bits)
{
    int baud_set12;
    int code;
    int other_code;
    int port_a_set;
    int delay;
    PORT_CONFIG *port_cfg;
    PORT_CONFIG *other_port_cfg;
    
    /* check if channel is specified, otherwise debug channel */

    if( port == 'A' ) {
	port_a_set = 1;
	port_cfg = &_port_a;
	other_port_cfg = &_port_b;
    }
    else if( port == 'B' ) {
	port_a_set = 0;
	port_cfg = &_port_b;
	other_port_cfg = &_port_a;
    }
    else
	return(1);

    if( (parity != 'N') && (parity != 'O') && (parity != 'E') )
	return(3);
    if( (length != 6) && (length != 7) && (length != 8) )
	return(4);
    if( (stop_bits != 1) && (stop_bits != 2) )
	return(5);
    if( !(baud_set12 = current_baud_set12) )
	baud_set12 = 1;
    other_code = -1;

    /* verify that a valid baud rate is being requested */

    if( (code = get_baud_code(baud, baud_set12)) == -1 ) {

	/* not found -- try to find a code in the other set */

	baud_set12 = (baud_set12 == 1) ? 2 : 1;
	if( (code = get_baud_code(baud, baud_set12)) == -1 )
	    return(2);

	/* check if new set and the other port was set up */

	if( other_port_cfg->baud_rate ) {

	    /* check if the baud rate available in the new set */

	    if( (other_code =
	    get_baud_code(other_port_cfg->baud_rate, baud_set12)) == -1 )
		return(2);
	}
    }

    /* change the baud rate set if required */

    if( baud_set12 != current_baud_set12 )
	_change_baud_set(current_baud_set12 = baud_set12);

    /* delay */

    for( delay = 0; delay < 1000; delay++ );

    /* set up baud rate */

    if( port_a_set ) {
	_reset_a(1);
	_change_baud_a(code);
	if( other_code != -1 )
	    _change_baud_b(other_code);
    }
    else {
	_reset_b(1);
	_change_baud_b(code);
	if( other_code != -1 )
	    _change_baud_a(other_code);
    }

    /* set up parity and bits per character */

    code = 0;
    if( parity == 'N' )
	code = 0x10;
    else if( parity == 'O' )
	code = 0x04;
    code |= (length - 5);

    if( port_a_set )
	_change_length_parity_stop_a(code, (stop_bits == 1) ? 0x7 : 0xf);
    else
	_change_length_parity_stop_b(code, (stop_bits == 1) ? 0x7 : 0xf);

    port_cfg->baud_rate = baud;
    port_cfg->get = port_cfg->buf;
    port_cfg->put = port_cfg->buf;
    port_cfg->count = 0;
    return(0);
}

/*------------------------------ _close_port() ------------------------------*/

/*
 * _close_port
 */

int _close_port(int port)
{
    if( (port == 'A') && _port_a.baud_rate ) {
	_port_a.baud_rate = 0;
	_reset_a(0);
    }
    else if( (port == 'B') && _port_b.baud_rate) {
	_port_b.baud_rate = 0;
	_reset_b(0);
    }
    else
	return(-1);
    return(0);
}

/*------------------------------ _putch_port() ------------------------------*/

/*
 * _putch_port
 */

int _putch_port(int port, int ch)
{
    if( (port == 'A') && _port_a.baud_rate )
	_putch_a(ch, &_port_a.xoff_rcvd );
    else if( (port == 'B') && _port_b.baud_rate )
	_putch_b(ch, &_port_b.xoff_rcvd );
    else
	return(-1);
    return(0);
}

/*---------------------------- _checkch_port() ------------------------------*/

/*
 * _checkch_port
 */

int _checkch_port(int port)
{
    if( (port == 'A') && _port_a.baud_rate )
	return(_port_a.count);
    else if( (port == 'B') && _port_b.baud_rate )
	return(_port_b.count);
    else
	return(-1);
}

/*------------------------------ _getch_port() ------------------------------*/

int _getch_port(int port)
{
    int c;
    PORT_CONFIG *p;
    char *p_xoff_sent;

    if( (port == 'A') && _port_a.baud_rate )
	p = &_port_a;
    else if( (port == 'B') && _port_b.baud_rate )
	p = &_port_b;
    else
	return(-1);

    /* wait until character available */

    while( p->count == 0 ) {

	/* if xoff was sent before, send xon */

	if( p->xoff_sent ) {
	    if( port == 'A' )
		_putch_a(XON, &p->xoff_rcvd);
	    else
		_putch_b(XON, &p->xoff_rcvd);
	    p->xoff_sent = 0;
	}
    }
    
    /* get a character from the buffer */

    c = *p->get++;
    if( p->get >= (p->buf + BUF_SIZE) )
	p->get = p->buf;
    p->count--;
    return(c);
}

/*------------------------------ get_baud_code() ----------------------------*/

/*
 * get_baud_code
 */

static int get_baud_code(short baud_rate, short set)
{
    int code;
    const unsigned short *p;

    if( set == 1 )
	p = set1;
    else
	p = set2;
    for( code = 0; code < 13; code++ ) {
	if( *p++ == baud_rate )
	    return((code << 4) + code);
    }
    return(-1);
}
