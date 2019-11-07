	title 'Grant Searle SD-card driver with mount feature'

;    CP/M-80 Version 3     --  Modular BIOS

;	Disk I/O Module for SBC multi volume SD-card

	;	Initial version 0.01,
	;	0.1 - added RAMDISK

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
	extrn	?bank,xbuf	; RAMDISK

    ; Port Address Equates

SD$DATA		equ 088H
SD$CONTROL	equ 089H
SD$STATUS	equ 089H
SD$LBA0		equ 08AH
SD$LBA1		equ 08BH
SD$LBA2		equ 08CH

SD$OUT		equ 0
SD$IN		equ 1

    ; common control characters

cr	equ 13
lf	equ 10
bell	equ 7

mmu$select	equ 0F8h	; use 2 bits to select which one of
				; 4 16k blocks to change
mmu$frame	equ 0FDh	; use 5 bits to remap to one of 32
				; locations in sram

    ; Extended Disk Parameter Headers (XPDHs)

	; disk A:
	dw sd$write
	dw sd$read
	dw sd$login
	dw sd$init
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
	dw sd$write
	dw sd$read
	dw sd$login
	dw sd$init
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
	dw sd$write
	dw sd$read
	dw sd$login
	dw sd$init
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
	db 11110000b	; AL0 - 1 bit set per directory block
	db 0		; AL1 -            "
	dw 0080h	; CKS - DIR check vector size (DRM+1)/4
	dw 1		; OFF - Reserved tracks
	db 2		; PSH
	db 3		; PSM

dpbr:
	; disk size = 56 (24) tracks / 128 sectors / 448 (192) blocks
	; each track is a 16 k SRAM block. 
	dw 128		; SPT - sectors per track
	db 4		; BSH - block shift factor
	db 15		; BLM - block mask
	db 0		; EXM - Extent mask
	dw 447		; DSM - Storage size (blocks - 1)
	dw 127		; DRM - Number of directory entries - 1
	db 11000000b	; AL0 - 1 bit set per directory block
	db 0		; AL1 -            "
	dw 0
	dw 8		; OFF - Reserved SRAM (128 k)
	db 0		; PSH
	db 0		; PSM

	dseg	; This is banked

mnttab:
	db -1		; define unmounted
	db -1		; for A:, B:, and C:
	db -1
	db -1		; always find unmounted at the end

sdtbl: dw rhd0,rhd1,rhd2	; shadow drivetable

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

sd$init:
	ret

sd$login:
	ret

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
		; -1=media error, 1=permanent error, 0=ok

sd$read:
	call set$lba			; make LBA out of diskinfo
	mvi b,0 ! mvi d,2		; set counters (b x d = 512 bytes)
	lhld @dma			; load data address
	call read$block
	xra a				; no error
	ret

sd$write:
	call set$lba			; make LBA out of diskinfo
	mvi b,0 ! mvi d,2		; set counters (b x d = 512 bytes)
	lhld @dma			; load destination address
	call write$block
	xra a				; all ok
	ret

set$lba:
	lda @rdrv ! mov c,a ! mvi b,0
	lxi h,mnttab ! dad b		; offset disk in mounttable
	mov a,m ! rrc ! rrc 		; get volume. line up with
	mov c,a ! ani 3Fh		; LBA frame filter high 6 bits
	out SD$LBA2			; send to sd-card
	mov a,c ! ani 0C0h ! mov c,a	; filter low 2 bits (placed high)
	lhld @trk ! mov a,h		; get high byte track, 
	rrc! rrc ! rrc			; line up with frame
	ora c ! mov c,a			; add remainder volume
	mov a,l ! rrc ! rrc ! rrc	; line up low byte
	mov l,a ! ani 1Fh ! ora c	; filter, add previous result
	out SD$LBA1			; send to sd-card
	mov a,l ! ani 0E0h ! mov c,a	; reclaim low 3 bits (placed high)
lba$wait:
	in SD$STATUS ! cpi 80h ! jnz lba$wait	; wait for disk ready
	lda @sect ! ora c		; fill in low 5 bits (sector)
	out SD$LBA0			; tell sd-card
	xra a ! inr a ! ret

	cseg	; bank switching ahead

read$block:
	lda @dbnk ! call ?bank			; switch to DMA bank
	mvi a,SD$OUT ! out SD$CONTROL		; select sdcard output
wait$read:
	in SD$STATUS ! cpi 0E0h ! jnz wait$read ; wait for char ready
	in SD$DATA ! mov m,a ! inx h		; read byte, store it
	dcr b ! jnz wait$read			; djnz next byte
	dcr d ! jnz wait$read			; djnz (D) next block
	lda @cbnk ! call ?bank			; back to page 0
	ret

write$block:
	lda @dbnk ! call ?bank			; switch to DMA bank
	mvi a,SD$IN ! out SD$CONTROL		; select sdcard input
wait$write:
	in SD$STATUS ! cpi 0A0h ! jnz wait$write	; wait buffer empty
	mov a,m ! out SD$DATA ! inx h		; output next byte
	dcr b ! jnz wait$write			; djnz (B) next byte
	dcr d ! jnz wait$write			; djnz (D) next block
	lda @cbnk ! call ?bank			; back to page 0
	ret

	; Ramdisk entry points
	; Ramdisk uses the xmove buffer for resident storage
	; memory quadrant 1 (4000 - 7FFF) is used as trackwindow
	; Make sure @trk @sect, @dma, @cbnk and @dbnk are held 
	; in resident memory (defined in bioskrnl.asm)
rd$init:
	mvi A,1 ! out mmu$select	; check for 1 or 2 SRAM chips
	mvi A,32 ! out mmu$frame
	lxi H,4100h ! mov m,a
	cmp m ! jz initOK
	xra A ! sta dpbr+6
	inr A ! sta dpbr+4
	mvi A,0C0h ! sta dpbr+5
initOK:	lda @cbnk ! call ?bank		; restore system bank
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
	mvi a,1 ! out mmu$select	; select quadrant 1 (4000-7FFF)
	mov a,l ! out mmu$frame		; move track into quadrant 1
	lhld @sect			; 0000-007F (HL)
	mov h,l ! mvi l,0		; 0000-7F00 (HL)
	db 0CBh,03Ch	; srl h		; 
	db 0CBh,01Dh	; rr l		; 0000-3F80 (HL)
	db 0CBh,0F4h	; set 6,h	; 4000-7F80 (HL)
	lxi d,xbuf			; DE holds buffer address
	lxi b,080h			; set sector size
	ret

sel$DMA:	; access DMA for read action
	lda @dbnk ! call ?bank		; switch to bank that holds DMA buffer
	lxi d,xbuf ! lhld @dma ! xchg	; HL holds xbuf, DE holds dma address
	lxi b,080h			; BC holds sector size
	ret

	end


