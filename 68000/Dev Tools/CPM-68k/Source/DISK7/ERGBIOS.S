*****************************************************************
*								*
*		CP/M-68K BIOS					*
*	Basic Input/Output Subsystem				*
*	For ERG 68000 with Tarbell floppy disk controller	*
*								*
*****************************************************************

	.globl	_init		* bios initialization entry point
	.globl	_ccp		* ccp entry point

_init:	move.l	#traphndl,$8c	* set up trap #3 handler
	clr.l	d0		* log on disk A, user 0
	rts

traphndl:
	cmpi	#nfuncs,d0
	bcc	trapng
	lsl	#2,d0		* multiply bios function by 4
	movea.l	6(pc,d0),a0	* get handler address
	jsr	(a0)		* call handler
trapng:
	rte

biosbase:
	.dc.l  _init
	.dc.l  wboot
	.dc.l  constat
	.dc.l  conin
	.dc.l  conout
	.dc.l  lstout
	.dc.l  pun
	.dc.l  rdr
	.dc.l  home
	.dc.l  seldsk
	.dc.l  settrk
	.dc.l  setsec
	.dc.l  setdma
	.dc.l  read
	.dc.l  write
	.dc.l  listst
	.dc.l  sectran
	.dc.l  setdma
	.dc.l  getseg
	.dc.l  getiob
	.dc.l  setiob
	.dc.l  flush
	.dc.l  setexc

	nfuncs=(*-biosbase)/4

wboot:	jmp	_ccp

constat: move.b	$ffff01,d0	* get status byte
	andi.w	#2,d0		* data available bit on?
	beq	noton		* branch if not
	moveq.l	#$1,d0		* set result to true
	rts

noton:	clr.l	d0		* set result to false
	rts

conin:	bsr	constat		* see if key pressed
	tst	d0
	beq	conin		* wait until key pressed
	move.b	$ffff00,d0	* get key
	and.l	#$7f,d0		* clear all but low 7 bits
	cmpi.b	#1,d0
	beq	break
	rts
break:
	trap	$f
	.dc.w	0		* return to MACSBUG
	rts

conout: move.b	$ffff01,d0	* get status
	and.b	#$1,d0		* check for transmitter buffer empty
	beq	conout		* wait until our port has aged...
	move.b	d1,$ffff00	* and output it
	rts			* and exit

lstout:	rts

pun:	rts

rdr:	rts

listst:	move.b	#$ff,d0
	rts

*
* Disk Handlers for Tarbell 1793 floppy disk controller
*
maxdsk	= 2	* this BIOS supports 2 floppy drives
dphlen	= 26	* length of disk parameter header

iobase	= $00fffff8	* Tarbell floppy disk port base address
dcmd	= iobase	* output port for command
dstat	= iobase	* input status port
dtrk	= iobase+1	* disk track port
dsect	= iobase+2	* disk sector port
ddata	= iobase+3	* disk data port
dwait	= iobase+4	* input port to wait for op finished
dcntrl	= iobase+4	* output control port for drive selection


home:	clr.b	track
	rts

seldsk:	
*	select disk given by register d1.b
	moveq	#0,d0
	cmp.b	#maxdsk,d1	* valid drive number?
	bpl	selrtn		* if no, return 0 in d0
	move.b	d1,seldrv	* else, save drive number
	lsl.b	#4,d1
	move.b	d1,selcode	* select code is 00 for drv 0, $10 for drv 1
	move.b	seldrv,d0
	mulu	#dphlen,d0
	add.l	#dph0,d0	* point d0 at correct dph
selrtn:	rts

settrk:	move.b	d1,track
	rts

setsec:	move.b	d1,sector
	rts

sectran:
*	translate sector in d1 with translate table pointed to by d2
*	result in d0
	movea.l	d2,a0
	ext.l	d1
	move.b	#0(a0,d1),d0
	ext.l	d0
	rts

setdma:
	move.l	d1,dma
	rts

read:
* Read one sector from requested disk, track, sector to dma address
* Retry if necessary, return in d0 00 if ok, else non-zero
	move.b	#10,errcnt	* set up retry counter
rretry:
	bsr	setup
	ori	#$88,d3		* OR read command with head load bit
	move.b	d3,dcmd		* output it to FDC
rloop:	btst	#7,dwait
	beq	rdone		* if end of read, exit
	move.b	ddata,(a0)+	* else, move next byte of data
	bra	rloop
rdone:
	bsr	rstatus		* get FDC status
	bne	rerror
	clr.l	d0
	rts
rerror:	bsr	errchk		* go to error handler
	subq.b	#1,errcnt
	bne	rretry
	move.l	#$ffffffff,d0
	rts

write:
* Write one sector to requested disk, track, sector from dma address
* Retry if necessary, return in d0 00 if ok, else non-zero
	move.b	#10,errcnt	* set up retry counter
wretry:
	bsr	setup
	ori	#$a8,d3		* OR write command with head load bit
	move.b	d3,dcmd		* output it to FDC
wloop:	btst	#7,dwait
	beq	wdone		* if end of read, exit
	move.b	(a0)+,ddata	* else, move next byte of data
	bra	wloop
wdone:
	bsr	rstatus		* get FDC status
	bne	werror
	clr.l	d0
	rts
werror:	bsr	errchk		* go to error handler
	subq.b	#1,errcnt
	bne	wretry
	move.l	#$ffffffff,d0
	rts

setup:
* common read and write setup code
* select disk, set track, set sector were all deferred until now
	move.b	#$d0,dcmd	* clear controller, get status
	move.b	curdrv,d3
	cmp.b	seldrv,d3
	bne	newdrive	* if drive not selected, do it
	move.b	track,d3
	cmp.b	oldtrk,d3
	bne	newtrk		* if not on right track, do it
	clr.l	d3		* if head already loaded, no head load delay
	btst	#5,dstat	* if head unloaded, treat as new disk
	bne	sexit
newdrive:
	move.b	selcode,dcntrl	* select the drive
	move.b	seldrv,curdrv
newtrk:
	bsr	chkseek		* seek to correct track if required
	moveq	#4,d3		* force head load delay
sexit:
	move.b	sector,dsect	* set up sector number
	move.b	track,dtrk	* set up track number
	move.l	dma,a0		* dma address to a0
	rts

errchk:
	btst.b	#4,d7
	bne	chkseek		* if record not found error, reseek
	rts

chkseek:
*	check for correct track, seek if necessary
	bsr	readid		* find out what track we're on
	beq	chks1		* if read id ok, skip restore code
restore:
*	home the drive and reseek to correct track
	move.b	#$0B,dcmd	* restore command to command port
rstwait:
	btst	#7,dwait
	bne	rstwait		* loop until restore completed
	btst	#2,dstat
	beq	restore		* if not at track 0, try again
	clr.l	d3		* track number returned in d3 from readid
chks1:
	move.b	d3,dtrk		* update track register in FDC
	move.b	track,oldtrk	* update oldtrk
	cmp.b	track,d3	* are we at right track?
	beq	chkdone		* if yes, exit
	move.b	track,ddata	* else, put desired track in data reg of FDC
	move.b	#$18,dcmd	*    and issue a seek command
chks2:	btst	#7,dwait
	bne	chks2		* loop until seek complete
	move.b	dstat,d3	* read status to clear FDC
chkdone:
	rts

readid:
*	read track id, return track number in d3
	move.b	#$c4,dcmd	* issue read id command
	move.b	dwait,d7	* wait for intrq
	move.b	ddata,d3	* track byte to d3
rid2:
	btst	#7,dwait
	beq	rstatus		* wait for intrq
	move.b	ddata,d7	* read another byte
	bra	rid2		* and loop
rstatus:
	move.b	dstat,d7
	andi.b	#$9d,d7		* set condition codes
	rts


flush:
	clr.l	d0		* return successful
	rts

getseg:
	move.l	#memrgn,d0	* return address of mem region table
	rts

getiob:
	rts

setiob:
	rts

setexc:
	andi.l	#$ff,d1		* do only for exceptions 0 - 255
	cmpi	#47,d1
	beq	noset		* this BIOS doesn't set Trap 15
	cmpi	#9,d1		* or Trace
	beq	noset
	lsl	#2,d1		* multiply exception nmbr by 4
	movea.l	d1,a0
	move.l	(a0),d0		* return old vector value
	move.l	d2,(a0)		* insert new vector
noset:	rts


	.data

seldrv:	.dc.b	$ff	* drive requested by seldsk
curdrv:	.dc.b	$ff	* currently selected drive

track:	.dc.b	0	* track requested by settrk
oldtrk:	.dc.b	0	* track we were on

sector:	.dc.w	0
dma:	.dc.l	0
selcode: .dc.b	0	* drive select code

errcnt:	.dc.b	10	* retry counter

memrgn:	.dc.w	1	* 1 memory region
	.dc.l	$800	* starts at 800 hex
	.dc.l	$17800	* goes until 18000 hex


* disk parameter headers

dph0:	.dc.l	xlt
	.dc.w	0	* dummy
	.dc.w	0
	.dc.w	0
	.dc.l	dirbuf	* ptr to directory buffer
	.dc.l	dpb	* ptr to disk parameter block
	.dc.l	ckv0	* ptr to check vector
	.dc.l	alv0	* ptr to allocation vector

dph1:	.dc.l	xlt
	.dc.w	0	* dummy
	.dc.w	0
	.dc.w	0
	.dc.l	dirbuf	* ptr to directory buffer
	.dc.l	dpb	* ptr to disk parameter block
	.dc.l	ckv1	* ptr to check vector
	.dc.l	alv1	* ptr to allocation vector

* disk parameter block

dpb:	.dc.w	26	* sectors per track
	.dc.b	3	* block shift
	.dc.b	7	* block mask
	.dc.b	0	* extent mask
	.dc.b	0	* dummy fill
	.dc.w	242	* disk size
	.dc.w	63	* 64 directory entries
	.dc.w	$c000	* directory mask
	.dc.w	16	* directory check size
	.dc.w	2	* track offset

* sector translate table

xlt:	.dc.b	 1, 7,13,19
	.dc.b	25, 5,11,17
	.dc.b	23, 3, 9,15
	.dc.b	21, 2, 8,14
	.dc.b	20,26, 6,12
	.dc.b	18,24, 4,10
	.dc.b	16,22


	.bss

dirbuf:	.ds.b	128	* directory buffer

ckv0:	.ds.b	16	* check vector
ckv1:	.ds.b	16

alv0:	.ds.b	32	* allocation vector
alv1:	.ds.b	32

	.end
ectory buffer

ckv0:	.ds.b	16	* check