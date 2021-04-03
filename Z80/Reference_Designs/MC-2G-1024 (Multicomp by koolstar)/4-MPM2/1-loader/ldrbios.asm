;	MP/M 2.0 Loader BIOS
;	(modified CP/M 2.2 BIOS)

;	org	1700h

buff	equ	0080h	;default buffer address

;	jump vector for indiviual routines

	jmp	boot
wboote:	jmp	wboot
	jmp	const
	jmp	conin
	jmp	conout
	jmp	list
	jmp	punch
	jmp	reader
	jmp	home
	jmp	seldsk
	jmp	settrk
	jmp	setsec
	jmp	setdma
	jmp	read
	jmp	write
	jmp	pollpt		; list status poll
	jmp	sectran		; sector translation


;	we also assume the MDS system has four disk drives

numdisks equ	1	;number of drives available

consol: db 1

signon:
	db 0Dh,0Ah,'Grant Searle Multicomp MP/M-II Banked Xios (V2.1)',0Dh,0Ah,0

boot:
wboot:
	di
	db 0d9h			; exx
	mov a,b ! sta mnttab	; save active volume
	mov a,c ! sta consol	; save active console
	db 0d9h			; exx - save for main program

	xra	a		;0 to accumulator
	sta	hstact		;host buffer inactive
	sta	unacnt		;clear unalloc count

	lxi h,signon ! call print
	ret
	
print:
	mov a,m					; get character
	ora a ! rz				; quit if zero
	mov c,a ! call conout			; output character
	inx h ! jmp print			; go for more

ACIA0$C	equ 80h
ACIA0$D	equ 81h
ACIA1$C	equ 82h
ACIA1$D	equ 83h

conout:
	lda consol	; get active console
	cpi 0		; if acia 0
	jz tx0		; use tx0
tx1:	in ACIA1$C	; check for character 
	ani 2		; ready in acia 1
	jz tx1		; wait some more
	mov a,c		; get output character
	out ACIA1$D	; print it
	xra a		; all ok
	ret
tx0:
	in ACIA0$C	; check for character
	ani 2		; ready in acia 0
	jz tx0		; wait some more
	mov a,c		; get output character
	out ACIA0$D	; print it
	xra a		; all ok
	ret		; 
	
const:
conin:
list:
punch:
reader:
pollpt:
	ret

;*********************************************************
;*                                                       *
;*      Sector Deblocking Algorithms for MP/M II V2.0    *
;*                                                       *
;*********************************************************
;;
;*****************************************************
;*                                                   *
;*         MP/M to host disk constants               *
;*                                                   *
;*****************************************************

blksiz	equ	4096		;MP/M allocation size
hstsiz	equ	512		;host disk sector size
hstspt	equ	32		;host disk sectors/trk
hstblk	equ	hstsiz/128	;MP/M sects/host buff
cpmspt	equ	hstblk * hstspt	;MP/M sectors/track
secmsk	equ	hstblk-1	;sector mask
secshf	equ	2		;log2(hstblk)
;
;*****************************************************
;*                                                   *
;*        BDOS constants on entry to write           *
;*                                                   *
;*****************************************************
wrall	equ	0		;write to allocated
wrdir	equ	1		;write to directory
wrual	equ	2		;write to unallocated
;
;*****************************************************
;*                                                   *
;*	The BDOS entry points given below show the   *
;*      code which is relevant to deblocking only.   *
;*                                                   *
;*****************************************************
;
;	DISKDEF macro, or hand coded tables go here
dpbase	equ	$		;disk param block base
dbh0:	dw 0,0,0,0,dirbuf,dpb,0,alv0

dpb:	dw 128		; SPT - sectors per track
	db 5		; BSH - block shift factor
	db 31		; BLM - block mask
	db 1		; EXM - Extent mask
	dw 2043		; 2047-4) DSM - Storage size (blocks - 1)
	dw 511		; DRM - Number of directory entries - 1
	db 240		; AL0 - 1 bit set per directory block
	db 0		; AL1 -            "
	dw 0000h	; CKS - DIR check vector size (DRM+1)/4
	dw 1		; OFF - Reserved tracks
;
seldsk:	call boot ! mvi a,0C9h ! sta boot
	xra a			; selected disknumber
	sta sekdsk		; seek disk number
	lxi h,dpbase		; base of parm block
	ret
;
home:
	; home the selected disk
	lda hstwrt		; check for pending write
	ora a
	jnz homed
	sta hstact		; clear host active flag
homed:
	lxi b,0000h
;
settrk:
	; set track given by registers bc
	mov h,b
	mov l,c
	shld sektrk		; track to seek
	ret
;
setsec:
	;set sector given by register c 
	mov	a,c
	sta	seksec		;sector to seek
	ret
;
setdma:
	;set dma address given by BC
	mov	h,b
	mov	l,c
	shld	dmaadr
	ret
;
sectran:
	;translate sector number BC
	mov	h,b
	mov	l,c
	ret
;
;*****************************************************
;*                                                   *
;*	The READ entry point takes the place of      *
;*	the previous BIOS defintion for READ.        *
;*                                                   *
;*****************************************************
read:
	;read the selected MP/M sector
	xra	a
	sta	unacnt		;unacnt = 0
	inr	a
	sta	readop		;read operation
	sta	rsflag		;must read data
	mvi	a,wrual
	sta	wrtype		;treat as unalloc
	jmp	rwoper		;to perform the read
;
;*****************************************************
;*                                                   *
;*	The WRITE entry point takes the place of     *
;*	the previous BIOS defintion for WRITE.       *
;*                                                   *
;*****************************************************
write:
	;write the selected MP/M sector
	xra	a		;0 to accumulator
	sta	readop		;not a read operation
	mov	a,c		;write type in c
	sta	wrtype
	ani	wrual		;write unallocated?
	jz	chkuna		;check for unalloc
;
;	write to unallocated, set parameters
	mvi	a,blksiz/128	;next unalloc recs
	sta	unacnt
	lda	sekdsk		;disk to seek
	sta	unadsk		;unadsk = sekdsk
	lhld	sektrk
	shld	unatrk		;unatrk = sectrk
	lda	seksec
	sta	unasec		;unasec = seksec
;
chkuna:
	;check for write to unallocated sector
	lda	unacnt		;any unalloc remain?
	ora	a
	jz	alloc		;skip if not
;
;	more unallocated records remain
	dcr	a		;unacnt = unacnt-1
	sta	unacnt
	lda	sekdsk		;same disk?
	lxi	h,unadsk
	cmp	m		;sekdsk = unadsk?
	jnz	alloc		;skip if not
;
;	disks are the same
	lxi	h,unatrk
	call	sektrkcmp	;sektrk = unatrk?
	jnz	alloc		;skip if not
;
;	tracks are the same
	lda	seksec		;same sector?
	lxi	h,unasec
	cmp	m		;seksec = unasec?
	jnz	alloc		;skip if not
;
;	match, move to next sector for future ref
	inr	m		;unasec = unasec+1
	mov	a,m		;end of track?
	cpi	cpmspt		;count MP/M sectors
	jc	noovf		;skip if no overflow
;
;	overflow to next track
	mvi	m,0		;unasec = 0
	lhld	unatrk
	inx	h
	shld	unatrk		;unatrk = unatrk+1
;
noovf:
	;match found, mark as unnecessary read
	xra	a		;0 to accumulator
	sta	rsflag		;rsflag = 0
	jmp	rwoper		;to perform the write
;
alloc:
	;not an unallocated record, requires pre-read
	xra	a		;0 to accum
	sta	unacnt		;unacnt = 0
	inr	a		;1 to accum
	sta	rsflag		;rsflag = 1
;
;*****************************************************
;*                                                   *
;*	Common code for READ and WRITE follows       *
;*                                                   *
;*****************************************************
rwoper:
	;enter here to perform the read/write
	xra	a		;zero to accum
	sta	erflag		;no errors (yet)
	lda	seksec		;compute host sector
	rept	secshf
	ora	a		;carry = 0
	rar			;shift right
	endm
	sta	sekhst		;host sector to seek
;
;	active host sector?
	lxi	h,hstact	;host active flag
	mov	a,m
	mvi	m,1		;always becomes 1
	ora	a		;was it already?
	jz	filhst		;fill host if not
;
;	host buffer active, same as seek buffer?
	lda	sekdsk
	lxi	h,hstdsk	;same disk?
	cmp	m		;sekdsk = hstdsk?
	jnz	nomatch
;
;	same disk, same track?
	lxi	h,hsttrk
	call	sektrkcmp	;sektrk = hsttrk?
	jnz	nomatch
;
;	same disk, same track, same buffer?
	lda	sekhst
	lxi	h,hstsec	;sekhst = hstsec?
	cmp	m
	jz	match		;skip if match
;
nomatch:
	;proper disk, but not correct sector
	lda	hstwrt		;host written?
	ora	a
	cnz	writehst	;clear host buff
;
filhst:
	;may have to fill the host buffer
	lda	sekdsk
	sta	hstdsk
	lhld	sektrk
	shld	hsttrk
	lda	sekhst
	sta	hstsec
	lda	rsflag		;need to read?
	ora	a
	cnz	readhst		;yes, if 1
	xra	a		;0 to accum
	sta	hstwrt		;no pending write
;
match:
	;copy data to or from buffer
	lda	seksec		;mask buffer number
	ani	secmsk		;least signif bits
	mov	l,a		;ready to shift
	mvi	h,0		;double count
	rept	7		;shift left 7
	dad	h
	endm
;	hl has relative host buffer address
	lxi	d,hstbuf
	dad	d		;hl = host address
	xchg			;now in DE
	lhld	dmaadr		;get/put MP/M data
	mvi	c,128		;length of move
	lda	readop		;which way?
	ora	a
	jnz	rwmove		;skip if read
;
;	write operation, mark and switch direction
	mvi	a,1
	sta	hstwrt		;hstwrt = 1
	xchg			;source/dest swap
;
rwmove:
	;C initially 128, DE is source, HL is dest
	ldax	d		;source character
	inx	d
	mov	m,a		;to dest
	inx	h
	dcr	c		;loop 128 times
	jnz	rwmove
;
;	data has been moved to/from host buffer
	lda	wrtype		;write type
	ani	wrdir		;to directory?
	lda	erflag		;in case of errors
	rz			;no further processing
;
;	clear host buffer for directory write
	ora	a		;errors?
	rnz			;skip if so
	xra	a		;0 to accum
	sta	hstwrt		;buffer written
	call	writehst
	lda	erflag
	ret
;
;*****************************************************
;*                                                   *
;*	Utility subroutine for 16-bit compare        *
;*                                                   *
;*****************************************************
sektrkcmp:
	;HL = .unatrk or .hsttrk, compare with sektrk
	xchg
	lxi	h,sektrk
	ldax	d		;low byte compare
	cmp	m		;same?
	rnz			;return if not
;	low bytes equal, test high 1s
	inx	d
	inx	h
	ldax	d
	cmp	m	;sets flags
	ret
;
;*****************************************************
;*                                                   *
;*	WRITEHST performs the physical write to      *
;*	the host disk, READHST reads the physical    *
;*	disk.					     *
;*                                                   *
;*****************************************************
sd$data		equ 088h
sd$control	equ 089h
sd$status	equ 089h
sd$lba0		equ 08ah
sd$lba1		equ 08bh
sd$lba2		equ 08ch

sd$read		equ 0
sd$write	equ 1

writehst:
	;hstdsk = host disk #, hsttrk = host track #,
	;hstsec = host sect #. write "hstsiz" bytes
	;from hstbuf and return error flag in erflag.
	;return erflag non-zero if error
	push b
	push d
	push h
	
	call setlba

	mvi b,0			; count in b (0 is 256 loops)
	mvi d,2
	lxi h,hstbuf		; destination Address
	
	mvi a,sd$write		; select SD blockwrite
	out sd$control

whst1:	in sd$status
	cpi 0A0H		; write buffer empty
	jnz whst1
	mov a,m
	out sd$data
	inx h
	dcr b ! jnz whst1	; repeated 256 times
	dcr d ! jnz whst1	; times 2 makes 512 bytes = 1 SD block
	
	pop h
	pop d
	pop b
	
	xra a
	sta erflag
	ret

readhst:
	;hstdsk = host disk #, hsttrk = host track #,
	;hstsec = host sect #. read "hstsiz" bytes
	;into hstbuf and return error flag in erflag.
	push b
	push d
	push h
	
	call setlba

	mvi b,0			; count in b (0 is 256 loops)
	mvi d,2
	lxi h,hstbuf		; destination Address
	
	mvi a,sd$read		; select SD blockread
	out sd$control

rhst1:	in sd$status
	cpi 0E0H		; read data ready
	jnz rhst1
	in sd$data
	mov m,a
	inx h
	dcr b ! jnz rhst1	; repeated 256 times
	dcr d ! jnz rhst1	; times 2 makes 512 bytes = 1 SD block

	pop h
	pop d
	pop b

	xra a
	sta erflag
	ret

; =============================================================================
; Convert track/head/sector into LBA for physical access to the disk
; routine destroys AF, HL and BC
; =============================================================================
setlba:		; don't save registers. this routine is called from 
		; readhst and writehst which already saves them
	
	lda hstdsk
	mov c,a
	mvi b,0
	lxi h,mnttab
	dad b
	mov a,m
	rrc
	rrc
	mov c,a
	ani 03Fh
	out sd$lba2
	mov a,c
	ani 0C0h
	mov c,a
	lhld hsttrk
	mov a,h
	rrc
	rrc
	rrc
	ora c
	mov c,a
	mov a,l
	rrc
	rrc
	rrc
	mov l,a
	ani 1Fh
	ora c
	out sd$lba1
	mov a,l
	ani 0E0h
	mov c,a	
lba1	in sd$status
	cpi 080h
	jnz lba1
	lda hstsec
	ora c
	out sd$lba0
	ret

; Disk mount table 

;*****************************************************
;*                                                   *
;*	Unitialized RAM data areas		     *
;*                                                   *
;*****************************************************
;
mnttab:	db -1		; volume for disk A: to be filled in on cold boot
	db -1		; volume for disk B:
	db -1		; volume for disk C:

sekdsk:	ds	1		;seek disk number
sektrk:	ds	2		;seek track number
seksec:	ds	1		;seek sector number
;
hstdsk:	ds	1		;host disk number
hsttrk:	ds	2		;host track number
hstsec:	ds	1		;host sector number
;
sekhst:	ds	1		;seek shr secshf
hstact:	ds	1		;host active flag
hstwrt:	ds	1		;host written flag
;
unacnt:	ds	1		;unalloc rec cnt
unadsk:	ds	1		;last unalloc disk
unatrk:	ds	2		;last unalloc track
unasec:	ds	1		;last unalloc sector
;
erflag:	ds	1		;error reporting
rsflag:	ds	1		;read sector flag
readop:	ds	1		;1 if read operation
wrtype:	ds	1		;write operation type
dmaadr:	ds	2		;last dma address
hstbuf:	ds	hstsiz		;host buffer
;
;*****************************************************
;*                                                   *
;*	The ENDEF macro invocation goes here	     *
;*                                                   *
;*****************************************************
hstBufEnd:	equ	$

dirbuf:	ds 128
alv0:	ds 256

	end




