;==============================================================================
; Contents of this file are based on the work of Grant Searle who
; holds copyright on the original.
;    (http://searle.hostei.com/grant/index.html
; 
; Author: Rienk H. Koolstra
; BIOS starts at FA00 with 87 bytes unused. Cold startup code resides in
; alv01 - alv03.
; 
; Code includes 1 fixed and 2 mountable 8M drives, 2 serial ports and 
; one 384k Ramdrive
;
; SRAM is subdivided in 32 32kByte banks. bank 0-1 are system RAM, 
; bank 2-3 are unused (CP/M-3 system ram) bank 4-31 are used for 
; the RAM disk
;
; You have permission to use this for NON COMMERCIAL USE ONLY
; If you wish to use it elsewhere, please include an acknowledgement
; to the contributors.
;==============================================================================


ccp		equ 0DC00h	; Base of CCP
bdos		equ ccp + 0806h	; Base of BDOS.
bios		equ ccp + 1600h	; Base of BIOS.


; CP/M base page data, vector and buffer Addresses.

iobyte		equ 03h		; Intel standard I/O definition byte.
userdrv		equ 04h		; Current user number and drive.
userpath	equ 40h		; Dos+ search path buffer
tpabuf		equ 80h		; Default I/O buffer and command line storage.

CBUFSIZE	equ 20h		; 12 bytes hysteresis, 
CBUFHIGH	equ 10h		; 16 bytes overrun
CBUFLOW		equ 5h		; minimal underrun

RTS_HIGH	equ 0E8h	; bit '1' is RTS 
RTS_LOW		equ 0EAh

SIOA_D		equ 00h
SIOB_D		equ 01h
SIOA_C		equ 02h
SIOB_C		equ 03h


; CF registers
CF_DATA		equ 10h
CF_FEATURES	equ 11h
CF_ERROR	equ 11h
CF_SECCOUNT	equ 12h
CF_LBA0		equ 13h		; CF_SECTOR
CF_LBA1		equ 14h		; CF_CYL_LOW
CF_LBA2		equ 15h		; CF_CYL_HI
CF_LBA3		equ 16h		; CF_HEAD
CF_STATUS	equ 17h
CF_COMMAND	equ 17h
                         
; CF Features
CF_8BIT		equ 01h
CF_NOCACHE	equ 082h

; CF Commands
CF_READ_SEC	equ 020h
CF_WRITE_SEC	equ 030H
CF_SET_FEAT	equ 0EFH

;banked memory
BANK		equ 030H
MDISK		equ 'M' - 41h	; Ramdisk driveletter

; Text formatters
LF		equ 0AH		; line feed
CR		equ 0DH		; carriage RETurn
CLS		equ 0Ch		; clear screen (FF)
; ============================================================

		ORG	bios		; BIOS origin.

; ============================================================
; BIOS jump table.
; ============================================================
	jp boot		; 0 Initialize.
wboote:	jp wboot	; 1 Warm boot.
	jp const	; 2 Console status.
	jp conin	; 3 Console input.
	jp conout	; 4 Console output.
	jp list		; 5 List output.
	jp punch	; 6 punch output.
	jp reader	; 7 Reader input.
	jp home		; 8 Home disk.
	jp seldsk	; 9 Select disk.
	jp settrk	; 10 Select track.
	jp setsec	; 11 Select sector.
	jp setdma	; 12 Set DMA Address.
	jp read		; 13 Read 128 bytes.
	jp write	; 14 Write 128 bytes.
	jp listst	; 15 List status.
	jp sectran	; 16 Sector translate.

; ============================================================
; Disk parameter headers for disk A - C and M
; ============================================================
dpbase:	dw 0000h,0000h,0000h,0000h,dirbuf,dpbF,0000h,alv00
dpB:	dw 0000h,0000h,0000h,0000h,dirbuf,dpbF,0000h,alv01
dpC:	dw 0000h,0000h,0000h,0000h,dirbuf,dpbF,0000h,alv02
dpM:	dw 0000h,0000h,0000h,0000h,dirbuf,dpbM,0000h,alv03
	
dpbF:	; 8 MB flash disk 
	dw 128		; SPT - sectors per track
	db 5		; BSH - block shift factor
	db 31		; BLM - block mask
	db 1		; EXM - Extent mask
	dw 2043		; DSM - Storage size (blocks - 1)
	dw 511		; DRM - Number of directory entries - 1
	db 11110000B	; AL0 - 1 bit set per directory block
	db 00000000B	; AL1 -            "
	dw 0		; CKS - DIR check vector size (DRM+1)/4 (0=fixed disk)
	dw 1		; OFF - Reserved tracks	
dpbM:	; 384 kB Memory disk 32 kB 'tracks'
	dw 256		; SPT - sectors per track
	db 4		; BSH - block shift factor
	db 15		; BLM - block mask
	db 1		; EXM - Extent mask
	dw 191		; DSM - Storage size (blocks - 1)
	dw 127		; DRM - Number of directory entries - 1
	db 11000000B	; AL0 - 1 bit set per directory block
	db 00000000B	; AL1 -            "
	dw 0		; CKS - DIR check vector size (DRM+1)/4 (0=fixed disk)
	dw 4		; OFF - Reserved tracks; tracks 0-3 are system RAM
; ============================================================
; Cold boot
; ============================================================


boot:
	jp init		; located in alv1. Runs only once

; ============================================================
; Warm boot
; ============================================================

wboot:
	di		; Disable interrupts.
	ld SP,biosstack	; Set default stack.

;	set interrupt vector page
	ld A,intpage
	ld I,A

;	Load  fresh copy of the CCP

	xor A
	ld (curhsec),A	; sector = 0
	ld HL,0
	ld (curtrk),HL	; track = 0
	ld HL,mnttab	
	ld A,(HL)	; get the physical disk
	ld (curvol),A	; disk = 0 (A:)
	ld A,4
	ld (xferCnt),A	; ccp is 4 sectors (2Kb) long
	ld HL,ccp
	ld (xferAdr),HL	; destination is ccp load address
	call readhst	; perform read
	ld A,1
	ld (xferCnt),A	; default sectorcount = 1
	ld HL,hstbuf
	ld (xferAdr),HL	; default transfer address is 512 byte hstbuff

; ============================================================
; Common code for cold and warm boot
; ============================================================

gocpm:
	; set up page zero (0000 - 0100)
	ld HL,tpabuf	; Address of BIOS DMA buffer.
	ld (dmaAddr),HL

	ld A,0C3h	; Opcode for 'JP'.
	ld (00h),A	; Load at start of RAM.
	ld HL,wboote	; Address of jump for a warm boot.
	ld (01h),HL

	ld (05h),A	; Opcode for 'JP'.
	ld HL,bdos	; Address of jump for the BDOS.
	ld (06h),HL

	ld A,(userdrv)	; get current drive number
	ld C,A		; Pass drive number in C.

	im 2
	ei 		; Enable interrupts

	jp ccp		; Start CP/M by jumping to the CCP.

; ============================================================
; Console I/O routines
; ============================================================

serialInt:
	di
	push HL
	push BC
	push DE
	push AF

	; check if there is a char in channel A
	; if not, there is a char in channel B
	xor A
	ld D,A		; we need D to be zero, for later
	out (SIOA_C),A	; poll control port
	in A,(SIOA_C)	; Status byte D2=TX Buff Empty, D0=RX char ready
	rrca 		; Rotates RX status into Carry Flag,
	jr nc,cintB

	; (HL)   = buffUse
	; (HL+1) = buffer read index
	; (HL+2) = buffer write index
	; (HL+3) = dataport number
	; HL+4   = start buffer
	ld HL,cbufferA	; buffer A
	jr cintAB
cintB:	ld HL,cbufferB	; Buffer B
cintAB:	push HL		; save for later
	inc HL
	inc HL		; skip read index
	inc (HL)	; increment write index
	res 5,(HL)	; fold back at character 32
	ld E,(HL)	; DE is now 16 bit write index 
	inc HL
	ld C,(HL)	; get dataport number
	inc HL		; point to first location in buffer
	add HL,DE	; add write index
	in A,(C)	; get character from dataport
	ld (HL),A	; store character
	pop HL		; back to start
	inc (HL)	; increment bytes in buffer
	ld A,CBUFHIGH	; buffer full?
	cp (HL)
	jr c,RTSlo	; if not yet, keep as is
	ld B,RTS_HIGH	; signal DCE
	call setRTS
RTSlo:	pop AF
	pop DE
	pop BC
	pop HL
	ei
	reti


conin:
	; 00=TTY:(B), 01=CRT:(A), 10=BAT:, 11=UC1:(B)
	push HL		; save registers
	push BC
	push DE
	ld A,(iobyte)
	and 03h		; mask console
	cp 02h
	jr z,reader2	; 10 -  BAT:
	cp 01h
	jr nz, coninB	; 00,11 - TTY:, UC1:

coninA:	ld HL,cbufferA	; 01 - CRT:
	jr coninAB
coninB:	ld HL,cbufferB
coninAB:
	push HL
	xor A		; clear A
	ld D,A		; we need D to be zero, for later
ciWait	cp (HL)		; check character ready (HL) is nr of bytes in buffer)
	jr z,ciWait	; wait until there is
	di
	inc HL		; read index
	inc (HL)	; increment read index
	res 5,(HL)	; fold back at character 32
	ld E,(HL)	; DE is now 16 bit index
	inc HL		; skip write index
	inc HL
	ld C,(HL)	; get dataport
	inc HL 		; start of buffer
	add HL,DE	; add read index
	ld A,(HL)	; this is the next available character
	pop HL		; back to start
	push AF		; save input character
	dec (HL)	; decrease nr of characters in buffer
	ld A,CBUFLOW
	cp (HL)		; when buffer is (almost) empty
	jr c,RTShi
	ld B,RTS_LOW	; make sure RTS is LOW (on)
	call setRTS
RTShi:	pop AF		; get input character back
	pop DE
	pop BC
	pop HL
	ei
	ret

setRTS:	inc C		; c -> control port
	inc C
	ld A,05h	; select register 5
	out (C),A	; signal new RTS
	ld A,B
	out (C),A
	ret

; ------------------------------------------------------------
reader:	
	; 00=TTY:(B), 01=PTR:(A), 10=UR1:(B), 11=UR2:(A)
	push HL
	push BC
	push DE
reader2:
	ld A,(iobyte)
	bit 3,A		;00, 10 - TTY:, PTR:
	jr z,coninB
	jr coninA


; ------------------------------------------------------------
conout:	
	push AF	
	ld A,(iobyte)
	and 03h		; mask console
	cp 02h		; 10 - BAT:
	jr z,list2	; "BAT:" redirect
	cp 01h		; 01 - CRT:
	jr nz,conoutB1	; 00, 11 - TTY: UC1:

conoutA1:
	call CKSIOA	; See if SIO channel B is finished transmitting
	jr z,conoutA1	; Loop until SIO flag signals ready
	ld A,C
	out (SIOA_D),A	; Output the character
	pop AF
	ret
 
conoutB1:
	call CKSIOB		; See if SIO channel B is finished transmitting
	jr z,conoutB1	; Loop until SIO flag signals ready
	ld A,C
	out (SIOB_D),A	; Output the character
	pop AF
	ret


; ------------------------------------------------------------
list:
	; 00=TTY:(B), 01=CRT:(A), 10=LPT:(B), 11=UL1:(B)
	push AF
list2:	ld A,(iobyte)
	and 0C0h	; mask list
	cp 40h		; 01 - CRT:
	jr nz,conoutB1	; 00,10,11 - TTY: LPT: UL1:

	jr conoutA1


; ------------------------------------------------------------
punch:
	; 00=TTY:(B), 01=PTP:(A), 10=UP1:(B), 11=UP2:(A)
	push AF
	ld A,(iobyte)
	bit 4,A
	jr z,conoutB1
	jr conoutA1


; ------------------------------------------------------------
const:
	ld A,(iobyte)
	and 00001011b	; Mask off console and high bit of reader
	cp 00001010b	; redirected to reader on UR1/2 (Serial A)
	jr Z,constA
	cp 00000010b	; redirected to reader on TTY/RDR (Serial B)
	jr Z,constB

	and 03h		; remove the reader from the mask - only console bits then remain
	cp 01h
	jr NZ,constB

constA:
	ld A,(cUseA)
	or A
	ret z
	ld A,-1
	ret

constB:
	ld A,(cUseB)
	or A
	ret z
	ld A,-1
	ret


; ------------------------------------------------------------
listst:
	ld A,-1		; Return list status of 0xFF (ready).
	ret


; ------------------------------------------------------------
CKSIOA:
	xor A
	out (SIOA_C),A
	in A,(SIOA_C)	; Status byte D2=TX Buff Empty, D0=RX char ready
	rrca 		; Rotates RX status into Carry Flag,
	bit 1,A		; Set Zero flag if still transmitting character
	ret

CKSIOB:
	xor A
	out (SIOB_C),A
	in A,(SIOB_C)	; Status byte D2=TX Buff Empty, D0=RX char ready
	rrca 		; Rotates RX status into Carry Flag,
	bit 1,A		; Set Zero flag if still transmitting character	
	ret


; ============================================================
; Disk processing entry points
; ============================================================

seldsk:
	ld A,C
	cp MDISK
	jr z,chgdskM	; m-disk, no mount table lookup
	cp 3		; we support max 3 CF disks
	jr nc,nodisk	; if invalid drive will give BDOS error
	ld B,0		; find drive in the mount table
	ld HL,mnttab	
	add HL,BC	; point to it and
	ld A,(HL)	; get the physical disk
	ld (reqvol),A	; volume for next action
	inc A		; -1 means NO disk is mounted
	jr nz,chgdsk

nodisk:
	ld HL,$0000	; invalid DPB address
	ld A,(userdrv)	; so set the drive back to default
	cp C		; If the default disk is not the same as the
	ret nz		; selected drive then return, 
	xor A		; else reset default back to a:
	ld (userdrv),A	; otherwise will be stuck in a loop
	ret

chgdskM:
;	xor A
	ld a,0FEh
	ld (reqvol),A	; Ramdisk is volume 0
	ld HL,dpM	; point to Ramdisk parameters
	ret
chgdsk:
	ld A,C		; retrieve disk
	rlca 		; *2
	rlca 		; *4
	rlca 		; *8
	rlca 		; *16
	ld HL,dpbase
	ld B,0
	ld C,A
	add HL,BC	; hl is the new DPB address
	ret


; ------------------------------------------------------------
home:
	ld BC,0000h	; continue with settrk


; ------------------------------------------------------------
settrk:
	ld (reqtrk),BC	; Set track passed from BDOS in register BC.
	ret


; ------------------------------------------------------------
setsec:
	ld (sector),BC	; allow for 256 sectors/track
	srl B		; pre-calculate host sector
	rr C		; allow for 64 host sectors
	srl C
	ld A,C
	ld (reqhsec),A
	ret


; ------------------------------------------------------------
setdma:
	ld (dmaAddr),BC	; Set DMA Address given by registers BC.
	ret


; ------------------------------------------------------------
sectran:
	push BC
	pop HL
	ret


; ------------------------------------------------------------
read:
	call compare	; see if hostbuffer is out of date
	call nz,flush	; if so write buffer and read new block
	call setDMApars	; set parameters for DMA Xfer
	ldir		; load DMA Buffer
	xor A
	ret

readhst:	; read physical host
	ld A,(curvol)
;	or A		; M-disk = volume 0
	cp 0FEh
	jr z,readRamd	; read Ramdisk

readFlash:		; read CompactFlash disk
	call getLBAddr	; new sector to read
	call setCFpars
	call cfWait
	ld A,CF_READ_SEC
	out (CF_COMMAND),A
rdNxtSec:
	call cfWait
	inir 		; input 256 bytes
	inir 		; and another 256
	dec E		; count down sectors to transfer
	jr nz,rdNxtSec
	xor A
	ret

readRamd:		; read Ramdisk
	call setMDpars	; DE > buffer, BC > count, HL location in bank 
	ldir		; transfer data to buffer
	xor A		; select system bank
	out (BANK),A
	ret


; ------------------------------------------------------------
write:
	push BC		; save write type 0=wrall 1=wrdir, 2=wrunal
	call compare	; see if target wants to change
	call nz,flush	; if so, write buffer to curent target if dirty, 
			; make requested target the current one,
			; read target and reset dirty flag.
	call setDMApars	; set params for DMA xfer (READ)
	ex DE,HL	; swap source / destination (WRITE)
	ldir		; write in hostbuffer
	ld A,0FFh
	ld (dirty),A	; set dirty
	xor A
	pop BC		; get access type back
	dec C		; DIR access?
	ret nz		; continue if access type is wrdir

writehst:	; write physical host
	ld A,(dirty)	; buffer clean?
	or A
	ret z		; no action
	ld A,(curvol)
;	or A		; M-disk = volume 0
	cp 0FEh
	jr z,writeRamd

writeFlash:	; write Compact Flash disk
	call setCFpars	; a sector is always read first
	call cfWait
	ld A,CF_WRITE_SEC
	out (CF_COMMAND),A
wrNxtSec:
	call cfWait
	otir 		; output 256 bytes
	otir 		; and another 256
	dec E		; count down sectors to transfer
	jr nz,wrNxtSec
	xor A
	ld (dirty),A
	ret

writeRamd:	; write Ramdisk
	call setMDpars	; DE > buffer, BC > count, HL location in bank A
	ex DE,HL	; swap source - destination
	ldir		; transfer data from buffer to memory disk
	xor A		; select system bank
	out (BANK),A
	ld (dirty),A
	ret


compare:	; check hostsector, track and volume for change
	ld E,4
	ld HL,reqhsec
	ld BC,curhsec
c1:	ld A,(BC)
	cpd
	ret nz		; not the same
	dec e
	ret z		; no change
	jr c1


flush:		; update hostbuffer: write pending data, update host address,
		; read new datablock
	ld A,(dirty)	; write hostbuffer when dirty
	or A
	call nz, writehst
	ld HL,reqvol	; honour requested data
	ld DE,curvol	; make requested data current
	ld BC,4
	ldir
	jp readhst	; read new datablock


setDMApars:	; prepare for DMA transfers. direction is READ
	ld E,0
	ld A,(sector)	; get CP/M sector
	and 03		; mask lower 2 bits
	ld D,A
	srl D		; bit 1 -> bit 0; bit 0 -> CF
	rr E		; CF -> bit 7
	ld HL,(xferAdr)	; point to hostbuffer
	add HL,DE	; point to correct block
	ld DE,(dmaAddr)
	ld BC,128	; DMA buffer size
	ret


setCFpars:
	call cfWait
	ld C,CF_LBA0	; first LBA port
	ld HL,LBA0	; set first LBA
	ld B,4		; 4 to go
sl1:	outi		; output and increment HL
	jr z,sl2	; if all 4 done, exit
	inc C		; next LBA Port
	jr sl1		; output next LBA
sl2:	ld A,(xferCnt)	; number of sectors to transfer
	out (CF_SECCOUNT),A
	ld E,A		; set E to xferCount
	ld HL,(xferAdr)	; set HL to source/destination address
	ld B,0		; set B to 256
	ld C,CF_DATA	; set C to data portnumber
	ret


setMDpars:	;parameters for MD READ operation

	ld HL,(curtrk)
	ld A,L
	out (BANK),A
	ld DE,(xferAdr)
	ld BC,512
	ld A,(curhsec)	; 
	rlca		; A = hostsector * 2
	ld H,A
	ld L,0		; HL = hostsector * 512
	ret

cfWait:
	in A,(CF_STATUS)
	rlca
	jr c,cfWait
	ret


getLBAddr:	; 00Vvvvvv|vvTttttt|tttsssss
		; some serious bitshifting ahead

	ld HL,(curtrk)	; 0000000T tttttttt
	ld A,L		; tttttttt
	and 07h		; 00000ttt
	rrca 		; t00000tt
	rrca 		; tt00000t
	rrca 		; ttt00000
	ld B,A
	ld A,(curhsec)	; 000sssss
	or B		; tttsssss
	ld (LBA0),A

	ld A,L		; tttttttt
	and 0F8h	; ttttt000
	or H		; ttttt00T
	rrca 		; Tttttt00
	rrca 		; 0Tttttt0
	rrca 		; 00Tttttt
	ld B,A
	ld A,(curvol)	; Vvvvvvvv (V is used for the 128+ diskset)
	rrca 		; vVvvvvvv
	rrca 		; vvVvvvvv
	ld C,A
	and 0C0h	; vv000000
	or B		; vvTttttt
	ld (LBA1),A

	ld A,C		; vvVvvvvv
	and 3FH		; 00Vvvvvv
	ld (LBA2),A

	ret


; ------------------------------------------------------------
;	interrupt table

	org (($+1)/2)*2	; table starts on an EVEN address
 
intpage equ $/256	; intpage is vector memory page number
intvec:	equ $-(intpage*256)
	dw serialInt	; interrupt address


; ------------------------------------------------------------
; Data storage

		ds	020h	; Start of BIOS stack area.
biosstack:	equ $


; Disk mount table 
mnttab:		db	-1	; physical disk A:
		db	-1	; disk B: 
		db	-1	; disk C:


; disk actions only take place with current values
curvol:		db	-1	; current volume
curtrk:		ds	2	; current track
curhsec:	ds	1	; current host sector
sector:		ds	2	; current sector
; requested values for next disk action
reqvol:		ds	1	; requested volume
reqtrk:		ds	2	; requested track
reqhsec:	ds	1	; requested host sector

xferCnt:	ds	1	; number of sectors to transfer
xferAdr:	ds	2	; disk read/write buffer
dmaAddr:	ds	2	; last dma Address

; current LBA
LBA0:		db 0
LBA1:		db 0
LBA2:		db 0
LBA3:		db 0E0h

dirty:		db 0		; flag to indicate mem/buff not synched

cbufferA:			; SIO-A. Keep these adresses together
cUseA:		db 0		; number of characters in buffer 
coPtrA:		db 0		; location of lsat character read
ciPtrA:		db 0		; location of last character written
cSIOA:		db SIOA_D	; data port address
cBufA:		ds CBUFSIZE

cbufferB			; SIO-B. Keep these adresses together
cUseB:		db 0		; number of characters in buffer 
coPrtB:		db 0		; location of lsat character read
ciPtrB:		db 0		; location of last character written
cSIOB:		db SIOB_D	; data port address
cBufB:		ds CBUFSIZE

dirbuf:		ds	128	; scratch directory area
hstbuf:		ds	512	; 512 bytes transfer buffer
alv00:		ds	256	; allocation vectors 0 for 8 MB bootdisk A:
alv01:				; allocation vectors 1 disk B:
alv02:		equ alv01 + 256	; allocation vectors 2 disk C:
alv03:		equ alv02 + 256	; allocation vectors ramdisk M:
alvend:		equ alv03 + 56	; end of allocation space


; the rest of the code is transient, it will be overwritten once 
; the buffers alv01 - alv03 are used

; cold init data
SIOCMD:	db 00h,18h	; reset channel
	db 04h,0C4h	; set clock/64, 1 stopbit
	db 01h,18h	; set interrupt on all Rx characters
	db 03h,0E1h	; set Rx enable, 8 bits data
	db 05h,RTS_LOW	; set Tx enable, 8 bits data, DTR & RTS
	db 02h,intvec	; set interrupt vector (channel B only)

SIGNON:	db CLS,'Z80 CP/M 2.2 BIOS ver 1.19',CR,LF,LF
	db 'Based on "CP/M on breadboard" by G. Searle 2007-13',CR,LF
	db 'http://searle.hostei.com/grant',CR,LF,LF
	db 'ZSDOS v1.1 (c) 1986-8 Harold F. Bower & Cameron W. Cotrill',CR,LF
	db 'ZCPR2 (c) 1982 by Richard Conn',CR,LF,LF,0



; cold start
init:
	di		; Disable interrupts.


	ld A,0		; Set memory bank 0
	out (30h),A
	ld SP,biosstack	; Set default stack.


;	Initialise SIOs

	ld HL,SIOCMD	; initialize SIO A
	ld B,10		; SIO A uses the first 5 commands
	ld C,SIOA_C
	otir

	ld HL,SIOCMD	; initialize SIO B
	ld B,12		; SIO B uses all 6 commands
	ld C,SIOB_C	; including set interrupt vector
	otir


	; Initialize flash card
	call cfWait
	ld A,CF_8BIT		; Set IDE to be 8bit
	out (CF_FEATURES),A
	ld A,CF_SET_FEAT
	out (CF_COMMAND),A

	call cfWait
	ld A,CF_NOCACHE		; No write cache
	out (CF_FEATURES),A
	ld A,CF_SET_FEAT
	out (CF_COMMAND),A

	xor A		; Clear I/O & drive bytes.
	ld (userdrv),A
	ld (userpath),A	; Initialize ZCPR search path

	ld A,1
	ld (xferCnt),a
	ld HL,hstbuf
	ld (xferAdr),HL

	ld HL,SIGNON	; print SIGNON for finished init
	call print


	; set interrupt vector page
	ld A,intpage
	ld I,A

	im 2
	ei

	jp gocpm

print:
	ld A,(HL)	; Get character
	and 7Fh		; strip high bit and set flags
	ret z		; Return on terminator
	ld C,A
	call conout	; Print it
	inc HL		; Next Character
	jr print	; Continue until 00h

; ZCPR2 data buffers
	org 0FCD0h
zcpr_stack:
	
	org 0FD00h
ndbase:	db 50,0,0,0,0,0

	org 0FF00h
clbase:	dw clbase+4
	db 200,0,'STARTUP',0



; ============================================================
; Disable the ROM, pop the boot disk and IOBYTE from the stack 
; (supplied by monitor), then start the OS
; ============================================================
popAndRun:
	ld A,1 
	out (38h),A
	pop AF
	ld (mnttab),A
	pop AF
	ld (iobyte),A
	ld HL,mnttab
	ld (0FFFEh),HL		; locate mount table for external programs
	ld C,0
	jp bios

	org 0FFD0h
fcbadr:


; ============================================================
; Normal start CP/M vector
; ============================================================
	org 0FFEEh	; change to 0FFFEh when not using PASMO
	dw popAndRun	; this value will be overwritten with 
			; the mount table address

biosfree:	equ zcpr_stack - alvend
	end
