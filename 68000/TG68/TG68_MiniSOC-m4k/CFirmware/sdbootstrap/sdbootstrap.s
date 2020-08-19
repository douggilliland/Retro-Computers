*-----------------------------------------------------------
* Program    : TG68SerialBootstrap
* Written by : Alastair M. Robinson
* Date       : 2012-06-23
* Description: Program to bootstrap the TG68 project over RS232.  Receives an S-Record.
*-----------------------------------------------------------

STACK equ $7ffffe

PERREGS equ $810000 ; Peripheral registers
SERPER equ $810002
HEX equ $810006 ; HEX display

PER_SPI equ $20
PER_SPI_BLOCKING equ $24
PER_SPI_CS equ $22
PER_TIMER_DIV7 equ $1e

CHARBUF equ $800800


;	dc.l	STACK		; Initial stack pointer
;	dc.l	START

START:				; first instruction of program
	; clear bss */
	lea.l   __s_bss,a0    
	move.l  #__e_bss,d0
l1
	cmp.l   d0,a0
	bge	  l2
	clr.l   (a0)+
	bra.s   l1
l2
	lea	STACK,a7
	move.w	#$364,SERPER
	move.w	#$2700,SR	; Disable all interrupts

	move.l	#$7ff,d7
	lea	CHARBUF,a0
.clrloop
	move.b	#$20,(a0)+
	dbf	d7,.clrloop

;	lea	.welcome,a0
;	bsr put_msg

	move.w	#0,SREC_COLUMN
	bsr	sd_start

.mainloop
	move.w	PERREGS,d0
	btst	#9,d0		; Rx intterupt?
	beq.b	.mainloop
	bsr.b	HandleByte
	bra.b	.mainloop

.welcome
	dc.b	'Testing..',0

	; FIXME - move these into character RAM for safe keeping?
SREC_BYTECOUNT	equ $ffff8
SREC_COLUMN equ $ffff6
SREC_ADDR equ $ffff2
SREC_TYPE equ $fffee
SREC_ADDRSIZE equ $fffea
SREC_COUNTER equ $fffe8 ; counts from 7 down to 0 to count the shifts required for each longword before bumping the address.


	; Stores temporary value in d6 and d7 to avoid having to read from overlaid RAM.
	
DoDecode		; Takes address of longword in A0, rotates 4 bits left and ors in the decoded nybble.
	and.l	#$df,d0	; To upper case, if necessary - numbers are now 16-25
	sub.b	#55,d0	; Map 'A' onto decimal 10.
	bpl.b	.washex		; If negative, then digit was a number.
	add.b	#39,d0	; map '0' onto 0.
.washex
;	rts
;	bsr.b	DecodeHex
;;	move.l	d7,d1
;;	lsl.l	#4,d1
;;	or.w	d0,d1
;;	move.l	d1,d7
	lsl.l	#4,d6
	or.b	d0,d6
	move.l	d6,(a0)
	rts

DoDecodeByte	; Takes address of longword in A0, rotates 4 bits left and ors in the decoded nybble.
	and.l	#$df,d0	; To upper case, if necessary - numbers are now 16-25
	sub.b	#55,d0	; Map 'A' onto decimal 10.
	bpl.b	.washex		; If negative, then digit was a number.
	add.b	#39,d0	; map '0' onto 0.
.washex
	lsl.b	#4,d7
	or.b	d0,d7
	move.b	d7,(a0)
	rts

HandleByte
	addq.w	#1,SREC_COLUMN

	cmp.b	#'S',d0		; First byte of a record is S - reset column counter.
	bne.b	.nots
	move.w	#$FFFF,HEX	; Debug
	moveq	#0,d1
	move.l	d1,d7		; Accumulator for byte values
	move.l	d1,d6		; Accumulator for longword values
	move.w	d1,SREC_COLUMN
	move.l	d1,SREC_ADDR
	move.l	d1,SREC_BYTECOUNT
	move.l	d1,SREC_TYPE
	bra.w	.end

.nots
	cmp.w	#1,SREC_COLUMN	; record type, high nybble
	bne.b	.nottype
	move.w	#$FFFE,HEX	; Debug
	lea	SREC_TYPE+3,a0
	bsr.s	DoDecodeByte	; Called once, should result in type being in the lowest nybble bye of SREC_TYPE
	move.l	SREC_TYPE,d1
	cmp.l	#3,d1
	ble.s	.dontinvert
	moveq.l	#10,d1
	sub.l	SREC_TYPE,d1 ; Just to be awkward, S7 has 32-bit addr, S8 has 24 and S9 has 16!
.dontinvert
	addq.l	#1,d1
	lsl.l	#1,d1
	move.l	d1,SREC_ADDRSIZE ; Addr_Size is now 4, 6 or 8, depending on whether the address field is 16, 24 or 32 bits long.
	bra.w	.end

.nottype
	move.w	SREC_TYPE+2,HEX	; Debug

	tst.l	SREC_TYPE
	beq.w	.end	; Ignore type 0 records
	cmp.l	#9,SREC_TYPE
	bgt.w	.nottype1 ; Type 1 2 or 3 have data

	cmp.w	#3,SREC_COLUMN	; Byte count
	bgt.b	.notbc
	lea	SREC_BYTECOUNT+3,a0
	bsr.w	DoDecodeByte	; Called twice, should result in bytecount being in the low byte of SREC_BYTECOUNT
	bra.w	.end
	
.notbc	; extract the address
	move.l	SREC_ADDRSIZE,d1
	addq.w	#3,d1
	move.w	SREC_COLUMN,d2
	cmp.w	d1,d2
	bgt.b	.notaddr
	lea	SREC_ADDR,a0
	bsr.w	DoDecode	; Called 2, 3 or 4 times, depending upon the number of address bits.
	move.w	SREC_ADDR+2,HEX
	move.w	#1,SREC_COUNTER
	bra.w	.end
.notaddr
	; Now for the actual data....
	cmp.l	#3,SREC_TYPE	; Only types 1, 2 and 3 have data...
	bgt.b	.nottype1

	move.l	SREC_BYTECOUNT,d1
	lsl.l	#1,d1	; Two characters for each output byte
	addq.l	#1,d1
	move.w	SREC_COLUMN,d2
	cmp.w	d1,d2
	bgt.b	.finishtype1

	move.l	SREC_ADDR,a0
	bsr.w	DoDecodeByte
	move.w	SREC_COUNTER,d1
	subq.w	#1,SREC_COUNTER
	subq.w	#1,d1
	bpl.b	.end
	addq.l	#1,SREC_ADDR
	move.w	#1,SREC_COUNTER
	bra.b	.end	

.finishtype1
	move.w	#$FFEF,HEX	; Debug
	move.w	SREC_COUNTER,d0
	addq.w	#1,d0
	and.w	#1,d0
	beq.b	.end
	move.l	SREC_ADDR,a0
	lsl.l	#2,d0
	lsl.B	d0,d7
	move.B	d7,(a0)
	
.nottype1
	move.w	#$FFEE,HEX	; Debug
	cmp.l	#7,SREC_TYPE
	blt.b	.end
	move.w	#$FFED,HEX	; Debug
	cmp.l	#9,SREC_TYPE
	bgt.b	.end
	move.w	#$FFEC,HEX	; Debug
	move.l	SREC_ADDR,(a7)	; Jump to the newly downloaded address...
	bclr	#0,PERREGS+4	; Disable ROM overlay
	rts			; Should be in prefetch, so will be executed even though the ROM's vanished.

.end
	rts



; SD card code, borrowed from Minimig.

_secbuf		equ			$7f000

	XREF	spi_init

sd_start:
		bsr	spi_init
		tst.b	d0
		bne	start2
      
		move.w		#$40,_drive	;Superfloppy
		bsr			_FindVolume		
       beq.s     start5
		clr.w		_drive		;1.Partition
		bsr			_FindVolume		
       bne.s     start3
       
start5
			bsr			fat_cdroot
			;d0 - LBA
			lea		mmio_name,a1
			bsr		fat_findfile
			beq.s     start3	
				
			lea		found_MM,a0
			bsr		put_msg
			move.l		#$2000,a0
			bsr		_LoadFile2
;			beq.s     start4	
;			jmp		$2000
;start4     move.w  #$60fe,$2000
;			jmp		$2000
			rts

start3			
			lea		notfound,a0
			bsr		put_msg
			rts
			
start2
	lea	.failed,a0
	bsr	put_msg

	rts
.failed
	dc.b	'SD init failed',0
     bra.s     start2

notfound   dc.b 'not ' 
found_MM   dc.b	'found '

mmio_name:	dc.b	'BOOT    SRE',0


;	A0	Stringpointer 
put_msga7
			move.l	a0,-(a7)
			move.l	8(a7),a0
			bsr	put_msg
			move.l	(a7)+,a0
			rts
put_msg
			movem.l		a0/a1,-(a7)
			move.l	textptr,d1
			lea		CHARBUF,a1
put_msg1
			move.b		(a0)+,d0
			beq			put_msg_end
			move.b		d0,(a1,d1)
			addq	#1,d1
			bra			put_msg1
put_msg_end
			add.l	#76,textptr
			movem.l	(a7)+,a0/a1
			rts

cluster				ds.b	4	;$00		; 32-bit clusters
part_fat			ds.b	4	;$04		; 32-bit start of fat
part_rootdir		ds.b	4	;$08		; 32-bit root directory address
part_cstart			ds.b	4	;$0c		; 32-bit start of clusters
part_rootdirentrys	ds.b	2	;$10		; entris in root directory
vol_fstype			ds.b	2	;$12
vol_secperclus		ds.b	2	;$14
scount				ds.b	2	;$16		; number of sectors to read
dir_is_fat16root	ds.b	4	;$18		; marker for rootdir
sector_ptr			ds.b	4	;$1c
;dir_is_fat16root	equ	$20
lba					ds.b	4	;$24
spipass 			ds.b	2	;$10000
SDHCtype			ds.b	2	

_cachevalid			ds.w	1
_cachelba			ds.l	1
_drive				ds.w	1
_fstype				ds.w	1
_rootcluster		ds.l	1
_rootsector			ds.l	1
_cluster			ds.l	1
_sectorcnt			ds.w	1
_sectorlba			ds.l	1
_attrib				ds.w	1

_volstart			ds.l	1	;start LBA of Volume
_fatstart			ds.l	1	;start LBA of first FAT table
_datastart			ds.l	1	;start LBA of data field
_clustersize		ds.w	1	;size of a cluster in blocks
_rootdirentrys		ds.w	1	;number of entry's in directory table

textptr	dc.l	76*4


	XREF	sd_read_sector
cmd_read_block:
cmd_read_sector:
	move.l	#_secbuf,-(a7)
	move.l	d0,-(a7)
	jsr	sd_read_sector
	lea	8(a7),a7
	eor.b	#1,d0
	lea	_secbuf,a0
	rts
		

_FindVolume:
		moveq		#0,d0	;partitionstable
		move.l		d0,_volstart
		bsr			cmd_read_sector
		bne.s 		_error

		lea	_secbuf,a0
		cmpi.b		#$55,$1fe(a0)
		bne.s		_error
		cmpi.b		#$AA,$1ff(a0)
		bne.s		_error
			
		move.w		_drive,d0
		and.w		#$70,d0
		cmp.w		#$40,d0
		bcc			_testfat	;Superfloppy
	
		lea			$1be(a0),a1		; pointer to partition table
		adda.w		d0,a1
		
		move.l		8(a1),d0	;LBA
		ror.w		#8,d0
		swap		d0
		ror.w		#8,d0
		move.l		d0,_volstart
		bsr			cmd_read_sector	; read sector 
		bne.s		_error
		lea	_secbuf,a0
		cmpi.b		#$55,$1fe(a0)
		bne.s		_error
		cmpi.b		#$AA,$1ff(a0)
		beq.s		_testfat

		lea	.sigfailed,a0
		bsr	put_msg
		moveq		#-1,d0
		rts
.sigfailed
		dc.b	'Failed to find signature',0
_error:
		lea	.firstfailed,a0
		bsr	put_msg
		moveq		#-1,d0
		rts
.firstfailed
		dc.b	'reading first block failed',0

fatmsg
	dc.b	'Testing for FAT filesystem',0
_testfat:
		lea	fatmsg,a0
		bsr	put_msg
		lea	_secbuf,a0
		lea	$36(a0),a0
		bsr	put_msg
		lea	_secbuf,a0
		cmpi.l		#$46415431,$36(a0)	;"FAT1"
		bne.s		_testfat_2
		move.b		#12,_fstype
		cmpi.l		#$32202020,$3A(a0)	;"2   "
		beq.s		_testfat_ex
		move.b		#16,_fstype
		cmpi.l		#$36202020,$3A(a0)	;"6   "
		beq.s		_testfat_ex
_testfat_2:
		move.b		#$00,_fstype
		cmpi.l		#$46415433,$52(a0)	;"FAT3"
		bne		_error
		cmpi.l		#$32202020,$56(a0)	;"2   "
		bne		_error
		move.b		#32,_fstype
_testfat_ex:
		move.l		$0a(a0),d0	; make sure sector size is 512
		and.l		#$FFFF00,d0
		cmpi.l		#$00200,d0
		bne		_error
		
		move.l		_volstart,d1
		move.w		$e(a0),d0		;reserved Sectors
		ror.w		#8,d0
		add.l		d0,d1
		move.l		d1,_fatstart			;Fat Table
		cmpi.b		#32,_fstype
		bne.s		 _fat16

		lea	fat32msg,a0
		bsr	put_msg
		lea _secbuf,a0		

;@fat32:
		move.l		$2c(a0),d0	; cluster of root directory
		ror.w		#8,d0
		swap		d0
		ror.w		#8,d0
		move.l		d0,_rootcluster
; find start of clusters
		move.l		$24(a0),d0	;FAT Size
		ror.w		#8,d0
		swap		d0
		ror.w		#8,d0
_add_start32		
		add.l		d0,d1
		subq.b		#1,$10(a0)
		bne.s		_add_start32
		bra.s		subcluster

fat32msg
		dc.b	'Found fat32',0
fat16msg
		dc.b	'Searching for fat16',0
		
_fat16
			lea	fat16msg,a0
			bsr	put_msg
			lea	_secbuf,a0
			moveq		#0,d0
			move.l		d0,_rootcluster
			move.w		$16(a0),d0				;Sectors per Fat
			ror.w		#8,d0
root_sect	add.l		d0,d1
			sub.b		#1,16(a0)			;number of FAT Copies
			bne			root_sect
			move.l		d1,_rootsector
	move.l	d1,d0		
			move.b		$12(a0),d0
			lsl.w		#8,d0
			move.b		$11(a0),d0
			move.w		d0,_rootdirentrys
			lsr.w		#4,d0
			add.l		d0,d1
subcluster:	
			moveq		#0,d0
			move.b		$d(a0),d0
			move.w		d0,_clustersize
			sub.l		d0,d1					; subtract two clusters to compensate
			sub.l		d0,d1					; for reserved values 0 and 1
			move.l		d1,_datastart			;start of clusters
			
fat_ex:
			moveq		#0,d0
			rts


fat_cdroot:
			move.l		_rootcluster,d0	; cluster of basic directory
			move.l		d0,_cluster	
			bne.s		 cdfat_32
		
			clr.l		_cluster
			move.w		_rootdirentrys,d0
			lsr.w			#4,d0
			move.w		d0,_sectorcnt
			move.l		_rootsector,d0
			move.l		d0,_sectorlba		;lba
			rts

cluster2lba:		
			move.l		_cluster,d0
cdfat_32:	
			move.w		_clustersize,d1
			move.w		d1,_sectorcnt
_fat32_1:		
			lsr.w			#1,d1
			bcs.s		_fat32_2
			lsl.l		#1,d0
			bra.s		_fat32_1
_fat32_2:
			add.l		_datastart,d0
			move.l		d0,_sectorlba	
			rts


		
fat_findfile
		movem.l		d2/a2,-(a7)
		move.l		a1,a2
fat_findfile_m4

		bsr			cmd_read_sector	; read sector 
		bne		fat_findfile_m8
			moveq		#15,d2
fat_findfile_m3
			tst.b	(a0)		;end
			beq.s		fat_findfile_m8
			moveq		#10,d0
fat_findfile_m2			
			move.b		(a2,d0),d1
			cmp.b		(a0,d0),d1
			beq			fat_findfile_m1
			add.b		#$20,d1		;
			cmp.b		(a0,d0),d1
			bne			fat_findfile_m9
fat_findfile_m1	
			dbra		d0,fat_findfile_m2

			moveq	#0,d0
			move.b	11(a0),d0
			move.w	d0,_attrib
			cmpi.b		#32,_fstype
			bne.s		 sfs_m3
			move.w	20(a0),d0		;high cluster
			ror.w	#8,d0
			swap	d0
sfs_m3:		move.w	26(a0),d0		;high cluster
			ror.w	#8,d0
			move.l	d0,_cluster
		movem.l		(a7)+,d2/a2
			moveq	#-1,d0
			rts


fat_findfile_m9
			adda		#$0020,a0
			dbra		d2,fat_findfile_m3		
			
			move.l 		_sectorlba,d0	
			addq.l		#1,d0		 
			move.l 		d0,_sectorlba			 

			subi.w		#1,_sectorcnt
			bne 		fat_findfile_m4
			bsr			next_cluster
			beq.s		fat_findfile_m8
			bsr			cluster2lba		
			bra			fat_findfile_m4
fat_findfile_m8			
		movem.l		(a7)+,d2/a2
			moveq		#0,d0			;file not found
			rts



_LoadFile:
;			move.l 		4(a7),a0	;Loadaddr
			
_LoadFile2:
			bsr			cluster2lba
_LoadFile1:	
			lea _secbuf,a0
			bsr			cmd_read_block
			bne.s		lferror
			
			move.l	#$200,d7
			movem.l	d0/a0,-(a7)
			move.b	(a0)+,d0
			bsr	HandleByte
			movem.l	(a7)+,d0/a0
			
			move.l 		_sectorlba,d0	
			addq.l		#1,d0		 
			move.l 		d0,_sectorlba			 

			subi.w		#1,_sectorcnt
			bne 		_LoadFile1
			bsr			next_cluster
			bne			_LoadFile2
			move.l		a0,d0
			rts
lferror:	moveq		#0,d0		
			rts
			
			
next_cluster:
		cmpi.b		#32,_fstype
		beq.s		 fnc_m32
		cmpi.b		#12,_fstype
		beq.s		 fnc_m12

;FAT16
		move.l    	_cluster,D0
		lsr.l     	#8,D0
		add.l		_fatstart,D0
		bsr			cmd_read_sector	; read sector 
		bne.s		fnc_end
		move.b    	_cluster+3,D0
		add.w		d0,d0
		move.w		(a0,d0),d0
		ror.w		#8,d0
		move.l    	D0,_cluster
		or.l		#$ffff000f,d0
		cmp.w		#$ffff,d0
		rts
fnc_m32:	
;FAT32
		move.l    	_cluster,D0
		lsr.l     	#7,D0
		add.l		_fatstart,D0
		bsr			cmd_read_sector	; read sector 
		bne.s		fnc_end
		move.b    	_cluster+3,D0
		and.w		#$7f,d0
		add.w		d0,d0
		add.w		d0,d0
		move.l		(a0,d0),d0
		ror.w		#8,d0
		swap		d0
		ror.w		#8,d0
		move.l    	D0,_cluster
		or.l		#$f0000007,d0
		cmp.l		#$ffffffff,d0
		rts
fnc_end:
		moveq		#0,d0
		rts
		

fnc_m12:	
;FAT12
		move.l		d2,-(a7)
		move.l    	_cluster,D0	;cluster
		move.l		d0,d1
		add.l		d0,d0
		add.l		d1,d0		;*3
		move.l		d0,d1		;nibbles
		lsr.l     	#8,D0		
		lsr.l     	#2,D0		;cluster*1.5/256
		add.l		_fatstart,D0
		move.l		d0,d2
		bsr			cmd_read_sector	; read sector 
		bne.s		fnc_end2
		move.l		d1,d0
		lsr.l		#1,d0
		and.w		#$1ff,d0
		cmp			#$1ff,d0
		bne			fnc_m14
		
		move.b		(a0,d0),d0
		exg.l		d0,d2
		addq.l		#1,d0
		bsr			cmd_read_sector	; read sector 
		bne.s		fnc_end2
		lsl			#8,d2
		move.b		(a0),d2
		bra.s		fnc_m15
		
fnc_m14:		
		move.b		(a0,d0),d2
		lsl			#8,d2
		move.b		1(a0,d0.w),d2
fnc_m15:
		rol.w		#8,d2
		and.w			#1,d1
		beq.s		fnc_m13
		lsr			#4,d2
fnc_m13:
		and.l		#$FFF,d2
		move.l    	D2,_cluster
		or.l		#$fffff00f,d2
		move.l		d2,d0

		move.l		(a7)+,d2
		cmp.w		#$ffff,d0
		rts

fnc_end2:
		move.l		(a7)+,d2
		moveq		#0,d0
		rts

	END	START		; last line of source

