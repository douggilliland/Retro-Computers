/*================= parallel receiver test routine =========================*/

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

#define INT short

/*------------------------------- prcvr() -----------------------------------*/

/*
 * prcvr is the parallel download receiver test routine that runs on the
 * 68000 target.  The function has the name prcvr (not ptest) inorder that
 * it can be linked with the same header as the actual parallel receiver.
 * The test program simply sets the state of the BUSY line (ACKNOWLEDGE,
 * pin 11 at the printer port) to the state of the READY line (pin 17 at the
 * printer port).
 *
 * The purpose of this test program is to verify that the correct printer
 * port an ROM socket have been located and the receiver socket address and
 * socket bus width have been set properly.
 *
 * This test program should be started on the 68000 target system and then
 * the parallel downloader (pldr) with the -t flag should be run on the
 * PC/AT.  The ACKNOWLEDGE line should be observed to change each time if
 * everything is working properly.
 *
 * _touch( *arg ) as it is used in this program is not a call to a function.
 * _touch( *arg ) simply tests the memory location pointed to by arg.  See
 * the discussion of _touch() in the Reference Manual under the volatile
 * type specifier.
 */

char *prcvr()
{
    register volatile char *rd_data;
    register volatile char *rd_stat;
    register volatile char *clr_ack;
    register volatile char *set_ack;

    /* initialize pointers */

    /* rd_data = RD_DATA; */
    rd_stat = RD_STAT;
    clr_ack = CLR_ACK;
    set_ack = SET_ACK;

    /* set the ACKNOWLEDGE line to reflect the status of the READY line */

    for( ; ; ) {
	if( *rd_stat & 0x1 )
	    _touch( *set_ack );
	else
	    _touch( *clr_ack );
    }
    /* return( (char *) -1 ); */
}
