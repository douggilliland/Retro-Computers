
/*	@(#)term.c	3.5		*/
/*
 * terminal/download/upload program
 *
 * this version uses interrupts on the serial input.
 * it also uses a vt52 emulator to display characters on the screen.
 * the <O>pen commands have been changed to accept a file name.
 *   saved input is now sent directly to CP/M without term buffering.
 */

/* interface to BIOS */
long BIOS();
#define MBIOS(a,b,c) BIOS((int)a,(long)b,(long)c)
#define CONS_ST	2
#define CONS_IN	3

/* aux port status reg and char available flag */
#define AUX_ST	(*(char *)0xf1c1cd)
#define RXCHAR	1
#define TXMPTY	4

/* aux port control reg */
#define AUX_CTL	(*(char *)0xf1c1cd)
#define EOI	0x38
#define RXINTEN	0x18
#define NOSINTS	0

/* aux port I/O */
#define AUX_CH	(*(char *)0xf1c1c9)

/* VME/10 control register 6 */
#define VME_CR6	(*(char *)0xf19f11)
#define INT3EN	0xa0

#define CR	13
#define LF	10
#define CMD	01
#define XON	0x11
#define XOFF	0x13
#define YES	1
#define NO	0
#define SIZE	32767

int	flag;		/* saving to file */
long	ochan;		/* output channel saving to */
char	ibuff[SIZE];	/* serial input buffer */
char	*ibpins, *ibpext; /* insert into and extract from buffer pointers */
int	ichar;		/* flag indicating character available in buffer */
int	oblkd;		/* flag blocking serial output */
int	iblkd;		/* flag indicating serial input blocked */
int	cr6;		/* original vme/10 cr6 contents */

/* local print string */
lprint(str)
char *str;
{
	char c;

	while ( c = *str++ )
	{
		if ( c == '\\' )
		{
			if ( (c = *str++) == 'n' ) c = 0x0a;
			else if ( c == 'r' ) c = 0x0d;
		}
		cons_out(c);
	}
}

/* send character to serial port */
sendc(ch)
char ch;
{
	if ( !((ch == XON) || (ch == XOFF)) )
		while ( oblkd )
			;
	while ( !(AUX_ST & TXMPTY) )
		;
	AUX_CH = ch;
}

/* get character from serial buffer */
char sgetc()
{
	char ch;

	if ( iblkd )
		if ( ibpext < ibpins )
		{
			if ( SIZE - (long)(ibpins - ibpext) > 500 )
			{
				sendc(XON);
				iblkd = NO;
			}
		}
		else if ( (long)(ibpext - ibpins) > 500 )
		{
			sendc(XON);
			iblkd = NO;
		}
	while ( !ichar )
		;
	ch = *ibpext;
	seti();
	if ( ibpext++ == ibuff + SIZE )
		ibpext = ibuff;
	if ( ibpext == ibpins )
		ichar = NO;
	clri();
	return(ch);
}

/* get character from keyboard */
char kgetc()
{
	return(MBIOS(CONS_IN,0,0));
}

/* serial port interrupt handler */
/* assumes only input interrupts */
serint()
{
	char ch;

	while ( AUX_ST & RXCHAR )
	{
		ch = AUX_CH;
		if ( ch == XOFF ) oblkd = YES;
		else if ( ch == XON ) oblkd = NO;
		else if ( !ichar || (ibpext != ibpins) )
		{
			/* if buffer was full we lose char */
			*ibpins = ch;
			if ( ibpins++ == ibuff + SIZE )
				ibpins = ibuff;
			ichar = YES;
		}
		if ( !iblkd )
	/* WARNING: sending char with ints disabled could lose input? */
			if ( ibpext < ibpins )
			{
				if ( SIZE - (long)(ibpins - ibpext ) < 300 )
				{
					sendc(XOFF);
					iblkd = YES;
				}
			}
			else if ( (long)(ibpext - ibpins) < 300 )
			{
				sendc(XOFF);
				iblkd = YES;
			}
	}
	/* send end of interrupt to ser port */
	AUX_CTL = EOI;
}

/* get string */
lgets(lgetc,fn,i)
char (*lgetc)();
char *fn;
{
	char c;

	do {
		c = (*lgetc)();
		*fn++ = c;
	} while ( (c!=CR) && (c!=LF) && (--i) );
	*(--fn) = 0;
}

/* open buffer */
opn(lgetc)
char (*lgetc)();
{
	char fname[40];
	char ostr[80];

	if (flag == NO)
	{
		if ( lgetc == kgetc )
			lprint("\n\rOPEN: file = ");
		lgets(lgetc,fname,40);
		if ( !(ochan = fopen(fname,"w")) )
		{
			lprint("\n\r<OPEN: file open error>\n\r");
			return;
		}
		flag = YES;
		sprintf(ostr,"\n\r<OPEN: %s opened>\n\r",fname);
		lprint(ostr);
	}
	else lprint("\n\r<OPEN: nothing done>\n\r");
}

/* close file */
clos()
{
	if (flag == YES)
	{
		flag = NO;
		fclose(ochan);
		fflush(ochan);
		lprint("\n\r<CLOSE: file closed>\n\r");
	}
	else lprint("\n\r<CLOSE: nothing done>\n\r");
}

/* quit */
quit() {
	/* disable interrupts */
	AUX_CTL = 1;		/* select ser port cr1 */
	AUX_CTL = NOSINTS;	/* disable ser port ints */
	setvmecr(6,cr6);	/* restore vme/10 cr6 */
	resvecs();		/* restore interrupt vectors */
	exit(0);
}

/* help */
help() {
	lprint("\n\r<c>lose\n\r<h>elp\n\r<o>pen");
	lprint("\n\r<q>uit\n\r");
/*	lprint("<t>ransmit\n\r");*/
}

/* get and process keyboard command */
cmd() {
	char c;

	c = kgetc() & 0x5f; /* make it UC */
	switch ( c )
	{
	case 'Q': quit();     break;
	case 'O': opn(kgetc); break;
	case 'C': clos();     break;
/*	case 'T': xmit();     break;*/
	case 'H': help();     break;
	}
}

/* upload to remote */
up()
{
	char fname[40];
	char ostr[80];
	char c, lastc;
	long chan;

	lgets(sgetc,fname,40);
	if ( !(chan = fopen(fname,"r")) )
	{
		sprintf(ostr,"\n\r<UPLOAD: cannot open %s>\n\r",fname);
		lprint(ostr);
		sendc(0x03);  /* ^C to end upload */
		return;
	}
	sprintf(ostr,"\n\r<UPLOAD: uploading %s>\n\r",fname);
	lprint(ostr);
	c = fgetc(chan);
	while ( !((c == -1) || (c == 0x1a /* ^Z */)) )
	{
		sendc(c);
		lastc = c;
		c = fgetc(chan);
	}
	if ( !((lastc == 0x0a) || (lastc == 0x0d)) )
		sendc(0x04); /* takes 2 ^D's to end */
	sendc(0x04); /* ^D to end upload */
	fclose(chan);
	lprint("\n\r<UPLOAD: complete>\n\r");
}

/* get and process remote command */
rcmd()
{
	char c;

	c = sgetc() & 0x5f; /* make it UC */
	switch ( c )
	{
	case 'O': opn(sgetc); break;
	case 'C': clos();     break;
	case 'U': up();       break;
	}
}

/* main terminal loop */
main()
{
	char c;

	lprint("\033H\033J");	/* home, clear */
	lprint("\n\rterminal/download/upload program - 3.5\n\r");
	lprint("\n\rCommands are ^A followed by another character.\n\r");
	lprint("\n\rLocal (from keyboard) commands are:");
	help();
	lprint("\n\rRemote (from host) commands are:");
	lprint("\n\r<o>pen (download file)\n\r<c>lose (download file)");
	lprint("\n\r<u>pload");
	lprint("\n\rCommands 'o' and 'u' expect a CP/M filename.");
	lprint("\n\rUpload terminates with ^D (normal) or ^C (error).\n\r");
	/* initialization */
	cr6 = VME_CR6;
	ibpins = ibuff;
	ibpext = ibuff;
	ichar = NO;
	oblkd = NO;
	iblkd = NO;
	flag = NO;
	setivecs();
	/* enable interrupts */
	AUX_CTL = 1;		/* select ser port cr1 */
	AUX_CTL = RXINTEN;	/* enable RX interrupts */
	setvmecr(6, cr6 | INT3EN); /* enable I/O chan INT3 */
	/* main loop */
	while (YES)
	{
		if ( ichar )
		{
			c = sgetc();
			if ( c == CMD ) rcmd();
			else if ( flag ) fputc(c,ochan);
			else cons_out(c);
		}
		else if ( MBIOS(CONS_ST,0,0) )
		{
			if ( (c = kgetc()) == CMD ) cmd();
			else sendc(c);
		}
	}
}

s_out(c);
		}
		else if ( MBIOS(CONS_ST,0,0) )
		{
			