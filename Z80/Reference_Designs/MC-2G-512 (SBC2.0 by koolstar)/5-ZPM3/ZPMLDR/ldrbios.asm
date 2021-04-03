; loaderbios for Grant Searle's multicomputer (CP/M version)
; passes on default console and bootvolule to loaded OS in 
; alternate registers B' and C' (B' is Bootvolume, C' is Console)

SD$DATA		equ	088h
SD$CONTROL	equ	089h
SD$STATUS	equ	089h
SD$LBA0		equ	08Ah
SD$LBA1		equ	08Bh
SD$LBA2		equ	08Ch

ACIA0$D		EQU	81h
ACIA0$C		EQU	80h
ACIA1$D		EQU	83h
ACIA1$C		EQU	82h

SD$OUT		equ	0
SD$IN		equ	1

	public mnttab,consol

	org $

	jmp boot
	jmp nooper
	jmp nooper
	jmp nooper
	jmp conout
	jmp nooper
	jmp nooper
	jmp nooper
	jmp home
	jmp seldsk
	jmp settrk
	jmp setsec
	jmp setdma
	jmp read
	jmp nooper
	jmp nooper
	jmp scrtn
	jmp nooper
	jmp nooper
	jmp nooper
	jmp nooper
	jmp nooper
	jmp nooper
	jmp nooper
	jmp nooper
	jmp ?move
	jmp nooper
	jmp nooper
	jmp nooper
	jmp nooper
	jmp 00000h
	jmp 00000h
	jmp 00000h

rhd0:	dw 0			; XLT
	db 0,0,0,0,0,0,0,0,0	; null
	db 0			; MF
	dw dpbhd8s		; DPP
	dw 0			; CSV
	dw alv0			; ALV
	dw dirbcb0		; DIRBCB
	dw dtabcb0		; DTABCB
	dw 0FFFFh		; HASH
	db 0			; HBANK

alv0:	ds 505

dpbhd8s:
	dw 128		; SPT - sectors per track
	db 5		; BSH - block shift factor
	db 31		; BLM - block mask
	db 1		; EXM - Extent mask
	dw 2043		; 2047-4) DSM - Storage size (blocks - 1)
	dw 511		; DRM - Number of directory entries - 1
	db 240		; AL0 - 1 bit set per directory block
	db 0		; AL1 -            "
	dw 8000h	; CKS - DIR check vector size (DRM+1)/4
	dw 1		; OFF - Reserved tracks
	db 2		; PSH
	db 3		; PSM

dirbcb0:
	db 0ffh		; drv
	ds 3		; rec
	db 0		; wflg
	db 0		; null
	dw 0		; track
	dw 0		; sector
	dw dirbuf0	; buffer address

dirbuf0:
	ds 512

dtabcb0:
	db 0ffh		; drv
	ds 3		; rec
	db 0		; wflg
	db 0		; null
	dw 0		; track
	dw 0		; sector
	dw dtabuf0	; buffer address

dtabuf0:
	ds 512

mnttab:	db 0		; not mounted

consol: db 1

signon:
	db 0Dh,0Ah,'CP/M V3.0 LoaderBIOS for Grant Searle',027h,'s Multicomputer',0Dh,0Ah,0


	; active volume and active acia were stored in address 0000-0001
	; by the popandrun action.
boot:
	di
	db 0D9h			; exx
	mov a,b ! sta mnttab	; retrieve boot disk
	mov a,c ! sta consol	; retrieve active console
	db 0D9h			; exx : save for main program

	lxi h,signon ! call print
	ret

nooper:
	ret

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


adrv:	ds 1		; currently selected disk drive
;rdrv:	ds 1		; controller relative disk drive
trk:	ds 2		; current track number
sect:	ds 2		; current sector number
dma:	ds 2		; current DMA address
;cnt:	db 0		; record count for multisector transfer
;dbnk:	db 0		; bank for DMA operations

home:	lxi b,00000h ! jmp settrk

seldsk:	lxi h,rhd0 ! mvi a,0 ! sta adrv ! ret

settrk:	mov l,c ! mov h,b ! shld trk ! ret

setsec:	mov l,c ! mov h,b ! shld sect ! ret

scrtn:	mov h,b ! mov l,c ! ret

setdma:	mov l,c ! mov h,b ! shld dma ! ret

read:
	push b ! push d ! push h
	call set$lba				; turn sect, trk, vol into LBA
	mvi b,0 ! mvi d,2 ! lhld dma		; set counters, set DMA address
	mvi a,SD$OUT ! out SD$CONTROL		; tell driver to read sector
wait$rd:
	in SD$STATUS ! cpi 0E0h ! jnz wait$rd	; wait for byte ready to read
	in SD$DATA ! mov m,a ! inx h		; read byte store it
	dcr b ! jnz wait$rd			; do 256 times...
	dcr d ! jnz wait$rd			; ...twice
	pop h ! pop d ! pop b
	xra a					; all ok
	ret

set$lba:
	lda mnttab ! rrc ! rrc			; get volume, line up LBA
	mov c,a ! ani 3Fh			; top 6 bits make
	out SD$LBA2				; LBA part 2
	mov a,c ! ani 0C0h ! mov c,a		; reclaim 2 lower volume bits
	lhld trk ! mov a,h			; get tracknr, line up high
	rrc ! rrc ! rrc ! ora c ! mov c,a	; byte and add to volume
	mov a,l ! rrc ! rrc ! rrc		; get low byte, line up 
	mov l,a ! ani 1Fh ! ora c		; filter high 5 bits and add
	out SD$LBA1				; make LBA part 1
	mov a,l ! ani 0E0h ! mov c,a		; low 3 tracknumber bits...
lba$wait:
	in SD$STATUS ! cpi 80h ! jnz lba$wait	; wait for SD-card to be ready
	lda sect ! ora c			; with sectornumber (5 bits)
	out SD$LBA0				; make LBA part 0
	ret

print:
	mov a,m					; get character
	ora a ! rz				; quit if zero
	mov c,a ! call conout			; output character
	inx h ! jmp print			; go for more


?move:
	xchg
	db 0EDh,0B0h	;ldir
	xchg
	ret

	end

