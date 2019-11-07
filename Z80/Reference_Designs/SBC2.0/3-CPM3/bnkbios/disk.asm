	title 'Grant Searle SD-card driver with mount feature'

;    CP/M-80 Version 3     --  Modular BIOS

;	Disk I/O Module for SBC multi volume IDE-card interface (CF or SD)

	;	Initial version 0.01,

	dseg

    ; Disk drive dispatching tables for linked BIOS

	public	rhd0,rhd1,rhd2,rrd0
	public	dmount,mnttab

    ; Variables containing parameters passed by BDOS

	extrn	@adrv,@rdrv
	extrn	@dma,@trk,@sect
	extrn	@cbnk,@dbnk
	extrn	@dtbl

    ; System Control Block variables

	extrn	@ermde,@media	; BDOS error mode, media flag

    ; Utility routines in standard BIOS

	extrn	?wboot	; warm boot vector
	extrn	?pmsg	; print message @<HL> up to 00, saves <BC> & <DE>
	extrn	?pdec	; print binary number in <A> from 0 to 99.
	extrn	?pderr	; print BIOS disk error header
	extrn	?conin,?cono	; con in and out
	extrn	?const		; get console status
	extrn	?bank,xbuf

    ; Port Address Equates
IDE$DATA	equ	10h
IDE$FEATURES	equ	11h
IDE$ERROR	equ	11h
IDE$SECCOUNT	equ	12h
IDE$LBA0	equ	13h
IDE$LBA1	equ	14h
IDE$LBA2	equ	15h
IDE$LBA3	equ	16h
IDE$STATUS	equ	17h
IDE$CONTROL	equ	17h

;IDE Features
IDE$8BIT	equ	1
IDE$NOCACHE	equ	082h
;IDE Commands
IDE$READSEC	equ	020h
IDE$WRITESEC	equ	030h




    ; common control characters

cr	equ 13
lf	equ 10
bell	equ 7


    ; Extended Disk Parameter Headers (XPDHs)

	; disk A:
	dw ide$write
	dw ide$read
	dw ide$login
	dw ide$init
	db 0,0			; relative drive zero
rhd0:	dw 0			; XLT
	db 0,0,0,0,0,0,0,0,0	; null
	db 0			; MF
	dw dpbh			; DPB
	dw 0FFFEh		; CSV
	dw 0FFFEh		; ALV
	dw 0FFFEh		; DIRBCB
	dw 0FFFEh		; DTABCB
	dw 0FFFEh		; HASH
	db 2			; HBANK

	; disk B:
	dw ide$write
	dw ide$read
	dw ide$login
	dw ide$init
	db 1,0			; relative drive one
rhd1:	dw 0			; XLT
	db 0,0,0,0,0,0,0,0,0	; null
	db 0			; MF
	dw dpbh			; DPB
	dw 0FFFEh		; CSV
	dw 0FFFEh		; ALV
	dw 0FFFEh		; DIRBCB
	dw 0FFFEh		; DTABCB
	dw 0FFFEh		; HASH
	db 2			; HBANK

	; disk C:
	dw ide$write
	dw ide$read
	dw ide$login
	dw ide$init
	db 2,0		; relative drive two
rhd2:	dw 0			; XLT
	db 0,0,0,0,0,0,0,0,0	; null
	db 0			; MF
	dw dpbh			; DPB
	dw 0FFFEh		; CSV
	dw 0FFFEh		; ALV
	dw 0FFFEh		; DIRBCB
	dw 0FFFEh		; DTABCB
	dw 0FFFEh		; HASH
	db 2			; HBANK

	; disk M:
	dw rd$write
	dw rd$read
	dw rd$login
	dw rd$init
	db 3,0		; relative drive 3
rrd0:	dw 0			; XLT
	db 0,0,0,0,0,0,0,0,0	; null
	db 0			; MF
	dw dpbr			; DPB
	dw 0FFFEh		; CSV
	dw 0FFFEh		; ALV
	dw 0FFFEh		; DIRBCB
	dw 0FFFEh		; DTABCB
	dw 0FFFEh		; HASH
	db 2			; HBANK
	cseg	; DPB must be resident

	; 8 MB, psize=512, pspt=32, tks=512, bls=4k, ndirs=512, off=1

dpbh:
	dw 128		; SPT - sectors per track
	db 5		; BSH - block shift factor
	db 31		; BLM - block mask
	db 1		; EXM - Extent mask
	dw 2043		; 2047-4) DSM - Storage size (blocks - 1)
	dw 511		; DRM - Number of directory entries - 1
	db 240		; AL0 - 1 bit set per directory block
	db 0		; AL1 -            "
	dw 0080h	; CKS - DIR check vector size (DRM+1)/4
	dw 1		; OFF - Reserved tracks
	db 2		; PSH
	db 3		; PSM

dpbr:
	; disk size = 24 tracks / 128 sectors / 192 blocks
	; each track is a 16 k SRAM block. 
	dw 256		; SPT - sectors per track
	db 4		; BSH - block shift factor
	db 15		; BLM - block mask
	db 1		; EXM - Extent mask
	dw 191		; DSM - Storage size (blocks - 1)
	dw 127		; DRM - Number of directory entries - 1
	db 11000000b	; AL0 - 1 bit set per directory block
	db 0		; AL1 -            "
	dw 0
	dw 3		; OFF - Reserved SRAM (128 k)
	db 0		; PSH
	db 0		; PSM

	dseg	; rest is banked (almost, except disk read and write routines)

mnttab:
	db -1		; define unmounted
	db -1		; for A:, B:, and C:
	db -1
	db -1		; always find unmounted at the end

sdtbl: dw rhd0,rhd1,rhd2

dmount:		; on entry D=volume (0-FE), E=logical drive (0-2)
	lxi h,mnttab ! push h			; save for later
	mvi a,2 ! cmp e ! jc mount$nogo1	; drive > 2
	mov a,d ! lxi b,4 ! db 0edh,0b1h	; cpir
	jz mount$nogo 				; volume already mounted

mount$go:					; a = volume number e=drive
	pop h					; reclaim mounttable
	mvi d,0 ! dad d ! mov m,a ! push psw	; update mounttable
	mov l,e ! mvi h,0 ! dad h ! push h	; create index from drive code
	lxi d,sdtbl ! dad d			; get pointer to shadow dtbl
	mov a,m ! inx h ! mov h,m ! mov l,a	; point at DPH
	push h
	xchg ! lxi h,11 ! dad d			; point at MF in DPH
	mvi a,0FFh ! mov m,a ! sta @media	; set media flags
	pop b ! lxi d,@dtbl ! pop h ! dad d	; DBH addr in BC; @dtbl in HL
	mov m,c ! inx h ! mov m,b		; store DPH address in dtbl
	pop psw ! ret				; DE is address mnttab, ok, ret
mount$nogo:
	pop h ! mvi d,0 ! dad d ! mov a,m ! ret	; DE is mnttab, nok, ret
mount$nogo1:
	pop h ! mvi a,-1 ! ret


	; Disk I/O routines for standardized BIOS interface

	; Initialization entry point.

	; called for first time initialization.

ide$init:
	ret

ide$login:
	ret				; no disk and return

	; disk READ and WRITE entry points.

		; these entries are called with the following arguments:

			; relative drive number in @rdrv (8 bits)
			; absolute drive number in @adrv (8 bits)
			; disk transfer address in @dma (16 bits)
			; disk transfer bank	in @dbnk (8 bits)
			; disk track address	in @trk (16 bits)
			; disk sector address	in @sect (16 bits)
			; pointer to XDPH in <DE>

		; they transfer the appropriate data, perform retries
		; if necessary, then return an error code in <A>
		; -1=media error, 1=permanet error, 0=ok

ide$read:
	call set$lba
	call ide$wait
	mvi a,1 ! out IDE$SECCOUNT
	mvi a,IDE$READSEC ! out IDE$CONTROL
	mvi b,0 ! lhld @dma ! mvi c,IDE$DATA
	call read$block
	xra a ! ret

ide$write:
	call set$lba
	call ide$wait
	mvi a,1 ! out IDE$SECCOUNT
	mvi a,IDE$WRITESEC ! out IDE$CONTROL
	mvi b,0 ! lhld @dma ! mvi c,IDE$DATA
	call write$block
	xra a ! ret

set$lba:
	call ide$wait
	lhld @trk ! mov a,l ! ani 07h	; get low 3 bits track
	rrc ! rrc ! rrc			; move to position 5-7
	mov b,a ! lda @sect ! add b	; put sector in bits 4-0
	out IDE$LBA0			; output to IDE
	
	mov a,l ! ani 0F8h ! ora h	; retrieve 5 high bits of track
	rrc ! rrc ! rrc ! mov b,a	; move to position 4-0
	lda @rdrv ! mov e,a		; get logical disk
	mvi d,0 ! lxi h, mnttab ! dad d	; offset in mounttable
	mov a,m ! rrc ! rrc ! mov c,a	; get physical volume 
	ani 0C0h ! ora b ! out IDE$LBA1	; combine with 6 high bits track
	
	mov a,c ! ani 03Fh ! out IDE$LBA2 ; rest of volume
	
	mvi a,0E0h ! out IDE$LBA3	; LBA mode using drive 0 = E0h
	
	xra a ! inr a ! ret


	cseg	; bank switching ahead


read$block:
	lda @dbnk ! call ?bank
	call ide$wait
	db 0EDh,0B2h,0EDh,0B2h		; inir  inir
	lda @cbnk ! call ?bank
	ret
	
write$block:
	lda @dbnk ! call ?bank
	call ide$wait
	db 0EDh,0B3h,0EDh,0B3h		; otir  otir
	lda @cbnk ! call ?bank
	ret

ide$wait:
	in IDE$STATUS
	rlc ! jc ide$Wait
	ret

rd$init:
	ret

rd$login:
	ret

rd$read: 
	call sel$SRAM			; set HL,DE and BC for SRAM access
	db 0EDh,0B0h	;ldir		; copy data from SRAM to buffer
	call sel$DMA			; set HL,DE and BC for DMA access
	db 0EDh,0B0h	;ldir		; copy data from buffer to DMA
	lda @cbnk ! call ?bank		; restore system bank
	xra a
	ret

rd$write: 
	call sel$DMA ! xchg		; set HL,DE and BC for DMA access
	db 0EDh,0B0h	;ldir		; copy data from DMA to buffer
	call sel$SRAM ! xchg		; set HL,DE and BC for SRAM access
	db 0EDh,0B0h	;ldir		; copy data from buffer to SRAM
	lda @cbnk ! call ?bank		; restore system bank
	xra a
	ret

sel$SRAM:	;access SRAM for read action
	lhld @trk
	mov a,l ! call ?bank
	lhld @sect			; 0000-00FF (HL)
	mov h,l ! mvi l,0		; 0000-FF00 (HL)
	db 0CBh,03Ch	; srl h		; 
	db 0CBh,01Dh	; rr l		; 0000-7F80 (HL)
	lxi d,xbuf			; DE holds buffer address
	lxi b,080h			; set sector size
	ret

sel$DMA:	; access DMA for read action
	lda @dbnk ! call ?bank		; switch to bank that holds DMA buffer
	lxi d,xbuf ! lhld @dma ! xchg	; HL holds xbuf, DE holds dma address
	lxi b,080h			; BC holds sector size
	ret
	end
