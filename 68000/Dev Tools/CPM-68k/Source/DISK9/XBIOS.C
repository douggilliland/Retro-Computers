/*=======================================================================*/
/*/---------------------------------------------------------------------\*/
/*|									|*/
/*|     CP/M-68K(tm) BIOS for the EXORMACS 				|*/
/*|									|*/
/*|     Copyright 1983, Digital Research.				|*/
/*|									|*/
/*|	Modified 9/ 7/82 wbt						|*/
/*|		10/ 5/82 wbt						|*/
/*|		12/15/82 wbt						|*/
/*|		12/22/82 wbt						|*/
/*|		 1/28/83 wbt						|*/
/*|		 2/05/84 sw	V1.2					|*/
/*|		 8/22/85 wbt    V1.3					|*/
/*|									|*/
/*\---------------------------------------------------------------------/*/
/*=======================================================================*/

#include "xbiostyp.h"	/* defines LOADER : 0-> normal bios, 1->loader bios */
			/* also defines CTLTYPE 0 -> Universal Disk Cntrlr  */
			/*			1 -> Floppy Disk Controller */
			/* MEMDSK: 0 -> no memory disk			    */
			/*	   4 -> 384K memory disk		    */
			/* If loader BIOS then define BOOTDRV */
			/* 0..3 => boot from a..d respectively*/

#include "biostyps.h"	/* defines portable variable types */

char copyright[] = "Copyright 1983, Digital Research";

struct memb { BYTE byte; };	/* use for peeking and poking memory */
struct memw { WORD word; };
struct meml { LONG lword;};


/************************************************************************/ 
/*      I/O Device Definitions						*/
/************************************************************************/


/************************************************************************/ 
/*      Define the two serial ports on the DEBUG board			*/
/************************************************************************/

/* Port Addresses */

#define PORT1 0xFFEE011	/* console port */
#define PORT2 0xFFEE015 /* debug port   */
 
/* Port Offsets */

#define PORTCTRL 0	/* Control Register */
#define PORTSTAT 0	/* Status  Register */
#define PORTRDR  2	/* Read  Data Register */
#define PORTTDR  2	/* Write Data Register */

/* Port Control Functions */
 
#define PORTRSET 3	/* Port Reset */
#define PORTINIT 0x11	/* Port Initialize */

/* Port Status Values */
 
#define PORTRDRF 1	/* Read  Data Register Full */
#define PORTTDRE 2	/* Write Data Register Empty */
 

/************************************************************************/
/* Define Disk I/O Addresses and Related Constants			*/
/************************************************************************/

#define DSKIPC		0xFF0000	/* IPC Base Address */

#define DSKINTV		0x3FC		/* Address of Disk Interrupt Vector */

#define INTTOIPC	0xD		/* offsets in mem mapped io area */
#define RSTTOIPC	0xF
#define MSGTOIPC	0x101
#define ACKTOIPC	0x103
#define	PKTTOIPC	0x105
#define	MSGFMIPC	0x181
#define ACKFMIPC	0x183
#define PKTFMIPC	0x185

#define DSKREAD		0x10		/* disk commands */
#define DSKWRITE	0x20

/* Some characters used in disk controller packets */

#define	STX	0x02
#define ETX	0x03
#define	ACK	0x06
#define NAK	0x15

#define PKTSTX		0x0		/* offsets within a disk packet */
#define PKTID		0x1
#define PKTSZ		0x2
#define PKTDEV		0x3
#define PKTCHCOM	0x4
#define PKTSTCOM	0x5
#define	PKTSTVAL	0x6
#define PKTSTPRM	0x8
#define	STPKTSZ		0xf


/************************************************************************/
/* BIOS  Table Definitions						*/
/************************************************************************/

/* Disk Parameter Block Structure */

struct dpb
{
	WORD	spt;
	BYTE	bsh;
	BYTE	blm;
	BYTE	exm;
	BYTE	dpbjunk;
	WORD	dsm;
	WORD	drm;
	BYTE	al0;
	BYTE	al1;
	WORD	cks;
	WORD	off;
};


/* Disk Parameter Header Structure */

struct dph
{
	BYTE	*xltp;
	WORD	 dphscr[3];
	BYTE	*dirbufp;
struct	dpb	*dpbp;
	BYTE	*csvp;
	BYTE	*alvp;
};



/************************************************************************/
/*	Directory Buffer for use by the BDOS				*/
/************************************************************************/

BYTE dirbuf[128];

#if ! LOADER

/************************************************************************/
/*	CSV's								*/
/************************************************************************/

BYTE	csv0[16];
BYTE	csv1[16];

#if ! CTLTYPE

BYTE	csv2[256];
BYTE	csv3[256];

#endif

#if	MEMDSK
BYTE	csv4[16];
#endif

/************************************************************************/
/*	ALV's								*/
/************************************************************************/

BYTE	alv0[32];	/* (dsm0 / 8) + 1	*/
BYTE	alv1[32];	/* (dsm1 / 8) + 1	*/

#if ! CTLTYPE

BYTE	alv2[412];	/* (dsm2 / 8) + 1	*/
BYTE	alv3[412];	/* (dsm2 / 8) + 1	*/

#endif

#if	MEMDSK
BYTE	alv4[48];	/* (dsm4 / 8) + 1	*/
#endif

#endif
 
/************************************************************************/
/*	Disk Parameter Blocks						*/
/************************************************************************/

/* The following dpb definitions express the intent of the writer,	*/
/* unfortunately, due to a compiler bug, these lines cannot be used.	*/
/* Therefore, the obscure code following them has been inserted.	*/
/*sw With release 1.2, the structure init bug disappeared, so...	*/
/*************    spt, bsh, blm, exm, jnk,   dsm,  drm,  al0, al1, cks, off */

struct dpb dpb0 = { 26,   3,   7,   0,   0,   242,   63,    0,   0,  16,   2};

#if ! CTLTYPE
struct dpb dpb2 = { 32,   5,  31,   1,   0,  3288, 1023,     0,  0, 256,   4};
#endif

#if   MEMDSK
struct dpb dpb3 = { 32,   4,  15,   0,   0,   191,   63,    0,   0,  0,   0};
#endif

/************************************************************************/
/* Sector Translate Table for Floppy Disks				*/ 
/************************************************************************/


BYTE	xlt[26] = {  1,  7, 13, 19, 25,  5, 11, 17, 23,  3,  9, 15, 21,
		     2,  8, 14, 20, 26,  6, 12, 18, 24,  4, 10, 16, 22 };

 
/************************************************************************/
/* Disk Parameter Headers						*/
/*									*/
/* Four disks are defined : dsk a: diskno=0, (Motorola's #fd04)		*/
/* if CTLTYPE = 0	  : dsk b: diskno=1, (Motorola's #fd05)		*/
/*			  : dsk c: diskno=2, (Motorola's #hd00)		*/
/*			  : dsk d: diskno=3, (Motorola's #hd01)		*/
/*									*/
/* Two disks are defined  : dsk a: diskno=0, (Motorola's #fd00)		*/
/* if CTLTYPE = 1	  : dsk b: diskno=1, (Motorola's #fd01)		*/
/*									*/
/************************************************************************/

#if ! LOADER

/* Disk Parameter Headers */
struct dph dphtab[] =

		{ {&xlt, 0, 0, 0, &dirbuf, &dpb0, &csv0, &alv0}, /*dsk a*/
		  {&xlt, 0, 0, 0, &dirbuf, &dpb0, &csv1, &alv1}, /*dsk b*/
#if ! CTLTYPE
		  {  0L, 0, 0, 0, &dirbuf, &dpb2, &csv2, &alv2}, /*dsk c*/
		  {  0L, 0, 0, 0, &dirbuf, &dpb2, &csv3, &alv3}, /*dsk d*/
#endif

#if   MEMDSK
		  {  0L, 0, 0, 0, &dirbuf, &dpb3, &csv4, &alv4}  /*dsk e*/
		};
#endif

#else

#if ! CTLTYPE
struct dph dphtab[4] =
#else
struct dph dphtab[2] =
#endif
		{ {&xlt, 0, 0, 0, &dirbuf, &dpb0,    0L,    0L}, /*dsk a*/
		  {&xlt, 0, 0, 0, &dirbuf, &dpb0,    0L,    0L}, /*dsk b*/
#if ! CTLTYPE
		  {  0L, 0, 0, 0, &dirbuf, &dpb2,    0L,    0L}, /*dsk c*/
		  {  0L, 0, 0, 0, &dirbuf, &dpb2,    0L,    0L}, /*dsk d*/
#endif
		};
#endif

/************************************************************************/
/*	Memory Region Table						*/
/************************************************************************/

struct mrt {	WORD count;
		LONG tpalow;
		LONG tpalen;
	   }
	memtab;				/* Initialized in BIOSA.S	*/


#if   MEMDSK
BYTE *memdsk;				/* Initialized in BIOSA.S	*/
#endif

#if ! LOADER

/************************************************************************/
/*	IOBYTE								*/
/************************************************************************/

WORD iobyte;	/* The I/O Byte is defined, but not used */

#endif


/************************************************************************/
/*	Currently Selected Disk Stuff					*/
/************************************************************************/

WORD settrk, setsec, setdsk;	/* Currently set track, sector, disk */
BYTE *setdma;			/* Currently set dma address */



/************************************************************************/
/*	Track Buffering Definitions and Variables			*/
/************************************************************************/

#if ! LOADER

#define	NUMTB	3 /* Number of track buffers -- must be at least 3	*/
		  /* for the algorithms in this BIOS to work properly	*/

/* Define the track buffer structure */

struct	tbstr {	
		struct	tbstr  *nextbuf;     /* form linked list for LRU  */
			BYTE	buf[32*128]; /* big enough for 1/4 hd trk */
			WORD	dsk;	     /* disk for this buffer  */
			WORD	trk;	     /* track for this buffer */
			BYTE	valid;	     /* buffer valid flag     */
			BYTE	dirty;	     /* true if a BIOS write has   */
					     /*	put data in this buffer,   */
					     /*	but the buffer hasn't been */
					     /* flushed yet.		   */
};

struct tbstr *firstbuf;	/* head of linked list of track buffers */
struct tbstr *lastbuf;  /* tail of ditto */

struct tbstr tbuf[NUMTB];	/* array of track buffers */

#else

/* the loader bios uses only 1 track buffer */

BYTE buf1trk[32*128];	/* big enough for 1/4 hd trk */
BYTE bufvalid;
WORD buftrk;

#endif


/************************************************************************/
/*	Disk I/O Packets for the UDC and other Disk I/O Variables	*/
/************************************************************************/

/* Home disk packet */

struct hmpkst {
		BYTE	a1;
		BYTE	a2;
		BYTE	a3;
		BYTE	dskno;
		BYTE	com1;
		BYTE	com2;
		BYTE	a6;
		BYTE	a7;
	      }
	hmpack = { 2,0, 7,0, 0,0, 3,0 };  /*sw Init by bytes now... */
/*	hmpack = { 512, 1792, 0,  768 };*/ /* kludge init by words */


/* Read/write disk packet */

struct rwpkst {
		BYTE	stxchr;
		BYTE	pktid;
		BYTE	pktsize;
		BYTE	dskno;
		BYTE	chcmd;
		BYTE	devcmd;
		WORD	numblks;
		WORD	blksize;
		LONG	iobf;
		WORD	cksum;
		LONG	lsect;
		BYTE	etxchr;
		BYTE	rwpad;
	      };
  struct rwpkst rwpack = { 2,0, 21,0,  16,1, 13, 256, 0L,   0, 0L,   3,0 };
/*struct rwpkst rwpack = { 512, 5376, 4097, 13, 256, 0, 0, 0, 0, 0, 768 };*/

#if ! LOADER

/* format disk packet */

struct fmtpkst {
		BYTE	fmtstx;
		BYTE	fmtid;
		BYTE	fmtsize;
		BYTE	fmtdskno;
		BYTE	fmtchcmd;
		BYTE	fmtdvcmd;
		BYTE	fmtetx;
		BYTE	fmtpad;
	       };

/*struct fmtpkst fmtpack = { 512, 1792, 0x4002, 0x0300 };*/
  struct fmtpkst fmtpack = { 2,0,  7,0,   64,2,    3,0 };

#endif

/************************************************************************/
/*	Define the number of disks supported and other disk stuff	*/
/************************************************************************/

#if ! CTLTYPE
#define NUMDSKS 4		/* number of disks defined */
#else
#define NUMDSKS 2
#endif
#if MEMDSK
#define NUMDSKS 5
#endif

#define MAXDSK  (NUMDSKS-1)	/* maximum disk number 	   */

#if ! CTLTYPE
BYTE cnvdsk[NUMDSKS] = { 4, 5, 0, 1 };  /* convert CP/M dsk# to EXORmacs */
BYTE rcnvdsk[6]	     = { 2, 3, 0, 0, 0, 1 }; /* and vice versa */
#else
BYTE cnvdsk[NUMDSKS] = { 0, 1 };
BYTE rcnvdsk[2]	     = { 0, 1 };
#endif

/* defines for IPC and disk states */

#define IDLE	0
#define ACTIVE	1

WORD ipcstate;	/* current IPC state */
WORD actvdsk;	/* disk number of currently active disk, if any */
LONG intcount;	/* count of interrupts needing to be processed  */



struct dskst {
		WORD	state;	/* from defines above	*/
		BYTE	ready;	/* 0 => not ready	*/
		BYTE	change;	/* 0 => no change	*/
	     }
	dskstate[NUMDSKS];


/************************************************************************/
/*      Generic Serial Port I/O Procedures				*/
/************************************************************************/

/************************************************************************/
/*	Port initialization						*/
/************************************************************************/

portinit(port)
REG BYTE *port;
{
        *(port + PORTCTRL) = PORTRSET;	/* reset the port */
        *(port + PORTCTRL) = PORTINIT;
}



/************************************************************************/ 
/*	Generic serial port status input status				*/
/************************************************************************/

 
portstat(port)
REG BYTE *port;
{
        if ( *(port + PORTSTAT) & PORTRDRF) return(0xff); /* input ready */
	else				    return(0x00); /* not ready	 */
}
 
 
/************************************************************************/ 
/*	Generic serial port input					*/
/************************************************************************/
 
BYTE portin(port)
REG BYTE *port;
{
        while ( ! portstat(port)) ;		/* wait for input	*/
        return ( *(port + PORTRDR));	/* got some, return it	*/
}
 
 
/************************************************************************/ 
/*	Generic serial port output					*/
/************************************************************************/
 
portout(port, ch)
REG BYTE *port;
REG BYTE ch;
{
        while ( ! (*(port + PORTSTAT) & PORTTDRE) ) ; /* wait for ok to send */
        *(port + PORTTDR) = ch;			      /* then send character */
}
 
 
/************************************************************************/ 
/*      Error procedure for BIOS					*/
/************************************************************************/

#if ! LOADER

bioserr(errmsg)
REG BYTE *errmsg;
{
        printstr("\n\rBIOS ERROR -- ");
        printstr(errmsg);
        printstr(".\n\r");
}
 
printstr(s)     /* used by bioserr */
REG BYTE *s;
{ 
        while (*s) {portout(PORT1,*s); s += 1; };
}

#else

bioserr()	/* minimal error procedure for loader BIOS */
{
	l : goto l;
}

#endif

/************************************************************************/
/*	Disk I/O Procedures						*/
/************************************************************************/


EXTERN dskia();		/* external interrupt handler -- calls dskic	 */
EXTERN setimask();	/* use to set interrupt mask -- returns old mask */

dskic()
{
	/* Disk Interrupt Handler -- C Language Portion */

	REG BYTE workbyte;
	BYTE	stpkt[STPKTSZ];

	workbyte = (DSKIPC + ACKFMIPC)->byte;
	if ( (workbyte == ACK) || (workbyte == NAK) )
	{
		if ( ipcstate == ACTIVE ) intcount += 1;
		else (DSKIPC + ACKFMIPC)->byte = 0;	/* ??? */
	}

	workbyte = (DSKIPC + MSGFMIPC)->byte;
	if ( workbyte & 0x80 )
	{
		getstpkt(stpkt);

		if ( stpkt[PKTID] == 0xFF )
		{
			/* unsolicited */

			unsolst(stpkt);
			sendack();
		}
		else
		{
			/* solicited */

			if ( ipcstate == ACTIVE ) intcount += 1;
			else sendack();
		}
	}


} /* end of dskic */

/************************************************************************/
/*	Read status packet from IPC					*/
/************************************************************************/

getstpkt(stpktp)
REG BYTE *stpktp;
{
	REG BYTE *p, *q;
	REG WORD i;

	p = stpktp;
	q = (DSKIPC + PKTFMIPC);

	for ( i = STPKTSZ; i; i -= 1 )
	{
		*p = *q;
		 p += 1;
		 q += 2;
	}
}

/************************************************************************/
/*	Handle Unsolicited Status from IPC				*/
/************************************************************************/

unsolst(stpktp)
REG BYTE *stpktp;
{
	REG WORD dev;
	REG WORD ready;
	REG struct dskst *dsp;

	dev = rcnvdsk[ (stpktp+PKTDEV)->byte ];
	ready = ((stpktp+PKTSTPRM)->byte & 0x80) == 0x0;
	dsp = & dskstate[dev];
	if (  ( ready  && !(dsp->ready) ) ||
	      (!ready) &&  (dsp->ready)     ) dsp->change = 1;
	dsp->ready = ready;
#if ! LOADER
	if ( ! ready ) setinvld(dev); /* Disk is not ready, mark buffers */
#endif
}


#if ! LOADER

/************************************************************************/
/*	Mark all buffers for a disk as not valid			*/
/************************************************************************/

setinvld(dsk)
REG WORD dsk;
{
	REG struct tbstr *tbp;

	tbp = firstbuf;
	while ( tbp )
	{
		if ( tbp->dsk == dsk ) tbp->valid = 0;
		tbp = tbp->nextbuf;
	}
}

#endif

/************************************************************************/
/*	Wait for an ACK from the IPC					*/
/************************************************************************/

waitack()
{
	REG WORD imsave;
	REG BYTE work;

	while (1)
	{
	  	while ( ! intcount ) ; /* wait */ 

		imsave = setimask(7);
		intcount -= 1;		
		work = (DSKIPC + ACKFMIPC)->byte;
		if ( (work == ACK) || (work == NAK) )
		{
			(DSKIPC + ACKFMIPC)->byte = 0;
			setimask(imsave);
			return(work == ACK);
		}
		setimask(imsave);
	}
}



/************************************************************************/
/*	Acknowledge a message from the IPC				*/
/************************************************************************/

sendack()
{
	(DSKIPC + MSGFMIPC)->byte = 0;	/* clear message flag */
	(DSKIPC + ACKTOIPC)->byte = ACK;	/* send ACK   */
	(DSKIPC + INTTOIPC)->byte = 0;	/* interrupt IPC      */
}


/************************************************************************/
/*	Send a packet to the IPC					*/
/************************************************************************/

sendpkt(pktadr, pktsize)
REG BYTE *pktadr;
REG WORD  pktsize;
{
	REG BYTE *iopackp;
	REG WORD  imsave;

	while ( (DSKIPC+MSGTOIPC)->byte ); /* wait til ready */
	(DSKIPC+ACKFMIPC)->byte = 0;
	(DSKIPC+MSGFMIPC)->byte = 0;
	iopackp = (DSKIPC+PKTTOIPC);
	do {*iopackp = *pktadr++; iopackp += 2; pktsize -= 1;} while(pktsize);
	(DSKIPC+MSGTOIPC)->byte = 0x80;
	imsave = setimask(7);
	dskstate[actvdsk].state = ACTIVE;
	ipcstate = ACTIVE;
	intcount = 0L;
	(DSKIPC+INTTOIPC)->byte = 0;
	setimask(imsave);
	waitack();
}

/************************************************************************/
/*	Wait for a Disk Operation to Finish				*/
/************************************************************************/

WORD dskwait(dsk, stcom, stval)
REG WORD dsk;
BYTE	 stcom;
WORD	 stval;
{
	REG WORD imsave;
	BYTE stpkt[STPKTSZ];

	imsave = setimask(7);
	while ( (! intcount) &&
		dskstate[dsk].ready && (! dskstate[dsk].change) )
	{
		setimask(imsave); imsave = setimask(7);
	}

	if ( intcount )
	{
		intcount -= 1;
		if ( ( (DSKIPC + MSGFMIPC)->byte & 0x80 ) == 0x80 )
		{
			getstpkt(stpkt);
			setimask(imsave);
			if ( (stpkt[PKTSTCOM] == stcom) &&
			     ( (stpkt+PKTSTVAL)->word == stval ) ) return (1);
			else					   return (0);
		}
	}
	setimask(imsave);
	return(0);
}

/************************************************************************/
/*	Do a Disk Read or Write						*/
/************************************************************************/

dskxfer(dsk, trk, bufp, cmd)
REG WORD  dsk, trk, cmd;
REG BYTE *bufp;
{
	/* build packet */

	REG WORD sectcnt;
	REG WORD result;

#if CTLTYPE
	LONG bytecnt;	/* only needed for FDC */
	WORD cheksum;
#endif

	rwpack.dskno = cnvdsk[dsk];
	rwpack.iobf  = bufp;
	sectcnt = (dphtab[dsk].dpbp)->spt;
	rwpack.lsect = trk * (sectcnt >> 1);
	rwpack.chcmd = cmd;
	rwpack.numblks = (sectcnt >> 1);

#if CTLTYPE
	cheksum = 0;			/* FDC needs checksum */
	bytecnt = ((LONG)sectcnt) << 7;
	while ( bytecnt-- ) cheksum += (~(*bufp++)) & 0xff;
	rwpack.cksum = cheksum;
#endif

	actvdsk = dsk;
	dskstate[dsk].change = 0;
	sendpkt(&rwpack, 21);
	result = dskwait(dsk, 0x70, 0x0);
	sendack();
	dskstate[dsk].state = IDLE;
	ipcstate = IDLE;
	return(result);
}


#if ! LOADER

/************************************************************************/
/*	Write one disk buffer						*/
/************************************************************************/

flush1(tbp)
struct tbstr *tbp;
{
	REG WORD ok;

	if ( tbp->valid && tbp->dirty )
		ok = dskxfer(tbp->dsk, tbp->trk, tbp->buf, DSKWRITE);
	else ok = 1;

	tbp->dirty = 0;		/* even if error, mark not dirty */
	tbp->valid &= ok;	/* otherwise system has trouble  */
				/* continuing.			 */
	return(ok);
}

/************************************************************************/
/*	Write all disk buffers						*/
/************************************************************************/

flush()
{
	REG struct tbstr *tbp;
	REG WORD ok;

	ok = 1;
	tbp = firstbuf;
	while (tbp)
	{
		if ( ! flush1(tbp) ) ok = 0;
		tbp = tbp->nextbuf;
	}
	return(ok);
}



/*************************************************************************/
/*	Fill the indicated disk buffer with the current track and sector */
/*************************************************************************/

fill(tbp)
REG struct tbstr *tbp;
{
	REG WORD ok;

	if ( tbp->valid && tbp->dirty ) ok = flush1(tbp);
	else ok = 1;

	if (ok) ok = dskxfer(setdsk, settrk, tbp->buf, DSKREAD);

	tbp->valid = ok;
	tbp->dirty = 0;
	tbp->trk = settrk;
	tbp->dsk = setdsk;

	return(ok);
}


/************************************************************************/
/*	Return the address of a track buffer structure containing the	*/
/*	currently set track of the currently set disk.			*/
/************************************************************************/

struct tbstr *gettrk()
{
	REG struct tbstr *tbp;
	REG struct tbstr *ltbp;
	REG struct tbstr *mtbp;
	REG WORD imsave;

	/* Check for disk on-line -- if not, return error */

	imsave = setimask(7);
	if ( ! dskstate[setdsk].ready )
	{
		setimask(imsave);
		tbp = 0L;
		return (tbp);
	}

	/* Search through buffers to see if the required stuff	*/
	/* is already in a buffer				*/

	tbp = firstbuf;
	ltbp = 0;
	mtbp = 0;

	while (tbp)
	{
		if ( (tbp->valid) && (tbp->dsk == setdsk) 
		     && (tbp->trk == settrk) )
		{
			if (ltbp)	/* found it -- rearrange LRU links */
			{
				ltbp->nextbuf = tbp->nextbuf;
				tbp->nextbuf  = firstbuf;
				firstbuf      = tbp;
			}
			setimask(imsave);
			return ( tbp );
		}
		else
		{
			mtbp = ltbp;	/* move along to next buffer */
			ltbp = tbp;
			tbp  = tbp->nextbuf;
		}
	}

	/* The stuff we need is not in a buffer, we must make a buffer	*/
	/* available, and fill it with the desired track		*/

	if (mtbp) mtbp->nextbuf = 0;	/* detach lru buffer */
	ltbp->nextbuf = firstbuf;
	firstbuf = ltbp;
	setimask(imsave);
	if (flush1(ltbp) && fill(ltbp)) mtbp = ltbp;	/* success */
	else				mtbp = 0L ;	/* failure */
	return (mtbp);
}



/************************************************************************/
/*	Bios READ Function -- read one sector				*/
/************************************************************************/

read()
{
	REG BYTE	*p;
	REG BYTE	*q;
	REG WORD	 i;
	REG struct tbstr *tbp;

#if	MEMDSK
    if(setdsk != MEMDSK)
    {
#endif
	tbp = gettrk();		/* locate track buffer with sector */

	if ( ! tbp ) return(1); /* failure */

	/* locate sector in buffer and copy contents to user area */

	p = (tbp->buf) + (setsec << 7);	/* multiply by shifting */
#if	MEMDSK
    }
    else
	p = memdsk + (((LONG)(settrk) << 12L) + ((LONG)setsec << 7L));
#endif
	q = setdma;
	i = 128;
	do {*q++ = *p++; i -= 1;} while (i); /* this generates good code */
	return(0);
}


/************************************************************************/
/*	BIOS WRITE Function -- write one sector 			*/
/************************************************************************/

write(mode)
BYTE mode;
{
	REG BYTE	*p;
	REG BYTE	*q;
	REG WORD	 i;
	REG struct tbstr *tbp;

	/* locate track buffer containing sector to be written */
#if	MEMDSK
    if(setdsk != MEMDSK)
    {
#endif
	tbp = gettrk();
	if ( ! tbp ) return (1); /* failure */

	/* locate desired sector and do copy the data from the user area */

	p = (tbp->buf) + (setsec << 7);	/* multiply by shifting */
#if	MEMDSK
     } else
     {
	p = memdsk + (((LONG)(settrk) << 12L) + ((LONG)setsec << 7L));
	q = setdma;
	i = 128;
	do {*p++ = *q++; i -= 1;} while (i); /* this generates good code */
	return(0);
      }
#endif
	q = setdma;
	i = 128;
	do {*p++ = *q++; i -= 1;} while (i); /* this generates good code */

	tbp->dirty = 1;	/* the buffer is now "dirty" */

	/* The track must be written if this is a directory write */

	if ( mode == 1 ){if ( flush1(tbp) ) return(0); else return(1);}
	else return(0);
}

#else

/************************************************************************/
/*	Read and Write functions for the Loader BIOS			*/
/************************************************************************/

read()
{
	REG BYTE *p;
	REG BYTE *q;
	REG WORD  i;

	if ( ( (! bufvalid) || (buftrk != settrk) ) &&
	     ( ! dskxfer(setdsk, settrk, buf1trk, DSKREAD) ) ) {return(1);}
	bufvalid = 1;
	buftrk = settrk;
	p = buf1trk + (setsec << 7);
	q = setdma;
	i = 128;
	do { *q++ = *p++; i-=1; } while(i);
	return(0);
}

#endif


/************************************************************************/
/*	BIOS Sector Translate Function					*/
/************************************************************************/

WORD sectran(s, xp)
REG WORD  s;
REG BYTE *xp;
{
	if (xp) return (WORD)xp[s];
	else	return (s+1);
}


/************************************************************************/
/*	BIOS Set Exception Vector Function				*/
/************************************************************************/

LONG setxvect(vnum, vval)
WORD vnum;
LONG vval;
{
	REG LONG  oldval;
	REG BYTE *vloc;

	vloc = ( (long)vnum ) << 2;
	oldval = vloc->lword;
	vloc->lword = vval;

	return(oldval);	

}


/************************************************************************/
/*	BIOS Select Disk Function					*/
/************************************************************************/

LONG slctdsk(dsk, logged)
REG BYTE dsk;
    BYTE logged;
{
	REG struct dph	*dphp;
	REG BYTE     st1, st2;
	BYTE	stpkt[STPKTSZ];

	setdsk = dsk;	/* Record the selected disk number */

#if ! LOADER

	/* Special Code to disable drive C. On the EXORmacs, drive C	*/
	/* is the non-removable hard disk.  Including this code lets	*/
	/* you save your non-removable disk for non-CP/M use.		*/

	if ( (dsk > MAXDSK) || ( dsk == 2 ) )
	{
		printstr("\n\rBIOS ERROR -- DISK ");
		portout(PORT1, 'A'+dsk);
		printstr(" NOT SUPPORTED\n\r");
		return(0L);
	}
#endif

	dphp = &dphtab[dsk];

#if	MEMDSK
	if (setdsk == MEMDSK)
		return(dphp);
#endif

	if ( ! (logged & 0x1) )
	{

		hmpack.dskno = cnvdsk[setdsk];
		hmpack.com1  = 0x30;
		hmpack.com2  = 0x02;
		actvdsk = dsk;
		dskstate[dsk].change = 0;
		sendpkt(&hmpack, 7);
		if ( ! dskwait(dsk, 0x72, 0x0) )
		{
			sendack();
			ipcstate = IDLE;
			return ( 0L );
		}
		getstpkt(stpkt);	/* determine disk type and size */
		sendack();
		ipcstate = IDLE;
		st1 = stpkt[PKTSTPRM];
		st2 = stpkt[PKTSTPRM+1];

		if ( st1 & 0x80 )	/* not ready / ready */
		{
			dskstate[dsk].ready = 0;
			return(0L);
		}
		else
			dskstate[dsk].ready = 1;

		switch ( st1 & 7 )
		{
		   case 1 :	/* floppy disk	*/

				dphp->dpbp = &dpb0;
				break;

#if ! CTLTYPE
		   case 2 :	/* hard disk	*/

				dphp->dpbp = &dpb2;
				break;
#endif

		   default :	bioserr("Invalid Disk Status");
				dphp = 0L;
				break;
		}
	}
	return(dphp);
}


#if ! LOADER
/****************************************************************/
/*								*/
/*	This function is included as an undocumented, 		*/
/*	unsupported method for EXORmacs users to format		*/
/*	disks.  It is not a part of CP/M-68K proper, and	*/
/*	is only included here for convenience, since the	*/
/*	Motorola disk controller is somewhat complex to		*/
/*	program, and the BIOS contains supporting routines.	*/
/*								*/
/****************************************************************/

format(dsk)
REG WORD dsk;
{
	REG WORD retval;

	if ( ! slctdsk( (BYTE)dsk, (BYTE) 1 ) ) return;

#if	MEMDSK
	if (setdsk == MEMDSK) return;
#endif

	fmtpack.dskno = cnvdsk[setdsk];
	actvdsk = setdsk;
	dskstate[setdsk].change = 0;
	sendpkt(&fmtpack, 7);
	if ( ! dskwait(setdsk, 0x70, 0x0) ) retval = 0;
	else				    retval = 1;
	sendack();
	ipcstate = IDLE;
	return(retval);
}

#endif 

/************************************************************************/
/*									*/
/*	Bios initialization.  Must be done before any regular BIOS	*/
/*	calls are performed.						*/
/*									*/
/************************************************************************/

biosinit()
{
	initprts();
	initdsks();
}

initprts()
{
        portinit(PORT1);
        portinit(PORT2);
}

initdsks()
{
	REG WORD i;
	REG WORD imsave;

#if ! LOADER
	for ( i = 0; i < NUMTB; ++i )
	{
		tbuf[i].valid = 0;
		tbuf[i].dirty = 0;
		if ( (i+1) < NUMTB ) tbuf[i].nextbuf = &tbuf[i+1];
		else		     tbuf[i].nextbuf = 0;
	}
	firstbuf = &tbuf[0];
	lastbuf  = &tbuf[NUMTB-1];
#else
	bufvalid = 0;
#endif

	for ( i = 0; i <= MAXDSK; i += 1)
	{
		dskstate[i].state  = IDLE;
		dskstate[i].ready  = 1;
		dskstate[i].change = 0;
	}

	imsave = setimask(7);  /* turn off interrupts */
	intcount = 0;
	ipcstate = IDLE;
	setimask(imsave);      /* turn on interrupts */
}
 


/************************************************************************/
/*									*/
/*      BIOS MAIN ENTRY -- Branch out to the various functions.		*/
/*									*/
/************************************************************************/
 
LONG cbios(d0, d1, d2)
REG WORD	d0;
REG LONG	d1, d2;
{

	switch(d0)
	{
		case 0:	biosinit();			/* INIT		*/
			break;

#if ! LOADER
		case 1:	flush();			/* WBOOT	*/
			initdsks();
			wboot();
		     /* break; */
#endif
		case 2:	return(portstat(PORT1));	/* CONST	*/
		     /* break; */

		case 3: return(portin(PORT1));		/* CONIN	*/
		     /* break; */

		case 4: portout(PORT1, (char)d1);	/* CONOUT	*/
			break;

		case 5:	;				/* LIST		*/
		case 6: portout(PORT2, (char)d1);	/* PUNCH	*/
			break;

		case 7:	return(portin(PORT2));		/* READER	*/
		     /* break; */

		case 8:	settrk = 0;			/* HOME		*/
			break;

		case 9:	
#if LOADER
			d1 = BOOTDRV;
#endif
			return(slctdsk((char)d1, (char)d2)); /* SELDSK	*/
		     /* break; */

		case 10: settrk = (int)d1;		/* SETTRK	*/
			 break;

		case 11: setsec = ((int)d1-1);		/* SETSEC	*/
			 break;

		case 12: setdma = d1;			/* SETDMA	*/
			 break;

		case 13: return(read());		/* READ		*/
		      /* break; */
#if ! LOADER
		case 14: return(write((char)d1));	/* WRITE	*/
		      /* break; */

		case 15: if ( *(BYTE *)(PORT2 + PORTSTAT) & PORTTDRE )
				return ( 0x0ff );
			   else	return ( 0x000 );
		      /* break; */
#endif

		case 16: return(sectran((int)d1, d2));	/* SECTRAN	*/
		      /* break; */
#if ! LOADER
		case 18: return(&memtab);		/* GMRTA	*/
		      /* break; */

		case 19: return(iobyte);		/* GETIOB	*/
		      /* break; */

		case 20: iobyte = (int)d1;		/* SETIOB	*/
			 break;

		case 21: if (flush()) return(0L);	/* FLUSH	*/
			 else	      return(0xffffL);
		      /* break; */
#endif
		case 22: return(setxvect((int)d1,d2));	/* SETXVECT	*/
		      /* break; */
#if ! LOADER
		/**********************************************************/
		/*       This function is not part of a standard BIOS.	  */
		/*	 It is included only for convenience, and will	  */
		/*	 not be supported in any way, nor will it	  */
		/* 	 necessarily be included in future versions of	  */
		/* 	 CP/M-68K					  */
		/**********************************************************/
		case 63: return( ! format((int)d1) );	/* Disk Formatter */
		      /* break; */
#endif
	
	 	default: return(0L);
			 break;

	} /* end switch */


} /* END OF BIOS */
 
 
 
/* End of C Bios */
