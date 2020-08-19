/*		     Receiver for S Records and $ Records		     */

/*		      Copyright 1987 by Sierra Systems			     */
/*			    All rights reserved				     */

/*
 * This receiver accepts both Motorola S Records and Sierra Systems $ Records.
 * Sierra Systems $ Records convey the same information as Motorola S Records.
 * The information in Sierra Systems $ Records is packed much tighter than the
 * information in Mororola S Records.  Sierra Systems $ Records pack 4 bytes
 * of binary data into 5 bytes of ascii data while Motorola S Records pack
 * 1 byte of binary into 2 bytes of ascii.  At 9600 Baud $ Records tranfer at
 * about 500 bytes per second while S Records transfer at only about 300 bytes
 * per second.
 *
 * The receiver for the serial loader running on the VAX prompts the user
 * to enter the commmand to start the loader. The PC_AT loader initiates the
 * receiver and then transmits the records, a prompt would get in the way.
 *
 * The input stream is scanned until either an 'S' or a '$' is found. If
 * an 'S' is found, the S-record function is called to take in the data.
 * Control is maintained by the function until the end of the input stream
 * is found or an unexpected character is found. In the case of an unexpected
 * character, control is passed back to calling function, which continues
 * the scans for the 'S' or '$'. If the S-record function returns because the
 * end of file is found, the calling function reports the entry address of the
 * loaded program and exits.
 * If a '$' is found, the dollar record function is called and behaves in
 * a similar fashion.
 *
 * The receiver can be configured to handle either $ records or S records or
 * both at the same time.
 * Compiler with S_RECORD defined to build S record receiver
 * Compiler with D_RECORD defined to build $ record receiver
 * Compiler with both D_RECORD and S_RECORD defined to be a receiver for both
 * After an error type control-e to see the error message again and exit the
 * program.  Note, the program exits after the first error because data is
 * lost and while the message is being printed.
 *
 * The receiver echoes the received data when the program is started at its
 * load address + 4.  At least 1 NULL character must be inserted at the end
 * of every record when the receiver is run in echo mode.
 *
 * NOTE: The program must be linked with its own run-time header - not the
 * standard C run-time header
 */

#ifdef XS_RECORD
#define S_RECORD 1
#endif
#ifdef XD_RECORD
#define D_RECORD 1
#endif

/* printable ASCII base and range in hex */

#define A_BASE	    0x28
#define A_RANGE	0x55

#define MAX_CHAR    128

#ifdef M68000
#define INT short
#else
#define INT int
#endif

#define RNG	    A_RANGE
#define BAS	    A_BASE

#ifdef S_RECORD
static const INT hex_val[] =
    {0,1,2,3,4,5,6,7,8,9,0,0,0,0,0,0,0,10,11,12,13,14,15};
#endif

static const char hex_char[] = 
    {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f' };

#ifdef D_RECORD
static const unsigned char map_base[][4] = {
    {	0*RNG-BAS,  0*RNG-BAS,	0*RNG-BAS,  0*RNG-BAS	},
    {	0*RNG-BAS,  0*RNG-BAS,	0*RNG-BAS,  1*RNG-BAS	},
    {	0*RNG-BAS,  0*RNG-BAS,	0*RNG-BAS,  2*RNG-BAS	},
    {	0*RNG-BAS,  0*RNG-BAS,	1*RNG-BAS,  0*RNG-BAS	},
    {	0*RNG-BAS,  0*RNG-BAS,	1*RNG-BAS,  1*RNG-BAS	},
    {	0*RNG-BAS,  0*RNG-BAS,	1*RNG-BAS,  2*RNG-BAS	},
    {	0*RNG-BAS,  0*RNG-BAS,	2*RNG-BAS,  0*RNG-BAS	},
    {	0*RNG-BAS,  0*RNG-BAS,	2*RNG-BAS,  1*RNG-BAS	},
    {	0*RNG-BAS,  0*RNG-BAS,	2*RNG-BAS,  2*RNG-BAS	},
    {	0*RNG-BAS,  1*RNG-BAS,	0*RNG-BAS,  0*RNG-BAS	},
    {	0*RNG-BAS,  1*RNG-BAS,	0*RNG-BAS,  1*RNG-BAS	},
    {	0*RNG-BAS,  1*RNG-BAS,	0*RNG-BAS,  2*RNG-BAS	},
    {	0*RNG-BAS,  1*RNG-BAS,	1*RNG-BAS,  0*RNG-BAS	},
    {	0*RNG-BAS,  1*RNG-BAS,	1*RNG-BAS,  1*RNG-BAS	},
    {	0*RNG-BAS,  1*RNG-BAS,	1*RNG-BAS,  2*RNG-BAS	},
    {	0*RNG-BAS,  1*RNG-BAS,	2*RNG-BAS,  0*RNG-BAS	},
    {	0*RNG-BAS,  1*RNG-BAS,	2*RNG-BAS,  1*RNG-BAS	},
    {	0*RNG-BAS,  1*RNG-BAS,	2*RNG-BAS,  2*RNG-BAS	},
    {	0*RNG-BAS,  2*RNG-BAS,	0*RNG-BAS,  0*RNG-BAS	},
    {	0*RNG-BAS,  2*RNG-BAS,	0*RNG-BAS,  1*RNG-BAS	},
    {	0*RNG-BAS,  2*RNG-BAS,	0*RNG-BAS,  2*RNG-BAS	},
    {	0*RNG-BAS,  2*RNG-BAS,	1*RNG-BAS,  0*RNG-BAS	},
    {	0*RNG-BAS,  2*RNG-BAS,	1*RNG-BAS,  1*RNG-BAS	},
    {	0*RNG-BAS,  2*RNG-BAS,	1*RNG-BAS,  2*RNG-BAS	},
    {	0*RNG-BAS,  2*RNG-BAS,	2*RNG-BAS,  0*RNG-BAS	},
    {	0*RNG-BAS,  2*RNG-BAS,	2*RNG-BAS,  1*RNG-BAS	},
    {	0*RNG-BAS,  2*RNG-BAS,	2*RNG-BAS,  2*RNG-BAS	},
    {	1*RNG-BAS,  0*RNG-BAS,	0*RNG-BAS,  0*RNG-BAS	},
    {	1*RNG-BAS,  0*RNG-BAS,	0*RNG-BAS,  1*RNG-BAS	},
    {	1*RNG-BAS,  0*RNG-BAS,	0*RNG-BAS,  2*RNG-BAS	},
    {	1*RNG-BAS,  0*RNG-BAS,	1*RNG-BAS,  0*RNG-BAS	},
    {	1*RNG-BAS,  0*RNG-BAS,	1*RNG-BAS,  1*RNG-BAS	},
    {	1*RNG-BAS,  0*RNG-BAS,	1*RNG-BAS,  2*RNG-BAS	},
    {	1*RNG-BAS,  0*RNG-BAS,	2*RNG-BAS,  0*RNG-BAS	},
    {	1*RNG-BAS,  0*RNG-BAS,	2*RNG-BAS,  1*RNG-BAS	},
    {	1*RNG-BAS,  0*RNG-BAS,	2*RNG-BAS,  2*RNG-BAS	},
    {	1*RNG-BAS,  1*RNG-BAS,	0*RNG-BAS,  0*RNG-BAS	},
    {	1*RNG-BAS,  1*RNG-BAS,	0*RNG-BAS,  1*RNG-BAS	},
    {	1*RNG-BAS,  1*RNG-BAS,	0*RNG-BAS,  2*RNG-BAS	},
    {	1*RNG-BAS,  1*RNG-BAS,	1*RNG-BAS,  0*RNG-BAS	},
    {	1*RNG-BAS,  1*RNG-BAS,	1*RNG-BAS,  1*RNG-BAS	},
    {	1*RNG-BAS,  1*RNG-BAS,	1*RNG-BAS,  2*RNG-BAS	},
    {	1*RNG-BAS,  1*RNG-BAS,	2*RNG-BAS,  0*RNG-BAS	},
    {	1*RNG-BAS,  1*RNG-BAS,	2*RNG-BAS,  1*RNG-BAS	},
    {	1*RNG-BAS,  1*RNG-BAS,	2*RNG-BAS,  2*RNG-BAS	},
    {	1*RNG-BAS,  2*RNG-BAS,	0*RNG-BAS,  0*RNG-BAS	},
    {	1*RNG-BAS,  2*RNG-BAS,	0*RNG-BAS,  1*RNG-BAS	},
    {	1*RNG-BAS,  2*RNG-BAS,	0*RNG-BAS,  2*RNG-BAS	},
    {	1*RNG-BAS,  2*RNG-BAS,	1*RNG-BAS,  0*RNG-BAS	},
    {	1*RNG-BAS,  2*RNG-BAS,	1*RNG-BAS,  1*RNG-BAS	},
    {	1*RNG-BAS,  2*RNG-BAS,	1*RNG-BAS,  2*RNG-BAS	},
    {	1*RNG-BAS,  2*RNG-BAS,	2*RNG-BAS,  0*RNG-BAS	},
    {	1*RNG-BAS,  2*RNG-BAS,	2*RNG-BAS,  1*RNG-BAS	},
    {	1*RNG-BAS,  2*RNG-BAS,	2*RNG-BAS,  2*RNG-BAS	},
    {	2*RNG-BAS,  0*RNG-BAS,	0*RNG-BAS,  0*RNG-BAS	},
    {	2*RNG-BAS,  0*RNG-BAS,	0*RNG-BAS,  1*RNG-BAS	},
    {	2*RNG-BAS,  0*RNG-BAS,	0*RNG-BAS,  2*RNG-BAS	},
    {	2*RNG-BAS,  0*RNG-BAS,	1*RNG-BAS,  0*RNG-BAS	},
    {	2*RNG-BAS,  0*RNG-BAS,	1*RNG-BAS,  1*RNG-BAS	},
    {	2*RNG-BAS,  0*RNG-BAS,	1*RNG-BAS,  2*RNG-BAS	},
    {	2*RNG-BAS,  0*RNG-BAS,	2*RNG-BAS,  0*RNG-BAS	},
    {	2*RNG-BAS,  0*RNG-BAS,	2*RNG-BAS,  1*RNG-BAS	},
    {	2*RNG-BAS,  0*RNG-BAS,	2*RNG-BAS,  2*RNG-BAS	},
    {	2*RNG-BAS,  1*RNG-BAS,	0*RNG-BAS,  0*RNG-BAS	},
    {	2*RNG-BAS,  1*RNG-BAS,	0*RNG-BAS,  1*RNG-BAS	},
    {	2*RNG-BAS,  1*RNG-BAS,	0*RNG-BAS,  2*RNG-BAS	},
    {	2*RNG-BAS,  1*RNG-BAS,	1*RNG-BAS,  0*RNG-BAS	},
    {	2*RNG-BAS,  1*RNG-BAS,	1*RNG-BAS,  1*RNG-BAS	},
    {	2*RNG-BAS,  1*RNG-BAS,	1*RNG-BAS,  2*RNG-BAS	},
    {	2*RNG-BAS,  1*RNG-BAS,	2*RNG-BAS,  0*RNG-BAS	},
    {	2*RNG-BAS,  1*RNG-BAS,	2*RNG-BAS,  1*RNG-BAS	},
    {	2*RNG-BAS,  1*RNG-BAS,	2*RNG-BAS,  2*RNG-BAS	},
    {	2*RNG-BAS,  2*RNG-BAS,	0*RNG-BAS,  0*RNG-BAS	},
    {	2*RNG-BAS,  2*RNG-BAS,	0*RNG-BAS,  1*RNG-BAS	},
    {	2*RNG-BAS,  2*RNG-BAS,	0*RNG-BAS,  2*RNG-BAS	},
    {	2*RNG-BAS,  2*RNG-BAS,	1*RNG-BAS,  0*RNG-BAS	},
    {	2*RNG-BAS,  2*RNG-BAS,	1*RNG-BAS,  1*RNG-BAS	},
    {	2*RNG-BAS,  2*RNG-BAS,	1*RNG-BAS,  2*RNG-BAS	},
    {	2*RNG-BAS,  2*RNG-BAS,	2*RNG-BAS,  0*RNG-BAS	},
    {	2*RNG-BAS,  2*RNG-BAS,	2*RNG-BAS,  1*RNG-BAS	},
    {	2*RNG-BAS,  2*RNG-BAS,	2*RNG-BAS,  2*RNG-BAS	},
    };
#endif

INT echo;
INT error_detected;
INT chksum;
unsigned INT type;
unsigned INT record_count;
char *p2hold_buf;
char *hold_buf_end;
char hold_buf[9];
char i2hex_buf[12];
char line_buf[MAX_CHAR];

#define NO_ERROR	0
#define CHKSUM_ERROR	1
#define PREFIX_ERROR	2
#define S5_ERROR	3

INT getc();
char *i2hex();
#ifdef S_RECORD
long s_record();
INT get_byte();
INT read_data();
#endif
#ifdef D_RECORD
long d_record();
INT read_d_data();
INT get_d_byte();
char *unmap_d_rec();
#endif

/*-------------------------------- srcvr() ----------------------------------*/

srcvr(echo_it)
INT echo_it;
{
    long entry_address;
    INT inchar;

    /* send prompt to signal user to start the loader on the host */

#ifndef PC_AT
    prompt_user();
#endif

    i2hex_buf[11] = '\0';
    error_detected = 0;
    echo = echo_it;
    for( ; ; ) {
	inchar = getc();
	switch(inchar) {
#ifdef S_RECORD
	case 'S':   
	    entry_address = s_record();
	    goto xit;
#endif
#ifdef D_RECORD
	case '$':   
	    p2hold_buf = hold_buf_end;
	    entry_address = d_record();
#endif
	xit:
	    if( error_detected ) {
		for( inchar = 999; ; inchar = getchx() ) {
		    if( (inchar == 5) || (inchar == 999) ) {
			switch( error_detected ) {
			case CHKSUM_ERROR:
			    putchx('S');
			    putstx(i2hex((long)type,2));
			    putstx(" checksum error: 0x");
			    putstx(i2hex((long)((chksum - 1) & 0xff),2));
			    putstx(" at record 0x");
			    putstx(i2hex((long)record_count,2));
			    break;
			case PREFIX_ERROR:
			    putstx("Invalid S record prefix at record 0x");
			    putstx(i2hex((long)record_count,2));
			    break;
#ifdef S_RECORD
			case S5_ERROR:
			    putstx("S5 record error: 0x");
			    putstx(i2hex((long)type,2));
			    putstx(" records sent, 0x");
			    putstx(i2hex((long)record_count,2));
			    putstx(" records received");
#endif
			}
			putstx("\r\n");
			if( inchar == 5 )
			    return;
		    }
		    else
			putstx("download error: press control-E to exit\r\n");
		}
	    }
	    putstx("Entry point: 0x");
	    putstx(i2hex(entry_address,sizeof(long)));
	    putstx("\r\n");
	    return;
	default:
	    while( getc() != '\n' );	/* throw away rest of the line */
	}
    }
}

#ifndef PC_AT
/*----------------------------- prompt_user() --------------------------------*/

/*
 * prompt_user prompts the user for the command to be sent to the host computer
 * to initialize that transfer on the host computer
 */

prompt_user()
{
    register char *ptr;
    register INT inchar;

    putstx("LOAD COMMAND> ");
    ptr = line_buf;
    for( ; ; ) {
	inchar = getchx();
	if( (inchar == '\r') || (inchar == '\n') ) {
	    putstx("\r\n");
	    *ptr++ = '\r';
	    *ptr = '\0';
	    ptr = line_buf;
	    while( *ptr )
		putchx1(*ptr++);
	    break;
	}
	if( inchar == '\b' ) {
	    if( ptr != line_buf ) {
		putstx("\b \b");
		ptr--;
	    }
	    continue;
	}
	if( ptr == &line_buf[MAX_CHAR - 3] )
	    continue;
	*ptr++ = inchar;
	putchx(inchar);
    }
}
#endif

#ifdef S_RECORD
/*------------------------------ s_record() ---------------------------------*/

/*
 * s_record reads and decodes S records
 */

long s_record()
{
    register char *ptr;
    long load_addr;
    INT fld_width;
    INT inchar;
    INT n_bytes;
    INT chk_sum;
    INT i;

    for( ; ; ) {
	inchar = getc();
	++record_count;
	switch(inchar) {
	case '0':
	    record_count = 0;
	    chk_sum = get_byte();
	    n_bytes = chk_sum - 3;  /* adj count for addr and checksum fields */
	    chk_sum += get_byte();
	    chk_sum += get_byte();
	    chk_sum += read_data(line_buf, n_bytes);
	    line_buf[n_bytes] = '\0';
	    chk_sum += get_byte() + 1; 
	    if( chk_sum & 0xff ) {
		error_detected = CHKSUM_ERROR;
		chksum = chk_sum;
		type = 0;
		return;
	    }
	    while( getc() != '\n' );
	    break;
	case '1':
	case '2':
	case '3':
	    fld_width = inchar - '0' + 1;
	    n_bytes = get_byte();
	    chk_sum = n_bytes;
	    load_addr = 0;
	    i = sizeof(long) - fld_width;
	    ptr = (char*)&load_addr + i;
	    while( ++i <= sizeof(long) ) {
		*ptr = get_byte();
		chk_sum += *ptr++;
	    }
	    n_bytes -= fld_width + 1;	/* adj count for addr and checksum */
	    chk_sum += read_data((char *)load_addr, n_bytes);
	    chk_sum += get_byte() + 1; 
	    if( chk_sum & 0xff ) {
		error_detected = CHKSUM_ERROR;
		chksum = chk_sum;
		type = fld_width - 1;
		return;
	    }
	    while( getc() != '\n' );
	    break;
	case '5':
	    /* fld_width = 2; */
	    n_bytes = get_byte();
	    chk_sum = n_bytes;
	    load_addr = 0;
	    ptr = (char*)&load_addr + 2;
	    for( i = 2; i; i-- ) {
		*ptr = get_byte();
		chk_sum += *ptr++;
	    }
	    chk_sum += get_byte() + 1; 
	    if( chk_sum & 0xff ) {
		error_detected = CHKSUM_ERROR;
		chksum = chk_sum;
		type = 5;
		return;
	    }
	    if( load_addr != record_count ) {
		type = load_addr;
		error_detected = S5_ERROR;
		return(0);
	    }
	    while( getc() != '\n' );
	    break;
	case '7':
	case '8':
	case '9':
	    fld_width = 11 - (inchar - '0');
	    n_bytes = get_byte();
	    chk_sum = n_bytes;
	    i = sizeof(long) - fld_width;
	    load_addr = 0;
	    ptr = (char*)&load_addr + i;
	    while( ++i <= sizeof(long) ) {
		*ptr = get_byte();
		chk_sum += *ptr++;
	    }
	    n_bytes -= fld_width + 1;	/* adj count for addr and checksum */
	    if( n_bytes > 0 ) 
		chk_sum += read_data(line_buf, n_bytes);
	    chk_sum += get_byte() + 1; 
	    if( chk_sum & 0xff ) {
		error_detected = CHKSUM_ERROR;
		chksum = chk_sum;
		type = 11 - fld_width;
		return;
	    }
	    while( getc() != '\n' );
	    return(load_addr);	    /* return starting address */
	default:
	    goto error;
	}
	inchar = getc();
	if( inchar != 'S' ) {
	error:
	    error_detected = PREFIX_ERROR;
	    return(0);
	}
    }
}

/*----------------------------- read_data() ---------------------------------*/

/*
 * read_data reads the characters from the record and stores values at
 * location ptr
 */

INT read_data(ptr,count)
char *ptr;
INT count;
{
    INT sum;

    sum = 0;
    while( -- count >= 0 ) {
	*ptr = get_byte();
	sum += *ptr++;
    }
    return(sum);
}

/*------------------------------- get_byte() --------------------------------*/

/*
 * get_byte reads 2 hexadecimal characters and converts them into a byte 
 */
 
INT get_byte()
{
    INT c;
    INT inchar;

    inchar = getc();
    c = hex_val[inchar - '0'] << 4;
    inchar = getc();
    c += hex_val[inchar - '0'];
    return (c);
} 
#endif

#ifdef D_RECORD
/*------------------------------ d_record() ---------------------------------*/

/*
 * d_record reads and decodes $ records
*/

long d_record()
{
    register char *ptr;
    long load_addr;
    INT fld_width;
    INT inchar;
    INT n_bytes;
    INT chk_sum;
    INT i;

    for( ; ; ) {
	++record_count;
	switch( inchar = get_d_byte() ) {
	case 0:
	    record_count = 0;
	    chk_sum = get_d_byte();
	    n_bytes = chk_sum - 3;  /* adj count for addr and checksum fields */
	    chk_sum += get_d_byte();
	    chk_sum += get_d_byte();
	    chk_sum += read_d_data(line_buf, n_bytes);
	    line_buf[n_bytes] = '\0';
	    chk_sum += get_d_byte() + 1; 
	    if( chk_sum & 0xff ) {
		error_detected = CHKSUM_ERROR;
		chksum = chk_sum;
		type = 0;
		return;
	    }
	    while( getc() != '\n' );
	    break;
	case 1:
	case 2:
	case 3:
	    fld_width = inchar + 1;
	    n_bytes = get_d_byte();
	    chk_sum = n_bytes;
	    load_addr = 0;
	    i = sizeof(long) - fld_width;
	    ptr = (char*)&load_addr + i;
	    while( ++i <= sizeof(long) ) {
		*ptr = get_d_byte();
		chk_sum += *ptr++;
	    }
	    n_bytes -= fld_width + 1;	/* adj count for addr and checksum */
	    chk_sum += read_d_data((char *)load_addr, n_bytes);
	    chk_sum += get_d_byte() + 1; 
	    if( chk_sum & 0xff ) {
		error_detected = CHKSUM_ERROR;
		chksum = chk_sum;
		type = fld_width - 1;
		return;
	    }
	    while( getc() != '\n' );
	    break;
	case 7:
	case 8:
	case 9:
	    fld_width = 11 - inchar;
	    n_bytes = get_d_byte();
	    chk_sum = n_bytes;
	    i = sizeof(long) - fld_width;
	    load_addr = 0;
	    ptr = (char*)&load_addr + i;
	    while( ++i <= sizeof(long) ) {
		*ptr = get_d_byte();
		chk_sum += *ptr++;
	    }
	    n_bytes -= fld_width + 1;	/* adj count for addr and checksum */
	    if( n_bytes > 0 ) 
		chk_sum += read_d_data(line_buf, n_bytes);
	    chk_sum += get_d_byte() + 1; 
	    if( chk_sum & 0xff ) {
		error_detected = CHKSUM_ERROR;
		chksum = chk_sum;
		type = 11 - fld_width;
		return;
	    }
	    while( getc() != '\n' );
	    return(load_addr);	    /* return starting address */
	default:
	    goto error;
	}
	inchar = getc();
	p2hold_buf = hold_buf_end;
	if( inchar != '$' ) {
	error:
	    error_detected = PREFIX_ERROR;
	    return(0);
	}
    }
}

/*----------------------------- read_d_data() -------------------------------*/

/*
 * read_d_data reads the characters from the record and stores values at
 * location ptr
 */

INT read_d_data(ptr,count)
char *ptr;
INT count;
{
    INT sum;

    sum = 0;
    while( -- count >= 0 ) {
	*ptr = get_d_byte();
	sum += *ptr++;
    }
    return(sum);
}

/*------------------------------- get_d_byte() ------------------------------*/

/*
 * get_d_byte reads raw data byte from buffer if available,
 * if not available, reads ascii characters into buffer until 5 characters
 * are collected, calls conversion function to get raw bytes
 */

INT get_d_byte()
{
    register INT i;
    INT inchar;
    char dollar_buf[6];

    if( p2hold_buf == hold_buf_end ) {
	for( i = 0; i < 5; i++ ) {	/* read 5 characters for conversion */
	    inchar = getc();
	    dollar_buf[i] = inchar;
	}
	dollar_buf[i] = '\0';
	hold_buf_end = unmap_d_rec(hold_buf, dollar_buf);
	p2hold_buf = hold_buf;
    }
    return(*p2hold_buf++);
}

/*----------------------------- unmap_d_rec() --------------------------------*/

/*
 * unmap_d_rec unmaps 5 ascii characters in $ format to 4 bytes of raw data
 */

char *unmap_d_rec(buf,dollar_buf)
register char *buf;
register unsigned char *dollar_buf;
{
    register const unsigned char *p2map_base;
    register INT i;
    
    while( *dollar_buf ) {
	p2map_base = map_base[*dollar_buf++ - A_BASE];
	for( i = 4; i; i-- )
	    *buf++ = *dollar_buf++ + *p2map_base++;
    }
    return(buf);
}
#endif

/*------------------------------ putstx() -----------------------------------*/

/*
 * putstx writes a character string to the terminal
 */

putstx(s)
char *s;
{
    while( *s )
	putchx(*s++);
}

/*------------------------------- i2hex() ----------------------------------*/

/*
 * i2hex takes an integer and a size mask in bytes and returns a pointer
 * to the converted ascii string ... warning ... do not call i2hex() more
 * than once inside a single function call
 */

char *i2hex(value,size_bytes)
unsigned long value;
int size_bytes;
{
    register char *ptr;

    value &= -1UL >> ((4 - size_bytes) << 3);

    ptr = i2hex_buf + 11;
    while( value ) {
	*--ptr = hex_char[value & 0xf];
	value >>= 4;
    }
    return(ptr);
}

/*------------------------------ getc() -----------------------------------*/

#ifdef PC_AT
INT getchx();
#define GETC	getchx()
#else
INT getchx1();
#define GETC	getchx1()
#endif

INT getc()
{
    INT c;

    while( !(c = GETC & 0x7f) );
    if( echo ) {
	if( c == '\n' )
	    return(c);
	putchx(c);
	if( c == '\r' )
	    putchx('\n');
    }
    return(c);
}
