/*========================== parallel receiver =============================*/

/*
 * SOCKET_ADDR must be defined to be the address of the ROM socket used to
 * receive the data ... 0xf2000 is assumed if SOCKET_ADDR is not defined
 *
 * WIDTH must be defined to be the width of the ROM socket bus in bits
 * (8, 16 or 32) ... 16 bits is assumed if WIDTH is not defined
 */

#ifndef SOCKET_ADDR
#define SOCKET_ADDR 0xf20000
#endif
#ifndef WIDTH
#define WIDTH		16
#endif
#if WIDTH == 8
#define SHIFT		0
#elif WIDTH == 16
#define SHIFT		1
#elif WIDTH == 32
#define SHIFT		2
#else
#error "WIDTH", the width of the bus was not set to 8, 16 or 32
#define SHIFT		0
#endif

#define RD_DATA	    (char*)(SOCKET_ADDR + (0 << SHIFT))
#define RD_STAT	    (char*)(SOCKET_ADDR + (1 << SHIFT))
#define CLR_ACK	    (char*)(SOCKET_ADDR + (2 << SHIFT))
#define SET_ACK	    (char*)(SOCKET_ADDR + (3 << SHIFT))

#define HDRSIZ	17
#define INT short

unsigned char rdblock();

/*------------------------------- prcvr() -----------------------------------*/

/*
 * prcvr is the parallel download receiver that runs on the 68000 target ...
 * a pointer to loaded program's execution entry point is returned if the
 * loaded program is to start automatically after being loaded ... a -1 is
 * retured when the program is not to be started automatically
 */

char *prcvr()
{
    register unsigned char chksum;
    INT ack;
    unsigned char c;

    long hdr_buf[HDRSIZ / sizeof(long) + 1];	/* not all longs */

    /* set the ACK line (BUSY) back to the PC_AT HIGH */

    init_rcvr();
    ack = 0;

    /* look for a string of 0x55's */

    while( rdblock(&ack, &c, 1) != 0x55 );
    while( rdblock(&ack, &c, 1) == 0x55 );

    /* synchronization failure */

    if( c != 0xaa )
	return((char*) -1);

    for( ; ; ) {

	/* get file header ... not portable do to byte ordering */

	chksum = rdblock(&ack, hdr_buf, HDRSIZ);

	/* verify the header checksum */

	if( rdblock(&ack, &c, 1) != chksum )
	    return((char*) -1);

	if( hdr_buf[1] ) {

	    /* normal section ... get data */

	    chksum = rdblock(&ack, hdr_buf[0], hdr_buf[1]);

	    /* verify data checksum */

	    if( rdblock(&ack, &c,1) != chksum )
		return((char*) -1);
	}

	/* last section */

	else {
	    if( hdr_buf[2] & 0x1000000 )
		return((char *) hdr_buf[0]);	/* return starting address  */
	    else
		return ((char *) -1);		/* return -1,  no autostart */
	}
    }
}

/*------------------------------- rdblock() ----------------------------------*/

/*
 * rdblock reads a block of data sent to the 68000 and places it into the
 * 68000 memory starting at the address specified by ptr
 */

#define clr_ack (set_ack - 2)	/* saves a register */

unsigned char rdblock(ack, ptr, length)
INT *ack;
register char *ptr;
register unsigned long length;
{
    register char rbyte;
    register char chksum;
    register INT acknowledge;
    register volatile char *rd_data;
    register volatile char *rd_stat;
    /* register volatile char *clr_ack; */
    register volatile char *set_ack;

    /* initialize pointers */

    rd_data = RD_DATA;
    rd_stat = RD_STAT;
    /* clr_ack = CLR_ACK; */
    set_ack = SET_ACK;

    acknowledge = *ack;
    chksum = 0;

    /* for each received byte */

    while( --length != -1 ) {
	if( acknowledge ) {
	    while( *rd_stat & 0x1 );
	    rbyte = *rd_data;
	    acknowledge = 0;
	    _touch(*clr_ack);
	} 
	else {
	    while( !(*rd_stat & 0x1) );
	    rbyte = *rd_data;
	    acknowledge = 1;
	    _touch(*set_ack);
	}

	/* update check-sum and place data into memory */

	chksum += rbyte;
	*ptr++ = rbyte;
    }
    *ack = acknowledge;
    return(chksum);
}

/*-------------------------------- init_rcvr() -------------------------------*/

/*
 * init_rcvr initializes the receiver by set the ACKNOWLEDGE line back to the
 * PC_AT to the HIGH state  ... do not return until a response from the
 * transmitter	has been confirmed
 */

init_rcvr()
{
    volatile char *set_ack;
    volatile char *rd_stat;
    volatile char *rd_data;

    INT count;

    rd_stat = RD_STAT;
    rd_data = RD_DATA;
    set_ack = SET_ACK;

timed_out:
    count = 0;
    do {
	_touch(*set_ack);
    } while( !(*rd_stat & 0x1) && (*rd_data != 0xaa) );
    while( (*rd_stat & 0x1) || (*rd_data != 0x55) )
	if( count++ > 0x1000 )
	    goto timed_out;
    _touch(*clr_ack);
}
