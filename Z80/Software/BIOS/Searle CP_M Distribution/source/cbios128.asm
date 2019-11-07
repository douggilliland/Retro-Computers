;==================================================================================
; Contents of this file are copyright Grant Searle
; Blocking/unblocking routines are the published version by Digital Research
; (bugfixed, as found on the web)
;
; You have permission to use this for NON COMMERCIAL USE ONLY
; If you wish to use it elsewhere, please include an acknowledgement to myself.
;
; http://searle.hostei.com/grant/index.html
;
; eMail: home.micros01@btinternet.com
;
; If the above don't work, please perform an Internet search to see if I have
; updated the web page hosting service.
;
;==================================================================================

ccp		.EQU	0D000h		; Base of CCP.
bdos		.EQU	ccp + 0806h	; Base of BDOS.
bios		.EQU	ccp + 1600h	; Base of BIOS.

; Set CP/M low memory datA, vector and buffer addresses.

iobyte		.EQU	03h		; Intel standard I/O definition byte.
userdrv		.EQU	04h		; Current user number and drive.
tpabuf		.EQU	80h		; Default I/O buffer and command line storage.


SD_DATA		.EQU	088H
SD_CONTROL	.EQU	089H
SD_STATUS	.EQU	089H
SD_LBA0		.EQU	08AH
SD_LBA1		.EQU	08BH
SD_LBA2		.EQU	08CH

RTS_HIGH	.EQU	0D5H
RTS_LOW		.EQU	095H

ACIA0_D		.EQU	$81
ACIA0_C		.EQU	$80
ACIA1_D		.EQU	$83
ACIA1_C		.EQU	$82

nmi		.EQU	66H

blksiz		.equ	4096		;CP/M allocation size
hstsiz		.equ	512		;host disk sector size
hstspt		.equ	32		;host disk sectors/trk
hstblk		.equ	hstsiz/128	;CP/M sects/host buff
cpmspt		.equ	hstblk * hstspt	;CP/M sectors/track
secmsk		.equ	hstblk-1	;sector mask
					;compute sector mask
;secshf		.equ	2		;log2(hstblk)

wrall		.equ	0		;write to allocated
wrdir		.equ	1		;write to directory
wrual		.equ	2		;write to unallocated

LF		.EQU	0AH		;line feed
FF		.EQU	0CH		;form feed
CR		.EQU	0DH		;carriage RETurn

;================================================================================================

		.ORG	bios		; BIOS origin.

;================================================================================================
; BIOS jump table.
;================================================================================================
		JP	boot		;  0 Initialize.
wboote:		JP	wboot		;  1 Warm boot.
		JP	const		;  2 Console status.
		JP	conin		;  3 Console input.
		JP	conout		;  4 Console OUTput.
		JP	list		;  5 List OUTput.
		JP	punch		;  6 punch OUTput.
		JP	reader		;  7 Reader input.
		JP	home		;  8 Home disk.
		JP	seldsk		;  9 Select disk.
		JP	settrk		; 10 Select track.
		JP	setsec		; 11 Select sector.
		JP	setdma		; 12 Set DMA ADDress.
		JP	read		; 13 Read 128 bytes.
		JP	write		; 14 Write 128 bytes.
		JP	listst		; 15 List status.
		JP	sectran		; 16 Sector translate.

;================================================================================================
; Disk parameter headers for disk 0 to 15
;================================================================================================
dpbase:
	 	.DW 0000h,0000h,0000h,0000h,dirbuf,dpb0,0000h,alv00
	 	.DW 0000h,0000h,0000h,0000h,dirbuf,dpb,0000h,alv01
	 	.DW 0000h,0000h,0000h,0000h,dirbuf,dpb,0000h,alv02
	 	.DW 0000h,0000h,0000h,0000h,dirbuf,dpb,0000h,alv03
	 	.DW 0000h,0000h,0000h,0000h,dirbuf,dpb,0000h,alv04
	 	.DW 0000h,0000h,0000h,0000h,dirbuf,dpb,0000h,alv05
	 	.DW 0000h,0000h,0000h,0000h,dirbuf,dpb,0000h,alv06
	 	.DW 0000h,0000h,0000h,0000h,dirbuf,dpb,0000h,alv07
	 	.DW 0000h,0000h,0000h,0000h,dirbuf,dpb,0000h,alv08
	 	.DW 0000h,0000h,0000h,0000h,dirbuf,dpb,0000h,alv09
	 	.DW 0000h,0000h,0000h,0000h,dirbuf,dpb,0000h,alv10
	 	.DW 0000h,0000h,0000h,0000h,dirbuf,dpb,0000h,alv11
	 	.DW 0000h,0000h,0000h,0000h,dirbuf,dpb,0000h,alv12
	 	.DW 0000h,0000h,0000h,0000h,dirbuf,dpb,0000h,alv13
	 	.DW 0000h,0000h,0000h,0000h,dirbuf,dpb,0000h,alv14
	 	.DW 0000h,0000h,0000h,0000h,dirbuf,dpb,0000h,alv15

; First drive has a reserved track for CP/M
dpb0:
		.DW 128 ;SPT - sectors per track
		.DB 5   ;BSH - block shift factor
		.DB 31  ;BLM - block mask
		.DB 1   ;EXM - Extent mask
		.DW 2043 ; (2047-4) DSM - Storage size (blocks - 1)
		.DW 511 ;DRM - Number of directory entries - 1
		.DB 240 ;AL0 - 1 bit set per directory block
		.DB 0   ;AL1 -            "
		.DW 0   ;CKS - DIR check vector size (DRM+1)/4 (0=fixed disk)
		.DW 1   ;OFF - Reserved tracks

dpb:
		.DW 128 ;SPT - sectors per track
		.DB 5   ;BSH - block shift factor
		.DB 31  ;BLM - block mask
		.DB 1   ;EXM - Extent mask
		.DW 2047 ;DSM - Storage size (blocks - 1)
		.DW 511 ;DRM - Number of directory entries - 1
		.DB 240 ;AL0 - 1 bit set per directory block
		.DB 0   ;AL1 -            "
		.DW 0   ;CKS - DIR check vector size (DRM+1)/4 (0=fixed disk)
		.DW 0   ;OFF - Reserved tracks

;================================================================================================
; Cold boot
;================================================================================================

boot:
		DI				; Disable interrupts.
		LD	SP,biosstack		; Set default stack.

;		Turn off ROM

		LD	A,$01
		OUT ($38),A

	   LD        A,RTS_LOW
	   OUT       (ACIA0_C),A         ; Initialise ACIA0
	   OUT       (ACIA1_C),A         ; Initialise ACIA1

		CALL	printInline
		.DB FF
		.TEXT "CP/M BIOS 2.0 by G. Searle 2013"
		.DB CR,LF
		.DB CR,LF
		.TEXT "CP/M 2.2 "
		.TEXT	"(c)"
		.TEXT	" 1979 by Digital Research"
		.DB CR,LF,0

		; CALL sdPreamble??

		XOR	a				; Clear I/O & drive bytes.
		LD	(userdrv),A
		JP	gocpm

;================================================================================================
; Warm boot
;================================================================================================

wboot:
		DI				; Disable interrupts.
		LD	SP,biosstack		; Set default stack.

		LD	B,11 ; Number of sectors to reload

		LD	A,0
		LD	(hstsec),A
		OUT	(SD_LBA2),A
		OUT	(SD_LBA1),A

		LD 	HL,ccp

wbRdAllSecs:

wBrdWait1: IN	A,(SD_STATUS)
		CP	128
		JR	NZ,wBrdWait1
		
		LD	A,(hstsec)
		OUT	(SD_LBA0),A
		
		LD	A,$00	; 00 = Read block
		OUT	(SD_CONTROL),A
		PUSH BC
		
		LD 	c,4
wBrd4secs:
		LD 	b,128
wBrdByte:

wBrdWait2: IN	A,(SD_STATUS)
		CP	224	; Read byte waiting
		JR	NZ,wBrdWait2

		IN	A,(SD_DATA)

		LD 	(HL),A
		INC 	HL
		dec 	b
		JR 	NZ, wBrdByte

		dec 	c
		JR 	NZ,wBrd4secs

		LD	A,(hstsec)
		INC	A
		LD	(hstsec),A

		POP BC

		DJNZ	wbRdAllSecs
;================================================================================================
; Common code for cold and warm boot
;================================================================================================

gocpm:
		xor	a			;0 to accumulator
		ld	(hstact),a		;host buffer inactive
		ld	(unacnt),a		;clear unalloc count

		LD	HL,tpabuf		; Address of BIOS DMA buffer.
		LD	(dmaAddr),HL
		LD	A,0C3h			; Opcode for 'JP'.
		LD	(00h),A			; Load at start of RAM.
		LD	HL,wboote		; Address of jump for a warm boot.
		LD	(01h),HL
		LD	(05h),A			; Opcode for 'JP'.
		LD	HL,bdos			; Address of jump for the BDOS.
		LD	(06h),HL
		LD	A,(userdrv)		; Save new drive number (0).
		LD	c,A			; Pass drive number in C.

		JP	ccp			; Start CP/M by jumping to the CCP.

;================================================================================================
; Console I/O routines
;================================================================================================


;------------------------------------------------------------------------------------------------
const:
		LD	A,(iobyte)
		AND	00001011b ; Mask off console and high bit of reader
		CP	00001010b ; redirected to reader on UR1/2 (Serial A)
		JR	Z,constA
		CP	00000010b ; redirected to reader on TTY/RDR (Serial B)
		JR	Z,constB

		AND	$03 ; remove the reader from the mask - only console bits then remain
		CP	$01
		JR	NZ,constB
constA:
		IN   A,(ACIA0_C)		; Status byte
		AND  $01
		CP   $0			; Z flag set if no char
		JR	Z, dataAEmpty
 		LD	A,0FFH
		RET
dataAEmpty:
		LD	A,0
        RET


constB:
		IN   A,(ACIA1_C)		; Status byte
		AND  $01
		CP   $0			; Z flag set if no char
		JR	Z, dataBEmpty
 		LD	A,0FFH
		RET
dataBEmpty:
		LD	A,0
        RET

;------------------------------------------------------------------------------------------------
reader:		
		PUSH	AF
reader2:	LD	A,(iobyte)
		AND	$08
		CP	$08
		JR	NZ,coninB
		JR	coninA
;------------------------------------------------------------------------------------------------
conin:
		PUSH	AF
		LD	A,(iobyte)
		AND	$03
		CP	$02
		JR	Z,reader2	; "BAT:" redirect
		CP	$01
		JR	NZ,coninB
		

coninA:
		POP	AF
waitForCharA:
		IN   A,(ACIA0_C)		; Status byte
		AND  $01
		CP   $0			; Z flag set if no char
		JR	Z, waitForCharA
		IN  A,(ACIA0_D)

		RET			; Char ready in A


coninB:
		POP	AF
waitForCharB:
		IN   A,(ACIA1_C)		; Status byte
		AND  $01
		CP   $0			; Z flag set if no char
		JR	Z, waitForCharB
		IN  A,(ACIA1_D)

		RET			; Char ready in A

;------------------------------------------------------------------------------------------------
list:		PUSH	AF		; Store character
list2:		LD	A,(iobyte)
		AND	$C0
		CP	$40
		JR	NZ,conoutB1
		JR	conoutA1

;------------------------------------------------------------------------------------------------
punch:		PUSH	AF		; Store character
		LD	A,(iobyte)
		AND	$20
		CP	$20
		JR	NZ,conoutB1
		JR	conoutA1

;------------------------------------------------------------------------------------------------
conout:		PUSH	AF
		LD	A,(iobyte)
		AND	$03
		CP	$02
		JR	Z,list2		; "BAT:" redirect
		CP	$01
		JR	NZ,conoutB1

conoutA1:	CALL	CKACIA0		; See if ACIA channel A is finished transmitting
		JR	Z,conoutA1	; Loop until ACIA flag signals ready
		LD	A,C
		OUT	(ACIA0_D),A	; OUTput the character
		POP	AF
		RET

conoutB1:	CALL	CKACIA1		; See if ACIA channel B is finished transmitting
		JR	Z,conoutB1	; Loop until ACIA flag signals ready
		LD	A,C
		OUT	(ACIA1_D),A	; OUTput the character
		POP	AF
		RET

;------------------------------------------------------------------------------------------------
CKACIA0
		IN   	A,(ACIA0_C)	; Status byte D1=TX Buff Empty, D0=RX char ready	
		RRCA			; Rotates RX status into Carry Flag,	
		BIT  	0,A		; Set Zero flag if still transmitting character	
        RET

CKACIA1
		IN   	A,(ACIA1_C)	; Status byte D1=TX Buff Empty, D0=RX char ready	
		RRCA			; Rotates RX status into Carry Flag,	
		BIT  	0,A		; Set Zero flag if still transmitting character	
        RET

;------------------------------------------------------------------------------------------------
listst:		LD	A,$FF		; Return list status of 0xFF (ready).
		RET

;================================================================================================
; Disk processing entry points
;================================================================================================

seldsk:
		LD	HL,$0000
		LD	A,C
		CP	16		; 16 for 128MB disk, 8 for 64MB disk
		jr	C,chgdsk	; if invalid drive will give BDOS error
		LD	A,(userdrv)	; so set the drive back to a:
		CP	C		; If the default disk is not the same as the
		RET	NZ		; selected drive then return, 
		XOR	A		; else reset default back to a:
		LD	(userdrv),A	; otherwise will be stuck in a loop
		LD	(sekdsk),A
		ret

chgdsk:		LD 	(sekdsk),A
		RLC	a		;*2
		RLC	a		;*4
		RLC	a		;*8
		RLC	a		;*16
		LD 	HL,dpbase
		LD	b,0
		LD	c,A	
		ADD	HL,BC

		RET

;------------------------------------------------------------------------------------------------
home:
		ld	a,(hstwrt)	;check for pending write
		or	a
		jr	nz,homed
		ld	(hstact),a	;clear host active flag
homed:
		LD 	BC,0000h

;------------------------------------------------------------------------------------------------
settrk:		LD 	(sektrk),BC	; Set track passed from BDOS in register BC.
		RET

;------------------------------------------------------------------------------------------------
setsec:		LD 	(seksec),BC	; Set sector passed from BDOS in register BC.
		RET

;------------------------------------------------------------------------------------------------
setdma:		LD 	(dmaAddr),BC	; Set DMA ADDress given by registers BC.
		RET

;------------------------------------------------------------------------------------------------
sectran:	PUSH 	BC
		POP 	HL
		RET

;------------------------------------------------------------------------------------------------
read:
		;read the selected CP/M sector
		xor	a
		ld	(unacnt),a
		ld	a,1
		ld	(readop),a		;read operation
		ld	(rsflag),a		;must read data
		ld	a,wrual
		ld	(wrtype),a		;treat as unalloc
		jp	rwoper			;to perform the read


;------------------------------------------------------------------------------------------------
write:
		;write the selected CP/M sector
		xor	a		;0 to accumulator
		ld	(readop),a	;not a read operation
		ld	a,c		;write type in c
		ld	(wrtype),a
		cp	wrual		;write unallocated?
		jr	nz,chkuna	;check for unalloc
;
;		write to unallocated, set parameters
		ld	a,blksiz/128	;next unalloc recs
		ld	(unacnt),a
		ld	a,(sekdsk)		;disk to seek
		ld	(unadsk),a		;unadsk = sekdsk
		ld	hl,(sektrk)
		ld	(unatrk),hl		;unatrk = sectrk
		ld	a,(seksec)
		ld	(unasec),a		;unasec = seksec
;
chkuna:
;		check for write to unallocated sector
		ld	a,(unacnt)		;any unalloc remain?
		or	a	
		jr	z,alloc		;skip if not
;
;		more unallocated records remain
		dec	a		;unacnt = unacnt-1
		ld	(unacnt),a
		ld	a,(sekdsk)		;same disk?
		ld	hl,unadsk
		cp	(hl)		;sekdsk = unadsk?
		jp	nz,alloc		;skip if not
;
;		disks are the same
		ld	hl,unatrk
		call	sektrkcmp	;sektrk = unatrk?
		jp	nz,alloc		;skip if not
;
;		tracks are the same
		ld	a,(seksec)		;same sector?
		ld	hl,unasec
		cp	(hl)		;seksec = unasec?
		jp	nz,alloc		;skip if not
;
;		match, move to next sector for future ref
		inc	(hl)		;unasec = unasec+1
		ld	a,(hl)		;end of track?
		cp	cpmspt		;count CP/M sectors
		jr	c,noovf		;skip if no overflow
;
;		overflow to next track
		ld	(hl),0		;unasec = 0
		ld	hl,(unatrk)
		inc	hl
		ld	(unatrk),hl		;unatrk = unatrk+1
;
noovf:
		;match found, mark as unnecessary read
		xor	a		;0 to accumulator
		ld	(rsflag),a		;rsflag = 0
		jr	rwoper		;to perform the write
;
alloc:
		;not an unallocated record, requires pre-read
		xor	a		;0 to accum
		ld	(unacnt),a		;unacnt = 0
		inc	a		;1 to accum
		ld	(rsflag),a		;rsflag = 1

;------------------------------------------------------------------------------------------------
rwoper:
		;enter here to perform the read/write
		xor	a		;zero to accum
		ld	(erflag),a		;no errors (yet)
		ld	a,(seksec)		;compute host sector
		or	a		;carry = 0
		rra			;shift right
		or	a		;carry = 0
		rra			;shift right
		ld	(sekhst),a		;host sector to seek
;
;		active host sector?
		ld	hl,hstact	;host active flag
		ld	a,(hl)
		ld	(hl),1		;always becomes 1
		or	a		;was it already?
		jr	z,filhst		;fill host if not
;
;		host buffer active, same as seek buffer?
		ld	a,(sekdsk)
		ld	hl,hstdsk	;same disk?
		cp	(hl)		;sekdsk = hstdsk?
		jr	nz,nomatch
;
;		same disk, same track?
		ld	hl,hsttrk
		call	sektrkcmp	;sektrk = hsttrk?
		jr	nz,nomatch
;
;		same disk, same track, same buffer?
		ld	a,(sekhst)
		ld	hl,hstsec	;sekhst = hstsec?
		cp	(hl)
		jr	z,match		;skip if match
;
nomatch:
		;proper disk, but not correct sector
		ld	a,(hstwrt)		;host written?
		or	a
		call	nz,writehst	;clear host buff
;
filhst:
		;may have to fill the host buffer
		ld	a,(sekdsk)
		ld	(hstdsk),a
		ld	hl,(sektrk)
		ld	(hsttrk),hl
		ld	a,(sekhst)
		ld	(hstsec),a
		ld	a,(rsflag)		;need to read?
		or	a
		call	nz,readhst		;yes, if 1
		xor	a		;0 to accum
		ld	(hstwrt),a		;no pending write
;
match:
		;copy data to or from buffer
		ld	a,(seksec)		;mask buffer number
		and	secmsk		;least signif bits
		ld	l,a		;ready to shift
		ld	h,0		;double count
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
;		hl has relative host buffer address
		ld	de,hstbuf
		add	hl,de		;hl = host address
		ex	de,hl			;now in DE
		ld	hl,(dmaAddr)		;get/put CP/M data
		ld	c,128		;length of move
		ld	a,(readop)		;which way?
		or	a
		jr	nz,rwmove		;skip if read
;
;	write operation, mark and switch direction
		ld	a,1
		ld	(hstwrt),a		;hstwrt = 1
		ex	de,hl			;source/dest swap
;
rwmove:
		;C initially 128, DE is source, HL is dest
		ld	a,(de)		;source character
		inc	de
		ld	(hl),a		;to dest
		inc	hl
		dec	c		;loop 128 times
		jr	nz,rwmove
;
;		data has been moved to/from host buffer
		ld	a,(wrtype)		;write type
		cp	wrdir		;to directory?
		ld	a,(erflag)		;in case of errors
		ret	nz			;no further processing
;
;		clear host buffer for directory write
		or	a		;errors?
		ret	nz			;skip if so
		xor	a		;0 to accum
		ld	(hstwrt),a		;buffer written
		call	writehst
		ld	a,(erflag)
		ret

;------------------------------------------------------------------------------------------------
;Utility subroutine for 16-bit compare
sektrkcmp:
		;HL = .unatrk or .hsttrk, compare with sektrk
		ex	de,hl
		ld	hl,sektrk
		ld	a,(de)		;low byte compare
		cp	(HL)		;same?
		ret	nz			;return if not
;		low bytes equal, test high 1s
		inc	de
		inc	hl
		ld	a,(de)
		cp	(hl)	;sets flags
		ret

;================================================================================================
; Convert track/head/sector into LBA for physical access to the disk
;================================================================================================
setLBAaddr:	
		LD	HL,(hsttrk)
		RLC	L
		RLC	L
		RLC	L
		RLC	L
		RLC	L
		LD	A,L
		AND	0E0H
		LD	L,A
		LD	A,(hstsec)
		ADD	A,L
		LD	(lba0),A

		LD	HL,(hsttrk)
		RRC	L
		RRC	L
		RRC	L
		LD	A,L
		AND	01FH
		LD	L,A
		RLC	H
		RLC	H
		RLC	H
		RLC	H
		RLC	H
		LD	A,H
		AND	020H
		LD	H,A
		LD	A,(hstdsk)
		RLC	a
		RLC	a
		RLC	a
		RLC	a
		RLC	a
		RLC	a
		AND	0C0H
		ADD	A,H
		ADD	A,L
		LD	(lba1),A

		LD	A,(hstdsk)
		RRC	A
		RRC	A
		AND	03H
		LD	(lba2),A

		LD	a,00H
		LD	(lba3),A

		; Transfer LBA to disk (LBA3 not used on SD card)
		LD	A,(lba2)
		OUT	(SD_LBA2),A
		LD	A,(lba1)
		OUT	(SD_LBA1),A
		LD	A,(lba0)
		OUT	(SD_LBA0),A
		RET
		
;================================================================================================
; Read physical sector from host
;================================================================================================

readhst:
		PUSH 	AF
		PUSH 	BC
		PUSH 	HL

rdWait1: IN	A,(SD_STATUS)
		CP	128
		JR	NZ,rdWait1
		
		CALL 	setLBAaddr
		
		LD	A,$00	; 00 = Read block
		OUT	(SD_CONTROL),A

		LD 	c,4
		LD 	HL,hstbuf
rd4secs:
		LD 	b,128
rdByte:

rdWait2: IN	A,(SD_STATUS)
		CP	224	; Read byte waiting
		JR	NZ,rdWait2

		IN	A,(SD_DATA)

		LD 	(HL),A
		INC 	HL
		dec 	b
		JR 	NZ, rdByte
		dec 	c
		JR 	NZ,rd4secs

		POP 	HL
		POP 	BC
		POP 	AF

		XOR 	a
		ld	(erflag),a
		RET


;================================================================================================
; Write physical sector to host
;================================================================================================

writehst:
		PUSH 	AF
		PUSH 	BC
		PUSH 	HL

wrWait1: IN	A,(SD_STATUS)
		CP	128
		JR	NZ,wrWait1

		CALL 	setLBAaddr
		
		LD	A,$01	; 01 = Write block
		OUT	(SD_CONTROL),A
	
		LD 	c,4
		LD 	HL,hstbuf
wr4secs:
		LD 	b,128
wrByte:
	
wrWait2: IN	A,(SD_STATUS)
		CP	160 ; Write buffer empty
		JR	NZ,wrWait2

		LD 	A,(HL)
		OUT	(SD_DATA),A
		INC 	HL
		dec 	b
		JR 	NZ, wrByte

		dec 	c
		JR 	NZ,wr4secs

		POP 	HL
		POP 	BC
		POP 	AF
		
		XOR 	a
		ld	(erflag),a
		RET

;================================================================================================
; Utilities
;================================================================================================

printInline:
		EX 	(SP),HL 	; PUSH HL and put RET ADDress into HL
		PUSH 	AF
		PUSH 	BC
nextILChar:	LD 	A,(HL)
		CP	0
		JR	Z,endOfPrint
		LD  	C,A
		CALL 	conout		; Print to TTY
		iNC 	HL
		JR	nextILChar
endOfPrint:	INC 	HL 		; Get past "null" terminator
		POP 	BC
		POP 	AF
		EX 	(SP),HL 	; PUSH new RET ADDress on stack and restore HL
		RET

;================================================================================================
; Data storage
;================================================================================================

dirbuf: 	.ds 128 		;scratch directory area
alv00: 		.ds 257			;allocation vector 0
alv01: 		.ds 257			;allocation vector 1
alv02: 		.ds 257			;allocation vector 2
alv03: 		.ds 257			;allocation vector 3
alv04: 		.ds 257			;allocation vector 4
alv05: 		.ds 257			;allocation vector 5
alv06: 		.ds 257			;allocation vector 6
alv07: 		.ds 257			;allocation vector 7
alv08: 		.ds 257			;allocation vector 8
alv09: 		.ds 257			;allocation vector 9
alv10: 		.ds 257			;allocation vector 10
alv11: 		.ds 257			;allocation vector 11
alv12: 		.ds 257			;allocation vector 12
alv13: 		.ds 257			;allocation vector 13
alv14: 		.ds 257			;allocation vector 14
alv15: 		.ds 257			;allocation vector 15

lba0		.DB	00h
lba1		.DB	00h
lba2		.DB	00h
lba3		.DB	00h

		.DS	020h		; Start of BIOS stack area.
biosstack:	.EQU	$

sekdsk:		.ds	1		;seek disk number
sektrk:		.ds	2		;seek track number
seksec:		.ds	2		;seek sector number
;
hstdsk:		.ds	1		;host disk number
hsttrk:		.ds	2		;host track number
hstsec:		.ds	1		;host sector number
;
sekhst:		.ds	1		;seek shr secshf
hstact:		.ds	1		;host active flag
hstwrt:		.ds	1		;host written flag
;
unacnt:		.ds	1		;unalloc rec cnt
unadsk:		.ds	1		;last unalloc disk
unatrk:		.ds	2		;last unalloc track
unasec:		.ds	1		;last unalloc sector
;
erflag:		.ds	1		;error reporting
rsflag:		.ds	1		;read sector flag
readop:		.ds	1		;1 if read operation
wrtype:		.ds	1		;write operation type
dmaAddr:	.ds	2		;last dma address
hstbuf:		.ds	512		;host buffer

hstBufEnd:	.EQU	$

biosEnd:	.EQU	$

; Disable the ROM, pop the active IO port from the stack (supplied by monitor),
; then start CP/M
popAndRun:
		LD	A,$01 
		OUT	($38),A

		POP	AF
		CP	$01
		JR	Z,consoleAtB
		LD	A,$01 ;(List is TTY:, Punch is TTY:, Reader is TTY:, Console is CRT:)
		JR	setIOByte
consoleAtB:	LD	A,$00 ;(List is TTY:, Punch is TTY:, Reader is TTY:, Console is TTY:)
setIOByte:	LD (iobyte),A
		JP	bios


;=================================================================================
; Relocate TPA area from 4100 to 0100 then start CP/M
; Used to manually transfer a loaded program after CP/M was previously loaded
;=================================================================================

		.org	0FFE8H
		LD	A,$01
		OUT	($38),A

		LD	HL,04100H
		LD	DE,00100H
		LD	BC,08F00H
		LDIR
		JP	bios

;=================================================================================
; Normal start CP/M vector
;=================================================================================

		.ORG 0FFFEH
		.dw	popAndRun

		.END
