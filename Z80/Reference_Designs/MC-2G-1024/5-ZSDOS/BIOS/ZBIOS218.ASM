; =============================================================================
; Contents of the original file are copyright Grant Searle

; http://searle.hostei.com/grant/index.html
; eMail: home.micros01@btinternet.com
;
; If these don't work, please perform an Internet search to see if I have
; updated the web page hosting service.
;
; Reworked by Rienk Koolstra
; 
; You have permission to use this for NON COMMERCIAL USE ONLY
; If you wish to use it elsewhere, please include an acknowledgement to the 
; authors.
; 
; 
; =============================================================================
; BIOS features:
; 3 8MB mountable fixed disks (A: is boot disk)
; 1 RAM disk starting at SRAM address 20000h (10000-1FFFF reserved for CP/M 3)
; 20 ms interrupt time module
; BIOS size: A00, 2560 bytes, with 148 bytes unused.
; =============================================================================


CCP		equ 0DA00h		; Base of CCP.  63k system (58k TPA)
BDOS		equ CCP + 0800h		; Base of BDOS.
BIOS		equ CCP + 1600h		; Base of BIOS.


; Set CP/M low memory data, vector and buffer Addresses.

IOBYTE		equ 03h			; Intel standard I/O definition byte.
USERDRV		equ 04h			; Current user number and drive.
USERPATH	equ 40h			; Dos+ search path buffer
TPABUF		equ 80h			; Default I/O buffer and command line
					; storage.

TDdate 		equ 40h			; days since 78/1/1 
TDhour 		equ TDdate+2		; hour, 0..23 (in BCD)
TDmin		equ TDdate+3		; minute, 0..59 (in BCD)
TDsec		equ TDdate+4		; second, 0..59 (in BCD)

SD_DATA		equ 088H
SD_CONTROL	equ 089H
SD_STATUS	equ 089H
SD_LBA0		equ 08AH
SD_LBA1		equ 08BH
SD_LBA2		equ 08CH

SD_READ		equ 00H
SD_WRITE	equ 01H

RTS_HIGH	equ 0D5H
RTS_LOW		equ 095H

ACIA0_B		EQU 07Bh	; Baud rate port
ACIA0_C		EQU 080H	; Control Port
ACIA0_D		EQU 081H	; Data Port
ACIA1_B		EQU 07Ch
ACIA1_C		EQU 082H
ACIA1_D		EQU 083H

B1200		EQU 0		; Baud Rates
B2400		EQU 1
B4800		EQU 2
B9600		EQU 3
B19200		EQU 4
B38400		EQU 5
B57600		EQU 6
B115200		EQU 7

MMU_SEL	equ 0F8h	; use 2 bits to select memory quadrant
MMU_FRM	equ 0FDh	; use 6 bits to remap SRAM page
MDISK		equ 'M' - 41h	; Ramdisk driveletter
MOFF		equ 8	; reserved tracks

; Text formatters
LF		equ 0AH			; line feed
FF		equ 0CH			; form feed
CR		equ 0DH			; carriage RETurn

; =============================================================================

	org	BIOS		; BIOS origin.

; =============================================================================
; BIOS jump table.
; =============================================================================
	jp boot			; 0 Initialize.
wboote:	jp wboot		; 1 Warm boot.
	jp const		; 2 Console status.
	jp conin  		; 3 Console input.
	jp conout		; 4 Console OUTput.
	jp list			; 5 List OUTput.
	jp punch		; 6 punch OUTput.
	jp reader		; 7 Reader input.
	jp home			; 8 Home disk.
	jp seldsk		; 9 Select disk.
	jp settrk		; 10 Select track.
	jp setsec		; 11 Select sector.
	jp setdma		; 12 Set DMA Address.
	jp read			; 13 Read 128 bytes.
	jp write		; 14 Write 128 bytes.
	jp listst		; 15 List status.
	jp sectran		; 16 Sector translate.

; =============================================================================
; Disk parameter headers for disk A - F
; =============================================================================
dpbase:	dw 0000h,0000h,0000h,0000h,dirbuf,dpbF,0000h,alv00	; A: (boot)
	dw 0000h,0000h,0000h,0000h,dirbuf,dpbF,0000h,alv01	; B:
	dw 0000h,0000h,0000h,0000h,dirbuf,dpbF,0000h,alv02	; C:
dpM:	dw 0000h,0000h,0000h,0000h,dirbuf,dpbM,0000h,alv03
	
dpbF:	dw 128		; SPT - sectors per track
	db 5		; BSH - block shift factor
	db 31		; BLM - block mask
	db 1		; EXM - Extent mask
	dw 2043		; 2047-4) DSM - Storage size (blocks - 1)
	dw 511		; DRM - Number of directory entries - 1
	db 240		; AL0 - 1 bit set per directory block
	db 0		; AL1 -            "
	dw 0		; CKS - DIR check vector size (DRM+1)/4 (0=fixed disk)
	dw 1		; OFF - Reserved tracks

dpbM:	; 896 kB Memory disk 
	dw 128		; SPT - sectors per track (16 kbyte memory block)
	db 4		; BSH - block shift factor
	db 15		; BLM - block mask
	db 0		; EXM - Extent mask
	dw 447		; DSM - Storage size (blocks - 1)
	dw 127		; DRM - Number of directory entries - 1
	db 11000000B	; AL0 - 1 bit set per directory block
	db 0		; AL1 -            "
	dw 0		; CKS - DIR check vector size (DRM+1)/4 (0=fixed disk)
	dw MOFF		; OFF - Reserved tracks; tracks first 64 k is system RAM

; =============================================================================
; Cold boot
; =============================================================================

boot:	jp run1ce	; defer to space reserved for alv01

; =============================================================================
; Warm boot
; =============================================================================

wboot:
;	di			; Disable interrupts.
	ld SP,BIOSstack		; Set default stack.


;	load fresh copy of the CCP

	xor A
	ld (curhsec),A	; sector = 0
	ld HL,0
	ld (curtrk),HL	; track = 0
	ld HL,mnttab	
	ld A,(HL)	; get the physical disk
	ld (curvol),A	; disk = 0 (A:)
	ld HL,CCP	; start address CCP
	ld (xferAdr),HL	; destination is ccp load address
wboot1:	call readhst	; perform read
	ld (xferAdr),HL	; next load address
	ld A,(curhsec)	; point to next sector
	inc A
	ld (curhsec),A
	cp 04h			; we need to load 4 sectors
	jr nz,wboot1


; =============================================================================
; Common code for cold and warm boot
; =============================================================================

gocpm:

	ld HL,hstbuf
	ld (xferAdr),HL
	ld HL,TPABUF		; Address of BIOS DMA buffer.
	ld (dmaAddr),HL
	ld A,0C3h		; Opcode for 'JP'.
	ld (00h),A		; Load at start of RAM.
	ld HL,wboote		; Address of jump for a warm boot.
	ld (01h),HL
	ld (05h),A		; Opcode for 'JP'.
	ld HL,BDOS+6		; Address of jump for the BDOS.
	ld (06h),HL
	ld (39h),A		; Opcode for 'JP'.
	ld HL,timint		; Address of jump to timer interrupt
	ld (3Ah),HL
	ld A,0F3h		; Opcode for 'DI'.
	ld (38h),A
	ld A,(USERDRV)		; Save new drive number (0).
	ld C,A			; Pass drive number in C.

	jp CCP			; Start CP/M by jumping to the CCP.

; =============================================================================
; Console I/O routines
; =============================================================================

;------------------------------------------------------------------------------
const:
	ld A,(IOBYTE)
	and 00001011b		; Mask off console and high bit of reader
	cp 00001010b		; redirected to reader on UR1/2 (Serial A)
	jr z,constA
	cp 00000010b		; redirected to reader on TTY/PTR (Serial B)
	jr z,constB	

	and 03h			; remove the reader from the mask
	cp 01h			; - only console bits then remain
	jr nz,constB		; CRT (01) = serial A
constA:				; TTY/UC1 (00/11) = serial B
	in A,(ACIA0_C)
	bit 0,A
	jr z, dataAempty
	ld A,0FFH
	ret
dataAempty:
	ld A,0
	ret

constB:
	in A,(ACIA1_C)
	bit 0,A
	jr z, dataBempty
	ld A,0FFH
	ret
dataBempty:
	xor A
	ret

;------------------------------------------------------------------------------
reader:	
	push AF
reader2: 
	ld A,(IOBYTE)
	bit 3,A			; UR1/UR2 (10/11) = serial A
	jr z,coninB		; TTY/PTR (00/01) = serial B
	jr coninA
;------------------------------------------------------------------------------
conin:
	push AF
	ld A,(IOBYTE)
	and 03h			; CRT (01) = serial A
	cp 02h			; TTY/UC1 (00/11) = serial B
	jr z,reader2		; "BAT:" redirect (10)
	cp 01h
	jr nz,coninB
	
coninA:
	pop AF
waitForCharA:
	in A,(ACIA0_C)
	bit 0,A
	jr z, waitForCharA
	in A,(ACIA0_D)
	ret			; Char ready in A

coninB:
	pop AF
waitForCharB:
	in A,(ACIA1_C)
	bit 0,A
	jr z, waitForCharB
	in A,(ACIA1_D)
	ret			; Char ready in B

;------------------------------------------------------------------------------
list:	
	push AF			; Store character
list2:
	ld A,(IOBYTE)		; CRT (01) = serial A
	and 0C0h		; TTY/LPT/UL1 (00/10/11) = serial B
	cp 40h
	jr nz,conoutB1
	jr conoutA1
;------------------------------------------------------------------------------
punch:
	push AF			; Store character
	ld A,(IOBYTE)		; UP1/UP2 (10/11) = serial A
	bit 5,A			; TTY/PTP (00/01) = serial B
	jr z,conoutB1
	jr conoutA1

;------------------------------------------------------------------------------
conout:	
	push AF			; Store character
	ld A,(IOBYTE)		; CRT (01) = serial A
	and 03h			; TTY/UC1 (00/11) = serial B
	cp 02h
	jr z,list2		; "BAT:" redirect
	cp 01h
	jr nz,conoutB1

conoutA1:
	call ckacia0		; See if SIO channel B is finished transmitting
	jr z,conoutA1		; Loop until SIO flag signals ready
	ld A,C
	out (ACIA0_D),A		; Output the character
	pop AF			; Retrieve character
	ret

conoutB1:
	call ckacia1		; See if SIO channel B is finished transmitting
	jr z,conoutB1		; Loop until SIO flag signals ready
	ld A,C
	out (ACIA1_D),A		; Output the character
	pop AF			; Retrieve character
	ret

;------------------------------------------------------------------------------
ckacia0:
	in A,(ACIA0_C)		; D2=TX Buff Empty, D0=RX char ready	
	rrca			; Rotates RX status into Carry Flag,	
	bit 0,A			; Set Zero flag if still transmitting character	
	ret

ckacia1:
	in A,(ACIA1_C)		; D2=TX Buff Empty, D0=RX char ready	
	rrca			; Rotates RX status into Carry Flag,	
	bit 0,A			; Set Zero flag if still transmitting character	
	ret

;------------------------------------------------------------------------------
listst:
	ld A,0FFh		; Return list status of 0xFF (ready).
	ret



; =============================================================================
; 20 ms interrupt service routine
; =============================================================================

timint:
	ld (svdhl),HL
	pop HL
	ld (svdret),HL
	push AF
	ld (svdsp),SP
	ld SP,lstintstk		; use local stack for interrupts
	push DE
	push BC


	; set max days in tcounter array to match current month
	ld HL,MFlag	; test for changed month value
	ld A,(HL)
	or A
	jr nz,clock	; same month, go add a tick
	dec (HL)	; reset flag (FF)
	ld HL,tcount+4	; month rollover value
	ld DE,timestr+1	; current month
	ld (HL),31h	; start with 30 days (31 is rollover value)
	ld A,(DE)	; retrieve new month
	cp 2		; is it february?
	jr z,feb	; do special treatment
	cp 8		; correct for august dayshift
	jr c,odd	; add a month between jul and aug
	inc A		; now all odd months are 31 days
odd:	rrca		; rotate bit 0 into carry flag
	jr nc,clock	; if no carry, then even. no change
	inc (HL)	; odd month has 31 days
	jr clock	; go add a tick

feb:	dec (HL)	; start with 29 days (HL) holds 30 rollover  value
	dec DE		; year locator
	ld A,(DE)	; get current year
	and 00010011b	; mask divide by 4
	jr z,clock	; hits on 00, 04 and 08 (xxx0-xx00)
	cp 00010010b
	jr z,clock	; hits on 12 and 16 	(xxx1-xx10)
	ld (HL),29h	; no leap year, store 28 days

clock:	ld DE,sec50	; Tick count
	ld HL,tcount	; rollover value per item
clk1:	call plusone	; increment items in list
	dec DE		; rollover occurred,
	inc HL		; point to next item in list
	jr clk1		; do next item
			; rolls over on year 99 in MFlag. No adverse effects

plusone:
	ld A,(DE)	; get item
	add A,1		; add one (with carry)
	daa		; make BCD
	ld (DE),A	; store it
	sub (HL)	; subtract overflow value
	jr nz,poEnd	; not zero, no rollover, finish up
	ld (DE),A	; save zero value
	ret		; continue after rollover.
poEnd:	pop BC		; no rollover, pop return address

; when the months changes, a new value needs to be inserted in the tcount array
; when a year changes, month rollover value stays 32. No action needed
	ld A,13h	; When the plusone routine exits with (HL) = 13, the 
	sub (HL)	; month number was incremented.
	jr nz, ckmon	; otherwise no action is needed.
	ld (MFlag),A	; update tcount array before next tick
ckmon:	xor A		; correct month and day to base 1
	ld HL,timestr+1	; point to current month
	cp (HL)		; if it is 0, make it 1
	jr nz,ckday
	inc (HL)
ckday:	inc HL		; same for current day
	cp (HL)
	jr nz,intEnd
	inc (HL)

intEnd:	pop BC
	pop DE
	ld SP,(svdsp)
	pop AF
	ld HL,(svdret)
	push HL
	ld HL,(svdhl)
	ei
	reti

; leap year calculation only valid 1901-2099
; MFlag = '0', indicates month tcount value needs to be updated
; tcount array holds rollover values i.e 1 higher than the max value
; all values are packed BCD

tcount:		db 50h,60h,60h,24h,32h,13h,00h,00h	; s50,ss,mm,hh,dd,mm,yy,cc
MFlag:		db 0
timestr:	db 0,1,1,0,0,0				; yy,mm,dd,hh,mm,ss
sec50:		db 25h					; 0..49 20 ms tcounter

intstk:			; local intrpt stk
	dw	0c7c7h,0c7c7h,0c7c7h,0c7c7h,0c7c7h
	dw	0c7c7h,0c7c7h,0c7c7h,0c7c7h,0c7c7h
lstintstk:
svdhl:	dw 0
svdsp:	dw 0
svdret:	dw 0


; ============================================================
; Disk processing entry points
; ============================================================

seldsk:
	ld A,C
	cp MDISK
	jr z,chgdskM	; m-disk, no mount table lookup
	cp 3		; we support max 3 flash disks
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
	ld A,(USERDRV)	; so set the drive back to default
	cp C		; If the default disk is not the same as the
	ret nz		; selected drive then return, 
	xor A		; else reset default back to a:
	ld (USERDRV),A	; otherwise will be stuck in a loop
	ret

chgdskM:
;	xor A
	ld A,0FEh
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
	ld BC,0000h


; ------------------------------------------------------------
settrk:
	ld (reqtrk),BC	; Set track passed from BDOS in register BC.
	ret


; ------------------------------------------------------------
setsec:
	ld A,C
	ld (sector),A
	rrca		; pre-calculate host sector
	rrca		; divide by 4
	and 1Fh		; clip remainder
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
	call compare	; see if buffer is out of date
	call nz,flush	; if so flush buffer and read next block
	call setDMApars	; set parameters for DMA Xfer
	ldir		; load DMA Buffer

	xor A
	ret

readhst:	; read physical host
	ld A,(curvol)
;	or A		; M-disk = volume 0
	cp 0FEh
	jr z,readRamd	; read Ramdisk
	;readFlash instead

readFlash:		;read flash disk
	call getLBAddr	; new sector to read
	call setSDpars
	ld A,SD_READ		; select SD blockread
	out (SD_CONTROL),A

rhst1:	in A,(SD_STATUS)
	cp 0E0H			; read data ready
	jr nz,rhst1
	in A,(SD_DATA)
	ld (HL),A
	inc HL
	djnz rhst1		; repeated 256 times
	dec D			; times 2
	jr nz,rhst1		; makes 512 bytes = 1 SD block
	
	xor A
	ret


readRamd:		; read Ramdisk
	ld A,1
	out (MMU_SEL),A	; select bank 1 (4000 - 7FFF)
	call setMDpars	; DE > buffer, BC > count, HL location in bank A
	out (MMU_FRM),A	; use 16 k block in A
	ldir		; transfer data to buffer
	ld A,1		; select system bank
	out (MMU_FRM),A
	xor A
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
	pop BC		; get access type back
	dec C		; DIR access?
	jr z, writehst	; if so, write buffer
	xor A
;	ld (dirty),A	; set clean
	ret

writehst:	; write physical host
	ld A,(dirty)	; buffer clean?
	or A
	ret z		; no action
	ld A,(curvol)
;	or A		; M-disk = volume 0
	cp 0FEh
	jr z,writeRamd
	; write Flash instead

writeFlash:	; write Compact Flash disk
	call setSDpars	; a sector is always read first
	ld A,SD_WRITE		; select SD blockwrite
	out (SD_CONTROL),A

whst1:	in A,(SD_STATUS)
	cp 0A0H			; write buffer empty
	jr nz,whst1
	ld A,(HL)
	out (SD_DATA),A
	inc HL
	djnz whst1		; repeated 256 times
	dec D			; times 2
	jr nz,whst1		; makes 512 bytes = 1 SD block
	
	xor A
	ld (dirty),A
	ret
	

writeRamd:	; write Ramdisk
	ld A,1
	out (MMU_SEL),A	; select page 4000-7FFF
	call setMDpars	; DE > buffer, BC > count, HL location in bank A
	ex DE,HL	; swap source - destination
	out (MMU_FRM),A	; select memory bank in A
	ldir		; transfer data from buffer to memory disk
	ld A,1		; select system bank
	out (MMU_FRM),A	
	xor A
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
	call writehst
	ld HL,reqvol	; swap to new volume/track/sector
	ld DE,curvol
	ld BC,4
	ldir
	call readhst	; read new datablock
	xor A
	ret


setDMApars:	; prepare for DMA transfers. direction is READ
	ld E,0
	ld A,(sector)	; get CP/M sector
	and 03		; mask lower 2 bits
	ld D,A
	rr D		; bit 1 -> bit 0; bit 0 -> CF
	rr E		; CF -> bit 7
	ld HL,(xferAdr)	; point to hostbuffer
	add HL,DE	; point to correct block
	ld DE,(dmaAddr)
	ld BC,128	; DMA buffer size
	ret


setSDpars:
	ld A,(LBA2)
	out (SD_LBA2),A
	ld A,(LBA1)
	out (SD_LBA1),A
sl1:	in A,(SD_STATUS)	; wait till SD is ready...
	cp 080H
	jr nz,sl1
	ld A,(LBA0)
	out (SD_LBA0),A
	ld HL,(xferAdr)	; set HL to source/destination address
	ld B,0		; set B to 256
	ld D,2		; times 2 = 512 bytes blocksize
	ret


setMDpars:	; parameters for MD READ operation
		; memory quadrant 2 is used to prevent interrupt interference
	ld DE,(xferAdr)	; destination
	ld BC,512	; length
	ld A,(curhsec)	; 000sssss
	or 20h		; 001sssss
	rlca		; times 2
	ld H,A		; times 256 -> 512
	ld L,0		; HL is byte address in page 2
	ld A,(curtrk)	; track and SRAM page are the same
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


; =============================================================================
; Data storage
; =============================================================================

	ds 020h			; Start of BIOS stack area.
BIOSstack: equ	$
;
; Disk mount table 
mnttab:	db -1			; volume for disk A: to be filled in on cold boot
	db -1			; volume for disk B:
	db -1			; volume for disk C:

; disk actions only take place with current values
curvol:		db	-1	; current volume, force first disk read
curtrk:		ds	2	; current track
curhsec:	ds	1	; current host sector
sector:		ds	1	; current sector
; requested values for next disk action
reqvol:		ds	1	; requested volume
reqtrk:		ds	2	; requested track
reqhsec:	ds	1	; requested host sector

xferAdr:	ds	2	; disk read/write buffer
dmaAddr:	ds	2	; last dma Address

; current LBA
LBA0:		db 0
LBA1:		db 0
LBA2:		db 0
;LBA3:		db 0

dirty:		db 0		; flag to indicate mem/buff not synched
 
dirbuf:		ds	128	; scratch directory area
hstbuf:		ds	512	; 512 bytes transfer buffer
alv00:		ds	256	; allocation vectors 0 for 8 MB bootdisk A:
alv01:				; allocation vectors 1 disk B:
alv02:		equ alv01 + 256	; allocation vectors 2 disk C:
alv03:		equ alv02 + 256	; allocation vectors ramdisk M:
alvend:		equ alv03 + 56	; end of allocation space


run1ce:				; destroyed when C: or M: is accessed
	di			; Disable interrupts.
	ld b,4
	xor A
bank0:	out (MMU_SEL),A		; select memory bank 0
	out (MMU_FRM),A
	inc A
	djnz bank0
	
	ld SP,BIOSstack		; Set default stack.

	ld A,RTS_LOW
	out (ACIA0_C),A		; Initialise ACIA0
	out (ACIA1_C),A		; Initialise ACIA1

	LD A,B115200		; select baudrate
	OUT (ACIA0_B),A
	OUT (ACIA1_B),A	

	call print
	db FF,'Z80 CP/M BIOS 2.20',CR,LF
	db 'Based on MULTICOMP by G. Searle 2007-13',CR,LF
	db 'http://searle.hostei.com/grant/Multicomp',CR,LF,LF
	db 'ZSDOS v1.1 (c) 1986-8 Harold F. Bower & Cameron W. Cotrill',CR,LF
	db 'ZCPR2 (c) 1982 by Richard Conn',CR,LF,LF,0


	xor A			; Clear I/O & drive bytes.
	ld (USERDRV),A
	ld (USERPATH),A		; Initialize Dos+ search path

	ld HL,hstbuf
	ld (xferAdr),HL

	ld A,0F3h		; set up interrupt service routine
	ld (38h),A		; entry point in RST 7 location
	ld A,0C3h
	ld (39h),A
	ld HL,timint
	ld (3Ah),HL


; test SRAM size
	ld A,1
	out (MMU_SEL),A
	ld A,32			; address second SRAM chip
	out (MMU_FRM),A
	ld HL,4100h		; arbitrary address
	ld (HL),A		; write something
	cp (HL)			; read it back
	jr Z,sizeOK		; if the same, second SRAM is present
	ld A,0C0h		; if not, modify dpbM
	ld (dpbM+5),A		; DSM = 192
	xor A
	ld (dpbM+6),A
	inc A
	ld (dpbM+4),A		; EXM = 1
sizeOK:	ld A,1
	out (MMU_SEL),A		; restore system memory
	out (MMU_FRM),A

	im 1			; interrupt mode 1
	ei			; start clock

	jp gocpm		; skip re-loading CCP

print:	xor A
	pop HL
	ld C,(HL)
	inc HL
	push HL
	cp C
	ret z
	call conout
	jr print
				
; Disable the ROM, pop the boot disk and IOBYTE from the stack 
; (supplied by monitor), then start the OS
;	org 0FFB0h
popAndRun:
	ld A,01h 
	out (38h),A		; kick ROM

	pop AF			; Monitor gives physical bootvolume
	ld (mnttab),A		; ignore 8 bit volume number

	pop AF			; Monitor gives the IOBYTE ...
	ld (IOBYTE),A


	ld HL,mnttab
	ld (0FFFEh),HL		; put mounttab vector in FFFE
	ld HL,timestr
	ld (0FFFCh),HL		; put time string vector in FFFC
	ld C,0
	jp BIOS

; ZCPR2/SDDOS data buffers
	org 0F9D0h
zcpr_stack:			; external stack

	org 0FA00h
LDTIM:				; clock driver/stamper module

	org 0FD00h
ndbase:	db 50,0,0,0,0,0		; named directories

	org 0FF00h
clbase:	dw clbase+4		; multiple command buffer
	db 200,0,'STARTUP',0	; initial command

	org 0FFD0h
fcbadr:				; external FCB


; =============================================================================
; Normal start CP/M vector
; =============================================================================

;	org 0FFFEh		; this is the correct address,
	org 0FFEEH		; but pasmo has a problem with hexfiles 
				; above FFEF. Then use this and edit hexfile
	dw popAndRun 
biosfree:	equ zcpr_stack - alvend

	end
