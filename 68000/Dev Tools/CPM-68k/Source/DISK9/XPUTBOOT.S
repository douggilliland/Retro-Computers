*********************************************************
*							*
*	Program to Write Boot Tracks for CP/M-68K (tm)	*
*							*
*	Copyright Digital Research 1982			*
*							*
*********************************************************
*
*
*
prntstr	=	9	BDOS Functions
dseldsk	=	14
open	=	15
readseq	=	20
dsetdma	=	26
*
seldsk	=	9	BIOS Functions
settrk	=	10
setsec	=	11
isetdma	=	12
write	=	14
sectran	=	16
flush	=	21
*
bufcnt	=	$80
bufsize	=	$80*bufcnt
*
	.text
*
start:	link	a6,#0
	move.l	8(a6),a0	base page address
	lea	$5c(a0),a1
	move.l	a1,fcb
	clr.b	hflag
	add	#$81,a0		first character of command tail
scan:	cmpi.b	#$20,(a0)+	skip over blanks
	beq	scan
	sub.l	#1,a0
scan1:	tst.b	(a0)
	beq	erxit
	cmpi.b	#$2d,(a0)+	check for -H flag
	bne	nohyph
	cmpi.b	#$48,(a0)+
	bne	erxit
	tst.b	hflag
	bne	erxit
	move.b	#$ff,hflag
	sub.l	#$24,fcb	change to 2nd default fcb
	bra	scan
nohyph:	cmpi.b	#$20,(a0)
	bne	scan1
scan2:	cmpi.b	#$20,(a0)+
	beq	scan2
	cmpi.b	#$61,-(a0)	get disk letter
	blt	upper		upshift
	sub	#$20,(a0)
upper:	cmpi.b	#$41,(a0)	compare with range A - P
	blt	erxit
	cmpi.b	#$50,(a0)
	bgt	erxit
	move.b	(a0),d0
	ext.w	d0		put disk letter into range 0 - 15
	sub.w	#$41,d0
	move.w	d0,dsk
*
*	open file to copy
*
	move.w	#open,d0
	move.l	fcb,d1
	trap	#2
	cmpi.w	#$00ff,d0
	bne	openok
	move.l	#opnfl,d1
	jmp	erx
openok:	move.l	fcb,a0
	clr.b	32(a0)
*
*	read
*
	move.l	#buf,d2
	clr.w	count
rloop:	move.w	#dsetdma,d0
	move.l	d2,d1
	trap	#2
	move.w	#readseq,d0
	move.l	fcb,d1
	trap	#2
	tst.w	d0
	bne	wrtout
	add.l	#128,d2
	add.w	#1,count
	cmpi.w	#bufcnt,count
	bgt	bufoflx
	bra	rloop
*
*	write
*
wrtout:	move.w	#seldsk,d0	select the disk
	move.w	dsk,d1
	clr.b	d2
	trap	#3
	tst.l	d0		check for select error
	beq	selerx
	move.l	d0,a0
	move.l	14(a0),a0	get DPB address
	move.w	(a0),spt	get sectors per track
	move.w	14(a0),off	get offset
	clr.w	trk		start at trk 0
	move.w	#1,sect		start at sector 1
	lea	buf,a0
	tst.b	hflag
	bne	wrt1
	cmpi.w	#$601a,(a0)
	bne	wrt1
	add.l	#28,a0
wrt1:	move.l	a0,bufp
*
wloop:	tst.w	count
	beq	exit
move.w	sect,d1		check for end-of-track
	cmp.w	spt,d1
	ble	sok
	move.w	#1,sect		advance to new track
	move.w	trk,d0
	add.w	#1,d0
	move.w	d0,trk
	cmp.w	off,d0
	bge	oflex
sok:	move.w	#settrk,d0	set the track
	move.w	trk,d1
	trap	#3
	move.w	sect,d1		set sector
	move.w	#setsec,d0
	trap	#3
	move.w	#isetdma,d0	set up dma address for write
	move.l	bufp,d1
	trap	#3
	move.w	#write,d0	and write
	clr.w	d1
	trap	#3
	tst.w	d0		check for write error
	bne	wrterx
	add	#1,sect		increment sector number
	sub	#1,count
	add.l	#128,bufp
	bra	wloop
*
exit:	move.w	#flush,d0	exit location - flush bios buffers
	trap	#3
	unlk	a6
	rts			and exit to CCP
*
erxit:	move.l	#erstr,d1	miscellaneous errors
erx:	move.w	#prntstr,d0	print error message and exit
	trap	#2
	bra	exit
*
selerx:	move.l	#selstr,d1	disk select error
	bra	erx
wrterx:	move.l	#wrtstr,d1	disk write error
	bra	erx
bufoflx: move.l	#bufofl,d1	buffer overflow
	bra	erx
oflex:	move.l	#trkofl,d1
	bra	erx
*
*
	.bss
*
	.even
*
buf:	.ds.b	bufsize+128
*
fcb:	.ds.l	1		fcb address
spt:	.ds.w	1		sectors per track
sect:	.ds.w	1		current sector
trk:	.ds.w	1		current track
dsk:	.ds.w	1		selected disk
off:	.ds.w	1		1st track of non-boot area
count:	.ds.w	1
bufp:	.ds.l	1
hflag:	.ds.b	1
*
	.data
*
erstr:	.dc.b	'Invalid Command Line',13,10,'$'
selstr:	.dc.b	'Select Error',13,10,'$'
wrtstr:	.dc.b	'Write Error',13,10,'$'
opnfl:	.dc.b	'Cannot Open Source File',13,10,'$'
bufofl:	.dc.b	'Buffer Overflow',13,10,'$'
trkofl:	.dc.b	'Too Much Data for System Tracks',13,10,'$'
*
*
	.end
,13,10,'$'
bufofl:	.dc.b	'Buffer Overflow',13,10,'$'
trkofl:	.dc.b	'Too Much Data for System Tracks',